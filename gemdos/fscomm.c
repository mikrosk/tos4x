/*
***************************    FSCOMM.C    ******************************
*
* $Revision: 2.3 $	$Source: /u2/MRS/osrevisions/gemdos/fscomm.c,v $
* =======================================================================
* $Author: apratt $ 	$Date: 90/08/03 13:41:03 $    $Locker:  $
* =======================================================================
*
* $Log: fscomm.c,v $
* Revision 2.3  90/08/03  13:41:03  apratt
* TTOS FINAL RELEASE
* 
* Revision 2.2  89/04/17  17:14:11  kbad
* YA header change
* 
* Revision 2.1  89/02/21  17:19:07  kbad
* *** TOS 1.4  FINAL RELEASE VERSION ***
* 
* Revision 1.2  88/06/13  15:06:00  apratt
* Header style change
* 
* Revision 1.1  88/04/26  14:48:18  apratt
* Version used 4/22/88 to make test ROMs
* 
*************************************************************************
*/

/****************************************************************************\
* 									     *
* GEMDOS File System							     *
* Common Storage (FS)							     *
* (C)1986 Atari Corp.							     *
* 									     *
* ---- Edit history (reverse order, please): ------------------------------  *
* 									     *
* 31-Jan-1986 lmd	Broken out from FS.C				     *
* 									     *
\****************************************************************************/

#include "fs.h"


/*
 * Log values of 1, 2, 4, 8 ...
 */
int logmsk[] = {
	0,	1,	3,	7,
	15,	31,	63,	127,
	255,	511,	1023,	2047,
	4095,	8191,	16383,	32767
};

int drvsel;		/* mask of drives selected since power up */
long rwerr;		/* hard error number currently in progress */
int errdrv;		/* drive on which error occurred */
long negone = {-1L};	/* handy -1 */
unsigned int time;	/* current time word */
unsigned int date;	/* current date word */

/*
 * Special directory file names
 *		   "0123456789a"
 */
char dots[22] =  { ".          " } ;
char dots2[22] = { "..         " } ;

FTAB sft[OPNFILES];	/* system file table */
DND *dirtbl[NCURDIR];	/* current directory DND ptr */
char diruse[NCURDIR];	/* current directory reference count */
DMD *drvtbl[16];	/* -> drive media descriptor for dev */
