/*	DESKSHELL.C		4/24/89	- 6/15/89	Derek Mui	*/
/*	Take out vdi_handle	6/28/89					*/
/*	Modify exec_file, run_it	9/13/89		D.Mui		*/
/*	Check undo key during printing	9/26/89		D.Mui		*/
/*	Change at exec_file to handle multiple file parameters	2/20/91	*/


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
#include <deskusa.h>
#include <osbind.h>
#include <error.h>
#include <extern.h>

EXTERN	BYTE	*bld_par();
EXTERN	BYTE	*r_slash();
EXTERN	BYTE	*g_name();
EXTERN	APP	*app_xtype();
EXTERN	BYTE	toupper();
EXTERN	BYTE	*scasb();
EXTERN	OBJECT	*get_tree();
EXTERN	WORD	d_exit;

EXTERN	WORD	s_defdir;
EXTERN	WORD	s_fullpath;
EXTERN	WINDOW	*x_win;
EXTERN	WORD	x_type;

EXTERN	WORD	sh_iscart;
EXTERN	BYTE	*strcpy();
EXTERN	WORD	global[];

BYTE	SHPRINT[] = "SHPRINT=";
BYTE	SHSHOW[] = "SHSHOW=";


	WORD
ch_tail( command, argu, tail )
	BYTE	*command,*argu,*tail;
{
	if ( ( strlen( command ) + strlen( argu ) + 2 ) >= PATHLEN )
	{
	  tail[0] = 0xFF;	
/*	  tail[1] = 0;		*/
/*	  do1_alert( FCNOMEM );	*/
	}
	else
	{
	  strcpy( argu, &tail[1] );	/* put in first argus	*/
	  strcat( command, &tail[1] );	/* patch in file name	*/
	  tail[0] = strlen( &tail[1] );
	}

	return( TRUE );
}


/*	Show a file	*/

	VOID
show_file( file )
	BYTE	*file;
{
	WORD	x,ret;
	BYTE	*tail,*bptr;

	shel_envrn( &bptr, SHSHOW );
	if ( bptr )
	{
	  if ( tail = bld_par(1,1) )
	  {
	    if ( !( ret = shel_write( 0, 0, 1, bptr, tail ) ) )
	      fill_string( bptr, FTOLAUNCH );
	    Mfree( tail );
	    if ( ret )
	      return;		
	  }
	}

	menu_bar( menu_addr, FALSE );
	v_hide_c( );
	v_enter_cur( );	
	vq_chcell( &d_nrows, &x );
	d_nrows--;
	showfile( file, FALSE );		
	v_exit_cur( );
	v_show_c( 0 );
	menu_bar( menu_addr, TRUE );	
	form_dial( FMD_FINISH, 0, 0, 0, 0, full.x, full.y, full.w, full.h );
	wait_msg( -1 );
}


	VOID
pr_setup( )
{
	inf_sset( get_tree( PRINTFIL ), PFILE, Nostr );
	dr_dial_w( PRINTFIL, FALSE );
}



/*	Use the system to print a file	*/

	WORD
aprint( file )
	BYTE	*file;
{
	OBJECT	*obj;

	obj = get_tree( PRINTFIL );
	xinf_sset( obj, PFILE, g_name( file ) );
	draw_fld( obj, PFILE ); 
	return( showfile( file, TRUE ) );
}


/*	Print one single file by using the user defined program */
/*	Or internal desktop print function			*/

	WORD
printit( str )
	BYTE	*str;
{
	BYTE	*bptr;

	shel_envrn( &bptr, SHPRINT );	/* user defined print program */
	if ( bptr )
	{
	  if ( !m_sfirst( bptr, 0x31 ) )
	  {
	    if ( ch_tail( str, Nostr, comtail ) )
	      if ( shel_write( 0, 0, 1, bptr, comtail ) )
		return;
	  }
	  else
	    fill_string( bptr, FTOLAUNCH );			
	}

	pr_setup();
	aprint( str );
	do_finish( PRINTFIL );
}


/*	Loop to print a lot of files	*/

	VOID
print_file( )
{
	WORD	ret,type,ret1;
	WORD	printed;
	GRECT	pt;	
	BYTE	*str,*tail,*bptr;	

	ret1 = build_rect( background, &pt, d_xywh[6], d_xywh[9] );

	shel_envrn( &bptr, SHPRINT );

	if ( bptr )
	{
	  if ( !m_sfirst( bptr, 0x31 ) )
	  {
	    if ( tail = bld_par(1,1) )
	    {
	      if ( !( ret = shel_write( 0, 0, 1, bptr, tail ) ) )
	        fill_string( bptr, FTOLAUNCH );

	      Mfree( tail );	
	      if ( ret )
	        goto p_1;		/* Done */
	    }
	  }
	}

	ret = x_first( &str, &type );	/* get the first file	*/

	printed = FALSE;

	wind_update( 1 );

	while( ret )
	{
	  if ( ( type == XFILE ) || ( type == WINICON ) )
	  {
	     if ( !printed )
	     {
	       pr_setup( );
	       printed = TRUE;
	     }

	     if ( !aprint( str ) )
	       break;
	  }

	  x_deselect();		/* deselecte the file	*/

	  if ( !ch_undo() )
	    break;
 	
	  if ( !( ret = x_next( &str, &type ) ) )
	    break;
	}

	if ( printed )
	  do_finish( PRINTFIL );

	wind_update( 0 );
p_1:		
	if ( x_type == DESKICON )	/* update the desktop	*/
	{
	  if ( ret1 )
	    do_redraw( 0, &pt, 0 );
	}
	else
	  up_2( x_win );
} 	


/*	Launch a file	*/

	VOID
launch_pref()
{
	WORD	graphic;
	REG OBJECT	*obj;
	BYTE	*ptr, *progname;
	WORD	fullpath;

	obj = get_tree( DLAUNCH );
	inf_sset( obj, RUNNAME, Nostr );
	if ( fmdodraw( DLAUNCH, 0 ) == LAUNCHOK )
	{
	  inf_sget( obj, RUNNAME, path1 );
	  if ( path1[0] )
	  {
	    graphic = ( obj[LGRAPHIC].ob_state & SELECTED ) ? TRUE : FALSE;
	    ptr = scasb( path1, ' ' );
	    if ( *ptr )		/* point to the blank	*/
	    {
	      *ptr++ = 0;
	      if ( !ch_tail( ptr, Nostr, comtail ) )
	        return;
	    }
	    else
	      comtail[0] = 0;

	    progname = path1;
	    if ( path1[1] == ':' )
	      path1[0] = toupper( path1[0] );
	    else {
/* ERS (12/8/92): if no path or drive is given, look for
 * the file in the current directory
 */
/* see if there's a slash */
		fullpath = FALSE;
		ptr = path1;
		while (*ptr)
		{
		  if (*ptr == '\\') fullpath = TRUE;
		  ptr++;
		}
/* if no slash and an open window, look for the file
 * in that window's directory; if found, use that
 * file for sure
 */
		if (!fullpath && winhead && winhead->w_id != -1)
		{
		  strcpy( winhead->w_path, path2 );
		  ptr = r_slash( path2 );
		  if (ptr)
		  {
		    strcpy( progname, ptr+1 );
		    if ( Fsfirst( path2, 0 ) == 0 )
		      progname = path2;
		  }
		}
	    }
	    run_it( progname, comtail, graphic, s_defdir, 0 );
	  }
	}
}


/*	Set the current directory					*/
/*	The path should look like A:\FILENAME or A:\FOLDER\FILENAME	*/

	WORD
set_dir( path )
	REG BYTE	path[];
{
	REG BYTE	*ptr;
	REG WORD	ret;

	if ( path[0] == 'c' )
	  return( TRUE );

	ret = TRUE;

	if ( path[0] == '\\' )		/* at the current root	*/
	  ret = Dsetpath( bckslsh );
	else
	{				/* there is drive id	*/
	  if ( path[1] == ':' )
	  {
	    if ( hit_disk( (WORD)path[0] ) )
	    {
	      Dsetdrv( (WORD)( toupper( path[0] ) - 'A') );
	      ptr = r_slash( path );
	      if ( &path[2] == ptr )
	        ret = Dsetpath( bckslsh );
	      else
	      {
	        *ptr = 0;
	        ret = Dsetpath( &path[2] );
	        *ptr = '\\';	
	      }
	    }
	  }
	  else			/* only file name !!!	*/
	    ret = FALSE;	/* OK			*/
	}

	return( ret ? FALSE : TRUE );
}




/*	Run an application include doing dialogue box	*/

	VOID
exec_file( infile, win, item, intail )
	BYTE	*infile,*intail;
	WINDOW	*win;
	WORD	item;
{
	REG APP	*app;
	WORD	type,install,graphic,code;
	WORD	dofull,setdir,which,id;		
	OBJECT	*obj;
	BYTE	*tail,*file,*newtail;
	BYTE	*bptr;

	app = app_xtype( infile, &install );
	type = app->a_type;
						/* installed document	*/
	if ( ( install ) && ( app->a_name[0] ) )
	{
	  tail = infile;			/* infile becomes tail	*/
	  file = app->a_name;
	}
	else
	{
	  if ( intail )
	    tail = ( intail[0] ) ? &intail[1] : Nostr;
	  else
	    tail = intail;

	  file = infile;
	}

	if ( strcmp( file, app->a_name ) )
	{
	  dofull = ( app->a_pref & 0x2 ) ? TRUE : FALSE; 
	  setdir = ( app->a_pref & 0x1 ) ? TRUE : FALSE;
	}
	else
	{
	  dofull = s_fullpath;
	  setdir = s_defdir;
	}

	newtail = (BYTE*)0;

	if ( !tail )		/* if multiple parameters	*/
	{
	  if ( !( tail = newtail = bld_par( dofull, 1 ) ) )
	    tail = Nostr;	/* No buffer, so put in Nostr */
	}
	else
	{
	  if ( !dofull )	/* single file only	*/
	    tail = g_name( tail );
	}

	if ( !newtail )
	{
	  if ( !ch_tail( tail, app->a_argu, comtail ) )	  
	    goto e_3;
	}

	graphic = TRUE;
	code = 1;

	switch( type )
	{
	  case TEXT:				/* print	*/
	    if ( ( which = do1_alert( STNOAPPL ) ) == 2 )
	      print_file( );
	    else
	    if ( which == 1 )		/* show 	*/
	      show_file( file );

	    goto e_3;
	
	  case ACCESSORY:		/* run an accessory	*/
	    code = 3;
	    break;
/*	    shel_write( 3, 0, 0, file, Nostr ); 	*/
	    return;
		
	  case TTP:		/* TOS takes parameter	*/
	    graphic = FALSE;

	  case PTP:		/* program takes parameter	*/
	    if ( ( install ) || ( *tail ) )
	      break;

	    obj = get_tree( ADOPENAP );
	    tail = g_name( file );
	    xinf_sset( obj, APPLNAME, tail );
	    inf_sset( obj, APPLPARM, app->a_argu );
	     
	    if ( fmdodraw( ADOPENAP, 0 ) == APPLCNCL )
	      goto e_3;

	    tail = (TEDINFO*)(obj[APPLPARM].ob_spec)->te_ptext;

	    if ( !newtail )
	    {
	      if ( !ch_tail( tail, Nostr, comtail ) )
	        goto e_3;
	    }

	    break;
		
	  case TOS:
	    graphic = FALSE;
	    break;
	
	  case PRG:
	  case APPS:
	    break;
	
	  default:
	    do1_alert( NOTYPE );
	    goto e_3;
	 }

	do_box( win, item, ( win ) ? FALSE : TRUE, TRUE, TRUE );
	run_it( file, ( newtail ) ? newtail : comtail, graphic, setdir, code );  

e_3:
	if ( newtail )
	  Mfree( newtail );
}


/*	Run the application	*/

	VOID
run_it( file, tail, graphic, setdir, code )
	BYTE	*file,*tail;
	WORD	graphic, setdir,code;
{
	LONG	ptrs[5];
	BYTE	*ptr;

	if ( strlen( file ) >= PATHLEN )
	{
	  do1_alert( NOBUF );
	  return;
	}
				/* Set default directory */
	strcpy( file, g_buffer );

	if ( !setdir )
	{
	  if ( winhead->w_id != -1 )
	    strcpy( winhead->w_path, g_buffer );
	}

#if 0		
	if ( !save_inf( FALSE ) )	/* prepare to launch application */
	  goto ex_1;
#endif

#if 0
	if ( *file == 'c' )
	{
	  if ( cart_init() )
	    sh_iscart = TRUE;
	  else
	  {
	    do1_alert( NOCART );			
	    return;
	  }
	}
	else
	  sh_iscart = FALSE;
#endif

/*	tail[strlen( tail )+1] = 0xD;	*/

				/* set default directory */
	ptr = r_slash( g_buffer );

	if ( *(ptr-1) != ':' )	/* not at the head */
	  *ptr = 0;
	else
	  *(ptr+1) = 0;

	code |= 0x0400;

	ptrs[0] = file;		/* file name */
	ptrs[3] = g_buffer;	/* default directory */

	if ( !shel_write( code, graphic, 1, &ptrs[0], tail ) )
	  fill_string( file, FTOLAUNCH );
}
