#include <osbind.h>
#include <string.h>

#if __STDC__
#include <stdlib.h>
#else
char *malloc();
#endif

/* macros like Gx, Bx, XBx are hard-coded for NARGS */
#define NARGS 9

/* TYPES: OR with 0x80 for longs. */

#define NOTUSED 0
#define CHAR 1
#define INT 2
#define WZERO 3		/* a word of zero */
#define LONG 0x84
#define STRING 0x85	/* type in a string */
#define RSBUF 0x86	/* allocate a read-string buffer */
#define BUF 0x87	/* a buffer (xSIZE syntax allowed) */
#define LZERO 0x88	/* a long zero */
#define TIMEBUF 0x89	/* a time and a date */
#define FMAGIC 0x8a	/* this arg is 0x87654321 */

#define LINESIZE 128

/*
 * Things returned by calls
 */

/* LONG is long */
/* INT is int */
/* RSBUF is rsbuf; argv[0] is address */
#define FREAD 0x100	/* means argv[2] is a buffer; dump 1st part */
			/* return value from function is size of buf */

#define BUF0 0x101	/* argv[0] is a character buffer; print it */
#define XDTA 0x102	/* Fgetdta is a dta; display it */
#define DFREE 0x103	/* argv[0] is a dfree buffer */
#define XMPB 0x105	/* argv[0] is an mpb */
#define XBPB 0x106	/* return value is a bpb */
#define FMTBUF 0x107	/* argv[0] is a flopfmt return buffer */
#define IOREC 0x108	/* return value is iorec; for argv[0] there are 2 */
#define BOOT 0x109	/* argv[0] is a boot sector */
#define FDATIME 0x10a	/* argv[0] is a date/time buf */
#define PALETTE 0x10b	/* argv[0] is start, [1] is length, [2] is buf */

typedef struct op {
    char name[28];
    int trap;
    int ret;
    int fcode;
    char *aname[NARGS];
    int type[NARGS];
} OP;

extern OP optab[];
extern int NCMDS;

/* include last, because protos come after structs */
#include "fs.h"


