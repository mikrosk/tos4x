* dos.s

*------------------------------------------------------------------------
*									:
*	Install GEMDOS under GEMDOS					:
*	(C)1986 Atari Corp.						:
*									:
*----									:
* 23-Dec-1987 akp	Changed _setup to _osi to match the extern	:
*			that BIOS startup.s calls.			:
* 29-Jan-1986 lmd	Hacked it up.					:
* 18-Sep-1987 lmd	Removed 'debugger' setup junk			:
*									:
*------------------------------------------------------------------------

_membot		= $432
_memtop		= $436
_sysbase	= $4f2

* exports:
	.globl	_GSX_ENTRY		; VDI entry point
	.globl	_bufl			; buffer list headers

* imports:
	.globl	_root			; _root (to make foldr100 happy)
	.globl	_announce		; announce our presence
	.globl	_osi			; C code to do hard stuff (setup.c)
	.globl	_sinit			; initialize resident stub

*+
*  Setup GEMDOS enviroment,
*  start it up,
*  exec COMMAND.PRG on root of C:
*
*-
	move.l	4(sp),basepg		; save ptr to basepage

	clr.l	-(sp)			; Super(NULL)
	move.w	#$20,-(sp)
	trap	#1
	addq	#6,sp
	move.l	d0,oldssp

	move.l	basepg,-(sp)
	bsr	_sinit			; init the stub
	addq	#4,sp
	move.l	oldssp,sp		; use same stack we started with

	moveq	#-1,d0			; get VDI entry point
	trap	#2
	move.l	d0,vdi
	move.l	#_rte,$88		; clobber old trap 2 vector

	move.l	basepg,a0		; compute memory limits: 
	move.l	$18(a0),a1		; a1 = BSS base
	add.l	$1c(a0),a1		;	+ BSS size
	move.l	a1,_membot		; _membot -> base of new TPA
	move.l	4(a0),_memtop		; _memtop -> top of new TPA

	jsr	_osi			; setup sector buffers, init GEMDOS

***  The _root pointer is only present
***  in systems generated on or after 10-Feb-1987
***  DOSDATE = %YYYYYYYMMMMDDDDD
***		0000111001001010

	;**** set _root address in system info block to new address ****
	move.l	_sysbase,a0
	cmp.l	#%0000111001001010,$1e(a0)	; after this date?
	bcs.s	.noroot				; no, don't fuck with it.
	move.l	#_root,$20(a0)

.noroot:
	bsr	_announce		; say we're here

again:	pea	nullenv(pc)		; null env
	pea	nullenv(pc)		; null tail
	pea	command(pc)		; path
	clr.w	-(sp)			; mode = exec
	move.w	#$4b,-(sp)
	trap	#1

	pea	alldone(pc)
	move.w	#9,-(sp)
	trap	#1
	addq	#6,sp

ahem:
	pea	hitreturn(pc)
	move.w	#9,-(sp)
	trap	#1
	addq	#6,sp

	move.w	#2,-(sp)		; get char from console
	move.w	#2,-(sp)
	trap	#13
	addq	#4,sp
	cmp.b	#13,d0			; is it RETURN?
	bne	ahem			; (ahem -- no -- try again)

	bra	again


alldone:	dc.b	13,10
		dc.b	'*** Root Process Terminated ***',13,10
		dc.b	0
hitreturn:	dc.b	'Hit [RETURN] to re-exec C:\\COMMAND.PRG',13,10
		dc.b	0

command:	dc.b	'C:\\COMMAND.PRG',0
nullenv:	dc.b	0,0,0,0
    even


*+
*  Jump to VDI entry point.
*
*-
_GSX_ENTRY:
	move.l	vdi,-(sp)		; "jump" to VDI
	rts

_rte:	rte				; random RTE

    bss
basepg:		ds.l	1		; -> original basepage
oldssp:		ds.l	1		; = original supervisor stack
vdi:		ds.l	1		; -> VDI entry point
