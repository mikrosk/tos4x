**********************************  pxtform.s  ********************************
*
* $Revision: 3.1 $	$Source: /u/lozben/projects/vdi/mtaskvdi/RCS/xfrmform.s,v $
* =============================================================================
* $Author: lozben $	$Date: 91/01/28 18:07:18 $     $Locker:  $
* =============================================================================
*
* $Log:	pxtform.s,v $
*******************************************************************************

		.include	"lineaequ.s"

		.globl		_diskbuf
		.globl		_PX_AND_INT_TRAN_FM

MF_BAS_AD	equ	00	; memory form base address (0: physical device)
MF_WD_PIX	equ	04	; form width in pixels (form width in words /16)
MF_HT_PIX	equ	06	; form height in pixels
MF_WD_WRD	equ	08	; form width in words
MF_FORMAT	equ	10	; form format flag (0:device specific 1:stndrd)
MF_PLANES	equ	12	; number of memory planes

*	CONTRL ARRAY OFFSETS

C_MFDB_S	equ	14	; pointer to source MFDB
C_MFDB_D	equ	18	; pointer to destination MFDB

*+
*	reverse the bit order of the word on the stack, result in d0
*-
rev_bits:
	movem.l	d1-d3,-(sp)
	move.w	16(sp),d3		; d3 <- word to reverse
	clr.w	d1			; d1 <- destination bit
	clr.w	d0
	move.w	#15,d2			; d2 <- source bit
rev_loop:
	btst	d2,d3
	beq	rev_skip
	bset	d1,d0
rev_skip:
	addq.w	#1,d1
	dbra	d2,rev_loop
	movem.l	(sp)+,d1-d3
	rts

_PX_AND_INT_TRAN_FM:

	movem.l	d3-d7/a3-a6,-(sp)		; save registers

	move.l  _lineAVar,a0			; a0 -> linea var struct
	move.l	_pblock,a2
	move.l	PB_CONTRL(a2),a2			; a2 -> control array
	move.l	C_MFDB_S(a2),a0			; a0 -> source MFDB
	move.l	C_MFDB_D(a2),a1			; a1 -> destination MFDB

skip0:
	cmp.w	#INTERLEAVED,MF_FORMAT(a0)	; see if src was orig intrlvd
	bne	skip1				; if not then skip
	bsr	I2P_TRAN_FM			; trnsfrm intrlvd to pix pcked
	bra	leave

skip1:
	cmp.w	#PIXPACKED,MF_FORMAT(a0)	; see if src was orig pix pcked
	bne	skip2				; if not then skip
	bsr	P2I_TRAN_FM			; trnsfrm pix pcked to intrlvd
	bra	leave

skip2:
	cmp.w	#DEVICEDEP,MF_FORMAT(a0)	; see if src is device format
	bne	leave				; if not then leave
	cmp.w	#PIXPACKED,MF_FORMAT(a1)	; see dest is pix packed
	bne	skip3				; if not then skip
	bsr	I2P_TRAN_FM			; trnsfrm intrlvd to pix packed
	bra	leave

skip3:
	bsr	P2I_TRAN_FM		; transform pix packed to interleaved

leave:
	movem.l	(sp)+,d3-d7/a3-a6	; restore registers

	rts

*******************************************************************************
*
* name:	I2P_TRAN_FM
*
* purpose:
*
*	transform interleaved memory form to pixel packed memory form.
*	Pixel packed forms are composed of series of N bits per pixel entities
*	while interlieved  forms are constructed from shuffled planes where
*	corresponding words from sequential planes are contiguous.
*	Transformation is to be performed in place.
*
*	source and destination MEMORY FORM DEFINITION BLOCKS are input.
*	the format of the destination is opposite that of the provided source.
*
*	it is assumed that the destination form is large enough to receive
*	the transformed source.
*
* parameters
*
*  in:	_CONTRL		address of control array (word wide)
*
*	control(07-08)	address of source MFDB
*	control(09-10)	address of destination MFDB
*
*******************************************************************************

I2P_TRAN_FM:

	move.l  _lineAVar,a0		; a0 -> linea var struct
	move.l	_pblock,a2
	move.l	PB_CONTRL(a2),a2		; a2 -> control array
	move.l	C_MFDB_S(a2),a0		; a0 -> source MFDB
	move.l	C_MFDB_D(a2),a1		; a1 -> destination MFDB

	moveq.l	#0,d0			; clear the high word
	move.w	MF_HT_PIX(a0),d2	; d2 <- # lines
	subq.w	#1,d2			; adjust for dbra
	move.w	MF_WD_WRD(a0),d3	; d3 <- planar word wrap
	subq.w	#1,d3			; adjust for dbra

	move.w	MF_PLANES(a0),d7	; d7 <- # of planes to transform	
	move.l	MF_BAS_AD(a0),a0	; a0 -> source data
	move.l	MF_BAS_AD(a1),a1	; a1 -> destination data

	cmp.w	#16,d7			; see how many planes
	beq	I2P16NxtLine		; do 16 plane mode
	rts

*******************************************************************************
*
* name:	P2I_TRAN_FM
*
* purpose:
*
*	transform pixel pact memory form to interleaved memory form.
*	Pixel packed forms are composed of series of N bits per pixel
*	entities while interlieved  forms are constructed from shuffled
*	planes where corresponding words from sequential planes are
*	contiguous. Transformation is to be performed in place.
*
*	source and destination MEMORY FORM DEFINITION BLOCKS are input.
*	the format of the destination is opposite that of the provided source.
*
*	it is assumed that the destination form is large enough to receive
*	the transformed source.
*
* parameters
*
*  in:	_CONTRL		address of control array (word wide)
*
*	control(07-08)	address of source MFDB
*	control(09-10)	address of destination MFDB
*
*******************************************************************************

P2I_TRAN_FM:

	move.l  _lineAVar,a0		; a0 -> linea var struct
	move.l	_pblock,a2
	move.l	PB_CONTRL(a2),a2		; a2 -> control array
	move.l	C_MFDB_S(a2),a0		; a0 -> source MFDB
	move.l	C_MFDB_D(a2),a1		; a1 -> destination MFDB

	moveq.l	#0,d0			; clear the high word
	move.w	MF_HT_PIX(a0),d2	; d2 <- # lines
	subq.w	#1,d2			; adjust for dbra
	move.w	MF_WD_WRD(a0),d3	; d3 <- planar word wrap
	subq.w	#1,d3			; adjust for dbra

	move.w	MF_PLANES(a0),d7	; d7 <- # of planes to transform	
	move.l	MF_BAS_AD(a0),a0	; a0 -> source data
	move.l	MF_BAS_AD(a1),a1	; a1 -> destination data

	cmp.w	#16,d7			; see how many planes
	beq	P2I16NxtLine		; do 16 plane mode
	rts

*******************************************************************************
***************** Pixel packed to interleaved 16 plane mode *******************
*******************************************************************************
		;
P2I16NxtLine:	; continue throught to I2P16NxtLine (same code works
		;
*******************************************************************************
***************** Interleaved to pixel packed 16 plane mode *******************
*******************************************************************************

I2P16NxtLine:
	move.w	d3,d5			; d5 <- planar word wrap - 1

I2P16Line:
	move.w	#15,d1
	lea	_diskbuf,a2		; a2 -> copy area

	movem.l	d0/d2/d3/d5/a0-a1,-(sp)

I2P16CpBuf:
	move.w	(a0)+,(a2)+
	dbra	d1,I2P16CpBuf
	lea	_diskbuf,a0		; a0 -> copy of source next 16 pix
	
	bsr	I2P16			; transform the next 16 pixels
	movem.l	(sp)+,d0/d2/d3/d5/a0-a1

	movem.l	d0-d1/a1,-(sp)
	move.w	#15,d1			; reverse the bits of the 16 words
I2P16RvLoop:
	move.w	(a1),-(sp)
	bsr	rev_bits
	addq.l	#2,sp
	move.w	d0,(a1)+
	dbra	d1,I2P16RvLoop
	movem.l	(sp)+,d0-d1/a1

	add.l	#32,a1			; a1 -> points to start of next 16 pix
	add.l	#32,a0			; a0 -> points to start of next 16 pix
	dbra	d5,I2P16Line		; do next 16 pixels
	dbra	d2,I2P16NxtLine
	rts

*+
*
*	transform 16 pixels from interleaved bit planes to pixel packed form.
*	
*
*	a0	points to source
*	a1	points to dest
*-
I2P16:	move.l	a1,a2		; save the pointer for later use
	movea.l	#1,a4		; a4 <- long loop count

I2PL16Loop:
	move.w	(a0),d0		; load 1st 16 pix of 1st plane
	move.w	2(a0),d1	; load 1st 16 pix of 2nd plane
	move.w	4(a0),d2	; load 1st 16 pix of 3rd plane
	move.w	6(a0),d3	; load 1st 16 pix of 4th plane
	move.w	8(a0),d4	; load 1st 16 pix of 5th plane
	move.w	10(a0),d5	; load 1st 16 pix of 6th plane
	move.w	12(a0),d6	; load 1st 16 pix of 7th plane
	move.w	14(a0),d7	; load 1st 16 pix of 8th plane

	move.w	#15,a3		; loop count for 16 pixels

I2PLB16Loop:
	lsl.l	d0		; shift needed bit into the high word
	move.w	d0,-(sp)	; save for later use

	move.w	d1,d0		; d0 <- 1st 16 pix of 2nd plane
	lsl.l	d0		; d0 <- shift another pixel in upper word
	move.w	d0,d1		; d1 <- adjusted word of 2nd plane

	move.w	d2,d0		; d0 <- 1st 16 pix of 3rd plane
	lsl.l	d0		; d0 <- shift another pixel in upper word
	move.w	d0,d2		; d1 <- adjusted word of 2nd plane

	move.w	d3,d0		; d0 <- 1st 16 pix of 4th plane
	lsl.l	d0		; d0 <- shift another pixel in upper word
	move.w	d0,d3		; d1 <- adjusted word of 4th plane

	move.w	d4,d0		; d0 <- 1st 16 pix of 5th plane
	lsl.l	d0		; d0 <- shift another pixel in upper word
	move.w	d0,d4		; d1 <- adjusted word of 5th plane

	move.w	d5,d0		; d0 <- 1st 16 pix of 6th plane
	lsl.l	d0		; d0 <- shift another pixel in upper word
	move.w	d0,d5		; d1 <- adjusted word of 6th plane

	move.w	d6,d0		; d0 <- 1st 16 pix of 7th plane
	lsl.l	d0		; d0 <- shift another pixel in upper word
	move.w	d0,d6		; d1 <- adjusted word of 7th plane

	move.w	d7,d0		; d0 <- 1st 16 pix of 8th plane
	lsl.l	d0		; d0 <- shift another pixel in upper word
	move.w	d0,d7		; d1 <- adjusted word of 8th plane

	swap	d0		; move the neede byte in the low order of d0
	move.b	d0,(a1)		; store pixel packed byte for the needed pix
	addq.l	#2,a1
	
	move.w	(sp)+,d0	; d0 <- 1st plane (shifted)
	subq.w	#1,a3		; see if we are done with the sixteen pixelx
	cmpa.w	#0,a3
	bge	I2PLB16Loop	; if not branch back

	add.l	#16,a0		; advance source by 8 words
	addq.l	#1,a2		; a2 -> to next byte of the starting dst
	movea.l	a2,a1		; a1 -> to next byte of the starting dst
	subq.w	#1,a4		; see if we are finished with 16 pixels
	cmpa.w	#0,a4
	bge	I2PL16Loop	; loop back

	rts

