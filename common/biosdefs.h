/* common supervisor stack size (in words) (also defined in bdosdefs.h) */
#ifndef SUPSIZ
#define SUPSIZ 1536
#endif

#define NUMFLOPPIES 2

/* standard for floppy, hard disk */
#define SECTOR_SIZE     512

#define SERIAL_BUFSIZE 256

/* number of sectors for media change detection */
#define BPBSECT 6

/* media def has not changed */
#define MEDIANOCHANGE    0
/* media may have changed */
#define MEDIAMAYCHANGE   1
/* media def has changed */
#define MEDIACHANGE      2

#define NCOOKIES 16

#define NVRAM_SUPPORT ((TOSVERSION >= 0x300) & !TP_50)

#define STBOOK 0

#define SPARROW 0

#define MSTECLK 1

/*
 * True if TT-MFP is assumed to be present;
 * otherwise checked at runtime
 */
#define TTMFP_ASSUMED (((TOSVERSION >= 0x300) & (TOSVERSION < 0x400)) & !TP_50)

/*
 * True to add support for TT-MFP
 */
#define TTMFP_SUPPORT (TTMFP_ASSUMED | (TP_50 & TP_55)) /* (TTMFP_ASSUMED | (PAK & HasTTMfp)) */

#define SCC_SUPPORT 0

/*
 * used to mark some strange looking code segments
 * that are needed to create a binary equivalent image
 * of the TOS ROMs
 */


/*
 * number of extra entries in bconmap table
 */
#if TTMFP_SUPPORT
#define rs232devs 4
#else
#define rs232devs 3
#endif

#define FASTRAMBASE $01000000

#define HD_SUPPORT 1
