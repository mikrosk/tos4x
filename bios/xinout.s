******************* Revision Control System *****************************
*
* $Author: lozben $
* =======================================================================
*
* $Date: 87/11/20 14:24:52 $
* =======================================================================
*
* $Locker:  $
* =======================================================================
*
* $Log: xinout.s,v $
* Revision 1.1  87/11/20  14:24:52  lozben
* Initial revision
*
*
* =======================================================================
*
* $Revision: 1.1 $
* =======================================================================
*
* $Source: d:/tos/bios\RCS\xinout.s,v $
* =======================================================================
*
*************************************************************************
*+
*  Hack _prtblk()'s character-output bindings
*  so they go through some vectors.
*
*  Did you scream "hack"?
*
*-

* imports:
	.globl	prv_lsto		; LST: out_status() and out()
	.globl	prv_lst
	.globl	prv_auxo		; AUX: out_status() and out()
	.globl	prv_aux

* exports:
	.globl	_plstostat
	.globl	_plstout
	.globl	_pauxostat
	.globl	_pauxout


_plstostat:
	movem.l	d3-d7/a3-a6,-(sp)
	clr.l	a5			; quick zeropage
	move.l	prv_lsto(a5),a0
	jsr	(a0)
	movem.l	(sp)+,d3-d7/a3-a6
	rts


_plstout:
	move.w	6(sp),d0
	movem.l	d3-d7/a3-a6,-(sp)
	move.w	d0,-(sp)
	move.w	d0,-(sp)
	clr.l	a5			; quick zeropage
	move.l	prv_lst(a5),a0
	jsr	(a0)
	addq	#4,sp
	movem.l	(sp)+,d3-d7/a3-a6
	rts


_pauxostat:
	movem.l	d3-d7/a3-a6,-(sp)
	clr.l	a5			; quick zeropage
	move.l	prv_auxo(a5),a0
	jsr	(a0)
	movem.l	(sp)+,d3-d7/a3-a6
	rts


_pauxout:
	move.w	6(sp),d0
	movem.l	d3-d7/a3-a6,-(sp)
	move.w	d0,-(sp)
	move.w	d0,-(sp)
	clr.l	a5			; quick zeropage
	move.l	prv_aux(a5),a0
	jsr	(a0)
	addq	#4,sp
	movem.l	(sp)+,d3-d7/a3-a6
	rts
