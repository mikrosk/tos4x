/*
***************************    PANIC.C     ******************************
*
* $Revision: 2.3 $	$Source: /u2/MRS/osrevisions/gemdos/panic.c,v $
* =======================================================================
* $Author: apratt $ 	$Date: 90/08/03 13:42:20 $    $Locker:  $
* =======================================================================
*
* $Log: panic.c,v $
* Revision 2.3  90/08/03  13:42:20  apratt
* TTOS FINAL RELEASE
* 
* Revision 2.2  89/04/17  17:15:15  kbad
* YA header change
* 
* Revision 2.1  89/02/21  17:21:31  kbad
* *** TOS 1.4  FINAL RELEASE VERSION ***
* 
* Revision 1.3  88/08/04  16:09:54  apratt
* Broke panic message string across many lines so it is easier
* to print.  No code change.
* 
* Revision 1.2  88/06/13  15:06:45  apratt
* Header style change
* 
* Revision 1.1  88/04/26  14:48:27  apratt
* Version used 4/22/88 to make test ROMs
* 
*************************************************************************
*/

#include "fs.h"
#include "gemerror.h"
#include "fsdecl.h"

/*
 *  Print panic message and bring the system
 *  to a grinding halt.
 */

panic()
{
  panic1("\033H*** OUT OF INTERNAL MEMORY:\033K\r\n\
*** USE FOLDR100.PRG TO GET MORE.\033K\r\n\033K\n\033K\n\
*** SYSTEM HALTED ***\033K");
  for (;;) ;
}

panic1(s)
char *s;
{
  while (*s)
    {
      bconout(2, *s);
      ++s;
    }
}
