/*
***************************    POOL.C      ******************************
*
* $Revision: 2.13 $	$Source: e:/tos/gd2\rcs\pool.c,v $
* =======================================================================
* $Author: apratt $ 	$Date: 1991/02/22 15:29:28 $    $Locker:  $
* =======================================================================
*
* $Log: pool.c,v $
* Revision 2.13  1991/02/22  15:29:28  apratt
* generic checkin
*
* Revision 2.12  1991/02/15  18:45:40  apratt
* CI at the end of the week...
*
* Revision 2.11  1991/02/12  18:20:10  apratt
* *** empty log message ***
*
* Revision 2.10  1991/02/11  19:56:48  apratt
* Checkin lest I lose work (again)
*
* Revision 2.9  91/01/23  14:30:26  apratt
* Trimmed logs & comments, changed to compile under GCC or (new) Alcyon.
* 
*************************************************************************
*/

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

/* struct block and Bis* predicates and Bmake* actions are in fs.h */

char *root[20];			/* still used so people can give us pool */

#define LENOSM 80L*LSIZE	/* 80 blocks - 40 folders or so */

struct block *blockhead;	/* head of list of blocks in the system */

char osmem[LENOSM];

voidfn
poolinit()
{
    DBCMD(16,"print Enter xminit;_c");
    blockhead = 0;
    (void)addheap(osmem,LENOSM);
    DBCMD(16,"print Leave xminit;_c");
}

/*
 * addheap: cut a chunk of memory into big blocks.
 * Returns a flag: 1 if some was added at blockhead, 0 if not.
 */

int
addheap(ptr,size)
void *ptr;
long size;
{
    struct block *bp = ptr;

    DBCMD(16,"print Enter addheap ptr: (lpeek (+ `a6 8)) "
	     "size: (lpeek (+ `a6 c));_c");

    /* round size down to large block size */
    size = (size/LSIZE)*LSIZE;

    if (!size) return 0;

    do {
	bp->b_next = blockhead;
	blockhead = bp;
	Bmakefree(bp);
	size -= LSIZE;
	bp++;
    } while (size);
    return 1;
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
 ***********************************************************************/

void
*getbig()
{
    REG struct block *ptr;
    REG MD *md;
    REG int i;
    REG int count;
    REG int lfree;	/* free small blocks in the whole pool */

    DBCMD(16,"print Enter getbig, check for a free block;_c");

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
	   	DBCMD(16,"print Cut block is all free so use it;_c");
	   	goto gotone;				/* all free! */
	    }
	}
    }

    /* well, no joy looking for free blocks... */

    DBCMD(16,"print No free block, check for new pool;_c");

    if (ptr = newpool()) goto gotone;

    /* no new pool, either... */

    DBCMD(16,"print -n No new pool, ;_c");
    if (lfree >= 4) {
	DBCMD(16,"print enough free to compact: try that.;_c");
	if (ptr = compact()) goto gotone;
	/* panic: compact failed (shouldn't happen) */
	goto abort;
    }
    DBCMD(16,"print not enough free to try compact;_c");

    /* can't compact little blocks... */
    
    /* panic with a message like "out of ospool, use FOLDR100" */
abort:
    Panic();

    /*
     * Common code for success; ptr is the guy we got
     */

gotone:
    DBCMD(16,"print Gotone: make it used & return it;_c");
    Bmakeused(ptr);

    /* clear block before returning it */
    clear(&ptr->b_data,((char *)(&ptr->b_data))+64);

    return (void *)(&ptr->b_data);
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
    int foundsome = 0;

    DBCMD(16,"print enter newpool;_c");

    pool = (struct pool *)root[4];    /* root[4] is where pool gets added */

    if (!pool) return 0;

    while (pool) {
	DBCMD(16,"print top of newpool loop;_c");
	next = pool;

	/* skip until noncontiguous */
	while (next->p_next && next->p_next == next+1) 
		next = next->p_next;

	end = next+1;

	next = next->p_next;	/* keep this for next time */

	DBCMD(16,"print found a contiguous block;_c");

	/* add heap (will do nothing if too small) */
	foundsome |= addheap(pool,((char *)end)-((char *)pool));

	/* set pool = next and look for another contiguous block */
	pool = next;
    }

    /* ensure that next call won't see this same stuff */
    root[4] = 0;

    if (!foundsome) {
	DBCMD(16,"print addheap didn't actually add any;_c");
	return 0;
    }

    DBCMD(16,"print newpool returns (lpeek ._blockhe);_c");

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
    REG int i;

    DBCMD(16,"print enter getsmall;_c");

    free = 0;

    for (ptr = blockhead; ptr; ptr = ptr->b_next) {
	if (Bisfree(ptr)) free = ptr;
	else if (Biscut(ptr)) {
	    for (md = &(ptr->b_data.b_mem[0]), i=3; i>=0; i--, md++) {
		if ((long)md->m_own == 1) {
		    DBCMD(16,"print hole in cut block, return it;_c");
		    goto gotmd;
		}
	    }
	}
    }

    /* there were no cut blocks with free slots */

    DBCMD(16,"print no unstuffed cut blocks;_c");

    if (free) {
	DBCMD(16,"print -n but there was a free block, ;_c");
	ptr = free;
	goto cutit;
    }

    /* there were no free uncut blocks, either */

    DBCMD(16,"print And no free uncut either;_c");

    if (ptr = newpool()) {
	DBCMD(16,"print -n newpool worked!;_c");
	goto cutit;
    }

    /* there was no more pool */
    
    DBCMD(16,"print newpool struck out;_c");
    /* we struck out */

    return 0;

cutit:
    DBCMD(16,"print cut block and return it;_c");
    Bmakecut(ptr);

    /* mark first three free */
    md = &(ptr->b_data.b_mem[0]);
    *(long *)&((md++)->m_own) = 1;
    *(long *)&((md++)->m_own) = 1;
    *(long *)&((md++)->m_own) = 1;

gotmd:
    /* clear block before returning it (incidentally marks as not free) */
    md->m_link = NULPTR;
    md->m_start = NULPTR;
    md->m_length = 0;
    md->m_own = NULPTR;

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

    DBCMD(16,"print enter compact;_c");

    dptr = sptr = 0;
    ptr = blockhead;
    maxcount = 0;

    while (ptr) {
	DBCMD(16,"print Major loop.;_c");
	if (Biscut(ptr)) {
	    DBCMD(16,"print -n block is cut,;_c");
	    count = 0;
	    for (md = &(ptr->b_data.b_mem[0]), i=3; i>=0; i--, md++) {
		if ((long)md->m_own == 1) {
		    DBCMD(16,"print -n F;_c");
		    count++;
		    if (dptr == 0) {
			DBCMD(16,"print -n {dptr};_c");
			dptr = ptr;
		    }
		}
	    }
	    if (count > maxcount) {
		DBCMD(16,(count < 3 ? 
			"print A new record!;_c" :
			"print Best you can ask!;_c"));
		sptr = ptr;
		maxcount = count;
		if (count == 4) {
		    DBCMD(16,"print Count is 4! This block is all free!;_c");
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
	    DBCMD(16,"print and LAST! - (quit);_c");
	    return 0;
	}
	DBCMD(16,"print first was best;_c");
    }
    dindex = 0;

    /* set sindex to the index of the first used md in sptr	*/
    /* and md to point to it (We *know* there is at least one)	*/

    for (md = &(sptr->b_data.b_mem[0]), sindex=0;
	 (long)md->m_own == 1;
	 sindex++, md++) /* no body */ ;

    /*
     * now stuff md's from sptr into dptr, advancing dptr as necessary
     * (at top of loop, we know (sptr,sindex) is used, but not that
     * (dptr,dindex) is free.
     */

    while (1) {
	DBCMD(16,"print top of move loop;_c");

	dest_md = advance(&dptr,&dindex,sptr);

	DBCMD(16,"print move src block/slot to dest block/slot;_c");
	mdmove(md,dest_md);

	/* mark the slot we just vacated as unused */
	*(long *)&(md->m_own) = 1;

	for (++md, ++sindex ; sindex < 4; sindex++, md++) {
	    DBCMD(16,"print Check block/slot for free-ness;_c");
	    if ((long)md->m_own != 1) goto notdone;
	    DBCMD(16,"print Was free;_c");
	}
	DBCMD(16,"print compact is done! {sindex fell off end};_c");
	return sptr;				/* we're done */

notdone:
	DBCMD(16,"print Advanced sindex to `d6;_c");
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
 * These are the two list headers which the md might be on
 */

static MD **mplist[] = {
    &pmd.mp_mfl, &pmd.mp_mal
};
#define MPLSIZE (sizeof(mplist)/sizeof(MD **))

void
mdmove(target,dest)
MD *target, *dest;
{
    MD **qq;
    REG MD *p;
    REG MD **q;
    REG int i;

    DBCMD(16,"print -n mdmove (lpeek (+ `a6 8)) into (lpeek (+ `a6 c));_c");

    /* outer loop steps qq through mfl and mal of both pmd's */
    /* inner loop goes through the list at qq */

    for (i=0; i<MPLSIZE; i++) {
	qq = mplist[i];
	for (p = *(q = qq); p; p = *(q = &p->m_link)) {
	    if (p == target) goto foundit;
	}
    }

    DBCMD(16,"print fails(!);_c");

    return;		/* error! small block isn't on either list */

foundit:

    /* now q is prev of (sptr,sindex) */
    DBCMD(16,"print succeeds;_c");

    *dest = *target;	/* structure copy including "next" pointer */
    *q = dest;		/* link target's prev to new location */
    return;
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
	    DBCMD(16,"print advance dptr,dindex starting;_c");
	    for (md = &(dptr->b_data.b_mem[dindex]);
		dindex < 4;
		dindex++, md++) {
		    if ((long)md->m_own == 1) {
			*pdptr = dptr;
			*pdindex = dindex;
			DBCMD(16,"print advance returns;_c");
			return md;
		    }
	    }
	}
	else {
	    DBCMD(16,"print block is not cut;_c");
	}

	DBCMD(16,"print no free there, bump dptr;_c");
	if ((dptr = dptr->b_next) == sptr) {
	    DBCMD(16,"print skip dptr over sptr;_c");
	    dptr = dptr->b_next;
	}
	dindex = 0;
    }
    return NULL;	/* never happens */
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
void *ptmp;
{
    REG struct block *ptr;

    DBCMD(16,"print enter freebig (lpeek (+ `a6 8));_c");
    ptr = (struct block *)(ptmp-HEADSIZE);

    if (Bisfree(ptr)) {
	/* panic! block is free */ 
	Panic();
    }

    Bmakefree(ptr);
    DBCMD(16,"print success! freebig returns;_c");
    return 0;
}

void
freesmall(ptr)
MD *ptr;
{
    REG struct block *p;
    REG MD *md;
    REG int i;

    DBCMD(16,"print enter freesmall (lpeek (+ `a6 8));_c");

    for (p = blockhead; p; p = p->b_next) {
	if ((char *)p < (char *)ptr && (char *)(p+1) > (char *)ptr) {
	    /* got it */
	    DBCMD(16,"print small one is in range of a block;_c");

	    if (!Biscut(p)) {
		/* panic: if not cut, big trouble */
		DBCMD(-1,"print freesmall panic! small in range of uncut big!");
		goto abort;
	    }
	    for (md = &(p->b_data.b_mem[3]), i=3;
		 i>=0;
		 i--,md--) {
		    if (ptr == md) {
			DBCMD(16,"print found which slice;_c");
			if ((long)md->m_own == 1) {
			    /* panic! it's already free! */
			    DBCMD(-1,"print freesmall of already free small!");
			    goto abort;
			}
			*(long *)&(md->m_own) = 1;
			DBCMD(16,"print success! freesmall returns;_c");
			return;
		    }
	    }
	    /* panic: the MD is within a block but not at a slice boundary */
	    DBCMD(-1,"print freesmall panic! MD not at slice boundary");
	    goto abort;
	}
    }

    /* fall through to abort: MD is not in any block */
abort:
    Panic();
}
