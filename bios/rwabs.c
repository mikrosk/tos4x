/*
******************* Revision Control System *****************************
*
* $Author: lozben $
* =======================================================================
*
* $Date: 87/11/20 14:24:34 $
* =======================================================================
*
* $Locker:  $
* =======================================================================
*
* $Log: rwabs.c,v $
* Revision 1.1  87/11/20  14:24:34  lozben
* Initial revision
*
* =======================================================================
*
* $Revision: 1.1 $
* =======================================================================
*
* $Source: /u2/MRS/osrevisions/bios/rwabs.c,v $
* =======================================================================
*
*************************************************************************
*/
#include "portab.h"
/* #define	DAS_BOOT 1
 */

/*
 * ST Disk support (and random BIOS functions)
 * (C)1985 Atari Corp.
 *
 *----
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
#define	MAXACCTIM	300L		/* 1.5seconds "free" time */

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
} dsbtab[2];


/*
 * Variables maintained by floppy vblank monitor:
 */
extern char wpstatus[];		/* write-protect status */
extern char wplatch[];		/* write-protect status latch */
extern WORD motoron;		/* motor-on status (for both drives) */


/*
 * Other floppy variables:
 */
unsigned extern long hz_200;	/* system timer tick */
extern char diskbuf[];		/* disk buffer somewhere in BSS */
extern int nflops;		/* number of active floppies {0,1,2} */
unsigned extern long acctim[];	/* time of last floppy access */
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
 * getdsb - return pointer to DSB
 */
LONG getdsb(dev)
WORD dev;
{
    return 0L;
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

    if (dev >= 2)			/* only floppies here */
	return NULL;			/* can't do much ... */

    q = &dsbtab[dev];			/* pointer to DSB */
    p = &q->b;				/* pointer to BPB */


    /*
     * Read the boot sector.
     * Compute the DOS BPB from the MSDOS one.
     */
    do {
	ret = floprd(diskbuf, 0L, dev, 1, 0, 0, 1);
	if (ret < 0) ret = critic((WORD)ret, dev);
    } while (ret == CRITICAL_RETRY);
    if (ret < 0) return NULL;


    /*
     * If recsiz or clsiz are <= 0 then
     * don't attempt to use the BPB:
     */
    if ((i = u2i(diskbuf + IBM_BPS)) <= 0 ||
	(j = low8bits(diskbuf[IBM_SPC])) <= 0)
	    return NULL;


    /*
     * Build the BPB from the MSDOS-format information:
     */
    p->recsiz = i;
    p->clsiz = j;
    p->fsiz = u2i(diskbuf + IBM_SPF);
    p->fatrec = p->fsiz + 1;
    p->clsizb = p->recsiz * p->clsiz;
    p->rdlen = (u2i(diskbuf + IBM_NDIRS) << 5) / p->recsiz;
    p->datrec = p->fatrec + p->rdlen + p->fsiz;
    p->numcl = (u2i(diskbuf + IBM_NSECTS) - p->datrec) / p->clsiz;

    q->dnsides = u2i(diskbuf + IBM_NSIDES);		/* "extra" info */
    q->dspt = u2i(diskbuf + IBM_SPT);
    q->dspc = q->dnsides * q->dspt;
    q->dhidden = u2i(diskbuf + IBM_NHID);
    q->dntracks = u2i(diskbuf + IBM_NSECTS) / q->dspc;

    for (i = 0; i < 3; ++i)				/* copy serial# */
	q->dserial[i] = diskbuf[VOL_SERIAL + i];

							/* make safe/unsure */
    diskmode[dev] = (wplatch[dev] = wpstatus[dev]) ? UNSURE : SAFE;

    return (long)q;					/* return BPB ptr */
}


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

    if (*dm == CHANGED) return CHANGED;		/* always hack CHANGED	*/
    if (wplatch[dv]) *dm = UNSURE;		/* ==> UNSURE		*/
    if ((hz_200 - acctim[dv]) < maxacctim)	/* SAFE if within time limit */
	return SAFE;
    return *dm;					/* return UNSURE or SAFE */
}


/*
 * Determine if media is SAFE or CHANGED
 * (no wishy-washy stuff here);
 * this may involve a disk access.
 *
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
		ret = floprd(diskbuf, 0L, dv, 1, 0, 0, 1);
		if (ret < 0) ret = critic((WORD)ret, dv);
	    } while (ret == CRITICAL_RETRY);
	    if (ret < 0) return ret;

	    for (i = 0; i < 3; ++i)
		if (diskbuf[VOL_SERIAL + i] != p->dserial[i])
			return CHANGED;

	    /* Reset write-protect latch */
	    if (!(wplatch[dv] = wpstatus[dv]))
		diskmode[dv] = SAFE;
	}

    return SAFE;
}


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
	bf = oddflag ? diskbuf : buf;		/* choose a buffer */
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

	++sect;					/* physical sector number */

	do {
	    if (rw & 1)					/* write */
	    {
		if (bf != buf) fastcpy(buf, bf);
		ret = flopwr(bf, 0L, dev, sect, track, side, cnt);

		if (!ret && fverify)			/* verify */
		{
		    ret = flopver(diskbuf, 0L,
				  dev, sect, track, side, cnt);
		    if (!ret && u2i(diskbuf))
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


#ifndef DAS_BOOT
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
#endif


#define	BOOT_MAGIC	0x1234		/* magic boot-sector checksum */


/*
 * Error returns:
 */
#define	NO_DRIVE	1		/* no floppy attatched */
#define	COULDNT_LOAD	2		/* couldn't read boot sector */
#define	UNREADABLE	3		/* unreadable boot sector */
#define	NOT_VALID_BS	4		/* boot sector not executable */


/*
 * Boot from floppy or hard disk.
 * Returns OK if diskbuf[] contains an executable
 * boot sector.
 */
boot()
{
    extern WORD _hinit();
    extern WORD bootdev;
    extern LONG floprd();
    register WORD err;


    /*
     * Initialize disk system:
     */
    hinit();

    /*
     * Attempt to load boot sector from floppy "bootdev":
     */
    err = nflops ? NO_DRIVE : COULDNT_LOAD;
    if (nflops && (bootdev < 2))
    {
	if (!floprd(diskbuf, 0L, bootdev, 1, 0, 0, 1))
	    err = OK;
	    else if (!wpstatus[0]) return UNREADABLE;
    }
    if (err != OK) return err;

    /*
     * Successfully loaded boot sector from somewhere,
     * check it out:
     */
    return (checksum(diskbuf, 0x100) == BOOT_MAGIC) ? OK : NOT_VALID_BS;
}





#ifndef DAS_BOOT
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

		/* 80 tracks single sided */
	0x00,0x02,0x02,0x01,0x00,0x02,0x70,0x00,0xd0,0x02,
	0xf8,0x05,0x00,0x09,0x00,0x01,0x00,0x00,0x00,

		/* 80 tracks double sided */
	0x00,0x02,0x02,0x01,0x00,0x02,0x70,0x00,0xa0,0x05,
	0xf9,0x05,0x00,0x09,0x00,0x02,0x00,0x00,0x00
};



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
    if (dsksiz >= 0)
    {
	j = dsksiz * 19;
	for (i = 0; i < 19; ++i)
	    buf[IBM_BPS + i] = proto_tab[j++];
    }


    /*
     * Make the sector executable or non-executable.
     */
    w = 0;
    for (p = buf; p < (buf + 0x1fe);)
	w += *p++;
    *p = BOOT_MAGIC - w;
    if (!execflg) ++(*p);
}
#endif


/*
 * Compute checksum of a number of 16-bit words.
 */
WORD checksum(p, cnt)
WORD *p;
int cnt;
{
    register WORD i;

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
