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
* $Log: prtblk.h,v $
* Revision 2.4  1992/08/11  00:34:42  kbad
* TOS 4.00 Falcon030 first production version
*
* Revision 2.3  1991/01/02  19:07:12  unknown
* Checkin to shut up rcsdiff: no changes.
*
* Revision 2.2  90/08/03  13:23:31  apratt
* TTOS FINAL RELEASE
* 
* Revision 2.1  89/02/21  17:22:35  kbad
* *** TOS 1.4  FINAL RELEASE VERSION ***
* 
* Revision 1.1  87/11/20  14:24:18  lozben
* Initial revision
* 
* =======================================================================
*
* $Revision: 2.4 $
* =======================================================================
*
* $Source: d:/tos/bios\rcs\prtblk.h,v $
* =======================================================================
*
*************************************************************************
*/
/* ______
** prtblk header file
** atari corp  (26 March 1985)     asm
** revision 1  (27 May 1985)       lmd
** revision 2  (24 July 1985)      asm
**
** see PRTBLK(2) manual pages
*/

/*
** Prtblk argument structure.
*/

typedef struct                                    /* PRTARG prtblk arguments */
        {
           char *blkptr;                          /* block pointer */
           unsigned short offset;                 /* bit offset */
           unsigned short width;                  /* x dimension */
           unsigned short height;                 /* y dimension */
           unsigned short left;                   /* left leading x */
           unsigned short right;                  /* right trailing x */
           unsigned short srcres;                 /* source resolution */
           unsigned short dstres;                 /* destination resolution */
           unsigned short *colpal;                /* color palette pointer */
           unsigned short type;                   /* printer type */
           unsigned short port;                   /* printer port */
           char *masks;                           /* halftone masks pointer */
        } PRTARG;

/*
** Prtblk errors.
*/

# define       PBERR     (-1)                     /* prtblk return error */
