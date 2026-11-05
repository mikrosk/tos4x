*********************************  sbblit.s  **********************************
*
* $Revision: 3.1 $	$Source: /u/lozben/projects/vdi/mtaskvdi/RCS/sbblit.s,v $
* =============================================================================
* $Author: lozben $	$Date: 91/08/06 17:34:28 $     $Locker:  $
* =============================================================================
*
* $Log:	sbblit.s,v $
*******************************************************************************


.include	"lineaequ.s"


		.globl	spx_bitblt
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
**		output:	a0.l -> address of word containing x,y		     **
**									     **
**									     **
**	d_xy2addr:							     **
**									     **
**		input:	d0.w =  x coordinate.				     **
**			d1.w =  y coordinate.				     **
**			a3.l -> line variable structure			     **
**			a6.l -> frame					     **
**									     **
**		output:	a1.l -> address of word containing x,y		     **
**									     **
**		destroys: d0,d1						     **
**									     **
*******************************************************************************
*******************************************************************************

s_xy2addr:	move.l	S_FORM(a6),a0		; a0 -> strt of srce form (0,0)
		mulu	byt_per_pix(a3),d0	; d0 <- x portion of offset
		mulu	S_NXLN(a6),d1		; d1 <- y portion of offset
		add.l	d0,d1			; d1 <- byte offs into mem frm
		add.l	d1,a0			; a0 -> (x,y)
		rts

d_xy2addr:	move.l	D_FORM(a6),a1		; a0 -> strt of dst form (0,0)
		mulu	byt_per_pix(a3),d0	; d0 <- x portion of offset
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
spx_bitblt:	tst.w	S_NXPL(a6)	; see if we are doing transparant blit
		bne	skip0		; if not then skip
		jmp	spx_tbitblt	; else do transparant blit
skip0:		move.l	_lineAVar,a3	; a3 -> linea variable structure
		move.w	S_YMIN(a6),d1	; d1 <- Ymin source
		bsr	s_xy2addr	; a0 -> start of source block

		move.w	D_XMIN(a6),d0	; compute address of source block
		move.w	D_YMIN(a6),d1
		bsr	d_xy2addr	; a1 -> start of destination block

		cmp.l	a1,a0		; which address is larger: src or dst
		blt	do_neg_case	; if source < dest then do neg case

		move.w	B_WD(a6),d3	; d3 <- span in pixels
		ble	leave		; leave if span is zero
		subq.w	#1,d3		; d3 <- span in pixels - 1
		move.w	B_HT(a6),d1	; d1 <- number of lines to blit
		ble	leave		; leave if number of lines is zero
		subq.w	#1,d1		; d1 <- number of lines to blit - 1

		move.w	S_NXLN(a6),d5		; d5 <- src line wrap (in bytes)
		move.w	D_NXLN(a6),d6		; d6 <- dst line wrap (in bytes)
		move.w	B_WD(a6),d7		; d7 <- span in pixels
		mulu	byt_per_pix(a3),d7	; d7 <- span in bytes
		sub.w	d7,d5			; d5 <- off to nxt line in src
		sub.w	d7,d6			; d6 <- off to nxt line in dst

		cmp.w	#16,_v_planes(a3)	; see how many bit per pixel
spx16PTab:	lea	pos16Tab,a3		; a3 -> table of 16 bit routines

tab_set0:	moveq.l	#0,d7			; clear for later use
		move.b	OP_TAB(a6),d7		; d7 <- logic op for the blit
		lsl.w	#2,d7			; d7 <- offset into the table
		move.l	(a3,d7.w),a3		; a3 -> to the desired routine	
		jmp	(a3)

pos16Tab:	dc.l	o0P16Line,o1P16Line,o2P16Line,o3P16Line
		dc.l	o4P16Line,o5P16Line,o6P16Line,o7P16Line
		dc.l	o8P16Line,o9P16Line,oAP16Line,oBP16Line
		dc.l	oCP16Line,oDP16Line,oEP16Line,oFP16Line



do_neg_case:	move.w	S_XMAX(a6),d0	; d0 <- Xmax source
		move.w	S_YMAX(a6),d1	; d1 <- Ymax source
		bsr	s_xy2addr	; a0 -> start of source block

		move.w	D_XMAX(a6),d0	; d0 <- Xmax source
		move.w	D_YMAX(a6),d1	; d1 <- Ymax source
		bsr	d_xy2addr	; a1 -> start of destination block

		move.w	B_WD(a6),d3	; d3 <- span in pixels
		beq	leave		; leave if span is zero
		subq.w	#1,d3		; d3 <- span in pixels - 1
		move.w	B_HT(a6),d1	; d1 <- number of lines to blit
		beq	leave		; leave if number of lines is zero
		subq.w	#1,d1		; d1 <- number of lines to blit - 1

		move.w	S_NXLN(a6),d5		; d5 <- src line wrap (in bytes)
		move.w	D_NXLN(a6),d6		; d6 <- dst line wrap (in bytes)
		move.w	B_WD(a6),d7		; d7 <- span in pixels
		mulu	byt_per_pix(a3),d7	; d7 <- span in bytes
		sub.w	d7,d5			; d5 <- off to nxt line in src
		sub.w	d7,d6			; d6 <- off to nxt line in src
		neg.w	d5			; make d5 neg offset
		neg.w	d6			; make d6 neg offset

		add.w	byt_per_pix(a3),a0	; adjust for predecrement
		add.w	byt_per_pix(a3),a1	; adjust for predecrement

		cmp.w	#16,_v_planes(a3)	; see how many bit per pixel
spx16NTab:	lea	neg16Tab,a3		; a3 -> table of 16 bit routines

tab_set1:	moveq.l	#0,d7			; clear for later use
		move.b	OP_TAB(a6),d7		; d7 <- logic op for the blit
		lsl.w	#2,d7			; d7 <- offset into the table
		move.l	(a3,d7.w),a3		; a3 -> to the desired routine
		jmp	(a3)


neg16Tab:	dc.l	o0N16Line,o1N16Line,o2N16Line,o3N16Line
		dc.l	o4N16Line,o5N16Line,o6N16Line,o7N16Line
		dc.l	o8N16Line,o9N16Line,oAN16Line,oBN16Line
		dc.l	oCN16Line,oDN16Line,oEN16Line,oFN16Line


leave:		rts


*+
*	d1.w	number fo lines to blit - 1
*	d3.w	span in pixels - 1
*	d5.w	offset to next line in source
*	d6.w	offset to next line in destination
*
*	a0	points to the source
*	a1	points to the destination
*-


******************************************************************************
************************** 16 bit case positive case *************************
******************************************************************************

*+
* D' = 0
*-
o0P16Line:	move.w	d3,d7			; d7 <- # pixels to blit - 1
o0P16Loop:	clr.w	(a1)+			; D <- 0
		dbra	d7,o0P16Loop		; do inner loop
		add.w	d6,a1			; a1 -> to next dest line
		dbra	d1,o0P16Line		; do next line
		rts	

*+
* D' = S AND D
*-
o1P16Line:	move.w	d3,d7			; d7 <- # pixels to blit - 1
o1P16Loop:	move.w	(a0)+,d2		; d2 <- S
		and.w	d2,(a1)+		; D' <- S AND D
		dbra	d7,o1P16Loop		; do inner loop
		add.w	d5,a0			; a0 -> to next source line
		add.w	d6,a1			; a1 -> to next dest line
		dbra	d1,o1P16Line		; do next line
		rts	

*+
* D' = S AND [NOT D]
*-
o2P16Line:	move.w	d3,d7			; d7 <- # pixels to blit - 1
o2P16Loop:	not.w	(a1)			; D' = NOT D
		move.w	(a0)+,d2		; d2 <- S
		and.w	d2,(a1)+		; D' = S AND [NOT D]
		dbra	d7,o2P16Loop		; do inner loop
		add.w	d5,a0			; a0 -> to next source line
		add.w	d6,a1			; a1 -> to next dest line
		dbra	d1,o2P16Line		; do next line
		rts	

*+
* D' = S (Replace Mode)
*-
o3P16Line:	move.w	d3,d7			; d7 <- # pixels to blit - 1
o3P16Loop:	move.w	(a0)+,(a1)+		; D' = S
		dbra	d7,o3P16Loop		; do inner loop
		add.w	d5,a0			; a0 -> to next source line
		add.w	d6,a1			; a1 -> to next dest line
		dbra	d1,o3P16Line		; do next line
		rts	

*+
* D' = [NOT S] AND D (Erase Mode)
*-
o4P16Line:	move.w	d3,d7			; d7 <- # pixels to blit - 1
o4P16Loop:	move.w	(a0)+,d2		; d2 <- S
		not.w	d2			; d2 <- NOT S
		and.w	d2,(a1)+		; D' = [NOT S] AND D
		dbra	d7,o4P16Loop		; do inner loop
		add.w	d5,a0			; a0 -> to next source line
		add.w	d6,a1			; a1 -> to next dest line
		dbra	d1,o4P16Line		; do next line
		rts	

*+
* D' = D
*-
o5P16Line:	rts
	
*+
* D' = S XOR D
*-
o6P16Line:	move.w	d3,d7			; d7 <- # pixels to blit - 1
o6P16Loop:	move.w	(a0)+,d2		; d2 <- S
		eor.w	d2,(a1)+		; D' = S XOR D
		dbra	d7,o6P16Loop		; do inner loop
		add.w	d5,a0			; a0 -> to next source line
		add.w	d6,a1			; a1 -> to next dest line
		dbra	d1,o6P16Line		; do next line
		rts	

*+
* D' = S OR D
*-
o7P16Line:	move.w	d3,d7			; d7 <- # pixels to blit - 1
o7P16Loop:	move.w	(a0)+,d2		; d2 <- S
		or.w	d2,(a1)+		; D' = S OR D
		dbra	d7,o7P16Loop		; do inner loop
		add.w	d5,a0			; a0 -> to next source line
		add.w	d6,a1			; a1 -> to next dest line
		dbra	d1,o7P16Line		; do next line
		rts	

*+
* D' = NOT [S OR D]
*-
o8P16Line:	move.w	d3,d7			; d7 <- # pixels to blit - 1
o8P16Loop:	move.w	(a0)+,d2		; d2 <- S
		or.w	d2,(a1)			; D' = S OR D
		not.w	(a1)+			; D' = NOT [S OR D]
		dbra	d7,o8P16Loop		; do inner loop
		add.w	d5,a0			; a0 -> to next source line
		add.w	d6,a1			; a1 -> to next dest line
		dbra	d1,o8P16Line		; do next line
		rts	

*+
* D' = NOT [S XOR D]
*-
o9P16Line:	move.w	d3,d7			; d7 <- # pixels to blit - 1
o9P16Loop:	move.w	(a0)+,d2		; d2 <- S
		eor.w	d2,(a1)			; D' = S XOR D
		not.w	(a1)+			; D' = NOT [S XOR D]
		dbra	d7,o9P16Loop		; do inner loop
		add.w	d5,a0			; a0 -> to next source line
		add.w	d6,a1			; a1 -> to next dest line
		dbra	d1,o9P16Line		; do next line
		rts	

*+
* D' = NOT D
*-
oAP16Line:	move.w	d3,d7			; d7 <- # pixels to blit - 1
oAP16Loop:	not.w	(a1)+			; D' = NOT D
		dbra	d7,o3P16Loop		; do inner loop
		add.w	d6,a1			; a1 -> to next dest line
		dbra	d1,oAP16Line		; do next line
		rts	

*+
* D' = S OR [NOT D]
*-
oBP16Line:	move.w	d3,d7			; d7 <- # pixels to blit - 1
oBP16Loop:	not.w	(a1)			; D' = NOT D
		move.w	(a0)+,d2		; d2 <- S
		or.w	d2,(a1)+		; D' = S OR [NOT D]
		dbra	d7,oBP16Loop		; do inner loop
		add.w	d5,a0			; a0 -> to next source line
		add.w	d6,a1			; a1 -> to next dest line
		dbra	d1,oBP16Line		; do next line
		rts	

*+
* D' = NOT S
*-
oCP16Line:	move.w	d3,d7			; d7 <- # pixels to blit - 1
oCP16Loop:	move.w	(a0)+,d2		; d2 <- S
		not.w	d2			; d2 <- NOT S
		move.w	d2,(a1)+		; D' = NOT S
		dbra	d7,oCP16Loop		; do inner loop
		add.w	d5,a0			; a0 -> to next source line
		add.w	d6,a1			; a1 -> to next dest line
		dbra	d1,oCP16Line		; do next line
		rts	

*+
* D' = [NOT S] OR D
*-
oDP16Line:	move.w	d3,d7			; d7 <- # pixels to blit - 1
oDP16Loop:	move.w	(a0)+,d2		; d2 <- S
		not.w	d2			; d2 <- NOT S
		or.w	d2,(a1)+		; D' = [NOT S] OR D
		dbra	d7,oDP16Loop		; do inner loop
		add.w	d5,a0			; a0 -> to next source line
		add.w	d6,a1			; a1 -> to next dest line
		dbra	d1,oDP16Line		; do next line
		rts		

*+
* NOT [S AND D]
*-
oEP16Line:	move.w	d3,d7			; d7 <- # pixels to blit - 1
oEP16Loop:	move.w	(a0)+,d2		; d2 <- S
		and.w	d2,(a1)			; D' = S AND D
		not.w	(a1)+			; D' = NOT [S AND D
		dbra	d7,oEP16Loop		; do inner loop
		add.w	d5,a0			; a0 -> to next source line
		add.w	d6,a1			; a1 -> to next dest line
		dbra	d1,oEP16Line		; do next line
		rts	

*+
* D' = 1
*-
oFP16Line:	move.w	d3,d7			; d7 <- # pixels to blit - 1
oFP16Loop:	move.w	#-1,(a1)+		; D' = all ones
		dbra	d7,oFP16Loop		; do inner loop
		add.w	d6,a1			; a1 -> to next dest line
		dbra	d1,oFP16Line		; do next line
		rts	

******************************************************************************
******************************* Negative cases *******************************
******************************************************************************
******************************************************************************
************************** 16 bit case negative case *************************
******************************************************************************

*+
* D' = 0
*-
o0N16Line:	move.w	d3,d7			; d7 <- # pixels to blit - 1
o0N16Loop:	clr.w	-(a1)			; D <- 0
		dbra	d7,o0N16Loop		; do inner loop
		add.w	d6,a1			; a1 -> to next dest line
		dbra	d1,o0N16Line		; do next line
		rts	

*+
* D' = S AND D
*-
o1N16Line:	move.w	d3,d7			; d7 <- # pixels to blit - 1
o1N16Loop:	move.w	-(a0),d2		; d2 <- S
		and.w	d2,-(a1)		; D <- S AND D
		dbra	d7,o1N16Loop		; do inner loop
		add.w	d5,a0			; a0 -> to next source line
		add.w	d6,a1			; a1 -> to next dest line
		dbra	d1,o1N16Line		; do next line
		rts	

*+
* D' = S AND [NOT D]
*-
o2N16Line:	move.w	d3,d7			; d7 <- # pixels to blit - 1
o2N16Loop:	not.w	-(a1)			; D' = NOT D
		move.w	-(a0),d2		; d2 <- S
		and.w	d2,(a1)			; D' = S AND [NOT D]
		dbra	d7,o2N16Loop		; do inner loop
		add.w	d5,a0			; a0 -> to next source line
		add.w	d6,a1			; a1 -> to next dest line
		dbra	d1,o2N16Line		; do next line
		rts	

*+
* D' = S (Replace Mode)
*-
o3N16Line:	move.w	d3,d7			; d7 <- # pixels to blit - 1
o3N16Loop:	move.w	-(a0),-(a1)		; D' = S
		dbra	d7,o3N16Loop		; do inner loop
		add.w	d5,a0			; a0 -> to next source line
		add.w	d6,a1			; a1 -> to next dest line
		dbra	d1,o3N16Line		; do next line
		rts	

*+
* D' = [NOT S] AND D (Erase Mode)
*-
o4N16Line:	move.w	d3,d7			; d7 <- # pixels to blit - 1
o4N16Loop:	move.w	-(a0),d2		; d2 <- S
		not.w	d2			; d2 <- NOT S
		and.w	d2,-(a1)		; D' = [NOT S] AND D
		dbra	d7,o4N16Loop		; do inner loop
		add.w	d5,a0			; a0 -> to next source line
		add.w	d6,a1			; a1 -> to next dest line
		dbra	d1,o4N16Line		; do next line
		rts	

*+
* D' = D
*-
o5N16Line:	rts
	
*+
* D' = S XOR D
*-
o6N16Line:	move.w	d3,d7			; d7 <- # pixels to blit - 1
o6N16Loop:	move.w	-(a0),d2		; d2 <- S
		eor.w	d2,-(a1)		; D' = S XOR D
		dbra	d7,o6N16Loop		; do inner loop
		add.w	d5,a0			; a0 -> to next source line
		add.w	d6,a1			; a1 -> to next dest line
		dbra	d1,o6N16Line		; do next line
		rts	

*+
* D' = S OR D
*-
o7N16Line:	move.w	d3,d7			; d7 <- # pixels to blit - 1
o7N16Loop:	move.w	-(a0),d2		; d2 <- S
		or.w	d2,-(a1)		; D' = S OR D
		dbra	d7,o7N16Loop		; do inner loop
		add.w	d5,a0			; a0 -> to next source line
		add.w	d6,a1			; a1 -> to next dest line
		dbra	d1,o7N16Line		; do next line
		rts	

*+
* D' = NOT [S OR D]
*-
o8N16Line:	move.w	d3,d7			; d7 <- # pixels to blit - 1
o8N16Loop:	move.w	-(a0),d2		; d2 <- S
		or.w	d2,-(a1)		; D' = S OR D
		not.w	(a1)			; D' = NOT [S OR D]
		dbra	d7,o8N16Loop		; do inner loop
		add.w	d5,a0			; a0 -> to next source line
		add.w	d6,a1			; a1 -> to next dest line
		dbra	d1,o8N16Line		; do next line
		rts	

*+
* D' = NOT [S XOR D]
*-
o9N16Line:	move.w	d3,d7			; d7 <- # pixels to blit - 1
o9N16Loop:	move.w	-(a0),d2		; d2 <- S
		eor.w	d2,-(a1)		; D' = S XOR D
		not.w	(a1)			; D' = NOT [S XOR D]
		dbra	d7,o9N16Loop		; do inner loop
		add.w	d5,a0			; a0 -> to next source line
		add.w	d6,a1			; a1 -> to next dest line
		dbra	d1,o9N16Line		; do next line
		rts	

*+
* D' = NOT D
*-
oAN16Line:	move.w	d3,d7			; d7 <- # pixels to blit - 1
oAN16Loop:	not.w	-(a1)			; D' = NOT D
		dbra	d7,o3N16Loop		; do inner loop
		add.w	d6,a1			; a1 -> to next dest line
		dbra	d1,oAN16Line		; do next line
		rts	

*+
* D' = S OR [NOT D]
*-
oBN16Line:	move.w	d3,d7			; d7 <- # pixels to blit - 1
oBN16Loop:	not.w	-(a1)			; D' = NOT D
		move.w	-(a0),d2		; d2 <- S
		or.w	d2,(a1)			; D' = S OR [NOT D]
		dbra	d7,oBN16Loop		; do inner loop
		add.w	d5,a0			; a0 -> to next source line
		add.w	d6,a1			; a1 -> to next dest line
		dbra	d1,oBN16Line		; do next line
		rts	

*+
* D' = NOT S
*-
oCN16Line:	move.w	d3,d7			; d7 <- # pixels to blit - 1
oCN16Loop:	move.w	-(a0),d2		; d2 <- S
		not.w	d2			; d2 <- NOT S
		move.w	d2,-(a1)		; D' = NOT S
		dbra	d7,oCN16Loop		; do inner loop
		add.w	d5,a0			; a0 -> to next source line
		add.w	d6,a1			; a1 -> to next dest line
		dbra	d1,oCN16Line		; do next line
		rts	

*+
* D' = [NOT S] OR D
*-
oDN16Line:	move.w	d3,d7			; d7 <- # pixels to blit - 1
oDN16Loop:	move.w	-(a0),d2		; d2 <- S
		not.w	d2			; d2 <- NOT S
		or.w	d2,-(a1)		; D' = [NOT S] OR D
		dbra	d7,oDN16Loop		; do inner loop
		add.w	d5,a0			; a0 -> to next source line
		add.w	d6,a1			; a1 -> to next dest line
		dbra	d1,oDN16Line		; do next line
		rts		

*+
* NOT [S AND D]
*-
oEN16Line:	move.w	d3,d7			; d7 <- # pixels to blit - 1
oEN16Loop:	move.w	-(a0),d2		; d2 <- S
		and.w	d2,-(a1)		; D' = S AND D
		not.w	(a1)			; D' = NOT [S AND D
		dbra	d7,oEN16Loop		; do inner loop
		add.w	d5,a0			; a0 -> to next source line
		add.w	d6,a1			; a1 -> to next dest line
		dbra	d1,oEN16Line		; do next line
		rts	

*+
* D' = 1
*-
oFN16Line:	move.w	d3,d7			; d7 <- # pixels to blit - 1
oFN16Loop:	move.w	#-1,-(a1)		; D' = all ones
		dbra	d7,oFN16Loop		; do inner loop
		add.w	d6,a1			; a1 -> to next dest line
		dbra	d1,oFN16Line		; do next line
		rts	
		
	.end
