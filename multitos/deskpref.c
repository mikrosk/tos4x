/*	DESKPREF.C		3/17/89	- 6/15/89	Derek Mui	*/
/*	Change at set color and pattern	6/29/90		D.Mui		*/ 
/*	Use m_st to determine the resolution	9/19/90	D.Mui		*/

/************************************************************************/
/*	New Desktop for Atari ST/TT Computer				*/
/*	Atari Corp							*/
/*	Copyright 1989,1990 	All Rights Reserved			*/
/************************************************************************/

#include <portab.h>
#include <deskobde.h>
#include <deskdefi.h>
#include <deskwin.h>
#include <gemdefs.h>
#include <osbind.h>
#include <deskusa.h>
#include <extern.h>

EXTERN	OBJECT	*get_tree();
EXTERN	WINDOW	*w_gfirst();
EXTERN	WINDOW	*w_gnext();
EXTERN	BYTE	*get_string();

EXTERN	WORD	d_maxcolor;


	WORD
desk_chres( res, mode )
	WORD	res,mode;
{
	WORD	ret;

	if ( !mode )
	  res = res_handle( res );

	if ( !( ret = shel_write( 5, res, mode, 0x0L, 0x0L ) ) )
#if 0
	  form_alert( 1, "[1][ Can't do resolution change ][ OK ]" );
#else
	  do1_alert( NORESCHG ); /* ++ERS 12/16/92 */
#endif
	return( ret );
}


 
/*	Set Color and pattern	*/ 

	VOID
col_pa_pref( )
{
	REG OBJECT	*obj;
	REG WORD	ret;
	REG WINDOW	*win;
	LONG		newwin;
	LONG		newdesk;
	LONG		*outpat;
	WORD		last,i,j;
	
	obj = get_tree( SSCREEN );

	newdesk = background[0].ob_spec;
	newwin = (UWORD)windspec;
					/* set the background pattern */
	last = ret = obj[DESKPREF].ob_state & SELECTED ? DESKPREF : WINPREF;

	for ( j = COLOR0,i = d_maxcolor; i < 16; i++ )
	  obj[j+i].ob_flags |= HIDETREE;	

	dr_dial_w( SSCREEN, FALSE );

	goto c_1;
	
	while( TRUE )
	{
	  ret = xform_do( obj, 0 );
c_1:
	  if ( ret == SOK )
	    break;

	  if ( ret == SCANCEL )
	  {
	    do_finish( SSCREEN );
	    return;
	  }

	  if ( ret == DESKPREF )
	  {
	    outpat = &newdesk;
	    obj[DESKPREF].ob_state = SELECTED;
	    obj[WINPREF].ob_state = NORMAL;
	    goto c_2;
	  }
		    
	  if ( ret == WINPREF )
	  {
	    outpat = &newwin;
	    obj[WINPREF].ob_state = SELECTED;
	    obj[DESKPREF].ob_state = NORMAL;
c_2:
	    draw_fld( obj, DESKPREF );
	    draw_fld( obj, WINPREF );
	    obj[PATTERN].ob_spec = *outpat;
	  }

	  if ( ( ret >= PAT0 ) && ( ret <= PAT7 ) )
	  {
	    obj[PATTERN].ob_spec &= 0xFFFFFF0FL;
	    obj[PATTERN].ob_spec |= obj[ret].ob_spec & 0x000000F0L;	
	  }
	  else				/* color changed	*/
	  if ( ( ret >= COLOR0 ) && ( ret <= COLOR15 ) )
	  {
	    obj[PATTERN].ob_spec &= 0xFFFFFFF0L;
	    obj[PATTERN].ob_spec |= obj[ret].ob_spec & 0x0000000FL;
	  }

	  m_objdraw( obj, OUTBOX, 2, 0, 0, full.w, full.h );
	  *outpat = obj[PATTERN].ob_spec;

	}/* while */

	do_finish( SSCREEN );

	if ( background[0].ob_spec != newdesk )
	{
	  background[0].ob_spec = newdesk;
	  do_redraw( 0, &full, 0 );
	}

	win = winhead;

	if ( windspec != (UWORD)newwin )
	{
	  windspec = (UWORD)newwin;
	  while( win )
	  {
	    if ( win->w_obj )	/* fixed 6/24/92 */	
	      win->w_obj[0].ob_spec = windspec;
	    win = win->w_next;
	  }

	  win = w_gfirst();
	  while( win )
	  {
	    do_redraw( win->w_id, &full, 0 );
	    win = w_gnext();
	  }
	}
}
