*********************************  entry.s  ***********************************
*
* $Revision: 3.3 $	$Source: /u/lozben/projects/vdi/mtaskvdi/RCS/entry.s,v $
* =============================================================================
* $Author: lozben $	$Date: 91/02/14 17:57:44 $     $Locker:  $
* =============================================================================
*
* $Log:	entry.s,v $
* Revision 3.3  91/02/14  17:57:44  lozben
* We forgot to reference the local_pb of a linea structure pointer.
* 
* Revision 3.2  91/02/13  10:36:41  lozben
* Forgot to include "lineaequ.s".
* 
* Revision 3.1  91/02/11  13:25:55  lozben
* Adjusted the code to work with the multiple linea variablestructures.
* 
* Revision 3.0  91/01/03  15:07:00  lozben
* New generation VDI
* 
* Revision 2.2  90/12/05  13:47:32  lozben
* Changed PTSIN from 512 to 1024.
* 
* Revision 2.1  89/02/21  17:18:57  kbad
* *** TOS 1.4  FINAL RELEASE VERSION ***
* 
*******************************************************************************

.include	"lineaequ.s"

	.globl	_GSX_ENTRY
	.globl	_MAX_VERT
	.globl	_cpy_pts
	.globl	_rst_pts
	.globl	_pblock
	.globl	_curWork
	.globl	_lapblock

	.xdef	ptsin_array
	.xdef	_FLIP_Y
	.xdef	_virt_work


PTSIN		equ	1024		; PTSIN maximum length:	1024 verticies

WK_HANDLE	equ	40		; workstation handle in the attribute area
WK_NEXT		equ	64		; next attribute area


*******************************************************************************
*
* _cpy_pts
*  copy the caller's PTSIN array to the local ptsin array and point the
*  parameter block at the copy; _rst_pts puts the caller's back.
*
*******************************************************************************

_cpy_pts:

	movem.l	d0-d2/a0-a4,-(sp)

	move.l	_pblock,a1		; a1 -> parameter block
	lea	ptsin_array,a3		; a3 -> local ptsin array
	move.l	PB_CONTRL(a1),a2	; a2 -> caller's contrl array
	move.l	PB_PTSIN(a1),a4		; a4 -> caller's ptsin array

	move.w	2(a2),d0	 ; d0 <- number of verticies from CONTRL[1]
	move.l	#ptsin_cnt,a0
	move.w	d0,(a0)		 ; save copy since driver may alter original
	beq	no_ptsin	 ; no entries to copy

	move.l	#ptsin_sav,a0
	move.l	a4,(a0)		 ; save the caller's ptsin pointer

	move.w	#PTSIN,d1	 ; d1 <- maximum length of ptsin array  (words)
	cmp.w	d1,d0		 ; is it more than we have room for?
	ble	ptsin_ok	 ; no, transfer this number

	move.w	d1,d0		 ; yes, set size to max
	move.w	d1,2(a2)	 ; truncate value in user's CONTRL array

ptsin_ok:
	move.l	a3,PB_PTSIN(a1)		; ptsin (local ptsin array)
	move.w	d0,d1			; d1 <- gets the number of verticies
	asr.w	#3,d0			; d0 <- (# of verticies) div (8)
	andi.w	#7,d1			; d1 <- (# of verticies) mod (8)
	add.w	d1,d1			; make d1 a word index
	neg.w	d1			; make it an index from the bottom
	jmp	dec_count(pc,d1.w)	; move mod 8 vertices

ptsin_loop:

	move.l	(a4)+,(a3)+		; move 8 verticies [(x,y)] at a time
	move.l	(a4)+,(a3)+
	move.l	(a4)+,(a3)+
	move.l	(a4)+,(a3)+
	move.l	(a4)+,(a3)+
	move.l	(a4)+,(a3)+
	move.l	(a4)+,(a3)+
	move.l	(a4)+,(a3)+

dec_count:				

	dbra	d0,ptsin_loop		; d0 contains count ((# of verts) / (8))

no_ptsin:
	movem.l	(sp)+,d0-d2/a0-a4
	rts


_rst_pts:
	move.l	_pblock,a1		; a1 -> parameter block
	move.l	PB_CONTRL(a1),a2	; a2 -> caller's contrl array
	move.w	ptsin_cnt,d0
	move.w	d0,2(a2)		; restore original array length
	beq	no_rst
	move.l	ptsin_sav,PB_PTSIN(a1)	; restore the caller's ptsin pointer
no_rst:
	rts


*******************************************************************************
*
* _GSX_ENTRY
*  This module is the front end of the built-in screen GIOS for the Atari RBP.
*  The application will have arrived at this point via
*
*	...
*
*	move	#115,d0
*	move.l	#PB,d1
*	trap	#2
*
*	...
*
* PB:	.dc.l	contrl
*	.dc.l	intin
*	.dc.l	ptsin
*	.dc.l	intout
*	.dc.l	ptsout
*
*******************************************************************************

_GSX_ENTRY:

	movem.l	d1-d7/a0-a6,-(sp)	; Save the callers registers

	move.l	d1,a0			; a0 -> caller's parameter block
	move.l	#_pblock,a1
	move.l	d1,(a1)			; this call's parameter block
	move.l	d1,a1
	move.l	PB_CONTRL(a1),a2	; a2 -> caller's contrl array
	move.l	#_FLIP_Y,a1
	clr.w	(a1)
	move.w	(a2),d0			; d0 <- opcode
	clr.w	4(a2)			; no ints out
	clr.w	8(a2)			; no pts out
	move.w	12(a2),d1		; d1 <- handle

	move.l	_curWork,a1		; same workstation as the last call ?
	beq	find_work
	cmp.w	WK_HANDLE(a1),d1
	beq	dispatch

find_work:
	move.l	#_virt_work,a1		; find the attribute area of the handle
work_loop:
	cmp.w	WK_HANDLE(a1),d1
	beq	found_work
	tst.l	WK_NEXT(a1)
	beq	no_work
	move.l	WK_NEXT(a1),a1
	bra	work_loop

no_work:
	cmp.w	#1,d0			; open workstation
	beq	dispatch
	cmp.w	#100,d0			; open virtual workstation
	beq	dispatch
	bra	leave			; handle is invalid, so exit

found_work:
	move.l	#_curWork,a2
	move.l	a1,(a2)

dispatch:
	cmp.w	#255,d0
	bgt	leave
	add.w	d0,d0
	add.w	d0,d0			; d0 <- offset into the table
	move.l	vdi_tbl(pc,d0.w),a5
	beq.l	leave			; no such function
	jsr	(a5)

leave:
	movem.l	(sp)+,d1-d7/a0-a6	; Restore the callers registers
	move.w	_FLIP_Y,d0		; d0 indicates magnitude/coordinate

	rts


vdi_tbl:
	dc.l	0		; 0
	dc.l	_v_opnwk		; 1
	dc.l	_v_clswk		; 2
	dc.l	_CLEARMEM		; 3
	dc.l	0		; 4
	dc.l	_CHK_ESC		; 5
	dc.l	_v_pline		; 6
	dc.l	_v_pmarker		; 7
	dc.l	_d_gtext		; 8
	dc.l	_v_fillarea		; 9
	dc.l	_v_cellarray		; 10
	dc.l	_v_gdp		; 11
	dc.l	_dst_height		; 12
	dc.l	_dst_rotation		; 13
	dc.l	_vs_color		; 14
	dc.l	_vsl_type		; 15
	dc.l	_vsl_width		; 16
	dc.l	_vsl_color		; 17
	dc.l	_vsm_type		; 18
	dc.l	_vsm_height		; 19
	dc.l	_vsm_color		; 20
	dc.l	_dst_font		; 21
	dc.l	_dst_color		; 22
	dc.l	_vsf_interior		; 23
	dc.l	_vsf_style		; 24
	dc.l	_vsf_color		; 25
	dc.l	_vq_color		; 26
	dc.l	_vq_cellarray		; 27
	dc.l	_v_locator		; 28
	dc.l	_v_valuator		; 29
	dc.l	_v_choice		; 30
	dc.l	_v_string		; 31
	dc.l	_vswr_mode		; 32
	dc.l	_vsin_mode		; 33
	dc.l	0		; 34
	dc.l	_vql_attr		; 35
	dc.l	_vqm_attr		; 36
	dc.l	_vqf_attr		; 37
	dc.l	_dqt_attributes		; 38
	dc.l	_dst_alignment		; 39
	dc.l	0		; 40
	dc.l	0		; 41
	dc.l	0		; 42
	dc.l	0		; 43
	dc.l	0		; 44
	dc.l	0		; 45
	dc.l	0		; 46
	dc.l	0		; 47
	dc.l	0		; 48
	dc.l	0		; 49
	dc.l	0		; 50
	dc.l	0		; 51
	dc.l	0		; 52
	dc.l	0		; 53
	dc.l	0		; 54
	dc.l	0		; 55
	dc.l	0		; 56
	dc.l	0		; 57
	dc.l	0		; 58
	dc.l	0		; 59
	dc.l	0		; 60
	dc.l	0		; 61
	dc.l	0		; 62
	dc.l	0		; 63
	dc.l	0		; 64
	dc.l	0		; 65
	dc.l	0		; 66
	dc.l	0		; 67
	dc.l	0		; 68
	dc.l	0		; 69
	dc.l	0		; 70
	dc.l	0		; 71
	dc.l	0		; 72
	dc.l	0		; 73
	dc.l	0		; 74
	dc.l	0		; 75
	dc.l	0		; 76
	dc.l	0		; 77
	dc.l	0		; 78
	dc.l	0		; 79
	dc.l	0		; 80
	dc.l	0		; 81
	dc.l	0		; 82
	dc.l	0		; 83
	dc.l	0		; 84
	dc.l	0		; 85
	dc.l	0		; 86
	dc.l	0		; 87
	dc.l	0		; 88
	dc.l	0		; 89
	dc.l	0		; 90
	dc.l	0		; 91
	dc.l	0		; 92
	dc.l	0		; 93
	dc.l	0		; 94
	dc.l	0		; 95
	dc.l	0		; 96
	dc.l	0		; 97
	dc.l	0		; 98
	dc.l	0		; 99
	dc.l	_d_opnvwk		; 100
	dc.l	_d_clsvwk		; 101
	dc.l	_vq_extnd		; 102
	dc.l	_d_contourfill		; 103
	dc.l	_vsf_perimeter		; 104
	dc.l	_v_get_pixel		; 105
	dc.l	_dst_style		; 106
	dc.l	_dst_point		; 107
	dc.l	_vsl_ends		; 108
	dc.l	_dro_cpyfm		; 109
	dc.l	_dr_trn_fm		; 110
	dc.l	_XFM_CRFM		; 111
	dc.l	_dsf_udpat		; 112
	dc.l	_vsl_udsty		; 113
	dc.l	_dr_recfl		; 114
	dc.l	_vqi_mode		; 115
	dc.l	_dqt_extent		; 116
	dc.l	_dqt_width		; 117
	dc.l	_EX_TIMV		; 118
	dc.l	_dt_loadfont		; 119
	dc.l	_dt_unloadfont		; 120
	dc.l	_drt_cpyfm		; 121
	dc.l	_v_show_c		; 122
	dc.l	_v_hide_c		; 123
	dc.l	_vq_mouse_status		; 124
	dc.l	_VEX_BUTV		; 125
	dc.l	_VEX_MOTV		; 126
	dc.l	_VEX_CURV		; 127
	dc.l	_vq_key_s		; 128
	dc.l	_s_clip		; 129
	dc.l	_dqt_name		; 130
	dc.l	_dqt_fontinfo		; 131
	dc.l	0		; 132
	dc.l	0		; 133
	dc.l	0		; 134
	dc.l	0		; 135
	dc.l	0		; 136
	dc.l	0		; 137
	dc.l	0		; 138
	dc.l	0		; 139
	dc.l	0		; 140
	dc.l	0		; 141
	dc.l	0		; 142
	dc.l	0		; 143
	dc.l	0		; 144
	dc.l	0		; 145
	dc.l	0		; 146
	dc.l	0		; 147
	dc.l	0		; 148
	dc.l	0		; 149
	dc.l	0		; 150
	dc.l	0		; 151
	dc.l	0		; 152
	dc.l	0		; 153
	dc.l	0		; 154
	dc.l	0		; 155
	dc.l	0		; 156
	dc.l	0		; 157
	dc.l	0		; 158
	dc.l	0		; 159
	dc.l	0		; 160
	dc.l	0		; 161
	dc.l	0		; 162
	dc.l	0		; 163
	dc.l	0		; 164
	dc.l	0		; 165
	dc.l	0		; 166
	dc.l	0		; 167
	dc.l	0		; 168
	dc.l	0		; 169
	dc.l	0		; 170
	dc.l	0		; 171
	dc.l	0		; 172
	dc.l	0		; 173
	dc.l	0		; 174
	dc.l	0		; 175
	dc.l	0		; 176
	dc.l	0		; 177
	dc.l	0		; 178
	dc.l	0		; 179
	dc.l	0		; 180
	dc.l	0		; 181
	dc.l	0		; 182
	dc.l	0		; 183
	dc.l	0		; 184
	dc.l	0		; 185
	dc.l	0		; 186
	dc.l	0		; 187
	dc.l	0		; 188
	dc.l	0		; 189
	dc.l	0		; 190
	dc.l	0		; 191
	dc.l	0		; 192
	dc.l	0		; 193
	dc.l	0		; 194
	dc.l	0		; 195
	dc.l	0		; 196
	dc.l	0		; 197
	dc.l	0		; 198
	dc.l	0		; 199
	dc.l	0		; 200
	dc.l	0		; 201
	dc.l	0		; 202
	dc.l	0		; 203
	dc.l	0		; 204
	dc.l	0		; 205
	dc.l	0		; 206
	dc.l	0		; 207
	dc.l	0		; 208
	dc.l	0		; 209
	dc.l	0		; 210
	dc.l	0		; 211
	dc.l	0		; 212
	dc.l	0		; 213
	dc.l	0		; 214
	dc.l	0		; 215
	dc.l	0		; 216
	dc.l	0		; 217
	dc.l	0		; 218
	dc.l	0		; 219
	dc.l	0		; 220
	dc.l	0		; 221
	dc.l	0		; 222
	dc.l	0		; 223
	dc.l	0		; 224
	dc.l	0		; 225
	dc.l	0		; 226
	dc.l	0		; 227
	dc.l	0		; 228
	dc.l	0		; 229
	dc.l	0		; 230
	dc.l	0		; 231
	dc.l	0		; 232
	dc.l	0		; 233
	dc.l	0		; 234
	dc.l	0		; 235
	dc.l	0		; 236
	dc.l	0		; 237
	dc.l	0		; 238
	dc.l	0		; 239
	dc.l	0		; 240
	dc.l	0		; 241
	dc.l	0		; 242
	dc.l	0		; 243
	dc.l	0		; 244
	dc.l	0		; 245
	dc.l	0		; 246
	dc.l	0		; 247
	dc.l	0		; 248
	dc.l	0		; 249
	dc.l	0		; 250
	dc.l	0		; 251
	dc.l	0		; 252
	dc.l	0		; 253
	dc.l	0		; 254
	dc.l	0		; 255


_MAX_VERT:	dc.w	PTSIN


	.bss

ptsin_sav:	ds.l	1		; caller's ptsin pointer
ptsin_cnt:	ds.w	1		; caller's number of verticies
_lapblock:	ds.l	5		; parameter block of line A calls
_pblock:	ds.l	1		; -> parameter block of the current call
_curWork:	ds.l	1		; -> attribute area of the current call

.end
