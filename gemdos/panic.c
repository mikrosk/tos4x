/*
***************************    PANIC.C     ******************************
*
* $Revision: 2.7 $	$Source: e:/tos/gd2\rcs\panic.c,v $
* =======================================================================
* $Author: apratt $ 	$Date: 1991/02/15 18:45:40 $    $Locker:  $
* =======================================================================
*
* $Log: panic.c,v $
* Revision 2.7  1991/02/15  18:45:40  apratt
* CI at the end of the week...
*
* Revision 2.6  1991/02/12  18:20:10  apratt
* *** empty log message ***
*
* Revision 2.5  1991/02/11  19:56:48  apratt
* Checkin lest I lose work (again)
*
* Revision 2.4  91/01/23  14:30:24  apratt
* Trimmed logs & comments, changed to compile under GCC or (new) Alcyon.
* 
*************************************************************************
*/

#include "fs.h"

/*
 *  Print panic message and bring the system
 *  to a grinding halt.
 */

volatile void
panic()
{
  char *p;
  char *s = "\033H*** OUT OF INTERNAL MEMORY:\033K\r\n*** USE FOLDR100.PRG TO GET MORE.\033K\r\n\033K\n\033K\n*** SYSTEM HALTED ***\033K";
  for (p=s; *p; bconout(2,*p++)) /* do nothing */ ;
  for (;;) /* halt the system */ ;
}
