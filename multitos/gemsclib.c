/*
*************************************************************************
*			Revision Control System
* =======================================================================
*  $Revision: 1.3 $	$Source: f:\multitos/RCS/gemsclib.c,v $
* =======================================================================
*  $Author: ersmith $	$Date: 1993/03/10 20:12:42 $	$Locker:  $
* =======================================================================
*  $Log: gemsclib.c,v $
*  Revision 1.3  1993/03/10  20:12:42  ersmith
*  Lattice port
*
*
* Revision 1.1  1993/02/24  23:52:46  ersmith
* 1 meg floppy MultiTOS
*
* Revision 1.0  1993/02/03  21:26:46  ersmith
* MultiTOS version 1.0
*
* Revision 2.2  89/04/26  18:26:50  mui
* TT
* 
* Revision 2.1  89/02/22  05:29:27  kbad
* *** TOS 1.4  FINAL RELEASE VERSION ***
* 
* Revision 1.1  88/06/02  12:35:07  lozben
* Initial revision
* 
*************************************************************************
*/
/*	GEMSCLIB.C	07/10/84 - 02/02/85	Lee Lorenzen		*/
/*	to 68k		03/08/85		Lowell Webster		*/

/*	-----------------------------------------------------------
*	AES Version 4.0	MultiTOS version is written by Derek M. Mui
*	Copyright (C) 1992 
*	Atari (U.S.) Corp
*	All Rights Reserved
*	-----------------------------------------------------------
*/	

/*
*	-------------------------------------------------------------
*	GEM Application Environment Services		  Version 1.0
*	Serial No.  XXXX-0000-654321		  All Rights Reserved
*	Copyright (C) 1985			Digital Research Inc.
*	-------------------------------------------------------------
*
*	02/12/93	cjg	Convert to Lattice C 5.51
*	02/23/93	cjg	Force the use of prototypes
*/

#include "pgem.h"
#include "pmisc.h"

#include "machine.h"


EXTERN THEGLO		D;


	VOID
sc_read(pscrap)
	LONG		pscrap;
{
	LSTCPY( ( BYTE *)pscrap, ( BYTE *)&D.g_scrap[0]);
}


	VOID
sc_write(pscrap)
	LONG		pscrap;
{
	LSTCPY( ( BYTE *)&D.g_scrap[0], ( BYTE *)pscrap);
}

