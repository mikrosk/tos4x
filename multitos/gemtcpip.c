/*	GEMTCPIP.C	9/19/92				Derek Mui		*/
/*	THis file contains functions to handle interprocess communication	*/

/*	-----------------------------------------------------------
*	AES Version 4.0	MultiTOS version is written by Derek M. Mui
*	Copyright (C) 1992 
*	Atari (U.S.) Corp
*	All Rights Reserved
*	-----------------------------------------------------------
*
*	02/12/93	cjg	Converted to Lattice C 5.51
*	02/22/93	cjg	Force the use of prototypes
*/	
#include "pgem.h"
#include "pmisc.h"

#include "machine.h"
#include "pdstruct.h"
#include "dispvars.h"
#include "aesmint.h"

EXTERN	PD	*currpd;
EXTERN	WORD	spdid;		/* wm_update owner	*/

#define	IP_OK		 0
#define IP_LOCK		-1	/* Sender is locking the screen resource	*/
#define	IP_NOID		-2	/* No receiver or invalid ID			*/
#define	IP_TIMEOUT	-3

#define	IP_SIZE	1024


/*	Talk to a process and wait for its reply	*/

	WORD
ip_talk( id, buffer )
	WORD	id;		/* receiver AES id	*/
	BYTE	*buffer;	/* data buffer		*/
{
	if ( currpd->p_pid == spdid )	/* the sender owns the screen 	*/
	  return( IP_LOCK );	/* return dead lock error	*/

	if ( !idtopd( id ) )
	  return( IP_NOID );

	return(IP_OK ); 
}

