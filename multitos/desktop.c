/*	DESKTOP.C		3/15/89 - 7/26/89	Derek Mui	*/
/*	Take out vdi_handle	6/28/89					*/
/*	Read in icn file	9/23/89			D.Mui		*/
/*	New adj_menu to adjust menu	6/27/90		D.Mui		*/
/*	Take the wind_update in deskmain	8/9/90	D.Mui		*/
/*	Add m_cpu to check CPU	9/19/90			D.Mui		*/
/*	Fix the cache menu so that it checks the cache when menu is down*/
/*					10/24/90	D.Mui		*/
/*	Moved the wind_set in the main to just before menu_bar. It is 	*/
/*	to fix the acc problem			12/4/90	D.Mui		*/
/*	Change appl_init to ap_init and appl_exit to ap_exit 4/3/91	*/
/*	Add wm_update before bringing up the menu bar 4/18/91 Mui	*/
/*	Install desktop critical error handler	4/22/91	D.Mui		*/
/*	Rename deskmain to desktop		5/1/91	D.Mui		*/
/*	Check control key for nodisk system at re_icon 8/13/91	D.Mui	*/
/*	Change all the iconblk to ciconblk	7/11/92	D.Mui		*/

/************************************************************************/
/*	New Desktop for Atari ST/TT Computer				*/
/*	Atari Corp							*/
/*	Copyright 1989,1990 	All Rights Reserved			*/
/************************************************************************/

#include <compiler.h>
#include <machine.h>
#include <deskobde.h>
#include <deskdefi.h>
#include <deskwin.h>
#include <gemdefs.h>
#include <osbind.h>
#include <extern.h>
#include <mintbind.h>	
#include <signal.h>
#include <vdomode.h>
#include <deskusa.h>

typedef struct cblk
{
	long		cb_pcontrol;
	int		*cb_pglobal;
	long		cb_pintin;
	long		cb_pintout;
	long		cb_padrin;
	long		cb_padrout;		
}CBLK;


EXTERN	BYTE	*get_fstring();
EXTERN	BYTE	*malloc();
EXTERN	VOID	free();
EXTERN	OBJECT	*get_tree();

EXTERN	UWORD	d_rezword;
EXTERN	WORD	icn_whandle;
EXTERN	BYTE	*lp_mid;
EXTERN	BYTE	*lp_start;
EXTERN	WORD	d_exit;
EXTERN	BYTE	*q_addr;
EXTERN	UWORD	apsize;
EXTERN	OBJECT	*deskptr;		/* desktop resource	*/
EXTERN	LONG	gl_vdo;
EXTERN	CBLK	c;
EXTERN	WORD	ctldown;

GLOBAL	WORD	v_handle;
GLOBAL	WORD	desk_id;
GLOBAL	WORD	m_st;		/* machine type flag	*/	
GLOBAL	WORD	m_cpu;		/* cpu type		*/
GLOBAL	WORD	numicon;	/* the number of icon in the resource	*/	
GLOBAL	BYTE	*iconmem;	/* icon data memory address	*/
GLOBAL	BYTE	restable[6];	/* resolution table	*/
				/* Low , Medium, High, TT Medium, TT High, TT Low */
GLOBAL	WORD	d_maxcolor;
GLOBAL	USERBLK	chxcache;
GLOBAL	WORD	pglobal[15];
CICONBLK	*ciconaddr;
GLOBAL	UWORD	st_time;	/* time code		*/
GLOBAL	UWORD	st_date;
GLOBAL	UWORD	st_dchar;
GLOBAL	WORD	st_keybd;

MLOCAL	BYTE	*TIMETABLE[] =
{/* Eurotime, Eurodate and seperator */
	0,0,'/',	/* USA	*/
	1,1,'.',	/* GERMANY	*/
	1,1,'/',	/* FRENCH	*/
	0,0,'/',	/* USA	*/
	1,1,'/',	/* SPAIN	*/
	1,1,'/',	/* ITALY	*/
	1,2,'-'		/* SWEDEN,NORWAY,FINLAND*/
};	


/*	Catch desktop terminate signal */

	VOID
desk_term()
{
	d_exit = L_EXIT;
	return;
	Debug1( "Desktop catches terminate signal\r\n" );

	ciconaddr = (BYTE*)0;
#if 0
	if ( iconmem )
	{
	  LBCOPY( temp, c.cb_pglobal, 30 );
	  *((LONG*)(&c.cb_pglobal[7])) = iconmem;
	  rsrc_free(); 	
	  iconmem = (BYTE*) 0;
	  LBCOPY( c.cb_pglobal, temp, 30 );	
	}
#endif
	iconaddr = (OBJECT*) 0;
	iconmem = (OBJECT*) 0;
	inf_path[0] = 0;		
	Pterm(1);
}


	WORD
ch_xcache()
{
	ch_cache( FALSE );
	return( 0 );
}


/*	Read in icn file	*/

	WORD
re_icon( )
{
	REG WORD	i,ret;
	WORD		temp[15];
	LONG		*ptr;
	BYTE		buf2[18];	
	BYTE		*iaddr;

	ret = FALSE;

	if ( !ctldown )			/* no control key down */
	{
	  LBCOPY( temp, c.cb_pglobal, 30 );
	  strcpy( cicndata, buf2 );	/* Try color icon file	*/
	  buf2[0] = ( isdrive() & 0x4 ) ? 'C' : 'A';
 
	  if ( !rsrc_load( buf2 ) )
	  {
	    strcpy( icndata, buf2 );	/* Try old icon file	*/
	    buf2[0] = ( isdrive() & 0x4 ) ? 'C' : 'A';
	    if ( !rsrc_load( buf2 ) )	
	      goto i_1;
	  }

	  ptr = &c.cb_pglobal[7];	/* get the new rsc address	*/
	  iaddr = *ptr;
		
	  if ( iconmem )		/* free up memory	*/
	  {				/* use rs_free to free memory	*/
	    *ptr = iconmem;		/* because it may have color icons */	
	    rsrc_free();
	  }

	  iconmem = iaddr;		
	  iconaddr = get_tree( 0 );	
	  numicon = iconaddr[0].ob_tail;
	  iconaddr++;			/* get the icon address	*/
	  ret = TRUE;
i_1:					/* restore the pglobal	*/
	  LBCOPY( c.cb_pglobal, temp, 30 );
	}

	return( ret );
}


/*	Initalize the icon and allocate backid memory	*/

	WORD
ini_icon()
{
	REG WORD	i;
	REG OBJECT	*obj;
	REG IDTYPE	*itype;
	    CICONBLK	*icblk;

	backid = malloc( (LONG)( sizeof( IDTYPE ) * ( maxicon + 1 ) ) );

	if ( !backid )
	{
#if 0
	  form_alert( 1, "[1][ Desktop failed to allocate | icon memory ][ OK ]" );
#else
	  do1_alert( FCNOMEM );	/* ++ERS 12/16/92 */
#endif
	  return( FALSE );
	}
	
	obj = background;
	
	for ( i = 1; i <= maxicon; i++ )
	{
	  itype = &backid[i];
	  obj[i].ob_type = G_CICON;	/* 7/11/92 */
	  obj[i].ob_flags = HIDETREE;
	  obj[i].ob_state = NORMAL;
	  obj[i].ob_width = dicon.w;
	  obj[i].ob_height = dicon.h;
	  icblk = (CICONBLK*)(iconaddr[0].ob_spec);
	  itype->i_cicon = *icblk;
	  itype->i_cicon.monoblk.ib_ptext = &itype->i_name[0]; 	
	  obj[i].ob_spec = &itype->i_cicon;
	  itype->i_path = (BYTE*)0;
	}

	return( TRUE );
}

/*	Shift the menu	*/

	VOID
adj_menu( which )
	WORD	which;
{
	OBJECT	*obj;
	WORD	w,x,y;

	obj = menu_addr;		/* shift the menu	*/
	objc_offset( menu_addr, which, &x, &y );
	
	w = obj[which].ob_width + x;
	if ( w >= ( full.w + full.x ) )
	{
	  x = w - ( full.w + full.x ) + gl_wchar;
	  obj[which].ob_x -= x;	
	}			
}


/*	Initalize the desktop resource		*/

	WORD
ini_rsc()
{
	REG OBJECT	*obj;
	GRECT	pt;
	ICONBLK		*iblk;
	WORD		w,i;
	CICONBLK	*icblk;

	Debug1( "Rsrc_rcfix\r\n" );	
	rsrc_rcfix( deskptr );				
	Debug1( "Get tree\r\n" );					
	menu_addr = get_tree( ADMENU );	/* get the menu address		*/
			
	adj_menu( IDSKITEM - 1 );
	adj_menu( ICONITEM - 1 );			

	if ( !iconaddr )		/* if icon has read in 	*/
	{				/* then read it again	*/
	  if ( !re_icon() )
	  {
	    iconaddr = get_tree( ADICON );
	    numicon = iconaddr[0].ob_tail;
	    iconaddr++;
	  }
	}

	background = get_tree( BACKGROUND );
					
	maxicon = background[0].ob_tail;/* max background icon		*/

/* 	Allocate memory for color icons 
 * 	These should go away if we have a RCS that can handle color icon 
 */

	if ( !ciconaddr )	/* 7/10/92 */
	{
	  if ( ciconaddr = malloc( (LONG)( sizeof(CICONBLK) * maxicon ) ) )
	  {		
	    for ( i = 0; i < maxicon; i++ )
	    {
/*	      ciconaddr[i].monoblk = *((ICONBLK*)background[i+1].ob_spec);	*/
/*              ciconaddr[i].mainlist = (CICON*)0;	*/
	      background[i+1].ob_spec = &ciconaddr[i];
	      backgroubd[i+1].ob_type = G_CICON;
	    }
	  }
	  else
	  {
 	    Cconws( "Color icon failed \r\n" );
	    return(FALSE);
	  }
	}

	rc_copy( &full, &background[0].ob_x );

	/* Precalculate the disk icon's pline values	*/

	if ( iconaddr[0].ob_type == G_CICON )
	{
	  icblk = (CICONBLK*)iconaddr[0].ob_spec;
	  iblk = &icblk->monoblk; 
	}
	else
	  iblk = (ICONBLK*)(iconaddr[0].ob_spec);

	rc_copy( &iblk->ib_xicon, &pt );	/* get the icon's xywh	*/

	d_xywh[0] = pt.x;			/* disk icon outline	*/
	d_xywh[3] = d_xywh[1] = pt.y;
	d_xywh[4] = d_xywh[2] = d_xywh[0] + pt.w; 
	d_xywh[5] = d_xywh[3] + pt.h;
	
	rc_copy( &iblk->ib_xtext, &pt );
	d_xywh[8] = d_xywh[6] = pt.x + pt.w;
	d_xywh[13] = d_xywh[7] = pt.y;
	d_xywh[11] = d_xywh[9] = d_xywh[7] + pt.h;
	d_xywh[12] = d_xywh[10] = pt.x;
	d_xywh[16] = d_xywh[14] = d_xywh[0];
	d_xywh[15] = d_xywh[5];
	d_xywh[17] = d_xywh[1];
				
	dicon.x = 0;			/* precalculate text icon's x,y,w,h */
	dicon.y = 0;
	dicon.w = iblk->ib_wtext;
	dicon.h = iblk->ib_hicon + iblk->ib_htext;

	rc_copy( &dicon, &r_dicon );
	r_dicon.w += 5;
	r_dicon.h += 7;
	r_dicon.w += ( full.w % r_dicon.w ) / ( full.w / r_dicon.w );
	r_dicon.h += ( full.h % r_dicon.h ) / ( full.h / r_dicon.h );
				
	w = gl_wchar * 14;		/* text outline	*/

	obj = get_tree( TEXTLINES );
	f_xywh[9] = f_xywh[8] = f_xywh[6] = f_xywh[3] = f_xywh[1] = f_xywh[0] = 0;
	f_xywh[2] = w;
	f_xywh[4] = w;
	f_xywh[5] = obj[TSTYLE].ob_height;
	f_xywh[7] = obj[TSTYLE].ob_height;

	Debug1( "Ini_rsc done\r\n" );	
	return( TRUE );
}


MLOCAL	BYTE	DESK_MAGIC[] = "4c4c444D";
MLOCAL	BYTE	SH_MAGIC[] = "SH_MAGIC=";

/*	Process 2 - Desktop 	*/

	WORD
deskmain()
{
	REG WORD	i;
	WORD		ret,x,doitonce,code;
	WORD		*ptr;
	WORD		buffer[8];
	OBJECT		*obj;
	BYTE		temp[30];
	LONG		value;
	LONG		*lptr;

	catchsignal( SIGTERM );	/* Redirect all the Signals	*/
				/* Catch only the terminate signal */	
	Psignal( SIGTERM, desk_term );

	if ( !inf_path[0] )	/* Not set up yet		*/	
	  m_infpath( inf_path );

	desk_id = appl_init( );	/* initalize the application	*/

				/* Let AES knows that we will handle AP_TERM 	*/
	shel_write( 9, 0x1, 0, Nostr, Nostr );
	
	ret = graf_handle( &x, &x, &x, &x );
	v_handle = ret;

	desk_vopnvwk( &v_handle, Getrez()+2, &ptr );
	
	if ( !v_handle )
	{
/* we can't really translate this string because the resource file
 * isn't open yet. Bummer! ++ERS 12/16/92
 */
	  form_alert( 1, "[1][ Desktop failed to open | work station ][ BYE ]" );
	  goto m_6;
	}

	doitonce = TRUE;
	icn_whandle = -1;
	d_exit = L_NOEXIT;

	ciconaddr = (BYTE*)0;	/* 7/10/92 */

	Debug1( "Desktop checks cookie\r\n" );

	if ( getcookie( 0x5F414B50L, &value ) )	/* get _AKP cookie */
	{
	  st_keybd = value & 0x00FFL;
	  code = ( value >> 8 ) & 0x00FF;	/* get the keyboard preferences */
	}
	else
	  st_keybd = code = 0;

	if ( ( st_keybd > 8 ) || ( st_keybd < 0 ) )
	  st_keybd = 0;

	if ( ( code > 6 ) || ( code < 0 ) || ( code == 3 ) )
	  code = 0;

	code = code * 3;
					/* set the default IDT stuff */
	st_time = TIMETABLE[code++];
	st_date = TIMETABLE[code++];
	st_dchar = TIMETABLE[code];

	/* The _IDT format is as follow				*/
	/* HIGH WORD  |	         LOW WORD			*/
	/* 31 - 16    | 15-12      11-8     	  7-0 bit 	*/
	/* Reserved   |	st_time    st_date  	  st_char	*/
	/*  		0 12 hour  0  MM-DD-YY   		*/
	/*		1 24 hour  1  DD-MM-YY			*/	
	/*			   2  YY-MM-DD			*/
	/*			   3  YY-DD-MM			*/
		
	if ( getcookie( 0x5F494454L, &value ) )	/* get _IDT cookie */
	{
	  st_date = ( value >> 8 ) & 0xFL;	/* get the date preferences */
	  st_time = ( value >> 12 ) & 0xFL;
	  if ( !( st_dchar = value & 0xffL ) )
	    st_dchar = '/';
	}
top:
	Debug1( "Desktop does rom ram\r\n" );
	Ndebug1( deskptr );
	rom_ram( 1, deskptr );	/* read in desktop resource	*/

	Debug1( "Desktop does deskerr\r\n" );

	deskerr();

	ret = TRUE;		/* assume everything is OK	*/

	appnode = (BYTE*)0;	/* No app buffer yet		*/
	applist = (BYTE*)0;	/* No app list yet		*/
	apsize = 0;		/* Initalize app size		*/
	autofile[0] = 0;

	desk_mice( HOURGLASS );	/* busy bee pointer		*/	
				/* get the full window size	*/

	wind_get( 0, WF_WORKXYWH, &full.x, &full.y, &full.w, &full.h );

	Debug1( "Desktop does ini_rsc\r\n" );

	ini_rsc();		/* init the resource		*/

	Debug1( "Ini_icon\r\n" );
	if ( !ini_icon() )	/* hide all the desktop icons	*/
	  goto m_2;

	Debug1( "Mem_init\r\n" );
	if ( !mem_init() )	/* init the app path buffer	*/
	{
m_2:	  desknoerr();	  
	  goto m_1;		/* and desk app buffer		*/
	}

	/* initalize all the windows before reading in inf file	*/

	Debug1( "Ini_window\r\n" );
	ini_windows( );	 

	d_maxcolor = ptr[13];		/* vdi max number of color	*/

	if ( doitonce )			/* do it once only	*/
	{
#if 0
	  adjdcol( WHITE );		/* adjust dialogue box's color  */
#endif
	  adjobjects();			/* adjust object positions      */
	}
		
	Debug1( "Read inf file\r\n" );
	read_inf();			/* Let see what the user want	*/

	Debug1( "Q_inf\r\n" );
	q_inf();			/* make a copy of inf file	*/

	desknoerr();
					/* Get the real res mode for FALCON	*/
	if ( ( gl_vdo & HIGHWORD ) == FALCON ) 
	  d_rezword = setmode(-1);
	else
	  pref_save = res_type(Getrez()+2);

					/* change the menu bar		*/
	do_view( ( s_view == S_ICON ) ? ICONITEM : TEXTITEM );

	switch( s_sort )
	{
	  case S_NAME:
	    i = NAMEITEM;
	    break;
	  case S_DATE:
	    i = DATEITEM;
	    break;
	  case S_SIZE:
	    i = SIZEITEM;
	    break;
	  case S_TYPE:
	    i = TYPEITEM;
	    break;
	  case S_NO:
	    i = NOSORT;
	}

	Debug1( "Wind_set\r\n" );
	wind_set( 0, WF_NEWDESK, background, 0, 0 );

	Debug1( "Do_view\r\n" );
	do_view( i );			/* fix up the menu bar	*/

	ch_machine( );			/* check the machine	*/
					/* set up the right menu text */
					/* do it here!!!!!!	*/	
	strcpy( get_fstring( ( m_cpu == 30 ) ? CACHETXT : BLTTXT ), menu_addr[BITBLT].ob_spec );

	menu_addr[SUPERITEM].ob_type = G_USERDEF;
	chxcache.ub_code = ch_xcache;
	menu_addr[SUPERITEM].ob_spec = &chxcache;

	Debug1( "Ch_cache\r\n" );
	ch_cache( TRUE );		/* set the cache	*/

					/* check desktop file	*/	
	put_keys();			/* set up the key menu	*/

	Debug1( "Put menu bar\r\n" );

	if ( d_exit != L_WAKEUP )
	{
	  menu_bar( menu_addr, TRUE );	/* show the menu	*/
	  do_redraw( 0, &full, 0 );	/* draw the background	*/
	}

	Debug1( "Menu_register\r\n" );
	menu_register( desk_id, get_fstring(DESKNAME) );

	Debug1( "Open def\r\n" );
	open_def();			/* open default windows	*/
	desk_mice( ARROW );

	if ( doitonce )
	{
	  if ( autofile[0] )
	    shel_write( 1, ( autofile[1] == '1' ) ? 1 : 0, 0, &autofile[3], Nostr );
	}

	doitonce = FALSE;

	Debug1( "Actions\r\n" );
	
	d_exit = L_NOEXIT;

	actions();			/* handle the events	*/

	wind_update( 1 );		/* Block out any more events	*/
	desk_mice( HOURGLASS );		

	free_windows( );		/* free up all windows	*/	

	wind_set( 0, WF_NEWDESK, 0x0L, 0, 0 );
	
	free( lp_start );		/* free string buffer	*/

	free( appnode );		/* free app buffer	*/
	
	free( backid );

	free( q_addr );			/* update inf file on disk	*/

	wind_update( 0 );		/* release window	*/

					/* Loop again		*/
	if ( ( d_exit == L_READINF ) || ( d_exit == L_WAKEUP ) )
	  goto top;

	Debug7( "Desktop frees mn_bar\r\n" );

	menu_bar( 0x0L, FALSE );
m_1:
	if ( ciconaddr )	/* start everything over again	*/	
	{
	  free( ciconaddr );
	  ciconaddr = (BYTE*)0;
	}

	iconaddr = (OBJECT*) 0;

	if ( iconmem )
	{
	  LBCOPY( temp, c.cb_pglobal, 30 );
	  *((LONG*)(&c.cb_pglobal[7])) = iconmem;
	  rsrc_free(); 	
	  iconmem = (BYTE*) 0;
	  LBCOPY( c.cb_pglobal, temp, 30 );	
	}

	inf_path[0] = 0;
	v_clsvwk( );
m_6:
	appl_exit();
	Pterm( 1 );
}


/*	Check the machine type and set res table	*/

	WORD
ch_machine()
{
	LONG	value;

	m_st = TRUE;		
			/* _VDO	*/
	if ( getcookie( 0x5F56444FL, &value ) )
	{			/* 7/16/92 */
	  if ( ( ( value >> 16 ) & 0x0000FFFFL ) >= 0x02 )	/* TT	*/
	    m_st = FALSE;
	}
			/* _CPU	*/
	getcookie( 0x5F435055L, &value );
	m_cpu = value;

	/* the restable is set according to gl_restype value	*/

	bfill( 6, 0, restable );	/* zero the table	*/

	if ( !m_st )			/* TT machine	*/
	{
	  if ( pref_save == 5 )		/* TT High	*/
	    restable[4] = 1;
	  else
	  {
	    bfill( 4, 1, restable );	/* LOW MEDIUM HIGH	*/
	    restable[5] = 1;		/* TT-LOW MEDIUM	*/
	  }
	}	
	else
	{
	  if ( pref_save == 3 )		/* ST HIGH		*/
	    restable[2] = 1;
	  else
	  {
	    restable[0] = 1;
	    restable[1] = 1;	
	  }		
	}
}


	LONG
inq_cache( data )
	REG LONG	data;
{
	BYTE	*old;
	int	super;

	super = Super( 0x1L );
	
	if ( !super )
	  old = Super( 0x0L );

	  asm( ".dc.w $4e7a,$0002" ); /* movec.l cacr,d0		*/

	  if ( data != -1 )
	    asm( ".dc.w $4e7b,$7002" ); /* movec.l d7,cacr		*/

	  asm( ".dc.w $4e7a,$7002" ); /* movec.l cacr,d7		*/

	if ( !super )
	  Super( old );

	asm( ".dc.w $2007" );
}



/*	Turn on the cache or bitblt 	*/

	VOID
ch_cache( set )
	WORD	set;
{
	WORD	value;
	LONG	data;
	WORD	temp;

	menu_addr[BITBLT].ob_state &= ~DISABLED;

	if ( m_cpu == 30 )
	{
	  if ( set )
	    data = ( s_cache ) ? CACHE_ON : CACHE_OFF;
	  else
	    data = 0xFFFFFFFFL;

	  if ( inq_cache( data ) == XCA_ON )
	    s_cache = TRUE;
	  else
	    s_cache = FALSE;

	  value = s_cache;

	}
	else
	{				/* turn the blt on	*/
					/* blt is there		*/
ch_1:	  if ( ( temp = trap14( 64, -1 ) ) & 0x2 )	
	  {
	    if ( set )
	    {
	      trap14( 64, ( cbit_save ) ? 1 : 0  );
	      set = FALSE;
	      goto ch_1;	/* check status again	*/
	    }
	    else
	      cbit_save = ( temp & 0x1 ) ? TRUE : FALSE; 	
	      		
	    value = cbit_save;

	  }
	  else
	  {
	    value = FALSE;
	    menu_addr[BITBLT].ob_state |= DISABLED;
	  }
	}

	if ( value )
	  menu_addr[BITBLT].ob_state |= CHECKED;
	else 
	  menu_addr[BITBLT].ob_state &= ~CHECKED;
}


#if 0
/* adjust object colors if it is invalid */

/* NOTE: This routine should no longer be necessary, but is
 * maintained "just to be sure"
 * ++ERS, 1/19/93
 */
	VOID
adjdcol(color)
	UWORD color;
{
    REG OBJECT  *obj;

    if ( d_maxcolor > LWHITE)
	return;

    obj = get_tree(ADFILEIN);
    obj[FILEFT].ob_spec = (obj[FILEFT].ob_spec & 0xfffffff0) | color;
    obj[FIRIGHT].ob_spec = (obj[FIRIGHT].ob_spec & 0xfffffff0) | color;

    obj = get_tree(ADINSDIS);
    obj[IUP].ob_spec = (obj[IUP].ob_spec & 0xfffffff0) | color;
    obj[IDOWN].ob_spec = (obj[IDOWN].ob_spec & 0xfffffff0) | color;

    obj = get_tree(ADFORMAT);
    obj[SRCDRA].ob_spec = (obj[SRCDRA].ob_spec & 0xfffffff0) | color;
    obj[SRCDRB].ob_spec = (obj[SRCDRB].ob_spec & 0xfffffff0) | color;
    obj[ADRIVE].ob_spec = (obj[ADRIVE].ob_spec & 0xfffffff0) | color;
    obj[BDRIVE].ob_spec = (obj[BDRIVE].ob_spec & 0xfffffff0) | color;

    obj = get_tree(INWICON);
    obj[WUP].ob_spec = (obj[WUP].ob_spec & 0xfffffff0) | color;
    obj[WDOWN].ob_spec = (obj[WDOWN].ob_spec & 0xfffffff0) | color;

    obj = get_tree(MNSYSTEM);
    obj[ MFLEFT ].ob_spec = ( obj[ MFLEFT ].ob_spec & 0xfffffff0L ) | color;
    obj[ MFRIGHT ].ob_spec = ( obj[ MFRIGHT ].ob_spec & 0xfffffff0L ) | color;
    obj[ MFUP ].ob_spec = ( obj[ MFUP ].ob_spec & 0xfffffff0L ) | color;
    obj[ MFDOWN ].ob_spec = ( obj[ MFDOWN ].ob_spec & 0xfffffff0L ) | color;
    obj[ MKUPS ].ob_spec = ( obj[ MKUPS ].ob_spec & 0xfffffff0L ) | color;
    obj[ MKDOWNS ].ob_spec = ( obj[ MKDOWNS ].ob_spec & 0xfffffff0L ) | color;
}
#endif
	
/* Adjust Object Positions */

	VOID
adjobjects()
{
    REG OBJECT 	*obj;
    WORD	x,y,w,h,dx,dy;	    
	
    obj = get_tree( ADINSDIS );
    objc_gclip( obj, IUP, &dx, &dy, &x, &y, &w, &h );
    obj[ IDOWN ].ob_y = h + obj[IUP].ob_y;   
    obj[ IDRIVE ].ob_y += 2;
    obj[ ITRASH ].ob_y += 2;
    obj[ IPRINTER ].ob_y += 2;

    obj = get_tree( INWICON );
    objc_gclip( obj, WUP, &dx, &dy, &x, &y, &w, &h );
    obj[ WDOWN ].ob_y = h + obj[ WUP ].ob_y;
    obj[ WFOLDER ].ob_height = gl_hchar;
    obj[ WNONE ].ob_height = gl_hchar;
    obj[ WOK ].ob_height = gl_hchar;
    obj[ WREMOVE ].ob_height = gl_hchar;
    obj[ WSKIP ].ob_height = gl_hchar;
    obj[ WQUIT ].ob_height = gl_hchar;    

    obj = get_tree( MNSYSTEM );
    objc_gclip( obj, MFUP, &dx, &dy, &x, &y, &w, &h );
    obj[ MFDOWN ].ob_y = h + obj[ MFUP ].ob_y;
    objc_gclip( obj, MKUPS, &dx, &dy, &x, &y, &w, &h );    
    obj[ MKDOWNS ].ob_y = h + obj[ MKUPS ].ob_y;
    obj[ MFBASE ].ob_height += 2;

    obj = get_tree( ADFILEIN );
    obj[ FIOK ].ob_y   += 2;
    obj[ FISKIP ].ob_y += 2;
    obj[ FICNCL ].ob_y += 2;
    obj[ FIRONLY ].ob_y -= 1;
    obj[ FIRWRITE ].ob_y -= 1;
}
