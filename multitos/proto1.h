/* FILE: GEMAPLIB.C
 * --------------------------------------------------------------------
 */
WORD 	ap_search(WORD mode, BYTE *name, WORD *type, WORD *paesid);
PD 	*get_aespd(CBLK *pcrys_blk);
WORD	ap_getinfo(WORD mode, WORD *out1, WORD *out2, WORD *out3,
			WORD *out4);
WORD 	ap_init(REG LONG pglobal);
WORD    ap_exit(PD *p, CBLK *pcrys_blk);
WORD 	ap_term(WORD id);
WORD 	ap_name(WORD id, BYTE *buff);
WORD 	rd_inmsg(WORD length, BYTE *buffer);
WORD 	ap_rdwr(WORD code, WORD id, WORD length, BYTE *pbuff);
WORD 	rd_mymsg(BYTE *buffer);
WORD 	ap_find(BYTE *pname);
VOID	ap_tplay(REG LONG pbuff, WORD length, WORD scale);
WORD 	ap_trecd(REG LONG pbuff, REG WORD length);

/* FILE: GEMAPLIB.C
 * --------------------------------------------------------------------
 */

EVB 	*get_evb(PD *p);
VOID	evremove(REG EVB *e, UWORD ret);
VOID 	evinsert(REG EVB *e, EVB **root);
VOID	takeoff(REG EVB *e);
EVSPEC	mwait(EVSPEC mask);
EVSPEC	iasync(WORD afunc, REG LONG aparm);
EVB	*x_eret(PD *p, EVSPEC mask);
EVB	*eret(EVSPEC mask);
UWORD	aret(EVSPEC mask);
EVSPEC 	acancel(REG PD *p, EVSPEC m);

/* FILE: GEMBASE.C
 * --------------------------------------------------------------------
 */

/******* NO FUNCTIONS IN THIS FILE ************/

/* FILE: GEMBIND.C
 * --------------------------------------------------------------------
 */

UWORD 	do_chg(OBJECT *tree, WORD iitem, REG UWORD chgvalue, WORD dochg,
			WORD dodraw, WORD chkdisabled);
VOID	crysbind(REG CBLK *pcrys_blk);
WORD 	chkbind(REG CBLK *pcrys_blk, LONG what);

/* FILE: APGRLIB.C
 * --------------------------------------------------------------------
 */

VOID 	gr_inside(REG GRECT *pt, REG WORD th);
VOID 	gr_rect(UWORD icolor, REG UWORD ipattern, REG GRECT *pt);
WORD	gr_just(WORD just, WORD font, LONG ptext, REG WORD w,
		REG WORD h, REG GRECT *pt);
VOID 	gr_gtext(WORD just, WORD font, LONG ptext, GRECT *pt, 
		WORD tmode);
VOID 	gr_crack(REG UWORD color, WORD *pbc, WORD *ptc, WORD *pic,
		REG WORD *pip, REG WORD *pmd);
VOID	gr_gicon(REG WORD state, LONG pmask, LONG pdata, LONG ptext,
		REG WORD ch, WORD chx, WORD chy, REG GRECT *pi,
		REG GRECT *pt);
VOID 	gr_box(WORD x, WORD y, WORD w, WORD h, REG WORD th);

/* FILE: APGSXIF.C
 * --------------------------------------------------------------------
 */

BOOLEAN	gsx_sclip(GRECT *pt);
VOID	gsx_gclip(GRECT *pt);
WORD	gsx_chkclip(REG GRECT *pt);
VOID	gsx_pline(WORD offx, WORD offy, REG WORD cnt, REG WORD *pts);
VOID	gsx_cline(UWORD x1, UWORD y1, UWORD x2, UWORD y2);
VOID	gsx_attr(UWORD text, REG UWORD mode, REG UWORD color);
VOID	gsx_bxpts(REG GRECT *pt);
VOID	gsx_box(GRECT *pt);
VOID	gsx_xbox(GRECT *pt);
VOID	gsx_xcbox(REG GRECT *pt);
VOID	gsx_fix(REG FDB *pfd, REG LONG theaddr, REG WORD wb, WORD h);
VOID 	gsx_blt(LONG saddr, REG UWORD sx, REG UWORD sy, REG UWORD swb,
		LONG daddr, REG UWORD dx, REG UWORD dy, UWORD dwb,
		UWORD w, UWORD h, UWORD rule, WORD fgcolor, WORD bgcolor);
VOID	bb_screen(WORD scrule, WORD scsx, WORD scsy, WORD scdx, WORD scdy,
		WORD scw, WORD sch);
VOID	gsx_trans(LONG saddr, UWORD swb, LONG daddr, UWORD dwb, REG UWORD h,
		WORD fg, WORD bg);
VOID	s_pntsize(BYTE *buffer);
VOID	gsx_lfont(BYTE *buffer);
VOID	gsx_start(VOID);
VOID	bb_fill(WORD mode, WORD fis, REG WORD patt, REG WORD hx,
		REG WORD hy, REG WORD hw, REG WORD hh);
UWORD	ch_width(WORD fn);
UWORD	ch_height(WORD fn);
VOID	gsx_tcalc(REG WORD font, LONG ptext, REG WORD *ptextw,
		REG WORD *ptexth, REG WORD *pnumchs);
VOID	gsx_tblt(REG WORD tb_f, REG WORD x, REG WORD y, WORD tb_nc);
VOID	gsx_xline(WORD ptscount, REG WORD *ppoints);

/* FILE: CTRLBIND.C
 * --------------------------------------------------------------------
 */

WORD 	crys_if(int opcode);
VOID	kickaes(VOID);
UWORD	appl_init(VOID);
WORD 	appl_exit(VOID);
WORD 	appl_find(BYTE *name);
WORD 	appl_search(WORD mode, BYTE *name, WORD *type, WORD *id);
VOID	appl_term(WORD id);
WORD 	appl_write(WORD rwid, WORD length, BYTE *pbuff);
WORD 	evnt_multi(UWORD flags, UWORD blck, UWORD bmsk, UWORD bst,
			UWORD m1flags, UWORD m1x, UWORD m1y, UWORD m1w,
			UWORD m1h, UWORD m2flags, UWORD m2x,
			UWORD m2y, UWORD m2w, UWORD m2h, LONG mepbuff,
			UWORD tlc, UWORD thc, UWORD *pmx, UWORD *pmy,
			UWORD *pmb, UWORD *pks, UWORD *pkr, UWORD *pbr);
WORD	evnt_timer(UWORD locnt, UWORD hicnt);
WORD	form_error(WORD number);
WORD 	form_alert(WORD button, BYTE *string);
WORD 	form_dial(WORD dtype, WORD ix, WORD iy, WORD iw, WORD ih,
			WORD x, WORD y, WORD w, WORD h);
WORD 	fsel_exinput(LONG pipath, LONG pisel, WORD *pbutton, BYTE *label);
WORD 	graf_mouse(WORD state, LONG form);
WORD 	graf_dragbox(WORD w, WORD h, WORD sx, WORD sy, WORD xc, WORD yc,
			WORD wc, WORD hc, WORD *pdx, WORD *pdy);
VOID	graf_mkstate(WORD *pmx, WORD *pmy, WORD *pmstate, WORD *pkstate);
WORD 	graf_rubbox( WORD xorigin, WORD yorigin, WORD wmin, WORD hmin,
			WORD *pwend, WORD *phend);
WORD 	graf_slidebox(OBJECT *tree, WORD parent, WORD obj, WORD isvert);
WORD 	graf_watchbox(OBJECT *tree, WORD obj, UWORD instate, UWORD outstate);
WORD 	menu_bar(OBJECT *tree, WORD showit);
WORD 	menu_tnormal(LONG tree, WORD titlenum, WORD normalit);
WORD 	menu_popup(MENU *Menu, WORD xpos, WORD ypos, MENU *MData);
WORD 	menu_attach(WORD flag, OBJECT *tree, WORD item, MENU *Menu);
WORD 	menu_istart(WORD flag, OBJECT *tree, WORD menu, WORD item);
WORD 	menu_settings(WORD flag, MN_SET *Values);
WORD 	objc_change( LONG tree, WORD drawob, WORD depth, WORD xc, WORD yc,
			WORD wc, WORD hc, WORD newstate, WORD redraw);
WORD 	objc_delete(LONG tree, WORD delob);
WORD 	objc_find(OBJECT *tree, WORD startob, WORD depth, WORD mx, WORD my);
WORD 	objc_offset(OBJECT *tree, WORD obj, WORD *poffx, WORD *poffy);
WORD 	objc_draw(LONG tree, WORD drawob, WORD depth, WORD xc, WORD yc,
			WORD wc, WORD hc);
WORD 	rsrc_gaddr(WORD rstype, WORD rsid, LONG *paddr);
WORD 	rsrc_rcfix(LONG header);
WORD	shel_envrn(LONG ppath, LONG psrch);
WORD 	shel_write(WORD doex, WORD isgr, WORD iscr, LONG pcmd, LONG ptail);
WORD 	wind_find(WORD mx, WORD my);
WORD 	wind_get(WORD w_handle, WORD w_field, WORD *pw1, WORD *pw2,
			WORD *pw3, WORD *pw4);
WORD 	wind_close(WORD handle);
WORD 	wind_open(WORD handle, WORD wx, WORD wy, WORD ww, WORD wh);
WORD 	wind_set(WORD w_handle, WORD w_field, WORD w2, WORD w3,
			WORD w4, WORD w5);
WORD 	wind_update(WORD mode);

/* FILE: DESKFILE.C
 * --------------------------------------------------------------------
 */
WORD 	pri_str(WORD where, BYTE *ptr);
VOID	pri_win(VOID);
VOID	newfolder( REG WINDOW *win);
VOID	sort_file(WINDOW *win, WORD mode);
VOID	set_newview(WORD index, REG WINDOW *win);
WORD 	read_files(REG WINDOW *win, WORD attr);

