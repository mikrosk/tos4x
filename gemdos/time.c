/*
***************************     TIME.C     ******************************
*
* $Revision: 2.6 $	$Source: e:/tos/gd2\RCS\time.c,v $
* =======================================================================
* $Author: apratt $ 	$Date: 1991/02/12 18:20:10 $    $Locker:  $
* =======================================================================
*
* $Log: time.c,v $
* Revision 2.6  1991/02/12  18:20:10  apratt
* *** empty log message ***
*
* Revision 2.5  1991/02/11  19:56:48  apratt
* Checkin lest I lose work (again)
*
* Revision 2.4  91/01/23  14:30:40  apratt
* Trimmed logs & comments, changed to compile under GCC or (new) Alcyon.
* 
*************************************************************************
*/

#include "fs.h"

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
uint t;
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
