/*
***************************    FSCOMM.C    ******************************
*
* $Revision: 2.6 $	$Source: e:/tos/gd2\RCS\fscomm.c,v $
* =======================================================================
* $Author: apratt $ 	$Date: 1991/02/12 18:20:10 $    $Locker:  $
* =======================================================================
*
* $Log: fscomm.c,v $
* Revision 2.6  1991/02/12  18:20:10  apratt
* *** empty log message ***
*
* Revision 2.5  1991/02/11  19:56:48  apratt
* Checkin lest I lose work (again)
*
* Revision 2.4  91/01/23  14:30:00  apratt
* Trimmed logs & comments, changed to compile under GCC or (new) Alcyon.
* 
*************************************************************************
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
uint time;		/* current time word */
uint date;		/* current date word */
PD rootpd;
PD *run;
char callno;
DFD *dfd_head;
OFD *ofd_head;

FTAB sft[OPNFILES];	/* system file table */
DMD drvtbl[MAXDEVS];	/* drive media descriptor for each dev */

long errbuf[3];

uint drvsel;

char nday[] = 
	/*0 J  F  M  A  M  J  J  A  S  O  N  D  */
	{ 0,31,28,31,30,31,30,31,31,30,31,30,31 } ;

