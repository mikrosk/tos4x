/*
 ********************************  vdidefs.h  *********************************
 *
 * =============================================================================
 * $Author: lozben $	$Date: 91/01/03 15:22:56 $
 * =============================================================================
 *
 * Revision 3.0  91/01/03  15:22:56  lozben
 * New generation VDI
 * 
 * Revision 2.2  90/03/01  13:32:58  lozben
 * *** Initial Revision ***
 * 
 *******************************************************************************
 */

#ifndef __VDIDEFS_H__
#define __VDIDEFS_H__ 1

#include "config.h"

#define	MAX_PAL		4096	/* palette size                     */

/*
 * set to 1 for supporting pixel-packed VIDEL modes, including hicolor and truecolor
 */

/*
 * set to 1 for supporting hardware accelerated blitter routines
 */

/*
 * set to 1 for supporting 8 planes interleaved video modes
 * (and corresponding 256 entries color palette)
 */

/*
 * used to mark some strange looking code segments
 * that are needed to create a binary equivalent image
 * of the TOS ROMs
 */

/*
 * used to mark code changes due to
 * multiple linea variable structures feature
 */
#define MULTI_LINEA (TOSVERSION >= 0x400)

/*
 * see lineavar.h for explanation
 */


#define MU_PLANES 4


/*
 * size of the "overlay" area
 */
#define OVLSIZE 3890

/*
 * PTSIN maximum length
 */
#define MAX_PTSIN 512

#endif /* __VDIDEFS_H__ */
