/*
******************* Revision Control System *****************************
*
* $Author: lozben $
* =======================================================================
*
* $Date: 87/11/20 14:24:18 $
* =======================================================================
*
* $Locker:  $
* =======================================================================
*
* $Log: prtblk.h,v $
* Revision 1.1  87/11/20  14:24:18  lozben
* Initial revision
*
* =======================================================================
*
* $Revision: 1.1 $
* =======================================================================
*
* $Source: d:/tos/bios\RCS\prtblk.h,v $
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
