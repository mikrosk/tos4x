/*
*************************************************************************
*			Revision Control System
* =======================================================================
*  $Revision: 1.6 $	$Source: f:\multitos/RCS/gemrom.c,v $
* =======================================================================
*  $Author: ersmith $	$Date: 1993/04/27 23:00:14 $	$Locker:  $
* =======================================================================
*  $Log: gemrom.c,v $
*  Revision 1.6  1993/04/27  23:00:14  ersmith
*  Merged Cary's and Hans-Martin's changes
*
 * Revision 1.4  1993/03/12  19:51:12  ersmith
 * Merged HMK's loadable resource stuff
 *
 * Revision 1.3  1993/03/10  20:12:42  ersmith
 * Lattice port
 *
* Revision 1.1  1993/02/24  23:52:46  ersmith
* 1 meg floppy MultiTOS
*
* Revision 1.0  1993/02/03  21:26:46  ersmith
* MultiTOS version 1.0
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
/* 	02/16/93	cjg	Converted to Lattice C 5.51		*/
/*	02/23/93	cjg	Force the use of prototypes		*/
/*	Add sofloaded resources			02/93   H.M.Krober	*/

/*	-----------------------------------------------------------
*	AES Version 4.0	MultiTOS version is written by Derek M. Mui
*	Copyright (C) 1992 
*	Atari (U.S.) Corp
*	All Rights Reserved
*	-----------------------------------------------------------
*/	

#include "pgem.h"
#include "pmisc.h"

#include "machine.h"
#include "objaddr.h"
#include "aesmint.h"
#include "rslib.h"
#include "gemdos.h"
/*
 *	Set the SOFTLOAD flag to implement softloaded GEM AES/DESKTOP
 *	resources. The AES will then try to read its resource file from
 *	[A|C]:\MULTITOS\GEM.RSC.  
 *
 *	NOTE: You have to define SOFTLOAD in geminit.c and desktop.c, too.
 *
 *	See the Defines in the makegem/makedesk files.
 */

/*
 *	Turn on resource file version number checking by setting the
 *	GEMRSVER to 1. Use "rscvers versnr GEM.RSC"
 *	to create a GEM.RSC with a version number in the first byte of the
 *	resource header. This is to prevent user from using the wrong
 *	resource file.
 *	See the Defines in the makegem/makedesk files.
 */

/* 
 * 	Set the ONERSC flag to indicate that the system just has the
 *	U.S. desktop resource in ROMs. If the system cannot load the
 *	GEM.RSC from disk, it will displaying a warning, saying that
 *	the U.S. version from ROM will be used.
 *	See the Defines in the makegem/makedesk files.
 *
 *	-> This message has to get internationalized?!
 */



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
#if SOFTLOAD
MLOCAL	LONG		rgemptr;	/* GEM's rsc pointer (ROM vers)	*/
MLOCAL	WORD		romuse;
#endif
MLOCAL	UWORD		*tosrsc;

MLOCAL VOID		rom_read( VOID );

#if SOFTLOAD

MLOCAL UWORD		*rscaddr; 	/* addr of the loaded rsc file */
MLOCAL LONG		rsc_load( VOID );
MLOCAL BYTE *GEMRSC = 	"C:\\MULTITOS\\GEM.RSC"; /* fname of rsc file */
#endif

#if ONERSC
MLOCAL	BYTE	*RSCTABLE[] =
{
	USARSC		/* USA, UK	*/
};			/* only US version in ROMs */

#else
MLOCAL	BYTE	*RSCTABLE[] =
{
	( BYTE *)USARSC,		/* USA, UK	*/
	( BYTE *)GRMRSC,		/* GERMAN	*/
	( BYTE *)FRERSC,		/* FRENCH	*/
	( BYTE *)USARSC,		/* reserved	*/
	( BYTE *)SPARSC,		/* SPANISH	*/
	( BYTE *)ITARSC,		/* ITALIAN	*/
	( BYTE *)USARSC		/* suppose to be SWEDISH	*/
};	
#endif

GLOBAL	WORD		st_lang;	/* Language code	*/
GLOBAL	LONG		deskptr;	/* DESKTOP'S rsc pointer	*/
GLOBAL	LONG		infptr;
#if SOFTLOAD
GLOBAL	LONG		rdeskptr;	/* DESKTOP'S rsc pointer	*/
GLOBAL	LONG		rinfptr;	/* ROM version			*/
#endif

/* do this whenever the Gem or desktop is ready		*/

	WORD
rom_ram( which, pointer )
	WORD		which;
	REG LONG	pointer;
{
	WORD		size;
	BYTE		*ptr;

	switch( which )
	{
	  case 0:		/* get the gem resource	*/
#if SOFTLOAD
	    if (rgemptr == gemptr) {	/* we only have to do this, if the */
					/* rom version is used */ 
	   	 ptr = (BYTE *)tosrsc;
	   	 ptr += 10;
	   	 size = tosrsc[0];
	    	 LBCOPY( (BYTE *)gemptr, ptr, size );
	    }
#else
	   	 ptr = (BYTE *)tosrsc;
	   	 ptr += 10;
	   	 size = tosrsc[0];
	    	 LBCOPY( (BYTE *)gemptr, ptr, size );
#endif
	    rs_global = pointer;
	    rs_hdr = gemptr;
	    LLSET( pointer + 14, rs_hdr );
	    LWSET( pointer + 18, size );
	    do_rsfix( rs_hdr, size ); 
	    rs_fixit( pointer );
	    break;

	  case 1:		/* copy the desktop resource	*/
				/* ok, the rsc file was not found 	*/
				/* on disk, so we have to use the 	*/
				/* rom version.				*/
#if SOFTLOAD
	    if (!romuse) {
		rom_read();
		
	    }  
	    deskptr = rdeskptr;
	    if (pointer == NULL)
		pointer = deskptr;
#endif
	    ptr = ( BYTE *)tosrsc;
	    ptr += tosrsc[0];
	    LBCOPY( ( BYTE *)pointer, ptr, tosrsc[1] - tosrsc[0] );
	    break;

	  case 3:		/* read in desktop.inf		*/
#if SOFTLOAD
	    if (!romuse) {
		rom_read();
		
	    }
	    infptr = rinfptr;
	    if (pointer == NULL)
		pointer = infptr;
#endif
	    LBCOPY( ( BYTE *)pointer, ( BYTE *)infptr, tosrsc[2] - tosrsc[1] );
	    return( tosrsc[2] - tosrsc[1] );
	}
}


/*	Free the system resource	*/

	VOID
rsc_free( VOID )
{
	
#if SOFTLOAD	
	
	if (romuse) {
		dos_free( gl_pglue );
		gemptr = rgemptr = NULL;
		deskptr = rdeskptr = NULL;
		infptr = rinfptr = NULL;
		romuse = FALSE;	
	} else if (gemptr) {
		dos_free(gemptr);
	}
	gemptr = NULL;
	rgemptr = NULL;
#else
	dos_free( gl_pglue );
#endif
}



/*	Read in the resource file (gem, desk, inf)  from ROM */	

	WORD
rsc_read( VOID )
{
	
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

#if SOFTLOAD
#if ONERSC
	tosrsc = RSCTABLE[0];	/* only US version in roms */
#else
	tosrsc = RSCTABLE[st_lang];
#endif
	gemptr = rsc_load();	/* try to load version from disk */

	if (gemptr == NULL) {		/* if no gem.rsc found,   */
					/* use US Version in ROMs */
		rom_read();
		gemptr = rgemptr;
#if ONERSC
		if (st_lang) != 0) {
			trap(0x9, "> Unable to open GEM.RSC in MULTITOS\r\n");
			trap(0x9, "> directory. Using US ROM version of\r\n");
			trap(0x9, "> GEM.RSC instead.\r\n");
			Fselect(3000, 0L, 0L, 0L);
		} else {
			trap( 0x9, "> Using GEM.RSC for AES from ROM.\r\n");
			Fselect(2000, 0L, 0L, 0L);
		}
#endif				
	}
#else
	tosrsc = RSCTABLE[st_lang];
	rom_read();
#endif
	
	return( TRUE );
}

MLOCAL VOID
rom_read( VOID )
{
	REG UWORD	*intptr;
	UWORD		size;
	BYTE		*a;
	BYTE		*b;

	if ( !( gl_pglue = dos_xalloc( (LONG)tosrsc[2], 3 ) ) )
	{
	  bailout( "Unable to install AES resource!\r\n" );
	  return;
	}

	intptr = tosrsc;
				/* copy the resource to RAM	*/
	size = intptr[2];
	a = ( BYTE *)tosrsc;
	b = ( BYTE *)gl_pglue;

	while( size )
	{
	  *b++ = *a++;
	  size--;	   
	}

	intptr = ( UWORD *)gl_pglue;

#if SOFTLOAD
	rgemptr = (LONG)(gl_pglue + 10);	/* Gem Resource */
	rdeskptr = (LONG)(gl_pglue + intptr[0]);/* Desktop Resource */
	rinfptr = (LONG)( gl_pglue + intptr[1] );/* Inf file resource */
	romuse = TRUE;
#else
	gemptr = (LONG)(gl_pglue + 10);	/* Gem Resource */
	deskptr = (LONG)(gl_pglue + intptr[0]);/* Desktop Resource */
	infptr = (LONG)( gl_pglue + intptr[1] );/* Inf file resource */
#endif

}

#if SOFTLOAD

/* read gem.rsc from disk */

LONG rsc_load()
{
	WORD	fd;
	LONG    rsl_hdr = NULL;
	LONG	rslsize;
	UWORD	hdr_buff[HDR_LENGTH/2];
	BYTE	vers;

	*GEMRSC = ( isdrive() & 0x4 ) ? 'C' : 'A';
	if ( ( fd = dos_open(GEMRSC, RMODE_RD) ) >= 0 )
	{
	  if ( dos_read( fd, HDR_LENGTH, &hdr_buff[0] ) > 0 )
	  {
	     /*
 	      *	Check the version number in the 1st byte of the rsc header.
	      * The format is: %1xxxxxxx
 	      *                 |  |
	      *                 |  +- version number
	      *                 +---- always one
	      */
#if GEMRSVER
	     vers = (BYTE) (hdr_buff[0] >> 8);
	     if (vers != (GEMRSVER | 0x80)) {
					/* wrong version number */ 
			trap(0x9, "> Incorrect version of GEM.RSC in\r\n");
			trap(0x9, "> MULTITOS directory. Using ROM\r\n");
			trap(0x9, "> version of GEM.RSC instead.\r\n");
			Fselect(3000, 0L, 0L, 0L); 
			goto rs_end;
	     }
#endif
					/* get size of resource	*/

						/* New format		*/
	     if ( hdr_buff[RT_VRSN] & 0x0004 )		
	     {					/* seek to the 1st entry*/
						/* of the table		*/
	       if ( dos_lseek( fd, SMODE, (LONG)(hdr_buff[RS_SIZE]) ) 
		    != hdr_buff[RS_SIZE] )
	       {
	         goto rs_end;
	       }
						/* read the size	*/
	       if ( dos_read( fd, sizeof(LONG), &rslsize ) != sizeof(LONG) )
	       {
	         goto rs_end;
	       }

	     }
	     else 	
	       rslsize = hdr_buff[RS_SIZE];
						/* allocate memory	*/
	     if ( rsl_hdr = dos_xalloc( rslsize, 3 ) )
	     {
						/* read it all in 	*/
	        dos_lseek( fd, SMODE, 0x0L );
	        if ( trap( X_READ, fd, rslsize, rsl_hdr ) == rslsize )
		{
	       		;
		}
		else
		  dos_free( rs_hdr );
	     }
	  }
rs_end:
	  dos_close( fd );
	}
	return rsl_hdr;
}
#endif
