/*	GEMMNLIB.C	04/26/84 - 04/05/85	Lowell Webster		*/
/*	Reg Opt		03/08/85 - 03/09/85	Derek Mui		*/
/*	At mn_do, added the ctlmouse	3/4/86	Derek Mui		*/
/*	Fix at mn_do			3/5/86	Derek Mui		*/
/*	Fix at mn_do for disabled menu bar	6/11/86	Derek Mui	*/
/*	Change at mn_bar to do a dsptch		3/10/88	D.Mui		*/
/*	Fix at mn_bar again so it won't lose click 6/25/90	D.Mui	*/
/*	Change at mn_clsda			10/2/90		D.Mui	*/
/*	Change at mn_bar and new routine mn_iadd 2/22/91	D.Mui	*/

/*	Sub menu and pop-up menu is written by Cary Gee
*	-----------------------------------------------------------
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

#include <compiler.h>
#include <machine.h>
#include <pdstruct.h>
#include <dispvars.h>
#include <obdefs.h>
#include <objaddr.h>
#include <windlib.h>
#include <gemlib.h>
#include <aesmint.h>
#include <signal.h>

EXTERN	WINDOW	*wm_top();
EXTERN	WORD	set_desk();
EXTERN	BYTE	*dos_xalloc();
EXTERN	VOID	bb_restore();
EXTERN	VOID	bb_save();
EXTERN	WORD	ev_multi();
EXTERN	WORD	ob_find();
EXTERN	VOID	ob_draw();
EXTERN	VOID	ob_change();
EXTERN	VOID	ob_actxywh();
EXTERN 	PD	*idtopd();

EXTERN	WORD	deskwind;
EXTERN	GRECT	gl_rfull;
EXTERN	WORD	gl_kbid;
EXTERN 	WORD	gl_width;
EXTERN 	WORD	gl_hbox;
EXTERN 	GRECT	gl_rzero;
EXTERN 	GRECT	gl_rmenu;
EXTERN 	WORD	gl_hchar;
EXTERN 	PD	*scr_pd;
EXTERN 	PD	*plr;
EXTERN	OBJECT	*gl_newdesk;
EXTERN	WORD	gl_newroot;

GLOBAL	WORD	gl_mnpid;	/* menu owner id		*/
GLOBAL  MOBLK	gl_ctwait;
GLOBAL 	LONG	gl_mntree;	/* current menu tree address	*/
GLOBAL 	GRECT	gl_rmnactv;	/* current menu active rectangle*/
GLOBAL 	WORD	gl_dacnt;	/* menu register ID count	*/
GLOBAL 	WORD	gl_dabase;	/* starting obj # of accessory and prg	*/	
GLOBAL 	WORD	gl_cdabox;	/* obj # of the acc menu box	*/
GLOBAL 	OBJECT	*mn_addr;	/* current new menu address	*/
GLOBAL 	WORD	mn_maxitem;	/* maximum number of menu item	*/
GLOBAL	WORD	gl_accid;	/* accessory id number count	*/


OBJECT  w_b1[] = { -1, -1, -1, G_BOX, NONE, NORMAL, 0xFF1100L, 2, 0, 20, 8 };
OBJECT	w_b2[] = { -1, -1, -1, G_STRING, NONE, NORMAL, "--------------------",
		    0,  1, 20, 1 };


/*	Add a menu item string and return obj number	*/

	WORD
mn_iadd( string, state )
	BYTE	*string;
	WORD	state;
{
	REG OBJECT	*obj;
	REG WORD	item;

	obj = mn_addr;		/* get the menu address	*/
	item = obj->ob_tail;

	if ( item == -1 )	/* this tree has no children yet*/
	  item = 1;
	else
	  item = item + 1;		/* get the next obj	*/
				
	if ( item > mn_maxitem )	/* too many item	*/
	  return( -1 );

	LBCOPY( &obj[item], w_b2, sizeof( OBJECT ) );
	rs_obfix( obj, item );
	ob_add( mn_addr, 0, item );		/* link the object	*/
	obj[item].ob_y = gl_hchar * ( item - 1 );
	obj[item].ob_width = obj[0].ob_width;	/* set the correct width*/
	obj[item].ob_spec = string;		/* set the pointer	*/
	obj[item].ob_state = state;
	obj[0].ob_height = item * gl_hchar;	/* set the box height	*/
	return( item );
}



/*	Allocate memory and patch the current menu	*/

	VOID
mn_create()
{
	GRECT		pc;

	gl_mnpid = 0;
					
	wm_get( 0, WF_WXYWH, &pc );	/* get the working size	*/
					/* max obj item		*/	
	mn_maxitem = pc.g_h / gl_hchar;	
				/* total memory needs including box	*/
	mn_addr = dos_xalloc( (LONG)( ( mn_maxitem + 1 ) * sizeof( OBJECT ) ), 3 );

	LBCOPY( mn_addr, w_b1, sizeof ( OBJECT ) );/* outside box	*/

				/* clear the menu area		*/	
	rc_copy( &gl_rmenu, &gl_ctwait.m_x );
	gl_ctwait.m_out = FALSE;

}



/*
*	Routine to display the menu bar.  Clipping is turned completely
*	off so that this operation will be as fast as possible.  The
*	global variable gl_mntree which is used in CTLMGR88.C is also
*	set or reset.
*	
*	If showit's 0x0100 is set, the tree is actually the PD address,
*	If 0x0200 is set, then update the current menu
*/

	WORD
mn_bar( tree, showit )
	LONG		tree;
	WORD		showit;
{
	REG WORD	i,j;
	OBJECT		*temp;
	REG OBJECT	*obj;
	WORD		addline,change;
	PD		*p1,*p;
	WINDOW		*win;

	if ( showit == -1 )	/* inquire the menu owner */
	   return( ( gl_mnpid ) ? gl_mnpid : -1 );

	p1 = currpd;

	if ( showit == 1 )	/* showit == 1 ? */
	{			/* don't update if you don't own the top window */
	  currpd->p_mnaddr = tree;	
	  if ( win = wm_top() )
	  {
	    if ( ( win->cowner != currpd ) && ( win->handle != deskwind ) )
	      return (FALSE);
	  }
	  else
	    return (FALSE);

	  send_ctrl( currpd, 8 );
	  return( TRUE );			
	}

	if ( !showit )
	{
	  send_ctrl( currpd, 9 );
	  return( TRUE );
	}

	if ( showit & 0x0200 )	/* update the current menu */
	{
	  if ( !gl_mnpid ) 
	    return( FALSE );
	  p1 = idtopd( gl_mnpid );
	  tree = p1->p_mnaddr;		
	  showit &= ~0x0200;	
	}

	if ( showit & 0x0100 )	/* set a new menu bar	*/
	{
	  p1 = (PD*)tree;
	  tree = p1->p_mnaddr;
	  showit &= ~0x0100;
	}

	if ( showit == 1 )
	{
	  if ( !tree )
	  {
	    Debug1( p1->p_name );
	    Debug1( " has no menu bar\r\n" );
	    return( FALSE );
	  }

	  change = ( gl_mnpid != p1->p_pid ) ? TRUE : FALSE;
	
	  gl_mnpid = p1->p_pid;
	  obj = mn_addr;		/* patch object pointer		*/

	  p1->p_mnaddr = temp = gl_mntree = tree;

	  Debug1( p1->p_name );
	  Debug1( "set menu bar at MN_BAR\r\n" );

	  w_nilit( 1, mn_addr );	/* reset menu box		*/	
	  				/* change the waiting rectangle	*/

	  ob_actxywh(tree, THEACTIVE, &gl_rmnactv);
	  ch_wrect( &gl_ctwait.m_x, &gl_rmnactv );
	  				/* copy into AES wait rectangle	*/
	  rc_copy( &gl_rmnactv, &gl_ctwait.m_x );
					/* old menu box obj number	*/
	  gl_cdabox = LWGET(OB_HEAD(THEMENUS));
					/* copy into the new menu	*/
	  ob_offset( tree, gl_cdabox, &obj[0].ob_x, &obj[0].ob_y );
					/* copy the old box's width 	*/
					/* into the new menu		*/
	  obj[0].ob_width = temp[gl_cdabox].ob_width;
					/* add the program info line	*/
	  mn_iadd( temp[gl_cdabox+1].ob_spec, temp[gl_cdabox+1].ob_state );
					/* if there is accessory then	*/
	  if ( gl_dacnt )		/* add disabled line		*/
	  {
	    i = mn_iadd( temp[gl_cdabox+2].ob_spec, DISABLED );
	    obj[i].ob_type = temp[gl_cdabox+2].ob_type;
 	  }

	  gl_dabase = 3;		/* gl_dabase should == 3	*/

	  for( i = 0; i < gl_accid; i++ )
	  {
	    if ( ( j = facc( i ) ) != -1 )
	    {
	      p1 = idtopd( j );
	      p1->p_mobj = mn_iadd( p1->p_acname, NORMAL );
	    }
	  }

	  addline = FALSE;

	  p1 = plr;			/* Look for all the programs	*/

	  while ( p1 )			/* and stuff it into the menu	*/
	  {
	    if ( p1->p_state != PS_DEAD )
	    {
	      if ( p1->p_type & (AESAPP|AESSHELL) )
	      {
		if ( !addline )
		{
		  addline = TRUE;
	  	  i = mn_iadd( temp[gl_cdabox+2].ob_spec, DISABLED );
	  	  obj[i].ob_type = temp[gl_cdabox+2].ob_type;
	        }
	        p1->p_mobj = mn_iadd( p1->p_prgname, NORMAL );
	      }

		/* check the app name who owns the menu */

	      if ( ( p1->p_pid == gl_kbid ) && ( p1->p_mobj != -1 ) )
		obj[p1->p_mobj].ob_state |= CHECKED;
	    }
 
	    p1 = p1->p_thread;		    
	  }

	  gsx_sclip( &gl_rmenu );
	  ob_draw( tree, THEBAR, MAX_DEPTH );
	  gsx_attr( FALSE, MD_REPLACE, BLACK );	/* not xor mode!	*/
	  gsx_cline( 0, gl_hbox - 1, gl_width - 1, gl_hbox - 1 );
	  
	  p = idtopd( gl_mnpid );

	  if ( ( change ) || ( p->p_newdesk != gl_newdesk ) )
	  {
	    if ( set_desk( p ) )
	      dk_redraw( gl_newdesk, gl_newroot, &gl_rfull );
	  }
	}
	else
	{
	  if ( p1->p_pid == gl_mnpid ) 	/* if it owns the menu */
	  {	
	    gl_mntree = 0x0L;			/* change the waiting rect */
	    ch_wrect( &gl_ctwait.m_x, &gl_rmenu );
						/* wait for no menu bar	*/
	    rc_copy( &gl_rmenu, &gl_ctwait.m_x );
	    gl_mnpid = 0;
	    Debug1( currpd->p_name );
	    Debug1( " mn_bar 0\r\n" );
	  }
	}

	return( TRUE );
}



/*
*	Routine to register a desk accessory item on the menu bar.
*	The return value is the object index of the menu item that
*	was added.
*/

	WORD
mn_register(pid, pstr)
	REG WORD	pid;
	BYTE		*pstr;
{
	WORD		ret;

	ret = TRUE;

	if ( pid == -1 )		/* rename process's name */
	  p_nameit( currpd, pstr );
	else
	{				/* rename the name in the menu */
	  if ( currpd->p_type & AESACC )
	  {
	    currpd->p_accid = gl_accid++;
	    LBCOPY( currpd->p_acname, pstr, 20 );	
/*	    strcpy( pstr, currpd->p_acname );	*/
	    gl_dacnt++;
	    ret = gl_accid - 1;
	  }
	  else
	    strcpy( pstr, &currpd->p_prgname[0] );

	  send_ctrl( currpd, 5 );
	}

	return( ret );
}	
	


/*	Change the waiting rectangle for new menu bar	*/

	VOID
ch_wrect( r, n )
	GRECT		*r;	/* old rect */
	GRECT		*n;	/* new rect */
{
	PD		*p;	
	REG EVB		*e;
	WORD		*p1,*p2;

	p = scr_pd;

	for ( e = p->p_cda.c_msleep; e ; e = e->e_link )
	{
	  p1 = &e->e_parm;
	  p2 = &e->e_return;

	  if ( ( r->g_x == p1[0] ) && 
	       ( r->g_y == p1[1] ) && 
	       ( r->g_w == p2[0] ) && 
	       ( r->g_h == p2[1] ) )
	  {
	    e->e_parm = HW(n->g_x) + n->g_y;
	    e->e_return = HW(n->g_w) + n->g_h;	  
	  }
	}
}

