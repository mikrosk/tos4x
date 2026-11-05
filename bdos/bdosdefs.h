/* major.minor */
#undef GEMDOS
#define GEMDOS 0x0013
#undef GEMDOS
#define GEMDOS 0x0014
#undef GEMDOS
#define GEMDOS 0x0015
#undef GEMDOS
#define GEMDOS 0x0017
#undef GEMDOS
#define GEMDOS 0x0019
#undef GEMDOS
#define GEMDOS 0x0020


/* common supervisor stack size (in words) (also defined in biosdefs.h) */
#ifndef SUPSIZ
#define SUPSIZ 1536
#endif
/* max open files in system */
#define OPNFILES 81
/* max current directories in use in system */
#define NCURDIR 40
/* number of block devices supported: A: ... Z: */
#define BLKDEVNUM 16
/* size of typeahead buffer */
#define KBBUFSZ 80
/* for compatibility with older versions: size of root array */
#define MAXQUICK 5

/*
 * support for filesystems with 1 fat only
 */

/*
 * support for alternate ram
 */
