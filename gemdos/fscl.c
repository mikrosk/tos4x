/*
***************************     FSCL.C     ******************************
*
* $Revision: 2.6 $	$Source: /u2/MRS/osrevisions/gemdos/fscl.c,v $
* =======================================================================
* $Author: apratt $ 	$Date: 90/08/03 13:40:45 $    $Locker:  $
* =======================================================================
*
* $Log: fscl.c,v $
* Revision 2.6  90/08/03  13:40:45  apratt
* TTOS FINAL RELEASE
* 
* Revision 2.5  90/05/21  12:52:12  apratt
* Changed flush(): now only called when the buffer is valid & dirty.
* (Also fixed a bug - bufl[buflist(n)] confused old Alcyon, and besides,
* n was not getting each buffer's type.)
* 
* Added flushall(), called in ixclose, to flush all dirty buffers on all
* drives.
* 
* Revision 2.4  90/04/24  10:59:14  apratt
* Removed some conditional compilations: BIGPARTS, FASTCL, and BIGCL.
* Those are always the case now.  Also FASTRAM is gone (see mem.c).
* 
* Revision 2.3  90/04/18  09:45:49  apratt
* Fixed a bug in flush() reported by a user(!): the first pass
* through the loop looked at the system variable space starting
* with bufl[N] as if it were a BCB.  Worked only because b_link
* is the first field in a BCB, and because the system variables
* hardly ever (never?) added up to a BCB that met the qualifications
* for writing.
* 
* Revision 2.2  89/04/17  17:13:58  kbad
* YA header change
* 
* Revision 2.1  89/02/21  17:18:28  kbad
* *** TOS 1.4  FINAL RELEASE VERSION ***
* 
* Revision 1.22  88/11/18  15:07:40  apratt
* Added line to invalidate a victim buffer.  Without this, a read error
* when loading up the new contents of the buffer leaves the old one valid.
* 
* Revision 1.21  88/10/20  17:35:15  apratt
* Fixed sign-extension bug which caused 12-bit FATs on disks
* with >2048 clusters to fail.  Now 12-bit FATs work for up
* to 4096 clusters, which is as it should be.
* 
* Revision 1.20  88/08/16  17:44:08  apratt
* Add check: don't decrement diruse[i] past zero.  This blocks but
* doesn't fix the diruse mismanagement bug.
* 
* Revision 1.19  88/08/08  17:41:40  apratt
* Changed location of one brace in ifdefs in flush(), so vgrind would
* not get confused.  NO CODE CHANGE.
* 
* Revision 1.18  88/07/12  16:01:06  apratt
* Added CKMEDIA code to ckdrv() ... otherwise chdir, getdir, and some
* other functions don't recognize media change.  This finally fixes
* the last media-change bugaboo, I hope.
* 
* Revision 1.17  88/07/11  18:20:27  apratt
* Fixed one line in getcl which seems to make 1K clusters work for
* big partitions.
* 
* Revision 1.16  88/07/11  17:05:50  apratt
* Added code which is compiled only if FASTCL is defined.  It speeds
* up the two slowest FAT operations: find-first-free-cluster and
* find-free-space.  Only works for 16-bit FATs; others still slow
* (but, good God, not as slow as old TOS!).
* 
* Revision 1.15  88/07/11  16:48:03  apratt
* Fixed FLUSHALL code so it doesn't flush RD sectors to "both FATS."
* (Also, BIGPART in the log message below should be BIGPARTS.)
* 
* Revision 1.14  88/07/06  17:36:11  apratt
* Added a macro for determining buffer list number from buffer type,
* and new code (ifdef FLUSHALL) which writes all dirty buffers to a
* drive when it flushes any of them (within one buffer list).  Fclose
* still flushes all buffers on all drives.  No code change if you
* don't define FLUSHALL.
* 
* Revision 1.13  88/07/06  15:10:13  apratt
* Removed register argument declarations in xgetfree (old Alcyon
* doesn't like them, even though in this case it worked).
* 
* Fixed an expression which revealed a compiler bug:
* long x &= 0xffff; sign-extends 0xffff into -1L.  Now 32MB code
* works with old compiler.  Works perfectly as far as I can tell.
* 
* Revision 1.12  88/06/30  13:21:30  apratt
* Added BIGPART code for 32MB partitions.  Seems to work.
* No code change if you don't define BIGPART.
* 
* Revision 1.11  88/06/13  15:23:38  apratt
* Added final version of >2 sec/cl code... It gets included if you
* define BIGCL.  Without BIGCL, there is **NO CODE CHANGE** but the
* BIGCL code has been tested pretty well.
* 
* Revision 1.10  88/06/13  15:05:49  apratt
* Header style change
* 
* Revision 1.9  88/05/31  12:27:29  apratt
* Added a comment to permit >2 sectors/cluster, per comments by a
* German developer (I forget his name).  *NO CODE CHANGE* -- just a
* reminder if I ever want to fix this limitation.
* 
* Revision 1.8  88/05/02  15:03:05  apratt
* Removed usr2xfr and xfr2usr routines; moved to rwa.s.
* 
* Revision 1.7  88/05/02  12:53:55  apratt
* Removed invalidation in flush(), put it in usrio where it belongs.
* Now data and subdirectory buffers, dirty or not, don't get invalidated
* when they're flushed.  Usrio() still invalidates the buffers it
* flushes, which is the only time it's necessary.
* 
* Revision 1.6  88/04/30  19:07:56  apratt
* Reworked 12-bit fat code to get around a compiler bug: compiler did
* word moves when assigning to *(char *)(&fatword).  Also, the last
* cluster on the disk is handled correctly, unlike the previous rev (1.5).
* 
* Revision 1.5  88/04/29  17:34:00  apratt
* Fixed yet another bug in getfat related to wflag... caused read-then-write
* not to mark the FAT sector for writing.  VERY BAD BUG -- means you
* can't use the TOS version that Slavik made on 4/29/88.  Sorry!
* 
* Revision 1.4  88/04/28  18:17:56  apratt
* Use divmod rather than % and / before Getfat() (divmod now a macro).
* Also fixed a bug in getfat which called getrec with wflag=1 always.
* 
* Revision 1.3  88/04/27  16:35:45  apratt
* Added improved FAT code for 12-bit FATs, and streamlined the whole
* getrec business (using macro Getfat and function getfat).
* 
* Revision 1.2  88/04/27  11:48:28  apratt
* Backed out missing-two-cluster fix (made it dependent on
* defining MISSING2CLFIX).
* 
* Revision 1.1  88/04/26  14:48:17  apratt
* Version used 4/22/88 to make test ROMs
* 
*************************************************************************
*/

/****************************************************************************\
* 									     *
* GEMDOS File System Cluster and Drive Handling				     *
* (C)1986 Atari Corp.							     *
* 									     *
* ---- Edit history (reverse order, please): ------------------------------  *
* 									     *
* 20-Apr-1988 akp	Made bufl[0] the FAT *and* root dir, 1 is other.     *
*			Also, flush doesn't invalidate buffers in list 0.    *
*			(This is only #ifndef OLDBUF.)			     *
* 05-Apr-1988 akp	Fixed "missing 2 clusters" bug -- limits were wrong  *
*			because of the two non-entries in the FAT.	     *
*			Fixes in both nextcl and xgetfree.		     *
* 24-Mar-1988 akp	Removed checks on MGET because it panics.	     *
* 17-Feb-1988 akp	Lintified.					     *
* 03-Feb-1988 akp	Cleaned up REG declarations (no more q_p).	     *
* 12-Jan-1988 akp	Removed panic messages (because MGET either works    *
*			or panics itself).				     *
* 13-Nov-1987 akp	Backed out media change: fatfingered other stuff.    *
* 09-Nov-1987 akp	Added media change check in ckdrv. Shouldn't it have *
*			been there all along? The comment about that fn	     *
*			said it checked media change also, but it didn't!    *
* 06-Nov-1987 akp	Added some REG declarations.			     *
* 21-Oct-1987 akp	Lintified.					     *
* 22-Sep-1987 akp	Added new cluster code for getcl and clfix.	     *
*			Added initialization of m_fatrec in log().	     *
* 17-Sep-1987 akp	Removed erroneous re-validation of buffers in flush. *
*			The buffer argument to flush must be invalidated     *
*			before flush returns if not a FAT buffer.	     *
*			Added REG declarations to xfr2usr.                   *
* 17-Jan-1986 lmd	Commented and prettified from Digital Research	     *
* 			source code.					     *
* 30-Jan-1986 lmd	Broken out from old FS.C			     *
* 									     *
\****************************************************************************/

#include "fs.h"
#include "gemerror.h"
#include "fsdecl.h"

/* 
 * macro to turn a buftyp into a buffer list number.
 * Input n is 0 for FAT, 1 for RD, 2 for data.
 * Originally, this formula was ((n) != 0), meaning the FAT was
 * on its own list and RD and data shared the other.  This
 * formula (FAT & RD on one, data on the other) makes more
 * sense to me.
 *
 * This macro is used in getrec to assign a block to a list,
 * and in flush to determine which list the buffer's on.
 */
#define buflist(n) ((n) == 2)

/*
 *  Allocate raw DMD;
 *	allocate DND for root directory;
 *	allocate OFD for root directory;
 *	allocate OFD for FAT sectors.
 *
 * Since MGET panics when it fails, we don't ever return errors.
 */
DMD
*getdmd(drv)
int drv;
{
  REG DMD *dm;

    drvtbl[drv] = dm = MGET(DMD);
    dm->m_dtl = MGET(DND);

    dm->m_dtl->d_ofd = MGET(OFD);
    dm->m_fatofd = MGET(OFD);
    return dm;
}


/*
 * Login `drv' given BPB `b'.
 *
 */
long
log(b,drv)			/* log in a media b on drive drv */
BPB *b;
int drv;
{
  OFD *fo;
  OFD *f;
  DND *d;
  DMD *dm;
  int rsiz;
  int cs;
  int n;
  int fs;
  int ncl;
  int fcl;
  
  rsiz = b->recsiz;
  cs = b->clsiz;
  n = b->rdlen;
  fs = b->fsiz;
  dm = getdmd(drv);
  d = dm->m_dtl;
  dm->m_fsiz = fs;			/* fat size */
  f = d->d_ofd;				/* root dir file */
  dm->m_drvnum = drv;
  f->o_dmd = dm;
  d->d_drv = dm;
  d->d_name[0] = 0;
  dm->m_fatrec = b->fatrec;
  dm->m_16 = b->b_flags & 1;
  dm->m_clsiz = cs;
  dm->m_clsizb = b->clsizb;
  dm->m_recsiz = rsiz;
  dm->m_numcl = b->numcl;
  dm->m_clrlog = log2(cs);
  dm->m_clrm = logmsk[dm->m_clrlog];
  dm->m_rblog = log2(rsiz);
  dm->m_rbm = logmsk[dm->m_rblog];
  dm->m_clblog = log2(dm->m_clsizb);
  f->o_fileln = n * rsiz;
  
  /* number of "clusters" for root dir */
  ncl = (n + cs - 1)/cs;
  d->d_strtcl = f->o_strtcl = -1 - ncl;
  fcl = (fs + cs - 1)/cs;
  fo = dm->m_fatofd;			/* fat "file" */
  fo->o_strtcl = d->d_strtcl - fcl;
  fo->o_dmd = dm;
  dm->m_recoff[0] = b->fatrec - (fo->o_strtcl * cs);
  dm->m_recoff[1] = (b->fatrec + fs) - (d->d_strtcl * cs);
  
  /* 2 is first data cluster */
  dm->m_recoff[2] = b->datrec - (2 * cs);
  fo->o_bytnum = 3;
  fo->o_curbyt = 3;
  fo->o_fileln = fs * rsiz;
  
  return (0L);
}

/*
 *  Flush a buffer
 *
 *  5/90: flush is only called from this source file (fscl.c),
 *  and it's only called when the buffer in question is actually
 *  dirty.  Therefore it doesn't check the validity or dirtiness
 *  of the buffer.
 *
 *  Flushing any buffer writes all buffers on that drive and that list.
 */

flush(x_b)
BCB *x_b;
{
  REG BCB *b;
  REG int n;
  REG int d;
  REG DMD *dm;
  int i;

  b = x_b;

  dm = b->b_dm;
  n = b->b_buftyp;
  d = b->b_bufdrv;

  /*
   * flush all dirty buffers on this list and on this drive.
   * (Unfortunately, they're flushed in LRU order, but this is
   * actually likely to be pretty sequential.)
   */

  i = buflist(n);

  for (b = bufl[i]; b; b = b->b_link) {
    if (b->b_bufdrv == d && b->b_dirty) {
    	n = b->b_buftyp;	/* n gets THIS BUFFER's type */
	b->b_bufdrv = -1;	/* invalidate now in case of error */
	rwabs(1,b->b_bufr,1,b->b_bufrec+dm->m_recoff[n],d);
	/* if FAT operation, flush to both FATs */
	if (!n) 
	    rwabs(1,b->b_bufr,1,b->b_bufrec+dm->m_recoff[0]-dm->m_fsiz,d);
	/* re-validate the buffer */
	b->b_bufdrv = d;
	b->b_dirty = 0;
    }
  }
}


/*
 * function to flush all dirty buffers on all drives.
 *
 * This is called by ixclose, because closing any file is now
 * guaranteed to flush all buffers on all drives. There may one 
 * day be a new call which does that explicitly, too.
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

flushall()
{
    REG BCB *b;
    REG int d;
    REG int l;

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

/*	Last modified	SCC	10 Apr 85

NOTE:	rwabs() is a macro that includes a longjmp() which is executed if the
	BIOS returns an error, therefore usrio() does not need to return any
	error codes.
*/

usrio(rwflg,num,x_strt,ubuf,dm)
int rwflg,num;
int x_strt;
char *ubuf;
DMD *dm;
{
	REG BCB *b;
	REG int d;
	REG int end;
	REG int strt;

	strt = x_strt;
	end = strt+num;
	d = dm->m_drvnum;

	/* flush all data blocks which overlap this write */
	for (b = bufl[1]; b; b = b->b_link) {
	    if ((b->b_bufdrv == d) &&
		(b->b_bufrec >= strt) &&
		(b->b_bufrec < end)) {
		    if (b->b_dirty) flush(b);
		    b->b_bufdrv = -1;	/* invalidate the buffer */
	    }
	}

	rwabs(rwflg,ubuf,num,strt+dm->m_recoff[2],dm->m_drvnum);
}


char
*getrec(x_recn,x_dm,wrtflg)
int x_recn;
DMD *x_dm;
int wrtflg;
{
	REG int recn;
	REG DMD *dm;
	REG BCB *b;
	REG int n;
	REG int cl;
	REG int err;
	BCB *p;
	BCB *mtbuf;
	REG BCB **q;
	BCB **phdr;
/*	long *scr;/**/
/*	char *p_kbshift = *(char **)((*(long *)0x4f2)+0x24);/**/

	recn = x_recn;
	dm = x_dm;

	/* put bcb management here */

	/*
	 * THIS CODE PERMITS UP TO 32MB PER PARTITION.
	 * The trick is to differentiate large, positive sector numbers from
	 * the negative sector numbers used for FAT and root directory ops.
	 * The FAT & RD sectors are in [xx..-1]; numbers outside
	 * that range are large positive sector numbers.  
	 *	XX = - ( dm->m_recoff[0] - dm->m_fatrec )
	 * 
	 */
	{
	    long xrecn = recn;
	    if (recn >= 0 || (recn < (- dm->m_recoff[0] - dm->m_fatrec))) {
		/* it's not meant to be negative */
		/* old compiler bug: 0xffff gets sign extended, so use L */
		xrecn &= 0xffffL;
	    }
	    /* rhs of the < is a negative "sector number" where RD starts */
	    if (xrecn < (dm->m_dtl->d_strtcl << dm->m_clrlog)) 
		n = 0;
	    else if (xrecn < 0) n = 1;
	    else n = 2;
	}

/*	scr = ((long *)0x3f8000) + n;/**/

	mtbuf = 0;

	/* CHANGED by AKP 4/88: bufl 0 is FAT/root dir, bufl 1 is other */
	phdr = &bufl[buflist(n)];

	/* set b to the matching buffer or the LAST empty buffer */
	for (b = *(q = phdr); b; b = *(q = &b->b_link))
	{
		if ((b->b_bufdrv == dm->m_drvnum) && (b->b_bufrec == recn)) {
			break;
		}

		/* empty buffer? remember it */
		if (b->b_bufdrv == -1) {
			mtbuf = b;
		}
	}
	if (!b)
	{	/* we went to the end of the list. */
		/* if mtbuf, set b to it and q to its prev's link */
		/* else set b to last buffer in the list & q to prev's link */

		if (mtbuf) {
			/* miss, but there's an empty */
			b = mtbuf;
/*			*scr = 0x0000ffffL;/**/
		}
/*		else {/**/
/*			/* miss, need to select a victim */
/*			*scr = 0x0000aaaaL;/**/
/*		}/**/

		/* need to find predecessor of mtbuf, or last guy */
doio:		for (p = *(q = phdr); p->b_link; p = *(q = &p->b_link))
			if (b == p)
				break;

		b = p;
		if (b->b_bufdrv != -1 && b->b_dirty) flush(b);

		/* INVALIDATE this buffer because the rwabs might fail! */
		b->b_bufrec = -1;
		rwabs(0,b->b_bufr,1,recn+dm->m_recoff[n],dm->m_drvnum);
		b->b_bufrec = recn;
		b->b_dirty = 0;
		b->b_buftyp = n;
		b->b_bufdrv = dm->m_drvnum;
		b->b_dm = dm;
	}
	else {
		/* cache hit */
		/* use a buffer, but first validate media */
/*		*scr = 0xffff0000L;/**/
		if (err = trap13(9,b->b_bufdrv))
			if (err == 1)
				goto doio; /* media may be changed */
			else if (err == 2)
			{ /* media definitely changed */
				errdrv = b->b_bufdrv;
				rwerr = E_CHNG; /* media change */
				longjmp(errbuf,rwerr);
			}
	}

	/* make this block most-recently-used in its list */
	*q = b->b_link;
	b->b_link = *phdr;
	*phdr = b;

	if (wrtflg)
		b->b_dirty = 1;

/*	if (*p_kbshift & 0x10) {/**/
/*		while (!(*p_kbshift & 0x02)) ;/**/
/*		while (*p_kbshift & 0x02) ;/**/
/*	}/**/
/*	*scr = 0;/**/
	return(b->b_bufr);
}


/***********************************************************************/
/***********************************************************************
 * New FAT code by AKP 17-Sep-1987
 *
 * This code circumvents almost all of the seek/read/write stuff by
 * asking for the FAT buffer directly from the disk cache.
 * Flush() takes care of the two-copies-of-a-FAT stuff.
 *
 * NOTE: This code assumes that there are at least two FAT buffers,
 * and that they're managed LRU: For non-16-bit FATs, it can call
 * getrec twice to get pointers to *two* FAT buffers, and assume they 
 * are both in memory at the same time.
 *
 **********************************************************************/

int newcl;		/* flag: goes TRUE at start of a cluster loop */
int clsector;		/* holds saved sector number */
DMD *cldev;		/* holds DMD of saved sector */
char *clsave;		/* holds saved sector pointer */
int clwrite;		/* when TRUE, the sector has been marked dirty */

/*
 * getfat: this combination of macro and procedure returns the requested
 * FAT sector from the disk, with a combination of speed & small code size.
 */

#define Getfat(s,dm,wflag) \
    ((newcl || (cldev != (dm)) || \
     (clsector != (s)) || ((wflag && !clwrite))) ? \
	getfat((s),(dm),(wflag)) : clsave)

char
*getfat(s,dm,wflag)
unsigned int s;
DMD *dm;
int wflag;
{
	/* get the buffer the sector is in */
	newcl = TRUE;		/* do this in case getrec longjmp's */
	clsave = getrec(s-(dm->m_recoff[0]-dm->m_fatrec),dm,wflag);
	clsector = s;
	cldev = dm;
	clwrite = wflag;
	newcl = FALSE;
	return clsave;
}


#define hibyte(w) (((w) >> 8) & 0xff)
#define lobyte(w) ((w) & 0xff)

clfix(x_cl,link,x_dm)
int x_cl;
int link;
DMD *x_dm;
{
    REG int cl;
    REG DMD *dm;

    /* used by m_16 only */
    int offset;
    REG unsigned int sector;
    REG char *buf;
    char *obuf;
    REG long pos;
    
    /* used by !m_16 only */
    int mask;
    unsigned fatword;
    REG char *fptr;	/* points to first byte of fatword */
    char *q;		/* points to buf[offset] once that's known */

    cl = x_cl;
    dm = x_dm;

    if (dm->m_16) {
	/* compute byte offset into FAT */
	pos = ((long)cl) << 1;

	/* now compute start of sector in FAT and byte offset in sector */
	sector = divmod(&offset,pos,dm->m_rblog);

	buf = Getfat(sector,dm,TRUE);	/* get sector for writing */

	swp68(link);
	*(int *)(&buf[offset]) = link;
	return;
    }
    else {
	fptr = &fatword;
	pos = (cl + (cl >> 1));

	link = link & 0x0fff;

	if (cl & 1) {
	    link = link << 4;
	    mask = 0x000f;
	}
	else
	    mask = 0xf000;

	/* hand-compute record and byte offset */
	sector = divmod(&offset,pos,dm->m_rblog);

	buf = Getfat(sector,dm,TRUE);	    /* get fat sector for writing */

	/* fatword comes out of this pre-swapped from 8088 format */

	*(fptr+1) = *(q = &(buf[offset]));
	if (offset == dm->m_recsiz-1) {
	    /* get next sector for the other half of the fat word */
	    obuf = buf;		/* save old buffer address */
	    buf = Getfat(sector+1,dm,TRUE);
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

getcl(x_cl,x_dm)
int x_cl;
DMD *x_dm;
{
    REG int cl;
    REG DMD *dm;

    REG long pos;
    unsigned offset;
    REG unsigned int sector;
    REG char *buf;

    unsigned fatword;
    REG char *fptr;	/* points to first byte of fatword */
    char *q;		/* points to buf[offset] when that's known */

    cl = x_cl;
    dm = x_dm;


    /*
     * RD clusters are in the range [XX..-1] wher XX is d_strtcl for RD.
     * NOTE: Jason's code originally used negative cl numbers for FAT,
     * but my new cluster code does not. Otherwise this would not be
     * sufficient.
     */

    if (cl < 0 && cl >= dm->m_dtl->d_strtcl) return cl+1;

    if (dm->m_16) {
	/* compute byte offset into FAT */
	pos = ((long)cl) << 1;

	/* now compute sector number in FAT and byte offset in the sector */
	sector = divmod(&offset,pos,dm->m_rblog);

	buf = Getfat(sector,dm,FALSE);

	fatword = *(int *)(&buf[offset]);
	swp68(fatword);
	return fatword;
    }
    else {
	fptr = &fatword;
    	pos = cl + (cl >> 1);
	sector = divmod(&offset,pos,dm->m_rblog);
    	buf = Getfat(sector,dm,FALSE);

	/* fatword comes out of this pre-swapped into 68000 format */
	*(fptr+1) = *(q = (&buf[offset]));
	if (offset == dm->m_recsiz-1) {
	    buf = Getfat(sector+1,dm,FALSE);
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

	return(cl);
    }
}


/**********************************************************************/

nextcl(x_p,wrtflg)
OFD *x_p;
int wrtflg;
{
	REG OFD *p;
	REG DMD *dm;
	REG int i;
	REG int cl;
	REG int cl2;
	REG int rover;
	REG int lastcl;

	p = x_p;
	cl = p->o_curcl;
	dm = p->o_dmd;

	/*
	 * NEW CODE for returning the "next cluster" of the root directory.
	 * RD clusters are in the range [xx..-1] where XX = d_strtcl for RD.
	 */
	if (cl < (dm->m_dtl->d_strtcl)) {
	    cl2 = cl + 1;
	    goto retcl;
	}
	else if (cl) cl2 = getcl(cl,dm);
	else cl2 = (p->o_strtcl ? p->o_strtcl : -1);

	if (wrtflg && (cl2 == -1))
	{ /* end of file, allocate new clusters */
	/* OPTIMIZE HERE FOR QUICK FINDING OF FIRST FREE CLUSTER ON DISK */
#ifdef MISSING2CLFIX
		lastcl = dm->m_numcl+2;
#else
		lastcl = dm->m_numcl;
#endif

		if (!cl && dm->m_16) {
		    if (cl2 = fastcl(dm,lastcl,FALSE)) i=0;
		    else i = lastcl;	/* failed */
		    goto gotcl;
		}

		/*
		 * this loop can run more than necessary, but only
		 * when you're out of space anyway, so don't bother
		 * trying to save a couple of milliseconds.
		 */

		rover = cl;
		for (i=2; i < lastcl; i++) 
		{
			if (rover < 2)
				rover = 2;

			if (!getcl(rover,dm))
				break;
			else
				rover = (rover + 1) % lastcl;
		}

		cl2 = rover;
gotcl:
		if (i < lastcl)
		{
			/* order changed by AKP to fix cl before cl2 */
			/* on the assumption that cl < cl2 (usually) */
			if (cl)
				clfix(cl,cl2,dm);
			else
			{
				p->o_strtcl = cl2;
				p->o_flag |= O_DIRTY;
			}
			clfix(cl2,-1,dm);
		}
		else
			return(-1);
	}

	if (cl2 == -1)
		return(-1);

retcl:	p->o_curcl = cl2;
	p->o_currec = cl2rec(cl2,dm);
	p->o_curbyt = 0;

	return(E_OK);
}

/*
 * Fast cluster code, invoked when looking for the first unused cluster
 * in a 16-bit FAT.  Call with freeflag TRUE to return number of free
 * clusters in the whole FAT.  (One "if" per sector doesn't seem
 * like too high a price to pay.)
 *
 * 'i' is used as a FAT sector counter.  'end' is set to the index
 * of the last FAT sector actually used (independent from dm->m_fsiz).
 * 'end' is computed in a sector-size-independent way.
 * In the inner loop, 'cl' is the count of words left to check in this
 * sector: it starts out short by two (and buf starts out incremented
 * by two words) in the first FAT sector.
 *
 * If a free cluster is found, its number is put in cl2, and i is
 * set to zero, so the later test "if (i < lastcl)" will fail.
 *
 * Note that little-g getfat() is used, for low overhead.
 */

fastcl(dm,x_lastcl,freeflag)
DMD *dm;
int x_lastcl;
int freeflag;
{
    REG int *buf;
    REG char *free;
    REG int clcount;
    REG int cl;
    REG int i;
    REG int lastcl;
    REG int clpersec;	    /* clusters represented by each sector of FAT */

    lastcl = x_lastcl;

    clpersec = dm->m_recsiz >> 1;

    /* be sneaky: use an A register as a counter.  Who'll know? */
    free = 0L;

    /* set up the first pass here; remainder get set up before "goto again" */

    i = 0;
    clcount = 2;
    cl = min(clpersec,lastcl) - 2;
    buf = ((int *)getfat(i,dm,FALSE)) + 2;

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
	buf = getfat(i,dm,FALSE);
	goto again;
    }

    /* drop out of the loop here. */

    return 0;
}


addit(x_p,siz,flg)
OFD *x_p;
long siz;
int flg; /* update curbyt ? (yes if less than 1 cluster transferred) */
{
	REG OFD *p;

	p = x_p;
	p->o_bytnum += siz;

	if (flg)
		p->o_curbyt += siz;

	if (p->o_bytnum > p->o_fileln)
	{
		p->o_fileln = p->o_bytnum;
		p->o_flag |= O_DIRTY;
	}
}


long
xrw(wrtflg,x_p,len,ubufr,bufxfr)
int wrtflg,(*bufxfr)();
OFD *x_p;
long len;
char *ubufr;
{
REG	OFD *p;
	char *bufp;
REG	DMD *dm;
	int bytn,recn,rsiz,lenxfr,csiz,csizb,lentail,num;
	int hdrrec,lsiz,tailrec;
	int last, nrecs, lflg; /* multi-sector variables */
	long nbyts;
REG	long rc;
	long bytpos,lenrec,lenmid;
	int hlen;

	p = x_p;

	/* determine "header" of request */

	dm = p->o_dmd;
	rsiz = dm->m_recsiz;
	csiz = dm->m_clsiz;
	csizb = dm->m_clsizb;
	bytpos = p->o_bytnum; /* starting file position */
	recn = divmod(&bytn,(long) p->o_curbyt,dm->m_rblog);
	recn += p->o_currec;

	if (bytn) /* do header */
	{
	  lenxfr = min(len,rsiz-bytn);
	  bufp = getrec(recn,dm,wrtflg);
	  addit(p,(long) lenxfr,1);
	  len -= lenxfr;
	  recn++;
	  if (!ubufr) 
	  {
	    rc = (long) (bufp+bytn);
	    goto exit;
	  }
	  (*bufxfr)(lenxfr,bufp+bytn,ubufr);
	  ubufr += lenxfr;
	}
	lentail = len & dm->m_rbm;

	newcl = TRUE;		/* AKP: new loop of cluster calls */

	/* is there any middle part ? */

	if (lenmid = len - lentail)
	{ /* do "header" records left in current cluster */
	  hdrrec = recn & dm->m_clrm;
	  if (hdrrec)
	  {
	    /*
	     * hdrrec is record offset in current cluster.
	     * lenmid is number of bytes in whole records left to go.
	     * set hlen = min(records-left-to-go,
	     *			records-left-in-current-cluster)
	     */
	    if ((hlen = (lenmid >> dm->m_rblog)) > (dm->m_clsiz - hdrrec))
		hlen = dm->m_clsiz - hdrrec;
	    usrio(wrtflg,hlen,recn,ubufr,dm);
	    ubufr += (lsiz = hlen << dm->m_rblog);
	    lenmid -= lsiz;
	    addit(p,(long) lsiz,1);
	  }
	  /* do "middle" complete clusters */
	  lenrec = lenmid >> dm->m_rblog;
	  num = divmod(&tailrec,lenrec,dm->m_clrlog);
	  last = nrecs = nbyts = lflg = 0;
	  while (num--)
	  {
	    rc = nextcl(p,wrtflg);
	    /* if eof or non-contiguous cluster, or last cluster of request, */
	    /* 		then finish pending I/O */
	    if ((!rc) && (p->o_currec == last + nrecs))
	    {
		nrecs += csiz;
		nbyts += csizb;
		if (!num) goto mulio;
	    }
	    else
	    {
		if (!num)
			lflg = 1;
mulio:		if (nrecs)
			usrio(wrtflg,nrecs,last,ubufr,dm);
		ubufr += nbyts;
		addit(p,nbyts,0);
		if (rc)
			goto eof;
		last = p->o_currec;
		nrecs = csiz;
		nbyts = csizb;
		if ((!num) && lflg)
		{
			lflg = 0;
			goto mulio;
		}
	    }
	  }

	  /* do "tail" records */

	  if (tailrec)
	  {
	    if (nextcl(p,wrtflg))
		goto eof;
	    lsiz = tailrec << dm->m_rblog;
	    addit(p,(long) lsiz,1);
	    usrio(wrtflg,tailrec,p->o_currec,ubufr,dm);
	    ubufr += lsiz;
	  }
	}
	/* do tail bytes within this cluster */
	if (lentail)
	{
	  recn = divmod(&bytn,(long) p->o_curbyt,dm->m_rblog);
	  if ((!recn) || (recn == csiz))
	  {
		if (nextcl(p,wrtflg))
			goto eof;
		recn = 0;
	  }
	  bufp = getrec(p->o_currec+recn,dm,wrtflg);
	  addit(p,(long) lentail,1);
	  if (!ubufr)
	  {
	    rc = (long) bufp;
	    goto exit;
	  }
	  (*bufxfr)(lentail,bufp,ubufr,wrtflg);
	}
eof:	rc = p->o_bytnum - bytpos;
exit:	newcl = TRUE;		/* AKP: set this just in case */
	return(rc);
}


/*
	Last modified	SCC	8 Apr 85
*/

long
ckdrv(x_d)
int x_d;	/* has this drive been accessed, or had a media change */
{
	REG int d;
	REG int mask;
	REG int i;
	REG BPB *b;
	long err;

	d = x_d;
	mask = 1 << d;

	if (!(mask & drvsel))
	{
		b = (BPB *)getbpb(d);
		if (!b)
			return(ERROR);
		if (log(b,d)) return (ENSMEM);
		drvsel |= mask;
	}
#ifdef CKMEDIA
1+; deliberate syntax error: this code doesn't work so don't use it.

	/* else drive exists, but need to validate it */
	else if (err = trap13(9,d)) {
	    if (err == 1) {
		/* only maybe: find out for sure */
		/* read into the same buf RWABS uses for reading serial	*/
		/* number, etc.  Don't care about the data, but will	*/
		/* actually read the disk if the state is "not sure."	*/
		extern char diskbuf[];		/* buffer exported by VDI */
		rwabs(0,diskbuf,1,0,d);
	    }
	    else {
	    	errdrv = d;
	    	rwerr = E_CHNG;
	    	longjmp(errbuf,rwerr);
	    }
	}
#endif
	if ((!run->p_curdir[d]) || (!dirtbl[run->p_curdir[d]]))
	{  /* need to allocate current dir on this drv */
		for (i = 1; i < NCURDIR; i++)
			if (!diruse[i])
				goto gotone;
		return(ERROR);

gotone:
		diruse[i]++;
		dirtbl[i] = drvtbl[d]->m_dtl;
		run->p_curdir[d] = i;
	}
	return(d);
}


/*	Function 0x36	d_free

	Error returns
		ERROR

*/

long
xgetfree(p_buf,p_drv) /*+ get disk free space data into buffer */
int p_drv;
long *p_buf;
{
REG	int drv;
REG	long *buf;
REG	int i;
REG	int free;
REG	DMD *dm;
REG	int end;

	drv = p_drv;
	buf = p_buf;

	drv = (drv ? drv-1 : run->p_curdrv);

	if ((i = ckdrv(drv)) < 0)
		return(ERROR);

	dm = drvtbl[i];
	free = 0;
	newcl = TRUE;		/* AKP: new loop of cluster calls */

#ifdef MISSING2CLFIX
	end = dm->m_numcl+2
#else
	end = dm->m_numcl;
#endif

	if (dm->m_16) free = fastcl(dm,end,TRUE);
	else {
	    for (i = 2; i < end; i++) 
		if (!getcl(i,dm)) 
		    free++;
	}

	newcl = TRUE;		/* AKP: set this again just in case */
	*buf++ = (long)(free);
	*buf++ = (long)(dm->m_numcl);
	*buf++ = (long)(dm->m_recsiz);
	*buf++ = (long)(dm->m_clsiz);
	return(E_OK);
}
