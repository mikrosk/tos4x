/*
***************************    PANIC.C     ******************************
*
* $Revision: 2.4 $	$Source: panic.c,v $
* =======================================================================
* $Author: apratt $ 	$Date: 91/01/23 14:30:24 $    $Locker:  $
* =======================================================================
*
* $Log: panic.c,v $
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
  for (p=s; *p; bconout(2,*s++)) /* do nothing */ ;
  for (;;) /* halt the system */ ;
}
