/*
***************************      MEM.C     ******************************
*
* $Revision: 2.22 $	$Source: d:/tos/dos\rcs\mem.c,v $
* =======================================================================
* $Author: unknown $ 	$Date: 1992/05/20 00:30:02 $    $Locker:  $
* =======================================================================
*
* $Log: mem.c,v $
* Revision 2.22  1992/05/20  00:30:02  unknown
* This ci represents falling back to 2.19, pre-memprot.  It has one
* thing put back in from 2.20: freesmall on MD's given up by xmunhook.
*
* Revision 2.19  1991/06/18  17:52:02  apratt
* Updated to DB release 3 (new print)
*
* Revision 2.18  1991/05/09  17:42:04  apratt
* Added a bunch of unsigned's.
*
* Revision 2.17  1991/04/30  12:12:38  apratt
* Converted DBCMDs to new infix DB style
*
* Revision 2.16  1991/04/05  18:39:26  apratt
* debugging message change
*
* Revision 2.15  1991/03/28  17:39:36  apratt
* THIS VERSION BOOTS! DESKTOP OPERATIONS WORK!
*
* Revision 2.14  1991/03/12  18:25:26  apratt
* Making gtest.prg works and lets you test functions in this version
*
* Revision 2.13  1991/02/15  18:45:40  apratt
* CI at the end of the week...
*
* Revision 2.12  1991/02/12  18:20:10  apratt
* *** empty log message ***
*
* Revision 2.11  1991/02/11  19:56:48  apratt
* Checkin lest I lose work (again)
*
* Revision 2.10  91/01/23  14:30:22  apratt
* Trimmed logs & comments, changed to compile under GCC or (new) Alcyon.
* 
*************************************************************************
*/

#include "fs.h"

MPB pmd;

/************************************************************************
 *
 *	TPA MEMORY MANAGEMENT
 *
 *
 * Once, this Code was grand: it used the TPA itself to keep track of the
 * free and allocated blocks.  But then the Word came, and the Word was
 * Backward-Compatibility.  And so, the Code was backed out.  Now you see
 * before you the tattered shreds of code, with OSpool used to keep track
 * of memory blocks: back to the Bad Old Days.
 *

Originally, for TT (the first machine with more than just ST RAM), this
code managed two separate MPB's: "pmd" and "pmdfast".  Now there's just one
again, and the MD's on the list contain information about the block.

There are two types of memory in the system as far as GEMDOS is concerned:
"ST RAM" and "ALTERNATIVE RAM."  The chief characteristic of alternative
RAM is that you can't put a screen there.  You also can't do ACSI DMA to
there, but drivers take care of that.  There are other things you can't do
from there: DMA sound, and possibly blits.  The point is that some programs
can run in any memory, and some _must_ have ST RAM (primarily because they
do double-buffering).

The code structure here is as follows: ffit has an extra argument, the
kind(s) of RAM which are eligible for satisfying this request:

	0	ST RAM only
	1	Alternative RAM only
	2	Either, ST RAM preferred
	3	Either, Alternative RAM preferred

Cases 1 and 2 will only come from user requests; xmalloc and xexec use 0
and 3, based on the hflags field of the process (either the one running or
the one being loaded).  This means that alternative RAM is always preferred
if it's available and eligible.

The low bit in the MD m_start field is used to distinguish one kind of RAM
from the other: when this bit is zero, the block is in ST RAM. Even when
contiguous, blocks do not coalesce when they're of different types.

The Getmpb call to the BIOS returns an MPB which might have more than one
free block on it: there is one free block per chunk of memory which the
BIOS found.  User programs can inform GEMDOS of more memory with the
Maddalt(start,size) call.  It gets put on the alternative RAM list;
presumably the ROMs found all the ST RAM.  A user on a TT or Mega STe with
a RAM card would put a program which calls Maddalt() in his AUTO folder:
this is sort of a "memory driver" and approaches the long-awaited
software-DRAM technology Atari's been working on.

This code gets rid of the dumb "rover" idea.  What a dog!

 ************************************************************************/

#define FLAG(val) (((unsigned long)(val)) & 1)
#define UNFLAG(val) ((MD *)(((unsigned long)(val)) & (~1)))
#define PUTFLAG(val,flag) ((char *)(((unsigned long)val) | flag))

/*
 * If you define QUANTUM to anything other than 2, you will change the
 * maxim "two successive Malloc() calls probably return contiguous 
 * memory."  If you've changed that for other reasons, fine, but this is
 * another contributing factor in that maxim.
 *
 * On the other hand, QUANTUM had better be at LEAST 2, since otherwise 
 * you would get odd-sized blocks, and the next block would start on an 
 * odd boundary!
 */

#define QUANTUM (4L)	/* longword-align everything */

/*
 * initialize memory allocator
 */

void
xminit()
{
    MD *p;
    unsigned long s;
    unsigned long adjust;

    (void)getmpb(&pmd);

    /* 
     * Make sure that each free block we got back starts on a quantum
     * boundary, and is an even number of quanta long.
     *
     * If that results in any zero-length blocks, tough luck: life gets
     * slower but no harm's done.
     */

    for (p = pmd.mp_mfl; p; p = p->m_link) {
	if (s = (((unsigned long)(UNFLAG(p->m_start))) & (QUANTUM-1))) {
	    adjust = QUANTUM - s;
	    p->m_start += adjust;
	    p->m_length -= adjust;
	}
	p->m_length = p->m_length & ~(QUANTUM-1);
	if (p->m_length < 0) p->m_length = 0;
    }
}

unsigned long 
mbiggest(mp,type)
MPB *mp;
int type;
{
    REG MD *p;
    REG unsigned long maxval;

    DBCMD(0x80,"print mbiggest mpb: -x (lpeek (`a6 + 8)) type: -x (wpeek (`a6 + c));_c");

    maxval = 0;

    for (p = mp->mp_mfl; p ; p = p->m_link) {
	/* if ST-only, stop at first alt RAM */
	if (type == 0 && FLAG(p->m_start)) break;
	/* else if alt only, don't count ST RAM */
	else if (type == 1 && !FLAG(p->m_start)) continue;

	if (p->m_length > maxval) maxval = p->m_length;
    }
    return maxval;
}


/*
 * Allocate memory from TPA.
 */
MD
*ffit(amount,mp,type)
MPB *mp;
unsigned long amount;
int type;
{
    MD *p;
    MD **q, **q1;
    MD *p1;
    int fval;

    DBCMD(0x80,"print ffit amt: -x (lpeek (`a6 + 8)) mpb: -x (lpeek (`a6 + c)) "
	       "type: -x (wpeek (`a6 + c));_c");

    p = *(q = &mp->mp_mfl);		/* start at the beginning */

    if (!p) return(0); /* no way */

    if (amount == 0) return NULPTR;

    /* round up to the next quantum */
    amount = (amount + (QUANTUM-1)) & ~(QUANTUM-1);

    fval = 1;
    switch (type) {
	case 0: fval = 0; /* then FALL THROUGH to case 1 */
	case 1: {
	    while (p && 
		   (p->m_length < amount ||
		    FLAG(p->m_start) != fval)) {
			p = *(q = &p->m_link);
	    }
	    if (p == NULPTR) return NULPTR;
	    break;
	}
	case 2:
	case 3: {
	    while (p && p->m_length < amount) {
		p = *(q = &p->m_link);
	    }
	    /* p is NULL, or first fit of any type */
	    if (p == NULPTR) return NULPTR;

	    /* if p is not ST RAM, or if our preference is ST RAM, */
	    /* then p is our match. */
	    if (FLAG(p->m_start) || (type == 2))
		break;

	    /* we get here only when pref. is alt, and p is ST: */
	    /* scan past ST RAM, look for ffit in alt RAM. */

	    p1 = p; q1 = q;

	    /* scan to end of ST RAM */
	    while (p && !FLAG(p->m_start)) {
		p = *(q = &p->m_link);
	    }
	    /* find first fit in alt RAM */
	    while (p && p->m_length < amount) {
		p = *(q = &p->m_link);
	    }
	    if (p == NULPTR) {
		/* no match in alt RAM, set p to our ST RAM match */
		p = p1;
		q = q1;
	    }
	} /* end case 2,3 */
    } /* end switch */
    
    /* now p is either ST RAM match or alt RAM match */

    if (p->m_length == amount) {
	/* take the whole thing */
	*q = p->m_link;
    }
    else {
	/* break it up */
	if (!(p1=getsmall()))
	    return(0);

	p1->m_length = p->m_length - amount;
	p1->m_start = p->m_start + amount;	/* preserves flags */
	p1->m_link = p->m_link;
	p->m_length = amount;
	*q = p1;
    }

    /* put matched block at head of allocated list (unsorted) */
    p -> m_link = mp->mp_mal;
    mp->mp_mal = p;
    p->m_own = run;
    return(p);
}


/*
 * Shrink an allocated block.
 */
long
xmshrink(n,blk,len)
int n;
void *blk;
unsigned long len;
{
    MD *m;
    MD *p;

    DBCMD(1,"print xmshrink (dummy) blk: -x (lpeek (`a6 + a)) "
	    "size: -x (lpeek (`a6 + e));_c");
    /*
     * Traverse the list of memory descriptors looking for this block.
     */
    for (p = pmd.mp_mal; p; p = p->m_link)
	if (blk == UNFLAG(p->m_start))
	    goto found;

    /*
     * If block address doesn't match any memory descriptor, then abort.
     */
    DBCMD(0x80,"print xmshrink fails: can not find block;_c");
    return(EIMBA);

found:

    /*
     * Always shrink to a block-granularity length
     */
    len = (len + (QUANTUM-1)) & ~(QUANTUM-1);

    /*
     * If the caller is not shrinking the block size, then abort.
     */
    if (p->m_length < len)
	return(EGSBF);

    /*
     * if not shrinking at all, just return. if shrinking to zero size,
     * just free.
     */

    if (len == p->m_length) return E_OK;

    if (!len) {
	freeit(p,&pmd);
	return E_OK;
    }

    /*
     * Create a memory descriptor for the freed portion of memory.
     */
    if (!(m = getsmall())) return ERROR;
    m->m_start = p->m_start + len;		/* preserves flag */
    m->m_length = p->m_length - len;
    p->m_length = len;
    freeit(m,&pmd);

    return(E_OK);
}


/*
 * Free block of TPA memory.
 */
void
freeit(m,mp)
MD *m;
MPB *mp;
{
    MD *p;
    MD **q;
    MD *p1;
    void *mtemp;

    DBCMD(0x80,"print freeit -x (lpeek (`a6 + 8)) mpb: -x (lpeek (`a6 + c));_c");

    p1 = 0;		/* this is p's prev */

    /*
     * Find where this block belongs in the free list. Blocks are sorted in
     * ascending address order. Block p goes after m (or NULL), p1 goes
     * before (or NULL).
     *
     * The "start" field may be odd for alt RAM.  That won't hurt anything,
     * and is preserved even through the coalescing phase.
     */

    mtemp = m->m_start;
    for (p = *(q = &mp->mp_mfl); p ; p1=p, p = *(q = &p->m_link)) {
	if (mtemp < p->m_start) break;	/* relies on unsigned compare */
    }

    m->m_link = p;
    *q = m;

    /*
     * m is linked in; now coalesce if possible. Un-like memory blocks will
     * not coalesce, even if contiguous, because start1+length1 != start2
     * when either start is odd and the other isn't.
     */

    if (p) {
	if (m->m_start + m->m_length == p->m_start) {
	    /* join to higher neighbor */
	    DBCMD(0x80,"print freeit: coalesce up;_c")
	    m->m_length += p->m_length;
	    m->m_link = p->m_link;

	    freesmall(p);
	}
    }

    /* if there's a prev, join to lower neighbor */
    if (p1) {
	if (p1->m_start + p1->m_length == m->m_start) {
	    /* join to lower neighbor */
	    DBCMD(0x80,"print freeit: coalesce down;_c")
	    p1->m_length += m->m_length;
	    p1->m_link = m->m_link;

	    freesmall(m);
	}
    }
}


/*
 * Allocate memory; friendly version, with arg telling where to get it
 * from.  Values for the flag are:
 *
 *	0: slow only
 *	1: fast only
 *	2: slow or fast, slow preferred
 *	3: fast or slow, fast preferred
 *
 * FMalloc(-1L,0) tells how big the largest single block is in slow RAM.
 * Ditto (-1L,1) for fast RAM.  Modes 2 and 3 with arg -1L both give the
 * largest block available, without regard to where.
 *
 * The hflags field of your PRG header dictates which mode (0 or 3) you get
 * when you use the old Malloc() call.
 */

unsigned long
xfmalloc(amount,mode)
unsigned long amount;
int mode;
{
    REG MD *ret;

    DBCMD(1,"print xfmalloc amt: -x (lpeek (`a6 + 8)) mode: -x (wpeek (`a6 + c));_c");

    if (amount == 0xffffffffL) return mbiggest(&pmd,mode);
    else {
	ret = ffit(amount,&pmd,mode);
	if (ret != NULPTR) return (long)UNFLAG(ret->m_start);
	else return (long)NULPTR;
    }
}

/*
 * Allocate Memory;
 * friendly version.
 *
 * Needs to know what *kind* of memory to allocate...  If P_RAMALLOC is
 * set, try fast RAM first, then slow RAM.  Else just slow.
 */
unsigned long
xmalloc(amount)
unsigned long amount;
{
    DBCMD(1,"print -n xmalloc amt: -x (lpeek (`a6 + 8)) >>;_c");

    if (run->p_hflags & P_RAMALLOC) return xfmalloc(amount,3);
    else return xfmalloc(amount,0);
}

/*
 * Free memory;
 * (friendly version.)
 */
long
xmfree(addr)
void *addr;
{
    MD *p;
    MD **q;

    DBCMD(0x01,"print xmfree -x (lpeek (`a6 + 8));_c");

    for (p = *(q = &pmd.mp_mal); p; p = *(q = &p->m_link)) {
	if (addr == UNFLAG(p->m_start)) goto found;
    }

    DBCMD(0x80,"print mfree of block which is not allocated.;_c");
    return(EIMBA);

    /* unlink & pass to freeit */
found:
    *q = p->m_link;

    freeit(p,&pmd);

    return(E_OK);
}

/*
 * unhook allocated memory from both allocated and free lists: this is
 * called by xtermres.
 */

void
xmunhook(pid)
PD *pid;
{
    REG MD *m;
    REG MD **q;
    REG MD *hold;
    
    DBCMD(0x80,"print xmunhook pid: -x (lpeek (`a6 + 8));_c");

    for (m = *(q = &pmd.mp_mal); m; ) {
	if (m->m_own == pid) {
	    /* here's one: link prev's next to m's next (and change m) */
	    *q = m = m->m_link;
	}
	else {
	    /* not one: move m and q onward */
	    hold = m;
	    m = *(q = &m->m_link);
	    freesmall(hold);
	}
    }
}

/*
 * free all memory owned by a given PID. This is called by ixterm.
 */

void
xmfreeall(pid)
PD *pid;
{
    REG MD *m;
    REG MD **q;
    
    DBCMD(0x80,"print xmfreeall pid: -x (lpeek (`a6 + 8));_c");

    for (m = *(q = &pmd.mp_mal); m; ) {
	if (m->m_own == pid) {
	    /* here's one: unlink from allocated list, then freeit() */
	    *q = m->m_link;
	    freeit(m,&pmd);
	    m = *q;
	}
	else {
	    /* not one: move m and q onward */
	    m = *(q = &m->m_link);
	}
    }
}

/*
 * new function by AKP 8/30/88: change ownership of a block when all you
 * know is its starting address.  Used by new Pexec mode 6 (which is "just
 * go" as God intended it to be).
 */

void
xmchown(blk,pid)
void *blk;
PD *pid;
{
    REG MD *m;

    DBCMD(0x80,"print xmchown blk: -x (lpeek (`a6 + 8)) pid: -x (lpeek (`a6 + c));_c");

    for (m = pmd.mp_mal; m; m = m->m_link) {
	if (UNFLAG(m->m_start) == blk) {
	    m->m_own = pid;
	    return;
	}
    }
}

/*
 * New function 4/90: inform GEMDOS that a block of (alternate) RAM exists
 * and should be used for programs, etc.
 *
 * Usage: Maddalt(char *block,long size)
 */

long
xaddalt(blk,siz)
void *blk;
unsigned long siz;
{
    REG MD *m;
    REG unsigned long s;

    DBCMD(1,"print xmaddalt blk: -x (lpeek (`a6 + 8)) siz: -x (lpeek (`a6 + c));_c");

    /* 
     * Make sure that the new block we get starts on a quantum boundary,
     * and is an even number of quanta long.
     *
     * If that results in a zero-length block, we return success but don't
     * do anything.
     */

    if (s = (((long)blk) & (QUANTUM-1))) {
	s = QUANTUM-s;
	blk += s;
	siz -= s;
    }
    siz &= ~(QUANTUM-1);
    if (siz <= 0) return 0;

    if ((m = getsmall()) == NULPTR) return ERROR;

    m->m_start = PUTFLAG(blk,1);
    m->m_length = siz;
    m->m_link = NULPTR;
    m->m_own = 0;
    freeit(m,&pmd);
    return 0L;
} 
    return (s_start = (void *)newstart);
}
