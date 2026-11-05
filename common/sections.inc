#include "config.h"

/*
 * Definitions for length of text, data and bss
 * of the separate modules.
 *
 * Length of BIOS text segment is different due to some extra
 * code for ALT-scancode mappings.
 *
 * Length of DESKTOP text segment is different due to some
 * differences in fmt_date() and fmt_time() which build
 * a language-specific version of the file date+time
 */


#define BTLEN_US    $0000603A
#define DTLEN_US    $0000FBCC

#define BIOSTLEN    BTLEN_US
#define DESKTLEN    DTLEN_US
#define DESKDLEN    $00000982
#define GLUELEN     $00007492

/*
 * these are identical in all language versions
 */
#define BIOSDLEN    $00000888
#define VDITLEN     $0000999A
#define VDIDLEN     $00002846
#define BDOSTLEN    $000062FC
#define BDOSDLEN    $0000039E
#define AESTLEN     $0000CCD6
#define AESDLEN     $000006D8


/*
 * The value of the base address of a RAMVERSION
 * actually depends on the physical amount of ST-RAM available:
 * - 4MB:   $00380000
 * - 16MB:  $00D80000
 * Other values depend on where the alternate RAM is located.
 * If it starts at $01000000 (like on TT or Falcon), use
 * - 64MB:  $04F80000
 * - 128MB: $08F80000
 * - 256MB: $10F80000
 * - 512MB: $20F80000
 * On Hades (with linear memory), use
 * - 64MB:  $03F80000
 * - 128MB: $07F80000
 * - 256MB: $0FF80000
 * - 512MB: $1FF80000
 * loadtos.prg from the TOSPATCH package can be used
 * to load such a TOS.
 */
#ifndef BIOSTBASE
#define BIOSTBASE   $00E00000
#endif


/*
 * now calculate addresses from above
 */
/*
 * The order of all TOS versions is BIOS, VDI, GEMDOS, AES, DESK (+ glued resource files)
 */
#define VDITBASE  BIOSTBASE+BIOSTLEN
#define BDOSTBASE VDITBASE+VDITLEN
#define AESTBASE  BDOSTBASE+BDOSTLEN
#define DESKTBASE AESTBASE+AESTLEN
#define ETEXT     DESKTBASE+DESKTLEN

#define BIOSDBASE ETEXT
#define VDIDBASE  BIOSDBASE+BIOSDLEN
#define BDOSDBASE VDIDBASE+VDIDLEN
#define AESDBASE  BDOSDBASE+BDOSDLEN
#define DESKDBASE AESDBASE+AESDLEN
#define EDATA     DESKDBASE+DESKDLEN+GLUELEN

