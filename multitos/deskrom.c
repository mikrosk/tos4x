/*	NEW	DESKROM.C	01/11/88 - 1/19/88	Derek Mui	*/
/*	Look for TOS.RSC and read in GEM.RSC,DESKTOP.RSC,DESKTOP.INF	*/
/*	Make sure you set the switches right at machine.h		*/
/*	Change at rsc_read do_cdir	1/28/88		D.Mui		*/	
/*	Change at rsc_read for TOS and ROM system 3/11/88		*/
/*	Put in all the resources		6/10/92	D.Mui		*/ 
/* 	02/16/93	cjg	Converted to Lattice C 5.51		*/
/*	02/23/93	cjg	Force the use of prototypes		*/
/*	Add sofloaded resources			02/93   H.M.Krober	*/
/*	Renamed to DESKROM.C			03/18/93 C.Gee		*/


/*	-----------------------------------------------------------
*	AES Version 4.0	MultiTOS version is written by Derek M. Mui
*	Copyright (C) 1992 
*	Atari (U.S.) Corp
*	All Rights Reserved
*	-----------------------------------------------------------
*/	


/*
 *	Set the SOFTLOAD flag to implement softloaded GEM AES/DESKTOP
 *	resources. The AES will then try to read its resource file from
 *	[A|C]:\MULTITOS\GEM.RSC.  
 *
 *	NOTE: You have to define SOFTLOAD in desktop.c too.
 *	See the Defines SOFTLOAD.H
 */
/*
 *	Turn on resource file version number checking by setting the
 *	GEMRSVER to 1. Use "rscvers versnr GEM.RSC" create
 *	create a GEM.RSC with a version number in the first byte of the
 *	resource header. This is to prevent user from using the wrong
 *	resource file.
 *	See the Defines in SOFTLOAD.H
 */
/* 
 * 	Set the ONERSC flag to indicate that the system just has the
 *	U.S. desktop resource in ROMs. If the system cannot load the
 *	GEM.RSC from disk, it will displaying a warning, saying that
 *	the U.S. version from ROM will be used.
 *	See the Defines in SOFTLOAD.H
 *
 *	-> This message has to get internationalized?!
 */

/*
 *	Set the DESKPRG flag to compile as a desktop replacement.
 *	Otherwise, this will compile for GEM.SYS
 *	Change the flags also in DESKTOP.C, DESKVARI.C, DESKSTAR.S
 *	See the Defines in SOFTLOAD.H
 */




#include "softload.h"

#if DESKPRG
#include "pdesk.h"
#include "pmisc.h"
#include "pboth.h"
#else
#include "pgem.h"
#include "pmisc.h"
#endif

#include "machine.h"
#include "objaddr.h"
#include "aesmint.h"
#include "rslib.h"
#include "gemdos.h"


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
	( BYTE *)USARSC		/* USA, UK	*/
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
#if !DESKPRG
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
#endif


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
#if DESKPRG
		free( ( VOIDP )gl_pglue );
#else
		dos_free( gl_pglue );
#endif
		gemptr = rgemptr = NULL;
		deskptr = rdeskptr = NULL;
		infptr = rinfptr = NULL;
		romuse = FALSE;	
	} else if (gemptr) {
#if DESKPRG
		free( ( VOIDP )gemptr);
#else
		dos_free( gemptr );
#endif
	}
	gemptr = NULL;
	rgemptr = NULL;
#else
#if DESKPRG
	free( ( VOIDP )gl_pglue );
#else
	dos_free( gl_pglue );
#endif

#endif
}



/*	Read in the resource file (gem, desk, inf)  from ROM */	

	WORD
rsc_read( VOID )
{

#if DESKPRG	
	/* moved to geminit.c 12/8/92 -- ERS */
	/* Restored here for desktop separation 03/18/93 -- CJG */

	LONG		value;

	/* The value is defined as 	*/
	/* X, X,  LANGUAGE, KEYVBOARD	*/


	if ( getcookie( 0x5F414B50L, &value ) )	/* get _AKP cookie */
	  st_lang = (( WORD )( value >> 8L ) & 0x00FF);	/* get the keyboard preferences */
	else
	  st_lang = 0;

	if ( ( st_lang > 6 ) || ( st_lang < 0 ) || ( st_lang == 3 ) )
	  st_lang = 0;
#endif

#if SOFTLOAD
#if ONERSC
	tosrsc = ( UWORD *)RSCTABLE[0];	/* only US version in roms */
#else
	tosrsc = ( UWORD *)RSCTABLE[st_lang];
#endif

#if DESKPRG
	rom_read();
	gemptr = rgemptr;
#else
	gemptr = rsc_load();	/* try to load version from disk */

	if( gemptr == NULL )
	{
	   rom_read();
	   gemptr = rgemptr;
	}
#endif


#else /* #else SOFLOAD */
	tosrsc = ( UWORD *)RSCTABLE[st_lang];
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

#if DESKPRG
	if ( !( gl_pglue = ( LONG )lmalloc( (LONG)tosrsc[2] ) ) )
#else
	if ( !( gl_pglue = dos_xalloc( (LONG)tosrsc[2], 3 ) ) )
#endif
	{
	    trap( 9, "Unable to install AES resource!\r\n" );
	    trap( 9, "Please reboot the machine!" );
	    while( !trap13( 1,2 ) );
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

#if !DESKPRG
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
	     vers = (BYTE) (hdr_buff[0] >> 8);
#if GEMRSVER
	     if (vers != (GEMRSVER | 0x80)) {
#if 0
					/* wrong version number */ 
			trap(0x9, "> Incorrect version of GEM.RSC in\r\n");
			trap(0x9, "> MULTITOS directory. Using ROM\r\n");
			trap(0x9, "> version of GEM.RSC instead.\r\n");
			Fselect(3000, 0L, 0L, 0L); 
#endif
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
#endif
