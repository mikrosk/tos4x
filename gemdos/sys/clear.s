	.globl	_clear


*+
*  Quickly zero (lots of) memory.
*
*  Synopsis:	clear(start, end)
*		    LONG start;	    4(sp) -> first location
*		    LONG end;	    8(sp) -> last location + 1
*
*    Uses:	C registers
*
*-
_clear:
	move.l	4(sp),a0	; a0 -> start
	move.l	8(sp),a1	; a1 -> end+1

	movem.l	d2-d7/a2-a3,-(sp)	; save registers
	movem.l	zeros(pc),d1-d7/a3 ; get 32 bytes of zero

	move.l	a0,d0		; word align first location
	btst	#0,d0
	beq.s	clr1		; (not necessary)
	move.b	d1,(a0)+

clr1:	move.l	a1,d0		; d0 = ((a1 - a0) & ~0xff)
	sub.l	a0,d0
	and.l	#$ffffff00,d0	; mask fractional bits
	beq.s	clr3		; if (d0 == 0) do end-fraction;
	lea	(a0,d0.l),a0	; a0 -> end of huge area
	move.l	a0,a2		; a2 -> there, too
	lsr.l	#8,d0		; get 256-byte chunk count
	subq	#1,d0		; pre-decrement for dbra

clr2:	movem.l	d1-d7/a3,-(a2)	; clear 32 bytes
	movem.l	d1-d7/a3,-(a2)	; clear 32 bytes
	movem.l	d1-d7/a3,-(a2)	; clear 32 bytes
	movem.l	d1-d7/a3,-(a2)	; clear 32 bytes
	movem.l	d1-d7/a3,-(a2)	; clear 32 bytes
	movem.l	d1-d7/a3,-(a2)	; clear 32 bytes
	movem.l	d1-d7/a3,-(a2)	; clear 32 bytes
	movem.l	d1-d7/a3,-(a2)	; clear 32 bytes
	dbra	d0,clr2

	bra	clr3

clr4:	move.b	d1,(a0)+	; clear a byte
clr3:	cmp.l	a0,a1		; while (a0 != a1)
	bne.s	clr4		; (not done)

	movem.l	(sp)+,d2-d7/a2-a3	; restore registers
	rts


zeros:	dc.l	0,0,0,0,0,0,0,0
