/*
***************************    FSCOMM.C    ******************************
*
* $Revision: 2.4 $	$Source: fscomm.c,v $
* =======================================================================
* $Author: apratt $ 	$Date: 91/01/23 14:30:00 $    $Locker:  $
* =======================================================================
*
* $Log: fscomm.c,v $
* Revision 2.4  91/01/23  14:30:00  apratt
* Trimmed logs & comments, changed to compile under GCC or (new) Alcyon.
*
*************************************************************************
*/

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
