/*
***************************     FSCL.C     ******************************
*
* $Revision: 2.12 $	$Source: e:/tos/gd2\rcs\fscl.c,v $
* =======================================================================
* $Author: apratt $ 	$Date: 1991/02/21 03:07:32 $    $Locker:  $
* =======================================================================
*
* $Log: fscl.c,v $
* Revision 2.12  1991/02/21  03:07:32  apratt
* This version performs this testbed perfectly.
*
* Revision 2.11  1991/02/15  18:45:40  apratt
* CI at the end of the week...
*
* Revision 2.10  1991/02/12  18:20:10  apratt
* *** empty log message ***
*
* Revision 2.9  1991/02/11  19:56:48  apratt
* Checkin lest I lose work (again)
*
* Revision 2.8  1991/01/23  17:09:42  apratt
* Changed d_left to d_child, d_right to d_next globally.  Removed o_thread,
* d_scan, m_fatofd, m_ofl, and d_dirfil.
*
* Revision 2.7  91/01/23  14:29:54  apratt
* Trimmed logs & comments, changed to compile under GCC or (new) Alcyon.
* 
*************************************************************************
*/

#include "fs.h"

/* 
 * macro to turn a buftyp into a buffer list number. Input n is 0 for FAT,
 * 1 for RD, 2 for data. Originally, this formula was ((n) != 0), meaning
 * the FAT was on its own list and RD and data shared the other.  This
 * formula (FAT & RD on one, data on the other) makes more sense to me.
 *
 * This macro is used in getrec to assign a block to a list, and in flush
 * to determine which list the buffer's on.
 */
#define buflist(n) ((n) == 2)

/*
 * compute log base 2 of n
 */

uint
log2(n)
uint n;
{
    uint i;
    for (i = 0; n; i++) n >>= 1;
    return i-1;
}

/*
 * dirdirty(dir), fatdirty(dev): write the indicated part of the disk out.
 * In the case of dirdirty, the dir's bcb field is passed to flush. For
 * fatdirty, we actually have to look for a dirty FAT sector to write.
 */

voidfn
dirdirty(dir)
DIR *dir;
{
    DBCMD("print -n dirdirty ; dirx (lpeek (+ `a6 8)) ; _c");
    dir->dir_bcb->b_dirty = 1;
    flush(dir->dir_bcb);
}

voidfn
fatdirty(dev)
uint dev;
{
    BCB *b;

    DBCMD("print fatdirty (wpeek (+ `a6 8));_c");
    for (b = bufl[0]; b; b = b->b_link) {
	if (b->b_bufdrv == dev && b->b_dirty) {
	    flush(b);
	    break;
	}
    }
}

/*
 *  Flush a buffer
 *
 *  5/90: flush is only called from this source file (fscl.c), and it's
 *  only called when the buffer in question is actually dirty.  Therefore
 *  it doesn't check the validity or dirtiness of the buffer.
 *
 *  Flushing any buffer writes all buffers on that drive and that list.
 */

voidfn
flush(b)
BCB *b;
{
  uint n;
  uint d;
  DMD *dmd;
  int i;

  DBCMD("print -n flush ;bcb (lpeek (+ `a6 8));_c");
  dmd = b->b_dmd;
  n = b->b_buftyp;
  d = b->b_bufdrv;

  /*
   * flush all dirty buffers on this list and on this drive.
   * (Unfortunately, they're flushed in LRU order, but this is actually
   * likely to be pretty sequential.)
   */

  i = buflist(n);

  for (b = bufl[i]; b; b = b->b_link) {
    if (b->b_bufdrv == d && b->b_dirty) {
    	n = b->b_buftyp;	/* n gets THIS BUFFER's type */
	b->b_bufdrv = B_INVALID; /* invalidate now in case of error */
	rwabs(1,b->b_bufr,1,b->b_bufrec,d);
	/* if FAT operation, flush to both FATs */
	if (!n) 
	    rwabs(1,b->b_bufr,1,b->b_bufrec - dmd->m_fsiz,d);
	/* re-validate the buffer */
	b->b_bufdrv = d;
	b->b_dirty = 0;
    }
  }
}


/*
 * function to flush all dirty buffers on all drives.
 *
 * This is called by ixclose, because closing any file is now guaranteed to
 * flush all buffers on all drives. There may one  day be a new call which
 * does that explicitly, too.
 *
 * Implementation:
 *
 * for each drive ...
 *   for each list ...
 *     for each buffer on the list ...
 *	     if on this drive and dirty
 *		flush(b); (takes care of the rest of this drive)
 *		break;    (back to "for each list")
 */

voidfn
flushall()
{
    REG BCB *b;
    REG int d;
    REG int l;

    DBCMD("print flushall;_c");

    for (d=0; d<MAXDEVS; d++) {
	for (l=1; l >= 0; l--) {
	    for (b = bufl[l]; b; b = b->b_link) {
		if (b->b_bufdrv == d && b->b_dirty) {
		    flush(b);
		    break;
		}
	    }
	}
    }
}

/*
 * usrio: actually do a block rwabs for a user file
 *
 * Invalidates any buffers in the region spanned by the operation. For
 * reads, writes the data first, but doesn't bother for writes.
 *
 * Adds dmd->m_recdata to the record number: the caller (xrw) works in
 * zero-based data record numbers.
 *
 * rwabs is a macro which longjmps on error.
 */

voidfn
usrio(rwflg,num,strt,ubuf,dmd)
uint rwflg,num;
uint strt;
void *ubuf;
DMD *dmd;
{
	BCB *b;
	uint d;
	uint end;

	DBCMD("print usrio rw: (wpeek (+ `a6 8)) count: (wpeek (+ `a6 a)) "
	      "start: (wpeek (+ `a6 c)) ubuf: (lpeek (+ `a6 e)) "
	      "dmd: (lpeek (+ `a6 12));_c");

	d = dmd->m_drvnum;
	strt += dmd->m_recdata;
	end = strt+num;

	/* flush all data blocks which overlap this write */
	for (b = bufl[1]; b; b = b->b_link) {
	    if ((b->b_bufdrv == d) &&
		(b->b_bufrec >= strt) &&
		(b->b_bufrec < end)) {
		    if (!rwflg && b->b_dirty) flush(b);
		    b->b_bufdrv = B_INVALID;	/* invalidate the buffer */
	    }
	}

	rwabs(rwflg,ubuf,num,strt,d);
}


/*
 * getrec: return pointer to buffer representing a record on disk. Also
 * fills in a BCB pointer if pbcb is nonnull.
 *
 * The record number is absolute. All buffer management goes here. Buffers
 * are managed LRU, and written using flush() when the victim is dirty.  If
 * wrtflg is 0, the buffer's dirty flag is left alone or cleared. If 1,
 * it's marked dirty.  If 2, the buffer management stuff is done, but the
 * buffer isn't actually read from disk; this is for extending files, where
 * the contents of the old record don't matter.  (For increased  security,
 * zero the buffer before returning it.)
 */

void
*getrec(recn,dmd,wrtflg,pbcb)
uint recn;
DMD *dmd;
int wrtflg;
BCB **pbcb;
{
    BCB *b;
    uint n;
    long err;
    BCB *p;
    BCB *mtbuf;
    REG BCB **q;
    BCB **phdr;
    int doread;
    int mcflag = 0;

    DBCMD("print getrec recn: (wpeek (+ `a6 8)) dmd: (lpeek (+ `a6 a)) "
	  "flg: (wpeek (+ `a6 e)) pbcb: (lpeek (+ `a6 10));_c");

    if (wrtflg == 2) doread = 0, wrtflg = 1;
    else doread = 1;

    /* put bcb management here */

    /* set n to the region for this sector: FAT, RD, or DATA */
    if (recn < dmd->m_recrd) n = 0;
    else if (recn < dmd->m_recdata) n = 1;
    else n = 2;

    mtbuf = 0;

    phdr = &bufl[buflist(n)];

    /* set b to the matching buffer or the LAST empty buffer */
    for (b = *(q = phdr); b; b = *(q = &b->b_link)) {
	if ((b->b_bufdrv == dmd->m_drvnum) && (b->b_bufrec == recn)) {
	    break;
	}

	/* empty buffer? remember it */
	if (b->b_bufdrv == B_INVALID) {
	    mtbuf = b;
	}
    }
    if (!b) {
	/*
	 * We went to the end of the list. if mtbuf, set b to it and q to
	 * its prev's link else set b to last buffer in the list & q to
	 * prev's link
	 */

	DBCMD("print cache miss;_c");

	if (mtbuf) {
	    /* miss, but there's an empty */
	    b = mtbuf;
	}

	/* 
	 * need to set q to link field of b's prev, or set b to last buf &
	 * q to its prev's link field
	 * 
	 * The label doio is used to actually do the I/O when there's a
	 * cache hit, but the the mediach state is 1 (so we check)
	 */
doio:
	for (p = *(q = phdr); p->b_link; p = *(q = &p->b_link))
	    if (b == p)
		break;

	b = p;

	/* if our victim is in use & dirty, flush him */
	if (b->b_bufdrv != B_INVALID && b->b_dirty) {
	    DBCMD("print flush victim;_c");
	    flush(b);
	}

	/* INVALIDATE this buffer because the rwabs might fail! */
	b->b_bufdrv = B_INVALID;

	/* do the read if doread, or mediach was/is nonzero */

	if (doread || mcflag == 1 || mediach(dmd->m_drvnum)) {
	    rwabs(0,b->b_bufr,1,recn,dmd->m_drvnum);
	}
	b->b_bufrec = recn;
	b->b_dirty = 0;
	b->b_buftyp = n;
	b->b_bufdrv = dmd->m_drvnum;
	b->b_dmd = dmd;
    }
    else {
	/* cache hit */
	/* use a buffer, but first validate media */
	DBCMD("print cache hit;_c");
	if (err = mediach(b->b_bufdrv)) {
	    if (err == 1) {
		mcflag = 1;
		goto doio; /* media may be changed */
	    }
	    else if (err == 2) {
		/* media definitely changed */
		errdrv = b->b_bufdrv;
		rwerr = E_CHNG; /* media change */
		longjmp(errbuf,rwerr);
	    }
	}
    }

    /* make this block most-recently-used in its list */
    *q = b->b_link;
    b->b_link = *phdr;
    *phdr = b;

    if (wrtflg)
	b->b_dirty = 1;

    if (pbcb) *pbcb = b;
    DBCMD("print allbcbs after getrec:;allbcbs;_c");
    return(b->b_bufr);
}

/***********************************************************************
 * New FAT code by AKP 17-Sep-1987
 *
 * This code circumvents almost all of the seek/read/write stuff by asking
 * for the FAT buffer directly from the disk cache. Flush() takes care of
 * the two-copies-of-a-FAT stuff.
 *
 * NOTE: This code assumes that there are at least two FAT buffers, and
 * that they're managed LRU: For non-16-bit FATs, it can call getrec twice
 * to get pointers to *two* FAT buffers, and assume they  are both in
 * memory at the same time.
 *
 * To use this code, set newcl = TRUE before and after any loop of cluster
 * calls in your code.  This invalidates the cached info so you're sure to 
 * get a read.  Calls:
 * 
 * getcl(cl,dmd) returns the FAT entry for cl
 * 
 * clfix(cl,link,dmd) writes 'link' into the FAT entry for cl
 * 
 * nextcl(cl,dmd,extflag,&extended) returns the next cluster in the chain,
 * extending the chain if necessary and extflag.  When extending, marks the
 * new cluster with -1.  *extended reflects whether or not the chain was
 * actually extended; pass in NULL if you don't care. Returns zero on EOF
 * when !extflag, and when extending fails because there are no free
 * clusters, and also if cl's entry is 0 or 0xfffx (where x is 0-e).  If cl
 * itself is zero, the first free cluster on the disk is returned (and
 * marked with -1).
 * 
 **********************************************************************/

uint newcl;		/* flag: goes TRUE at start of a cluster loop */
uint clsector;		/* holds saved sector number */
DMD *cldev;		/* holds DMD of saved sector */
char *clsave;		/* holds saved sector pointer */
BCB *clbcb;		/* hold the cluster's BCB for marking dirty */

/*
 * getfat: this combination of macro and procedure returns the requested
 * FAT sector from the disk, with a combination of speed & small code size.
 *
 * The logic is this: if newcl is set, you definitely call getfat, which
 * calls getrec.  If the dev isn't the same or the cluster isn't the same,
 * you call getfat.  Otherwise, you OR wflag into the record's dirty flag
 * and return the cached record pointer.
 *
 * The win is when you are chasing a FAT chain: you set newcl=TRUE, then
 * call getcl (and clfix) a lot, and you only go through the buffer 
 * management code once per FAT *sector* you touch, instead of once  per
 * FAT *entry* you touch.  
 *
 * Is this really a win?  Maybe not. When do you use this a lot? On
 * floppies, and when finding the next free cluster for an existing  file
 * (find first free cluster is a separate operation), and when Fseeking to
 * the end of a long file (but even then...).
 */

#define Getfat(s,dmd,wflag) \
    ((newcl || (cldev != (dmd)) || (clsector != (s))) \
	? getfat((s),(dmd),(wflag)) \
	: (clbcb->b_dirty |= wflag, clsave))

char
*getfat(s,dmd,wflag)
unsigned int s;
DMD *dmd;
int wflag;
{
	/* get the buffer the sector is in */
	newcl = TRUE;		/* do this in case getrec longjmp's */
	clsave = getrec(s+dmd->m_recfat,dmd,wflag,&clbcb);
	clsector = s;
	cldev = dmd;
	newcl = FALSE;
	return clsave;
}


#define hibyte(w) (((w) >> 8) & 0xff)
#define lobyte(w) ((w) & 0xff)

voidfn
clfix(cl,link,dmd)
uint cl;
uint link;
DMD *dmd;
{
    /* used by m_16 only */
    uint offset;
    uint sector;
    char *buf;
    char *obuf;
    ulong pos;
    
    /* used by !m_16 only */
    uint mask;
    uint fatword;
    char *fptr;		/* points to first byte of fatword */
    char *q;		/* points to buf[offset] once that's known */

    DBCMD("print clfix (wpeek (+ `a6 8)) becomes (wpeek (+ `a6 a));_c");

    if (dmd->m_16) {
	/* compute byte offset into FAT */
	pos = ((ulong)cl) << 1;

	/* now compute start of sector in FAT and byte offset in sector */
	sector = pos >> dmd->m_rblog;
	offset = pos & dmd->m_rbm;

	buf = Getfat(sector,dmd,TRUE);	/* get sector for writing */

	swp68(link);
	*(uint *)(&buf[offset]) = link;
	return;
    }
    else {
	fptr = (char *)(&fatword);
	pos = (cl + (cl >> 1));

	link = link & 0x0fff;

	if (cl & 1) {
	    link = link << 4;
	    mask = 0x000f;
	}
	else
	    mask = 0xf000;

	/* compute sector and byte offset from pos */
	sector = pos >> dmd->m_rblog;
	offset = pos & dmd->m_rbm;

	buf = Getfat(sector,dmd,TRUE);	    /* get fat sector for writing */

	/* fatword comes out of this pre-swapped from 8088 format */

	*(fptr+1) = *(q = &(buf[offset]));
	if (offset == dmd->m_recsiz-1) {
	    /* get next sector for the other half of the fat word */
	    obuf = buf;		/* save old buffer address */
	    buf = Getfat(sector+1,dmd,TRUE);
	    *fptr = buf[0];
	}
	else {
	    obuf = 0;
	    *fptr = *(q+1);
	}

	/* AND out the old, OR in the new */
	fatword = (fatword & mask) | link;

	/* fatword is still in 68000 format; write it backwards  */
	if (!obuf) {
	    /* just write the new value */
	    *q = *(fptr+1);
	    *(q+1) = *fptr;
	}
	else {
	    *q = *(fptr+1);
	    buf[0] = *fptr;
	}
    }
}

uint
getcl(cl,dmd)
uint cl;
DMD *dmd;
{
    ulong pos;
    uint offset;
    uint sector;
    char *buf;

    uint fatword;
    char *fptr;		/* points to first byte of fatword */
    char *q;		/* points to buf[offset] when that's known */

    if (dmd->m_16) {
	/* compute byte offset into FAT */
	pos = ((ulong)cl) << 1;

	/* now compute sector number in FAT and byte offset in the sector */
	sector = pos >> dmd->m_rblog;
	offset = pos & dmd->m_rbm;

	buf = Getfat(sector,dmd,FALSE);

	fatword = *(uint *)(&buf[offset]);
	swp68(fatword);
	return fatword;
    }
    else {
	fptr = (char *)(&fatword);
    	pos = cl + (cl >> 1);
	sector = pos >> dmd->m_rblog;
	offset = pos & dmd->m_rbm;
    	buf = Getfat(sector,dmd,FALSE);

	/* fatword comes out of this pre-swapped into 68000 format */
	*(fptr+1) = *(q = (&buf[offset]));
	if (offset == dmd->m_recsiz-1) {
	    buf = Getfat(sector+1,dmd,FALSE);
	    *fptr = buf[0];
	}
	else *fptr = *(q+1);

	if (cl & 1)
	    cl = (fatword >> 4);
	else
	    cl = fatword;

	/* AKP: sign extend any entry ffx to fffx; others get chopped off */
	if ((cl & 0x0ff0) == 0x0ff0)
	    cl |= 0xf000;
	else
	    cl &= 0x0fff;

	return cl;
    }
}


uint
nextcl(cl,dmd,extflag,extended)
uint cl;
DMD *dmd;
int extflag;
int *extended;
{
    uint xcl, lastcl, cl2, rover, i;

    DBCMD("print nextcl;_c");

    if (extended) *extended = 0;

    if (!cl) {
	if (!extflag) return 0;
	/* get first cluster, mark with 0xffff, return it */
	goto extend;
    }

    xcl = getcl(cl,dmd);
    if (!xcl) {
	/* bad news: some clust or dir slot points to a free clust */
	DBCMD("print INCONSISTENT DIR/FAT: zero entry;_c");
	return 0;
    }
    else if (xcl == 0xffff) {
	if (!extflag) {
	    DBCMD("print end of chain and !extend;_c");
	    return 0;
	}

extend:
	DBCMD("print extend the chain;_c");
	/* extend the chain, return the new cl */
	if (!cl && dmd->m_16) {
	    cl2 = fastcl(dmd,FALSE);
	    if (!cl2) {
		DBCMD("print fastcl/no free space;_c");
		return 0;
	    }
	}
	else {
	    /*
	     * this loop can run more than nec., but only if no space.
	     */
	    rover = cl;
	    lastcl = dmd->m_numcl + 2;
	    for (i=2; i<lastcl; i++) {
		if (rover < 2) rover = 2;
		if (!getcl(rover,dmd)) {
		    cl2 = rover;
		    goto gotone;
		}
		if (++rover > lastcl) rover = 0;
	    }
	    DBCMD("print slowcl/no free space;_c");
	    return 0;
	}
gotone:
	if (cl) clfix(cl,cl2,dmd);
	clfix(cl2,-1,dmd);
	if (extended) *extended = 1;
	DBCMD("print extended: return cl2;_c");
	return cl2;
    }
    else if ((xcl & 0xfff0) == 0xfff0) {
	DBCMD("print FAT error: bad sector, etc.;_c");
	return 0;
    }
    else {
	DBCMD("print nextcl returns next cluster;_c");
	return xcl;
    }
}


/*
 * Fast cluster code, invoked when looking for the first unused cluster in
 * a 16-bit FAT.  Call with freeflag TRUE to return number of free clusters
 * in the whole FAT.  (One "if" per sector doesn't seem like too high a
 * price to pay.)
 *
 * 'i' is used as a FAT sector counter.  'end' is set to the index of the
 * last FAT sector actually used (independent from dmd->m_fsiz). 'end' is
 * computed in a sector-size-independent way. In the inner loop, 'cl' is
 * the count of words left to check in this sector: it starts out short by
 * two (and buf starts out incremented by two words) in the first FAT
 * sector.
 *
 * If a free cluster is found, its number is put in cl2, and i is set to
 * zero, so the later test "if (i < lastcl)" will fail.
 *
 * Note that little-g getfat() is used, for low overhead.
 */

uint
fastcl(dmd,freeflag)
DMD *dmd;
int freeflag;
{
    uint *buf;
    uint free;
    uint clcount;
    uint cl;
    uint i;
    uint clpersec;	    /* clusters represented by each sector of FAT */
    uint lastcl;

    clpersec = dmd->m_recsiz >> 1;
    lastcl = dmd->m_numcl + 2;

    free = 0;

    /* set up the first pass here; remainder get set up before "goto again" */

    i = 0;
    /* clcount: first cluster to look at in this sector */
    clcount = 2;
    /* cl: clusters left to look at in this sector */
    cl = min(clpersec,lastcl) - 2;
    /* buf: pointer following along in this sector */
    buf = ((uint *)getfat(i,dmd,FALSE)) + 2;

again:
    /* stop at the sooner of the end of sector or the end of FAT */
    if (!freeflag) {
	while (cl-- && *buf++) {
	    clcount++;
	}
	if (cl >= 0) {
	    /* quit because *buf was 0! return number of zero entry */
	    return clcount;
	}
    }
    else {
	while (cl--) {
	    if (!*buf++) free++;
	    clcount++;
	}
	if (clcount == lastcl) return (int)free;
    }

    /* this is the end condition for the loop, followed by setup for next */

    if (clcount < lastcl) {
	i++;
	cl = min(clpersec,lastcl-clcount);
	buf = (uint *)getfat(i,dmd,FALSE);
	goto again;
    }

    /* drop out of the loop here. */

    return 0;
}

/*
 * long and involved read-write call. Operates on OFD's.
 *
 * The read/write pointer information in the OFD is maintained thus:
 *
 * o_bytnum is the read/write pointer for the file.
 * o_curcl is the cluster number bytnum is in; when zero, the file is
 *	zero-length and the rest doesn't matter.
 * o_currec is the record number on disk where bytenum is, zero-based
 *	from the start of the data part of the disk.
 *
 * If you call this for reading, don't try to read past EOF.  That is
 * assumed fairly subtly in a couple of places.
 *
 * The overall logic is as follows:
 *
    The "head" of the operation is the part that fills out the rest of
the record o_bytnum is in the middle of.

    The "middle" of the operation is the span of whole records.

    The "tail" is the part that falls into the leading fringe of the
last record of the operation.

    The head is done first, then the middle, then the tail.  If bytnum is
on a record boundary, the op can't have a head, only a middle and a tail.

    The logic of the middle part is thus:

    if (there's a middle) {
	set up a run starting at the current record, with run_len = 1;
	while (--lenmid) {
	    ++currec;
	    if (fell off the end of the current cluster) {
		curcl = next cluster of this file, extending if nec;
		currec = cl2rec(curcl);
		if (currec not contiguous with run) {
		    write out the run;
		    set up a new run with run_len = 0;
		}
	    }
	    ++run_len;
	}
	write out the run;
    }

 * It seems like this code handles falling off a cluster a lot: in three
 * different places.  If you can think of a better way, let me know.
 * 
 * There is a BUG in this code: if you do a transfer that ends on a record
 * boundary, the curcl/currec fields are wrong.  It's worse if you end on a
 * cluster boundary.
 * 
 */

long
xrw(wrtflg,ofd,len,ubufr,bufxfr)
int wrtflg;
OFD *ofd;
long len;
void *ubufr;
void (*bufxfr) _P((uint, void *, void *));
{
    char *bufp;
    DMD *dmd;
    uint lenhead, lenmid, lentail;
    uint run_start, run_len;
    uint xcl;
    int extended;
    ulong rc;
    ulong runlen;
    DFD *dfd;

    /* holders for commonly-used fields */
    uint recsiz, clsiz, clsizb;
    ulong bytnum;
    uint curcl, currec, recoffs;

    DBCMD("print xrw flg: (wpeek (+ `a6 8)) "
	  "ofd: (lpeek (+ `a6 a)) "
	  "len: (lpeek (+ `a6 e)) "
	  "ubufr: (lpeek (+ `a6 12));_c");

    dfd = ofd->o_dfd;
    dmd = &drvtbl[dfd->dfd_dev];
    recsiz = dmd->m_recsiz;
    clsiz = dmd->m_clsiz;
    clsizb = dmd->m_clsizb;
    bytnum = ofd->o_bytnum;

    curcl = ofd->o_curcl;
    currec = ofd->o_currec;

    newcl = TRUE;

    if (!curcl) {
	/* our r/w pointer is not valid */
	DBCMD("print start of file;_c");
	curcl = dfd->dfd_strtcl;
	swp68(curcl);
	if (!curcl) {
	    /* file is empty */
	    DBCMD("print file is empty;_c");
	    if (!wrtflg) return 0;
	    if (!(curcl = nextcl(0,dmd,wrtflg,NULL))) {
		/* can't extend file from zero size */
		return 0;
	    }
	    dfd->dfd_strtcl = curcl;
	    swp68(dfd->dfd_strtcl);
	    dfd->dfd_dirty = 1;
	    /* set extended now; if there's a middle this is set again */
	    extended = TRUE;
	}
	currec = cl2rec(curcl,dmd);
    }
    else {
    	if (currec >= (cl2rec(curcl,dmd) + dmd->m_clsiz)) {
	    /* a previous read/write ended at a cluster boundary. */
	    if (!(curcl = nextcl(curcl,dmd,wrtflg,NULL))) {
		/* no next cluster: end of file or full disk */
		return 0;
	    }
	    currec = cl2rec(curcl,dmd);
	}
    }

    DBCMD((ofd->o_curcl = curcl, ofd->o_currec = currec,
	  "print OFD at top of xrw call:;do_ofd (lpeek (+ `a6 a));_c"));

    recoffs = bytnum & dmd->m_rbm;

    if (!recoffs) lenhead = 0;
    else lenhead = min(recsiz-recoffs,len);

    /* do the head */
    if (lenhead) {
	DBCMD("print do head;_c");
	bufp = getrec(currec+dmd->m_recdata,dmd,wrtflg,NULL);
	(*bufxfr)(lenhead,bufp+recoffs,ubufr);
	ubufr += lenhead;
	bytnum += lenhead;
	len -= lenhead;

	/* incr currec if head ended at end of record (even if done) */
	if ((bytnum & dmd->m_rbm) == 0) ++currec;

	/* if more to do, extend file to include next cluster */
	if (len && ((currec & dmd->m_clrm) == 0)) {
	    DBCMD("print more to do and fell off - a cluster: advance;_c");
	    xcl = nextcl(curcl,dmd,wrtflg,NULL);
	    if (xcl == 0) goto eof;
	    curcl = xcl;
	    currec = cl2rec(curcl,dmd);
	}
    }

    /* head is done. Now compute lentail, lenmid. lenmid counts RECORDS. */

    lentail = len & dmd->m_rbm;
    len -= lentail;
    lenmid = len >> dmd->m_rblog;

    if (lenmid) {
	DBCMD("print do middle;_c");
	run_start = currec;
	run_len = 1;
	while (--lenmid) {
	    DBCMD("print top of middle loop;_c");
	    if ((++currec & dmd->m_clrm) == 0) {
		/* fell off a cluster */
		xcl = nextcl(curcl,dmd,wrtflg,NULL);
		if (xcl == 0) goto eof;
		curcl = xcl;
		currec = cl2rec(curcl,dmd);
		if (currec != (run_start+run_len)) {
		    DBCMD("print discontiguous record: do the run;_c");
		    usrio(wrtflg,run_len,run_start,ubufr,dmd);
		    runlen = ((ulong)run_len) << dmd->m_rblog;
		    ubufr += runlen;
		    bytnum += runlen;
		    /* set up next run */
		    run_start = currec;
		    run_len = 0;
		}
	    }
	    ++run_len;
	}

	DBCMD("print out of middle loop: do the last run;_c");
	usrio(wrtflg,run_len,run_start,ubufr,dmd);
	runlen = ((ulong)run_len) << dmd->m_rblog;
	ubufr += runlen;
	bytnum += runlen;

	/* incr currec even if no more to do, as a signal for next time */
	currec++;

	/* if there's more work and fell off a clust, advance to next cl */
	if (lentail && ((currec & dmd->m_clrm) == 0)) {
	    DBCMD("print there is a tail and it starts a new cluster;_c");
	    xcl = nextcl(curcl,dmd,wrtflg,&extended);
	    if (xcl == 0) goto eof;
	    curcl = xcl;
	    currec = cl2rec(curcl,dmd);
	}
    }

    /* do tail bytes in last record */

    if (lentail) {
	DBCMD("print do the tail;_c");
	/* getrec for the record; if extended, don't read it in */
	bufp = getrec(currec + dmd->m_recdata,
			dmd,
			(extended ? 2 : wrtflg),
			NULL);
	(*bufxfr)(lentail,bufp,ubufr);
	bytnum += lentail;

	/* incr currec if tail filled up record, as a flag for next time */
	if ((bytnum & dmd->m_rbm) == 0) currec++;
    }

eof:
    /* set rc to actual number of bytes transferred */
    rc = bytnum - ofd->o_bytnum;
    ofd->o_currec = currec;
    ofd->o_curcl = curcl;
    ofd->o_bytnum = bytnum;
    if (bytnum > dfd->dfd_fileln) {
	dfd->dfd_fileln = bytnum;
	dfd->dfd_dirty = 1;
    }

    DBCMD("print OFD after xrw call:;do_ofd (lpeek (+ `a6 a));_c");
    return rc;
}


/*
 * ckdrv: return 0 for success.  Checks to see if a drive exists, logs it
 * in if so and doesn't have a DMD.  drvsel is a bitmap of drives which
 * have DMD's.  If a drive experiences mediach, its drvsel bit is cleared.
 * If the subsequent getbpb fails, it won't get set again.
 *
 * Call this before doing anything with any drive in an OS call. fn2dir is
 * a good choice, but some calls (Fsnext, Dgetpath) don't take file names,
 * yet need to use this call.
 */

long
ckdrv(d)
uint d;
{
    uint mask;
    BPB *b;

    mask = 1 << d;

    if (!(drvsel & mask)) {
	b = (BPB *)getbpb(d);
	if (!b) return ERROR;
	log(b,d);
	drvsel |= mask;
	run->p_curdir[d] = 0;
    }
    return E_OK;
}

/*
 * Login `drv' given BPB `b'.
 *
 */
voidfn
log(b,drv)			/* log in a media b on drive drv */
BPB *b;
int drv;
{
    DMD *dmd = &drvtbl[drv];

    dmd->m_recfat = b->fatrec;
    dmd->m_recrd = b->fatrec + b->fsiz;
    dmd->m_recdata = b->datrec;
    dmd->m_drvnum = drv;
    dmd->m_fsiz = b->fsiz;
    dmd->m_clsiz = b->clsiz;
    dmd->m_clsizb = b->clsizb;
    dmd->m_recsiz = b->recsiz;
    dmd->m_numcl = b->numcl;
    dmd->m_clrlog = log2(b->clsiz);
    dmd->m_clrm = b->clsiz - 1;
    dmd->m_rblog = log2(b->recsiz);
    dmd->m_rbm = b->recsiz - 1;
    dmd->m_clblog = log2(b->clsizb);
    dmd->m_16 = b->b_flags;
}


/*
 * Dfree()
 */

long
xgetfree(buf,drv)
uint drv;
long *buf;
{
    uint i;
    uint free;
    DMD *dmd;
    uint end;

    drv = (drv ? drv-1 : run->p_curdrv);

    if (ckdrv(drv)) return ERROR;

    dmd = &drvtbl[drv];
    free = 0;
    newcl = TRUE;
    end = dmd->m_numcl + 2;

    if (dmd->m_16) free = fastcl(dmd,TRUE);
    else {
	for (i = 2; i < end; i++) 
	    if (!getcl(i,dmd))
		free++;
    }

    newcl = TRUE;
    *buf++ = (long)(free);
    *buf++ = (long)(dmd->m_numcl);
    *buf++ = (long)(dmd->m_recsiz);
    *buf++ = (long)(dmd->m_clsiz);
    return(E_OK);
}
