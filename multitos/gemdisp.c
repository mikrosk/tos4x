/*	GEMDISP.C	1/27/84 - 02/03/85	Lee Jay Lorenzen	*/
/*	Reg Opt		03/09/85		Derek Mui		*/
/*	1.1		03/21/85		Lowell Webster		*/
/*	Change chkbd	07/22/85		Derek Mui		*/
/*	Change disp_act	07/12/85		Derek Mui		*/
/*	Reorganize the chkkbd	08/14/85	Derek Mui		*/
/*	Trying 1.2	10/16/85		Derek Mui		*/
/*	Fix the forker  3/10/86			Derek Mui		*/
/*	Fix the KEYSTOP	3/21/86			Derek Mui		*/
/*	Inlined code of schedule and mwait_act	4/9/88			*/
/*	Fix the accessory wait problem	7/13/90	D.Mui			*/
/*	Block process when in critical error	8/1/90	D.Mui		*/
/*	Massive change for Mint		10/1/91		D.Mui		*/
/*	Convert to Lattice C 5.51	02/17/93	C.Gee		*/
/*	Force the use of prototypes	02/24/93	C.Gee		*/

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
#include "pgem.h"
#include "pmisc.h"

#include "machine.h"
#include "dispvars.h"
#include "windlib.h"
#include "message.h"
#include "aesmint.h"
#include "signal.h"

#define KEYSTOP 0x2b1c0000L		/* control backslash	*/
EXTERN  LONG	trap();
EXTERN  LONG	trap13();

EXTERN	WORD	gl_mfid;
EXTERN	WORD	reschid;
EXTERN	PD	*tlr;
EXTERN	WORD	spdid;
EXTERN	WORD	gl_mnpid;
EXTERN	PD	*alr;
EXTERN	GRECT	gl_offscreen;
EXTERN	WORD	phanwind;
EXTERN	WORD	scr_exit;
EXTERN	WORD	shutdown;
EXTERN	LONG	ad_armice;
EXTERN	GRECT	gl_rzero;
EXTERN	GRECT	gl_rfull;
EXTERN	WORD	deskwin;
EXTERN	THEGLO	D;
EXTERN	WORD	gl_moff;
EXTERN	PD	*shellpd;
EXTERN	LONG	shel_magic;
EXTERN	WORD	aesid;
EXTERN	PD	*scr_pd;
EXTERN	WORD	kstate;
EXTERN	WORD	gl_recd;
EXTERN	WORD	gl_rlen;
EXTERN	LONG	gl_rbuf;
EXTERN	WORD	gl_kbid;
EXTERN	WORD	gl_newid;
EXTERN	WORD	gl_dacnt;

GLOBAL	PD	*shutpd;	/* process that shut down the system */

GLOBAL	WORD	gl_debug;
GLOBAL	WORD	gl_port;


/*	Show all the current process on the screen	*/

	VOID
showall( VOID )
{
	PD	*p;

	p  = rlr;
	Debug1( "Rlr: " );
	while( p )
	{
	  Debug1( p->p_name );
	  Debug1( " " );
	  p = p->p_link;
	}	

	p  = drl;
	Debug1( "\r\nDrl: " );
	while( p )
	{
	  Debug1( p->p_name );
	  Debug1( " " );
	  p = p->p_link;
	}	

	p  = nrl;
	Debug1( "\r\nNrl: " );
	while( p )
	{
	  Debug1( p->p_name );
	  Debug1( " " );
	  p = p->p_link;
	}	

	p  = slr;
	Debug1( "\r\nSlr: " );
	while( p )
	{
	  Debug1( p->p_name );
	  Debug1( " " );
	  p = p->p_link;
	}	

	p  = alr;
	Debug1( "\r\nAlr: " );
	while( p )
	{
	  Debug1( p->p_name );
	  Debug1( " " );
	  p = p->p_link;
	}	

	p  = tlr;
	Debug1( "\r\ntlr: " );
	while( p )
	{
	  Debug1( p->p_name );
	  Debug1( " " );
	  p = p->p_link;
	}
	
	Debug1( "\r\n" );	

}


/*	Do nothing rouine	*/

	VOID
donothing( VOID )
{

}


/*	Catch the signal and do nothing */

	VOID
catchsignal( ignore )
	WORD	ignore;
{
	WORD	i;

	for( i = 1; i < 31; i++ )
	{
	  if ( i != ignore )
	    Psignal( i, &donothing );
	}
}



	VOID
Ndebug( level, number )
	WORD	level;
	LONG	number;
{
	BYTE	buffer[14];

	lbintohex( number, buffer );
	Debug( level, buffer );
	Debug( level, "\r\n" );	
}

/*	Debug routine	*/

	VOID
Debug( level, str )
	WORD	level;
	BYTE	*str;
{
	if ( gl_debug >= level )
	{
	  while( *str )
	    trap13( 3, gl_port, *str++ );
	}
}

/*
 *	Convert system process id to
 *	aes's pd structure
 */

	PD
*systopd( i )
	WORD	i;
{
	REG PD	*p;

	p = plr;

	while( p )
	{
	  if ( i == p->p_sysid )
	    return( p );
	 
  	  p = p->p_thread;   	
	}

	return( (PD*)0 );
}


/*	Forker of process terminate	*/

	VOID
pdterm( ret )
	LONG	ret;
{
	PD	*p,**p1;

	Debug1( "Exit code is: " );
	Ndebug1( ret );

	if ( p = systopd( (WORD)(ret >> 16) ) )
	{
	  p->p_exitcode = (WORD)(ret & 0x0000FFFFL);
 
	  switch( p->p_state )
	  {
	    case PS_MWAIT:
	      Debug7( "Dead process on PS_MWAIT list\r\n" );
	      p1 = &nrl;
	      break;

	    case PS_READY:
	      Debug7( "Dead process on PS_READY list\r\n" );
	      p1 = &drl;
	      break;

	    case PS_BLOCKED:
	      Debug7( "Dead process on PS_BLOCKED list\r\n" );
	      p1 = &slr;	
	      break;

	    case PS_ZOMBIE:
	      Debug7( "Dead process on PS_ZOMBIE list\r\n" );
	      p1 = &rlr;
	      break;
		
	    case PS_ALLRUN:
	      Debug7( "Dead process on PS_ALLRUN list\r\n" );
	      p1 = &rlr;
	      break;

	    case PS_RUN:
	      Debug7( "Dead process on PS_RUN list\r\n" );
	      p1 = &rlr;
	      break;

	    case PS_NEW:
	      Debug7( "Dead process on PS_NEW list\r\n" );
	      p1 = &alr;
	      break;
	
	    default:
	      Debug1( "Error! Can't find the dead process\r\n" );
	      return;
	  }

	  Debug1( p->p_name );
	  Debug1( " signaled to terminate\r\n" );
	  if ( !unlink_pd( p1, p ) )
	  {
	    Debug1( "Pdterm unlink fails\r\n" );
	    showall();
	  }
	  else
	  {
	    p->p_state = PS_DEAD;
	    scheduler( p );
	  }
	}
}


/*	Process termination handler	*/

	VOID
sigchld( VOID )
{
	LONG	l;

	while( ( l = Pwait3( 1, 0x0L ) ) )
	{
	  if ( l < 0L )
	    break;
	  
	  if ( !forkq( ( WORD(*)())pdterm, l ) )
	  {
	    Debug1( "Fail to register terminate\r\n" );
	    break;
	  }
	}
}


/*	Process to be put on wait state	*/

	WORD
dsptch( p )
	PD	*p;
{
	WORD	ret;

	if ( p )
	{		/* some of the starting prcoess */
			/* may be either on rlr or alr	*/
	  if ( !( ret = unlink_pd( &rlr, p ) ) )
	    ret = unlink_pd( &alr, p );

	  if ( ret )
	  {
	    scheduler( p );
	    savestate();
	    return( 1 );
	  }
	  else
	  {
	    Debug1( "Dsptch unlink fails\r\n" );
	    showall();
	  }
	}

	return( 0 );
}



/*	Send messag to control manager	*/

	VOID
send_ctrl( p, type )
	REG PD		*p;
	WORD		type;
{
	WORD		buffer[8];				
					/* if it is a program		*/

	if ( ( scr_pd ) && ( p->p_state != PS_DEAD ) ) 
	{
	  buffer[0] = type;
	  buffer[1] = p->p_pid;		/* send message to control manager */
	  ap_rdwr( AQWRT, scr_pd->p_pid, EV_BUFSIZE, ( BYTE *)buffer );
	}
}


/*	Switch to next top window's process	*/
/*	Call by scheduler			*/

	VOID
swap_next( p, pterm )
	PD		*p;
	WORD		pterm;
{
	REG PD		*newp;
	WINDOW		*win;
	WORD		item,changed,chgback;

	changed = chgback = FALSE;

	/* if it owns the phanom winodw then close it first */

	if ( srchwp( phanwind )->cowner == p )
	{
	  wmclose( phanwind );
	  changed = TRUE;
	}

	if ( p == scr_pd )	/* if screen manager is exiting	*/	
	  return;		/* don't send message to itself */

	/* If the background owned by this process, 	*/
	/* then it needs to be redrawn			*/

	if ( gl_newid == p->p_pid )
	  chgback = TRUE;

				/* Menu bar must change	*/
	if ( ( gl_mnpid == p->p_pid ) || ( !gl_mnpid ) || changed )	
	{
	  win = wm_top();	/* search for next available app*/
	  while( win )
	  {			/* Skip the phanton window	*/
	    if ( win->handle != phanwind )
	    {  
	      newp = win->owner;

	      if ( ( newp != p ) && ( newp->p_mnaddr ) && ( !newp->p_sleep ) &&
		   ( newp->p_type & (AESAPP|AESSHELL) ) )
	        break;
	    }

	    if ( win->under != NIL )
	      win = srchwp( win->under );
	    else
	      win = (WINDOW*)0;
	  }

	  if ( !win )		/* if no window then set to ours*/
	  {
	    newp = scr_pd;	/* set to the screen manager	*/
				/* is the shell still alive?	*/
	    if ( ( shellpd ) && ( !shellpd->p_sleep ) ) 	
	    {			/* yes				*/
	      if ( ( shellpd != p ) && shellpd->p_mnaddr )
	        newp = shellpd;
	    }
	  }

	  if ( ( item = w_tophandle( newp ) ) != -1 )
/*	    wmset( item, WF_TOP, (GRECT*)0 ); CJG */
	    wmset( item, WF_TOP, (WORD*)0 );
	  else
	    openphanwind( newp );

	  gl_kbid = newp->p_pid;
	}
	else
	  newp = idtopd( gl_mnpid );
	
	if ( gl_mfid == p->p_pid )
	  gr_arrow( newp->p_pid );	/* Change back to arrow		*/

				/* get this process's top window*/
				/* if not on top then ask him to do so */
	set_desk( newp );	/* set the background screen owner */
				/* and pointer 			   */

/*	mn_bar( newp, TRUE|0x0100 );	*/
	send_ctrl( newp, 8 );	/* update the menu		*/

	if ( pterm )		/* process termination, let the	*/
	  send_ctrl( newp, 2 );	/* screen manager decides what  */
	else			/* to do			*/
	{
	  if ( chgback )
	    send_ctrl( newp, 3 );
	}
}


/*	Get any ready process from Not Ready to Ready	*/

	VOID
make_ready( VOID )
{
	REG PD	*p;

	if ( p = tlr )		/* terminating process list */
	{
	  if ( Pgetpid() == idtopd( aesid )->p_sysid )
	  {
	    unlink_pd( &tlr, p );
	    currpd = idtopd( aesid );
	    ps_term( p );
	  }
	}

	if ( p = alr )		/* start up process list	*/
	{
	  if ( ( !cpdid ) || ( cpdid == -1 ) ) 
	  {
	    cpdid = p->p_pid;			
	    alr = p->p_link;
	    scheduler( p );
	  }
	}

	if ( cpdid == -1 )	/* release the critical id	*/
	  cpdid = 0;

	if ( p = drl )		/* dsptch ready list	*/
	{
	  drl = p->p_link;	/* restore the state	*/	
	  p->p_state = p->p_prvstate;
	  if ( p->p_state != PS_DEAD )
	  {
	    scheduler( p );	/* link it to the ready list	*/
	    switchto( ( LONG )p );
	  }
	}
}


/*	Send a message to the AES	*/
/*	Receiver id should be 0		*/

	VOID	
sendmsg( d1, d0 )
	LONG	d0,d1;
{
	AES 	msg;
	WORD	id;
	PD	*p;

	if ( cpdid ) 		/* if there is a critcial process */ 
	{
	  id = ( WORD )Pgetpid( );
	  if ( p = systopd( id ) )
	  {
	    if ( !( p->p_type & AESSYSTEM ) )
	      while ( cpdid  && ( cpdid != p->p_pid ) )
	        Syield();
	  }
	}

	msg.aes_func = d0;
	msg.aes_blk  = d1;
	Pmsg( 2, 100L, &msg );	/* send message and wait	*/
}


/*	Put all the incoming event into fork queue	*/

	WORD
forkq( fcode,fdata )
	WORD		(*fcode)();
	LONG		fdata;
{
	REG FPD		*f;

	if ( fpcnt < NFORKS )		/* queue up a incoming event	*/
	{
	  f = &D.g_fpdx[fpt++];
					/* wrap pointer around	*/
	  if ( fpt == NFORKS )
	    fpt = 0;

	  f->f_code = fcode;
	  f->f_data = fdata;

	  fpcnt++;
	  return( TRUE );
	}

	return( FALSE );
}


/*	Unlink a process from a list	*/

	WORD
unlink_pd( list, p )
	PD	**list,*p;
{
	PD	*p1;

	if ( !( p1 = (*list) ) )
	  return( 0 );

	if ( p1 == p )
	  *list = p1->p_link;
	else
	{
	  while( p1 )
	  {
	    if ( p1->p_link == p )
	    {
	      p1->p_link = p->p_link;
	      break;
	    }
	    else
	      p1 = p1->p_link;
	  }

	  if ( !p1 )	/* not found */
	  {
	    Debug1( p->p_name );
	    Debug1( " not found in the unlink_pd. Pstate is " );	
	    Ndebug1( (LONG)p->p_state );
	    return( 0 );
	  }
	}

	p->p_link = (PD*)0;

	return( 1 );
}


/*	Link the process to the head of the list	*/

	VOID
link_head( list, p )
	PD	**list,*p;
{
	p->p_link = (*list) ? (*list) : (PD*)0;
 	*list = p;
}


/*	Link a process to the end of the list		*/
/*	This process must not link to another list	*/

	VOID
link_tail( list, p )
	PD		**list,*p;
{
	REG PD		*p1;

	if ( !( p1 = *list ) )		/* if the list is empty	*/
	  *list = p;			/* link it at the head	*/
	else
	{
	  while( p1 )			/* links it to the end	*/
	  {
	    if ( !p1->p_link )
	    {
	      p1->p_link = p;
	      break;
	    }
	    p1 = p1->p_link;	
	  }
	}
	
	p->p_link = (PD*)0;
}


/*	Process scheduler	*/

	VOID
scheduler( p )
	REG PD		*p;
{      
	if ( !p )	/* No process, better return	*/
	  return;
again:
	switch( p->p_state )
	{
	  case PS_MWAIT:
	    if ( p->p_prvstate == PS_ALLRUN )
	    {
	      p->p_prvstate = PS_RUN;		      
	      cpdid = -1;
	    }

	    if ( !( p->p_evwait & p->p_evflg ) )
	    {	
              p->p_link = nrl;		/* Put it to not ready list	*/
	      nrl = p;
	    }
	    else			/* ready to run	*/
	    {
	      p->p_state = p->p_prvstate;
 	      goto again;
	    }

	    break;		
	
	  case PS_BLOCKED:		/* waiting for screen sync	*/
	    if ( p->p_prvstate == PS_ALLRUN )
	      p->p_prvstate = PS_RUN;	/* switch its process state	*/
	
	    Debug7( p->p_name );
	    Debug7( " is blocked\r\n" );
	    link_tail( &slr, p );
	    if ( cpdid == p->p_pid )
	      cpdid = -1;

	    break;	

	  case PS_DEAD:		/* This is process is marked dead	*/
	    link_tail( &tlr, p );
	    break;

	  case PS_ZOMBIE:	/* This guy is sleeping	*/
	    link_head( &rlr, p );
	    break;
	
	/****************************************************************/
	/* Newly created process will start in PS_NEW mode and be put 	*/
	/* on alr list. When it is ready to move to rlr, the state will */
	/* be changed to PS_ALLRUN.					*/
	/* This mode will cause the program continue to run it until it */
	/* is sent into wait state					*/
	/****************************************************************/

	  case PS_NEW:			/* new process			*/
	    p->p_state = PS_ALLRUN;

	  case PS_ALLRUN:		/* accessories	all run		*/
	  case PS_CRITICAL:		/* critical section		*/
	  case PS_RUN:
	    link_head( &rlr, p );
	    break;

	}
}


/*	Process all the incoming events			*/
/*	All the events should be queued up in the	*/
/*	fork queue and event scheduler should execute	*/
/*	them one at a time				*/

	VOID
forker( VOID )
{
	REG FPD		*f;
/*	REG PD		*oldrl;*/
	REG LONG	amt;
	FPD		tempf;
/*	BYTE		*old;*/

	f = &tempf;

	while( fpcnt )
	{
	  fpcnt--;
	  tempf = D.g_fpdx[fph++];
	  if ( fph == NFORKS ) 
	    fph = 0;
					/* see if recording	*/
	  if ( gl_recd )
	  {
					/* check for stop key	*/
	    if ( (f->f_code == ( WORD(*)())&kchange) &&
	         ((f->f_data & 0xffff0000L) == KEYSTOP) )
	      gl_recd = FALSE;
						/* if still recording	*/
						/*   then handle event	*/
	    if (gl_recd)
	    {
						/* if its a time event &*/
						/*   previously recorded*/
						/*   was a time event	*/
						/*   then coalesce them	*/ 
						/*   else record the	*/
						/*   event		*/
	      if ( (f->f_code == ( WORD(*)())&tchange) &&
	           (LLGET(gl_rbuf - sizeof(FPD)) == ( LONG )&tchange) )
	      {
	        amt = f->f_data + LLGET(gl_rbuf-sizeof(LONG));
	        LLSET(gl_rbuf - sizeof(LONG), amt);	      
	      }
	      else
	      {
	        LBCOPY( ( BYTE *)gl_rbuf, ( BYTE *)f, sizeof(FPD));
	        gl_rbuf += sizeof(FPD);
	        gl_rlen--;
		gl_recd = gl_rlen;
	      }
	    }
	  }/* gl_recd */

	  (*f->f_code)(f->f_data);

	}/* fpcnt */
}


/*	Come back from aes function, now do something	*/

	VOID
wake_up( wakeup )
	WORD	wakeup;
{
	AES	msg;
	LONG	temp;

	if ( currpd )
	{
	  switch( currpd->p_state )
	  {
	    case PS_NEW:
	      Debug1( "Wake_up detects PS_NEW process\r\n" );
	      if ( !unlink_pd( &alr, currpd ) )
		Debug1( "wake_up unlink fails\r\n" );
	      scheduler( currpd );
	    case PS_ALLRUN:
	    case PS_ZOMBIE:
	    case PS_DEAD:
	    case PS_RUN:
	      if ( wakeup )
	      {
	        temp = (LONG)currpd->p_sysid;
	        temp |= 0xFFFF0000L;
	        Pmsg( 0x8001, temp, &msg );
	      }
    	      break;

	    default:
	      if ( currpd )
	      {
		Debug1( "Wake_up call unknown state process\r\n" );
	        if ( !unlink_pd( &rlr, currpd ) )
		  Debug1( "wake_up unknown state unlink fail\r\n" );
	        scheduler( currpd );
	      }
	   }
	}
}


/*
*	Check the incoming message
*	By the time this function is called, the process already 
*	start executing. If the process doesn't has a PD, we will
*	create one for him as long as his first call is ap_init
*	After the get_pd, we need to queue it to rlr right the way
*/

	PD
*chkmsg( mintid, aesblk )
	UWORD	mintid;
	LONG	aesblk;
{
	AES	msg;
	BYTE	name[60];
	WORD	*wptr;
	PD	*p;
	LONG	value;
	WORD	ret;
	BYTE	*ptr;

	if ( !( p = systopd( mintid ) ) )
	{			/* if the operation is not 	*/
				/* appl_init then ignore it	*/
	   wptr = ( WORD *)( *((LONG*)(aesblk)));
	   if ( *wptr != 10 )
	     goto g_2;
		
	   dos_dta( ( LONG )name );
	   ret = dos_sfirst( ( LONG )"U:\\proc\\*.*", 0 );
	      
	   while( ret )
	   {
	      ptr = scasb( &name[30], '.' );
	      asctobin( ptr + 1, &value );
	      if ( value == (LONG)( mintid ) )
		break;
	      else
		ret = dos_snext();
	   }		  
				/* allocate a process 	*/	
	   if ( ( ret ) && ( p = get_pd( &name[30], AESAPP ) ) )
	   {
	     p->p_sysid = mintid;
	     if ( !unlink_pd( &alr, p ) )
	 	Debug1( "Chkmsg unlink fails\r\n" );
	     scheduler( p );
	   }
	   else
	   {
g_2:	     value = (LONG)mintid;
	     value |= 0xFFFF0000L;
	     Pmsg( 0x8001, value, &msg );
	     p = (PD*)0;
	   }
	}

	return( p );
}


/*	This is the loop of the AES process 0		*/
/*	AES's main() calls this function and loops	*/
/*	forever. It wait for all the process to 	*/
/*	ask for AES function service			*/

	VOID
disp( VOID )
{
	AES		msg;

	while( TRUE )		/* keep looking for AES requests */
	{
	  if ( scr_exit ) 	/* screen manager exits?	*/
	  {			/* wait for coming back AES context */
	    if ( Pgetpid() == idtopd( aesid )->p_sysid )
	      break;
	  }

	  chkkbd();		/* poll the keyboard		*/
	  waitforaes();
	  forker();		/* execute all the fork process	*/

		  		/* if there are events still in the queue */
	  make_ready();		/* get ready to run process	*/	
	  releaes();
				/* check for AES request in the Pmsg */
	  if ( !(UWORD)(Pmsg( 0x8000, 100L, &msg ) ) )
	    toaes( msg.aes_func, msg.aes_blk, msg.aes_id );
	  			/* aes will not return to here	*/
	  Syield();
	}

	dispret();		/* jump back to geminit	*/
}



/*	Process termination handler...			*/
/*	Make sure to report to the process's parent 	*/
/*	about it exit code, clean up all the unfinished */
/*	events, make sure resolution change is OK	*/

	VOID
ps_term( p )
	PD	*p;
{
	WORD	i,ret;
	PD	*p1;
	EVB	*e;

	if ( p->p_pid == cpdid )	/* release the critical	*/
	{
	  Debug6( "Release cpd\r\n" );
	  cpdid = -1;			/* control		*/
	}

	if ( p->p_type & AESACC )
	  gl_dacnt--;			/* subtract accessory count	*/

	if ( p->p_type & AESSHELL )	/* default shell exit	*/
	{
	  shellpd = scr_pd;	
	  shellpd->p_type |= AESSHELL;	
	  shel_magic = 0x0L;
	}

					/* tell its parent exit code */
	if ( ( p->p_ppid ) && ( p->p_ppid != -1 ) )
	{
	  Debug6( "Send exit message to its parent\r\n" );
	  ap_sendmsg( CH_EXIT, p->p_ppid, p->p_pid, p->p_exitcode, 0, 0, 0 );
	}
	    
	if ( p->p_pid == reschid )
	  send_ctrl( idtopd( aesid ), 6 );

	p1 = plr;		/* clean up the search first pointer 	*/
				/* in all the processes' table	 	*/ 
	while( p1 )			
	{
	  if ( p1->p_spd == p )
	    p1->p_spd = p->p_thread; 
	
	  p1 = p1->p_thread;

	}

				/* 5/13/92	*/
	Debug6( "mn_free\r\n" );

	mn_free( p->p_pid );

	Debug6( "Close all the window of this process\r\n" );

	wm_clspd( p, FALSE );	/* close all the opened window	*/
	Debug1( "check window locking\r\n" );

	ch_wmlock( p, TRUE );	/* release window control	*/
	Debug6( "Swap to next process\r\n" );
	swap_next( p, TRUE );	/* send message to control mgr	*/

	Debug6( "Free all the write queue\r\n" );

	while ( e = p->p_qnq )	/* free up all the processes 	*/
	{			/* who are waiting to write	*/
	  e->e_flag |= NOCANCEL;
	  evremove( e, 0 );
	}  
	
	Debug6( "Cancel outstanding events\r\n" );
					/* cancel outstanding event	*/
	ret = acancel( p, p->p_evwait );

	Debug6( "Cancel outstanding bits\r\n" );

	i = 1;

	while( ret )
	{
	  if ( i & ret )
	  {
	    ret &= ~i;		/* cancel out the bit		*/	
	    x_eret( p, i );	/* cancel satisfied event	*/
	  }
	  i <<= 1;
	}

	Debug6( "Restore the mouse\r\n" );

	if ( p->p_mouse.moff )	/* restore mouse on/off		*/
	{
	  gl_moff -= p->p_mouse.moff;
	  if ( !gl_moff )
	  {
	    gl_moff = 1;
	    gsx_mon();	
	  }
	}

	if ( p == scr_pd )	/* screen manager exit	*/
	  scr_exit = TRUE;	/* exit the whole AES	*/
	else
	  free_pd( p );

	if ( shutdown )		/* if in shutdown mode */
	{
	  if ( shutpd == p )
	  {
	    Debug1( "Shutdown set to 0\r\n" );
	    shutdown = 0;
	    shutpd = (PD*)0;
	  }	
	  else
	  {
	    p = plr;
	    while( p )
	    {
	      if ( p->p_type & AESAPP )
	      {
	        if ( p != shutpd )
		  return;
	      }
	      p = p->p_thread;
	    }


	    /* We need to send the shutdown message to screen and let
	     * screen manager to send it back to the owner.The reason
	     * is to avoid the shutdown's caller to receiver the 
	     * message too soon thus the previous swapping calls which
	     * Gemdisp makes will become invalid when caller exit too soon
	     * and will screw up the system.
	     */	

	    if ( shutpd )	/* in the shutdown mode */
	    {			
	      if ( reschid )	/* res change process	*/
		send_ctrl( idtopd( reschid ), 7 );
	      else
	        send_ctrl( shutpd, 7 );

	      Debug6( "Send 3 done\r\n" );
	      shutdown = 0;
	      shutpd = (PD*)0;
	    }
	  }
	}
	
	Debug1( "Termination done\r\n" );
}
