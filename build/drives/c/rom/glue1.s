; bss after the BIOS: VDI and GEMDOS variables at their 2.07 addresses ($1644 to endos);
; the objects hold no bss of their own, their commons resolve to these labels; the Atari BIOS
; names (prtblk.c, rwabs.c, flop.s) sit at the same addresses as the 2.06 names.
	.bss
	.globl	_diskbuf
	.globl	_seed_ty
	.globl	_search_
	.globl	_Qbottom
	.globl	_qTop
	.globl	_qPtr
	.globl	_qTmp
	.globl	_qHole
	.globl	_oldy
	.globl	_oldxlef
	.globl	_oldxrig
	.globl	_newxlef
	.globl	_newxrig
	.globl	_xleft
	.globl	_xright
	.globl	_directi
	.globl	_done
	.globl	_gotseed
	.globl	_leftold
	.globl	_leftdir
	.globl	_leftsee
	.globl	_h_align
	.globl	_leftcol
	.globl	_collisi
	.globl	_v_align
	.globl	_Q
	.globl	_width
	.globl	_height
	.globl	_wordx
	.globl	_wordy
	.globl	_rmword
	.globl	_rmwordx
	.globl	_rmwordy
	.globl	_charx
	.globl	_chary
	.globl	_rmchar
	.globl	_rmcharx
	.globl	_rmchary
	.globl	_FLIP_Y
	.globl	_deftxbu
	.globl	ptsin_ar
	.globl	_angle
	.globl	_vdivars
	.globl	_beg_ang
	.globl	_CUR_FON
	.globl	_del_ang
	.globl	_deltay
	.globl	_deltay1
	.globl	_deltay2
	.globl	_end_ang
	.globl	_fil_int
	.globl	_fill_ma
	.globl	_fill_mi
	.globl	_n_steps
	.globl	_odeltay
	.globl	_s_begst
	.globl	_s_endst
	.globl	_s_fil_c
	.globl	_s_fill_
	.globl	_s_patms
	.globl	_s_patpt
	.globl	_start
	.globl	_xc
	.globl	_xrad
	.globl	__Y
	.globl	_yc
	.globl	_yrad
	.globl	_m_poshx
	.globl	_m_poshy
	.globl	_m_plane
	.globl	_m_cdb_b
	.globl	_m_cdb_f
	.globl	_mask_fo
	.globl	_INQ_TAB
	.globl	_DEV_TAB
	.globl	_GCURX
	.globl	_GCURY
	.globl	_HIDE_CN
	.globl	_MOUSE_B
	.globl	_REQ_COL
	.globl	_SIZ_TAB
	.globl	_TERM_CH
	.globl	_chc_mod
	.globl	_cur_wor
	.globl	_def_fon
	.globl	_font_ri
	.globl	_ini_fon
	.globl	_line_cw
	.globl	_loc_mod
	.globl	_num_qc_
	.globl	_q_circl
	.globl	_str_mod
	.globl	_val_mod
	.globl	_cur_ms_
	.globl	_resrvd1
	.globl	_disab_c
	.globl	_xydraw
	.globl	_draw_fl
	.globl	_mouse_f
	.globl	_retsav
	.globl	_sav_cxy
	.globl	_save_le
	.globl	_save_ad
	.globl	_save_st
	.globl	_save_ar
	.globl	_tim_add
	.globl	_tim_cha
	.globl	_user_bu
	.globl	_user_cu
	.globl	_user_mo
	.globl	_v_cel_h
	.globl	_v_celmx
	.globl	_v_celmy
	.globl	_v_cel_w
	.globl	_v_col_b
	.globl	_v_col_f
	.globl	_v_cur_a
	.globl	_v_cur_o
	.globl	_v_curcx
	.globl	_v_curcy
	.globl	_vct_ini
	.globl	_v_cur_t
	.globl	_v_fnt_a
	.globl	_v_fnt_n
	.globl	_v_fnt_s
	.globl	_v_fnt_w
	.globl	_v_hz_re
	.globl	_v_off_a
	.globl	_v_stat_
	.globl	_v_delay
	.globl	_v_vt_re
	.globl	_bytes_l
	.globl	_v_plane
	.globl	lineavar
	.globl	_v_lin_w
	.globl	_CONTRL
	.globl	_INTIN
	.globl	_PTSIN
	.globl	_INTOUT
	.globl	_PTSOUT
	.globl	_FG_BP_1
	.globl	_FG_BP_2
	.globl	_FG_BP_3
	.globl	_FG_BP_4
	.globl	_LSTLIN
	.globl	_LN_MASK
	.globl	_WRT_MOD
	.globl	_X1
	.globl	_Y1
	.globl	_X2
	.globl	_Y2
	.globl	_patptr
	.globl	_patmsk
	.globl	_multifi
	.globl	_CLIP
	.globl	_XMN_CLI
	.globl	_YMN_CLI
	.globl	_XMX_CLI
	.globl	_YMX_CLI
	.globl	_XACC_DD
	.globl	_DDA_INC
	.globl	_T_SCLST
	.globl	_MONO_ST
	.globl	_SOURCEX
	.globl	_SOURCEY
	.globl	_DESTX
	.globl	_DESTY
	.globl	_DELX
	.globl	_DELY
	.globl	_FBASE
	.globl	_FWIDTH
	.globl	_STYLE
	.globl	_LITEMAS
	.globl	_SKEWMAS
	.globl	_WEIGHT
	.globl	_R_OFF
	.globl	_L_OFF
	.globl	_SCALE
	.globl	_CHUP
	.globl	_TEXT_FG
	.globl	_scrtchp
	.globl	_scrpt2
	.globl	_TEXT_BG
	.globl	_COPYTRA
	.globl	_quitfil
	.globl	_LA_ROUT
	.globl	_LA_HARD
	.globl	_LA_SOFT
	.globl	_BLT_MOD
	.globl	biosav
	.globl	savesr
	.globl	fstack
	.globl	old_tik
	.globl	old_2
	.globl	_rseed
	.globl	_seed
	.globl	_PR
	.globl	_prtbdev
	.globl	_prtboch
	.globl	_prtbyt
	.globl	_msec
	.globl	_blue
	.globl	_prtbbva
	.globl	_supstk
	.globl	_WS
	.globl	_prtbflg
	.globl	_TW
	.globl	_prtbdma
	.globl	_time
	.globl	_hues
	.globl	_prtbova
	.globl	_root
	.globl	_glbkbch
	.globl	_ofdlist
	.globl	_fd_medi
	.globl	_maxacct
	.globl	_glbcolu
	.globl	_ajwidth
	.globl	_prtbwid
	.globl	_diskmod
	.globl	_drivech
	.globl	_rrecno
	.globl	_prtbbyt
	.globl	_rasincr
	.globl	_prtbilo
	.globl	_prtn1
	.globl	_prtbihi
	.globl	_prtn2
	.globl	_rwrtflg
	.globl	_curflop
	.globl	_pixincr
	.globl	_prtbwor
	.globl	_prtbstr
	.globl	_rasword
	.globl	_plnword
	.globl	_prtbp2
	.globl	_prtbchu
	.globl	_quality
	.globl	_virt_wo
	.globl	_pixword
	.globl	_prtbp1
	.globl	_rdm
	.globl	_green
	.globl	_prtbgva
	.globl	_plzword
	.globl	_prtbend
	.globl	_inbit
	.globl	_prtbpms
	.globl	_index
	.globl	_prtbidx
	.globl	_dirlock
	.globl	_invid
	.globl	_prtbinv
	.globl	_color
	.globl	_prtbink
	.globl	_ofdbuf
	.globl	_ldivr
	.globl	_bpbsums
	.globl	_cksum
	.globl	_oscnt
	.globl	_ram8x8
	.globl	_rwerr
	.globl	_prtbrva
	.globl	_red
	.globl	_pmd
	.globl	_sft
	.globl	_run
	.globl	_ram8x16
	.globl	_a
	.globl	_pbpar
	.globl	_bakbuf
	.globl	_fill
	.globl	_blkdev
	.globl	_dsbtab
	.globl	_secbuf
	.globl	_osuser
	.globl	_dirrec
	.globl	_huepal
	.globl	_prtbval
	.globl	_dirtbl
	.globl	_planes
	.globl	_prtbpla
	.globl	_prtboff
	.globl	_rasbit
	.globl	_errbuf
	.globl	_duppal
	.globl	_prtbtco
	.globl	_CD
	.globl	_prtbaco
	.globl	_intpal
	.globl	_prtbmax
	.globl	_ED
	.globl	_prtbeps
	.globl	_pixblk
	.globl	_prtbobu
	.globl	_fd_err
	.globl	_flopok
	.globl	_diruse
	.globl	_drvtbl
	.globl	_drvsel
	.globl	_pixlen
	.globl	_prtbhei
	.globl	_HI
	.globl	_prtbmon
	.globl	_intens
	.globl	_prtbmva
	.globl	_ME
	.globl	_prtbmed
	.globl	_CP
	.globl	_prtbemp
	.globl	_uptime
	.globl	_pixhgt
	.globl	_prtblin
	.globl	_errdrv
	.globl	_EP
	.globl	_prtbodd
	.globl	_pixwid
	.globl	_prtbdot
	.globl	_prtbit
	.globl	_prtboma
	.globl	_plzbit
	.globl	_prtbbit
	.globl	_DR
	.globl	_prtbpre
	.globl	_lumsat
	.globl	_prtbmin
	.globl	_ospd
	.globl	_buptr
	.globl	_LO
	.globl	_prtblow
	.globl	_DW
	.globl	_prtbamo
	.globl	_date
	.globl	_bcbx
	.globl	_LS
	.globl	_prtbbol
	.globl	_beptr
	.globl	endos
_diskbuf:
_seed_ty:
	ds.b	2
_search_:
	ds.b	2
_Qbottom:
	ds.b	2
_qTop:
	ds.b	2
_qPtr:
	ds.b	2
_qTmp:
	ds.b	2
_qHole:
	ds.b	2
_oldy:
	ds.b	2
_oldxlef:
	ds.b	2
_oldxrig:
	ds.b	2
_newxlef:
	ds.b	2
_newxrig:
	ds.b	2
_xleft:
	ds.b	2
_xright:
	ds.b	2
_directi:
	ds.b	2
_done:
	ds.b	2
_gotseed:
	ds.b	2
_leftold:
	ds.b	2
_leftdir:
	ds.b	2
_leftsee:
	ds.b	2
_h_align:
_leftcol:
	ds.b	2
_collisi:
_v_align:
	ds.b	2
_Q:
_width:
	ds.b	2
_height:
	ds.b	2
_wordx:
	ds.b	2
_wordy:
	ds.b	2
_rmword:
	ds.b	2
_rmwordx:
	ds.b	2
_rmwordy:
	ds.b	2
_charx:
	ds.b	2
_chary:
	ds.b	2
_rmchar:
	ds.b	2
_rmcharx:
	ds.b	2
_rmchary:
	ds.b	2
_FLIP_Y:
	ds.b	168
_deftxbu:
	ds.b	532
ptsin_ar:
	ds.b	3122
_angle:
_vdivars:
	ds.b	2
_beg_ang:
	ds.b	2
_CUR_FON:
	ds.b	4
_del_ang:
	ds.b	2
_deltay:
	ds.b	2
_deltay1:
	ds.b	2
_deltay2:
	ds.b	2
_end_ang:
	ds.b	2
_fil_int:
	ds.b	2
_fill_ma:
	ds.b	2
_fill_mi:
	ds.b	2
_n_steps:
	ds.b	2
_odeltay:
	ds.b	2
_s_begst:
	ds.b	2
_s_endst:
	ds.b	2
_s_fil_c:
	ds.b	2
_s_fill_:
	ds.b	2
_s_patms:
	ds.b	2
_s_patpt:
	ds.b	4
_start:
	ds.b	2
_xc:
	ds.b	2
_xrad:
	ds.b	2
__Y:
	ds.b	2
_yc:
	ds.b	2
_yrad:
	ds.b	2
_m_poshx:
	ds.b	2
_m_poshy:
	ds.b	2
_m_plane:
	ds.b	2
_m_cdb_b:
	ds.b	2
_m_cdb_f:
	ds.b	2
_mask_fo:
	ds.b	64
_INQ_TAB:
	ds.b	90
_DEV_TAB:
	ds.b	90
_GCURX:
	ds.b	2
_GCURY:
	ds.b	2
_HIDE_CN:
	ds.b	2
_MOUSE_B:
	ds.b	2
_REQ_COL:
	ds.b	96
_SIZ_TAB:
	ds.b	30
_TERM_CH:
	ds.b	2
_chc_mod:
	ds.b	2
_cur_wor:
	ds.b	4
_def_fon:
	ds.b	4
_font_ri:
	ds.b	16
_ini_fon:
	ds.b	2
_line_cw:
	ds.b	2
_loc_mod:
	ds.b	2
_num_qc_:
	ds.b	2
_q_circl:
	ds.b	80
_str_mod:
	ds.b	2
_val_mod:
	ds.b	2
_cur_ms_:
	ds.b	1
_resrvd1:
	ds.b	1
_disab_c:
	ds.b	2
_xydraw:
	ds.b	4
_draw_fl:
	ds.b	1
_mouse_f:
	ds.b	1
_retsav:
	ds.b	4
_sav_cxy:
	ds.b	4
_save_le:
	ds.b	2
_save_ad:
	ds.b	4
_save_st:
	ds.b	2
_save_ar:
	ds.b	256
_tim_add:
	ds.b	4
_tim_cha:
	ds.b	4
_user_bu:
	ds.b	4
_user_cu:
	ds.b	4
_user_mo:
	ds.b	4
_v_cel_h:
	ds.b	2
_v_celmx:
	ds.b	2
_v_celmy:
	ds.b	2
_v_cel_w:
	ds.b	2
_v_col_b:
	ds.b	2
_v_col_f:
	ds.b	2
_v_cur_a:
	ds.b	4
_v_cur_o:
	ds.b	2
_v_curcx:
	ds.b	2
_v_curcy:
	ds.b	2
_vct_ini:
	ds.b	1
_v_cur_t:
	ds.b	1
_v_fnt_a:
	ds.b	4
_v_fnt_n:
	ds.b	2
_v_fnt_s:
	ds.b	2
_v_fnt_w:
	ds.b	2
_v_hz_re:
	ds.b	2
_v_off_a:
	ds.b	4
_v_stat_:
	ds.b	1
_v_delay:
	ds.b	1
_v_vt_re:
	ds.b	2
_bytes_l:
	ds.b	2
_v_plane:
lineavar:
	ds.b	2
_v_lin_w:
	ds.b	2
_CONTRL:
	ds.b	4
_INTIN:
	ds.b	4
_PTSIN:
	ds.b	4
_INTOUT:
	ds.b	4
_PTSOUT:
	ds.b	4
_FG_BP_1:
	ds.b	2
_FG_BP_2:
	ds.b	2
_FG_BP_3:
	ds.b	2
_FG_BP_4:
	ds.b	2
_LSTLIN:
	ds.b	2
_LN_MASK:
	ds.b	2
_WRT_MOD:
	ds.b	2
_X1:
	ds.b	2
_Y1:
	ds.b	2
_X2:
	ds.b	2
_Y2:
	ds.b	2
_patptr:
	ds.b	4
_patmsk:
	ds.b	2
_multifi:
	ds.b	2
_CLIP:
	ds.b	2
_XMN_CLI:
	ds.b	2
_YMN_CLI:
	ds.b	2
_XMX_CLI:
	ds.b	2
_YMX_CLI:
	ds.b	2
_XACC_DD:
	ds.b	2
_DDA_INC:
	ds.b	2
_T_SCLST:
	ds.b	2
_MONO_ST:
	ds.b	2
_SOURCEX:
	ds.b	2
_SOURCEY:
	ds.b	2
_DESTX:
	ds.b	2
_DESTY:
	ds.b	2
_DELX:
	ds.b	2
_DELY:
	ds.b	2
_FBASE:
	ds.b	4
_FWIDTH:
	ds.b	2
_STYLE:
	ds.b	2
_LITEMAS:
	ds.b	2
_SKEWMAS:
	ds.b	2
_WEIGHT:
	ds.b	2
_R_OFF:
	ds.b	2
_L_OFF:
	ds.b	2
_SCALE:
	ds.b	2
_CHUP:
	ds.b	2
_TEXT_FG:
	ds.b	2
_scrtchp:
	ds.b	4
_scrpt2:
	ds.b	2
_TEXT_BG:
	ds.b	2
_COPYTRA:
	ds.b	2
_quitfil:
	ds.b	4
_LA_ROUT:
	ds.b	40
_LA_HARD:
	ds.b	4
_LA_SOFT:
	ds.b	4
_BLT_MOD:
	ds.b	4
biosav:
	ds.b	8
savesr:
	ds.b	2
fstack:
	ds.b	2072
old_tik:
	ds.b	4
old_2:
	ds.b	4
_rseed:
_seed:
	ds.b	4
_PR:
_prtbdev:
	ds.b	2
_prtboch:
_prtbyt:
	ds.b	2
_msec:
	ds.b	2
_blue:
_prtbbva:
	ds.b	2
_supstk:
	ds.b	3072
_WS:
_prtbflg:
	ds.b	2
_TW:
_prtbdma:
	ds.b	2
_time:
	ds.b	2
_hues:
_prtbova:
	ds.b	8
_root:
	ds.b	80
_glbkbch:
	ds.b	960
_ofdlist:
	ds.b	4
_fd_medi:
_maxacct:
	ds.b	4
_glbcolu:
	ds.b	6
_ajwidth:
_prtbwid:
	ds.b	2
_diskmod:
_drivech:
	ds.b	2
_rrecno:
	ds.b	2
_prtbbyt:
_rasincr:
	ds.b	2
_prtbilo:
_prtn1:
	ds.b	2
_prtbihi:
_prtn2:
	ds.b	2
_rwrtflg:
	ds.b	2
_curflop:
	ds.b	2
_pixincr:
_prtbwor:
	ds.b	2
_prtbstr:
_rasword:
	ds.b	4
_plnword:
_prtbp2:
	ds.b	4
_prtbchu:
_quality:
	ds.b	2
_virt_wo:
	ds.b	308
_pixword:
_prtbp1:
	ds.b	4
_rdm:
	ds.b	4
_green:
_prtbgva:
	ds.b	2
_plzword:
_prtbend:
	ds.b	4
_inbit:
_prtbpms:
	ds.b	2
_index:
_prtbidx:
	ds.b	2
_dirlock:
	ds.b	2
_invid:
_prtbinv:
	ds.b	2
_color:
_prtbink:
	ds.b	2
_ofdbuf:
	ds.b	5600
_ldivr:
	ds.b	4
_bpbsums:
_cksum:
	ds.b	24
_oscnt:
	ds.b	2
_ram8x8:
	ds.b	90
_rwerr:
	ds.b	4
_prtbrva:
_red:
	ds.b	2
_pmd:
	ds.b	12
_sft:
	ds.b	750
_run:
	ds.b	4
_ram8x16:
	ds.b	90
_a:
_pbpar:
	ds.b	30
_bakbuf:
	ds.b	12
_fill:
	ds.b	4
_blkdev:
_dsbtab:
	ds.b	72
_secbuf:
	ds.b	2048
_osuser:
	ds.b	2
_dirrec:
	ds.b	4
_huepal:
_prtbval:
	ds.b	32
_dirtbl:
	ds.b	160
_planes:
_prtbpla:
	ds.b	2
_prtboff:
_rasbit:
	ds.b	2
_errbuf:
	ds.b	12
_duppal:
_prtbtco:
	ds.b	2
_CD:
_prtbaco:
	ds.b	2
_intpal:
_prtbmax:
	ds.b	32
_ED:
_prtbeps:
	ds.b	2
_pixblk:
_prtbobu:
	ds.b	8
_fd_err:
_flopok:
	ds.b	4
_diruse:
	ds.b	40
_drvtbl:
	ds.b	64
_drvsel:
	ds.b	2
_pixlen:
_prtbhei:
	ds.b	2
_HI:
_prtbmon:
	ds.b	2
_intens:
_prtbmva:
	ds.b	8
_ME:
_prtbmed:
	ds.b	2
_CP:
_prtbemp:
	ds.b	2
_uptime:
	ds.b	4
_pixhgt:
_prtblin:
	ds.b	2
_errdrv:
	ds.b	2
_EP:
_prtbodd:
	ds.b	2
_pixwid:
_prtbdot:
	ds.b	2
_prtbit:
_prtboma:
	ds.b	2
_plzbit:
_prtbbit:
	ds.b	2
_DR:
_prtbpre:
	ds.b	2
_lumsat:
_prtbmin:
	ds.b	32
_ospd:
	ds.b	256
_buptr:
	ds.b	12
_LO:
_prtblow:
	ds.b	2
_DW:
_prtbamo:
	ds.b	2
_date:
	ds.b	2
_bcbx:
	ds.b	80
_LS:
_prtbbol:
	ds.b	2
_beptr:
	ds.b	12
endos:
