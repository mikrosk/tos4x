/*
***************************    FSDECL.H    ******************************
*
* $Revision: 2.8 $	$Source: e:/tos/gd2\rcs\fsdecl.h,v $
* =======================================================================
* $Author: apratt $ 	$Date: 1991/02/15 18:45:40 $    $Locker:  $
* =======================================================================
*
* $Log: fsdecl.h,v $
* Revision 2.8  1991/02/15  18:45:40  apratt
* CI at the end of the week...
*
* Revision 2.7  1991/02/12  18:20:10  apratt
* *** empty log message ***
*
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

extern uint realtime;
extern uint realdate;
extern BCB *bufl[];
extern uint bootdev;
extern long errbuf[3];
extern char diruse[];
extern DMD drvtbl[16];

extern char diskbuf[];
extern MPB pmd;
extern char nday[];

extern PD rootpd;
extern OFD *rootuft[];
extern PD *pdtab[];
extern char biosdev[];

DFD *dfd_head;
OFD *ofd_head;

