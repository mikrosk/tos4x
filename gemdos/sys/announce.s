.include atari

AINIT = $a000
APUTPIX = $a001
AGETPIX = $a002
ALINE = $a003
AHLINE = $a004
AFRECT = $a005
AFPOLY = $a006
ABITBLT = $a007

	.globl _version

	.text
msg:	.dc.b	"\eE\r\tWARNING: LoGiC hAzArD\r\n"
_stopm:: .dc.b	"\tRAM GEMDOS "
_vers:	.dc.b	"000000-0000\r\n"
	.dc.b	"\treport problems to kbad\r\n\n",0

msg3:	.dc.b	" Right Shift installs stub\r\n"
	.dc.b	" Control causes DB stop\r\n"
	.dc.b	" Alternate aborts GEMDOS load\r\n",0

	.even

_announce::
	pea		_vers(pc)
	jsr		_version
	addq	#4,sp
	pea.l	msg(PC)
	move.w	#9,-(sp)
	trap	#1
	addq	#6,sp

	.dc.w	$a000
	move.l	a0,a3
	move.w	#0,X1(a3)
	move.w	#$0f,X2(a3)
	move.w	#1,COLBIT0(a3)
	move.w	#1,COLBIT1(a3)
	move.w	#1,COLBIT2(a3)
	move.w	#1,COLBIT3(a3)
	move.w	#0,WMODE(a3)

	moveq	#$1f,d7
	lea.l	icon1(pc),a4
	move.w	d7,d6
	lsl.w	#1,d6

.loop1:
	move.w	d7,Y2(a3)
	move.w	d7,Y1(a3)
	move.w	(a4,d6.w),LNMASK(a3)
	.dc.w	$a003
	subq.w	#2,d6
	dbra	d7,.loop1

	moveq	#$1f,d7
	lea.l	icon2(pc),a4
	move.w	#$10,X1(a3)
	move.w	#$1f,X2(a3)
	move.w	d7,d6
	lsl.w	#1,d6

.loop2:
	move.w	d7,Y2(a3)
	move.w	d7,Y1(a3)
	move.w	(a4,d6.w),LNMASK(a3)
	.dc.w	$a003
	subq.w	#2,d6
	dbra	d7,.loop2

	; clear d7 & d6 == 0 so they're both FALSE when we return.

	clr.w	d7
	clr.w	d6

	; pause while left shift is down (give time for stop button or reading)
	; right shift says "Yes, install the stub."
	; ctl says "Install the stub AND cause a stop right away."

	; first, check left shift & give a msg if it's down

	Kbshift #-1
	btst	#1,d0
	beq.s	.done

	pea.l	msg3
	move.w	#9,-(sp)
	trap	#1
	addq.w	#6,sp
	
.kbloop:
	Kbshift	#-1
	btst	#1,d0
	beq.s	.done		; left shift not down (any more) -> done.
	btst	#0,d0		; right shift sets stub flag
	bne.s	.dostub
	btst	#2,d0		; ctl sets stub flag & msg flag
	bne.s	.domsg
	btst	#3,d0		; alt sets "don't install at all!" flag
	bne	.noinst
	bra.s	.kbloop

.noinst:
	st	d6		; d6=1/d7=0 means don't install at all!
	sf	d7
	rts

.domsg:
	st	d6

.dostub:
	st	d7

.done:	rts

icon1:	.dc.w	$0000,$000F,$007F,$00FA,$03D5,$07AA,$0F55,$0FAA
	.dc.w	$1DD5,$38EF,$307F,$3038,$703C,$606E,$6277,$666B
	.dc.w	$6275,$626B,$6277,$606E,$703C,$3038,$307F,$38EF
	.dc.w	$1DD5,$0FAA,$0F55,$07AA,$03D5,$00FA,$007F,$000F

icon2:	.dc.w	$0000,$F800,$FF00,$AF80,$55E0,$AAF0,$5578,$AAF8
	.dc.w	$55DC,$FB8E,$FF06,$0E06,$1E07,$3B03,$7733,$EB4B
	.dc.w	$D74B,$EB4B,$7733,$3B03,$1E07,$0E06,$FF06,$FB8E
	.dc.w	$55DC,$AAF8,$5578,$AAF0,$55E0,$AF80,$FF00,$F800

