******************* Revision Control System *****************************
*
* $Author: lozben $
* =======================================================================
*
* $Date: 87/11/20 14:23:37 $
* =======================================================================
*
* $Locker:  $
* =======================================================================
*
* $Log: clear.s,v $
* Revision 1.1  87/11/20  14:23:37  lozben
* Initial revision
*
*
* =======================================================================
*
* $Revision: 1.1 $
* =======================================================================
*
* $Source: /u2/MRS/osrevisions/bios/clear.s,v $
* =======================================================================
*
*************************************************************************
*+
*
*  Quickly zero (lots of) memory.
*  Copyright 1986 Atari Corp.
*
*  Synopsis:	clear(start, end)
*		    LONG start;	    4(sp) -> first location
*		    LONG end;	    8(sp) -> last location + 1
*
*    Uses:	C registers d0-d2/a0-a2
*
*-
	.globl _clear
_clear:
	move.l	4(sp),a0		; a0 -> start
	move.l	8(sp),a1		; a1 -> end+1
	movem.l	d3-d7/a3,-(sp)		; save registers

	moveq	#0,d1			; get lots of cheap zeros
	moveq	#0,d2			; into d1-d7/a3
	moveq	#0,d3
	moveq	#0,d4
	moveq	#0,d5
	moveq	#0,d6
	moveq	#0,d7
	move.w	d7,a3

	move.l	a0,d0			; word align first location
	btst	#0,d0
	beq.s	clr1			; (not necessary)
	move.b	d1,(a0)+

clr1:	move.l	a1,d0			; d0 = ((a1 - a0) & ~0xff)
	sub.l	a0,d0
	and.l	#$ffffff00,d0		; mask fractional bits, d0 = whole part
	beq.s	clr3			; if (d0 == 0) do end-fraction;
	lea	(a0,d0.l),a0		; a0 -> end of huge area
	move.l	a0,a2			; a2 -> there, too
	lsr.l	#8,d0			; get 256-byte chunk count

clr2:	movem.l	d1-d7/a3,-(a2)		; clear 32 bytes
	movem.l	d1-d7/a3,-(a2)		; clear 32 bytes
	movem.l	d1-d7/a3,-(a2)		; clear 32 bytes
	movem.l	d1-d7/a3,-(a2)		; clear 32 bytes
	movem.l	d1-d7/a3,-(a2)		; clear 32 bytes
	movem.l	d1-d7/a3,-(a2)		; clear 32 bytes
	movem.l	d1-d7/a3,-(a2)		; clear 32 bytes
	movem.l	d1-d7/a3,-(a2)		; clear 32 bytes
	subq.l	#1,d0			; decrement count
	bne.s	clr2			; while (d0) clear some more...

clr3:	cmp.l	a0,a1			; while (a0 != a1)
	beq.s	clr4			; (done)
	move.b	d1,(a0)+		; clear a byte
	bra.s	clr3

clr4:	movem.l	(sp)+,d3-d7/a3		; restore registers
	rts
