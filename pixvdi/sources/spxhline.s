*********************************  spxhline.s  ********************************
*
* $Revision: 3.1 $	$Source: /u/lozben/projects/vdi/mtaskvdi/RCS/sbblit.s,v $
* =============================================================================
* $Author: lozben $	$Date: 91/08/06 17:34:28 $     $Locker:  $
* =============================================================================
*
* $Log:	sbblit.s,v $
*******************************************************************************


.include	"lineaequ.s"

	.globl	PX_HABLINE
	.globl	px_fline
	.globl	spx_hline

*******************************************************************************
*******************************************************************************
**									     **
**	HABLINE								     **
**									     **
**	This routine draws a line between (X1,Y1) and (X2,Y1) using the	     **
**	BLASTER hardware bit blt.					     **
**	The line has attributes of color, pattern, and writing mode	     **
**									     **
**	Note that 2 entry points are provided for ABLINE		     **
**									     **
**	input:		X1 = minimum X of line	     (assumed to be clipped) **
**			X2 = maximum X of line	     (assumed to be clipped) **
**			Y1 = row that line is on     (assumed to be clipped) **
**		    PATMSK = index mask for pattern			     **
**		    PATPTR = pointer to start of pattern		     **
**		 _v_planes = number of video planes			     **
**		 _WRT_MODE = writing mode				     **
**									     **
**			      0 => replace mode.			     **
**			      1 => transparent mode.			     **
**			      2 => xor mode.				     **
**			      3 => reverse transparent mode.		     **
**									     **
**		 V_HLINE = pointer to horizontal line primitive		     **
**									     **
**	output:	  nothing is returned					     **
**									     **
**	destroys: everything						     **
**									     **
*******************************************************************************
*******************************************************************************


PX_HABLINE:

	move.l	_lineAVar,a4		; a4 -> LineA variable base
	movem.w	_X1(a4),d4-d6		; d4 <- X1   d5 <- Y1   d6 <- X2

px_fline:
	move.w	d4,d7			; means pattern is rotated as though
					;    it started at X = 0
	move.w	d5,d0			; d0 <- Y1
	and.w	_patmsk(a4),d0		; d0 <- initial pattern index
	add.w	d0,d0			; d0 <- initial pattern offset
	tst.w	_multifill(a4)		; d0 <- offset to next pattern plane
	beq	pxh0			; skip if pattern is not multi plane
	mulu	_v_planes(a4),d0	; d0 <- offset to pattern line

pxh0:
	move.l	_patptr(a4),a0		; a0 -> start of pattern
	add.w	d0,a0			; a0 -> pattern word

	move.l	_lineAVar,a4		; a4 -> base of LineA variables
	move.l	V_ROUTINES(a4),a1	; load vectrd list of primitives
	move.l	V_HLINE(a1),a1		; vec to vert line primitive
	jmp	(a1)			; sft: "aline"  hrd: "hb_vline"

*+
*	d0.w	pattern mask
*	d4.w	X1
*	d5.w	Y1
*	d6.w	X2
*	d7.w	pattern start in X direction
*
*	a0	points to pattern word
*	a4	points to line A varibale structure
*-
spx_hline:
	move.l	_v_bas_ad,a1		; a1 -> base of screen
	move.w	_v_lin_wr(a4),d1	; d1 <- dst width (in bytes)
	mulu	d5,d1			; d1 <- y offset for dst
	move.w	d4,d2			; d2 <- X1
	mulu	byt_per_pix(a4),d2	; d2 <- x portion of offset
	add.l	d1,d2			; d2 <- byte offs into mem frm
	add.l	d2,a1			; a1 -> (x,y)

	sub.w	d4,d6			; d6 <- dY: Y2-Y1

	tst.w	_multifill(a4)		; d0 <- offset to next pattern plane
	bne	multiFill		; do multiplane pattern fill

	move.w	#15,d3
	and.w	d7,d3			; number of pixels to rotate mask
	move.w	(a0),d2			; d2 <- line style mask for this line
	rol.w	d3,d2			; adjust the mask
	move.l	#-1,d0			; mask for XOR mode
	move.l	_FG_B_PLANES(a4),d3	; a1 -> bitplane color array

	lsl.w	#2,d3			; make d3 long word offset
	add.l	#pal_map,d3		; d3 <- desired offset
	move.l	(a4,d3.w),d3		; d3 <- desired foreground col
	move.l	pal_map(a4),d4		; d4 <- desired background col
	
	cmp.w	#-1,d2			; solid line ?
	beq	spxsolid		; then no line style mask

	cmp.w	#16,_v_planes(a4)	; see how many bits per pixel
	lea	HLine16Tab,a2		; a2 -> table of 16 bit routines

tab_set:
	move.w	_WRT_MODE(a4),d5	; clear for later use
	lsl.w	#2,d5			; d2 <- offset into the table
	move.l	(a2,d5.w),a2		; a2 -> desired routine
	jmp	(a2)			; go to the desired routine

HLine16Tab:	dc.l	H16M1Line,H16M2Line,H16M3Line,H16M4Line

spxsolid:
	cmp.w	#16,_v_planes(a4)	; see how many bits per pixel
	lea	HSol16Tab,a2		; a2 -> table of 16 bit solid routines
	move.w	_WRT_MODE(a4),d5
	lsl.w	#2,d5			; d5 <- offset into the table
	move.l	(a2,d5.w),a2		; a2 -> desired routine
	jmp	(a2)			; go to the desired routine

HSol16Tab:	dc.l	S16M1Line,S16M1Line,S16M3Line,S16M4Line

*+
*	d0	contains $ffffffff
*	d2	line style mask
*	d3	foreground color
*	d4	background color
*	d6	# of pixels to plot - 1
*
*	a1	points to the first pixel
*-

******************************************************************************
******************************* 16 bit HLINE CASE ****************************
******************************************************************************
*+
* Replace mode (1)
*-
H16M1Line:
	rol.w	d2			; rotate the line style mask
	bcs	H16M1FG			; if cary is set set to foreground
	move.w	d4,(a1)+		; set to background
	dbra	d6,H16M1Line		; do next pixel
	rts

H16M1FG:
	move.w	d3,(a1)+		; set to foreground
	dbra	d6,H16M1Line		; do next pixel
	rts

*+
* Transparant mode (2)
*-
H16M2Line:
	rol.w	d2			; rotate the line style mask
	bcs	H16M2FG			; if cary is set set to foreground
	addq.w	#2,a1			; point to next pixel
	dbra	d6,H16M2Line		; do next pixel
	rts

H16M2FG:
	move.w	d3,(a1)+		; set to foreground
	dbra	d6,H16M2Line		; do next pixel
	rts

*+
* XOR mode (3)
*-
H16M3Line:
	rol.w	d2			; rotate the line style mask
	bcs	H16M3FG			; if cary is set set to foreground
	addq.w	#2,a1			; point to next pixel
	dbra	d6,H16M3Line		; do next pixel
	rts

H16M3FG:
	eor.w	d0,(a1)+		; set to foreground
	dbra	d6,H16M3Line		; do next pixel
	rts

*+
* Reverse Transparent mode (4)
*-
H16M4Line:
	rol.w	d2			; rotate the line style mask
	bcs	H16M4FG			; if cary is set set to foreground
	move.w	d3,(a1)+		; set to foreground
	dbra	d6,H16M4Line		; do next pixel
	rts

H16M4FG:
	addq.w	#2,a1			; point to next pixel
	dbra	d6,H16M4Line		; do next pixel
	rts

******************************************************************************
************************  MULTIPLANE PATTERN HLINE CASE **********************
******************************************************************************

*+
*	d4	X1
*	d6	# of pixels to plot - 1
*
*	a0	points to pattern line
*	a1	points to the first pixel
*	a4	points to line A varibale structure
*-
multiFill:
	and.w	#15,d4			; d4 <- X1 mod 16
	move.w	d4,d0			; d0 <- X1 mod 16

	move.w	d4,d5			; d5 <- # of pixels into pattern word
	movea.l	a0,a2			; a2 -> pattern line
	mulu	byt_per_pix(a4),d4	; d4 <- offset into pattern line
	add.w	d4,a0			; a0 -> into the proper pattern word
	move.w	#15,d0			; d5 <- int loop count (16 pix = 1 word)

	sub.w	#15,d5
	neg.w	d5			; d5 <- 15 - mod 16 count

	cmp.w	#16,_v_planes(a4)	; see how many bits per pixel

*+
*	d0	contains the number 15
*	d5	15 - mod 16 count
*	d6	# of pixels to plot - 1
*
*	a0	points to pattern word
*	a1	points to the first pixel
*	a2	points to pattern line
*-

M16MFill:
	move.w	(a0)+,(a1)+
	subq.w	#1,d6			; decremnts # of pixels
	bmi	M16MLeave		; if finished then leave
	dbra	d5,M16MFill		; check to see if doing new 16 pix
	move.w	d0,d5			; start new 16 pixel counter
	movea.l	a2,a0			; start new pattern line
	bra	M16MFill		; loop back to do more of same line

M16MLeave:
	rts



******************************************************************************
*************************** 16 bit solid HLINE CASE **************************
******************************************************************************
*+
* Replace and Transparent mode (1, 2): two pixels per long
*-
S16M1Line:
	move.w	d3,d4
	swap	d3
	move.w	d4,d3			; d3 <- foreground in both words
	addq.w	#1,d6			; d6 <- # of pixels to plot
	move.w	d6,d2
	and.w	#1,d2			; d2 <- odd pixel left over
	asr.w	#1,d6			; d6 <- # of pixel pairs
	beq	s16m1odd
	subq.w	#1,d6
s16m1loop:
	move.l	d3,(a1)+		; set to foreground
	dbra	d6,s16m1loop		; do next pixel pair
s16m1odd:
	tst.b	d2
	beq	s16m1done
	move.w	d3,(a1)+		; set the last pixel
s16m1done:
	rts

*+
* XOR mode (3)
*-
S16M3Line:
	addq.w	#1,d6			; d6 <- # of pixels to plot
	move.w	d6,d2
	and.w	#1,d2			; d2 <- odd pixel left over
	asr.w	#1,d6			; d6 <- # of pixel pairs
	beq	s16m3odd
	subq.w	#1,d6
s16m3loop:
	eor.l	d0,(a1)+		; XOR with -1
	dbra	d6,s16m3loop		; do next pixel pair
s16m3odd:
	tst.b	d2
	beq	s16m3done
	eor.w	d0,(a1)+		; XOR the last pixel
s16m3done:
	rts

*+
* Reverse Transparent mode (4)
*-
S16M4Line:
	rts

