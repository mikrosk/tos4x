*
* memory test, used by dmaboot to kill time while waiting for
* hard disks to spin up.
*
* This is called multiple times; each time it's expected to
* return reasonably quickly so other things (i.e. check keyboard
* for a breakout key) can happen.  The mt_state variable tells
* what's going on, and other mt_ variables contain state too.
*
* state0: initialize mt_start, mt_end, print message, go to state 1.
* state1: test in 128KB blocks starting at mt_start until mt_end 
*	  is reached.  In either case go to state 2.
* state2: initialize mt_start, mt_end for TT RAM, print msg, state 3.
* state3: test in 128KB blocks starting at mt_start until mt_end
*	  is reached.  In either case go to state 4
* state4: print "done" msg, go to state 5
* state5: do nothing.
*
* Memory is checked in 128K blocks because it was originally sized
* in 128K blocks, so we know there is a whole number of such blocks
* in the system.  Users should get suspicious if there isn't as
* much tested here as they think they have, but that's another story.
*
* State2 degenerates into state 4 if you're not on a TT or have no TT RAM.
*
* mem_test_next returns 0 in d0 and EQ in ccr when it isn't done yet,
* and -1 in d0 and NE in ccr when it is.
*
* mt_start is the counter that tells where to start testing in the next
* cycle.  mt_beg is the first memory address to really test; before that
* are dummies.  mt_end is the last memory address to really test; after
* that is dummies.  mt_top is the actual end of the memory region, and thus
* the end of the region to print dashes for.
*
* The test prints a dash for every block that passes, up to 32 dashes;
* if you have more that 32*128K in your system you still get 32 dashes
* and they come out slower.
*

*
* configuration section: 
* Set test to 1 if you want something you can run as a PRG.
*

test		equ	0

* exports
	.globl	mem_test_next
	.globl	mem_abort
	.globl	mtestmsg

* imports
	.globl	phystop
	.globl	_ramtop
	.globl	_memtop
	.globl	_membot
	.globl	_v_bas_ad

*phystop	equ	$42e
*_ramtop	equ	$5a4
*_memtop	equ	$436
*_membot	equ	$432

.if test

.globl _main
_main:
	move.l	4(sp),a5
	move.l	#mt_stack,-(sp)
	move.w	#$20,-(sp)
	trap	#1

	move.l	$18(a5),d0
	add.l	$1c(a5),d0		; d0 is start of my heap
	move.l	d0,_membot
	move.l	4(a5),d1		; d1 = end of heap
	move.l	#((128*1024)-1),d0
	not.l	d0			; (stupid mas has no ~ operator)
	and.l	d0,d1			; round down to 128K boundary
	move.l	d1,_v_bas_ad
	clr.l	_ramtop
	move.l	$42e,phystop

	move.w	#1,-(sp)
	move.l	#-1,-(sp)
	move.w	#$44,-(sp)
	trap	#1			; Mxalloc(-1L,1);
	addq	#8,sp
	move.l	d0,d7			; d7 holds amt of tt ram for state2
	beq	nottram

	move.w	#1,-(sp)
	move.l	d0,-(sp)
	move.w	#$44,-(sp)
	trap	#1
	addq	#8,sp
	move.l	d0,d6			; d6 holds start of tt ram for state2

	move.l	#$02000000,_ramtop	; assume a true TT RAM size of 16MB
nottram:

l0:	bsr	mem_test_next
	beq	l0
	clr.w	-(sp)
	trap	#1

.endif

.macro putchar c
	move.w	c,-(sp)
	move.l	#$00030002,-(sp)
	trap	#$d
	addq	#6,sp
.endm

mem_test_next:
	move.l	mt_state,a0
	move.l	a0,d0
	beq	mstate0			; first call
	jmp	(a0)

mstate0:
	move.l	#mtestmsg,a0
	bsr	prmsg
	clr.l	mt_start		; region base is zero
	move.l	phystop,mt_top		; region top is phystop
	move.l	_membot,d0		; get end of OS mem usage
	add.l	#(128*1024)-1,d0	; round up to 128K boundary
	move.l	#(128*1024)-1,d1
	not.l	d1
	and.l	d1,d0			; (stupid mas has no ~ operator)
	move.l	d0,mt_beg		; that is the first address to test
	move.l	_v_bas_ad,d0		; get start of screen RAM
	and.l	d1,d0			; round down to 128KB boundary
	move.l	d0,mt_end		; this is end address to test
	clr.w	mt_badflag
	move.l	#mstate1,mt_state
	bra	dobar			; set interval, draw bar, return 0

mstate1:
	bsr	mblktest
	move.w	mt_badflag,d1		; remember if any were bad
	or.w	d0,d1
	move.w	d1,mt_badflag

	move.l	mt_countdown,d0		; decr our print-a-dot countdown
	sub.l	#(128*1024),d0
	move.l	d0,mt_countdown
	bgt	m1nodot

; yes, time to put up a dot
	move.l	mt_interval,d0
	add.l	d0,mt_countdown		; reload countdown, preserving wrap
	tst.w	mt_badflag		; put up a - or X as appropriate
	beq	m1good
	putchar	#'X'
	bra	m1dotdone
m1good:
	putchar	#'-'
m1dotdone:
	clr.w	mt_badflag		; forget badness
m1nodot:
	move.l	mt_start,d0
	cmp.l	mt_top,d0		; stop when start == top
	bne	m1done

* done with state 1; print the actual number of KB in ST RAM
* but first back up by nine spaces (so this msg overlaps the dashes)

	move.l	d7,-(sp)
	moveq.l	#8,d7
m1bs:	putchar	#8
	dbra	d7,m1bs
	move.l	(sp)+,d7

	putchar	#' '
	move.l	phystop,d0
	asr.l	#8,d0
	asr.l	#2,d0
	bsr	pdecl
	move.l	#mkbmsg,a0		; say " KB"
	bsr	prmsg

	move.l	#mstate2,mt_state
m1done:	clr.l	d0			; return EQ when not done
	rts

mstate2:
	clr.w	mt_badflag
	move.l	_ramtop,d0
	beq	mstate4			; if no TT RAM, do state 4.
	cmp.l	#$01000000,d0
	beq	mstate4			; if no TT RAM, do state 4.

	move.l	d0,mt_top

	move.l	#$01000000,mt_start

.if test
	move.l	d6,mt_beg		; d6 is bottom of what we can touch
	move.l	d7,d0
	add.l	d6,d0			; d0 is top of what we can touch
.else
	move.l	mt_start,mt_beg
.endif

	move.l	#((128*1024)-1),d1	; round down to 128K boundary
	not.l	d1
	and.l	d1,d0
	move.l	d0,mt_end

	move.l	#mttmsg,a0
	bsr	prmsg
	move.l	#mstate3,mt_state
	bra	dobar			; set interval, draw bar, return 0

mstate3:
	bsr	mblktest
	move.w	mt_badflag,d1
	or.w	d0,d1
	move.w	d1,mt_badflag

	move.l	mt_countdown,d0
	sub.l	#(128*1024),d0
	move.l	d0,mt_countdown
	bgt	m3nodot

; yes, time to put up a dot
	move.l	mt_interval,d0
	add.l	d0,mt_countdown
	tst.w	mt_badflag
	beq	m3good
	putchar	#'X'
	bra	m3dotdone
m3good:
	putchar	#'-'
m3dotdone:
	clr.w	mt_badflag
m3nodot:
	move.l	mt_start,d0
	cmp.l	mt_end,d0
	bne	m3done

* end of state 3; print actual number of KB of TT RAM
* but back up by nine spaces first so number of KB overlaps dashes

	move.l	d7,-(sp)
	moveq.l	#8,d7
m3bs:	putchar	#8
	dbra	d7,m3bs
	move.l	(sp)+,d7

	putchar	#' '
	move.l	_ramtop,d0
	sub.l	#$01000000,d0
	asr.l	#8,d0
	asr.l	#2,d0
	bsr	pdecl
	move.l	#mkbmsg,a0
	bsr	prmsg

	move.l	#mstate4,mt_state
m3done:	clr.l	d0			; return EQ when not done
	rts

mstate4:
	move.l	#mdonemsg,a0
	bsr	prmsg
	move.l	#mstate5,mt_state
	clr.l	d0			; return EQ when not done
	rts

mem_abort:
	tst.l	mt_state		; if haven't started, shut up.
	beq	mstate5
	cmp.l	#mstate5,mt_state	; if already in state 5, shut up.
	beq	mstate5
	move.l	#mabrtmsg,a0		; say we aborted
	bsr	prmsg
	move.l	#mstate5,mt_state	; go to state 5
mstate5:
	moveq.l	#-1,d0			; return NE when done
	rts

dobar:
* compute number of blocks and interval for mt_start - mt_top
* even though we're only testing from mt_beg through mt_end
*
* If it's 1MB or less then we have to space over some.
*
	move.l	mt_top,d0
	sub.l	mt_start,d0
	cmp.l	#(1024*1024),d0		; need to space over?
	bhi	nospace			; no
	move.l	#spacemsg,a0		; yes: output spaces
	bsr	prmsg

nospace:
	move.l	#invmsg,a0		; begin inverse video
	bsr	prmsg
	move.l	mt_top,d0
	sub.l	mt_start,d0		; get RAM size to d0 again

	cmp.l	#(1024*4096),d0
	ble	i128			; 4MB and lower: 128KB blocks

	move.l	d0,d2
	lsr.l	#5,d2			; d2 is size/32
	move.l	d2,mt_interval		; which is interval
	moveq.l	#32,d2			; d2 is now number of blocks
	bra	gotnblocks

i128:	move.l	#(128*1024),mt_interval	; interval is 128K
	move.l	d0,d2
	clr.w	d2
	swap	d2			; d2 /= 64K
	lsr.l	#1,d2			; d2 /= 2 (total 128K) 
					; d2 is now size/128K,
					; which is number of blocks

gotnblocks:
	move.l	d7,-(sp)		; save register
	move.l	mt_interval,mt_countdown	; init countdown
	move.l	d2,d7
	move.l	d2,-(sp)		; save d2 for later
blloop:
	putchar	#' '			; until d2 expires
	subq.l	#1,d7
	bne	blloop
	move.l	(sp)+,d7		; get original d2 back into d7

bsloop:	putchar	#8			; until d2 expires
	subq.l	#1,d7
	bne	bsloop
	move.l	(sp)+,d7		; restore d7
	clr.l	d0			; return EQ when not done
	rts

mttmsg:		dc.b	13,10,"TT RAM ",0
mdonemsg:	dc.b	13,10,"Memory Test Complete.",13,10,0

mkbmsg:		dc.b	" KB",27,"q",27,"K",0
mabrtmsg:	dc.b	13,10,"Memory Test Aborted.",27,"q",13,10,0
invmsg:		dc.b	27,'p',0
spacemsg:	dc.b	"       ",0

.even

*
* prmsg: print the message whose address is in a0
* Destroys d0-d2/a0-a2.
*

prmsg:	move.l	a5,-(sp)
	move.l	a0,a5
prloop:	move.b	(a5)+,d0
	beq	prdone
	putchar	d0
	bra	prloop
prdone:	move.l	(sp)+,a5
	rts

*
* mblktest: test 128KB from mt_start.
* Returns d0=0 for OK, d0=-1 for bad in the block somewhere
*

mblktest:
	moveq.l	#0,d0			; pre-set to "no error"
	move.l	mt_start,d1
	cmp.l	mt_beg,d1		; if mt_start < mt_beg, skip test
	blo	mtdone
	cmp.l	mt_end,d1		; if mt_start >= mt_end, skip test
	bhs	mtdone

	move.l	#((128*1024)/4)-1,d0	; d0 is dbra count in longs
	move.l	d0,d1			; save count in d1

	move.l	mt_start,a0
	moveq.l	#-1,d2
mta:	move.l	d2,(a0)+		; fill with -1
	dbra	d0,mta

	move.l	mt_start,a0
	move.l	d1,d0
mtb:	cmp.l	(a0)+,d2		; compare with -1
	dbne	d0,mtb
	bne	mtbad

	move.l	mt_start,a0
	move.l	d1,d0
	moveq.l	#1,d2
mtc:	rol.l	#1,d2			; fill with walking bit
	move.l	d2,(a0)+
	dbra	d0,mtc

	move.l	mt_start,a0
	move.l	d1,d0
	moveq.l	#1,d2
mtd:	rol.l	#1,d2
	cmp.l	(a0)+,d2		; compare with walking bit
	dbne	d0,mtd
	bne	mtbad

	move.l	mt_start,a0
	move.l	d1,d0
	moveq.l	#0,d2			; fill with zero - left that way
mte:	move.l	d2,(a0)+
	dbra	d0,mte

	move.l	mt_start,a0
	move.l	d1,d0
mtf:	cmp.l	(a0)+,d2		; compare with zero
	dbne	d0,mtf
	bne	mtbad
	moveq.l	#0,d0
	bra	mtdone

mtbad:	moveq.l	#-1,d0
mtdone:	move.l	mt_start,a0		; advance mt_start
	add.l	#(128*1024),a0
	move.l	a0,mt_start		; write new value back
	rts				; return d0=0 for OK, 1 for bad

;; pdeclx -- print word in d0.l in decimal
;; pdecl  -- print word in d0.l in decimal with leading blanks
	.globl	pdeclx,pdecl

pdeclx:	movem.l	d3-d4,-(sp)
	moveq	#1,d4
	bra.b	pdecl0

pdecl:	movem.l	d3-d4,-(sp)
	clr.l	d4

pdecl0:	move.l	#10000,d2
	clr.w	d3		; no digits have been printed yet

* special case for 64K exactly; we can print anything from 0
* to 64K (as opposed to 64K-1).

	cmp.l	#$00010000,d0
	bne	p1
	putchar	#'6'
	putchar	#'5'
	putchar	#'5'
	putchar	#'3'
	putchar	#'6'
	bra	p5

p1:
	divu	d2,d0
	swap	d0
	move.w	d0,d1		; d1 has remainder
	swap	d0

	movem.l	d1-d2,-(sp)

	or.b	d0,d0		; if non-zero digit
	bne.b	p2
	tst	d3		; or, a non-zero digit has been printed
	bne.b	p2
	cmpi.l	#1,d2		; or it is the last digit
	beq.b	p2		; then go print this digit
	tst.w	d4		; else is this 'no leading blank mode'?
	bne.b	p4		; then don't print anything
	move.b	#' ',d0		; else print a space
	bra.b	p3
p2:	addi.b	#'0',d0		; ASCII adjust
	moveq	#1,d3		; something has been printed

p3:	putchar	d0
p4:	movem.l	(sp)+,d1-d2

	move.l	d1,d0		; last remainder becomes new dividend

	move.l	#10,d1
	divu	d1,d2		; divu.l d1,d2:d2  (d2/d1 -> d2, no remainder)
	bne	p1
p5:
	movem.l	(sp)+,d3-d4
	rts

.bss
mt_state:	ds.l	1

mt_start:	ds.l	1	; region starts here
mt_beg:		ds.l	1	; start testing here
mt_end:		ds.l	1	; stop testing here
mt_top:		ds.l	1	; region stops here

mt_interval:	ds.l	1
mt_countdown:	ds.l	1

mt_badflag:	ds.w	1

.if test
		ds.b	1024
mt_stack:	ds.b	0
_memtop:	ds.l	1
_v_bas_ad:	ds.l	1
_membot:	ds.l	1
_ramtop:	ds.l	1

phystop:	ds.l	1

.endif
