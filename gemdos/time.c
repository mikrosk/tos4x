/*
***************************     TIME.C     ******************************
*
* $Revision: 2.3 $	$Source: /u2/MRS/osrevisions/gemdos/time.c,v $
* =======================================================================
* $Author: apratt $ 	$Date: 90/08/03 13:42:56 $    $Locker:  $
* =======================================================================
*
* $Log: time.c,v $
* Revision 2.3  90/08/03  13:42:56  apratt
* TTOS FINAL RELEASE
* 
* Revision 2.2  89/04/17  17:15:56  kbad
* YA header change
* 
* Revision 2.1  89/02/21  17:22:49  kbad
* *** TOS 1.4  FINAL RELEASE VERSION ***
* 
* Revision 1.2  88/06/13  15:07:05  apratt
* Header style change
* 
* Revision 1.1  88/04/26  14:48:31  apratt
* Version used 4/22/88 to make test ROMs
* 
*************************************************************************
*/

/****************************************************************************\
* 									     *
* GEMDOS Time and Date Functions					     *
* (C)1986 Atari Corp.							     *
* 									     *
* ---- Edit history (reverse order, please): ------------------------------  *
* 									     *
* 03-Feb-1988 akp	Changed some register declarations.		     *
* 03-Dec-1987 akp	Added calls to 'upd_tod()' to update the BIOS's	     *
*			clocks when Tsettime() / Tgettime() are called.	     *
* 17-Jan-1986 lmd	Commented and prettified from Digital Research	     *
* 			source code.					     *
* 									     *
\****************************************************************************/
#include "fs.h"
#include "gemerror.h"

extern unsigned int time, date;		/* declared in fs.c */
extern int nday[];			/* declared in sup.c */


/*
 * Get Date.
 */
long
xgetdate()
{
	return(date);
}


/*
 * Set Date.
 */
long
xsetdate(d)
int d;
{
REG	int curmo;
REG	int day;

	curmo = ((d >> 5) & 0x0F);
	day = d & 0x001F;

	if ((d >> 9) > 119)		/* Warranty expires 12/31/2099 */
		return(ERROR);

	if (curmo > 12)			/* 12 months a year */
		return (ERROR);

	if ((curmo == 2) && !(d & 0x0600))	/* Feb && Leap */
	{
		if (day > 29)
			return(ERROR);
	}
	else if (day > nday[curmo])
		return (ERROR);

	date = d;			/* ok, assign that value to date */
	upd_tod();			/* update BIOS clock */
	return (E_OK);
}


/*
 * Get Time.
 */
long
xgettime()
{
	return(time);
}


/*
 * Set Time.
 */
long
xsettime(t)
int t;
{
	if ((t & 0x001F) >= 30)
		return(ERROR);

	if ((t & 0x07e0) >= (60 << 5))	/* 60 max minutes per hour */
	    return (ERROR);

	/* max of 24 hours in a day */
	/* UNSIGNED below is for stupid old Alcyon compiler */
	if ((unsigned)(t & 0xf800) >= (unsigned)(24 << 11))
	    return (ERROR);

	time = t;
	upd_tod();			/* update BIOS clock */
	return (E_OK);
}
