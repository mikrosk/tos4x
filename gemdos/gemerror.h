/*
***************************   GEMERROR.H   ******************************
*
* $Revision: 2.7 $	$Source: e:/tos/gd2\RCS\gemerror.h,v $
* =======================================================================
* $Author: apratt $ 	$Date: 1991/03/28 17:47:08 $    $Locker:  $
* =======================================================================
*
* $Log: gemerror.h,v $
* Revision 2.7  1991/03/28  17:47:08  apratt
* THIS VERSION WORKS! DESKTOP OPS WORK!
*
* Revision 2.6  1991/02/15  18:45:40  apratt
* CI at the end of the week...
*
* Revision 2.5  1991/02/11  19:56:48  apratt
* Checkin lest I lose work (again)
*
* Revision 2.4  91/01/23  14:30:20  apratt
* Trimmed logs & comments, changed to compile under GCC or (new) Alcyon.
* 
* Revision 2.3  90/08/03  13:42:05  apratt
* TTOS FINAL RELEASE
* 
* Revision 2.2  89/04/17  17:14:57  kbad
* YA header change
* 
* Revision 2.1  89/02/21  17:21:06  kbad
* *** TOS 1.4  FINAL RELEASE VERSION ***
* 
* Revision 1.2  88/06/13  15:07:15  apratt
* Header style change
* 
* Revision 1.1  88/04/26  14:48:34  apratt
* Version used 4/22/88 to make test ROMs
* 
*
* =======================================================================
*
* $Revision: 2.7 $
* =======================================================================
*
* $Source: e:/tos/gd2\RCS\gemerror.h,v $
* =======================================================================
*
*************************************************************************
*/

/* standard error numbers for GEMDOS */

/* BIOS level errors */

#define	E_OK	  0L	/* OK, no error			*/
#define	ERROR	 -1L	/* basic, fundamental error	*/
#define	EDRVNR	 -2L	/* drive not ready		*/
#define	EUNCMD	 -3L	/* unknown command		*/
#define	E_CRC	 -4L	/* CRC error			*/
#define	EBADRQ	 -5L	/* bad request			*/
#define	E_SEEK	 -6L	/* seek error			*/
#define	EMEDIA	 -7L	/* unknown media		*/
#define	ESECNF	 -8L	/* sector not found		*/
#define	EPAPER	 -9L	/* no paper			*/
#define	EWRITF	-10L	/* write fault			*/
#define	EREADF	-11L	/* read fault			*/
#define	EGENRL	-12L	/* general error		*/
#define	EWRPRO	-13L	/* write protect		*/
#define	E_CHNG	-14L	/* media change			*/
#define	EUNDEV	-15L	/* unknown device		*/
#define	EBADSF	-16L	/* bad sectors on format	*/
#define	EOTHER	-17L	/* insert other disk		*/

/* BDOS level errors */

#define	EINVFN	-32L	/* invalid function number			 1 */
#define	EFILNF	-33L	/* file not found				 2 */
#define	EPTHNF	-34L	/* path not found				 3 */
#define	ENHNDL	-35L	/* too many open files (no handles left)	 4 */
#define	EACCDN	-36L	/* access denied				 5 */
#define	EIHNDL	-37L	/* invalid handle				 6 */

#define	ENSMEM	-39L	/* insufficient memory				 8 */
#define EIMBA	-40L	/* invalid memory block address			 9 */

#define	EDRIVE	-46L	/* invalid drive was specified			15 */
#define	ENSAME	-48L	/* not the same drive				   */
#define	ENMFIL	-49L	/* no more files				18 */

/* our own inventions */

#define	ERANGE	-64L	/* range error					*/
#define	EINTRN	-65L	/* internal error				*/
#define EPLFMT  -66L	/* invalid program load format			*/
#define EGSBF	-67L	/* setblock failure due to growth restrictions  */
