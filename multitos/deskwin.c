/*	DESKWIN.C		3/16/89	- 6/15/89 	Derek Mui	*/
/*	Take out vdi_handle	6/28/89					*/
/*	Put in error checking for window memory allocating 9/24/89	*/
/*	Add up_1allwin		11/14/90		D.Mui		*/
/*	Add up_2allwin		4/18/91			D.Mui		*/
/*	Fix at view_adjust for vertical slide box's size 7/9/91	D.Mui	*/
/*	Add a blt loop		9/26/91			D.Mui		*/
/*	Add a draw_loop for background window 9/27/91	D.Mui		*/
/*	New function for blitting windows	7/7/92	D.Mui		*/
/*	Codes written by Je We						*/
/*	Change all the iconblk to ciconblk	7/11/92	D.Mui		*/
/*	Change w_iblk to w_ciblk	7/11/92		D.Mui		*/
/*	Handling for iconified windows added 5/04/93	H.Krober	*/

/************************************************************************/
/*	New Desktop for Atari ST/TT Computer				*/
/*	Atari Corp							*/
/*	Copyright 1989,1990 	All Rights Reserved			*/
/************************************************************************/

#include "portab.h"
#include "machine.h"
#include "obdefs.h"
#include "deskdefi.h"
#include "deskwin.h"
#include "osbind.h"
#include "message.h"
#include "deskusa.h"
#include "extern.h"
#include "error.h"
#include "pdesk.h"
#include "pmisc.h"

EXTERN	WORD	desk_id;

MLOCAL	VOID	srl_row();
MLOCAL	VOID	srl_col();
MLOCAL	VOID	do_redraw();

GRECT	sizes[] = { 150, 150, 150, 150 };
OBJECT	blank[] = { -1, -1, -1, G_BOX, NONE, NORMAL, 0x000000F0L, 0, 0, 0, 0 };


	VOID
draw_loop( handle, obj, start, depth, x, y, w, h )
	WORD	handle,start,depth,x,y,w,h;
	OBJECT	*obj;
{
	GRECT	pt,px;

	wind_update(1);
	desk_mice( M_OFF );

	if ( !handle )		/* if background window */
	{
	  wind_get( handle, WF_OWNER, &pt.g_x, &pt.g_y, &pt.g_w, &pt.g_h );
	  if ( pt.g_x != desk_id )
	    goto d_l1;
	}
	
	if ( handle == -1 )
	{
	  objc_draw( (LONG)obj, start, depth, x, y, w, h );
	  goto d_l1;
	}

	px.g_x = x;
	px.g_y = y;
	px.g_w = w;
	px.g_h = h;

	wind_get( handle, WF_FIRSTXYWH, &pt.g_x, &pt.g_y, &pt.g_w, &pt.g_h );
	
	while( pt.g_w && pt.g_h )
	{
	  if ( rc_intersect( &px, &pt ) )
	    objc_draw( (LONG)obj, start, depth, pt.g_x, pt.g_y, pt.g_w, pt.g_h );

	  wind_get( handle, WF_NEXTXYWH, &pt.g_x, &pt.g_y, &pt.g_w, &pt.g_h );
	}
d_l1:
	desk_mice( M_ON );
	wind_update( 0 );
}

		 

/*	Update the window info line	*/

	VOID
winfo( win )
	WINDOW	*win;
{
	REG WORD	i;
	REG DIR		*dir;
	UWORD		j;
	LONG		sizes;
	LONG		sizes1;
	BYTE		buffer[14];
	BYTE		*type;
	WORD		temp1, temp2;

	dir = (DIR *) win->w_memory;
	j = 0;
	sizes = 0;
	sizes1 = 0;

	for ( i = 0; i < win->w_items; i++ )
	{
	  sizes += dir[i].d_size; 
	  if ( dir[i].d_state & SELECTED )
	  {
	    sizes1 += dir[i].d_size;
	    j++;
	  }
	}

	if ( j )		/* some items are selected	*/
	{
	  *( (LONG *) &buffer[0] ) = sizes1;
	  *( (WORD *) &buffer[4] ) = j;
	  type = get_fstring( ( j == 1 ) ? ISEL : ISELS );
	}
	else
	{
	  *( (LONG *) &buffer[0] ) = sizes;
	  *( (WORD *) &buffer[4] ) = (WORD)win->w_items;
	  type = get_fstring( ( win->w_items == 1 ) ? ISTR : ISTRS );
	}

	merge_str( win->w_info, type, (UWORD *)buffer );
	temp1 = (WORD) ( (LONG) win->w_info >> 16L );
	temp2 = (WORD) ((LONG) win->w_info & 0x0000FFFFL);
	wind_set( win->w_id, WF_INFO, temp1, temp2, 0, 0 );	
}


	WINDOW
*w_gnext()
{
	WINDOW 	*win;

	while( ww_win )
	{
	  win = ww_win;
	  ww_win = (WINDOW *) ww_win->w_next;	  
	  if ( win->w_id != -1 )
	    return( win );
	}

 	return( (WINDOW*)0 );
}

	WINDOW
*w_gfirst()
{
	ww_win = winhead;
	return( w_gnext() );
}



/*	Update all the windows, change dir path if fails	*/

	VOID
up_2allwin( path )
	BYTE	path[];
{
	REG WINDOW	*win;

	win = w_gfirst();
	
	while ( win )
	{
	  if ( path[0] == win->w_path[0] )
	  {
	    if ( !open_subdir( win, 0, FALSE, FALSE, TRUE ) )
	    {
	      strcpy( wilds, &win->w_path[2] );
	      open_subdir( win, 0, FALSE, FALSE, TRUE );
	    }
	  }

	  win = w_gnext();
	}
}


/*	Update all the windows					*/
/*	If the path has nothing, then update all the windows	*/

	VOID
up_1allwin( path, full, change )
	BYTE	path[];
	WORD	full;	/* compare full path	*/
	WORD	change;
{
	REG WINDOW	*win;

	win = w_gfirst();
	
	while ( win )
	{
	  if ( !path[0] )
	    goto uu_1;

	  if ( full )		/* compare the full path	*/
	  {
	    if ( strcmp( path, win->w_path ) )
	      goto uu_1;
	  }
	  else			/* just the id	*/	
	  {
	    if ( path[0] == win->w_path[0] )
	    {
uu_1:  	      if ( !up_win( win, change ) )
	      {
	        strcpy( wilds, &win->w_path[2] );
	        up_win( win, FALSE );
	      }
	    }
	  }

	  win = w_gnext();
	}
}


	VOID
up_allwin( path, full )
	BYTE	path[];
	WORD	full;
{
	up_1allwin( path, full, FALSE );
}
 


/* 	Do the actual update of a particular window	*/

	WORD
up_win( win, mediac )
	WINDOW	*win;
	WORD	mediac;
{
	BYTE	*ptr;
	/* BYTE	*old;	not used */
	WORD	ret;

	ptr = win->w_path;

	if ( ptr[0] != 'c' )
	{
	  if ( mediac )
	  {
/*	    desk_mice( HOURGLASS );	  */
	    if ( ret = hit_disk( (WORD)ptr[0] ) )
	    {
#if 0
	      old = Super( 0x0L );
	      mediach( (WORD)(ptr[0] - 'A') );
	      Super( old );
#endif
	    }
	      
/*	    desk_mice( ARROW );		*/

	    if ( !ret )
	      return( FALSE );
	  }
	}

	if ( !open_subdir( win, 0, FALSE, FALSE, TRUE ) )
	{
	  if ( ( mediac ) && ( ret ) )	/* it is force media change	*/
	  {
	    strcpy( wilds, &win->w_path[2] );
	    return( open_subdir( win, 0, FALSE, FALSE, TRUE ) );
 	  } else {
 	    return( FALSE );
 	  }	    
	}

	return( TRUE );
}


/*	Bring bottom window to top	*/

	VOID
bottop()
{
	REG WINDOW	*win;
	WINDOW	*win1;
	/* WORD	item;  		not used */
	WORD	buffer[8];

	if ( win = w_gfirst() )
	{
	  while( win )			/* get to the bottom one	*/
	  {
	    win1 = win;
	    win = w_gnext();
	  }	

	  if ( win1 != winhead )	/* stimulate a message call	*/
	  {
	    buffer[0] = WM_TOPPED;
	    buffer[3] = win1->w_id;
	    hd_window( buffer );
	  }
	}
}


/*	Allocate memory for window path	*/

	WORD
path_alloc( level )		/* requested level	*/
	WORD	level;
{
	WORD	oldlevel,wsize;
	LONG	size;
	REG WORD	i;
	REG BYTE	*addr;
	BYTE	*path;

	oldlevel = d_level;

	while( d_level <= level )
	{
	  d_level = d_level * 2;
	}

	wsize = ( 13 * ( d_level + 1 ) ) + 3;
	size = ( MAXWIN * 2 * (UWORD)wsize ) + 1;
	addr = path = malloc( size );
	
	if ( path )
	{
	  path3 = addr;
	  addr += wsize;
	
	  for ( i = 0; i < MAXWIN; i++ )
	  {
	    if ( winpd[i].w_path )
	      strcpy( winpd[i].w_path, addr );
	    else
	      *addr = 0;
	
	    winpd[i].w_path = addr;
	    addr += wsize;
	    winpd[i].w_buf = addr;
	    addr += wsize;
	    winpd[i].w_level = d_level;
	  }

	  free_path();

	  d_path = path;
	  return( TRUE );
	}
	else
	  do1_alert( FCNOMEM );
	
	d_level = oldlevel;	/* restore the old level	*/
	return( FALSE );
}


	VOID
free_path()
{
	if ( d_path )
	{
/*	  form_alert( 1, "[1][ Free Path Memory ][ OK ]" );	*/
	  free( d_path );
	  d_path = (BYTE*)0;
	}
}


/*	Clean up all the window		*/

	VOID
clr_allwin( )
{
	REG WINDOW	*win;

	win = w_gfirst();

	while( win )
	{
	  clr_xwin( win, TRUE );
	  win = w_gnext();
	}
}


/*	Clean up and dselect the window objects		*/

	VOID
clr_xwin( win, infoupdate )
	REG WINDOW	*win;
	WORD		infoupdate;
{
	OBJECT		*obj;
	REG WORD	i;
	WORD		change,ret;
	REG DIR		*dir;
	GRECT		pt;

	dir = (DIR *) win->w_memory;
	obj = win->w_obj;
	ret = build_rect( obj, &pt, obj[1].ob_width, obj[1].ob_height );
	change = FALSE;
	
	for( i = 0; i < win->w_items; i++ )
	{
	  if ( dir[i].d_state & SELECTED )
	  {
	    change = TRUE;
	    dir[i].d_state = NORMAL;
	  }
	}

	if ( change )
	{
	  set_newview( win->w_srtitem, win );
	  if ( ret )
	    do_redraw( win->w_id, &pt, 0 );
	}

	if ( change && infoupdate )
	  winfo( win );
}



/*	Move the vertical bar	*/

	VOID
srl_verbar( win, pos )
	REG WINDOW	*win;
	UWORD	pos;
{
	LONG	l;
	UWORD	i;
	WORD	diff,dir;

	l = (LONG)pos * (LONG)win->w_vvicons;
	i = (UWORD) (l / 1000L);	/* L added by hmk when changed to LC */

	if ( i == win->w_rowi )		/* No change	*/
	  return;

	diff = i - win->w_rowi;		/* Up or down	*/

	if ( diff < 0 )
	{
	  diff *= -1;
	  dir = SUP;
	}
	else
	  dir = SDOWN;
	  
	if ( diff < win->w_xrow )	/* less than one window	*/
	  srl_row( win, diff, dir );
	else
	{
	  win->w_rowi = i;
	  if ( win->w_vvicons )
	  {
	    l = 1000L * (LONG) win->w_rowi;
	    l = l / (LONG)win->w_vvicons;
	  }
	  else
	    l = 0L;
  
	  wind_set( win->w_id, WF_VSLIDE, (UWORD)l, 0, 0, 0 );	

	  win->w_obj->ob_y = win->w_work.g_y;	/* reset at the topmost	*/
	  win->w_srtitem = i * win->w_icol;
	  up_1( win );
	}
}


/*	Move the horizontal bar	*/

	VOID
srl_hzbar( win, pos )
	REG WINDOW	*win;
	UWORD	pos;
{
	LONG		l;
	UWORD		x,w;	
	REG OBJECT	*obj;
	REG WORD	diff,i;
	WORD		dir;

	l = (LONG)pos * (LONG)win->w_hvicons;
	i = (UWORD) (l / 1000L);  /* L added by hmk when changed to LC */
	
	if ( i == win->w_coli )
	  return;

	diff = i - win->w_coli;

	if ( diff < 0 )
	{
	  dir = SRIGHT;
	  diff *= -1;
	}
	else
	  dir = SLEFT;

	if ( diff < win->w_xcol )	/* less than one window	*/
	  srl_col( win, diff, dir );
	else
	{
	  win->w_coli = i;
	  if ( win->w_hvicons )
	  { 
	    l = 1000L * (LONG)win->w_coli;
	    l /= (LONG)win->w_hvicons;  
	  }
	  else
	    l = 0L;

	  wind_set( win->w_id, WF_HSLIDE, (UWORD)l, 0, 0, 0 );	

	  x = win->w_work.g_x;
	  w = win->w_work.g_w;

	  obj = win->w_obj;	
	  obj[0].ob_x = x;	/* reset at the leftmost	*/
	  obj[0].ob_width = w;
	  i = i * fobj.g_w;
	  obj[0].ob_x -= i;
	  obj[0].ob_width += i;
	  draw_loop( win->w_id, obj, 0, MAX_DEPTH, x, win->w_work.g_y,
		 w, win->w_work.g_h );	  
	}
}



/*	Scroll the content down		*/

	VOID
srl_row( win, row, dir )
	REG WINDOW	*win;
	WORD		row, dir;
{
	WORD		i;

	if ( dir == SDOWN )		/* scroll content dowm	*/
	{
	  i = win->w_vvicons - win->w_rowi;
	  if ( i )
	  {
	    if ( row > i )
	      row = i;

	    set_newview( win->w_srtitem + ( win->w_icol * row ), win );
	    blt_window( win, SDOWN, row );
	  }
	}
	else
	if ( win->w_rowi )		/* scroll content up	*/
	{
	  if ( ( win->w_rowi - row ) < 0 )
	    row = win->w_rowi;

	  set_newview( win->w_srtitem - ( win->w_icol * row ), win );	  
	  blt_window( win, SUP, row );
	}
}

	VOID
srl_col( win, col, dir )
	REG WINDOW	*win;
	REG WORD	col;
	WORD		dir;
{
	if ( dir == SRIGHT )		/* scroll content right	*/
	{
	  if ( win->w_coli > 0 )
	  {
	    if ( ( win->w_coli - col ) < 0 )
	      col = win->w_coli;

	    blt_window( win, SRIGHT, col );
	  }
	}
	else				/* scroll content left	*/
	if ( win->w_coli < win->w_hvicons )
	{
	  if ( ( win->w_coli + col ) > win->w_hvicons ) 
	    col = win->w_hvicons - win->w_coli;

	  blt_window( win, SLEFT, col );
	}
}


/*	Bitblt a window content either up, dowm, left or right	*/

	VOID
blt_window( win, mode, size )
	REG	WINDOW	*win;
	WORD	mode,size;
{
	REG 	OBJECT	*obj;
	REG 	WORD	x;
		LONG	l;
		WORD	block;
		UWORD	i;
		WORD	w = 0;	/* before changing to LC, 'w' was NOT */
				/* initalized. (02/16/92 hmk */
	/* NOT USED ANYMORE:
		WORD	y, e_x[12], y1, h, *ptr, top;
		LONG	trash;
		GRECT	pt;
	*/

	obj = win->w_obj;

	if ( ( mode == SUP ) || ( mode == SDOWN ) )
	{
	  i = size * win->w_icol;
	  block = obj[i].ob_height + obj[i].ob_y;

	  if ( mode == SUP )
	    win->w_rowi -= size;
	  else
	    win->w_rowi += size;

	  do_blit( win->w_id, &win->w_work, ( mode == SUP ) ? 0 : 1, block);
	  
	  if ( win->w_vvicons )
	  {
	    l = 1000L * (LONG)win->w_rowi;
	    l = l / (LONG)win->w_vvicons;  
	  }
	  else
	    l = 0L;

	  wind_set( win->w_id, WF_VSLIDE, (UWORD)(l), 0, 0, 0 );

	}
	else				/* scroll left or right		*/
	{
	  block = obj[size].ob_width + obj[size].ob_x;

	  if ( mode == SRIGHT )	
	  {
	    win->w_coli -= size;
	    obj[0].ob_x += block;
	    obj[0].ob_width -= block;
	  }
	  else
	  {
	    win->w_coli += size;
	    obj[0].ob_x -= block;
	    obj[0].ob_width += block;
	  }

	  if ( block > w )
	    x = win->w_work.g_x;
	  else
	    w = block + 1;

	  do_blit( win->w_id, &win->w_work, ( mode == SRIGHT ) ? 2 : 3, block );

	  if ( win->w_hvicons )
	  {
	    l = 1000L * (LONG)win->w_coli;
	    l /= (LONG)win->w_hvicons;
	  }
	  else
	    l = 0L;
  
	  wind_set( win->w_id, WF_HSLIDE, (UWORD)l, 0, 0, 0 );

	}

/*	desk_mice( M_ON );	*/
}


/*	Adjust everything inside the window because of window's */
/*	size has been changed or object type is changed		*/
/*	Adjust means we have to do recalculation		*/
/*	otherwise, pin down the left upper corner and just 	*/
/*	adjust the scroll bars					*/

	VOID  
view_adjust( win )
	REG WINDOW	*win;
{
	REG OBJECT	*obj;
	REG UWORD	x,col;
	UWORD	row;		/* must be unsigned	*/
	LONG	l;
	UWORD	i;

	obj = win->w_obj;

	/***  Figure out the vertical slide bar	***/

	x = win->w_items / win->w_icol;	/* number of row needed	*/

	if ( win->w_items % win->w_icol )
	  x++;

	if ( !x )			 /* at least one row	*/
	  x = 1;
	
	row = win->w_work.g_h / fobj.g_h; /* current visible number of row */

	win->w_xrow = row;

	win->w_vvicons = ( x < row ) ? 0 : ( x - row );

	if ( x > row )		/* if there is more need to be shown */	
	{
	  l = 1000L * (LONG)row;
	  i = (UWORD) (l / (LONG)x);
	}
	else
	  i = 1000;

	wind_set( win->w_id, WF_VSLSIZE, i, 0, 0, 0 );

	if ( win->w_rowi > win->w_vvicons )
	  win->w_rowi = win->w_vvicons;

	if ( !win->w_vvicons )
          i = 0;
	else
	{
	  l = 1000L * (LONG)win->w_rowi;
	  i = (UWORD) (l / (LONG)win->w_vvicons);
	}

	wind_set( win->w_id, WF_VSLIDE, i, 0, 0, 0 );

	/***    Figure the horizontal slide bar size	***/
	
	if ( win->w_icol <= 1 )
	  col = 1;
	else
	  col = win->w_work.g_w / fobj.g_w; /* current visible column	*/

	if ( !col )
	  col = 1;
	  
	x = ( win->w_items > win->w_icol ) ? win->w_icol : win->w_items;

	win->w_xcol = col;		/* current visible column	*/

	win->w_hvicons = ( x <= col ) ? 0 : ( x - col ) ;

	if ( !x )
	  i = 1000;
	else
	{
	  l = 1000L * (LONG)col;
	  i = (UWORD)(l / (LONG)x);
	}

	wind_set( win->w_id, WF_HSLSIZE, i, 0, 0, 0 );

	if ( win->w_coli > win->w_hvicons )
	  win->w_coli = win->w_hvicons;

	obj[0].ob_x = win->w_work.g_x;
	obj[0].ob_x -= ( win->w_coli * fobj.g_w );
	obj[0].ob_width = win->w_work.g_w;
	obj[0].ob_width += ( win->w_coli * fobj.g_w );

	if ( !win->w_hvicons )	/* fits all the file	*/
	  i = 0;
	else
	{
	  l = 1000L * (LONG)win->w_coli;
	  i = (UWORD)(l / (LONG)win->w_hvicons);
	}

	wind_set( win->w_id, WF_HSLIDE, i, 0, 0, 0 );
	set_newview( win->w_rowi * win->w_icol, win );		
}	


/*	Change the viewing mode, form text to icon or vice verse	*/

	VOID
sort_show( mode, view )
	WORD	mode,view;
{
	REG WINDOW	*win;

/*	desk_mice( HOURGLASS );	*/

	win = w_gfirst();

	while( win )
	{
	  if ( view )
	  {
	    view_fixmode( win );	/* change icon or text mode */
	    view_adjust( win );		/* view adjust will set new view ptr */
	    do_redraw( win->w_id, &full, 0 );
	  }			
	  else
	  {
	    sort_file( win, mode ); 
	    up_1( win );
	  }

	  win = w_gnext();
	}

/*	desk_mice( ARROW );	*/
}


/*	The viewing mode has been changed				*/
/*	Fix up the icon position according to largest window size	*/
/*	Call this routine before calling view_adjust!!!!!!!		*/
/*	It used the s_stofit flag to set the horizontal number of icon!	*/ 

	VOID
view_fixmode( win )
	WINDOW	*win;
{
	REG WORD	x,y,w,i,offx;
	WORD		h,limitw,limith;
	WORD		type,offy;
	WORD		len,col,row,doitc;
	CICONBLK	*iblk;
	BYTE		*text;
	REG OBJECT	*obj;
	OBJECT		*obj1;
	TEDINFO		*ted;

	obj = win->w_obj;

	if ( s_view == S_ICON )		/* icon mode	*/
	{
	  w = dicon.g_w;
	  h = dicon.g_h;			/* Change also at deskinf.c	*/ 
	  offx = ( gl_hchar == 8 ) ? gl_wchar / 2 : gl_wchar; 
	  offy = gl_hchar / 2;		
	  type = G_CICON;
	  iblk = win->w_ciblk;
	}
	else				/* text mode	*/
	{
	  obj1 = get_tree( TEXTLINE ); /* was TEXTLINES, changed by hmk for LC */
	  len = strlen( (BYTE *)( (TEDINFO*)(obj1[TSTYLE].ob_spec) )->te_ptext );	
	  w = ( len - 1 ) * gl_wchar;
	  h = gl_hchar;	  
	  offx = 3 * gl_wchar;
	  offy = 2;
	  type = G_TEXT;
	  text = win->w_text;
	  ted = win->w_ted;
	}

	fobj.g_w = w + offx; 
	fobj.g_h = h + offy;

	if ( s_stofit )		/* size to fit	*/
	  limitw = win->w_work.g_w;
	else
	  limitw = full.g_w - gl_wbox;

	limith = full.g_h - ( 3 * gl_hbox );

	x = offx;
	y = offy;

	col = 0;		/* min one col one row	*/
	row = 0;

	doitc = TRUE;

	for ( i = 1; i < ( win->w_maxicons + 1 ); i++ )
	{
	  obj[i].ob_type = type;
	  obj[i].ob_x = x;
	  obj[i].ob_y = y;
	  obj[i].ob_width = w;
	  obj[i].ob_height = h;
	  obj[i].ob_next = i+1;

	  if ( s_view == S_ICON )	/* icon mode	*/	  
            obj[i].ob_spec = (LONG) iblk++;
	  else
	  {
	    obj[i].ob_spec = (LONG) ted;
	    ted->te_ptext = (LONG) text;
	    text += len;
	    ted++;
	  }

	  col++;			/* one icon added	*/
	  x = x + w + offx;		/* point to next x pos	*/

	  if ( ( x + w ) > limitw )	/* off the edge?	*/
	  {
	    x = offx;			/* yes			*/
	    y = y + h + offy;
	    row++;
	    if ( doitc )
	    {
	      win->w_icol = col;	/* maximum col of icons	*/
	      doitc = FALSE;
	    }
	  }

	  if ( y >= limith )		/* At the bottom	*/
	    break;

	}/* for */

	win->w_irow = row;		/* maximum row of icons	*/

	/* Free up the rest of the icons	*/

	obj[0].ob_tail = i;
	obj[i].ob_next = 0;

	win->w_vicons = i;		/* maximum visible icons*/
}


/*	Make this window to be the top one	*/

	VOID
make_top( win )
	REG WINDOW	*win;
{
	REG WINDOW	*winptr;	

	if ( win )
	{
/*	  set_dir( win->w_path );	*/

	  if ( winhead == win )		/* already on top	*/
	    return;

	  winptr = winhead;

	  while( winptr )	
	  {
	    if ( winptr->w_next == (BYTE *) win )
	    {
	      winptr->w_next = win->w_next;
	      win->w_next = (BYTE *) winhead;
	      winhead = win;
	      break;	
	    }

	    winptr = (WINDOW *) winptr->w_next;
	  }
	}
}


/*	Allocate a window object	*/
	
	WORD
alloc_obj( mode, win )
	WORD	mode;
	REG WINDOW	*win;
{
	REG WORD	i,j;
	REG UWORD	item;
	REG OBJECT	*obj1,*obj2;
	WORD		len;
	CICONBLK	*iblk;
	TEDINFO		*ted;
	UWORD		k;
	LONG		size;
/* UNUSED:
	WORD		w, h;
*/
 	i = full.g_w / dicon.g_w;		
	if ( full.g_w % dicon.g_w )
	  i++;	 

	j = full.g_h / dicon.g_h;
	if ( full.g_h % dicon.g_h )
	  j++;	 
	  
	item = i * j;

	obj2 = get_tree( TEXTLINE ); /* was TEXTLINES, changed by hmk for LC */

 	i = full.g_w / obj2[TSTYLE].ob_width;		
	if ( full.g_w % obj2[TSTYLE].ob_width )
	  i++;	 

	j = full.g_h / obj2[TSTYLE].ob_height;
	if ( full.g_h % obj2[TSTYLE].ob_height )
	  j++;	 
	  
	k = i * j;

	if ( k > item )
	  item = k;	

	len = strlen ((BYTE *)( (TEDINFO*)(obj2[TSTYLE].ob_spec) )->te_ptext );

	size = 0L;
	size += (LONG)(( item + 1 ) * sizeof( OBJECT ) );
	size += (LONG)( item * len );
	size += (LONG)( item * sizeof( TEDINFO ) );
	size += (LONG)( item * sizeof( CICONBLK ) );

	if ( win->w_obj = (OBJECT *) malloc( size ) )
	{
	  obj1 = win->w_obj;

	  LBCOPY( (BYTE *)obj1++,(BYTE *)blank, sizeof( OBJECT ) );		

	  for( i = 0; i < item; i++ )	/* copy object structure */
	    LBCOPY( (BYTE *)obj1++,(BYTE *)&iconaddr[ICON1], sizeof( OBJECT ) );

	  win->w_ciblk = iblk = (CICONBLK *) obj1;

					/* start of the iconblk area	*/
	  for( i = 0; i < item; i++ )	/* copy icon structure		*/
	    LBCOPY( (BYTE *)iblk++,(BYTE *)iconaddr[ICON1].ob_spec, sizeof( CICONBLK ) );

	  win->w_ted = ted = (TEDINFO *) iblk;

	  for ( i = 0; i < item; i++ )
	    LBCOPY( (BYTE *)ted++,(BYTE *)obj2[TSTYLE].ob_spec, sizeof( TEDINFO ) );

	  win->w_text = (BYTE *) ted;		/* set the text pointer		*/

	  win->w_maxicons = (WORD) item;
	}
	else
	{	
	  win->w_maxicons = 0;
	  do1_alert( NOWINMEM );
	  return( FALSE );
	}
	
	/*
 	 *	allocate memory for objedct tree in iconified state
	 */
	size = 0L;
	size += (LONG)(2 * sizeof( OBJECT ) ); 	/* form + one icon */
	size += (LONG)( 128 ); 			/* buffer for file name */
	size += (LONG)(sizeof( CICONBLK ) );	/* the icon */
	if ( win->w_icnobj = (OBJECT *) malloc( size ) ) {
		obj1 = win->w_icnobj;

	 	LBCOPY( (BYTE *)obj1,(BYTE *)blank, sizeof( OBJECT ) );		
		obj1++;

	    	LBCOPY((BYTE*)obj1,(BYTE*)&iconaddr[ICON0], sizeof(OBJECT));
		obj1++;

		win->w_icnobj[1].ob_spec = (LONG) obj1;
		win->w_icnobj[1].ob_next = 0;
		win->w_icnobj[1].ob_head = -1;
		win->w_icnobj[1].ob_tail = -1;
		win->w_icnobj[1].ob_x = 0;
		win->w_icnobj[1].ob_y = 0;

					/* start of the iconblk area	*/
	   	LBCOPY( (BYTE *)obj1,(BYTE *)iconaddr[ICON0].ob_spec, 
			sizeof( CICONBLK ) );	

		((CICONBLK *)obj1)->monoblk.ib_ptext  = 
			(LONG) (obj1) + sizeof(CICONBLK);

		objc_add(win->w_icnobj, 0, 1);
	} else {
		do1_alert( NOWINMEM );
		return( FALSE );
	}
}


/*	Initalize all the windows	*/

	VOID
ini_windows( )
{
	REG WORD	i;
	REG WINDOW	*win;

	d_level = 4;

	win = &winpd[0];

	for( i = 0; i < MAXWIN; i++, win++ )
	{
	  win->w_obj = (OBJECT*)0;
	  win->w_icnobj = (OBJECT*)0;
	  win->w_path = (BYTE*)0;	/* window path	*/
	  win->w_buf = (BYTE*)0;	  
	  win->w_free = FALSE;		/* window is not free yet	*/
	  win->w_level = 0;	  
	  win->w_id = -1;		/* window is not open		*/
	  win->w_rowi = 0;
	  win->w_coli = 0;	  
	  win->w_memory = 0x0L;		/* clean up file memory		*/
	  win->w_iconified = FALSE;

	  /* Put in default sizes, in case users have old inf file */
	  
	  rc_copy( (WORD *)sizes, (WORD *)&win->w_work );
	  rc_copy( (WORD *)sizes, (WORD *)&win->w_sizes );
	  rc_copy( (WORD *)sizes, (WORD *)&win->w_normsizes );
	}		

	path_alloc( 4 );		/* allocate path memory	*/

	win = &winpd[0];

	for( i = 0; i < MAXWIN; i++, win++ )
	{
#if 0
	  if ( !alloc_obj( 0, win ) )  /* in case memory alloc failed	*/
	  {
	    do1_alert( NOWINMEM );
	    break;
	  }
#endif
	  win->w_next = (BYTE *) &winpd[i+1];
	  win->w_free = TRUE;		/* this window is available	*/
	}

	winpd[i-1].w_next = (BYTE*)0;
	winhead = &winpd[0];
}



	VOID
ret_win( win )
	WINDOW	*win;
{
	if ( win->w_obj )
	{
	  free( win->w_obj );
	  win->w_obj = (OBJECT*)0;
	}

	win->w_free = TRUE;
}



	WINDOW
*alloc_win( )
{	
	REG WINDOW	*win;	
	
	win = winhead;

	while( win )
	{
	  if ( win->w_free )
	  {
	    if ( !alloc_obj( 0, win ) )		/* allocate objects */
	    {
	      do1_alert( NOWINMEM );	
	      break;
	    }
	    win->w_free = FALSE;
	    return( win );
	  }

	  win = (WINDOW *) win->w_next;
	}

	return( (WINDOW*)0 );
}


/*	Get the window data structure address according to handle	*/

	WINDOW
*get_win( handle )
	WORD	handle;
{
	REG WINDOW	*win;

	win = winhead;
	
	while( win )
	{
	   if ( win->w_id == handle )
	     break;

	   win = (WINDOW *) win->w_next;
	}

	return( win );	
}


/*	Open window	*/

	VOID
open_window( handle )
	WORD	handle;
{
	REG WINDOW	*win;

	win = get_win( handle );		/* window's size	*/
						/* open it		*/

	win->w_obj->ob_spec = windspec;		/* set window's color	*/

	if (win->w_icnobj) 
		win->w_icnobj->ob_spec = windspec; /* +++ HMK 5/6/93 */

	if (win->w_iconified) {
		wind_set(handle, WF_UNICONIFYXYWH, 
			win->w_normsizes.g_x, win->w_normsizes.g_y, 
			win->w_normsizes.g_w, win->w_normsizes.g_h);
		wind_set(handle, WF_ICONIFY, 
			win->w_sizes.g_x, win->w_sizes.g_y, 
			win->w_sizes.g_w, win->w_sizes.g_h); 
		
		set_wiconname(win);
	} else
		do_xyfix( &win->w_sizes );

	wind_open( handle, win->w_sizes.g_x, win->w_sizes.g_y, 
			win->w_sizes.g_w, win->w_sizes.g_h );

	wind_get( handle, WF_CURRXYWH, &win->w_sizes.g_x, 
		&win->w_sizes.g_y, &win->w_sizes.g_w, &win->w_sizes.g_h );

						/* get the working area	*/
						/* and set it to object	*/
	wind_get( handle, WF_WORKXYWH, &win->w_work.g_x, &win->w_work.g_y, 
		&win->w_work.g_w, &win->w_work.g_h );
	
	if (win->w_iconified)					
		rc_copy( (WORD *)&win->w_work, &win->w_icnobj->ob_x );
	else
		rc_copy( (WORD *)&win->w_work, &win->w_obj->ob_x );
	make_top( win );
}


/*	Create Window of its full size	*/

	WORD
create_window( )
{
	REG WINDOW	*win;
	WORD	handle;
					/* Do we have any window pd ?	*/
	if ( win = alloc_win( ) )
	{
	  handle = wind_create( ALLITEMS, 
			win->w_normsizes.g_x, win->w_normsizes.g_y, 
			win->w_normsizes.g_w, win->w_normsizes.g_h );
	  Debug1("NEWDESK: Create window\r\n");		
	  if ( handle < 0 )		/* release windows	*/
	    ret_win( win );
	  else
	  {
	    win->w_id = handle;
	    return( handle );
	  }
	}
	return( -1 );
}


/*	Get the top window		*/

	WINDOW 
*get_top()
{
	return( w_gfirst() );

#if UNLINKED
	WORD	handle, ret;
	WINDOW	*win;

					/* find out who is on top	*/
	wind_get( 0, WF_TOP, &handle, &ret, &ret, &ret );
	if ( handle > 0 )
	{
	  if ( win = get_win( handle ) )
  	    return( win );
	}
	return( (WINDOW*)0 );
#endif
}


/*	Close and delete a window	*/

	VOID
close_window( handle, closeit )
	WORD	handle,closeit;
{
	GRECT		r;
	REG WINDOW	*win;

	win = get_win( handle );

	if ( closeit ) {		/* close window		*/
		if (win && win->w_iconified) {
			wind_get(handle, WF_UNICONIFY, 
				&r.g_x, &r.g_y, &r.g_w, &r.g_h);
	      		win->w_iconified = FALSE;	/* no icon anymore */
	      		rc_copy( (WORD *)&r, (WORD *)&win->w_sizes ); /* old sizes */
 		}
	  wind_close( handle );
	}
	/*	Delete window and assume it is closed	*/
	/*	Free up the file memory 		*/

	if ( win )
	{
	  win->w_id = -1;

	  ret_win( win );
  	
	  if ( win->w_memory )
	  {
	    Mfree( win->w_memory );	/* yes, Mfree -- see deskfile.c */
	    win->w_memory = (BYTE*)0;
	  }
	
	  wind_delete( handle );	/* delete the window */

	  if ( closeit )		/* look for top window */
	  {
 	    if ( win == winhead )	/* close the top window */
	    {
	      win = winhead;
	
	      while( win )
	      {
		if ( win->w_id != -1 )
		{
		  make_top( win );
		  break;
		}
	        else
		  win = (WINDOW *) win->w_next;
	      }
	    }
	  }
	}
}



/*	Free and close all the windows and free the objects	*/ 

	VOID
free_windows( )
{
	REG WINDOW	*win;
	WORD	i;
	
	for ( i = 0; i < MAXWIN; i++ )
	{
	   win = &winpd[i];

	   if ( win->w_obj )
	   {
	     free( win->w_obj );
	     win->w_obj = (OBJECT*)0;
	   }
#if 0
	   if (win->w_iconified) {
		GRECT	pc;
		wind_get(win->w_id, WF_UNICONIFY, 
			&pc.g_x, &pc.g_y, &pc.g_w, &pc.g_h);
		wind_set(win->w_id, WF_UNICONIFY, 
			pc.g_x, pc.g_y, pc.g_w, pc.g_h); 
		
	   }
#endif
/*	   win->w_iconified = FALSE;	  */ 
	   if (win->w_icnobj) {
	   	free( win->w_icnobj );
	   	win->w_icnobj = (OBJECT*)0;		
	   }

	   /* don't close window, do it at the sh_main */

	   if ( win->w_id != -1 )	
	     close_window( win->w_id, FALSE );
	}

	free_path();				
}


/*	This is my own redraw routine		*/

	VOID
do_redraw( handle, pc, which )
	REG WORD	handle;
	GRECT	*pc;
	WORD	which;
{
	/* NOT USED: GRECT	pt; */
	REG OBJECT	*obj;
	WINDOW	*win;
	GRECT	px;

	rc_copy( (WORD *)pc, (WORD *)&px );
	
	if ( handle > 0 )
	{
	  win = get_win( handle );

	  if (win->w_iconified) {
		  obj = win->w_icnobj; 	/* Draw this tree if window is	*/
					/* icnonified.			*/
	  } else
		  obj = win->w_obj;
	}
	else
	  obj = background;

	if ( which )
	{
	  objc_offset( (OBJECT *)obj, which, &px.g_x, &px.g_y ); 
	  px.g_w = obj[which].ob_width;
	  px.g_h = obj[which].ob_height;	
	}

	draw_loop( handle, obj, 0, MAX_DEPTH, px.g_x, px.g_y, px.g_w, px.g_h );
}


/*	Fxi up the xywh	*/

	VOID
do_xyfix( pc )
	REG	GRECT	*pc;
{
	GRECT	rect;
	
	rc_copy( (WORD *)&full, (WORD *)&rect );

	pc->g_w =	min( pc->g_w, rect.g_w );
	pc->g_h =	min( pc->g_h, rect.g_h );
	
	if ( pc->g_x >= ( rect.g_x + rect.g_w ) )
	  pc->g_x = rect.g_x + rect.g_w;
	  
	if ( pc->g_x < rect.g_x )
	  pc->g_x = rect.g_x;

	if ( pc->g_y >= ( rect.g_y + rect.g_h ) )
	  pc->g_y = rect.g_y + rect.g_h;

	if ( pc->g_y < rect.g_y )
	  pc->g_y = rect.g_y;

	rect.g_x = pc->g_x;

	pc->g_x = (rect.g_x & 0x000f);
	
	if ( pc->g_x < 8 )
	  pc->g_x = rect.g_x & 0xfff0;
	else
	  pc->g_x = (rect.g_x & 0xfff0) + 16;

	pc->g_y = max(pc->g_y, rect.g_y);
}



/* 	Blitwd.c written by Ye Jian Wen	*/

	VOID
do_blit(wh, wdact, dir, pixel)	
	WORD wh;		/* blit window handle */
	GRECT *wdact;		/* the window to blit */
	WORD dir;		/* the direction to blit */
	WORD pixel;		/* number of pixel to blit */
{  
	WINDOW	*win;

	GRECT wdrct;	/* the current window rectangle in rect list */ 

	wind_update(BEG_UPDATE);	/* lock screen */

	rc_intersect( &full, wdact );	/* clip to the screen	*/	

	wind_get(wh, WF_FIRSTXYWH, &wdrct.g_x, &wdrct.g_y, &wdrct.g_w, &wdrct.g_h);
	win = get_win(wh);

	while (wdrct.g_w && wdrct.g_h)	
	{				/* clip to the screen	*/
	   if ( rc_intersect( &full, &wdrct ) )
	   {				/* while it is not the last one */
	     if (rc_intersect(wdact, &wdrct)) 
	     {				/*check see if this one is damaged*/ 
		setclip(&wdrct);
		blit( dir, win, &wdrct, pixel);	/* blit arrow up */
	     }
	     wind_get(wh, WF_NEXTXYWH, &wdrct.g_x, &wdrct.g_y, &wdrct.g_w,
		 &wdrct.g_h);
	   }
	}
	wind_update(END_UPDATE);	/* unlock screen */
}


/* blit the window to right by # of pixel*/

	VOID
blit( dir, win, box, pixel)
	WORD	dir;
	WINDOW	*win;
	GRECT 	*box;
	WORD 	pixel;
{
	WORD pxyarray[8];
	WORD x[2]; 

	x[0] = 0;
	x[1] = 0;

	setclip( box );
	graf_mouse(M_OFF, 0L);
	d_setattr( MD_REPLACE, BLACK );

	switch( dir )
	{
	  case 0:		/* move contents up */
	    if ( pixel > box->g_h )
	      pixel = box->g_h;
	    else
	    {
		pxyarray[0] = box->g_x;
		pxyarray[1] = box->g_y;
		pxyarray[2] = box->g_x+box->g_w;
		pxyarray[3] = box->g_y+box->g_h-pixel;
		pxyarray[4] = box->g_x;
		pxyarray[5] = box->g_y+pixel;
		pxyarray[6] = box->g_x+box->g_w;
		pxyarray[7] = pxyarray[3]+pixel;
		d_vro_cpyfm(3, pxyarray, (LONG *)&x[0],(LONG *)&x[0]);
	    }
	
	     objc_draw( (LONG)win->w_obj, 0, MAX_DEPTH, box->g_x, box->g_y,
		 box->g_w, pixel);
	     break;

	  case 1:
	    if ( pixel > box->g_h )
	      pixel = box->g_h;
	    else
	    {
		pxyarray[0] = box->g_x;
		pxyarray[1] = box->g_y+pixel;
		pxyarray[2] = box->g_x+box->g_w;
		pxyarray[3] = box->g_y+box->g_h-1;
		pxyarray[4] = box->g_x;
		pxyarray[5] = box->g_y;
		pxyarray[6] = box->g_x+box->g_w;
		pxyarray[7] = pxyarray[3]-pixel;
		d_vro_cpyfm( 3, pxyarray,(LONG *)&x[0],(LONG *)&x[0]);
	     }

	     objc_draw( (LONG)win->w_obj, 0, MAX_DEPTH, box->g_x, box->g_y
		+box->g_h-pixel,box->g_w, pixel );
	     break;

	  case 2:		/* Move contents to right */
	    if ( pixel > box->g_w )
	      pixel = box->g_w;
	    else
	    {
		pxyarray[0] = box->g_x;	/* source */
		pxyarray[1] = box->g_y;
		pxyarray[2] = box->g_x+box->g_w-pixel;
		pxyarray[3] = box->g_y+box->g_h;
		pxyarray[4] = box->g_x+pixel;
		pxyarray[5] = box->g_y;
		pxyarray[6] = box->g_x+box->g_w;
		pxyarray[7] = box->g_y+box->g_h;
		d_vro_cpyfm( 3, pxyarray,(LONG *)&x[0],(LONG *)&x[0]);
	    }

	     objc_draw( (LONG)win->w_obj, 0, MAX_DEPTH, box->g_x, box->g_y,
		 pixel, box->g_h);
	     break;

	   case 3:		/* Move contents to left	*/
	     if ( pixel > box->g_w )
	       pixel = box->g_w;
	     else
	     {   	
	     	pxyarray[0] = box->g_x+pixel;
	      	pxyarray[1] = box->g_y;
		pxyarray[2] = box->g_x+box->g_w - 1;
	      	pxyarray[3] = box->g_y+box->g_h;
	 	pxyarray[4] = box->g_x;
		pxyarray[5] = box->g_y;
		pxyarray[6] = pxyarray[2]-pixel;
		pxyarray[7] = box->g_y+box->g_h;
		d_vro_cpyfm( 3, pxyarray,(LONG *)&x[0],(LONG *)x[0]);
	     }

	     objc_draw( (LONG)win->w_obj, 0, MAX_DEPTH, box->g_x+box->g_w
		-pixel, box->g_y, pixel, box->g_h);
	     break;
	
	   default:
	     break;

	}

	graf_mouse(M_ON, 0L);
}


/* set clip to specified rectangle */

	VOID
setclip(p)	
	GRECT *p;
{
	WORD ptr[4];

	ptr[0] = p->g_x;
	ptr[1] = p->g_y;
	ptr[2] = p->g_x + p->g_w - 1;
	ptr[3] = p->g_y + p->g_h - 1;
	vs_clip( 1, ptr );
}

/* 
 *	Iconify a window
 */
VOID
iconify_window(handle, pc)
WORD		handle;
REG GRECT	*pc;		/* recommended size for iconified window */
{
	REG WINDOW	*win;

	if ( !( win = get_win( handle ) ) )
	    return;		/* illegal window handle */

	rc_copy((WORD *)&win->w_sizes, (WORD *)&win->w_normsizes); 

	form_dial(FMD_SHRINK, pc->g_x, pc->g_y, pc->g_w, pc->g_h,
	  win->w_work.g_x, win->w_work.g_y, win->w_work.g_w, win->w_work.g_h);

	wind_set(handle, WF_ICONIFY, pc->g_x, pc->g_y, pc->g_w, pc->g_h); 

	clr_xwin(win, FALSE); 			/* deselect everything */
	win->w_iconified = TRUE; 		/* set icon flag */
	rc_copy( (WORD *)pc, (WORD *)&win->w_sizes );
					
	wind_get( handle, WF_WORKXYWH, &pc->g_x, &pc->g_y, &pc->g_w, &pc->g_h);

	rc_copy( (WORD *)pc, (WORD *)&win->w_work );
	/*
	 *	Set up coord for w_icnobj object tree.
	 *	This tree with one icon will be drawn when
	 *	window is iconified.
	 */
	win->w_icnobj[0].ob_x  = win->w_work.g_x;
	win->w_icnobj[0].ob_y  = win->w_work.g_y;	
	win->w_icnobj[0].ob_width  = win->w_work.g_w;
	win->w_icnobj[0].ob_height = win->w_work.g_h;	

	set_wiconname(win);	/* set name of icon in work area of 	*/
				/* iconified window 			*/
}

/*
 *	Uniconify winow, bring it back to normal state
 */
VOID
uniconify_window(handle, pc)
WORD		handle;
REG GRECT	*pc;	/* old window's size */
{
	REG WINDOW	*win;

	if ( !( win = get_win( handle ) ) )
	    return;		/* illegal window handle */

	win->w_icnobj[1].ob_state |= SELECTED;
	do_redraw(win->w_id, &win->w_work, 0);

	form_dial(FMD_GROW, win->w_work.g_x, win->w_work.g_y, win->w_work.g_w, 
		win->w_work.g_h, pc->g_x, pc->g_y, pc->g_w, pc->g_h);

	wind_set(handle, WF_UNICONIFY, pc->g_x, pc->g_y, pc->g_w, pc->g_h); 

	win->w_icnobj[1].ob_state &= (~SELECTED);
	win->w_iconified = FALSE;			/* no icon anymore */
	rc_copy( (WORD *)pc, (WORD *)&win->w_sizes ); 	/* old sizes */

	wind_get( handle, WF_WORKXYWH, &pc->g_x, &pc->g_y, &pc->g_w, &pc->g_h);
	rc_copy( (WORD *)pc, (WORD *)&win->w_work ); 	/* work area */
	rc_copy( (WORD *)pc, (WORD *)&win->w_obj->ob_x );
	view_fixmode(win);	/* Make sure items show up correctly,   */
	view_adjust(win);	/* necessary because user could have    */
				/* changed something in the Index menu. */
}

/*
 *	Set name of Icon in iconified Window
 */
VOID
set_wiconname(win)
REG WINDOW	*win;
{
	REG BYTE	*s1, *s2;
	BYTE		savechr;

	/*
	 *	Get the current folder name for the
	 *	icon's name.
	 */
	if ((win->w_path!=NULL)&&((s2=r_slash(win->w_path))!=NULL)) {
		savechr = *s2;	
		*s2 = '\0'; 
   
		if ((s1 = r_slash(win->w_path)) == NULL)
			goto else_slash;
			
		if (s1 == win->w_path) {
			*s2++ = (BYTE) savechr;
			savechr = *s2;
			*s2 = '\0';
			s1 += 2;
		} else {
			s1++;
		}
		strcpy(s1,  ((CICONBLK *)win->w_icnobj[1].ob_spec)->monoblk.ib_ptext);
			*s2 = (BYTE) savechr;
	} else { /* we are at root, so use baskslash as name */
else_slash:
		   strcpy("\\",  
		     ((CICONBLK *)win->w_icnobj[1].ob_spec)->monoblk.ib_ptext); 
	}
}

