/*
***************************     SUP.C      ******************************
*
* $Revision: 2.13 $	$Source: e:/tos/gd2\RCS\sup.c,v $
* =======================================================================
* $Author: apratt $ 	$Date: 1991/04/30 12:12:38 $    $Locker:  $
* =======================================================================
*
* $Log: sup.c,v $
* Revision 2.13  1991/04/30  12:12:38  apratt
* Folded setup.c into this file.  Setup.c is no more.
*
* Revision 2.12  1991/03/28  17:47:08  apratt
* THIS VERSION WORKS! DESKTOP OPS WORK!
*
* Revision 2.11  1991/03/12  18:25:26  apratt
* Making gtest.prg works and lets you test functions in this version
*
* Revision 2.10  1991/02/15  18:45:40  apratt
* CI at the end of the week...
*
* Revision 2.9  1991/02/11  19:56:48  apratt
* Checkin lest I lose work (again)
*
* Revision 2.8  91/01/23  17:08:56  apratt
* Changed d_left to d_child, d_right to d_next globally.  Removed o_thread,
* d_scan, m_fatofd, m_ofl, and d_dirfil.
* 
* Revision 2.7  91/01/23  14:30:36  apratt
* Trimmed logs & comments, changed to compile under GCC or (new) Alcyon.
* 
*************************************************************************
*/

/*
 * This file consists primarily of the code that gets control from the trap
 * handler, and the media-change and other error handlers.  The dispatcher
 * just dispatches the call, retries on media change, and returns on other
 * disk errors.
 *
 * I also put the stuff that used to be in common.c here; it's just
 * declarations of global things.
 */

#include "fs.h"

/*
 * mask for getting remainder of powers of two
 */

uint logmsk[] = {
	0,	1,	3,	7,	15,	31,	63,	127,
	255,	511,	1023,	2047,	4095,	8191,	16383,	32767, 65535
};

long rwerr;		/* hard error number currently in progress */
uint errdrv;		/* drive on which error occurred */
uint realtime;		/* current time word */
uint realdate;		/* current date word */
PD rootpd;
OFD *rootuft[OPNFILES];
PD *pdtab[NUMPDS];
PD *run;
DFD *dfd_head;
OFD *ofd_head;

DMD drvtbl[MAXDEVS];	/* drive media descriptor for each dev */

jmp_buf errbuf;

uint drvsel;

char nday[] = 
	/*0 J  F  M  A  M  J  J  A  S  O  N  D  */
	{ 0,31,28,31,30,31,30,31,31,30,31,30,31 } ;

/****************************************************************************/

static long
endmediach(drv,rc)
int drv;
long rc;
{
    /* clear bit to force ckdrv to check the drive */
    drvsel &= ~(1 << drv);
    if (ckdrv(drv)) return rc;
    else return E_OK;
}

static long
domediach(dev,rc)
int dev;
long rc;
{
	int i;
	BCB *bx;
	PD *pd, **ppd;

	/*
	 * Deallocate structures associated with the drive we just had a
	 * media-change on:
	 *	free up open files;
	 *	free up FAT ofd;
	 *	free up current-directory slots;
	 *	free up DMD;
	 */
	offree(dev);

	for (pd = *(ppd = &pdtab[0]); ppd < &pdtab[NUMPDS]; pd = *(++ppd)) {
	    if (pd) pd->p_curdir[dev] = 0;	/* set CWD=root */
        }

	/*
	 * Invalidate buffers filled with stuff from that drive:
	 */
	for (i = 0; i < 2; i++)
	    for (bx = bufl[i]; bx; bx = bx->b_link)
		if (bx->b_bufdrv == dev)
		    bx->b_bufdrv = -1;

	/* then, in with the new */
	return endmediach(dev,rc);
}

/*
 * NEW FUNCTION 2/88, number 0x50:
 * "CAUSE MEDIA CHANGE" on a logical device.
 *
 * long Causemc(devno)
 * int devno;
 *
 * This function causes GEMDOS to forget everything it knew about
 * the logical device "devno" (where 0=A, 1=B, ...).  All open files
 * are closed, all buffers are invalidated (NOT written to the disk),
 * and an attempt is made to log the drive in again (i.e. read its BPB).
 *
 * The intended use is for programs which fool with the directory structure
 * of a logical device without calling GEMDOS, such as a disk compaction
 * program.  After modifying the disk, it can call Causemc to make
 * GEMDOS forget all its cached information about the device and re-read
 * the FAT and directory structure.
 *
 * RETURNS
 *	0 for success, or if the drive was unknown to begin with
 *		(and therefore there's nothing to forget).
 *
 *	ENSMEM (-39) or ERROR (-1) if the new media can't be logged in.
 *	EDRIVE (-46) if drv is not in the range 0-15.
 *
 */

long
xmediach(drv)
int drv;
{
	if (drv >= MAXDEVS) return EDRIVE;
	/* if the drive exists in the first place... */
	if (drvsel & (1 << drv)) {
		return domediach(drv,ERROR);	/* cause media change */
	}
	else {
		return endmediach(drv,ERROR);
	}
}

static long (*funcs[])() = {
	/* 0x00 */
	&x0term,	&xconin,	&xconout,	&xauxin,
	&xauxout,	&xprtout,	&xrawio,	&xrawcin,
	&xnecin,	&xconws,	&xconrs,	&xconstat,
	&ni,		&ni,		&xsetdrv, 	&ni,

	/* 0x10 */
	&xconos,	&xprnos,	&xauxis,	&xauxos,
	&xaddalt,	&ni,		&ni, 		&ni,
	&ni,		&xgetdrv,	&xsetdta, 	&ni,
	&ni,		&ni,		&ni,		&ni,

	/* 0x20 */
	&ni,		&ni,		&ni,		&ni,
	&ni,		&ni,		&ni,		&ni,
	&ni,		&ni,		&xgetdate,	&xsetdate,
	&xgettime,	&xsettime,	&ni,		&xgetdta,

	/* 0x30 */
	&xgetver,	&xtermres,	&ni,		&ni,
	&ni,		&ni,		&xgetfree,	&ni,
	&ni,		&xmkdir,	&xrmdir,	&xchdir,
	&xcreat,	&xopen,		&xclose,	&xread,

	/* 0x40 */
	&xwrite,	&xunlink,	&xlseek,	&xchmod,
 	&xfmalloc,	&xdup,		&xforce,	&xgetdir,
	&xmalloc,	&xmfree,	&xmshrink,	&xexec,
	&xterm,		&ni,		&xsfirst,	&xsnext,

	/* 0x50 */
	&xmediach,	&ni,		&ni,		&ni,
	&ni,		&ni,		&xrename,	&xdatime,
};

/*
 * Trap Interface;
 * called from assembly-language trap handler.
 *
 * This is NOT varargs - pw is really a pointer to the arg stack.
 */
long
osif(pw)
int *pw;
{
    uint fn;
    long rc;
    BCB *bx;
    uint i;

restrt:
    *(&fn) = *(&pw[0]);	/* take addr so these are not put in regs */

    if (fn >= (sizeof funcs / sizeof (long (*)())))
	return(EINVFN);

    if (rc = setjmp(errbuf)) {
	/* hard error processing */
	/* is this a media change ? */
	if (rc == E_CHNG) {
	    if (rc = domediach(errdrv,rc)) return rc;
	    rwerr = 0;
	    errdrv = 0;
	    goto restrt;
	}

	/* else handle as hard error on disk for now		*/
	/* Invalidate all buffers for that device! What the	*/
	/* hell kind of error recovery is that?! (AKP)		*/

	/* This is actually not as bad as it sounds, but it is	*/
	/* pretty bad... */

	for (i = 0; i < 2; i++)
	    for (bx = bufl[i]; bx; bx = bx->b_link)
		if (bx->b_bufdrv == errdrv)
		    bx->b_bufdrv = -1;
	return rc;
    }

    /* end of setjmp/longjmp handling */

    /* this copies the max number of args from the arg stack -- bad news */
    /* if the arg stack abuts the end of real memory! */

    return (funcs[pw[0]])(pw[1],pw[2],pw[3],pw[4],pw[5],pw[6],pw[7]);
}

/*
 * Code to initialize GEMDOS; called from rwa.s
 */

#define NBUFS 4		/* MUST BE AT LEAST FOUR! See FSCL for why. */
#define DEFBUFSIZ 8192	/* outrageously large sectors by default */
char secbuf[NBUFS][DEFBUFSIZ];			/* sector buffers */
BCB bcbx[NBUFS];				/* bcb for each buffer */

extern void tikhnd(), (*otime)(), ntrap2(), (*obdos)(), enter();

/*
 * Initialize GEMDOS
 */
voidfn
osi()
{
	BCB *b, *e1, *e2;
	int i;
	ulong datime;

	datime = gettime();
	realdate = (datime >> 16);
	realtime = (datime & 0xffff);

	/*
	 * Setup sector buffers (NBUFS of 'em)
	 */
	e1 = &bcbx[(NBUFS/2)-1];
	e2 = &bcbx[NBUFS-1];
	for (i=0, b = &bcbx[0]; i<NBUFS; i++, b++) {
	    if (b == e1 || b == e2) b->b_link = 0;
	    else b->b_link = b+1;
	    b->b_bufdrv = B_INVALID;
	    b->b_bufr = &secbuf[i][0];
	}

	/*
	 * Setup links in buffer-list
	 * First one caches FATs and root directories,
	 * second one caches subdirectory and data blocks.
 	 */
	bufl[0] = &bcbx[0];
	bufl[1] = e1+1;

	/*
	 * Initialize OS, login boot device:
	 */

#if !UNREAL
	otime = setexc(0x100,-1);
	(void)setexc(0x100,tikhnd);

	obdos = setexc(0x22,ntrap2);
	(void)setexc(0x21,enter);
#endif

	/* set rootpd and fill it with important stuff */
	run = &rootpd;
	clear(run,run+1);
	run->p_xdta = (DTA *)run->p_cmdlin; /* default DTA is your cmd line */
	run->p_uft = rootuft;
	run->p_uftsize = OPNFILES;
	clear(&run->p_uft[0],&run->p_uft[run->p_uftsize]);
	for (i=0; i<NUMSTD; i++) run->p_uft[i] = ofdtty(biosdev[i]);

	run->p_hflags = 7;

	/* clear the PD table, then add rootpd to it */
	clear(&pdtab[0],&pdtab[NUMPDS]);
	pdtab[0] = run;

	(void)xsetdrv(bootdev);		/* Dsetdrv(boot dev) */

	poolinit();
	xminit();
	coninit();
}


