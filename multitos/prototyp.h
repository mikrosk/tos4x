/* FILE: PROTOTYPE.H
 * --------------------------------------------------------------------
 * DATE: February 11, 1993 cjg - Created
 *
 * Description: Prototypes File for AES Sources
 */




/* FILE: MN_EVENT.C
 * --------------------------------------------------------------------
 */
UWORD	xdo_chg( OBJECT *tree, WORD iitem, REG UWORD chgvalue,
		 WORD dochg, WORD dodraw, WORD usetrap );

WORD	mu_set( OBJECT *tree, REG WORD last_item, WORD cur_item,
		WORD setit, WORD usetrap);

LONG	EvntSubMenu( WORD id, REG MENU_PTR MenuPtr );

VOID	M1_Event( WORD id, MENU_PTR MenuPtr, WORD *old_obj, WORD *cur_obj,
		  MENU_PTR SubMenuPtr, WORD *MenuDelayFlag, WORD *MenuDragFlag,
		  WORD *mn_mask, MOBLK *m1, MOBLK *m2, MRETS *mk, 
		  BOOLEAN *MenuObject );

VOID	ClearDelays( WORD *MenuDelayFlag, WORD *MenuDragFlag, WORD *mn_mask );

VOID 	ItemHandler( WORD id, REG MENU_PTR MenuPtr, WORD cur_obj, WORD old_obj,
		     MENU_PTR SubMenuPtr, WORD *MenuDelayFlag,
		     WORD *MenuDragFlag, WORD *mn_mask, WORD *MenuObject,
	     	     MOBLK *m1, MOBLK *m2, MRETS *mk );

BOOLEAN	Pop_Blit( REG MENU_PTR MenuPtr, WORD flag );

BOOLEAN ArrowCheck( REG MENU_PTR MenuPtr, OBJECT *tree, REG WORD cur_obj );

BOOLEAN	ArrowScroll( REG MENU_PTR MenuPtr, REG WORD cur_obj );

VOID	SetDRect( REG GRECT *DragRect, REG WORD mx, REG WORD my,
		  REG GRECT *SubRect );

WORD	GetMouseState( REG MRETS *mk, REG MENU_PTR MenuPtr );

BOOLEAN	CheckButton( WORD button, MRETS *mk );





/* FILE: MN_EVENT.C
 * --------------------------------------------------------------------
 */
WORD	FindIndex( WORD id, OBJECT *itree, WORD imenu );

WORD 	Get_New_Index( WORD id, OBJECT *itree, WORD imenu );

VOID	InitProcess( REG PNODE_PTR CurPtr, WORD id );

PNODE_PTR  FindProcess( WORD id );

PNODE_PTR  GetNewProc( WORD id );

VOID	mn_new( VOID );

VOID	mn_free( WORD id );

VOID	InitCluster( REG CNODE_PTR CurPtr );

CNODE_PTR  GetNewCluster( VOID );

VOID	FreeClusters( PNODE_PTR ProcPtr );

WORD	GetNewID( PNODE_PTR ProcPtr );

INDEX_PTR  GetIndexPtr( PNODE_PTR ProcPtr, WORD index );

VOID	DeleteIndex( PNODE_PTR ProcPtr, WORD index, BOOLEAN flag );




/* FILE: MN_MBAR.C
 * --------------------------------------------------------------------
 */
VOID	rect_change( LONG tree, MOBLK *prmob, WORD iob, WORD x );

VOID	mu_save( WORD saveit, LONG tree, WORD imenu);

WORD	menu_down( REG LONG tree, WORD ititle, OBJECT **itree );

BOOLEAN	mn_hdo( WORD *ptitle, OBJECT **ptree, WORD *pmenu,
		WORD *pitem, WORD *keyret );

WORD	GetObjMenu( OBJECT *tree, WORD ititle, OBJECT **itree );




/* FILE: MN_EVENT.C
 * --------------------------------------------------------------------
 */
WORD	Menu_Insert( OBJECT *tree, WORD Parent );

VOID	Menu_Delete( WORD MenuID );

VOID	mn_init( VOID );

VOID	InitMenuNode( REG MENU_PTR MenuPtr );

WORD	GetNewMenu( VOID );

WORD	FindNewMenuID( VOID );

MENU_PTR GetMenuPtr( WORD MenuID );

VOID	CheckMenuHeight( REG MENU_PTR MenuPtr );

WORD	CountMenuItems( REG MENU_PTR MenuPtr );

VOID	SetMenuHeight( REG MENU_PTR MenuPtr, WORD start_obj, BOOLEAN adjust_flag );

VOID	RestoreMenu( REG MENU_PTR MenuPtr );

VOID 	AdjustMenuPosition( REG MENU_PTR MenuPtr, WORD xpos, WORD ypos,
			    GRECT rect, BOOLEAN Horizontal_Flag,
			    BOOLEAN Vertical_Flag );

VOID	MenuScrollAdjust( REG MENU_PTR MenuPtr, WORD start_obj );

VOID	PushArrowText( REG MENU_PTR MenuPtr );

VOID	PopArrowText( REG MENU_PTR MenuPtr );

WORD	SetMaxHeight( WORD height );




/* FILE: MN_POPUP.C
 * --------------------------------------------------------------------
 */
BOOLEAN	mn_popup( WORD id, MENU *Menu, WORD xpos, WORD ypos, MENU *MData );

VOID	AssignMenuData( REG MENU_PTR MenuPtr, WORD start_obj );




/* FILE: MN_SUBMN.C
 * --------------------------------------------------------------------
 */
WORD	mn_istart( WORD id, WORD flag, OBJECT *tree, WORD menu, WORD item );

WORD	mn_iset( WORD id, OBJECT *itree, WORD imenu, WORD start_obj );

WORD	mn_iget( WORD id, OBJECT *tree, WORD imenu );

BOOLEAN	mn_attach( WORD id, WORD flag, OBJECT *tree, WORD item, MENU *Menu );

BOOLEAN	mn_setmn( WORD id, OBJECT *tree, WORD item, MENU *Menu );

BOOLEAN	mn_getmn( WORD id, OBJECT *tree, WORD item, MENU *Menu );

VOID	DetachSubMenu( WORD id, OBJECT *tree, WORD item );

BOOLEAN	CheckForSubMenu( WORD id, OBJECT *tree, WORD obj, MENU_PTR SubMenuPtr );

MENU_PTR DoSubMenu( WORD id, OBJECT *tree, WORD obj );

MENU_PTR ShowSubMenu( WORD id, WORD MenuIndex, WORD xpos, WORD ypos, GRECT *rect );

VOID	HideSubMenu( REG MENU_PTR MenuPtr );

VOID	Init_Delays( VOID );

VOID	SetDisplayDelay( LONG ms, LONG *oldvalue );

VOID	SetDragDelay( LONG ms, LONG *oldvalue );

VOID	SetScrollDelay( LONG ms, LONG *oldvalue );

VOID	SetArrowDelay( LONG ms, LONG *oldvalue );

VOID	mn_settings( WORD flag, MN_SET *Values );

BOOLEAN	CountLevel( VOID );





/* FILE: MN_TOOLS.C
 * --------------------------------------------------------------------
 */
VOID	ObjcDraw( OBJECT *tree, WORD obj, GRECT *rect );

VOID	rc_2xy( GRECT *r, WORD *pxy );









/* FILE: GEMGRLIB.C
 * --------------------------------------------------------------------
 */
WORD	gr_stilldn( WORD out, WORD x, WORD y, WORD w, WORD h );

VOID	gr_setup( WORD color );

VOID	gr_clamp( WORD xorigin, WORD yorigin, WORD wmin, WORD hmin,
		  WORD *pneww, WORD *pnewh );

VOID	gr_scale( REG WORD xdist, REG WORD ydist, WORD *pcnt,
		  REG WORD *pxstep, REG WORD *pystep );

VOID	gr_stepcalc( WORD orgw, WORD orgh, REG GRECT *pt, REG WORD *pcx,
		     REG WORD *pcy, WORD *pcnt, WORD *pxstep, WORD *pystep );

VOID	gr_xor( WORD clipped, WORD cnt, WORD cx, WORD cy, WORD cw, WORD ch, 
		REG WORD xstep, REG WORD ystep, WORD dowdht );

VOID	gr_draw( WORD have2box, REG GRECT *po, REG GRECT *poff );

WORD	gr_wait( REG GRECT *po, REG GRECT *poff, WORD mx, WORD my );

VOID	gr_rubwind( WORD xorigin, WORD yorigin, WORD wmin, WORD hmin,
		    GRECT *poff, WORD *pwend, WORD *phend );

VOID	gr_rubbox( WORD xorigin, WORD yorigin, WORD wmin, WORD hmin, 
		   WORD *pwend, WORD *phend );

VOID	gr_dragbox( WORD w, WORD h, REG WORD sx, REG WORD sy, GRECT *pc,
		    WORD *pdx, WORD *pdy );

VOID	gr_movebox( WORD w, WORD h, REG WORD srcx, REG WORD srcy,
		    WORD dstx, WORD dsty );

VOID	gr_growbox( REG GRECT *po, GRECT *pt );

VOID	gr_shrinkbox( REG GRECT *po, REG GRECT *pt );

WORD	gr_watchbox( REG LONG tree, REG WORD obj, WORD instate, WORD outstate );

WORD	gr_slidebox( REG LONG tree, WORD parent, WORD obj, WORD isvert );

VOID	gr_mkstate( WORD *pmx, WORD *pmy, WORD *pmstat, WORD *pkstat );

VOID	gr_arrow( WORD id );

VOID	gr_bee( WORD id );

WORD	gr_mcheck( VOID );

WORD	gr_mouse( REG WORD kind, MFORM *grmaddr );





/* FILE: GEMGSXIF.C
 * --------------------------------------------------------------------
 */
WORD	res_handle( WORD in );

WORD	res_type( WORD in );

VOID	gsx_malloc( VOID );

VOID	gsx_mfree( VOID );

VOID	gsx_mret( LONG *pmaddr, LONG *pmlen );

VOID	gsx_ncode( WORD code, WORD n, WORD m );

VOID	gsx_1code( WORD code, WORD value );

VOID	gsx_init( VOID );

VOID	gsx_graphic( REG WORD tographic);

VOID	gsx_escapes( WORD esc_code );

VOID	v_hardcopy( VOID );

VOID	gsx_wsopen( VOID );

VOID	gsx_wsclose( VOID );

VOID	ratinit( VOID );

VOID	ratexit( VOID );

VOID	bb_set( REG WORD sx, REG WORD sy, REG WORD sw, REG WORD sh,
		REG WORD *pts1, REG WORD *pts2, FDB *pfd,
		FDB *psrc, FDB *pdst );

VOID	bb_save( REG GRECT *ps );

VOID	bb_restore( REG GRECT *pr);

VOID	gsx_setmb( UWORD *boff, UWORD *moff, LONG *pdrwaddr );

VOID	gsx_resetmb( VOID );

WORD	gsx_tick( LONG tcode, LONG *ptsave );

VOID	gsx_xmfset( LONG pmfnew );

VOID	gsx_mfset( LONG pmfnew );

VOID	gsx_mxmy( WORD *pmx, WORD *pmy );

WORD	gsx_button( VOID );

VOID	gsx_moff( VOID );

VOID	gsx_mon( VOID );

VOID	v_opnwk( WORD *pwork_in, WORD *phandle, REG WORD *pwork_out, WORD *ppt_out );

VOID	v_pline( WORD count, WORD *pxyarray );

VOID	vst_clip( REG WORD clip_flag, WORD *pxyarray );

VOID	vst_height( WORD height, WORD *pchr_width, WORD *pchr_height,
		   WORD *pcell_width, WORD *pcell_height );

VOID	vr_recfl( WORD *pxyarray, WORD *pdesMFDB );

VOID	vro_cpyfm( WORD wr_mode, WORD *pxyarray, WORD *psrcMFDB, WORD *pdesMFDB );

VOID	vrt_cpyfm( WORD wr_mode, WORD *pxyarray, WORD *psrcMFDB, WORD *pdesMFDB,
		   WORD fgcolor, WORD bgcolor );

VOID	vrn_trnfm( WORD *psrcMFDB, WORD *pdesMFDB );

VOID	vsl_width( WORD width );

WORD	v_load_fonts( VOID );

WORD	v_font_name( WORD i, BYTE *name, WORD *fsmflag );

WORD	v_setfont( WORD id );

VOID	v_set_alignment( WORD hor_in, WORD ver_in );

VOID	v_setpoint( WORD point, WORD *wchar, WORD *hchar, WORD *wbox, WORD *hbox );

VOID	v_unload_font( VOID );

VOID	v_monotext( WORD x, WORD y, WORD i, WORD width );

WORD	vst_arbpt( WORD point, WORD *chwd, WORD *chht, WORD *cellwd, WORD *cellht );

VOID	vqt_width( WORD inchar, WORD *space, WORD *dummx, WORD *dummy );







/* FILE: GEMINIT.C
 * --------------------------------------------------------------------
 */
WORD	aescookie( LONG cookie, LONG *p_value );

WORD	cMiNt( VOID );

VOID	s_debug( BYTE *buffer );

VOID	s_sport( BYTE *buffer );

VOID	s_lang( BYTE *buffer );

VOID	s_sredraw( BYTE *buffer );

VOID	s_tredraw( BYTE *buffer );

VOID	s_env( BYTE *buffer );

VOID	ldaes( BYTE *inbuffer );

BYTE	*set_up( VOID );

VOID	clr_theglo( VOID );

VOID	main( VOID );

LONG	set_cache( REG LONG newcacr );

VOID	r_aescnf( VOID );

BYTE	*sk_tonext( REG BYTE *ptr );

WORD	s_aescnf( BYTE *name, WORD (*function)() );

WORD	pred_dinf( VOID );

VOID	bailout( BYTE *ptr );




/* FILE: GEMMNLIB.C
 * --------------------------------------------------------------------
 */
WORD	mn_iadd( BYTE *string, WORD state );

VOID	mn_create( VOID );

WORD	mn_bar( LONG tree, WORD showit );

WORD	mn_register( REG WORD pid, BYTE *pstr );

VOID	ch_wrect( GRECT *r, GRECT *n );






/* FILE: GEMOBED.C
 * --------------------------------------------------------------------
 */
VOID	ob_center( LONG tree, GRECT *pt );

WORD	scan_to_end( REG BYTE *pstr, REG WORD idx, BYTE chr );

VOID	ins_char( REG BYTE *str, WORD pos, BYTE chr, REG WORD tot_len );

WORD	find_pos( REG BYTE *str, REG WORD pos );

VOID	pxl_rect( REG LONG tree, REG WORD obj, WORD ch_pos, REG GRECT *pt, TEDINFO *edblk );

VOID	curfld( LONG tree, WORD obj, WORD new_pos, WORD dist, TEDINFO *edblk );

WORD	instr( REG BYTE chr, REG BYTE *str );

WORD	check( REG BYTE *in_char, BYTE valchar );

VOID	ob_stfn( WORD idx, WORD *pstart, WORD *pfinish );

WORD	ob_delit( WORD idx );

WORD	ob_edit( REG LONG tree, REG WORD obj, WORD in_char, REG WORD *idx, WORD kind );






/* FILE: GEMOBJOP.C
 * --------------------------------------------------------------------
 */
BYTE	ob_sst( LONG tree, WORD obj, REG LONG *pspec, WORD *pstate,
		WORD *ptype, REG WORD *pflags, GRECT *pt, WORD *pth );

VOID	everyobj( REG LONG tree, REG WORD this, REG WORD last, WORD (*routine)(),
		  WORD startx, WORD starty, WORD maxdep );

WORD	get_par( REG LONG tree, REG WORD obj );






/* FILE: GEMOBLIB.C
 * --------------------------------------------------------------------
 */
UWORD	far_call( WORD (*fcode)(), LONG fdata );

WORD	ob_sysvar( UWORD mode, UWORD which, UWORD inval1, UWORD inval2, 
		   UWORD *outval1, UWORD *outval2 );

VOID	ob_format( WORD just, BYTE *raw_str, BYTE *tmpl_str, BYTE *fmt_str );

WORD	ob_user( LONG tree, WORD obj, GRECT *pt, LONG spec, WORD curr_state, WORD new_state );

VOID	draw_hi( REG GRECT *prect, WORD state, WORD clip, WORD th, WORD icol );

WORD	xor16( WORD col );

WORD	xor_ok( WORD type, WORD flags, LONG spec );

VOID	just_draw( REG LONG tree, REG WORD obj, REG WORD sx, REG WORD sy);

VOID	ob_draw( REG LONG tree, WORD obj, WORD depth );

WORD	ob_find( REG LONG tree, REG WORD currobj, 
		 REG WORD depth, WORD mx, WORD my );

VOID	ob_add( REG LONG tree, REG WORD parent, REG WORD child );

VOID	ob_delete( REG LONG tree, REG WORD obj );

VOID	ob_order( REG LONG tree, REG WORD mov_obj, WORD new_pos );

VOID	ob_change( REG LONG tree, REG WORD obj, UWORD new_state, WORD redraw );

UWORD	ob_fs( LONG tree, WORD ob, WORD *pflag );

VOID	ob_actxywh( REG LONG tree, REG WORD obj, REG GRECT *pt );

VOID	ob_relxywh( LONG tree, WORD obj, GRECT *pt );

VOID	ob_setxywh( LONG tree, WORD obj, GRECT *pt );

VOID	ob_offset( REG LONG tree, REG WORD obj, REG WORD *pxoff, REG WORD *pyoff );

VOID	ob_dxywh( REG LONG tree, REG WORD obj, WORD *pdx, WORD *pdy,
		  WORD *pdw, WORD *pdh );

VOID	ob_gclip( REG LONG tree, REG WORD obj, WORD *pxoff, WORD *pyoff,
		  WORD *pxcl, WORD *pycl, WORD *pwcl, WORD *phcl );

WORD	get_prev( REG LONG tree, WORD parent, REG WORD obj );

CICON *match_planes( CICON *iconlist, WORD planes );

CICON *find_eq_or_less( CICON *iconlist, WORD planes );

VOID	gr_cicon( REG WORD state, LONG pmask, LONG pdata, BYTE *ptext,
		  REG WORD ch, WORD chx, WORD chy, REG GRECT *pi,
		  REG GRECT *pt, CICONBLK *cicon );

VOID	gsx_cblt( LONG saddr, REG UWORD sx, REG UWORD sy, REG UWORD swb,
		  LONG daddr, REG UWORD dx, REG UWORD dy, UWORD dwb,
		  UWORD w, UWORD h, UWORD rule, WORD numplanes );

VOID	convert_mask( WORD *mask, WORD *gl_mask, WORD width, WORD height );

WORD 	*fix_mono( WORD *ptr, LONG *plane_size, WORD *tot_res );

WORD	*fix_res( WORD *ptr, LONG mono_size, LONG *next_res );

VOID	fixup_cicon( WORD *ptr, WORD tot_icons, CICONBLK **carray );

VOID	get_color_rsc( BYTE *cicondata );

VOID	my_trans( LONG saddr, UWORD swb, LONG daddr, UWORD dwb, REG UWORD h, UWORD nplanes );

VOID	trans_cicon( WORD tot_icons, CICONBLK **carray );

VOID	free_cicon( CICONBLK **carray );

VOID	tran_check( BYTE *saddr, BYTE *daddr, BYTE *mask, WORD w, WORD h, WORD nplanes );

UWORD	reverse( WORD index );

WORD	get_rgb( WORD index );

VOID	expand_data( BYTE *saddr, BYTE *daddr, BYTE *mask,
		     WORD splanes, WORD dplanes, WORD w, WORD h );








/* FILE: GEMPD.C
 * --------------------------------------------------------------------
 */
WORD	facc( WORD which );

PD	*fpdnm( BYTE *pname, UWORD pid );

PD	*idtopd( WORD id );

VOID	freepds( VOID );

VOID	free_pd( PD *p );

VOID	p_nameit( PD *p, BYTE *pname );

PD 	*xget_pd( BYTE *name, WORD type );

PD	*get_pd( BYTE *name, WORD type );

PD	*pstart( REG PD *px, WORD (*pcode)(), BYTE *ldaddr );





/* FILE: GEMQUEUE.C
 * --------------------------------------------------------------------
 */
VOID	doq( WORD donq, REG PD *p, QPB *m );

WORD	aqueue( WORD isqwrite, REG EVB *e, REG QPB *lm );




/* FILE: GEMRLIST.C
 * --------------------------------------------------------------------
 */
RLIST	*newrect( VOID );

VOID	delrect( RLIST *rp, char *rlist);

RLIST	*genrlist( UWORD handle, WORD area);

WORD	brkrect( GRECT *trect, GRECT *brect, UWORD *hv_pc );

WORD	chgrlist( UWORD hv_pc, GRECT *cutrect, RLIST *oldrp, RLIST **rlist);

RLIST	*mkrect( UWORD pc, REG GRECT *trect, REG GRECT *brect );

WORD	mrgrect( RLIST *rp1, RLIST *rp2 );




/* FILE: GEMROM.C
 * --------------------------------------------------------------------
 */
WORD	rom_ram( WORD which, REG LONG pointer );

VOID	rsc_free( VOID );

WORD	rsc_read( VOID );






/* FILE: GEMRSLIB.C
 * --------------------------------------------------------------------
 */
VOID	fix_chpos( LONG pfix, WORD ifx);

VOID	rs_obfix( LONG tree, WORD curob );

BYTE	*rs_str( UWORD stnum );

LONG	get_sub( WORD rsindex, WORD rtype, WORD rsize );

LONG	get_addr( REG UWORD rstype, REG UWORD rsindex );

VOID	fix_trindex( VOID );

VOID	fix_cicon( VOID );

VOID	fix_objects( VOID );

VOID	fix_tedinfo( VOID );

VOID	fix_nptrs( WORD cnt, WORD type );

WORD	fix_ptr( WORD type, WORD index );

WORD	fix_long( REG LONG plong );

WORD	rs_sglobe( LONG pglobal );

WORD	rs_free( LONG pglobal );

WORD	rs_gaddr( LONG pglobal, UWORD rtype, UWORD rindex, REG LONG *rsaddr );

WORD	rs_saddr( LONG pglobal, UWORD rtype, UWORD rindex, LONG rsaddr );

WORD	rs_readit( LONG pglobal, LONG rsfname );

VOID	do_rsfix( LONG hdr, WORD size );

VOID	rs_fixit( LONG pglobal );

VOID	rs_rcfix( LONG pglobal, BYTE *header );

WORD	rs_load( REG LONG pglobal, LONG rsfname );




/* FILE: GEMSCLIB.C
 * --------------------------------------------------------------------
 */
VOID	sc_read( LONG pscrap );

VOID	sc_write( LONG pscrap );





/* FILE: GEMSHLIB.C
 * --------------------------------------------------------------------
 */
UWORD	sh_len( REG BYTE *path );

BYTE	*sh_argv( BYTE *file, BYTE *tail );

WORD	sys_reschange( WORD res );

WORD	sh_reschg( WORD mode, WORD res );

WORD	sh_shutdown( WORD isgem, WORD code );

WORD	sh_broadcast( WORD sender, BYTE *message );

VOID	sh_draw( BYTE *lcmd );

BYTE	*sh_name( BYTE *ppath );

WORD	sh_fork( BYTE *program, BYTE *tail, BYTE *envrn );

VOID	sh_background( VOID );

WORD	sh_read( LONG pcmd, LONG ptail );

WORD	sh_exec( WORD doex, WORD isgem, WORD isargv, BYTE *pcmd, BYTE *ptail );

WORD	sh_write( WORD doex, WORD isgem, WORD isover, BYTE *pcmd, BYTE *ptail);

UWORD	sh_get( BYTE *pbuffer, UWORD len );

WORD	sh_put( BYTE *pdata, UWORD len );

WORD	sh_tographic( VOID );

WORD	sh_toalpha( VOID );

VOID	sh_envrn( REG LONG *ppath, BYTE psrch[] );

WORD	sh_path( WORD whichone, REG BYTE *dp, REG BYTE *pname, BYTE *envrn );

WORD	sh_search( REG WORD (*routine)() );

WORD	sh_find( REG LONG pspec, REG WORD (*routine)(), BYTE *envrn, WORD pathsearch );

WORD	sh_spath( BYTE *path );

WORD	l_shell( BYTE *buffer );

PD	*idesk( WORD mode );

WORD	sh_pfind( BYTE *file, BYTE *envrn, WORD search, BYTE *pathname );

WORD	sh_chktype( BYTE *file, WORD *type );

WORD	sh_xfind( BYTE *file, BYTE *pathname );






/* FILE: GEMSIGNA.C
 * --------------------------------------------------------------------
 */
PD	*ch_mowner( WORD button );

VOID	mchange( REG WORD mx, REG WORD my );

VOID	post_mouse( REG PD *p, WORD grx, WORD gry );

VOID	tchange( REG LONG c );

VOID	bchange( WORD button, WORD clicks );

VOID	post_button( PD *p, WORD button, REG WORD clks, WORD xrat, WORD yrat );

VOID	b_click( REG WORD newstate );

VOID	b_delay( WORD amnt );

UWORD	dq( PD *p );

VOID	syskeyin( UWORD ch, WORD keyin );

VOID	kchange( UWORD ch, WORD keyin );

VOID	post_keybd( PD *p, UWORD ch, WORD keyin );

WORD	downorup( WORD button, EVB *e );

WORD	test_button( WORD button, LONG buparm );

WORD	inorout( REG EVB *e, WORD rx, WORD ry );

VOID	chkkbd( VOID );






/* FILE: GEMTCPIP.C
 * --------------------------------------------------------------------
 */
WORD	ip_talk( WORD id, BYTE *buffer );





/* FILE: GEMWMLIB.C
 * --------------------------------------------------------------------
 */
WINDOW	*srchwp( WORD handle );

VOID	setmenu( PD *p );

VOID	w_setslide( WINDOW *wp, WORD field );

VOID	w_nilit( REG WORD num, REG OBJECT olist[] );

WORD	set_desk( PD *p );

VOID	wm_clspd( PD *p, WORD message );

WINDOW	*wm_top( VOID );

WORD	wm_init( VOID );

WORD	wm_start( VOID );

WORD	wm_create( UWORD kind, REG GRECT *rect );

WORD	wmopen( WORD handle, REG GRECT *rect );

WORD	wm_open( WORD handle, REG GRECT *rect);

WORD	wmclose( WORD handle );

WORD	wm_close( WORD handle );

WORD	wmdelete( WORD handle );

WORD	wm_delete( WORD handle );

WORD	wm_get( REG WORD handle, WORD field, REG WORD ow[], WORD iw[] );

WORD	wmset( REG WORD handle, REG WORD field, REG WORD iw[] );

WORD	wm_set( REG WORD handle, REG WORD field, REG WORD iw[] );

WORD	wm_find( WORD mx, WORD my);

WORD	wm_calc( WORD type, WORD kind, WORD ix, WORD iy, WORD iw, WORD ih,
		 WORD *ox, WORD *oy, WORD *ow, WORD *oh);

VOID	wm_min( REG WORD kind, WORD *ow, WORD *oh );

WORD	wm_new( VOID );

VOID	wm_free( VOID );

WINDOW	*newwp( VOID );

WORD	newhndl( REG WINDOW *nwp);

VOID	storewp( WINDOW *wp );

WORD	totop( WORD handle, WORD caller );

WORD	tobot( WORD handle );

VOID	activate(REG WINDOW *wp, WORD topped);

VOID	setcol( REG WINDOW *wp, WORD ndx, WORD topped);

VOID	w_adjust( REG WINDOW *wp, REG GRECT *rect);

VOID	w_clipdraw( WINDOW *wp, WORD obj, GRECT *pc );

VOID	w_drawchange( GRECT *dirty, UWORD skip, UWORD stop);

VOID	w_bld( WINDOW *wp, REG WORD ob, WORD type, WORD parent,
	      LONG spec, WORD is3d );

VOID	w_obrect( WINDOW *wp, WORD ob, WORD obx, WORD oby, WORD obw, WORD obh);

VOID	w_rect( REG GRECT *raddr, WORD gx, WORD gy, WORD gw, WORD gh);

VOID	w_ted( REG TEDINFO *tedaddr, char *ptext, WORD just, WORD color);

VOID	ap_sendmsg( WORD type, WORD towhom, WORD w3, WORD w4, WORD w5, WORD w6, WORD w7);

VOID	openphanwind( PD *p );

WORD	w_tophandle( PD *p );

WORD	rd_wmmsg( PD *p, WORD buffer[] );

VOID	dk_newdraw( GRECT *px );

VOID	dk_redraw( OBJECT *obj, WORD root, GRECT *px );






/* FILE: ROMCART.C
 * --------------------------------------------------------------------
 */
WORD	 cart_init( VOID );

CARTNODE *cart_find( WORD fill );

WORD	cart_sfirst( BYTE *pdta, WORD attr );

WORD	cart_snext( VOID );

VOID	ld_cartacc( VOID );

WORD	cart_exec( BYTE *pcmd, BYTE *ptail );

WORD	c_sfirst( BYTE *path );







/* FILE: UTILITY.C
 * --------------------------------------------------------------------
 */
BYTE	*r_slash( REG BYTE *path );

VOID	lbintohex( LONG longval, BYTE buffer[] );

VOID	lbintoasc( REG LONG longval, REG BYTE buffer[] );

WORD	asctobin( BYTE *ptr, LONG *value );

VOID	r_get( REG WORD *pxywh, WORD *px, WORD *py, WORD *pw, WORD *ph );

VOID	r_set( REG WORD *pxywh, WORD x, WORD y, WORD w, WORD h );

VOID	rc_constrain( REG GRECT *pc, REG GRECT *pt );

VOID	rc_copy( REG WORD *psxywh, REG WORD *pdxywh );

VOID	rc_union( REG GRECT *p1, REG GRECT *p2 );

WORD	rc_intersect( REG GRECT *p1, REG GRECT *p2 );

UWORD	inside( REG WORD x, REG WORD y, REG GRECT *pt );

WORD	rc_equal( REG WORD *p1, REG WORD *p2 );

VOID	movs( REG WORD num, REG BYTE *ps, REG BYTE *pd );

WORD	min( WORD a, WORD b );

WORD	max( WORD a, WORD b );

VOID	bfill( REG WORD num, REG BYTE bval, REG BYTE *addr );

BYTE	toupper( REG BYTE ch );

VOID	upperstr( BYTE *str );

BYTE	*scasb( REG BYTE *p, REG BYTE b );

WORD	strlen( REG BYTE *p1 );

WORD	strcmp( REG BYTE *p1, REG BYTE *p2 );

WORD	nstrcmp( BYTE *p1, BYTE **dest );

WORD	strchk( REG BYTE s[], REG BYTE t[] );

BYTE	*strcpy( REG BYTE *ps, REG BYTE *pd );

BYTE	*strscn( REG BYTE *ps, REG BYTE *pd, REG BYTE stop );

BYTE	*strcat( REG BYTE *ps, REG BYTE *pd );

VOID	fmt_str( REG BYTE *instr, REG BYTE *outstr );

VOID	unfmt_str( REG BYTE *instr, REG BYTE *outstr );

VOID	fs_sset( LONG tree, WORD obj, LONG pstr, REG LONG *ptext, WORD *ptxtlen );

VOID	inf_sset( LONG tree, WORD obj, BYTE *pstr );

VOID	fs_sget( LONG tree, WORD obj, LONG pstr );

VOID	inf_sget( LONG tree, WORD obj, BYTE *pstr );

VOID	inf_fldset( LONG tree, WORD obj, UWORD testfld, UWORD testbit,
		    UWORD truestate, UWORD falsestate );

WORD	inf_gindex( LONG tree, WORD baseobj, WORD numobj );

WORD	inf_what( REG LONG tree, REG WORD ok, REG WORD cncl );

VOID	merge_str( REG BYTE *pdst, REG BYTE *ptmp, UWORD parms[] );

WORD	wildcmp( REG BYTE *pwild, REG BYTE *ptest );

BYTE	*nstrcpy( BYTE *src, BYTE *dest, WORD n );
