/*	DESKBUTT.C		3/16/89 - 3/22/89	Derek Mui	*/
/*	Foption( win )		9/14/89			D.Mui		*/

/************************************************************************/
/*	New Desktop for Atari ST/TT Computer				*/
/*	Atari Corp							*/
/*	Copyright 1989,1990 	All Rights Reserved			*/
/************************************************************************/

#include "portab.h"
#include "obdefs.h"
#include "deskdefi.h"
#include "deskwin.h"
#include "windlib.h"
#include "deskusa.h"
#include "osbind.h"
#include "extern.h"
#include "pdesk.h"
#include "pmisc.h"

EXTERN	WORD	d_multi;
EXTERN	WORD	desk_id;
EXTERN	WINDOW	*get_win();
EXTERN	WINDOW	*get_top();
EXTERN	DIR	*get_dir();
EXTERN	WINDOW	*x_win;

/*	Find an empty icon	*/

WORD
av_icon( VOID )
{
	REG WORD	i,k;
	REG OBJECT	*obj;
	WORD		x,y,col,row;
	WORD		xcol,xrow,found;

	obj = background;

	for ( i = 1; i <= maxicon; i++ )
	{
	  if ( obj[i].ob_flags & HIDETREE )
	  {
	    k = i;
	    col = full.g_w / r_dicon.g_w;
	    row = full.g_h / r_dicon.g_h;

	    for ( xrow = 0; xrow < row; xrow++ )
	    {
	      for ( xcol = 0; xcol < col; xcol++ )
	      {
	        found = FALSE;
	        app_posicon( xcol, xrow, &x, &y );

	        for ( i = 1; i <= maxicon; i++ )
	        {
	          if ( !( obj[i].ob_flags & HIDETREE ) )
	          {
		    if ( ( obj[i].ob_x == x ) && ( obj[i].ob_y == y ) )
		    {
		      found = TRUE;
		      break;
		    }
	          }
	        }

	        if ( !found )
	          goto av_1;
	      }
  	    } 
av_1:
	    backid[k].i_path = (BYTE*)0;
	    obj[k].ob_flags = NONE;
	    obj[k].ob_state = NORMAL;
	    obj[k].ob_x = x;
	    obj[k].ob_y = y;
	    return( k );
	  }
 	}

	return( -1 );
}


/*	Deselect all the disk and trash icons	*/

VOID
clr_dicons( VOID )
{
	GRECT		pt;
	REG OBJECT	*obj;
	WORD		i;

	obj = background;

	if ( build_rect( obj, &pt, d_xywh[6], d_xywh[9] ) )
	{
	  for ( i = 1; i <= obj[0].ob_tail; i++ )
	    obj[i].ob_state = NORMAL;	

	  do_redraw( 0, &pt, 0 );
	}	

}


/*	Handle the click event		*/

VOID
hd_button( WORD clicks, WORD kstate, WORD mx, WORD my )
{
	REG WORD	item;
	WORD		xitem,type,keypress,state;
	REG OBJECT	*obj;
	REG WINDOW	*win;
	WINDOW		*win1;

	wind_get( 0, WF_OWNER, &type, &xitem, &xitem, &xitem );

	if ( type != desk_id )
	  return;
				/* click on any objects	*/

	if ( ( kstate != K_RSHIFT ) && ( kstate != K_LSHIFT ) )
	  keypress = FALSE;
	else
	  keypress = TRUE;

	if ( i_find( mx, my, &win1, &xitem, &type ) )
	{
	   item = xitem;
	   win = win1;

	   if ( type == WINICON )	/* window objects	*/
	   {
	     clr_dicons( );		/* clean up desktop icons */

	     if ( ( x_win ) && ( x_win != win ) )
	       clr_xwin( x_win, TRUE );

	     if ( !item )		/* hit nothing		*/
	     {
	       if ( !keypress )		/* shift key down?	*/
		clr_xwin( win, FALSE );
		
	       r_box( win->w_id, win );
	       winfo( win );
	       return;
	     }
	     else			/* hit something	*/
	     {
	       obj = win->w_obj;	
	       state = obj[item].ob_state;  /* JTT - changed from ob_states */

	       if ( ( state & SELECTED ) && ( !keypress ) )
	  	  goto a_1;
 
	       if ( !keypress )
	       {
	         clr_xwin( win, FALSE );
	         state = SELECTED;
	       }
	       else
	         state ^= SELECTED;

	       obj[item].ob_state = state;
	       get_dir( win, item )->d_state = state;
	       do_redraw( win->w_id, &full, item );
	       winfo( win );
	     }
	  }
	  else				/* desktop icon selected 	*/
	  {
	    clr_allwin( );

	    if ( !item )		/* hit background		*/
	    {
	      if ( !keypress )		/* clean up all the disk icons	*/	
	        clr_dicons( );	
		
	      r_box( 0, (WINDOW*)0 );
	      return;
	    }
	    else
	    {
	      obj = background;
	      state = obj[item].ob_state;

	      if ( ( state & SELECTED ) && ( !keypress ) )
	         goto a_1;	
	    
	      if ( !keypress )
	      {
	        state = SELECTED;
	        clr_dicons();
	      }
	      else
	        state ^= SELECTED;

	      obj[item].ob_state = state; 
	      do_redraw( 0, &full, item );
	    }
	  }
a_1:
	  o_select();			/* update the search routine	*/
	  x_select();

	  if ( clicks == 2 ) {		/* double clicks	*/
	    if (!d_multi)	/* maybe not only in single tasking mode??? */
	    	clr_allwin();
	    open_item( item, type, win );
	  } else				/* button still down	*/
 	    hd_down( item, type, win );

	}/* nothing is found	*/
}
