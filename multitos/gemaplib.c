/*	GEMAPLIB.C			10/31/90	D.Mui		*/
/*	Fix the ap_tplay, so after it finished, it stay where it is	*/
/*	4/17/86			Derek Mui				*/ 
/*	Fix at ap_tplay	4/8/86			Derek Mui		*/
/*	Kludge at ap_tplay 3/11/86 - 3/12/86	Derek Mui		*/
/*	Fix the ap_trec 03/10/86		Derek Mui		*/
/*	1.1		03/20/85		Lowell Webster		*/
/*	Reg Opt		03/09/85		Derek Mui		*/
/*	GEMAPLIB.C	03/15/84 - 02/09/85	Lee Lorenzen		*/
/*	Fix at ap_trecd to fix the length  4/5/90	D.Mui		*/
/*	Change at appl_exit	11/16/90 - 12/18/90	D.Mui		*/
/*	Change at ap_rdwr for Mint OS	7/23/91		D.Mui		*/

/*	-----------------------------------------------------------
*	AES Version 4.0	MultiTOS version is written by Derek M. Mui
*	Copyright (C) 1992 
*	Atari (U.S.) Corp
*	All Rights Reserved
*	-----------------------------------------------------------
*/	

/*
*	-------------------------------------------------------------
*	GEM Application Environment Services		  Version 1.1
*	Serial No.  XXXX-0000-654321		  All Rights Reserved
*	Copyright (C) 1985			Digital Research Inc.
*	-------------------------------------------------------------
*/

#include "compiler.h"
#include "machine.h"
#include "pdstruct.h"
#include "obdefs.h"
#include "gemlib.h"
#include "dispvars.h"
#include "aesmint.h"
#include "signal.h"

#define TCHNG 0
#define BCHNG 1
#define MCHNG 2
#define KCHNG 3

EXTERN	WORD		w_tophandle();
EXTERN	BYTE		*scasb();
EXTERN	VOID		pdterm();
EXTERN	PD		*systopd();
EXTERN	BYTE		*rs_str();
EXTERN	PD		*idtopd();
EXTERN	PD		*fpdnm();
EXTERN	WORD		tchange();
EXTERN	WORD		bchange();
EXTERN	WORD		mchange();
EXTERN	WORD		kchange();
EXTERN	WORD		justretf();

EXTERN	WORD		spdid;
EXTERN	WORD		cpdid;
EXTERN	PD		*alr;
EXTERN	WORD		gl_fid;
EXTERN	WORD		gl_fsm;
EXTERN	WS		gl_ws;
EXTERN	WORD		gl_multi;
EXTERN	WORD		sh_graphic;
EXTERN	WORD		phanwind;
EXTERN	GRECT		gl_offscreen;
EXTERN	WORD		gl_ticktime;
EXTERN	LONG		drwaddr;
EXTERN	WORD		gl_nplanes;
EXTERN	THEGLO		D;
EXTERN	GRECT		gl_rfull;
EXTERN	PD		*scr_pd;
EXTERN	WORD		gl_restype;
EXTERN	WORD		gl_rschange;
EXTERN	PD		*plr;
EXTERN	PD		*shellpd;

GLOBAL	WORD		gl_recd;
GLOBAL	WORD		gl_rlen;
GLOBAL	LONG		gl_rbuf;
GLOBAL	WORD		gl_play;	/* 3/11/86	*/
GLOBAL	LONG		gl_store;	/* 3/11/86	*/


/*	Search all the program in the system	*/

	WORD
ap_search( mode, name, type, paesid )
	WORD	mode;
	BYTE	*name;
	WORD	*type,*paesid;
{
	PD	*p;

	if ( mode == 2 )	/* search shell */
	{
	  p = shellpd;
	  movs( 8, p->p_name, name );
	  *paesid = p->p_pid;
	  *type = p->p_type;
	  return( TRUE );
	}

	if ( !mode )	/* search first	*/
	  currpd->p_spd = plr;

	p = plr;

	while( p )
	{
	  if ( p == currpd->p_spd )
	  {
	    movs( 8, p->p_name, name );
	    *paesid = p->p_pid;
	    *type = p->p_type;
	    currpd->p_spd = p->p_thread;
	    return( TRUE );
	  }

	  p = p->p_thread;
	}

	return( FALSE );
}



#define AESVERSION	0x0400FFFFL


/*	Check for AES id make sure there is no critcial		 	*/
/*	process is running and return it's pd				*/
/*	Return Zero for PD not found, -1 indicates this process 	*/
/*	isn't ready , otherwise it is OK				*/

	PD
*get_aespd( pcrys_blk )
	CBLK	*pcrys_blk;
{
	LONG	*l1;
	WORD	*w1;	
	PD	*p;

	w1 = (WORD *)pcrys_blk->cb_pglobal;
	l1 = (LONG *)pcrys_blk->cb_pglobal;
	
/*	p = (PD*)0;	*/

	if ( l1[0] == AESVERSION )	/* check for AES signature */
	  p = idtopd( w1[2] );
	else
	  p = systopd( (WORD)Pgetpid() );

	if ( p )
	{		/* Check to see if the new process is ready to run or	*/
			/* not. The make_ready in the disp() should change the	*/
			/* PS_NEW to PS_ALLRUN if it is ready			*/

	  if ( ( p->p_state & PS_NEW ) && !( p->p_type & AESSYSTEM ) )
	    return( (PD*)-1 );
	}

	return( p );
}


/*	Application get info 	*/
EXTERN WORD st_lang;

	WORD	
ap_getinfo( mode, out1, out2, out3, out4 )
	WORD	mode;
	WORD	*out1, *out2, *out3, *out4;
{
	WORD	ret;

	ret = TRUE;

	switch( mode )
	{
	  case AI_NTEXT:	/* inquire normal text 	*/
	    *out1 = gl_ws.ws_chmaxh;
	    *out2 = gl_fid;
	    *out3 = gl_fsm;	
	    break;

	  case AI_STEXT:	/* inquire small text	*/
	    *out1 = gl_ws.ws_chminh;
	    *out2 = gl_fid;
	    *out3 = gl_fsm;	
	    break;

	  case AI_E1:		/* general environment 1 */
	    *out1 = gl_restype;	/* resolution numbner		*/
	    *out2 = 16;		/* number of color supported 	*/
	    *out3 = 1;		/* supported color icons	*/
	    *out4 = 1;		/* supported new resources file */
	    break;	

	  case AI_LANG:		/* language info, etc */
	    *out1 = st_lang;	/* which language */
	    break;		/* we really should report more */

	  default:
	    ret = FALSE;	
	}

	return( ret );
}


/*	Application init	*/

	WORD
ap_init( pglobal )
	REG LONG	pglobal;
{
	Debug1( currpd->p_name );
	Debug1( " ->appl_init and from " );
	Debug1( currpd->p_where );
	Debug1( " Comtail is " );
	Debug1( currpd->p_wtail );
	Debug1( "\r\n" );

	if ( currpd->p_state == PS_ZOMBIE )
	  currpd->p_state = PS_RUN;

	LLSET(pglobal, AESVERSION);	/* version 4.0 MultiTask*/
	if ( !gl_multi )		/* Mint isn't here	*/
	  LWSET(pglobal+2, 1);		/* single task		*/

	LWSET(pglobal+4, currpd->p_pid);
	LWSET(pglobal+20, gl_nplanes);
	LLSET(pglobal+22, (LONG)currpd);
					/* Max character height	*/
	LWSET(pglobal+26, gl_ws.ws_chmaxh );
					/* Min character height	*/
	LWSET(pglobal+28, gl_ws.ws_chminh );

	if ( ( currpd->p_type & AESAPP ) && ( currpd != scr_pd ) )
	{				/* Just in case some app may	*/
					/* does appl_init several times	*/	
	  wm_update(1);
	  if ( w_tophandle( currpd ) == -1 )
	  {
	    openphanwind( currpd );
	    send_ctrl( currpd, 4 );
	  }
	  wm_update(0);
	}

	return( currpd->p_pid );
}


/*	Application exit 	*/

	WORD
ap_exit( p, pcrys_blk )
	PD	*p;
	CBLK	*pcrys_blk;
{
	LONG	*l1;

	if ( p->p_pid == cpdid )	/* release critical control */
	  cpdid = -1;

	swap_next( p, FALSE );	

	l1 =(LONG *) pcrys_blk->cb_pglobal;
	
	l1[0] = 0x0L;	/* erase aes signature */
	return( TRUE );
}


/*	Application termination		*/

	WORD
ap_term( id )
	WORD	id;
{
	PD	*p;
	LONG	i;

	if ( p = idtopd( id ) )
	{
	  if ( !(p->p_type & AESSYSTEM) && ( p->p_state != PS_DEAD ) )
	  {
	    i = (UWORD)(p->p_sysid);	  
	    forkq( pdterm, i << 16 );
/*	    if ( p == currpd )
	      p->p_state = PS_DEAD;
*/
	    return( TRUE );
	  }
	}

	return( FALSE );
}



/*	Return the name for the process	*/ 

	WORD
ap_name( id, buff )
	WORD	id;
	BYTE	*buff;
{
	PD	*p;

	if ( p = idtopd( id ) )
	{
	  movs( 8, p->p_name, buff );
	  buff[8] = 0;
	  return( TRUE );
	}
	else
	  return( FALSE );
}


/*	Read current process internal message	*/

	WORD
rd_inmsg( length, buffer )
	WORD	length;
	BYTE	*buffer;
{
	if ( length == EV_BUFSIZE )
	{
	  if ( !rd_mymsg( buffer ) )
	  {
	    if ( !rd_wmmsg( currpd, buffer ) )
	      return( FALSE );
	  }
	  return( TRUE );
	}

	return( FALSE );
}




/*	Application read or write	*/

	WORD
ap_rdwr( code, id, length, pbuff )
	WORD		code, id, length;
	BYTE		*pbuff;
{
	EVSPEC		msk;
	QPB		l;
	PD		*p;

	if ( id == -1 )		/* quick check for own message	*/
	{
	  if ( code == AQRD )	/* only for read operation	*/
	  {			/* check the regular message buffer first */
	    if ( currpd->p_qindex >= length )
	    {	
	      id = currpd->p_pid;
	      goto a_1;	
	    }
				/* check the auxially buffer */
	    if ( rd_inmsg( length, pbuff ) )
	      return( TRUE );
	  }
	}
	else
	{
	  if ( p = idtopd( id ) )
	  {			/* quick check for message if target	*/
				/* is itself and it is a read		*/

	    if ( ( p->p_state == PS_DEAD ) || ( p->p_state == PS_ZOMBIE ) )
		return( FALSE );

	    if ( ( code == AQRD ) && ( p == currpd ) )
	    {
	      if ( currpd->p_qindex >= length )
		goto a_1;

	      if ( rd_inmsg( length, pbuff ) )
		return( TRUE );
	    }

a_1:
	    l.qpb_pid = id;
	    l.qpb_cnt = length;
	    l.qpb_buf = pbuff;

	    msk = iasync( code, &l );

	    if ( msk == -1 )
	      return( TRUE );

	    if ( msk )
	    {
	      Debug1( currpd->p_name );
	      Debug1( "make Ap_rdwr need to wait\r\n" );	
				/* everything is OK	*/
	      mwait( msk );	/* wait for event	*/
	      aret( msk );
	      return( TRUE );
	    }
	  }
	}

	return( FALSE );		/* something is wrong	*/
}	


/*	Read the internal process message	*/

	WORD
rd_mymsg( buffer )
	BYTE	*buffer;
{

	if ( currpd->p_message[0] == 1 )	/* there is a message	*/
	{
	  Debug7( "Rd_mymsg buffer is " );
	  Ndebug7( buffer );
	  Ndebug7( &currpd->p_message[1] );
	  LBCOPY( buffer, &currpd->p_message[1], EV_BUFSIZE ); 
	  currpd->p_message[0] = 0;	/* message is sent	*/
	  return( TRUE );
	}
	else
	  return( FALSE );
}


/*	Application FIND	*/

	WORD
ap_find( pname )
	BYTE	*pname;
{
	REG PD		*p;
	BYTE		temp[9];
	WORD		loword,hiword;
/*	WORD		id;
	BYTE		*bptr;
*/
	if ( !pname )
	  return( currpd->p_pid );	

	loword = (WORD)((long)pname & 0x0000FFFFL);
	hiword = (WORD)(( (long)pname & 0xFFFF0000L ) >> 16);

	if ( hiword == 0xFFFF )		/* Look for AES Id */
	{
	  if ( p = systopd( loword ) )
	    return( p->p_pid );
	  else
	    return( -1 );
	}

	if ( hiword == 0xFFFE )		/* Look for Mint Id */
	{
	  if ( p = idtopd( loword ) )
	    return( p->p_sysid );
	  else
	    return( -1 );
	}

	LSTCPY( &temp[0], pname );

	if ( !( p = fpdnm( &temp[0], 0x0 ) ) )	/* Not found */
	  return( -1 );
    	
	return( p->p_pid );
}




/*
*	Application Tape Player
*/
	VOID
ap_tplay(pbuff, length, scale)
	REG LONG		pbuff;
	WORD		length;
	WORD		scale;
{
	REG WORD		i;
	FPD		f;
	LONG		ad_f;

	ad_f = (LONG)(&f);

	Syield();			/* dispatch everybody	*/

	gl_play = FALSE;

	for(i=0; i<length; i++)
	{
						/* get an event to play	*/
	  LBCOPY(ad_f, pbuff, sizeof(FPD));
	  pbuff += sizeof(FPD);
						/* convert it to machine*/
						/*   specific form	*/


	  switch( ((WORD)(f.f_code)) )
	  {
	    case TCHNG:
		ev_timer( (f.f_data*100L)/scale );
		f.f_code = 0;
		break;
	    case MCHNG:
	        if (!gl_play)	/* diconnect the cursor from VDI	*/
		{		/* until the playing is done		*/
		  i_lptr1( justretf, 0x0 );	
	  	  gsx_ncode(CUR_VECX, 0x0L);
	  	  m_lptr2( &drwaddr );	
		  i_lptr1( justretf, 0x0 );	/* not interrupt of mouse */
		  gsx_ncode(MOT_VECX, 0x0L);    /* movement		  */
		  m_lptr2( &gl_store );
		}
		f.f_code = &mchange;
		gl_play = TRUE;	      
		break;
	    case BCHNG:
		f.f_code = &bchange;
		break;
	    case KCHNG:
		f.f_code = &kchange;
		break;
	  }
						/* play it		*/
	  if (f.f_code)
	    forkq(f.f_code, f.f_data);

						/*  let someone else	  */
						/*  hear it and respond   */
	  Syield();
	}

	if (gl_play)				/* connect back the mouse */
	{
	  i_lptr1( drwaddr );	
	  gsx_ncode(CUR_VECX, 0x0L);
	  i_lptr1( gl_store, 0x0 );	
	  gsx_ncode(MOT_VECX, 0x0L);
	  gl_play = FALSE;
	}

} /* ap_tplay */


/*
*	APplication Tape RECorDer
*/
	WORD
ap_trecd(pbuff, length)
	REG LONG		pbuff;
	REG WORD		length;
{
	REG WORD		i;
	REG LONG		code;
	    BYTE		*trash;	
						/* start recording in	*/
						/*   forker()		*/
	cli();
	gl_recd = TRUE;
	gl_rlen = length;
	gl_rbuf = pbuff;
	sti();
	  					/* 1/10 of a second	*/
						/*   sample rate	*/
	while( gl_recd )
	  ev_timer(100L);
						/* done recording so	*/
						/*   figure out length	*/
	cli();
	gl_recd = FALSE;
	length = length - gl_rlen;		/* Fixed 4/5/90		*/
	gl_rlen = 0;
/*	length = ((WORD)(gl_rbuf - pbuff)) / sizeof(FPD);	*/
	gl_rbuf = 0x0L;
	sti();
						/* convert to machine	*/
						/*   independent 	*/
						/*   recording		*/
	for(i=0; i<length; i++)
	{
	  code = 0x0L;
	  trash = (BYTE *)(LLGET(pbuff));
	  if(trash == (BYTE *)(&tchange))
	  {
	    code = TCHNG;		/*    WORD is changed to LONG	*/
/*	    LLSET(pbuff+sizeof(LONG *), LLGET(pbuff+sizeof(LONG *)) * 
			gl_ticktime);	*/
	  }
	  if(trash == (BYTE *)(&mchange))
	    code = MCHNG;
	  if(trash == (BYTE *)(&kchange))
	    code = KCHNG;
	  if(trash == (BYTE *)(&bchange))
	    code = BCHNG;
	  LLSET(pbuff, code);
	  pbuff += sizeof(FPD);
	}
	return(length);
} /* ap_trecd */


