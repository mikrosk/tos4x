/*
***************************     TIME.C     ******************************
*
* $Revision: 2.10 $	$Source: d:/tos/dos\rcs\time.c,v $
* =======================================================================
* $Author: kbad $ 	$date: 1991/02/15 18:45:40 $    $Locker:  $
* =======================================================================
*
* $Log: time.c,v $
* Revision 2.10  1992/08/11  00:37:02  kbad
* TOS 4.00 Falcon030 first production version
*
* Revision 2.9  1991/03/28  17:39:36  apratt
* THIS VERSION BOOTS! DESKTOP OPERATIONS WORK!
*
* Revision 2.8  1991/03/12  18:25:26  apratt
* Making gtest.prg works and lets you test functions in this version
*
* Revision 2.7  1991/02/15  18:45:40  apratt
* CI at the end of the week...
*
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
 * Tick Handler;
 * called every so often by the BIOS's
 * timer interrupt handler.
 */

int msec;

void
tikfrk(n)
int n;
{
	int curmo;

	msec += n;
	if (msec >= 2000)
	{
		/* update time */

		msec -= 2000;
		realtime++;

		if ((realtime & 0x1F) != 30)
			return;

		realtime &= 0xFFE0;
		realtime += 0x0020;

		if ((realtime & 0x7E0) != (60 << 5))
			return;

		realtime &= 0xF81F;
		realtime += 0x0800;

		/* UNSIGNED below is for stupid old Alcyon compiler */
		if ((unsigned)(realtime & 0xF800) != (unsigned)(24 << 11))
			return;

		realtime = 0;

		/* update date */

		if ((realdate & 0x001F) == 31)
			goto datok;

		realdate++;			/* bump day */

		if ((realdate & 0x001F) <= 28)
			return;

		if ((curmo = (realdate >> 5) & 0x0F) == 2)
		{
		/* 2100 is the next non-leap year divisible by 4, so OK */
			if (!(realdate & 0x0600))
				if ((realdate & 0x001F) <= 29)
					return;
				else
					goto datok;
		}

		if ((realdate & 0x001F) <= nday[curmo])
			return;

datok:		realdate &= 0xFFE0;		/* bump month */
		realdate += 0x0021;

		if ((realdate & 0x01E0) <= (12 << 5))
			return;

		realdate &= 0xFE00;		/* bump year */
		realdate += 0x0221;
	}
}

/*
 * Get date.
 */
long
xgetdate()
{
	return realdate;
}


/*
 * Set date.
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

	realdate = d;			/* ok, assign that value to date */
	upd_tod();			/* update BIOS clock */
	return (E_OK);
}


/*
 * Get Time.
 */
long
xgettime()
{
	return realtime;
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

	realtime = t;
	upd_tod();			/* update BIOS clock */
	return (E_OK);
}


