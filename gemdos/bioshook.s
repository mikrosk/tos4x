***************************     BIOSHOOK.S      ****************************
*
* $Revision: $	$Source: $
* =======================================================================
* $Author: $ 	$Date: $    $Locker: $
* =======================================================================
*
* $Log: $
****************************************************************************

* 
* This file contains hooks for using BIOS calls in a multi-tasking
* environment. GEMDOS and the BIOS are protected by a single
* mutual-exclusion semaphore. When any process is in either place, no other
* process can get in.  Naturally, when a process is in GEMDOS, it is
* allowed to make BIOS calls.  Thus, the GEMDOS/BIOS semaphore is an
* "owner" pointer, and that process may get in as often as it likes.  It's
* also got a counter; entering either BIOS or GEMDOS increments it, leaving
* decrements it, so you know when it drops to zero.
*
* This code creates a stack frame for the process to return through.
* That's OK for BIOS, which always returns directly to its caller.
* GEMDOS and AES don't always return to their callers right away.
*

.include "switches.s"

.globl _block
.globl _run

_longframe	equ	$59e

_newxbios:
	move.l	oldxbios,a2		; a2 holds vector to call
	bra	enter_bios

_newbios:
	move.l	oldbios,a2		; a2 holds vector to call

enter_bios:
	move.l	_run,a0			; get basepage address
	tst.w	bioscount
	beq	new_entry		; no process now in BIOS
	move.l	biosown,d1
	cmp.l	a0,d1
	beq	another_entry		; this process already owns BIOS 

* This guy needs to block waiting for access to BIOS.  When the processes
* blocked on this event wake up, they all try again; one will succeed, the
* others will block again.

	move.l	#BLK_BIOS,-(sp)
	jsr	_block
	bra	_newbios

new_entry:
	move.l	a0,biosown
	clr.w	bioscount

* You get here when this guy already owns BIOS; let him in.

another_entry:
	addq.w	#1,bioscount

* create a stack frame for the BIOS call to return through

	tst.w	longframe.w
	beq	notlong
	clr.w	-(sp)
notlong:
	pea	bios_ret(PC)
	move.w	sr,-(sp)
	jmp	(a2)			; jump to old BIOS vector

* BIOS calls return through here

bios_ret:
	subq.w	#1,bioscount
	rte				; return to original stack frame

.bss
oldxbios:	ds.l	1
oldbios:	ds.l	1
bioscount:	ds.w	1
