/*
***************************    FSDECL.H    ******************************
*
* $Revision: 2.6 $	$Source: e:/tos/gd2\RCS\fsdecl.h,v $
* =======================================================================
* $Author: apratt $ 	$Date: 1991/02/11 19:56:48 $    $Locker:  $
* =======================================================================
*
* $Log: fsdecl.h,v $
* Revision 2.6  1991/02/11  19:56:48  apratt
* Checkin lest I lose work (again)
*
* Revision 2.5  91/01/23  14:29:58  apratt
* Trimmed logs & comments, changed to compile under GCC or (new) Alcyon.
*
*************************************************************************
*/

/*
 * declarations for fs*.c
 *
 */

extern uint logmsk[];

extern PD *run;

		/* AKP: callno++ once per OS call; sort of a timer */
extern char callno;
extern uint newcl;	/* AKP: set this TRUE at start of a cluster loop */
extern uint drvsel;	/* mask of drives selected since power up */
extern long rwerr;	/* hard error number currently in progress */
extern uint errdrv;	/* drive on which error occurred */

extern long negone;
extern unsigned int time;
extern unsigned int date;
extern BCB *bufl[];
extern long errbuf[3];
extern FTAB sft[];
extern char diruse[];
extern DMD drvtbl[16];

extern char diskbuf[];
extern MPB pmd;
extern char nday[];

extern PD rootpd;

DFD *dfd_head;
OFD *ofd_head;

extern long glbkbchar[3][KBBUFSZ];
extern char kbchar[3];
extern long *insptr[3];
extern long *remptr[3];
extern int glbcolumn[3];
