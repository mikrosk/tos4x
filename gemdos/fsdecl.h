/*
***************************    FSDECL.H    ******************************
*
* $Revision: 2.5 $	$Source: fsdecl.h,v $
* =======================================================================
* $Author: apratt $ 	$Date: 91/01/23 14:29:58 $    $Locker:  $
* =======================================================================
*
* $Log: fsdecl.h,v $
* Revision 2.5  91/01/23  14:29:58  apratt
* Trimmed logs & comments, changed to compile under GCC or (new) Alcyon.
*
* Revision 2.4  90/08/03  13:41:06  apratt
* TTOS FINAL RELEASE
* 
* Revision 2.3  90/04/24  10:59:58  apratt
* Added xfmalloc, xmalloc, xsetblk.
* 
* Revision 2.2  89/04/17  17:14:14  kbad
* YA header change
* 
* Revision 2.1  89/02/21  17:19:11  kbad
* *** TOS 1.4  FINAL RELEASE VERSION ***
* 
* Revision 1.4  88/08/08  18:22:33  apratt
* Reinstated declaration of ixwrite as returning a long.
* 
* Revision 1.3  88/06/13  15:07:12  apratt
* Header style change
* 
* Revision 1.2  88/04/28  18:17:37  apratt
* Removed declaration of divmod (it's now a macro)
* 
* Revision 1.1  88/04/26  14:48:33  apratt
* Version used 4/22/88 to make test ROMs
*
*************************************************************************
*/

/*
 * declarations for fs*.c
 *
 */

extern PD *run;

		/* AKP: callno++ once per OS call; sort of a timer */
extern char callno;
extern int newcl;	/* AKP: set this TRUE at start of a cluster loop */
extern int drvsel;	/* mask of drives selected since power up */
extern long rwerr;	/* hard error number currently in progress */
extern int errdrv;	/* drive on which error occurred */
extern char biosdev[];	/* AKP: neg of std BIOS device # for handles 0-6 */
			/* declared in sup.c */

extern int logmsk[];
extern long negone;
extern char dots[];
extern char dots2[];
extern unsigned int time;
extern unsigned int date;
extern BCB *bufl[];
extern long errbuf[3];
extern FTAB sft[];
extern DND *dirtbl[];
extern char diruse[];
extern DMD *drvtbl[16];

extern char diskbuf[];
extern MPB pmd;
extern char nday[];

extern long glbkbchar[3][KBBUFSZ];
extern char kbchar[3];
extern long *insptr[3];
extern long *remptr[3];
extern int glbcolumn[3];
