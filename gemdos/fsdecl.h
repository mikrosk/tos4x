/*
***************************    FSDECL.H    ******************************
*
* $Revision: 2.13 $	$Source: d:/tos/dos\rcs\fsdecl.h,v $
* =======================================================================
* $Author: kbad $ 	$Date: 1992/07/27 20:09:24 $    $Locker:  $
* =======================================================================
*
* $Log: fsdecl.h,v $
* Revision 2.13  1992/07/27  20:09:24  kbad
* Lattice compiled Sparrow GEMDOS
*
* Revision 2.12  1991/06/20  17:14:06  apratt
* changes for new newcl/Getfat code
*
* Revision 2.11  1991/03/28  17:47:08  apratt
* THIS VERSION WORKS! DESKTOP OPS WORK!
*
* Revision 2.10  1991/03/12  18:25:26  apratt
* Making gtest.prg works and lets you test functions in this version
*
* Revision 2.9  1991/02/22  15:29:28  apratt
* generic checkin
*
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

extern long _dblev;	/* (rwa) debugger level mask */

extern uint logmsk[];	/* (sup) */

extern PD *run;		/* (sup) */

extern uint drvsel;	/* (sup) mask of drives selected since power up */
extern long rwerr;	/* (sup) hard error number currently in progress */
extern uint errdrv;	/* (sup) drive on which error occurred */

/* BIOS uses these names */
#define realtime time
#define realdate date
extern uint realtime;	/* (sup) */
extern uint realdate;	/* (sup) */
extern BCB *bufl[];	/* BIOS */
extern uint bootdev;	/* BIOS */
extern char diruse[];	/* unused? */
extern DMD drvtbl[16];	/* (sup) */

extern char diskbuf[];	/* (sys\ld_dos) */
extern MPB pmd;		/* (mem) */
extern char nday[];	/* (sup) */

extern PD rootpd;	/* (sup) */
extern OFD *rootuft[];	/* (sup) */
extern PD *pdtab[];	/* (sup) */
extern char biosdev[];	/* (fshand) */

DFD *dfd_head;		/* (sup) */
OFD *ofd_head;		/* (sup) */

extern jmp_buf errbuf;	/* (sup) */
