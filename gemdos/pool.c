/*
***************************    POOL.C      ******************************
*
* $Revision: 2.8 $	$Source: /u2/MRS/osrevisions/gemdos/pool.c,v $
* =======================================================================
* $Author: apratt $ 	$Date: 90/08/03 13:42:23 $    $Locker:  $
* =======================================================================
*
* $Log: pool.c,v $
* Revision 2.8  90/08/03  13:42:23  apratt
* TTOS FINAL RELEASE
* 
* Revision 2.7  90/04/24  11:04:53  apratt
* Changed back to single-pmd memory model, and removed rover code.
* There is no rover any more.
* 
* Revision 2.6  90/01/02  18:05:27  apratt
* Fixed compact (at last!) - marking of vacated slot was wrong
* (marked the slot it was vacated TO!).
* 
* Revision 2.5  89/12/27  14:43:16  apratt
* Split code which handles the second discontiguous memory block out
* to be compiled only ifdef FASTRAM.
* 
* Revision 2.4  89/12/21  14:19:56  apratt
* Fixed another bug, not serious but bad: 'advance' didn't check to see
* if a block was cut before treating it as such.  Fortunately, it would
* have to find 0x00000001 in a field, which is a little unlikely in
* most big-block structs.  Also, after calling mdmove, the slot which 
* was vacated should have its m_own set to 1, not 0 (fixed).
* 
* Revision 2.3  89/12/20  18:00:44  apratt
* Fixed two BIG BUGS in this file.
* First, it could move the MD which the pmd's rover pointed to,
* causing infinite loops and other fun things.  Second, it didn't
* look on the fast-RAM lists (pmdfast) when looking for the md's
* it was moving.  Both fixed.
* 
* Revision 2.2  89/04/17  17:15:19  kbad
* YA header change
* 
* Revision 2.1  89/02/21  17:21:35  kbad
* *** TOS 1.4  FINAL RELEASE VERSION ***
* 
* Revision 1.3  88/07/06  10:14:13  apratt
* Removed incorrect '&' operator from "clear block before returning it"
* code.  Don't know why this ever compiled.  It worked before, and
* there's probably no change to the compiler output.  Aztec C caught it.
* 
* Revision 1.2  88/06/13  15:06:47  apratt
* Header style change
* 
* Revision 1.1  88/04/26  14:48:28  apratt
* Version used 4/22/88 to make test ROMs
* 
*************************************************************************
*/

/***********************************************************************\
* 									*
* GEMDOS OSpool management						*
* (C)1986 Atari Corp.							*
* 									*
* ---- Edit history (reverse order, please): ---------------------------*
* 									*
* 03-Mar-1988 akp	Started this new ospool allocator.		*
*									*
\***********************************************************************/

/***********************************************************************

The theory here is this: the OSPOOL is made up of lots of (possibly
discontinuous) big blocks.  They are singly-linked, and there's a type
byte in the header telling what's in the block.  A big block can be
either free (0), allocated (>0), or split into small blocks (<0). 

The header also has a byte (the last byte of the header, just before the
contents start) which is used to record the "time" (oscall number) that
the block was last touched (for freleaf processing; only large blocks).

When you need a little block, you look in the heap for a free little
block.  If there's not one there, you look for a free big block, and
split it up into four little blocks and use the first one.  If there are
no free big blocks, you check to see if any new blocks were added as
pool by somebody like FOLDR100...  For this reason, root[] is still
valid.  You add those blocks to the heap, and use one of those. 
Finally, you call freleaf to free up a big block.  If this fails, you're
history.  I don't know if a panic is in order here or not.  Maybe a
longjmp with an error ENSMEM. 

When you need a big block, the process is much the same: look for a free
big block or a cut block with no used blocks in it, then check to see if
more pool was added by some kind soul.  If there are four free little
blocks but they aren't in a row, compact the little-block storage, and
look again.  If there aren't four free blocks, call freleaf.  Then just
fail (panic). 

***********************************************************************

At the start of the world, this section needs to be initialized:
call poolinit() to do that.  This splits up the pool into big blocks.

Don't give me heat about the goto's: they save a lot of redundant code
and extra checking. 

**********************************************************************/

#include "fs.h"
#include "fsdecl.h"
#include "gemerror.h"

#ifdef POOLDEBUG

int _debug = 0;
#define Debug(s) (_debug ? trap14(11,5,-1,s) : 0)

#else

#define Debug(s) /*nothing*/

#endif POOLDEBUG

struct block {
    struct block *b_next;	/* next block in the heap */
    char b_type;		/* see Bis* predicates below */
    char b_callno;		/* used only if the block is big */
    union {
	char b_big[64];		/* either one big block, or... */
	MD b_mem[4];	/* four small blocks */
				/* if m_own is 1, little block is free */
    } b_data;
};

#define LSIZE sizeof(struct block)
#define HEADSIZE 6		/* size of header before data */

/* btype predicates */

#define Bisfree(bp) ((bp)->b_type == 0)		/* big and free */
#define Bisused(bp) ((bp)->b_type < 0)		/* big but used */
#define Biscut(bp)  ((bp)->b_type > 0)		/* cut up (have to check */
						/* free-ness individually) */
#define Bmakefree(bp) ((bp)->b_type = 0)
#define Bmakeused(bp) ((bp)->b_type = -1)
#define Bmakecut(bp)  ((bp)->b_type = 1)

char *root[20];			/* still used so people can give us pool */

#define LENOSM 80L*LSIZE	/* 80 blocks - 40 folders or so */

struct block *blockhead;	/* head of list of blocks in the system */

char osmem[LENOSM];

/* forward declarations */

struct block *compact(), *newpool();
MD *advance();
char *freleaf();

poolinit()
{
    Debug("print Enter xminit");
    blockhead = 0;
    addheap(osmem,LENOSM);
    Debug("print Leave xminit");
}

/*
 * addheap: cut a chunk of memory into big blocks.
 */

addheap(x_ptr,x_size)
struct block *x_ptr;
long x_size;
{
    REG struct block *ptr;
    REG long size;
    REG struct block *p;
    REG int i;

    ptr = x_ptr;
    size = x_size;

    Debug("print Enter addheap ptr: `a5 size: `d7");

    /* round size down to large block size */
    size = (size/LSIZE)*LSIZE;

    Debug("print addheap: rounded size is `d7");

    while (size) {
	ptr->b_next = blockhead;
	blockhead = ptr;
	Bmakefree(ptr);
	size -= LSIZE;
	Debug("print addheap block at `a5");
	ptr++;
    }

    Debug("print addheap returns");
}

/************************************************************************
 *
 * getbig: allocate a big block, return its data address
 *
 * Go through all blocks.  Look for a free one or a cut one with all
 * free little blocks inside.
 *
 * Failing that, look for new pool.
 *
 * Then try to compact the little block storage.
 *
 * Finally, call freleaf, and panic if that fails.
 *
 ***********************************************************************/

struct _dnd
*getbig()
{
    REG struct block *ptr;
    REG MD *md;
    REG int i;
    REG char *ptmp;
    REG int count;
    REG int lfree;	/* free small blocks in the whole pool */

    Debug("print Enter getbig... check for a free block");

    lfree = 0;

    for (ptr = blockhead; ptr; ptr = ptr->b_next) {
	if (Bisfree(ptr)) goto gotone;			/* joy! */
	else if (Biscut(ptr)) {
	    /* cut: see if all four are free */
	    count = 0;
	    for (md = &(ptr->b_data.b_mem[0]), i=3; i>=0; i--, md++) {
		if ((long)md->m_own == 1) {
		    lfree++;
		    count++;
		}
	    }
	    if (count == 4) {
	   	Debug("print Cut block `a5 is all free so use it");
	   	goto gotone;				/* all free! */
	    }
	}
    }

    /* well, no joy looking for free blocks... */

    Debug("print No free block... check for new pool");

    if (ptr = newpool()) goto gotone;

    /* no new pool, either... */

    Debug("print -n No new pool ...");
    if (lfree >= 4) {
	Debug("print enough free to compact: try that.");
	if (ptr = compact()) goto gotone;
	/* panic: compact failed (shouldn't happen) */
	goto abort;
    }
    Debug("print not enough to try compact");

    /* can't compact little blocks... Have to free a big one */
    
    Debug("print Last resort: call freleaf");

    if (ptmp = freleaf()) {
	ptr = (struct block *)(ptmp-HEADSIZE);
	goto gotone;
    }
    
    /* panic with a message like "out of ospool, use FOLDR100" */
abort:
    Panic();

    /*
     * Common code for success; ptr is the guy we got
     */

gotone:
    Debug("print Gotone at `a5 ... make it used & return it");
    Bmakeused(ptr);

    /* clear block before returning it */

    for (ptmp = &(ptr->b_data); ptmp < (ptr+1); ptmp += 4)
    	*(long *)ptmp = 0L;

    return (char *)(&ptr->b_data);
}

/************************************************************************
 *
 * newpool: check for new pool from somebody like FOLDR100, and
 * add it to the heap.  Return a pointer to one of the blocks.
 *
 * Note that the added pool may not be contiguous; break it as 
 * efficiently as possible, of course.
 *
 * The struct pool here matches what pool blocks should look like
 * when they are added by FOLDR100 (for instance): just a bunch of
 * 66-byte blocks where the first long points to the next block.
 *
 ***********************************************************************/

struct block
*newpool()
{
    REG struct pool {
	struct pool *p_next;
	char data[62];
    } *pool;
    REG struct pool *next;
    REG struct pool *end;

    Debug("print enter newpool");

    pool = (struct pool *)root[4];    /* root[4] is where pool gets added */

    if (!pool) return 0;

    while (pool) {
	Debug("print top of loop: pool = `a5");
	next = pool;

	/* skip until noncontiguous */
	while (next->p_next && next->p_next == next+1) 
		next = next->p_next;

	end = next+1;

	next = next->p_next;	/* keep this for next time */

	Debug("print contiguous: pool `a5 thru end `a3 .. next is `a4");

	/* add heap (will do nothing if too small) */
	addheap(pool,((char *)end)-((char *)pool));

	/* set pool = next and look for another contiguous block */
	pool = next;
    }
    Debug("print newpool returns (lpeek ._blockhe)");

    /* ensure that next call won't see this same stuff */
    root[4] = 0;

    return blockhead;
}

/************************************************************************
 *
 * getsmall: return a pointer to a small block.  Return NULL if none.
 *
 * This looks for a cut block with a free slot, and cuts an uncut
 * block only if it has to.
 *
 * If there are no uncut blocks, it looks for more pool, then calls
 * freleaf to free up a big one.
 *
 ***********************************************************************/

MD
*getsmall()
{
    REG struct block *ptr;
    REG struct block *free;
    REG MD *md;
    char *ptmp;
    REG int i;

    Debug("print enter getsmall");

    free = 0;

    for (ptr = blockhead; ptr; ptr = ptr->b_next) {
	if (Bisfree(ptr)) free = ptr;
	else if (Biscut(ptr)) {
	    for (md = &(ptr->b_data.b_mem[0]), i=3; i>=0; i--, md++) {
		if ((long)md->m_own == 1) {
		    Debug("print hole in cut block `a5 , `d7 ... return it");
		    goto gotmd;
		}
	    }
	}
    }

    /* there were no cut blocks with free slots */

    Debug("print no unstuffed cut blocks");

    if (free) {
	Debug("print -n ...but there was a free block ...");
	ptr = free;
	goto cutit;
    }

    /* there were no free uncut blocks, either */

    Debug("print And no free uncut either");

    if (ptr = newpool()) {
	Debug("print -n newpool worked!");
	goto cutit;
    }

    /* there was no more pool */
    
    Debug("print newpool struck out");
    if (ptmp = freleaf()) {
	Debug("print -n Freleaf worked!");
	ptr = (struct block *)(ptmp-HEADSIZE);
	goto cutit;
    }

    /* we struck out */

    return 0;

cutit:
    Debug("print cut block at `a5 & return it");
    Bmakecut(ptr);

    /* mark first three free */
    md = &(ptr->b_data.b_mem[0]);
    *(long *)&((md++)->m_own) = 1;
    *(long *)&((md++)->m_own) = 1;
    *(long *)&((md++)->m_own) = 1;

gotmd:
    /* clear block before returning it (incidentally marks as not free) */
    md->m_link = md->m_start = md->m_length = md->m_own = 0L;

    return md;
}

/************************************************************************
 *
 * Compact: try to compact storage.  Called if there are four free
 * small blocks, and we want to make one big block out of them.
 *
 * This routine MUST NOT be called if there are fewer than four free
 * blocks in the heap.  It does correctly handle the case where there
 * is a completely free cut block in the heap (it returns that block).
 *
 ***********************************************************************/

struct block
*compact()
{
    struct block *dptr;
    REG struct block *sptr;
    REG struct block *ptr;
    REG MD *md;
    REG int i;
    REG int sindex;
    REG int count;
    REG int maxcount;
    int dindex;
    MD *dest_md;


    /* find the cut block with the least number of used MDs (min 1) */
    /* and also the first candidate dest block which isn't that one */

    Debug("print enter compact");

    dptr = sptr = 0;
    ptr = blockhead;
    maxcount = 0;

    while (ptr) {
	Debug("print Major loop. ptr= `a4");
	if (Biscut(ptr)) {
	    Debug("print -n is cut,");
	    count = 0;
	    for (md = &(ptr->b_data.b_mem[0]), i=3; i>=0; i--, md++) {
		if ((long)md->m_own == 1) {
		    Debug("print -n F");
		    count++;
		    if (dptr == 0) {
			Debug("print -n {dptr}");
			dptr = ptr;
		    }
		}
	    }
	    Debug(count ? "print count is `d5" : "print no free");
	    if (count > maxcount) {
		Debug(count < 3 ? 
			"print A new record!" : "print Best you can ask!");
		sptr = ptr;
		maxcount = count;
		if (count == 4) {
		    Debug("print Count is 4! This block is all free!");
		    return sptr;
		}
		if (count == 3) break;	/* best you can ask for! */
	    }
	}
	ptr = ptr->b_next;
    }

    /* take care of case where first unstuffed block has 3 holes, */
    /* so dptr and sptr are equal */

    if (dptr == sptr) {
	if (!(dptr = sptr->b_next)) {
	    Debug("print ...and LAST! (quit)");
	    return 0;
	}
	Debug("print first was best... Dptr := (lpeek (- `a6 4))");
    }
    dindex = 0;

    /* set sindex to the index of the first used md in sptr	*/
    /* and md to point to it (We *know* there is at least one)	*/

    for (md = &(sptr->b_data.b_mem[0]), sindex=0;
	 (long)md->m_own == 1;
	 sindex++, md++) /* no body */ ;

    Debug("print -n sindex is `d6");

    /*
     * now stuff md's from sptr into dptr, advancing dptr as necessary
     * (at top of loop, we know (sptr,sindex) is used, but not that
     * (dptr,dindex) is free.
     */

    while (1) {
	Debug("print top of move loop");

	dest_md = advance(&dptr,&dindex,sptr);

	Debug("print move `a5 `d6 to (lpeek (- `a6 4)) (wpeek (- `a6 6))");
	mdmove(md,dest_md);

	/* mark the slot we just vacated as unused */
	*(long *)&(md->m_own) = 1;

	for (++md, ++sindex ; sindex < 4; sindex++, md++) {
	    Debug("print Check `a5 `d6 for free-ness");
	    if ((long)md->m_own != 1) goto notdone;
	    Debug("print Was free");
	}
	Debug((Bmakefree(sptr),
		"print compact is done! {sindex fell off end}"));
	return sptr;				/* we're done */

notdone:
	Debug("print Advanced sindex to `d6");
    }
}
	
/************************************************************************
 *
 * mdmove: copy an md, changing links as appropriate
 *
 * The MD could be on the free or allocated list.
 *
 * THIS ROUTINE DIDN'T KNOW ABOUT PMDFAST, THE FAST-RAM MEMORY HEADER!
 * Now it does (12/20/89).
 *
 * THIS ROUTINE HAD A BUG:  it ignored the "rover" pointers in the
 * PMD structures.  Now, if you're moving the block which either rover
 * points to, that rover is updated with the new location of the block.
 *
 * So much for that bug -- as of 4/90 there IS no "rover"!
 *
 ***********************************************************************/

/*
 * These are the four list headers which the md might be on
 */

extern MPB pmd;

static MD **mplist[] = {
    &pmd.mp_mfl, &pmd.mp_mal
};
#define MPLSIZE (sizeof(mplist)/sizeof(MD **))

mdmove(x_target,x_dest)
MD *x_target, *x_dest;
{
    REG MD *target;
    REG MD *dest;
    MD **qq;
    REG MD *p;
    REG MD **q;
    REG int i;

    target = x_target;
    dest = x_dest;

    Debug("print -n mdmove `a5 into `a4");

    /* outer loop steps qq through mfl and mal of both pmd's */
    /* inner loop goes through the list at qq */

    for (i=0; i<MPLSIZE; i++) {
	qq = mplist[i];
	for (p = *(q = qq); p; p = *(q = &p->m_link)) {
	    if (p == target) goto foundit;
	}
    }

    Debug("print fails.");

    return 1;		/* error! small block isn't on either list */

foundit:

    /* now q is prev of (sptr,sindex) */
    Debug("print succeeds");

    *dest = *target;	/* structure copy including "next" pointer */
    *q = dest;		/* link target's prev to new location */
    return 0;
}

/*
 * Advance dptr,dindex to next free block which isn't in sptr.
 * Leaves dptr,dindex unchanged if it is free already.
 * Returns md pointer to the dest.
 */

MD
*advance(pdptr,pdindex,sptr)
struct block **pdptr, *sptr;
int *pdindex;
{
    REG struct block *dptr; 
    REG int dindex;
    REG MD *md;

    dptr = *pdptr;
    dindex = *pdindex;
    while (dptr) {
	if (Biscut(dptr)) {
	    Debug("print advance dptr,dindex starting at `a5 `d7");
	    for (md = &(dptr->b_data.b_mem[dindex]);
		dindex < 4;
		dindex++, md++) {
		    if ((long)md->m_own == 1) {
			*pdptr = dptr;
			*pdindex = dindex;
			Debug("print advance returns `a5 `d7 { `a4 }");
			return md;
		    }
	    }
	}
	else {
	    Debug("print block is not cut");
	}

	Debug("print no free there, bump dptr");
	if ((dptr = dptr->b_next) == sptr) {
	    Debug("print skip dptr over sptr");
	    dptr = dptr->b_next;
	}
	dindex = 0;
    }
}

/************************************************************************
 *
 * long freebig: free a big block back into the pool.
 * Returns 0 for success.
 *
 * This is trivial.
 *
 ***********************************************************************/

long
freebig(ptmp)
char *ptmp;
{
    REG struct block *ptr;

    Debug("print enter freebig `a5");
    ptr = (struct block *)(ptmp-HEADSIZE);

    if (Bisfree(ptr)) {
	/* panic! block isn't free */ 
	Panic();
    }

    Bmakefree(ptr);
    Debug("print success! freebig returns");
    return 0;
}

long
freesmall(x_ptr)
MD *x_ptr;
{
    REG MD *ptr;
    REG struct block *p;
    REG MD *md;
    REG int i;

    Debug("print enter freesmall `a5");
    ptr = x_ptr;

    for (p = blockhead; p; p = p->b_next) {
	if ((char *)p < (char *)ptr && (char *)(p+1) > (char *)ptr) {
	    /* got it */
	    Debug("print `a5 is in range of block `a4");

	    if (!Biscut(p)) {
		/* panic: if not cut, big trouble */
		goto abort;
	    }
	    for (md = &(p->b_data.b_mem[3]), i=3;
		 i>=0;
		 i--,md--) {
		    if (ptr == md) {
			Debug("print Slice `d7");
			if ((long)md->m_own == 1) {
			    /* panic! it's already free! */
			    goto abort;
			}
			*(long *)&(md->m_own) = 1;
			Debug("print success! freesmall returns");
			return 0;
		    }
	    }
	    /* panic: the MD is within a block but not at a slice boundary */
	    goto abort;
	}
    }

    /* fall through to abort: MD is not in any block */
abort:
    Panic();
}
