*********************************  spxtblit.s  ********************************
*
* $Revision: 3.1 $	$Source: /u/lozben/projects/vdi/mtaskvdi/RCS/sbblit.s,v $
* =============================================================================
* $Author: lozben $	$Date: 91/08/06 17:34:28 $     $Locker:  $
* =============================================================================
*
* $Log:	sbblit.s,v $
*******************************************************************************


.include	"lineaequ.s"


		.globl	pos16Tab
		.globl	spx_tbitblt

*       FRAME PARAMETERS

B_WD	  equ	-76	; width of block in pixels			    +00
B_HT	  equ	-74	; height of block in pixels			    +02
PLANE_CT  equ	-72	; number of consequitive planes to blt		    +04

FG_COL	  equ	-70	; foreground color (logic op table index:hi bit)    +06
BG_COL	  equ	-68	; background color (logic op table index:lo bit)    +08
OP_TAB	  equ	-66	; logic ops for all fore and background combos	    +10

S_XMIN	  equ	-62	; minimum X: source				    +14
S_YMIN	  equ	-60	; minimum Y: source				    +16
S_FORM	  equ	-58	; source form base address			    +18
S_NXWD	  equ	-54	; offset to next word in line  (in bytes)	    +22
S_NXLN	  equ	-52	; offset to next line in plane (in bytes)	    +24
S_NXPL	  equ	-50	; offset to next plane from start of current plane  +26

D_XMIN	  equ	-48	; minimum X: destination			    +28
D_YMIN	  equ	-46	; minimum Y: destination			    +30
D_FORM	  equ	-44	; destination form base address			    +32
D_NXWD	  equ	-40	; offset to next word in line  (in bytes)	    +36
D_NXLN	  equ	-38	; offset to next line in plane (in bytes)	    +38
D_NXPL	  equ	-36	; offset to next plane from start of current plane  +40

***					    			    ***
***   these parameters are internally set, some have dual purpose   ***
***					                            ***

P_INDX	  equ	-24	; initial pattern index				    +52

S_ADDR	  equ	-22	; initial source address 			    +54
S_XMAX	  equ	-18	; maximum X: source				    +58
S_YMAX	  equ	-16	; maximum Y: source				    +60

D_ADDR	  equ	-14	; initial destination address			    +62
D_XMAX	  equ	-10	; maximum X: destination			    +66
D_YMAX	  equ	-08	; maximum Y: destination			    +68

INNER_CT  equ	-06	; blt inner loop initial count			    +70
DST_WR	  equ	-04	; destination form wrap (in bytes)		    +72
SRC_WR	  equ	-02	; source form wrap (in bytes)			    +74


*******************************************************************************
*******************************************************************************
**									     **
**	s_xy2addr:							     **
**									     **
**		input:	d0.w =  x coordinate				     **
**			d1.w =  y coordinate				     **
**			a3.l -> line variable structure			     **
**			a6.l -> frame					     **
**									     **
**		output:	a0.l -> address of the word containing x,y	     **
**									     **
**									     **
**	d_xy2addr:							     **
**									     **
**		input:	d0.w =  x coordinate.				     **
**			d1.w =  y coordinate.				     **
**			a3.l -> line variable structure			     **
**			a6.l -> frame					     **
**									     **
**		output:	a1.l -> address of byte containing x,y		     **
**									     **
**		destroys: d0,d1						     **
**									     **
*******************************************************************************
*******************************************************************************

s_xy2addr:	move.l	S_FORM(a6),a0		; a0 -> strt of srce form (0,0)
		ext.l	d0			; clear the upper word
		lsr.w	#4,d0			; d0 <- x portion of offset
		lsl.w	#1,d0			; d0 <- make it a word offset
		mulu	S_NXLN(a6),d1		; d1 <- y portion of offset
		add.l	d0,d1			; d1 <- byte offs into mem frm
		add.l	d1,a0			; a0 -> (x,y)
		rts

d_xy2addr:	move.l	D_FORM(a6),a1		; a0 -> strt of dst form (0,0)
		mulu	byt_per_pix(a5),d0	; d0 <- x portion of offset
		mulu	D_NXLN(a6),d1		; d1 <- y portion of offset
		add.l	d0,d1			; d1 <- byte offs into mem frm
		add.l	d1,a1			; a0 -> (x,y)
		rts
	

*+
* purpose:	set up parameters for bitblt and thread together the
*		appropriate bitblt fragments for software implementation
*		of bitblt. We are dealing with opaque case.
*
* in:		d0.w	Xmin source
*		d2.w	Xmin destination
*		d4.w	Xmax source
*		d6.w	Xmax destination
*
*		a6.l	points to frame with following parameters set:
*
*		Ymin source, Ymax source, Ymin destination, Ymax destination
*		Xmin source, Xmax source, Xmin destination, Xmax destination
*		rectangle height, rectangle width, number of planes
*-
spx_tbitblt:	move.l	_lineAVar,a5	; a5 -> linea variable structure
		move.w	S_YMIN(a6),d1	; d1 <- Ymin source
		bsr	s_xy2addr	; a0 -> start of source block

		move.w	D_XMIN(a6),d0	; compute address of source block
		move.w	D_YMIN(a6),d1
		bsr	d_xy2addr	; a1 -> start of destination block

		tst.w	B_WD(a6)	; see if span is zero or less
		ble	leave		; leave if span is zero
		move.w	B_HT(a6),d0	; d0 <- number of lines to blit
		ble	leave		; leave if number of lines is zero
		subq.w	#1,d0		; d1 <- number of lines to blit - 1

		moveq.l	#0,d1		; clear for later use
		move.w	S_XMIN(a6),d1	; d1 <- source x min
		divu	#16,d1		; we need the remainder
		move.w	d1,d6		; d6 <- source left
		swap	d1		; d1.w <- # of bits to shift in left fr
		move.w	d1,d5
		sub.w	#16,d5
		neg.w	d5		; d5 <- # of pix to blit in left fringe
		moveq.l	#0,d3		; clear for later use
		move.w	S_XMAX(a6),d3	; d3 <- source x max
		divu	#16,d3		; we need the remainder
		move.w	d3,d7		; d7 <- source right
		clr.w	d3		; assume no right fringe
		cmp.w	d6,d7		; see if l and r fringe are in same long
		beq	skip0		; skip if no fringe
		swap	d3		; d3.w <- # bits to blt in rght fr - 1
		addq.w	#1,d3		; d3 <- # of bits to blt in right fr
		bra	skip1		; go to more than 1 fringe case

skip0:		move.w	B_WD(a6),d5		; d5 <- # pix to blt in lft fr

skip1:		sub.w	d6,d7			;
		beq	skip2			; if inner loop is 0 no adjust
		subq.w	#1,d7			; d7 <- # of inner loop ittrtns
skip2:		move.w	d7,a4			; span of inner loop in pix / 16

		move.w	S_NXLN(a6),d6		; d5 <- src line wrap (in bytes)
		addq.w	#1,d7			; add the left fringe
		tst.w	d3			; see if we have right fringe
		beq	skip3			; skip if no right fringe
		addq.w	#1,d7			; add the right fringe

skip3:		add.w	d7,d7			; d7 <- blit span in bytes
		sub.w	d7,d6			; d6 <- off to nxt line in src
		move.w	d6,a2			; a2 <- off to nxt line in src

		move.w	D_NXLN(a6),d6		; d6 <- dst line wrap (in bytes)
		move.w	B_WD(a6),d7		; d7 <- span in pixels
		mulu	byt_per_pix(a5),d7	; d7 <- span in bytes
		sub.w	d7,d6			; d6 <- off to nxt line in dst
		move.w	d6,a3			; a3 <- off to nxt line in dst

		move.w	FG_COL(a6),d6		; d6 <- foreground color
		lsl.w	#2,d6			; make d6 long word offset
		add.l	#pal_map,d6		; d6 <- desired offset
		move.l	(a5,d6.w),d6		; d6 <- desired foreground col

		move.w	BG_COL(a6),d7		; d7 <- background color
		lsl.w	#2,d7			; make d7 long word offset
		add.l	#pal_map,d7		; d7 <- desired offset
		move.l	(a5,d7.w),d7		; d7 <- desired background col

spxtblt:	cmp.w	#16,_v_planes(a5)	; see how many bit per pixel
spx16PTab:	lea	pos16Tab,a5		; a5 -> table of 16 bit routines

tab_set0:	moveq.l	#0,d2			; clear for later use
		move.b	OP_TAB(a6),d2		; d2 <- logic op for the blit
		lsl.w	#2,d2			; d2 <- offset into the table
		move.l	(a5,d2.w),-(sp)		; push the desired routine
		move.w	#15,a5			; used for inner loop
		rts				; go to the desired routine

pos16Tab:	dc.l	o0P16Loop,o1P16Loop,o2P16Loop,o3P16Loop
		dc.l	o4P16Loop,o5P16Loop,o6P16Loop,o7P16Loop
		dc.l	o8P16Loop,o9P16Loop,oAP16Loop,oBP16Loop
		dc.l	oCP16Loop,oDP16Loop,oEP16Loop,oFP16Loop

leave:		rts

*+
*
*	d0.w	number fo lines to blit - 1
*	d1.w	# of bits to shift in the left fringe before blitting
*	d3.w	pixels to blit in right fringe
*	d5.w	pixels to blit in left fringe
*	d6.l	foreground color
*	d7.l	background color
*
*	a0.l	points to the source
*	a1.l	points to the destination
*	a2.w	offset to next line in source
*	a3.w	offset to next line in destination
*	a4.w	span for inner loop in pixels / 16
*	a5.w	contains the number 15
*-


******************************************************************************
************************** 16 bit case positive case *************************
******************************************************************************

*+
* D' = 0 (clear destination block)
*-
o0P16Loop:	moveq	#0,d7			; d0 <- S (for left fringe)
		move.w	d5,d4			; d4 <- # of pix in left fringe

		;
		; do left fringe
		;
		bra	o0P16En0		; go to the entry point
o0P16LFr:	move.w	d7,(a1)+		; set dst to background color
o0P16En0:	dbra	d4,o0P16LFr		; do next pixel

		;
		; do inner loop
		;
		move.w	a4,d2			; d2 <- internal loop
		bra	o0P16En1		; go to the entry point
o0P16Line:	move.w	a5,d4			; d4 <- 15
o0P16:		move.w	d7,(a1)+		; set dst to background color
		dbra	d4,o0P16		; do next pix
o0P16En1:	dbra	d2,o0P16Line		; do next set of 16 pixels
		move.w	d3,d4			; d4 <- # of pix in right fringe
		beq	o0P16Sk1		; branch if no right fringe
		bra	o0P16En2		; go to the entry point

		;
		; do right fringe
		;		
o0P16RFr:	move.w	d7,(a1)+		; set dst to background color
o0P16En2:	dbra	d4,o0P16RFr		; do next pixel

o0P16Sk1:	add.w	a2,a0			; a0 -> to next line in src
		add.w	a3,a1			; a1 -> to next line in dst
		dbra	d0,o0P16Loop		; do next line
		rts

*+
* D' = S AND D
*-
o1P16Loop:	swap	d0			; save count for # of lines - 1
		move.w	(a0)+,d0		; d0 <- S (for left fringe)
		lsl.w	d1,d0			; adjust for the fringe case
		move.w	d5,d4			; d4 <- # of pix in left fringe

		;
		; do left fringe
		;
		bra	o1P16En0		; go to the entry point
o1P16LFr:	lsl.w	d0			; if shifted out bit was set
		bcs	o1P16LFg		; then splat foreground
		and.w	d7,(a1)+		; D' = S AND D
		dbra	d4,o1P16LFr		; do next pixel
		bra	o1P16Sk0
o1P16LFg:	and.w	d6,(a1)+		; D' = S AND D
o1P16En0:	dbra	d4,o1P16LFr		; do next pixel

		;
		; do inner loop
		;
o1P16Sk0:	move.w	a4,d2			; d2 <- internal loop
		bra	o1P16En1		; go to the entry point
o1P16Line:	move.w	a5,d4			; d4 <- 15
		move.w	(a0)+,d0		; d5 <- S
o1P16:		lsl.w	d0			; if shifted out bit was set
		bcs	o1P16Fg			; then splat foreground
		and.w	d7,(a1)+		; D' = S AND D
		dbra	d4,o1P16		; do next pix
		dbra	d2,o1P16Line		; do next set of 16 pixels
		move.w	d3,d4			; d4 <- # of pix in right fringe
		beq	o1P16Sk1		; branch if no right fringe
		move.w	(a0)+,d0		; d0 <- S (for right fringe)
		bra	o1P16En2		; go to the entry point

o1P16Fg:	and.w	d6,(a1)+		; D' = S AND D
		dbra	d4,o1P16		; do next pix
o1P16En1:	dbra	d2,o1P16Line		; do next set of 16 pixels
		move.w	d3,d4			; d4 <- # of pix in right fringe
		beq	o1P16Sk1		; branch if no right fringe
		move.w	(a0)+,d0		; d0 <- S (for right fringe)
		bra	o1P16En2		; go to the entry point

		;
		; do right fringe
		;		
o1P16RFr:	lsl.w	d0			; if shifted out bit was set
		bcs	o1P16RFg		; then splat foreground
		and.w	d7,(a1)+		; D' = S AND D
		dbra	d4,o1P16RFr		; do next pixel
		bra	o1P16Sk1
o1P16RFg:	and.w	d6,(a1)+		; D' = S AND D
o1P16En2:	dbra	d4,o1P16RFr		; do next pixel

o1P16Sk1:	add.w	a2,a0			; a0 -> to next line in src
		add.w	a3,a1			; a1 -> to next line in dst
		swap	d0			; restore line count
		dbra	d0,o1P16Loop		; do next line
		rts

*+
* D' = S AND (NOT D)
*-
o2P16Loop:	swap	d0			; save count for # of lines - 1
		move.w	(a0)+,d0		; d0 <- S (for left fringe)
		lsl.w	d1,d0			; adjust for the fringe case
		move.w	d5,d4			; d4 <- # of pix in left fringe

		;
		; do left fringe
		;
		bra	o2P16En0		; go to the entry point
o2P16LFr:	lsl.w	d0			; if shifted out bit was set
		bcs	o2P16LFg		; then splat foreground
		not.w	(a1)			; D' = NOT D
		and.w	d7,(a1)+		; D' = S AND (NOT D)
		dbra	d4,o2P16LFr		; do next pixel
		bra	o2P16Sk0
o2P16LFg:	not.w	(a1)			; D' = NOT D
		and.w	d6,(a1)+		; D' = S AND (NOT D)
o2P16En0:	dbra	d4,o2P16LFr		; do next pixel

		;
		; do inner loop
		;
o2P16Sk0:	move.w	a4,d2			; d2 <- internal loop
		bra	o2P16En1		; go to the entry point
o2P16Line:	move.w	a5,d4			; d4 <- 15
		move.w	(a0)+,d0		; d5 <- S
o2P16:		lsl.w	d0			; if shifted out bit was set
		bcs	o2P16Fg			; then splat foreground
		not.w	(a1)			; D' = NOT D
		and.w	d7,(a1)+		; D' = S AND (NOT D)
		dbra	d4,o2P16		; do next pix
		dbra	d2,o2P16Line		; do next set of 16 pixels
		move.w	d3,d4			; d4 <- # of pix in right fringe
		beq	o2P16Sk1		; branch if no right fringe
		move.w	(a0)+,d0		; d0 <- S (for right fringe)
		bra	o2P16En2		; go to the entry point

o2P16Fg:	not.w	(a1)			; D' = NOT D
		and.w	d6,(a1)+		; D' = S AND (NOT D)
		dbra	d4,o2P16		; do next pix
o2P16En1:	dbra	d2,o2P16Line		; do next set of 16 pixels
		move.w	d3,d4			; d4 <- # of pix in right fringe
		beq	o2P16Sk1		; branch if no right fringe
		move.w	(a0)+,d0		; d0 <- S (for right fringe)
		bra	o2P16En2		; go to the entry point

		;
		; do right fringe
		;		
o2P16RFr:	lsl.w	d0			; if shifted out bit was set
		bcs	o2P16RFg		; then splat foreground
		not.w	(a1)			; D' = NOT D
		and.w	d7,(a1)+		; D' = S AND (NOT D)
		dbra	d4,o2P16RFr		; do next pixel
		bra	o2P16Sk1
o2P16RFg:	not.w	(a1)			; D' = NOT D
		and.w	d6,(a1)+		; D' = S AND (NOT D)
o2P16En2:	dbra	d4,o2P16RFr		; do next pixel

o2P16Sk1:	add.w	a2,a0			; a0 -> to next line in src
		add.w	a3,a1			; a1 -> to next line in dst
		swap	d0			; restore line count
		dbra	d0,o2P16Loop		; do next line
		rts

*+
* D' = S (Replace mode)
*-
o3P16Loop:	swap	d0			; save count for # of lines - 1
		move.w	(a0)+,d0		; d0 <- S (for left fringe)
		lsl.w	d1,d0			; adjust for the fringe case
		move.w	d5,d4			; d4 <- # of pix in left fringe

		;
		; do left fringe
		;
		bra	o3P16En0		; go to the entry point
o3P16LFr:	lsl.w	d0			; if shifted out bit was set
		bcs	o3P16LFg		; then splat foreground
		move.w	d7,(a1)+		; set dst to background color
		dbra	d4,o3P16LFr		; do next pixel
		bra	o3P16Sk0
o3P16LFg:	move.w	d6,(a1)+		; set dst to foreground color
o3P16En0:	dbra	d4,o3P16LFr		; do next pixel

		;
		; do inner loop
		;
o3P16Sk0:	move.w	a4,d2			; d2 <- internal loop
		bra	o3P16En1		; go to the entry point
o3P16Line:	move.w	a5,d4			; d4 <- 15
		move.w	(a0)+,d0		; d5 <- S
o3P16:		lsl.w	d0			; if shifted out bit was set
		bcs	o3P16Fg			; then splat foreground
		move.w	d7,(a1)+		; set dst to background color
		dbra	d4,o3P16		; do next pix
		dbra	d2,o3P16Line		; do next set of 16 pixels
		move.w	d3,d4			; d4 <- # of pix in right fringe
		beq	o3P16Sk1		; branch if no right fringe
		move.w	(a0)+,d0		; d0 <- S (for right fringe)
		bra	o3P16En2		; go to the entry point

o3P16Fg:	move.w	d6,(a1)+		; set dst to foreground color
		dbra	d4,o3P16		; do next pix
o3P16En1:	dbra	d2,o3P16Line		; do next set of 16 pixels
		move.w	d3,d4			; d4 <- # of pix in right fringe
		beq	o3P16Sk1		; branch if no right fringe
		move.w	(a0)+,d0		; d0 <- S (for right fringe)
		bra	o3P16En2		; go to the entry point

		;
		; do right fringe
		;		
o3P16RFr:	lsl.w	d0			; if shifted out bit was set
		bcs	o3P16RFg		; then splat foreground
		move.w	d7,(a1)+		; set dst to background color
		dbra	d4,o3P16RFr		; do next pixel
		bra	o3P16Sk1
o3P16RFg:	move.w	d6,(a1)+		; set dst to foreground color
o3P16En2:	dbra	d4,o3P16RFr		; do next pixel

o3P16Sk1:	add.w	a2,a0			; a0 -> to next line in src
		add.w	a3,a1			; a1 -> to next line in dst
		swap	d0			; restore line count
		dbra	d0,o3P16Loop		; do next line
		rts

*+
* D' = (NOT S) AND D (erase mode)
*-
o4P16Loop:	not.w	d7			; S' = NOT S (bg color)
		not.w	d6			; S' = NOT S (fg color)

o4P16Loop1:	swap	d0			; save count for # of lines - 1
		move.w	(a0)+,d0		; d0 <- S (for left fringe)
		lsl.w	d1,d0			; adjust for the fringe case
		move.w	d5,d4			; d4 <- # of pix in left fringe

		;
		; do left fringe
		;
		bra	o4P16En0		; go to the entry point
o4P16LFr:	lsl.w	d0			; if shifted out bit was set
		bcs	o4P16LFg		; then splat foreground
		and.w	d7,(a1)+		; D' = (NOT S) AND D
		dbra	d4,o4P16LFr		; do next pixel
		bra	o4P16Sk0
o4P16LFg:	and.w	d6,(a1)+		; D' = (NOT S) AND D
o4P16En0:	dbra	d4,o4P16LFr		; do next pixel

		;
		; do inner loop
		;
o4P16Sk0:	move.w	a4,d2			; d2 <- internal loop
		bra	o4P16En1		; go to the entry point
o4P16Line:	move.w	a5,d4			; d4 <- 15
		move.w	(a0)+,d0		; d5 <- S
o4P16:		lsl.w	d0			; if shifted out bit was set
		bcs	o4P16Fg			; then splat foreground
		and.w	d7,(a1)+		; D' = (NOT S) AND D
		dbra	d4,o4P16		; do next pix
		dbra	d2,o4P16Line		; do next set of 16 pixels
		move.w	d3,d4			; d4 <- # of pix in right fringe
		beq	o4P16Sk1		; branch if no right fringe
		move.w	(a0)+,d0		; d0 <- S (for right fringe)
		bra	o4P16En2		; go to the entry point

o4P16Fg:	and.w	d6,(a1)+		; D' = (NOT S) AND D
		dbra	d4,o4P16		; do next pix
o4P16En1:	dbra	d2,o4P16Line		; do next set of 16 pixels
		move.w	d3,d4			; d4 <- # of pix in right fringe
		beq	o4P16Sk1		; branch if no right fringe
		move.w	(a0)+,d0		; d0 <- S (for right fringe)
		bra	o4P16En2		; go to the entry point

		;
		; do right fringe
		;		
o4P16RFr:	lsl.w	d0			; if shifted out bit was set
		bcs	o4P16RFg		; then splat foreground
		and.w	d7,(a1)+		; D' = (NOT S) AND D
		dbra	d4,o4P16RFr		; do next pixel
		bra	o4P16Sk1
o4P16RFg:	and.w	d6,(a1)+		; D' = (NOT S) AND D
o4P16En2:	dbra	d4,o4P16RFr		; do next pixel

o4P16Sk1:	add.w	a2,a0			; a0 -> to next line in src
		add.w	a3,a1			; a1 -> to next line in dst
		swap	d0			; restore line count
		dbra	d0,o4P16Loop1		; do next line
		rts

*+
* D' = D (destination unchanged)
*-
o5P16Loop:	rts				; do nothing

*+
* D' = S XOR D (XOR mode)
*-
o6P16Loop:	move.w	#-1,d6			; S' = $ffffffff (fg color)

o6P16Loop1:	swap	d0			; save count for # of lines - 1
		move.w	(a0)+,d0		; d0 <- S (for left fringe)
		lsl.w	d1,d0			; adjust for the fringe case
		move.w	d5,d4			; d4 <- # of pix in left fringe

		;
		; do left fringe
		;
		bra	o6P16En0		; go to the entry point
o6P16LFr:	lsl.w	d0			; if shifted out bit was set
		bcs	o6P16LFg		; then splat foreground
		addq.w	#2,a1			; point to next pixel
		dbra	d4,o6P16LFr		; do next pixel
		bra	o6P16Sk0
o6P16LFg:	eor.w	d6,(a1)+		; D' = S xor D
o6P16En0:	dbra	d4,o6P16LFr		; do next pixel

		;
		; do inner loop
		;
o6P16Sk0:	move.w	a4,d2			; d2 <- internal loop
		bra	o6P16En1		; go to the entry point
o6P16Line:	move.w	a5,d4			; d4 <- 15
		move.w	(a0)+,d0		; d5 <- S
o6P16:		lsl.w	d0			; if shifted out bit was set
		bcs	o6P16Fg			; then splat foreground
		addq.w	#2,a1			; point to next pixel
		dbra	d4,o6P16		; do next pix
		dbra	d2,o6P16Line		; do next set of 16 pixels
		move.w	d3,d4			; d4 <- # of pix in right fringe
		beq	o6P16Sk1		; branch if no right fringe
		move.w	(a0)+,d0		; d0 <- S (for right fringe)
		bra	o6P16En2		; go to the entry point

o6P16Fg:	eor.w	d6,(a1)+		; D' = S xor D
		dbra	d4,o6P16		; do next pix
o6P16En1:	dbra	d2,o6P16Line		; do next set of 16 pixels
		move.w	d3,d4			; d4 <- # of pix in right fringe
		beq	o6P16Sk1		; branch if no right fringe
		move.w	(a0)+,d0		; d0 <- S (for right fringe)
		bra	o6P16En2		; go to the entry point

		;
		; do right fringe
		;		
o6P16RFr:	lsl.w	d0			; if shifted out bit was set
		bcs	o6P16RFg		; then splat foreground
		addq.w	#2,a1			; point to next pixel
		dbra	d4,o6P16RFr		; do next pixel
		bra	o6P16Sk1
o6P16RFg:	eor.w	d6,(a1)+		; D' = S xor D
o6P16En2:	dbra	d4,o6P16RFr		; do next pixel

o6P16Sk1:	add.w	a2,a0			; a0 -> to next line in src
		add.w	a3,a1			; a1 -> to next line in dst
		swap	d0			; restore line count
		dbra	d0,o6P16Loop1		; do next line
		rts

*+
* D' = S OR D (transparant mode)
*-
o7P16Loop:	swap	d0			; save count for # of lines - 1
		move.w	(a0)+,d0		; d0 <- S (for left fringe)
		lsl.w	d1,d0			; adjust for the fringe case
		move.w	d5,d4			; d4 <- # of pix in left fringe

		;
		; do left fringe
		;
		bra	o7P16En0		; go to the entry point
o7P16LFr:	lsl.w	d0			; if shifted out bit was set
		bcs	o7P16LFg		; then splat foreground
		addq.w	#2,a1			; advance D by one pixel
		dbra	d4,o7P16LFr		; do next pixel
		bra	o7P16Sk0
o7P16LFg:	move.w	d6,(a1)+		; set dst to foreground color
o7P16En0:	dbra	d4,o7P16LFr		; do next pixel

		;
		; do inner loop
		;
o7P16Sk0:	move.w	a4,d2			; d2 <- internal loop
		bra	o7P16En1		; go to the entry point
o7P16Line:	move.w	a5,d4			; d4 <- 15
		move.w	(a0)+,d0		; d5 <- S
o7P16:		lsl.w	d0			; if shifted out bit was set
		bcs	o7P16Fg			; then splat foreground
		addq.w	#2,a1			; advance D by one pixel
		dbra	d4,o7P16		; do next pix
		dbra	d2,o7P16Line		; do next set of 16 pixels
		move.w	d3,d4			; d4 <- # of pix in right fringe
		beq	o7P16Sk1		; branch if no right fringe
		move.w	(a0)+,d0		; d0 <- S (for right fringe)
		bra	o7P16En2		; go to the entry point

o7P16Fg:	move.w	d6,(a1)+		; set dst to foreground color
		dbra	d4,o7P16		; do next pix
o7P16En1:	dbra	d2,o7P16Line		; do next set of 16 pixels
		move.w	d3,d4			; d4 <- # of pix in right fringe
		beq	o7P16Sk1		; branch if no right fringe
		move.w	(a0)+,d0		; d0 <- S (for right fringe)
		bra	o7P16En2		; go to the entry point

		;
		; do right fringe
		;		
o7P16RFr:	lsl.w	d0			; if shifted out bit was set
		bcs	o7P16RFg		; then splat foreground
		addq.w	#2,a1			; advance D by one pixel
		dbra	d4,o7P16RFr		; do next pixel
		bra	o7P16Sk1
o7P16RFg:	move.w	d6,(a1)+		; set dst to foreground color
o7P16En2:	dbra	d4,o7P16RFr		; do next pixel

o7P16Sk1:	add.w	a2,a0			; a0 -> to next line in src
		add.w	a3,a1			; a1 -> to next line in dst
		swap	d0			; restore line count
		dbra	d0,o7P16Loop		; do next line
		rts

*+
* D' = NOT (S OR D)
*-
o8P16Loop:	swap	d0			; save count for # of lines - 1
		move.w	(a0)+,d0		; d0 <- S (for left fringe)
		lsl.w	d1,d0			; adjust for the fringe case
		move.w	d5,d4			; d4 <- # of pix in left fringe

		;
		; do left fringe
		;
		bra	o8P16En0		; go to the entry point
o8P16LFr:	lsl.w	d0			; if shifted out bit was set
		bcs	o8P16LFg		; then splat foreground
		or.w	d7,(a1)			; D' = S or D
		not.w	(a1)+			; D' = NOT (S OR D)
		dbra	d4,o8P16LFr		; do next pixel
		bra	o8P16Sk0
o8P16LFg:	or.w	d6,(a1)			; D' = S or D
		not.w	(a1)+			; D' = NOT (S OR D)
o8P16En0:	dbra	d4,o8P16LFr		; do next pixel

		;
		; do inner loop
		;
o8P16Sk0:	move.w	a4,d2			; d2 <- internal loop
		bra	o8P16En1		; go to the entry point
o8P16Line:	move.w	a5,d4			; d4 <- 15
		move.w	(a0)+,d0		; d5 <- S
o8P16:		lsl.w	d0			; if shifted out bit was set
		bcs	o8P16Fg			; then splat foreground
		or.w	d7,(a1)			; D' = S or D
		not.w	(a1)+			; D' = NOT (S OR D)
		dbra	d4,o8P16		; do next pix
		dbra	d2,o8P16Line		; do next set of 16 pixels
		move.w	d3,d4			; d4 <- # of pix in right fringe
		beq	o8P16Sk1		; branch if no right fringe
		move.w	(a0)+,d0		; d0 <- S (for right fringe)
		bra	o8P16En2		; go to the entry point

o8P16Fg:	or.w	d6,(a1)			; D' = S or D
		not.w	(a1)+			; D' = NOT (S OR D)
		dbra	d4,o8P16		; do next pix
o8P16En1:	dbra	d2,o8P16Line		; do next set of 16 pixels
		move.w	d3,d4			; d4 <- # of pix in right fringe
		beq	o8P16Sk1		; branch if no right fringe
		move.w	(a0)+,d0		; d0 <- S (for right fringe)
		bra	o8P16En2		; go to the entry point

		;
		; do right fringe
		;		
o8P16RFr:	lsl.w	d0			; if shifted out bit was set
		bcs	o8P16RFg		; then splat foreground
		or.w	d7,(a1)			; D' = S or D
		not.w	(a1)+			; D' = NOT (S OR D)
		dbra	d4,o8P16RFr		; do next pixel
		bra	o8P16Sk1
o8P16RFg:	or.w	d6,(a1)			; D' = S or D
		not.w	(a1)+			; D' = NOT (S OR D)
o8P16En2:	dbra	d4,o8P16RFr		; do next pixel

o8P16Sk1:	add.w	a2,a0			; a0 -> to next line in src
		add.w	a3,a1			; a1 -> to next line in dst
		swap	d0			; restore line count
		dbra	d0,o8P16Loop		; do next line
		rts

*+
* D' = NOT (S XOR D)
*-
o9P16Loop:	swap	d0			; save count for # of lines - 1
		move.w	(a0)+,d0		; d0 <- S (for left fringe)
		lsl.w	d1,d0			; adjust for the fringe case
		move.w	d5,d4			; d4 <- # of pix in left fringe

		;
		; do left fringe
		;
		bra	o9P16En0		; go to the entry point
o9P16LFr:	lsl.w	d0			; if shifted out bit was set
		bcs	o9P16LFg		; then splat foreground
		eor.w	d7,(a1)			; D' = S eor D
		not.w	(a1)+			; D' = NOT (S eor D)
		dbra	d4,o9P16LFr		; do next pixel
		bra	o9P16Sk0
o9P16LFg:	eor.w	d6,(a1)			; D' = S eor D
		not.w	(a1)+			; D' = NOT (S eor D)
o9P16En0:	dbra	d4,o9P16LFr		; do next pixel

		;
		; do inner loop
		;
o9P16Sk0:	move.w	a4,d2			; d2 <- internal loop
		bra	o9P16En1		; go to the entry point
o9P16Line:	move.w	a5,d4			; d4 <- 15
		move.w	(a0)+,d0		; d5 <- S
o9P16:		lsl.w	d0			; if shifted out bit was set
		bcs	o9P16Fg			; then splat foreground
		eor.w	d7,(a1)			; D' = S eor D
		not.w	(a1)+			; D' = NOT (S eor D)
		dbra	d4,o9P16		; do next pix
		dbra	d2,o9P16Line		; do next set of 16 pixels
		move.w	d3,d4			; d4 <- # of pix in right fringe
		beq	o9P16Sk1		; branch if no right fringe
		move.w	(a0)+,d0		; d0 <- S (for right fringe)
		bra	o9P16En2		; go to the entry point

o9P16Fg:	eor.w	d6,(a1)			; D' = S eor D
		not.w	(a1)+			; D' = NOT (S eor D)
		dbra	d4,o9P16		; do next pix
o9P16En1:	dbra	d2,o9P16Line		; do next set of 16 pixels
		move.w	d3,d4			; d4 <- # of pix in right fringe
		beq	o9P16Sk1		; branch if no right fringe
		move.w	(a0)+,d0		; d0 <- S (for right fringe)
		bra	o9P16En2		; go to the entry point

		;
		; do right fringe
		;		
o9P16RFr:	lsl.w	d0			; if shifted out bit was set
		bcs	o9P16RFg		; then splat foreground
		eor.w	d7,(a1)			; D' = S eor D
		not.w	(a1)+			; D' = NOT (S eor D)
		dbra	d4,o9P16RFr		; do next pixel
		bra	o9P16Sk1
o9P16RFg:	eor.w	d6,(a1)			; D' = S eor D
		not.w	(a1)+			; D' = NOT (S eor D)
o9P16En2:	dbra	d4,o9P16RFr		; do next pixel

o9P16Sk1:	add.w	a2,a0			; a0 -> to next line in src
		add.w	a3,a1			; a1 -> to next line in dst
		swap	d0			; restore line count
		dbra	d0,o9P16Loop		; do next line
		rts

*+
* D' = NOT D
*-
oAP16Loop:	move.w	d5,d4			; d4 <- # of pix in left fringe

		;
		; do left fringe
		;
		bra	oAP16En0		; go to the entry point
oAP16LFr:	not.w	(a1)+			; D' = NOT D
oAP16En0:	dbra	d4,oAP16LFr		; do next pixel

		;
		; do inner loop
		;
		move.w	a4,d2			; d2 <- internal loop
		bra	oAP16En1		; go to the entry point
oAP16Line:	move.w	a5,d4			; d4 <- 15
oAP16:		not.w	(a1)+			; D' = NOT D
		dbra	d4,oAP16		; do next pix
oAP16En1:	dbra	d2,oAP16Line		; do next set of 16 pixels
		move.w	d3,d4			; d4 <- # of pix in right fringe
		beq	oAP16Sk1		; branch if no right fringe
		bra	oAP16En2		; go to the entry point

		;
		; do right fringe
		;		
oAP16RFr:	not.w	(a1)+			; D' = NOT D
oAP16En2:	dbra	d4,oAP16RFr		; do next pixel

oAP16Sk1:	add.w	a2,a0			; a0 -> to next line in src
		add.w	a3,a1			; a1 -> to next line in dst
		dbra	d0,oAP16Loop		; do next line
		rts

*+
* D' = S OR (NOT D)
*-
oBP16Loop:	swap	d0			; save count for # of lines - 1
		move.w	(a0)+,d0		; d0 <- S (for left fringe)
		lsl.w	d1,d0			; adjust for the fringe case
		move.w	d5,d4			; d4 <- # of pix in left fringe

		;
		; do left fringe
		;
		bra	oBP16En0		; go to the entry point
oBP16LFr:	lsl.w	d0			; if shifted out bit was set
		bcs	oBP16LFg		; then splat foreground
		not.w	(a1)			; D' = NOT D
		or.w	d7,(a1)+		; D' = S or (NOT D)
		dbra	d4,oBP16LFr		; do next pixel
		bra	oBP16Sk0
oBP16LFg:	not.w	(a1)			; D' = NOT D
		or.w	d6,(a1)+		; D' = S or (NOT D)
oBP16En0:	dbra	d4,oBP16LFr		; do next pixel

		;
		; do inner loop
		;
oBP16Sk0:	move.w	a4,d2			; d2 <- internal loop
		bra	oBP16En1		; go to the entry point
oBP16Line:	move.w	a5,d4			; d4 <- 15
		move.w	(a0)+,d0		; d5 <- S
oBP16:		lsl.w	d0			; if shifted out bit was set
		bcs	oBP16Fg			; then splat foreground
		not.w	(a1)			; D' = NOT D
		or.w	d7,(a1)+		; D' = S or (NOT D)
		dbra	d4,oBP16		; do next pix
		dbra	d2,oBP16Line		; do next set of 16 pixels
		move.w	d3,d4			; d4 <- # of pix in right fringe
		beq	oBP16Sk1		; branch if no right fringe
		move.w	(a0)+,d0		; d0 <- S (for right fringe)
		bra	oBP16En2		; go to the entry point

oBP16Fg:	not.w	(a1)			; D' = NOT D
		or.w	d6,(a1)+		; D' = S or (NOT D)
		dbra	d4,oBP16		; do next pix
oBP16En1:	dbra	d2,oBP16Line		; do next set of 16 pixels
		move.w	d3,d4			; d4 <- # of pix in right fringe
		beq	oBP16Sk1		; branch if no right fringe
		move.w	(a0)+,d0		; d0 <- S (for right fringe)
		bra	oBP16En2		; go to the entry point

		;
		; do right fringe
		;		
oBP16RFr:	lsl.w	d0			; if shifted out bit was set
		bcs	oBP16RFg		; then splat foreground
		not.w	(a1)			; D' = NOT D
		or.w	d7,(a1)+		; D' = S or (NOT D)
		dbra	d4,oBP16RFr		; do next pixel
		bra	oBP16Sk1
oBP16RFg:	not.w	(a1)			; D' = NOT D
		or.w	d6,(a1)+		; D' = S or (NOT D)
oBP16En2:	dbra	d4,oBP16RFr		; do next pixel

oBP16Sk1:	add.w	a2,a0			; a0 -> to next line in src
		add.w	a3,a1			; a1 -> to next line in dst
		swap	d0			; restore line count
		dbra	d0,oBP16Loop		; do next line
		rts

*+
* D' = NOT S
*-
oCP16Loop:	not.w	d6			; d6 <- NOT FG
		not.w	d7			; d7 <- NOT BG

oCP16Loop1:	swap	d0			; save count for # of lines - 1
		move.w	(a0)+,d0		; d0 <- S (for left fringe)
		lsl.w	d1,d0			; adjust for the fringe case
		move.w	d5,d4			; d4 <- # of pix in left fringe

		;
		; do left fringe
		;
		bra	oCP16En0		; go to the entry point
oCP16LFr:	lsl.w	d0			; if shifted out bit was set
		bcs	oCP16LFg		; then splat foreground
		move.w	d7,(a1)+		; set dst to background color
		dbra	d4,oCP16LFr		; do next pixel
		bra	oCP16Sk0
oCP16LFg:	move.w	d6,(a1)+		; set dst to foreground color
oCP16En0:	dbra	d4,oCP16LFr		; do next pixel

		;
		; do inner loop
		;
oCP16Sk0:	move.w	a4,d2			; d2 <- internal loop
		bra	oCP16En1		; go to the entry point
oCP16Line:	move.w	a5,d4			; d4 <- 15
		move.w	(a0)+,d0		; d5 <- S
oCP16:		lsl.w	d0			; if shifted out bit was set
		bcs	oCP16Fg			; then splat foreground
		move.w	d7,(a1)+		; set dst to background color
		dbra	d4,oCP16		; do next pix
		dbra	d2,oCP16Line		; do next set of 16 pixels
		move.w	d3,d4			; d4 <- # of pix in right fringe
		beq	oCP16Sk1		; branch if no right fringe
		move.w	(a0)+,d0		; d0 <- S (for right fringe)
		bra	oCP16En2		; go to the entry point

oCP16Fg:	move.w	d6,(a1)+		; set dst to foreground color
		dbra	d4,oCP16		; do next pix
oCP16En1:	dbra	d2,oCP16Line		; do next set of 16 pixels
		move.w	d3,d4			; d4 <- # of pix in right fringe
		beq	oCP16Sk1		; branch if no right fringe
		move.w	(a0)+,d0		; d0 <- S (for right fringe)
		bra	oCP16En2		; go to the entry point

		;
		; do right fringe
		;		
oCP16RFr:	lsl.w	d0			; if shifted out bit was set
		bcs	oCP16RFg		; then splat foreground
		move.w	d7,(a1)+		; set dst to background color
		dbra	d4,oCP16RFr		; do next pixel
		bra	oCP16Sk1
oCP16RFg:	move.w	d6,(a1)+		; set dst to foreground color
oCP16En2:	dbra	d4,oCP16RFr		; do next pixel

oCP16Sk1:	add.w	a2,a0			; a0 -> to next line in src
		add.w	a3,a1			; a1 -> to next line in dst
		swap	d0			; restore line count
		dbra	d0,oCP16Loop1		; do next line
		rts

*+
* D' = (NOT S) OR D reverse transparant
*-
oDP16Loop:	swap	d0			; save count for # of lines - 1
		move.w	(a0)+,d0		; d0 <- S (for left fringe)
		lsl.w	d1,d0			; adjust for the fringe case
		move.w	d5,d4			; d4 <- # of pix in left fringe

		;
		; do left fringe
		;
		bra	oDP16En0		; go to the entry point
oDP16LFr:	lsl.w	d0			; if shifted out bit was set
		bcs	oDP16LFg		; then splat foreground
		move.w	d7,(a1)+		; set dst to background color
		dbra	d4,oDP16LFr		; do next pixel
		bra	oDP16Sk0
oDP16LFg:	addq.w	#2,a1			; advance D by one pixel
oDP16En0:	dbra	d4,oDP16LFr		; do next pixel

		;
		; do inner loop
		;
oDP16Sk0:	move.w	a4,d2			; d2 <- internal loop
		bra	oDP16En1		; go to the entry point
oDP16Line:	move.w	a5,d4			; d4 <- 15
		move.w	(a0)+,d0		; d5 <- S
oDP16:		lsl.w	d0			; if shifted out bit was set
		bcs	oDP16Fg			; then splat foreground
		move.w	d7,(a1)+		; set dst to background color
		dbra	d4,oDP16		; do next pix
		dbra	d2,oDP16Line		; do next set of 16 pixels
		move.w	d3,d4			; d4 <- # of pix in right fringe
		beq	oDP16Sk1		; branch if no right fringe
		move.w	(a0)+,d0		; d0 <- S (for right fringe)
		bra	oDP16En2		; go to the entry point

oDP16Fg:	addq.w	#2,a1			; advance D by one pixel
		dbra	d4,oDP16		; do next pix
oDP16En1:	dbra	d2,oDP16Line		; do next set of 16 pixels
		move.w	d3,d4			; d4 <- # of pix in right fringe
		beq	oDP16Sk1		; branch if no right fringe
		move.w	(a0)+,d0		; d0 <- S (for right fringe)
		bra	oDP16En2		; go to the entry point

		;
		; do right fringe
		;		
oDP16RFr:	lsl.w	d0			; if shifted out bit was set
		bcs	oDP16RFg		; then splat foreground
		move.w	d7,(a1)+		; set dst to background color
		dbra	d4,oDP16RFr		; do next pixel
		bra	oDP16Sk1
oDP16RFg:	addq.w	#2,a1			; advance D by one pixel
oDP16En2:	dbra	d4,oDP16RFr		; do next pixel

oDP16Sk1:	add.w	a2,a0			; a0 -> to next line in src
		add.w	a3,a1			; a1 -> to next line in dst
		swap	d0			; restore line count
		dbra	d0,oDP16Loop		; do next line
		rts

*+
* D' = NOT (S AND D)
*-
oEP16Loop:	swap	d0			; save count for # of lines - 1
		move.w	(a0)+,d0		; d0 <- S (for left fringe)
		lsl.w	d1,d0			; adjust for the fringe case
		move.w	d5,d4			; d4 <- # of pix in left fringe

		;
		; do left fringe
		;
		bra	oEP16En0		; go to the entry point
oEP16LFr:	lsl.w	d0			; if shifted out bit was set
		bcs	oEP16LFg		; then splat foreground
		and.w	d7,(a1)			; D' = S and D
		not.w	(a1)+			; D' = NOT (S and D)
		dbra	d4,oEP16LFr		; do next pixel
		bra	oEP16Sk0
oEP16LFg:	and.w	d6,(a1)			; D' = S and D
		not.w	(a1)+			; D' = NOT (S and D)
oEP16En0:	dbra	d4,oEP16LFr		; do next pixel

		;
		; do inner loop
		;
oEP16Sk0:	move.w	a4,d2			; d2 <- internal loop
		bra	oEP16En1		; go to the entry point
oEP16Line:	move.w	a5,d4			; d4 <- 15
		move.w	(a0)+,d0		; d5 <- S
oEP16:		lsl.w	d0			; if shifted out bit was set
		bcs	oEP16Fg			; then splat foreground
		and.w	d7,(a1)			; D' = S and D
		not.w	(a1)+			; D' = NOT (S and D)
		dbra	d4,oEP16		; do next pix
		dbra	d2,oEP16Line		; do next set of 16 pixels
		move.w	d3,d4			; d4 <- # of pix in right fringe
		beq	oEP16Sk1		; branch if no right fringe
		move.w	(a0)+,d0		; d0 <- S (for right fringe)
		bra	oEP16En2		; go to the entry point

oEP16Fg:	and.w	d6,(a1)			; D' = S and D
		not.w	(a1)+			; D' = NOT (S and D)
		dbra	d4,oEP16		; do next pix
oEP16En1:	dbra	d2,oEP16Line		; do next set of 16 pixels
		move.w	d3,d4			; d4 <- # of pix in right fringe
		beq	oEP16Sk1		; branch if no right fringe
		move.w	(a0)+,d0		; d0 <- S (for right fringe)
		bra	oEP16En2		; go to the entry point

		;
		; do right fringe
		;		
oEP16RFr:	lsl.w	d0			; if shifted out bit was set
		bcs	oEP16RFg		; then splat foreground
		and.w	d7,(a1)			; D' = S and D
		not.w	(a1)+			; D' = NOT (S and D)
		dbra	d4,oEP16RFr		; do next pixel
		bra	oEP16Sk1
oEP16RFg:	and.w	d6,(a1)			; D' = S and D
		not.w	(a1)+			; D' = NOT (S and D)
oEP16En2:	dbra	d4,oEP16RFr		; do next pixel

oEP16Sk1:	add.w	a2,a0			; a0 -> to next line in src
		add.w	a3,a1			; a1 -> to next line in dst
		swap	d0			; restore line count
		dbra	d0,oEP16Loop		; do next line
		rts

*+
* D' = 1 (fill the destination block)
*-
oFP16Loop:	move.w	#-1,d7			; d0 <- S (for left fringe)
		move.w	d5,d4			; d4 <- # of pix in left fringe

		;
		; do left fringe
		;
		bra	oFP16En0		; go to the entry point
oFP16LFr:	move.w	d7,(a1)+		; set dst to background color
oFP16En0:	dbra	d4,oFP16LFr		; do next pixel

		;
		; do inner loop
		;
		move.w	a4,d2			; d2 <- internal loop
		bra	oFP16En1		; go to the entry point
oFP16Line:	move.w	a5,d4			; d4 <- 15
oFP16:		move.w	d7,(a1)+		; set dst to background color
		dbra	d4,oFP16		; do next pix
oFP16En1:	dbra	d2,oFP16Line		; do next set of 16 pixels
		move.w	d3,d4			; d4 <- # of pix in right fringe
		beq	oFP16Sk1		; branch if no right fringe
		bra	oFP16En2		; go to the entry point

		;
		; do right fringe
		;		
oFP16RFr:	move.w 	d7,(a1)+		; set dst to background color
oFP16En2:	dbra	d4,oFP16RFr		; do next pixel

oFP16Sk1:	add.w	a2,a0			; a0 -> to next line in src
		add.w	a3,a1			; a1 -> to next line in dst
		dbra	d0,oFP16Loop		; do next line
		rts
		.end
