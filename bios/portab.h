/*
******************* Revision Control System *****************************
*
* $Author: kbad $
* =======================================================================
*
* $Date: 1992/08/11 00:34:42 $
* =======================================================================
*
* $Locker:  $
* =======================================================================
*
* $Log: portab.h,v $
* Revision 2.4  1992/08/11  00:34:42  kbad
* TOS 4.00 Falcon030 first production version
*
* Revision 2.3  1991/01/02  19:07:08  unknown
* Checkin to shut up rcsdiff: no changes.
*
* Revision 2.2  90/08/03  13:23:22  apratt
* TTOS FINAL RELEASE
* 
* Revision 2.1  89/02/21  17:22:11  kbad
* *** TOS 1.4  FINAL RELEASE VERSION ***
* 
* Revision 1.1  87/11/20  14:24:08  lozben
* Initial revision
* 
* =======================================================================
*
* $Revision: 2.4 $
* =======================================================================
*
* $Source: d:/tos/bios\rcs\portab.h,v $
* =======================================================================
*
*************************************************************************
*/
/************************************************************************/
/*	PORTAB.H	Pointless redefinitions of C syntax.		*/
/*		Copyright 1985 Atari Corp.				*/
/*									*/
/*	WARNING: Use of this file may make your code incompatible with	*/
/*		 C compilers throughout the civilized world.		*/
/************************************************************************/

#define mc68k 0

#define UCHARA 1				/* if char is unsigned     */
/*
 *	Standard type definitions
 */
#define	BYTE	char				/* Signed byte		   */
#define BOOLEAN	int				/* 2 valued (true/false)   */
#define	WORD	int  				/* Signed word (16 bits)   */
#define	UWORD	unsigned int			/* unsigned word	   */

#define	LONG	long				/* signed long (32 bits)   */
#define	ULONG	long				/* Unsigned long	   */

#define	REG	register			/* register variable	   */
#define	LOCAL	auto				/* Local var on 68000	   */
#define	EXTERN	extern				/* External variable	   */
#define	MLOCAL	static				/* Local to module	   */
#define	GLOBAL	/**/				/* Global variable	   */
#define	VOID	/**/				/* Void function return	   */
#define	DEFAULT	int				/* Default size		   */

#ifdef UCHARA
#define UBYTE	char				/* Unsigned byte 	   */
#else
#define	UBYTE	unsigned char			/* Unsigned byte	   */
#endif

/****************************************************************************/
/*	Miscellaneous Definitions:					    */
/****************************************************************************/
#define	FAILURE	(-1)			/*	Function failure return val */
#define SUCCESS	(0)			/*	Function success return val */
#define	YES	1			/*	"TRUE"			    */
#define	NO	0			/*	"FALSE"			    */
#define	FOREVER	for(;;)			/*	Infinite loop declaration   */
#define	NULL	0			/*	Null pointer value	    */
#define NULLPTR (char *) 0		/*				    */
#define	EOF	(-1)			/*	EOF Value		    */
#define	TRUE	(1)			/*	Function TRUE  value	    */
#define	FALSE	(0)			/*	Function FALSE value	    */
