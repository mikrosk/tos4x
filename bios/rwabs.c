/*
******************* Revision Control System *****************************
*
* $Author: kbad $
* =======================================================================
*
* $Date: 1992/08/11 00:34:42 $
* =======================================================================
*
* $Locker:  $
* =======================================================================
*
* $Log: rwabs.c,v $
* Revision 2.11  1992/08/11  00:34:42  kbad
* TOS 4.00 Falcon030 first production version
*
* Revision 2.10  1992/07/27  20:12:04  kbad
* Nearly last Sparrow test BIOS
*
* Revision 2.9  1992/05/18  23:08:30  unknown
* Added USE_DISK_CHANGE for Sparrow.  Flop.s and this file need to be
* built with that switch in the same state.  In this file the consequence
* is that wpstatus and wplatch are gone, and the disk-change line is used
* for media-change detection.  Other impact is stepping the drive to
* make that signal go away.
*
* Revision 2.8  91/08/26  16:37:14  apratt
* Changed to checksum only 6 sectors; diskbuf is under 4K in size in
* STe VDI.  Also changed to use dskbufp the pointer, not diskbuf
* the buffer, so changing the pointer really changes where this stuff
* goes.
* 
* Revision 2.7  91/08/05  15:15:33  apratt
* Added code to compute checksums on the first N sectors of a disk
* and compare with the old values, improving media-change detection
* by comparing FATs.  In addition, the serial number written by
* MSDOS versions 5.0 (4.0?) and newer is checked.  (This is all moot
* if your GEMDOS discards cached information when there are no open
* files and the media-change state is "maybe.")
* 
* Revision 2.6  91/06/20  14:09:52  apratt
* Added another bit in the flags word of the BPB: set flags & 2 when
* the floppy claims to have fewer than two FATs.  New GEMDOSes
* should check this and not write two FATs when this is set.
* 
* Revision 2.5  91/06/13  16:29:42  apratt
* Added a check of the four-byte serial number that MSDOS 5.0 puts at offset
* $27 in the boot sector.  For non-MSDOS 5.0 disks, this is just another four
* bytes' worth of chance to be different, but for MSDOS 5.0 disks it's the
* ONLY chance, since they all appear to have the same serial number.
* 
* See also GEMDOS of this date for new media change handling.
* 
* Revision 2.4  91/05/21  16:57:45  apratt
* Removed things which were ifdef DAS_BOOT, and left in unconditionally those
* things which were ifndef DAT_BOOT.  Added Protobt type 5 for quad density,
* against future need.  Changed some magic numbers into #defined constants.
* 
* 
* Revision 2.3  90/08/03  13:23:37  apratt
* TTOS FINAL RELEASE
* 
* Revision 2.2  89/11/27  14:50:03  apratt
* Added a fourth Protobt() disk type: 1.44MB (18 sec/2side/80trk).
* 
* Revision 2.1  89/02/21  17:22:52  kbad
* *** TOS 1.4  FINAL RELEASE VERSION ***
* 
* Revision 1.6  89/02/06  23:10:32  kbad
* mediach() used to use the 200Hz timer for the grace period, now uses
* the video frame counter (frclock).  This way, mediach() will work even
* if the 200Hz timer is disabled.
* 
* Revision 1.5  88/04/22  15:30:11  apratt
* Went back to 5-sector FATs thanks to a bug in the dual-drive code
* (that is, the logical A/B code for single-drive systems).  I don't
* know what the bug is yet, but it causes big trouble with differing
* FAT sizes.  This explains why PC disks don't always work on ST's.
* 						-- Allan
* 
* Revision 1.4  88/04/20  17:02:21  apratt
* Added initializing bflags in getbpb to zero -- 12-bit FATs.
* (Previously, this field went uninitialized... Just lucky, I guess.)
* 
* Revision 1.3  88/04/05  17:47:24  apratt
* Removed unsigned declarations (they don't work in old Alcyon)
* 
* Revision 1.2  88/02/26  17:02:16  apratt
* Changed boot params to match MSDOS better: floppies get 3 sectors/FAT
* and a media-descriptor byte of F9.
* Also changed to look for a boot sector on floppy regardless of bootdev.
* 
* Revision 1.1  87/11/20  14:24:34  lozben
* Initial revision
* 
* =======================================================================
*
* $Revision: 2.11 $
* =======================================================================
*
* $Source: d:/tos/bios\rcs\rwabs.c,v $
* =======================================================================
*
*************************************************************************
*/

#include "portab.h"

/*
 * ST Disk support (and random BIOS functions)
 * (C)1985 Atari Corp.
 *
 *----
 *  6-Feb-1989 kbad	Time mediach() grace period with video frames
 *			rather than 200Hz clock.  If the 200Hz timer
 *			got disabled, mediach() was always within the
 *			grace period.  Basing both the floppy WP status
 *			check and the access timer on Vblanks is safer.
 * 22-Apr-1988 akp	Changed back to 5 sec/FAT because of big bug
 *			in the dual-logical-to-lone-physycal mapping code.
 *			Haven't found the bug itself, but this sure
 *			manifested it.  This also explains why PC disks
 *			don't always work on ST's.
 * 26-Feb-1988 akp	Changed boot params to match MSDOS better.
 *			Floppies get 3 sec/FAT, media byte F9.
 *			Also changed to look for a boot sector on floppy 0
 *			regardless of bootdev.
 * 23-Feb-1985 lmd	Added multiple-sector floppy read support.
 * 23-Feb-1985 lmd	Added "rand()" function.
 * 24-Feb-1985 lmd	Added hard disk hooks.
 * 24-Feb-1985 lmd	Added floppy and hard boot code.
 * 25-Feb-1985 lmd	boot() goes to default boot device
 * 28-Feb-1985 lmd	boot() returns diagnostics, initializes disk system
 *  1-Mar-1985 lmd	Added proto_bt() boot sector prototyper
 *  1-Mar-1985 lmd	Added mediach(dev) BIOS call
 *  4-Mar-1985 lmd	getbpb() sets disk mode to "SAFE"
 *  4-Mar-1985 lmd	fixed bugs in proto_bt()
 *  9-Mar-1985 lmd	Added critical error handler hook
 * 13-Mar-1985 lmd	getbpb() returns NULL on read failure
 * 17-Mar-1985 lmd	Added write-verify switch
 * 22-Mar-1985 lmd	Added magic r/w mode to rwabs (rw = 2, 3)
 *  1-Apr-1985 lmd	Moved DSBs to flop.s (hooray!)
 *  8-Apr-1985 lmd	Cleaned up installable dev interface
 * 15-Apr-1985 lmd	Happy IRS day.
 * 15-Apr-1985 lmd	check for dev>=2 (only floppies allowed...)
 *  6-May-1985 lmd	Added access-timing depended UNSURE checking
 * 15-Jul-1985 lmd	Fixed problem with media changes prior to
 *			retrying after invoking the critical error handler.
 * 22-Aug-1985 lmd	Fixed problem with "double retries" on media removal;
 *			chkmedia() returns a hard error if the boot sector
 *			is unreadable.
 * 30-Aug-1985 lmd	Don't call chkmedia() in floprw() if the read/write
 *			mode doesn't permit media changes.
 *  3-Sep-1985 lmd	If 'buf' parameter to 'rwabs' is NULL (0L) then
 *			set the media-change mode to 'count'.  [Yuckko]
 *  9-Sep-1985 lmd	Check for BPS <= 0 and SPC <= 0 (not just zero) on
 *			BPB validation.  This is still a kludge.
 *
 */

/*
 * June 1991: added a check on the 32-bit serial number that MSDOS 5.0
 * puts at offset $27 in the boot sector.  For non-MSDOS 5.0 disks,
 * it's just another chance for two disks to be different.  For MSDOS 5.0
 * disks it's the only chance, since they all appear to have the same
 * three-byte serial number at offset 8.
 */

/*
 * May 1992: you can compile with -DUSE_DISK_CHANGE=1 to get a version
 * that uses the disk-change output from the floppy.
 */

#define	MAXACCTIM	82L	/* about 1.5 sec. "free" time... */
				/* Since this is based on video frames, */
				/* it varies with the monitor.  Oh well. */

#define	READ	0
#define	WRITE	1

#define	low8bits(x) ((x)&0xff)		/* unsigned coercion of char to int */




/*
 * Information we need from an IBM-PC-format
 * boot sector:
 */
#define	VOL_SERIAL	0x08	/* (.A) 24-bit volume serial#	*/
#define	IBM_BPS		0x0b	/* (.W) #bytes/sector		*/
#define	IBM_SPC		0x0d	/* (.B) #sectors/cluster	*/
#define	IBM_RES		0x0e	/* (.W) #reserved sectors	*/
#define	IBM_NFATS	0x10	/* (.B) #FATs			*/
#define	IBM_NDIRS	0x11	/* (.W) #root directory entries	*/
#define	IBM_NSECTS	0x13	/* (.W) #sectors on media	*/
#define	IBM_MEDIA	0x15	/* (.B) media descriptor byte	*/
#define	IBM_SPF		0x16	/* (.W) #sectors/FAT		*/
#define	IBM_SPT		0x18	/* (.W) #sectors/track		*/
#define	IBM_NSIDES	0x1a	/* (.W) #sides on dev		*/
#define	IBM_NHID	0x1c	/* (.W) #hidden sectors		*/
#define MSDOS5_SER	0x27	/* four-byte serial number	*/


#define	CRITICAL_RETRY	0x00010000L		/* "retry" return code */

/*
 * Error codes
 * Sort of like the PC-DOS ones
 */
#define	OK			0		/* the anti-error */
#define	ERROR			(-1)		/* anti-success */
#define	DRIVE_NOT_READY		(-2)
#define	UNKNOWN_CMD		(-3)
#define	CRC_ERROR		(-4)
#define	BAD_REQUEST		(-5)
#define	SEEK_ERROR		(-6)
#define	UNKNOWN_MEDIA		(-7)
#define	SECTOR_NOT_FOUND	(-8)
#define	NO_PAPER		(-9)		/* how can a disk do this? */
#define	WRITE_FAULT		(-10)
#define	READ_FAULT		(-11)
#define	GENERAL_MISHAP		(-12)		/* Captain_Catastrophe? */
#define	WRITE_PROTECT		(-13)
#define	MEDIA_CHANGE		(-14)
#define	UNKNOWN_DEVICE		(-15)
#define	BAD_SECTORS		(-16)		/* bad sectors on media */
#define	INSERT_DISK		(-17)		/* fake two drives */
#define	WRONG_DISK_DUMMY	(-18)		/* luser stuck in wrong disk */


/*
 * BPB structure
 * as defined by GEMDOS:
 */
struct bpb {
	WORD	recsiz,			/* physical sector size in bytes */
		clsiz,			/* cluster size in sectors */
		clsizb,			/* cluster size in bytes */
		rdlen,			/* root directory length in sectors */
		fsiz,			/* FAT size in sectors */
		fatrec,			/* sector# of 1st sector of 2nd FAT */
		datrec,			/* sector# of 1st data sector */
		numcl,			/* number of data clusters on disk */
		bflags;			/* various flags */
};


/*
 * Flags in bpb.bflags:
 */
#define	BPB_16BIT_FAT	0x0001		/* indicates 16-bit FAT entries */


/*
 * "Device State Block"
 * as defined by us.
 * The DSB is used by drivers to hold a device's state.
 * Most devices require a pointer to this beastie as a parameter
 * in their calls.
 */
struct dsb {
	/*
	 * Loaded (or computed from) the boot sector:
	 */
	struct bpb b;			/* JDOS' BPB */
	WORD	dntracks,		/* #tracks (cylinders) on dev */
		dnsides,		/* #sides per cylinder */
		dspc,			/* #sectors/cylinder */
		dspt,			/* #sectors/track */
		dhidden;		/* #hidden tracks */
	char	dserial[3];		/* 24-bit volume serial number */
	char	dmsd5_ser[4];		/* 32-bit serial # from MSDOS 5.0 */
} dsbtab[2];


#if USE_DISK_CHANGE
/* nothing here */
#else
/*
 * Variables maintained by floppy vblank monitor:
 */
extern char wpstatus[];		/* write-protect status */
extern char wplatch[];		/* write-protect status latch */
#endif

/*
 * Other floppy variables:
 */
extern long hz_200;		/* system timer tick, for rand() */
extern long frclock;		/* video frame counter, for mediach() */
extern char *dskbufp;		/* disk buffer somewhere in BSS */
extern int nflops;		/* number of active floppies {0,1,2} */
extern long acctim[];		/* time of last floppy access */
long maxacctim;			/* delay for floppy to turn UNSAFE */

char diskmode[2];		/* floppy mode {SAFE, UNSURE, CHANGED} */
int flopok[2];			/* 0: drive OK; -1: drive unusable */
int curflop;			/* current floppy# inserted */


/*
 * Floppy modes
 * (states for disk-change detection)
 */
#define	SAFE	0		/* media has definitely not changed */
#define	UNSURE	1		/* media might have changed (we don't know) */
#define	CHANGED	2		/* media has definitely changed */


/*
 * New media-change code.  Set CKSECTS to zero to disable this code. Eight
 * is a good number to avoid the risk that a weird format doesn't have nine
 * sectors per track.
 */

#define CKSECTS 6		/* check first 6 sectors -- dskbufp is 3K */

#if CKSECTS
WORD cksum[CKSECTS*2];		/* One word per sector per drive */
#endif

/*
 * dskinit - initialize floppy drives
 */
dskinit()
{
	LONG getbpb();
	extern LONG drvbits;

	WORD i, j;
	char *s, *d;

	maxacctim = MAXACCTIM;
	for (i = curflop = nflops = 0; i < 2; ++i)
	{
	    diskmode[i] = SAFE;
	    if ((flopok[i] = flopini(0L, 0L, i, 0, 0, 0)) == 0)
	    {
		++nflops;
		drvbits |= 3;
	    }
	}
}


/*
 * getbpb - return pointer to BPB
 * Reset disk mode to "SAFE"
 */
long getbpb(dev)
WORD dev;
{
    register struct dsb *q;
    register struct bpb *p;
    register int i, j;
    char *s, *d;
    LONG ret, floprd(), critic();
#if CKSECTS
    char *ckptr;
#endif

    if (dev >= 2)			/* only floppies here */
	return NULL;			/* can't do much ... */

    q = &dsbtab[dev];			/* pointer to DSB */
    p = &q->b;				/* pointer to BPB */


    /*
     * Read the boot sector.
     * Compute the DOS BPB from the MSDOS one.
     */
    do {

#if USE_DISK_CHANGE
	/*
	 * Clear possible disk changed signal.
	 * The return from clear_disk_change() could be ignored,
	 * since any drive error will show up on the next floprd()...
	 */
	ret = clear_disk_change(dev);
#if 0
	if (ret < 0) goto critical;
#endif
#endif

#if CKSECTS
	ret = floprd(dskbufp, 0L, dev, 1, 0, 0, CKSECTS);
#else
	ret = floprd(dskbufp, 0L, dev, 1, 0, 0, 1);
#endif

	if (ret < 0) {
critical:    ret = critic((WORD)ret, dev);
	}
    } while (ret == CRITICAL_RETRY);
    if (ret < 0) return NULL;


    /*
     * If recsiz or clsiz are <= 0 then
     * don't attempt to use the BPB:
     */
    if ((i = u2i(dskbufp + IBM_BPS)) <= 0 ||
	(j = low8bits(dskbufp[IBM_SPC])) <= 0)
	    return NULL;


    /*
     * Build the BPB from the MSDOS-format information:
     */
    p->recsiz = i;
    p->clsiz = j;
    p->fsiz = u2i(dskbufp + IBM_SPF);
    p->fatrec = p->fsiz + 1;
    p->clsizb = p->recsiz * p->clsiz;
    p->rdlen = (u2i(dskbufp + IBM_NDIRS) << 5) / p->recsiz;
    p->datrec = p->fatrec + p->rdlen + p->fsiz;
    p->numcl = (u2i(dskbufp + IBM_NSECTS) - p->datrec) / p->clsiz;
    p->bflags = 0;	/* Floppies always have 12-bit FATs */

    /* if the disk has only one FAT, set a flag in bflags saying so. */
    /* Newer GEMDOSes check this and only write the FAT once if set. */
    if (dskbufp[IBM_NFATS] < 2) p->bflags |= 2;

    q->dnsides = u2i(dskbufp + IBM_NSIDES);		/* "extra" info */
    q->dspt = u2i(dskbufp + IBM_SPT);
    q->dspc = q->dnsides * q->dspt;
    q->dhidden = u2i(dskbufp + IBM_NHID);
    q->dntracks = u2i(dskbufp + IBM_NSECTS) / q->dspc;

    for (i = 0; i < 3; ++i)				/* copy serial# */
	q->dserial[i] = dskbufp[VOL_SERIAL + i];
    for (i = 0; i < 4; ++i)
	q->dmsd5_ser[i] = dskbufp[MSDOS5_SER + i];


#if CKSECTS
    /* compute checksums */
    ckptr = dskbufp;
    for (i=0; i<CKSECTS; i++) {
	cksum[i] = checksum(ckptr,0x100);
	ckptr += 0x200;
    }
#endif
							/* make safe/unsure */
#if USE_DISK_CHANGE
    diskmode[dev] = SAFE;
#else
    diskmode[dev] = (wplatch[dev] = wpstatus[dev]) ? UNSURE : SAFE;
#endif

    return (long)q;					/* return BPB ptr */
}


/*
 * getdsb - return pointer to DSB
 */
LONG getdsb(dev)
WORD dev;
{
    return 0L;
}


#if USE_DISK_CHANGE
/*
 * In a disk_change system, there is only one physical drive, so select it
 * and read its state.  This procedure doesn't even take a drive-number
 * argument.
 *
 * This could mess with any other code that's using the floppy select lines
 * from the PSG, but if you're using those you shouldn't be calling Mediach().
 */

WORD
check_disk_change() {
    WORD ret;
    WORD oporta;

    oporta = setporta(0xfd);			/* drive 0 select */
    ret = ((*(char *)0xffff860f)&0x80);		/* get the bit */
    setporta(oporta);				/* restore values */
    return (ret == 0);
}

/*
 * Check for disk change, and if it's changed,
 * read Trk1/Sect1 to clear the signal.
 * Return any floprd() error.
 * Used by getbpb(), and chkmedia() if CKSECTS.
 */
WORD clear_disk_change(dev)
WORD dev;
{
    WORD ret = 0;
    if (check_disk_change())
	ret = floprd(dskbufp, 0L, dev, 1, 1, 0, 1);
    return ret;
}

#endif

/*
 * mediach - determine if media has changed
 * Return SAFE if the media definitely has not changed.
 * Return UNSURE if we're not sure if it's changed.
 * Return CHANGED if we're sure the media changed.
 *
 */
WORD mediach(dev)
WORD dev;
{
    register WORD dv;
    register char *dm;

    if (dev >= 2)			/* only floppies here */
	return UNKNOWN_DEVICE;

    dv = dev;
    dm = &diskmode[dv];

    if (*dm == CHANGED) return CHANGED;		/* always return if CHANGED */

#if USE_DISK_CHANGE
    /*
     * Remember, even if the disk_change line goes low, we want to return
     * UNSURE until the next read or getbpb; this is so a seek caused by
     * I/O in the "ignore mediach" mode doesn't make us forget it was unsure.
     */
    if (check_disk_change()) *dm = UNSURE;
    return *dm;
#else
    if (wplatch[dv]) *dm = UNSURE;		/* ==> UNSURE		*/
    if ((frclock - acctim[dv]) < maxacctim)	/* SAFE if within time limit */
	return SAFE;
    return *dm;					/* return UNSURE or SAFE */
#endif
}


/*
 * Determine if media is SAFE or CHANGED
 * (no wishy-washy stuff here);
 * this may involve a disk access.
 *
 */

#if CKSECTS
/*
 * This is the #if branch of the CKSECTS media-change code, where we
 * run a checksum on the first N sectors of the disk and compare them
 * with the checksums of the disk we got via Getbpb.  In floprw(), each
 * time one of the important sectors is written its checksum is updated.
 */

WORD chkmedia(dev)
WORD dev;
{
    register struct dsb *p;
    register char *ckptr;
    register char *ptr2;
    register int i;
    register LONG ret;
    WORD *ckval;
    WORD mediach();
    LONG floprw();

    p = &dsbtab[dev];
    i = mediach(dev);
    if (i == CHANGED) return i;
    else if (i == UNSURE) {
	/* read the first CKSECTS sectors and check serial # & cksum */
	do {

#if USE_DISK_CHANGE
	    /*
	     * Clear possible disk changed signal.
	     * The return from clear_disk_change() could be ignored,
	     * since any drive error will show up on the next floprd()...
	     */
	    ret = clear_disk_change(dev);
#if 0
	    if (ret < 0) goto critical;
#endif
#endif

	    ret = floprd(dskbufp,0L,dev,1,0,0,CKSECTS);
	    if (ret < 0) {
critical:	ret = critic((WORD)ret,dev);
	    }
	} while (ret == CRITICAL_RETRY);
	if (ret < 0) return ret;

	/* check old-style 3-byte serial number first */
	ckptr = &dskbufp[VOL_SERIAL];
	ptr2 = &p->dserial[0];
	if (*ckptr != *ptr2 ||
	    *(ckptr+1) != *(ptr2+1) ||
	    *(ckptr+2) != *(ptr2+2))
		return CHANGED;

	/* check 4-byte MSDOS serial number */
	ckptr = &dskbufp[MSDOS5_SER];
	ptr2 = &p->dmsd5_ser[0];
	if (*ckptr != *ptr2 ||
	    *(ckptr+1) != *(ptr2+1) ||
	    *(ckptr+2) != *(ptr2+2) ||
	    *(ckptr+3) != *(ptr2+3))
		return CHANGED;

	/* for each sector, perform a checksum & compare */
	ckptr = dskbufp;
	ckval = &cksum[dev ? CKSECTS : 0];
	for (i=0; i<CKSECTS; i++) {
	    if (checksum(ckptr,0x100) != ckval[i]) return CHANGED;
	    ckptr += 0x200;
	}

#if USE_DISK_CHANGE
	diskmode[dev] = SAFE;
#else
	/* reset the write-protect latch */
	if (!(wplatch[dev] = wpstatus[dev]))
	    diskmode[dev] = SAFE;
#endif

    }
    return SAFE;
}

#else
/*
 * This is the old media-change detection code, included #if !CKSECTS.  It
 * checks the three-byte serial number in the boot sector, along with the
 * 4-byte serial number introduced with MSDOS 5.0.
 */

WORD chkmedia(dev)
WORD dev;
{
    register int i;
    register WORD dv;
    register LONG ret;
    register struct dsb *p;
    WORD mediach();
    LONG floprw();

	dv = dev;
	p = &dsbtab[dv];

	/*
	 * Check for media change.
	 * If the media is UNSAFE, then read the boot sector to
	 * determine if the media really was changed.
	 * If the media was changed, return an error to the caller.
	 */
	i = mediach(dv);
	if (i == CHANGED) return i;
	else if (i == UNSURE)
	{
	    /*
	     * Read boot sector and compare volume's serial number with
	     * the one in the DSB.
	     */
	    do {
		ret = floprd(dskbufp, 0L, dv, 1, 0, 0, 1);
		if (ret < 0) ret = critic((WORD)ret, dv);
	    } while (ret == CRITICAL_RETRY);
	    if (ret < 0) return ret;

	    for (i = 0; i < 3; ++i)
		if (dskbufp[VOL_SERIAL + i] != p->dserial[i])
			return CHANGED;
	    for (i = 0; i < 4; ++i)
		if (dskbufp[MSDOS5_SER + i] != p->dmsd5_ser[i])
			return CHANGED;

#if USE_DISK_CHANGE
	    diskmode[dv] = SAFE;
#else
	    /* Reset write-protect latch */
	    if (!(wplatch[dv] = wpstatus[dv]))
		diskmode[dv] = SAFE;
#endif
	}

    return SAFE;
}
#endif

/*
 * rwabs - read multiple sectors from dev, into a buffer:
 *
 */
LONG rwabs(rw, buf, count, recno, dev)
WORD rw;
LONG buf;
WORD count, recno, dev;
{
    register WORD dv;
    register LONG ret;

    if ((dv = dev) >= 2)			/* only floppies here */
	return UNKNOWN_DEVICE;

    if (!nflops) return DRIVE_NOT_READY;	/* no disks attached anyway */


    /*
     *   If 'buf' is 0L, then set the media-change mode
     *   on the dev to whatever 'count' is.
     */
    if (!buf)
    {
	diskmode[dev] = count;
	return 0;
    }


    /*
     * If 'rw' allows media-change checking, then
     * make sure the disk in the drive is the one we
     * really want there.  If 'chkmedia' returns a
     * hard error, return that hard error.  If 'chkmedia'
     * discovers a media change, return that.
     */
    if (rw < 2 && (ret = (long)chkmedia(dv)) != 0)
    {
	if (ret == CHANGED) ret = MEDIA_CHANGE;
	return ret;
    }

    return floprw(rw, buf, recno, dv, count);	/* do operation */
}


/*
 * floprw - floppy read/write sectors
 */
LONG floprw(rw, buf, recno, dev, count)
WORD rw;
LONG buf;
WORD recno, dev, count;
{
    LONG critic(), flopver(), floprd(), flopwr();
    int u2i();
    extern WORD fverify;

    register struct dsb *p;
    register LONG ret;
    register WORD track, side, sect, cnt;
    WORD oddflag;
    LONG bf;
#if CKSECTS
    char *ckptr;
    register int i;
#endif

    p = &dsbtab[dev];
    oddflag = ((buf & 1) == 1);
    if (!p->dspc)				/* "cannot happen" */
	p->dspt = p->dspc = 9;

    /*
     * Read or write sectors.
     * Optimize for multi-sector transfers
     * (as much of a track as possible):
     */
    while (count)
    {
	bf = oddflag ? dskbufp : buf;		/* choose a buffer */
	track = recno / p->dspc;		/* compute track# */
	sect = recno % p->dspc;			/* compute sector# */
	if (sect < p->dspt)
	    side = 0;				/* single-sided media */
	else
	{					/* two-sided media */
	    side = 1;
	    sect -= p->dspt;
	} 
	if (oddflag) cnt = 1;			/* unaligned: read 1 sector */
	else if ((p->dspt - sect) < count)
	     cnt = p->dspt - sect;		/* rest of track */
	else cnt = count;			/* part of track */

	if (bf != buf) fastcpy(buf, bf);	/* copy buf to bf if nec. */

#if CKSECTS
	/* if you're writing to track 0 side 0 sector < CKSECTS, redo cksum */
	/* (note: sector numbers are still 0-based until ++sect below) */

	if ((rw & 1) && (!(track | side)) && (sect < CKSECTS)) {
	    ckptr = bf;
	    for (i=0; i<cnt; i++) {
		cksum[sect+i] = checksum(ckptr,0x100);
		ckptr += 0x200;
	    }
	}
#endif

	++sect;		/* make sect a 1-based physical sector number */

	do {
	    if (rw & 1)					/* write */
	    {
		ret = flopwr(bf, 0L, dev, sect, track, side, cnt);

		if (!ret && fverify)			/* verify */
		{
		    ret = flopver(dskbufp, 0L,
				  dev, sect, track, side, cnt);
		    if (!ret && u2i(dskbufp))
			ret = BAD_SECTORS;
		}
	    }
	    else					/* read */
	    {
		ret = floprd(bf, 0L, dev, sect, track, side, cnt);
		if (bf != buf) fastcpy(bf, buf);
	    }

	    /*
	     * On read/write error, send a "message" (boy, is this
	     * a fucking kludge) to someone who might handle it.
	     * On a retry, check for a possible media change.
	     */
	    if (ret < 0)
	    {
		ret = critic((WORD)ret, dev);
		if (rw < 2 &&
		    ret == CRITICAL_RETRY &&
		    chkmedia(dev) == CHANGED)
			ret = MEDIA_CHANGE;
	    }
	} while (ret == CRITICAL_RETRY);
	if (ret < 0) return ret;

	buf += ((long)cnt << 9);		/* advance DMA pointer */
	recno += cnt;				/* bump record number */
	count -= cnt;				/* decrement count */
    }

    return OK;					/* success! */
}


/*
 * Random number generator parameters.
 * (from Knuth, vol II)
 */
#define	RAND_A	3141592621L		/* multiplier */
#define	RAND_C	1			/* incrementer */

LONG seed;				/* seed (zeroed at powerup) */

/*
 * Return a 24-bit random number.
 * If the seed is zero (uninitialized)
 * then use the frame clock, slightly
 * munged, as a starting value.
 */
LONG rand()
{
    extern LONG hz_200;			/* raw 200-hz system timer counter */

    if (!seed) seed = hz_200 | (hz_200 << 16);
    seed = (RAND_A * seed + RAND_C);
    return (seed >> 8) & 0xffffff;
}


#define	BOOT_MAGIC	0x1234		/* magic boot-sector checksum */


/*
 * Error returns:
 */
#define	NO_DRIVE	1		/* no floppy attatched */
#define	COULDNT_LOAD	2		/* couldn't read boot sector */
#define	UNREADABLE	3		/* unreadable boot sector */
#define	NOT_VALID_BS	4		/* boot sector not executable */


/*
 * Boot from floppy.
 * Returns OK if dskbufp[] contains an executable
 * boot sector.
 *
 * Used to boot from floppy only if bootdev < 2... and never booted
 * from hard disk as advertised.  Now tries to find a boot sector
 * on floppy 0 regardless.
 */
boot()
{
    extern WORD _hinit();
/*    extern WORD bootdev; */
    extern LONG floprd();
    register WORD err;


    /*
     * Initialize disk system:
     */
    hinit();

    /*
     * Attempt to load boot sector from floppy "bootdev":
     */
    if (nflops)
    {
	if (!floprd(dskbufp, 0L, 0, 1, 0, 0, 1)) err = OK;
	else return COULDNT_LOAD;
    }
    else err = NO_DRIVE;

    if (err != OK) return err;

    /*
     * Successfully loaded boot sector from somewhere,
     * check it out:
     */
    return (checksum(dskbufp, 0x100) == BOOT_MAGIC) ? OK : NOT_VALID_BS;
}





/*
 * Prototype BPBs for floppies;
 * used to construct boot sectors.
 */
char proto_tab[] =
{		/* 40 tracks single sided */
	0x00,0x02,0x01,0x01,0x00,0x02,0x40,0x00,0x68,0x01,
	0xfc,0x02,0x00,0x09,0x00,0x01,0x00,0x00,0x00,

		/* 40 tracks double sided */
	0x00,0x02,0x02,0x01,0x00,0x02,0x70,0x00,0xd0,0x02,
	0xfd,0x02,0x00,0x09,0x00,0x02,0x00,0x00,0x00,

 /* AKP: these (below) had five sectors/fat -- changed to 3 */
 /* AKP: Changed back to 5 because of big bug in single-drive switch code */

		/* 80 tracks single sided */
 /*	bytes/sec sec/cl  res secs  NFATS N RD ents  N Sectors on media */
	0x00,0x02, 0x02, 0x01,0x00, 0x02, 0x70,0x00, 0xd0,0x02,
 /*      MD    sec/fat   sec/track  nsides      N hidden */
	0xf9, 0x05,0x00, 0x09,0x00, 0x01,0x00, 0x00,0x00,
 /* was 0xf8 -- AKP 2/88 */

		/* 80 tracks double sided */
 /*	bytes/sec sec/cl  res secs  NFATS N RD ents  N Sectors on media */
	0x00,0x02, 0x02, 0x01,0x00, 0x02, 0x70,0x00, 0xa0,0x05,
 /*      MD    sec/fat   sec/track  nsides      N hidden */
	0xf9, 0x05,0x00, 0x09,0x00, 0x02,0x00, 0x00,0x00,

 /* AKP: Added type 4: 80 tracks double sided 1.44MB (high density) */
 /*	bytes/sec sec/cl  res secs  NFATS N RD ents  N Sectors on media */
	0x00,0x02, 0x02, 0x01,0x00, 0x02, 0xe0,0x00, 0x40,0x0b,
 /*      MD    sec/fat   sec/track  nsides      N hidden */
	0xf0, 0x05,0x00, 0x12,0x00, 0x02,0x00, 0x00,0x00,
 /* MSDOS 5.0 uses f0 as the media descriptor.  The 3.3 docs read "other." */

 /* AKP: Added type 5: 80 tracks double sided 2.88MB (quad density) */
 /*	bytes/sec sec/cl  res secs  NFATS N RD ents  N Sectors on media */
	0x00,0x02, 0x02, 0x01,0x00, 0x02, 0xe0,0x00, 0x80,0x16,
 /*      MD    sec/fat   sec/track  nsides      N hidden */
	0xf0, 0x0a,0x00, 0x24,0x00, 0x02,0x00, 0x00,0x00
/* 10 sectors/fat means you can use this prototype for 40 sectors per track */

};

#define PROTOSIZ 19			/* 19 bytes per proto entry */
#define NUMPROTO 6			/* 6 entries in table */


/*
 * Prototype a boot sector.  (this is a strange function...)
 *
 * 'serial' is the disk's volume ID (or -1 not to initialize).
 * If serial > 0xffffff, it is replaced by a different, random serial number
 *
 * 'dsktyp' is the disk size (0, 1, 2, 3), or -1 not to initialize.
 *
 * If 'execflg' is 1, the boot sector is made executable (bootable);
 * If 'execflg' is 0, the boot sector is g'teed NOT to be executable;
 * If 'execflg' is -1, keep the boot sector the way it was passed
 * (it will stay executable or non-executable, no matter what other
 * changes were made to it).
 */
WORD proto_bt(buf, serial, dsksiz, execflg)
char *buf;
LONG serial;
WORD dsksiz, execflg;
{
    long rand();
    register int i, j;
    register char *s;
    WORD *p, w;


    /*
     * If execflg < 0, determine if boot sector is already executable.
     * Whatever the case, make sure the sector /stays/ the way it
     * came to us.
     */
    if (execflg < 0)
	execflg = (checksum(buf, 0x100) == BOOT_MAGIC);


    /*
     * Install volume ID
     */
    if (serial >= 0)
    {
	if (serial > 0x00ffffff)
	    serial = rand();
	for (i = 0; i < 3; ++i)
	{
	    buf[VOL_SERIAL + i] = serial & 0xff;
	    serial >>= 8;
	}
    }


    /*
     * Install BPB
     */
    if (dsksiz >= 0 && dsksiz < NUMPROTO)
    {
	j = dsksiz * PROTOSIZ;
	for (i = 0; i < PROTOSIZ; ++i)
	    buf[IBM_BPS + i] = proto_tab[j++];
    }


    /*
     * Make the sector executable or non-executable.
     */
    w = 0;
    for (p = buf; p < (WORD *)(buf + 0x1feL);)
	w += *p++;
    *p = BOOT_MAGIC - w;
    if (!execflg) ++(*p);
}


/*
 * Compute checksum of a number of 16-bit words.
 */
WORD checksum(xp, xcnt)
WORD *xp;
int xcnt;
{
    register WORD i;
    register WORD cnt;
    register WORD *p;

    cnt = xcnt;
    p = xp;

    for (i = 0; cnt--;)
	i += *p++;
    return i;
}



/*
 * Convert an 8086-flavored integer
 * to a 68000 integer.
 */
int u2i(loc)
char *loc;
{
    return (low8bits(*(loc+1)) << 8) | low8bits(*loc);
}
