/*
*************************************************************************
*			Revision Control System
* =======================================================================
*  $Revision: 1.1 $	$Source: f:\multitos/RCS/gemrom.c,v $
* =======================================================================
*  $Author: ersmith $	$Date: 1993/02/24 23:52:46 $	$Locker:  $
* =======================================================================
*  $Log: gemrom.c,v $
*  Revision 1.1  1993/02/24  23:52:46  ersmith
*  1 meg floppy MultiTOS
*
* Revision 2.2  89/04/26  18:26:27  mui
* TT
* 
* Revision 2.1  89/02/22  05:29:13  kbad
* *** TOS 1.4  FINAL RELEASE VERSION ***
* 
* Revision 1.5  88/11/01  18:02:04  kbad
* Revamped PRG define
* 
* Revision 1.4  88/10/03  12:08:52  kbad
* New build obsoletes ROM/IMG/PRG changes.
* 
* Revision 1.3  88/09/22  04:49:08  kbad
* Added "tosrsc" label of inline linked resource
* 
* Revision 1.2  88/09/08  18:59:25  kbad
* added <flavor.h> for prg/img/rom flag
* 
* Revision 1.1  88/06/02  12:34:59  lozben
* Initial revision
* 
*************************************************************************
*/
/*	NEW	GEMROM.C	01/11/88 - 1/19/88	Derek Mui	*/
/*	Look for TOS.RSC and read in GEM.RSC,DESKTOP.RSC,DESKTOP.INF	*/
/*	Make sure you set the switches right at machine.h		*/
/*	Change at rsc_read do_cdir	1/28/88		D.Mui		*/	
/*	Change at rsc_read for TOS and ROM system 3/11/88		*/
/*	Put in all the resources		6/10/92	D.Mui		*/ 

/*	-----------------------------------------------------------
*	AES Version 4.0	MultiTOS version is written by Derek M. Mui
*	Copyright (C) 1992 
*	Atari (U.S.) Corp
*	All Rights Reserved
*	-----------------------------------------------------------
*/	

#define ONE_LANG	/* only 1 country resource */

#include <compiler.h>
#include <machine.h>
#include <obdefs.h>
#include <objaddr.h>
#include <aesmint.h>

EXTERN	LONG	dos_xalloc();
EXTERN	VOID	do_rsfix();

EXTERN	LONG	rs_global;
EXTERN	LONG	rs_hdr;

EXTERN	UWORD	USARSC[];
EXTERN	UWORD	GRMRSC[];
EXTERN	UWORD	FRERSC[];
EXTERN	UWORD	ITARSC[];
EXTERN	UWORD	SWERSC[];
EXTERN	UWORD	SPARSC[];

MLOCAL	LONG		gl_pglue;
MLOCAL	LONG		gemptr;		/* GEM's rsc pointer		*/
MLOCAL	UWORD		*tosrsc;

#ifdef ONE_LANG
MLOCAL	BYTE	*RSCTABLE[] =
{
	USARSC,		/* USA, UK	*/
	USARSC,		/* GERMAN	*/
	USARSC,		/* FRENCH	*/
	USARSC,		/* reserved	*/
	USARSC,		/* SPANISH	*/
	USARSC,		/* ITALIAN	*/
	USARSC		/* suppose to be SWEDISH	*/
};	
#else
MLOCAL	BYTE	*RSCTABLE[] =
{
	USARSC,		/* USA, UK	*/
	GRMRSC,		/* GERMAN	*/
	FRERSC,		/* FRENCH	*/
	USARSC,		/* reserved	*/
	SPARSC,		/* SPANISH	*/
	ITARSC,		/* ITALIAN	*/
	USARSC		/* suppose to be SWEDISH	*/
};	
#endif

GLOBAL	WORD		st_lang;	/* Language code	*/
GLOBAL	LONG		deskptr;	/* DESKTOP'S rsc pointer	*/
GLOBAL	LONG		infptr;

/* do this whenever the Gem or desktop is ready		*/

	WORD
rom_ram( which, pointer )
	WORD		which;
	REG LONG	pointer;
{
	WORD		size;
	REG WORD	doit;
	BYTE		*ptr;

	switch( which )
	{
	  case 0:		/* get the gem resource	*/
	    ptr = tosrsc;
	    ptr += 10;
	    size = tosrsc[0];
	    LBCOPY( gemptr, ptr, size );
	    rs_global = pointer;
	    rs_hdr = gemptr;
	    LLSET( pointer + 14, rs_hdr );
	    LWSET( pointer + 18, size );
	    do_rsfix( rs_hdr, size ); 
	    rs_fixit( pointer );
	    break;

	  case 1:		/* copy the desktop resource	*/
	    ptr = tosrsc;
	    ptr += tosrsc[0];
	    LBCOPY( pointer, ptr, tosrsc[1] - tosrsc[0] );
	    break;

	  case 3:		/* read in desktop.inf		*/
	    LBCOPY( pointer, infptr, tosrsc[2] - tosrsc[1] );
	    return( tosrsc[2] - tosrsc[1] );
	}
}


/*	Free the system resource	*/

	VOID
rsc_free( )
{
	dos_free( gl_pglue );
}



/*	Read in the resource file	*/	

	WORD
rsc_read()
{
	REG UWORD	*intptr;
	UWORD		size;
	BYTE		*a;
	BYTE		*b;
	
#if 0	/* moved to geminit.c 12/8/92 -- ERS */
	LONG		value;

	/* The value is defined as 	*/
	/* X, X,  LANGUAGE, KEYVBOARD	*/

	if ( aescookie( 0x5F414B50L, &value ) )	/* get _AKP cookie */
	  st_lang = ( value >> 8 ) & 0x00FF;	/* get the keyboard preferences */
	else
	  st_lang = 0;

	if ( ( st_lang > 6 ) || ( st_lang < 0 ) || ( st_lang == 3 ) )
	  st_lang = 0;
#endif

	tosrsc = RSCTABLE[st_lang];	
 
	if ( !( gl_pglue = dos_xalloc( (LONG)tosrsc[2], 3 ) ) )
	{
	  bailout( "Unable to install AES resource!\r\n" );
	  return( FALSE );
	}

	intptr = tosrsc;
				/* copy the resource to RAM	*/
	size = intptr[2];
	a = tosrsc;
	b = gl_pglue;

	while( size )
	{
	  *b++ = *a++;
	  size--;	   
	}

	intptr = gl_pglue;
	gemptr = (LONG)(gl_pglue + 10);	/* Gem Resource */
	deskptr = (LONG)(gl_pglue + intptr[0]);/* Desktop Resource */
	infptr = (LONG)( gl_pglue + intptr[1] );/* Inf file resource */
	return( TRUE );
}
