/*************************************************************************
 *                       Revision Control System
 * =======================================================================
 *  $Author: mui $       $Date: 89/04/26 18:10:36 $
 * =======================================================================
 *
 * Revision 2.2  89/04/26  18:10:36  mui
 * aes30
 *
 * Revision 2.1  89/02/22  05:21:49  kbad
 * *** TOS 1.4  FINAL RELEASE VERSION ***
 *
 * Revision 1.1  88/06/02  12:29:37  lozben
 * Initial revision
 *
 *************************************************************************
 *       Fix bug at appl_init    3/13/87         Derek Mui
 *       The bug originated from DRI, it's not Landon's fault
 *       Deskif.s                                Landon Dyer
 *       Use MAC to assemble     6/28/90         D.Mui
 *       Release the acc wait at appl_exit       7/13/90 D.Mui
 * assemble with MAS 900801 kbad
 *       Removed far_call        4/8/91          D.Mui
 *       Remove gr_mouse         6/13/91         D.Mui
 */

#include "config.h"
#include "deskdefs.h"
#include "../aes/aesdefs.h"
#include "asmdefs.h"



	xref _pglobal
	xref _gl_wchar
	xref _gl_hchar
	xref _gl_wbox
	xref _gl_hbox
	xref _gl_handle
	xref _gl_bvdisk
	xref _gl_bvhard


/* 306de: 00e35c7e */
	xdef _appl_bvset
_appl_bvset:
	move.w	8-4(sp),_gl_bvdisk
	move.w	10-4(sp),_gl_bvhard
	moveq	#1,d0
	rts


	xdef _appl_write
_appl_write:
	link	a6,#0
	move.l	8+4(sp),-(sp)		; ap_rdwr(AQWRT, rwid, length, pbuff)
	move.l	8+4(sp),-(sp)
	move.w	#2,-(sp)
	jsr	_ap_rdwr
dispit:	unlk	a6			; restore A6 and SP
disp1:	move.l	d0,-(sp)		; save return value
	jsr	_dsptch			; dispatch
	move.l	(sp)+,d0		; restore return value
	rts				; ... and return


	xdef _evnt_multi
_evnt_multi:
	link	a6,#-26

	moveq	#0,d0			; d0 = bclk<<16
	move.w	10(a6),d0
	swap	d0
	moveq	#0,d1			; d1 = bmsk<<8 + btst
	move.w	12(a6),d1
	lsl	#8,d1
	add	14(a6),d1
	add.l	d1,d0			; d0 = (bclk<<16) + (bmsk<<8) + btst

	moveq	#0,d1			; d1 = thc<<16
	move.w	42(a6),d1
	swap	d1
	moveq	#0,d2			; d2 = tlc
	move.w	40(a6),d2
	add.l	d2,d1			; d1 = (thc<<16) + tlc

	pea	-20(a6)			; &rets[?]
	move.l	36(a6),-(sp)		; mepbuff
	move.l	d0,-(sp)		; buparm (D0)
	move.l	d1,-(sp)		; tmcount (D1)
	pea	26(a6)			; &m2flags
	pea	16(a6)			; &m1flags
	move.w	8(a6),-(sp)		; flags
	jsr	_ev_multi		; ev_multi(...)
	lea	44(a6),a2		; array copy to ptrs in user space
	lea	-20(a6),a1
	moveq	#6-1,d1

cplp:	move.l	(a2)+,a0		; get pointer from pointer vector
	move.w	(a1)+,(a0)		; copy word to pointer's ref
	dbra	d1,cplp			; loop for more pointers
	bra	dispit			; dispatch, unlk, return D0 to caller


	xdef _evnt_button
_evnt_button:
	link	a6,#-8
	pea	-8(a6)
	move.w	12(a6),-(sp)
	move.w	10(a6),-(sp)
	move.w	8(a6),-(sp)
	jsr	_ev_button
	lea	14(a6),a2		; a2 -> vector of addrs to stuff
cplp4a:	lea	-8(a6),a1		; a1 -> vector of words
cplp4:	moveq	#4-1,d1			; d1 = count
	bra	cplp


	xdef _evnt_dclick
_evnt_dclick:
	move.l	4(sp),-(sp)
	jsr	_ev_dclick
	addq.l	#4,sp
	bra	disp1


	xdef _form_do
_form_do:
	clr	-(sp)
	jsr	_desk_wait
	move.w	10(sp),(sp)			; CS from 8(sp)
	move.l	6(sp),-(sp)
	jsr	_fm_do
	addq.l	#6,sp
	bra	disp1


	xdef _form_dial
_form_dial:
	pea	14(sp)			; &x
	pea	6+4(sp)			; &ix
	move.w	4+8(sp),-(sp)		; dtype
	jsr	_fm_dial
	lea	10(sp),sp
	bra	disp1


	xdef _form_alert
_form_alert:
	move.l	6(sp),-(sp)
	move.w	4+4(sp),-(sp)
	jsr	_fm_alert
	addq.l	#6,sp
	bra	disp1


	xdef _form_error
_form_error:
	move.w	4(sp),-(sp)
	jsr	_fm_error
	addq.l	#2,sp
	bra	disp1


	xdef _form_center
_form_center:
	link	a6,#-8			; space for GRECT
	pea	-8(a6)			; &rect
	move.l	8(a6),-(sp)		; tree
	jsr	_ob_center		; ob_center(tree, &rect)
	lea	12(a6),a2		; copy coords back
	lea	-8(a6),a1
	bra	cplp4


/* actually unused */
	xdef _graf_handle
_graf_handle:
	lea	4(sp),a1
	move.l	(a1)+,a0
	move.w	_gl_wchar,(a0)
	move.l	(a1)+,a0
	move.w	_gl_hchar,(a0)
	move.l	(a1)+,a0
	move.w	_gl_wbox,(a0)
	move.l	(a1)+,a0
	move.w	_gl_hbox,(a0)
	move.w	_gl_handle,d0
	rts


	xdef _graf_rubbox
_graf_rubbox:
	lea	_gr_rubbox,a0		; a0 -> routine to call
	bra.b	copy16			; use common code to copy args


	xdef _graf_mkstate
_graf_mkstate:
	lea	_gr_mkstate,a0		; a0 -> routine to call

copy16:	moveq	#4-1,d0			; copy 16 bytes of args
mkslab:	move.l	16(sp),-(sp)
	dbra	d0,mkslab
	jsr	(a0)			; call routine
	add.w	#16,sp
	bra	disp1


	xdef _graf_growbox
_graf_growbox:
	lea	_gr_growbox,a0
grafx:	pea	12(sp)
	pea	4+4(sp)
	jsr	(a0)
	addq	#8,sp
	bra	disp1


	xdef _graf_shrinkbox
_graf_shrinkbox:
	lea	_gr_shrinkbox,a0
	bra	grafx


	xdef _menu_tnormal
_menu_tnormal:
	move.l	#$00010001,-(sp)	; TRUE, TRUE
	moveq	#1,d1
	tst.w	10+4(sp)		; !normal
	seq	d0
	and.w	d1,d0
	move.w	d0,-(sp)
	move.w	d1,-(sp)		; SELECTED
menx1:	move.w	8+8(sp),-(sp)		; dlist
menx:	move.l	4+10(sp),-(sp)		; mlist *CS*
	jsr	_do_chg
	add.w	#14,sp
	bra	disp1


	xdef _menu_bar
_menu_bar:
	move.w	8(sp),-(sp)		; showit
	move.l	4+2(sp),-(sp)		; tree
	jsr	_mn_bar
	addq	#6,sp
	bra	disp1


	xdef _menu_icheck
_menu_icheck:
	clr.l	-(sp)			; FALSE FALSE		0
	move.w	10+4(sp),-(sp)		; check			4
	move.w	#4,-(sp)		; CHECKED		6
	bra	menx1


	xdef _menu_ienable
_menu_ienable:
	moveq	#1,d2			; (mask for bools)
	clr.w	-(sp)			; FALSE				+2
	move.w	8+2(sp),d0
	smi	d0
	and.w	d2,d0
	move.w	d0,-(sp)		; (bool)!(dlist & 0x8000)	+4
	tst.w	10+4(sp)
	seq	d0
	and.w	d2,d0
	move.w	d0,-(sp)		; !enable			+6
	move.w	#8,-(sp)		; DISABLED			+8
	move.w	8+8(sp),d0
	and.w	#$7fff,d0
	move.w	d0,-(sp)		; dlist & 0x7fff		+10
	bra	menx


	xdef _objc_offset
_objc_offset:
	lea	_ob_offset,a0
	bra	copy16


	xdef _objc_order
_objc_order:
	lea	_ob_order,a0
	bra	copy16


	xdef _objc_find
_objc_find:
	lea	_ob_find,a0
	bra	copy16


	xdef _objc_add
_objc_add:
	lea	_ob_add,a0
	bra	copy16


	xdef _objc_draw
_objc_draw:
	pea	12(sp)
	jsr	_gsx_sclip
	addq	#4,sp
	lea	_ob_draw,a0
	bra	copy16


	xdef _objc_change
_objc_change:
	pea	12(sp)			;				+4
	jsr	_gsx_sclip
	move.l	20+4(sp),-(sp)		; newstate, redraw		+8
	move.w	8+8(sp),-(sp)		; drawob			+10
	move.l	4+10(sp),-(sp)		; tree				+14
	jsr	_ob_change
	add.w	#14,sp
	bra	disp1


	xdef _rsrc_free
_rsrc_free:
	pea	_pglobal
	jsr	_rs_free
	addq	#4,sp
	bra	disp1


	xdef _rsrc_gaddr
_rsrc_gaddr:
	move.l	8(sp),-(sp)		; paddr				+4
	move.l	4+4(sp),-(sp)		; rstype, rsid			+4
	pea	_pglobal		; &pglobal			+4
	jsr	_rs_gaddr
	add.w	#12,sp
	bra	disp1


	xdef _shel_write
_shel_write:
	lea	_sh_write,a0
	bra	copy16


	xdef _shel_get
_shel_get:
	lea	_sh_get,a0
	bra	copy16


	xdef _shel_put
_shel_put:
	lea	_sh_put,a0
	bra	copy16


	xdef _wind_close
_wind_close:
	lea	_wm_close,a0
	bra	copy16


	xdef _wind_delete
_wind_delete:
	lea	_wm_delete,a0
	bra	copy16


	xdef _wind_find
_wind_find:
	lea	_wm_find,a0
	bra	copy16


	xdef _wind_update
_wind_update:
	lea	_wm_update,a0
	bra	copy16


	xdef _wind_create
_wind_create:
	lea	_wm_create,a0
windx:	pea	6(sp)			; &wx				+4
	move.w	4+4(sp),-(sp)		; kind				+4
	jsr	(a0)
	addq	#6,sp
	bra	disp1


	xdef _wind_open
_wind_open:
	lea	_wm_open,a0
	bra	windx


	xdef _wind_get
_wind_get:
	link	a6,#-8
	pea	-8(a6)
	move.l	8(a6),-(sp)		; w_handle, w_field
	jsr	_wm_get
	lea	12(a6),a2		; -> vector of ptrs
	bra	cplp4a			; go copy 4 integers


	xdef _wind_set
_wind_set:
	pea	8(sp)			; &w2
	move.l	4+4(sp),-(sp)		; w_handle, w_field
	jsr	_wm_set
	addq.l	#8,sp
	bra	disp1


	xdef _wind_calc
_wind_calc:
	moveq	#7-1,d0			; copy 7 longs of args
wndcp:	move.l	28(sp),-(sp)
	dbra	d0,wndcp
	jsr	_wm_calc
	adda.w	#28,sp
	bra	disp1


