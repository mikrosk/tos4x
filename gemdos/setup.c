/*
***************************    SETUP.C     ******************************
*
* $Revision: 2.6 $	$Source: e:/tos/gd2\RCS\setup.c,v $
* =======================================================================
* $Author: apratt $ 	$Date: 1991/02/12 18:20:10 $    $Locker:  $
* =======================================================================
*
* $Log: setup.c,v $
* Revision 2.6  1991/02/12  18:20:10  apratt
* *** empty log message ***
*
* Revision 2.5  1991/02/11  19:56:48  apratt
* Checkin lest I lose work (again)
*
* Revision 2.4  91/01/23  14:30:36  apratt
* Trimmed logs & comments, changed to compile under GCC or (new) Alcyon.
* 
*************************************************************************
*/

/*
 * Setup GEMDOS sector buffers.
 */
#include "fs.h"

/*
 * new code: number of sector buffers variable based on a #define.
 * One day we'll make this change, but for TOS 1.4 it's not worth it.
 */

#define NBUFS 4		/* MUST BE AT LEAST FOUR! See FSCL for why. */
char secbuf[NBUFS][512];			/* sector buffers */
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

#if REAL
	/*
	 * Initialize OS, login boot device:
	 */

	otime = setexc(0x100,tikhnd);
	obdos = setexc(0x22,ntrap2);
	(void)setexc(0x21,enter);

#endif
	(void)xsetdrv(bootdev);		/* Dsetdrv(boot dev) */

	poolinit();
	xminit();
	handinit();

	run = &rootpd;

	/* clear the rootpd -- for compatibility with old ROMs which	*/
	/* got it from ospool (and therefore got it clear).		*/

	clear(run,run+1);

	callno = 0;

	/* init keyboard queues */
	kbchar[0] = kbchar[1] = kbchar[2] = 0;
	remptr[0] = insptr[0] = &(glbkbchar[0][0]);
	remptr[1] = insptr[1] = &(glbkbchar[1][0]);
	remptr[2] = insptr[2] = &(glbkbchar[2][0]);
}


