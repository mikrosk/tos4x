/*
***************************    SETUP.C     ******************************
*
* $Revision: 2.3 $	$Source: /u2/MRS/osrevisions/gemdos/setup.c,v $
* =======================================================================
* $Author: apratt $ 	$Date: 90/08/03 13:42:43 $    $Locker:  $
* =======================================================================
*
* $Log: setup.c,v $
* Revision 2.3  90/08/03  13:42:43  apratt
* TTOS FINAL RELEASE
* 
* Revision 2.2  89/04/17  17:15:41  kbad
* YA header change
* 
* Revision 2.1  89/02/21  17:22:14  kbad
* *** TOS 1.4  FINAL RELEASE VERSION ***
* 
* Revision 1.3  88/12/01  16:34:09  apratt
* Added new code #ifdef VARBUFS, not defined for TOS 1.4.
* This code allows a variable number of GEMDOS sector buffers.
* If this code is enabled, NBUFS MUST BE AT LEAST FOUR.
* 
* Revision 1.2  88/06/13  15:06:55  apratt
* Header style change
* 
* Revision 1.1  88/04/26  14:48:29  apratt
* Version used 4/22/88 to make test ROMs
* 
*************************************************************************
*/

/************************************************************************
* HISTORY:								*
* 23-Dec-87: akp	Changed setup() to osi() to match the extern	*
*			that BIOS startup.s calls.			*
*									*
************************************************************************/

/*
 * Setup GEMDOS sector buffers.
 */
#include "fs.h"
#include "fsdecl.h"

#ifdef VARBUFS

/*
 * new code: makes number of sector buffers variable based on a #define.
 * One day we'll make this change, but for TOS 1.4 it's not worth it.
 */

#define NBUFS 4		/* MUST BE AT LEAST FOUR! See FSCL for why. */
char secbuf[NBUFS][512];			/* sector buffers */
BCB bcbx[NBUFS];				/* bcb for each buffer */

#else

/*
 * Sector buffers,
 * four seems to be about right (hard-coded in osi())
 * Extensible through base-BSS links.
 */
char secbuf[4][512];				/* sector buffers */
BCB bcbx[4];					/* bcb for each buffer */

#endif

extern BCB *bufl[2];

/*
 * Initialize GEMDOS
 */
osi()
{
#ifdef VARBUFS

	REG BCB *b, *e1, *e2;
	REG int i;

	/*
	 * Setup sector buffers (NBUFS of 'em)
	 */
	e1 = &bcbx[(NBUFS/2)-1];
	e2 = &bcbx[NBUFS-1];
	for (i=0, b = &bcbx[0]; i<NBUFS; i++, b++) {
	    if (b == e1 || b == e2) b->b_link = 0;
	    else b->b_link = b+1;
	    b->b_bufdrv = -1;
	    b->b_bufr = &secbuf[i];
	}

	/*
	 * Setup links in buffer-list
	 * First one caches FATs and root directories,
	 * second one caches subdirectory and data blocks.
 	 */
	bufl[0] = &bcbx[0];
	bufl[1] = e1+1;

#else

	/*
	 * Setup sector buffers (four of 'em)
	 */
	bcbx[0].b_link = &bcbx[1];
	bcbx[2].b_link = &bcbx[3];
	bcbx[0].b_bufdrv = -1;
	bcbx[1].b_bufdrv = -1;
	bcbx[2].b_bufdrv = -1;
	bcbx[3].b_bufdrv = -1;
	bcbx[0].b_bufr = &secbuf[0][0];
	bcbx[1].b_bufr = &secbuf[1][0];
	bcbx[2].b_bufr = &secbuf[2][0];
	bcbx[3].b_bufr = &secbuf[3][0];

	/*
	 * Setup links in buffer-list
	 * First one caches FATs and root directories,
	 * second one caches subdirectory and data blocks.
 	 */
	bufl[0] = &bcbx[0];
	bufl[1] = &bcbx[2];

#endif

	/*
	 * Initialize OS, login boot device:
	 */
	osinit();				/* initialize OS */
	xsetdrv(*(int *)0x446);			/* log in boot device */
}
