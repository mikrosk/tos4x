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
* $Log: prtblkc.h,v $
* Revision 2.4  1992/08/11  00:34:42  kbad
* TOS 4.00 Falcon030 first production version
*
* Revision 2.3  1991/01/02  19:07:16  unknown
* Checkin to shut up rcsdiff: no changes.
*
* Revision 2.2  90/08/03  13:23:33  apratt
* TTOS FINAL RELEASE
* 
* Revision 2.1  89/02/21  17:22:39  kbad
* *** TOS 1.4  FINAL RELEASE VERSION ***
* 
* Revision 1.1  87/11/20  14:24:23  lozben
* Initial revision
* 
* =======================================================================
*
* $Revision: 2.4 $
* =======================================================================
*
* $Source: d:/tos/bios\rcs\prtblkc.h,v $
* =======================================================================
*
*************************************************************************
*/
/* ______
** prtblk C source header file
** atari corp  (26 March 1985)     asm
** revision 1  (27 May 1985)       lmd
** revision 2  (24 July 1985)      asm
**
** see prtblk.c
*/

# include      "prtblk.h"

/*
** Prtblk print parameter values.
*/

# define       MAXOFF    (7)                      /* maximum value of offset */

# define       LOWID     (320)                    /* low clip width */
# define       HIWID     (640)                    /* medium/high clip width */

# define       LOW       (0)                      /* low srcres */
# define       MEDIUM    (1)                      /* medium srcres */
# define       HIGH      (2)                      /* high srcres */
# define       MAXSRC    (2)                      /* maximum value of srcres */

# define       DRAFT     (0)                      /* draft dstres */
# define       FINAL     (1)                      /* final dstres */
# define       MAXDST    (1)                      /* maximum value of dstres */

# define       ATMDM     (0)                      /* Atari mono dot matrix */
# define       ATCDM     (1)                      /* Atari color dot matrix */
# define       ATMDW     (2)                      /* Atari mono daisy wheel */
# define       EPMDM     (3)                      /* Epson mono dot matrix */
# define       MAXTYP    (3)                      /* maximum value of type */

# define       PRNTR     (0)                      /* parallel printer port */
# define       MODEM     (1)                      /* serial modem port */
# define       MAXPOR    (1)                      /* maximum value of port */

/*
** Prtblk control character and escape sequence strings.
*/

# define       ABMMO     "\033\131\377"           /* Atari BitMap mode */
# define       EBMMO     "\033\114\377"           /* Epson BitMap mode */

# define       YELLO     "\033\130\006\377"       /* set yellow */
# define       MAGTA     "\033\130\005\377"       /* set magenta */
# define       CYAN      "\033\130\003\377"       /* set cyan */

# define       PIXLS     "\033\063\001\377"       /* pixel line spacing */
# define       RASLS     "\033\061\377"           /* raster line spacing */

# define       RSTLS     "\033\062\377"           /* reset line spacing */
# define       RSTCO     "\033\130\000\377"       /* reset color */

# define       CR        '\015'                   /* carriage return */
# define       LF        '\012'                   /* line feed */

/*
** Prtblk get word bit and byte bit macro functions.
*/

# define       WRDBIT(wrd,bit)  ((wrd>>(15-bit))&0x0001)
# define       BYTBIT(byt,bit)  ((byt>>(7-bit))&0x0001)

/*
** Prtblk miscellaneous macros.
*/

# define       NOABRT    (1)                      /* prtcnt no abort value */

# define       RETERR  {prtcnt=(-1);return(-1);}  /* return prtblk error */

# define       FALSE     (0)                      /* boolean false */
# define       TRUE      (1)                      /* boolean true */

/*
** Prtblk boolean globals for print parameters.
*/

char LO;                                          /* low srcres */
char ME;                                          /* medium srcres */
char HI;                                          /* high srcres */

char DR;                                          /* draft dstres */

char CD;                                          /* Atari color dot matrix */
char DW;                                          /* Atari mono daisy wheel */
char ED;                                          /* Epson mono dot matrix */

char PR;                                          /* parallel printer port */

char TW;                                          /* truncate trailing white */
char WS;                                          /* white space flag */

char EP;                                          /* Epson pad byte flag */
char CP;                                          /* clear pixel block flag */
char LS;                                          /* raster line space flag */

/*
** Prtblk color translation globals.
*/

short duppal;                                     /* duplicate colpal entry */
short red;                                        /* red comp of duppal */
short green;                                      /* green comp of duppal */
short blue;                                       /* blue comp of duppal */

short lumsat[16];                                 /* lumin/satur palette */
short huepal[16];                                 /* hue palette */
short intpal[16];                                 /* intensity palette */

short invid;                                      /* inverse video value */

/*
** Prtblk pixel mapping parameters.
*/

short height;                                     /* BitMap height counter */
short quality;                                    /* print quality counter */
short color;                                      /* ymc color counter */
short width;                                      /* BitMap width counter */
short ajwidth;                                    /* adjusted width */
short planes;                                     /* BitMap plane count */
short pixhgt;                                     /* pixel block height */
short pixwid;                                     /* pixel block width */
short pixlen;                                     /* pixel block length */
short index;                                      /* lumsat index */
short inbit;                                      /* index set bit */

char prtn1;                                       /* BitMap mode argument n1 */
char prtn2;                                       /* BitMap mode argument n2 */
char prtbyt;                                      /* printer byte */
short prtbit;                                     /* printer byte set bit */

short *rasword;                                   /* raster word address */
short rasbit;                                     /* raster word bit */
short rasincr;                                    /* raster byte increment */
short *plzword;                                   /* plane zero word address */
short plzbit;                                     /* plane zero word bit */
short *pixword;                                   /* pixel word address */
short pixincr;                                    /* pixel byte increment */
short *plnword;                                   /* plane word address */

char pixblk[8];                                   /* pixel block */
char dmasks[] =                                   /* default halftone masks */
     {
        0x0f, 0x0f, 0x0d, 0x06, 0x09, 0x06,
        0x08, 0x06, 0x08, 0x02, 0x08, 0x00,
        0x08, 0x00, 0x08, 0x00, 0x00, 0x00
     };

short hues[4];                                    /* pixel block hues */
short intens[4];                                  /* pixel block intensities */

/*
** Prtblk miscellaneous globals.
*/

PRTARG a;                                         /* duplicate prtblk args */
