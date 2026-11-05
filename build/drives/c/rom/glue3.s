; AES and desktop variables at their 2.07 addresses (from endos to the end of the bss), linked into
; the AES object first, so the AES commons resolve to these labels.
	.bss
	.globl	retsava
	.globl	_gl_rest
	.globl	_gl_rsch
	.globl	ustak
	.globl	_diskin
	.globl	dummycmd
	.globl	execmode
	.globl	execflag
	.globl	_ad_rso
	.globl	_ml_mnho
	.globl	_ml_ctrl
	.globl	_ml_pmow
	.globl	_ml_pkow
	.globl	_fsname
	.globl	_fcopy
	.globl	_pathcop
	.globl	_defdrv
	.globl	_aautopa
	.globl	_wtcolor
	.globl	_wbcolor
	.globl	pblock
	.globl	_crit_er
	.globl	_dk_err
	.globl	savestk
	.globl	_SAV2TRP
	.globl	_savsup
	.globl	drawsp
	.globl	_aesldiv
	.globl	errsave
	.globl	errstk
	.globl	savea0
	.globl	srsave
	.globl	savsr
	.globl	psetsr
	.globl	dspstk
	.globl	retaddr
	.globl	tr_retsa
	.globl	_drwaddr
	.globl	_tikaddr
	.globl	gstksave
	.globl	tstksave
	.globl	_tiksav
	.globl	_NUM_TIC
	.globl	_CMP_TIC
	.globl	_TICKS
	.globl	gstack
	.globl	tstack
	.globl	fspec
	.globl	mydev
	.globl	oldgetbp
	.globl	oldmedia
	.globl	oldrwabs
	.globl	_maddr
	.globl	mform
	.globl	trp13are
	.globl	trp14are
	.globl	_w_inc
	.globl	_bar_max
	.globl	saveret
	.globl	_fobj
	.globl	_intout
	.globl	_xprint
	.globl	_ptsout
	.globl	_m_st
	.globl	_full
	.globl	_ctrl
	.globl	_temp
	.globl	_gl_daba
	.globl	_gl_adac
	.globl	_winp
	.globl	_rets
	.globl	_xrat
	.globl	_yrat
	.globl	_s_cache
	.globl	_gl_hcha
	.globl	_gl_nacc
	.globl	_gl_dabo
	.globl	_gl_dacn
	.globl	_gl_bdel
	.globl	_ad_hgmi
	.globl	_gl_pacc
	.globl	_desk_ac
	.globl	_ib
	.globl	_bi
	.globl	_gl_bcli
	.globl	_ad_fsna
	.globl	_gl_hand
	.globl	_ad_armi
	.globl	_ad_sele
	.globl	_g_buffe
	.globl	_s_defdi
	.globl	_ad_fsel
	.globl	_gl_dcli
	.globl	_cdele_s
	.globl	_gl_heig
	.globl	_gl_anam
	.globl	_ad_pfil
	.globl	_ad_shcm
	.globl	_ad_fpat
	.globl	_gl_apid
	.globl	_gl_ainf
	.globl	_gl_bdes
	.globl	_gl_dcin
	.globl	_gl_recd
	.globl	_q_chang
	.globl	_gh_buff
	.globl	_ad_path
	.globl	_chxcach
	.globl	_iconadd
	.globl	old_bcod
	.globl	_gl_hcli
	.globl	_gl_bvha
	.globl	_ad_shta
	.globl	_ad_stde
	.globl	_used_ac
	.globl	_cbit_sa
	.globl	_back_up
	.globl	_gl_wcha
	.globl	_ad_fsdt
	.globl	_dr
	.globl	_ad_wind
	.globl	_gl_mode
	.globl	_gl_bpen
	.globl	_gl_cmfo
	.globl	_gl_bvdi
	.globl	_f_renam
	.globl	_ad_inti
	.globl	_gl_hsch
	.globl	_backgro
	.globl	_menu_ad
	.globl	_gl_moff
	.globl	_gl_rcen
	.globl	_sh_isca
	.globl	_hdr_buf
	.globl	_d_maxco
	.globl	_d_level
	.globl	_gl_grap
	.globl	_gl_lcol
	.globl	_f_abort
	.globl	_f_level
	.globl	old_mcod
	.globl	_gl_npla
	.globl	_gl_tick
	.globl	_path1
	.globl	_r_dicon
	.globl	_DOS_AX
	.globl	_gl_mlen
	.globl	_gl_mask
	.globl	_gl_ncol
	.globl	_path2
	.globl	_d_displ
	.globl	_w_walkf
	.globl	_ad_envr
	.globl	_desk_pi
	.globl	_winhead
	.globl	_path3
	.globl	_pref_sa
	.globl	_gl_newd
	.globl	_wasclr
	.globl	_gl_rmna
	.globl	_pglobal
	.globl	_inf_pat
	.globl	_gl_wcli
	.globl	_cart_dt
	.globl	_gl_mkre
	.globl	_gl_awin
	.globl	_g_autob
	.globl	_ad_titl
	.globl	_gl_ctwa
	.globl	_gl_rbuf
	.globl	_p_timed
	.globl	_gl_xcli
	.globl	_sh_isge
	.globl	_appfree
	.globl	_mentabl
	.globl	_gl_ycli
	.globl	_gl_hbox
	.globl	_ad_fstr
	.globl	_gl_omfo
	.globl	_gl_rlen
	.globl	_gl_rmen
	.globl	_gl_tcol
	.globl	_sys_ada
	.globl	_W_TREE
	.globl	_gl_mnpi
	.globl	_pr_mcli
	.globl	_appnode
	.globl	_gl_wsch
	.globl	_iconmem
	.globl	_rs_glob
	.globl	_elinkof
	.globl	_gl_play
	.globl	_comtail
	.globl	_gl_font
	.globl	_gl_cown
	.globl	_font_sa
	.globl	_gl_widt
	.globl	_sh_doex
	.globl	_gl_pglu
	.globl	_ad_sysg
	.globl	_gl_rful
	.globl	_gl_patt
	.globl	_gl_rscr
	.globl	_fs_firs
	.globl	_appl_ms
	.globl	_ml_ocnt
	.globl	_newbuff
	.globl	_restabl
	.globl	_cart_pt
	.globl	_fs_coun
	.globl	_gl_newr
	.globl	_fs_fnum
	.globl	_maxicon
	.globl	_x_index
	.globl	_gl_btru
	.globl	_ccopy_s
	.globl	_numfile
	.globl	_gl_hspt
	.globl	_gl_hpts
	.globl	_wind_ms
	.globl	_gl_kown
	.globl	_crt_err
	.globl	_gl_wbox
	.globl	_gl_mntr
	.globl	_gl_mown
	.globl	_autofil
	.globl	_gl_wtre
	.globl	_gemsize
	.globl	_wind_sp
	.globl	_lp_star
	.globl	_s_fullp
	.globl	_gl_rzer
	.globl	_gl_mous
	.globl	_s_stofi
	.globl	_gl_nrow
	.globl	_infsize
	.globl	_numicon
	.globl	_sh_up
	.globl	_filestr
	.globl	_tmpmoff
	.globl	_windspe
	.globl	_gl_stor
	.globl	_ctldown
	.globl	_autoexe
	.globl	_fs_topp
	.globl	_d_nrows
	.globl	_gl_wtop
	.globl	_write_s
	.globl	_applist
	.globl	_desksiz
	.globl	_deskptr
	.globl	_o_statu
	.globl	_gl_wspt
	.globl	_gl_wpts
	.globl	_pr_xrat
	.globl	_pr_butt
	.globl	_drawstk
	.globl	_afile
	.globl	_pr_yrat
	.globl	_d_dir
	.globl	_numdirs
	.globl	_edblk
	.globl	_pxyarra
	.globl	_x_statu
	.globl	_tolsize
	.globl	_dicon
	.globl	_tbutton
	.globl	_m_cpu
	.globl	_nogem
	.globl	_deskp
	.globl	_gl_mx
	.globl	_gl_my
	.globl	_fpcnt
	.globl	_o_win
	.globl	_cpbox
	.globl	_gl_ws
	.globl	_i_statu
	.globl	_x_cur
	.globl	_winpd
	.globl	_intin
	.globl	_x_win
	.globl	_cda
	.globl	_wwait
	.globl	_W_ACTIV
	.globl	_DOS_ERR
	.globl	_ptsin
	.globl	_dpd
	.globl	_fph
	.globl	_dlr
	.globl	_drl
	.globl	_D
	.globl	_eul
	.globl	_fpt
	.globl	_nrl
	.globl	_rlr
	.globl	_slr
	.globl	_rul
	.globl	_evx
	.globl	_zlr
	.globl	_backid
	.globl	_g_flag
	.globl	_q_addr
	.globl	_d_path
	.globl	_lp_end
	.globl	_sh_gem
	.globl	_mclick
	.globl	_gl_fis
	.globl	_lp_mid
	.globl	_no_aes
	.globl	_dtabuf
	.globl	_ctl_pd
	.globl	_rename
	.globl	_opcode
	.globl	_gl_src
	.globl	_q_path
	.globl	_o_item
	.globl	_d_exit
	.globl	_gl_dst
	.globl	_gl_rfs
	.globl	_rs_hdr
	.globl	_gl_tmp
	.globl	_nodesk
	.globl	_srcbuf
	.globl	_er_num
	.globl	_srclen
	.globl	_curpid
	.globl	_indisp
	.globl	_dstbuf
	.globl	_infork
	.globl	_dstlen
	.globl	_apsize
	.globl	_kstate
	.globl	_s_view
	.globl	_fixsrc
	.globl	_gemptr
	.globl	_o_type
	.globl	_fixdst
	.globl	_contrl
	.globl	_d_xywh
	.globl	_infptr
	.globl	_f_xywh
	.globl	_mtrans
	.globl	_pxpath
	.globl	_warray
	.globl	_x_type
	.globl	_s_sort
	.globl	_ww_win
	.globl	_tmpmon
	.globl	_button
retsava:
	ds.b	4
_gl_rest:
	ds.b	2
_gl_rsch:
	ds.b	2
ustak:
	ds.b	132
_diskin:
	ds.b	2
dummycmd:
	ds.b	2
execmode:
	ds.b	2
execflag:
	ds.b	6
_ad_rso:
	ds.b	4
_ml_mnho:
	ds.b	4
_ml_ctrl:
	ds.b	8
_ml_pmow:
	ds.b	4
_ml_pkow:
	ds.b	4
_fsname:
	ds.b	40
_fcopy:
	ds.b	40
_pathcop:
	ds.b	4
_defdrv:
	ds.b	2
_aautopa:
	ds.b	128
_wtcolor:
	ds.b	38
_wbcolor:
	ds.b	38
pblock:
	ds.b	20
_crit_er:
	ds.b	4
_dk_err:
	ds.b	4
savestk:
	ds.b	4
_SAV2TRP:
	ds.b	4
_savsup:
	ds.b	4
drawsp:
	ds.b	4
_aesldiv:
	ds.b	4
errsave:
	ds.b	4
errstk:
	ds.b	1028
savea0:
	ds.b	4
srsave:
	ds.b	2
savsr:
	ds.b	2
psetsr:
	ds.b	2
dspstk:
	ds.b	644
retaddr:
	ds.b	4
tr_retsa:
	ds.b	4
_drwaddr:
	ds.b	4
_tikaddr:
	ds.b	4
gstksave:
	ds.b	4
tstksave:
	ds.b	4
_tiksav:
	ds.b	4
_NUM_TIC:
	ds.b	4
_CMP_TIC:
	ds.b	4
_TICKS:
	ds.b	4
gstack:
	ds.b	96
tstack:
	ds.b	96
fspec:
	ds.b	8
mydev:
	ds.b	2
oldgetbp:
	ds.b	4
oldmedia:
	ds.b	4
oldrwabs:
	ds.b	8
_maddr:
	ds.b	4
mform:
	ds.b	74
trp13are:
	ds.b	4
trp14are:
	ds.b	4
_w_inc:
	ds.b	2
_bar_max:
	ds.b	2
saveret:
	ds.b	4
_fobj:
	ds.b	8
_intout:
	ds.b	20
_xprint:
	ds.b	2
_ptsout:
	ds.b	20
_m_st:
	ds.b	2
_full:
	ds.b	8
_ctrl:
	ds.b	8
_temp:
	ds.b	50
_gl_daba:
	ds.b	2
_gl_adac:
	ds.b	24
_winp:
	ds.b	6
_rets:
	ds.b	12
_xrat:
	ds.b	2
_yrat:
	ds.b	2
_s_cache:
	ds.b	2
_gl_hcha:
	ds.b	2
_gl_nacc:
	ds.b	2
_gl_dabo:
	ds.b	2
_gl_dacn:
	ds.b	2
_gl_bdel:
	ds.b	2
_ad_hgmi:
	ds.b	4
_gl_pacc:
	ds.b	24
_desk_ac:
	ds.b	24
_ib:
	ds.b	34
_bi:
	ds.b	14
_gl_bcli:
	ds.b	2
_ad_fsna:
	ds.b	4
_gl_hand:
	ds.b	2
_ad_armi:
	ds.b	4
_ad_sele:
	ds.b	4
_g_buffe:
	ds.b	160
_s_defdi:
	ds.b	2
_ad_fsel:
	ds.b	4
_gl_dcli:
	ds.b	2
_cdele_s:
	ds.b	2
_gl_heig:
	ds.b	2
_gl_anam:
	ds.b	28
_ad_pfil:
	ds.b	4
_ad_shcm:
	ds.b	4
_ad_fpat:
	ds.b	4
_gl_apid:
	ds.b	2
_gl_ainf:
	ds.b	28
_gl_bdes:
	ds.b	2
_gl_dcin:
	ds.b	2
_gl_recd:
	ds.b	2
_q_chang:
	ds.b	2
_gh_buff:
	ds.b	4
_ad_path:
	ds.b	4
_chxcach:
	ds.b	8
_iconadd:
	ds.b	4
old_bcod:
	ds.b	4
_gl_hcli:
	ds.b	2
_gl_bvha:
	ds.b	2
_ad_shta:
	ds.b	4
_ad_stde:
	ds.b	4
_used_ac:
	ds.b	2
_cbit_sa:
	ds.b	2
_back_up:
	ds.b	2
_gl_wcha:
	ds.b	2
_ad_fsdt:
	ds.b	4
_dr:
	ds.b	32
_ad_wind:
	ds.b	4
_gl_mode:
	ds.b	2
_gl_bpen:
	ds.b	2
_gl_cmfo:
	ds.b	74
_gl_bvdi:
	ds.b	2
_f_renam:
	ds.b	2
_ad_inti:
	ds.b	4
_gl_hsch:
	ds.b	2
_backgro:
	ds.b	4
_menu_ad:
	ds.b	4
_gl_moff:
	ds.b	2
_gl_rcen:
	ds.b	8
_sh_isca:
	ds.b	2
_hdr_buf:
	ds.b	36
_d_maxco:
	ds.b	2
_d_level:
	ds.b	2
_gl_grap:
	ds.b	2
_gl_lcol:
	ds.b	2
_f_abort:
	ds.b	2
_f_level:
	ds.b	2
old_mcod:
	ds.b	4
_gl_npla:
	ds.b	2
_gl_tick:
	ds.b	2
_path1:
	ds.b	128
_r_dicon:
	ds.b	8
_DOS_AX:
	ds.b	2
_gl_mlen:
	ds.b	4
_gl_mask:
	ds.b	2
_gl_ncol:
	ds.b	2
_path2:
	ds.b	128
_d_displ:
	ds.b	2
_w_walkf:
	ds.b	2
_ad_envr:
	ds.b	4
_desk_pi:
	ds.b	12
_winhead:
	ds.b	4
_path3:
	ds.b	4
_pref_sa:
	ds.b	2
_gl_newd:
	ds.b	4
_wasclr:
	ds.b	2
_gl_rmna:
	ds.b	8
_pglobal:
	ds.b	30
_inf_pat:
	ds.b	128
_gl_wcli:
	ds.b	2
_cart_dt:
	ds.b	4
_gl_mkre:
	ds.b	12
_gl_awin:
	ds.b	4
_g_autob:
	ds.b	128
_ad_titl:
	ds.b	4
_gl_ctwa:
	ds.b	10
_gl_rbuf:
	ds.b	4
_p_timed:
	ds.b	2
_gl_xcli:
	ds.b	2
_sh_isge:
	ds.b	2
_appfree:
	ds.b	4
_mentabl:
	ds.b	30
_gl_ycli:
	ds.b	2
_gl_hbox:
	ds.b	2
_ad_fstr:
	ds.b	4
_gl_omfo:
	ds.b	74
_gl_rlen:
	ds.b	2
_gl_rmen:
	ds.b	8
_gl_tcol:
	ds.b	2
_sys_ada:
	ds.b	4
_W_TREE:
	ds.b	192
_gl_mnpi:
	ds.b	4
_pr_mcli:
	ds.b	2
_appnode:
	ds.b	4
_gl_wsch:
	ds.b	2
_iconmem:
	ds.b	4
_rs_glob:
	ds.b	4
_elinkof:
	ds.b	4
_gl_play:
	ds.b	2
_comtail:
	ds.b	128
_gl_font:
	ds.b	2
_gl_cown:
	ds.b	4
_font_sa:
	ds.b	2
_gl_widt:
	ds.b	2
_sh_doex:
	ds.b	2
_gl_pglu:
	ds.b	4
_ad_sysg:
	ds.b	4
_gl_rful:
	ds.b	8
_gl_patt:
	ds.b	2
_gl_rscr:
	ds.b	8
_fs_firs:
	ds.b	2
_appl_ms:
	ds.b	16
_ml_ocnt:
	ds.b	2
_newbuff:
	ds.b	4
_restabl:
	ds.b	6
_cart_pt:
	ds.b	4
_fs_coun:
	ds.b	2
_gl_newr:
	ds.b	2
_fs_fnum:
	ds.b	4
_maxicon:
	ds.b	2
_x_index:
	ds.b	2
_gl_btru:
	ds.b	2
_ccopy_s:
	ds.b	2
_numfile:
	ds.b	4
_gl_hspt:
	ds.b	2
_gl_hpts:
	ds.b	2
_wind_ms:
	ds.b	16
_gl_kown:
	ds.b	4
_crt_err:
	ds.b	2
_gl_wbox:
	ds.b	2
_gl_mntr:
	ds.b	4
_gl_mown:
	ds.b	4
_autofil:
	ds.b	128
_gl_wtre:
	ds.b	4
_gemsize:
	ds.b	2
_wind_sp:
	ds.b	10
_lp_star:
	ds.b	4
_s_fullp:
	ds.b	2
_gl_rzer:
	ds.b	8
_gl_mous:
	ds.b	2
_s_stofi:
	ds.b	2
_gl_nrow:
	ds.b	2
_infsize:
	ds.b	2
_numicon:
	ds.b	2
_sh_up:
	ds.b	2
_filestr:
	ds.b	14
_tmpmoff:
	ds.b	2
_windspe:
	ds.b	2
_gl_stor:
	ds.b	4
_ctldown:
	ds.b	2
_autoexe:
	ds.b	2
_fs_topp:
	ds.b	2
_d_nrows:
	ds.b	2
_gl_wtop:
	ds.b	2
_write_s:
	ds.b	2
_applist:
	ds.b	4
_desksiz:
	ds.b	2
_deskptr:
	ds.b	4
_o_statu:
	ds.b	2
_gl_wspt:
	ds.b	2
_gl_wpts:
	ds.b	2
_pr_xrat:
	ds.b	2
_pr_butt:
	ds.b	2
_drawstk:
	ds.b	4
_afile:
	ds.b	4192
_pr_yrat:
	ds.b	2
_d_dir:
	ds.b	2
_numdirs:
	ds.b	4
_edblk:
	ds.b	28
_pxyarra:
	ds.b	20
_x_statu:
	ds.b	2
_tolsize:
	ds.b	4
_dicon:
	ds.b	8
_tbutton:
	ds.b	2
_m_cpu:
	ds.b	2
_nogem:
	ds.b	2
_deskp:
	ds.b	6
_gl_mx:
	ds.b	2
_gl_my:
	ds.b	2
_fpcnt:
	ds.b	2
_o_win:
	ds.b	4
_cpbox:
	ds.b	4
_gl_ws:
	ds.b	114
_i_statu:
	ds.b	2
_x_cur:
	ds.b	2
_winpd:
	ds.b	1136
_intin:
	ds.b	256
_x_win:
	ds.b	4
_cda:
	ds.b	4
_wwait:
	ds.b	2
_W_ACTIV:
	ds.b	456
_DOS_ERR:
	ds.b	2
_ptsin:
	ds.b	40
_dpd:
	ds.b	4
_fph:
	ds.b	2
_dlr:
	ds.b	4
_drl:
	ds.b	4
_D:
	ds.b	13982
_eul:
	ds.b	4
_fpt:
	ds.b	2
_nrl:
	ds.b	4
_rlr:
	ds.b	4
_slr:
	ds.b	4
_rul:
	ds.b	4
_evx:
	ds.b	28
_zlr:
	ds.b	4
_backid:
	ds.b	4
_g_flag:
	ds.b	2
_q_addr:
	ds.b	4
_d_path:
	ds.b	4
_lp_end:
	ds.b	4
_sh_gem:
	ds.b	2
_mclick:
	ds.b	2
_gl_fis:
	ds.b	2
_lp_mid:
	ds.b	4
_no_aes:
	ds.b	2
_dtabuf:
	ds.b	48
_ctl_pd:
	ds.b	4
_rename:
	ds.b	2
_opcode:
	ds.b	2
_gl_src:
	ds.b	20
_q_path:
	ds.b	40
_o_item:
	ds.b	2
_d_exit:
	ds.b	2
_gl_dst:
	ds.b	20
_gl_rfs:
	ds.b	8
_rs_hdr:
	ds.b	4
_gl_tmp:
	ds.b	20
_nodesk:
	ds.b	2
_srcbuf:
	ds.b	2
_er_num:
	ds.b	2
_srclen:
	ds.b	2
_curpid:
	ds.b	2
_indisp:
	ds.b	2
_dstbuf:
	ds.b	2
_infork:
	ds.b	2
_dstlen:
	ds.b	2
_apsize:
	ds.b	2
_kstate:
	ds.b	2
_s_view:
	ds.b	2
_fixsrc:
	ds.b	4
_gemptr:
	ds.b	4
_o_type:
	ds.b	2
_fixdst:
	ds.b	4
_contrl:
	ds.b	24
_d_xywh:
	ds.b	36
_infptr:
	ds.b	4
_f_xywh:
	ds.b	36
_mtrans:
	ds.b	2
_pxpath:
	ds.b	4
_warray:
	ds.b	32
_x_type:
	ds.b	2
_s_sort:
	ds.b	2
_ww_win:
	ds.b	4
_tmpmon:
	ds.b	2
_button:
	ds.b	2
