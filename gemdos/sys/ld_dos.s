* ld_dos.s

*------------------------------------------------------------------------
*									:
*	Install GEMDOS under GEMDOS					:
*	(C)1986 Atari Corp.						:
*									:
*----									:
* 02-Feb-1987 akp	Added bootmunge handler for warm boots, and	:
*			removed clearing of memvalid (which forced cold	:
*			boots).						:
* 23-Dec-1987 akp	Changed _setup to _osi to match the extern	:
*			that BIOS startup.s calls.			:
* 05-Oct-1987 akp	Copied this from dos.s to ld_dos.s, caused it	:
*			to rts rather than execute command.tos		:
* 18-Sep-1987 lmd	Removed 'debugger' setup junk			:
* 29-Jan-1986 lmd	Hacked it up.					:
*									:
*------------------------------------------------------------------------

* exports:
	.globl	_GSX_ENTRY		; VDI entry point
	.globl	_bufl			; buffer list headers
	.globl	_bootdev
	.globl	_dbexists
	.globl	_diskbuf		; 1K disk buffer normally exported
*					; by VDI
	.globl	_longframe

* imports:
	.globl	_announce		; announce our presence
	.globl	_stopm			; msg to send when calling debug
	.globl	_osi			; C code to do hard stuff (setup.c)
	.globl	_sinit			; initialize resident stub
	.globl	_root
	.globl	_run
	.globl	mybp			; this is just before XBRA in rwa

* These are for export to setup.c and everybody else who uses them. They're
* actually defined in startup.s as system variables.

resvalid	= $426
resvector	= $42a
_membot		= $432
_memtop		= $436
_bootdev	= $446
_bufl		= $4b2
_sysbase	= $4f2
_longframe	= $59e

.bss
_diskbuf:	ds.b	1024

MSG_MSG	equ	$f000	; debugger message number for print-string

.text
*+
*  Setup GEMDOS enviroment,
*  start it up.
*
*-
	; cause resets to re-load boot sector from floppy.
	; see comments before bootmunge for more details.

	move.l	4(sp),basepg		; save ptr to basepage
	move.l	4(sp),mybp		; save it in XBRA struct too

	clr.b	_dbexists
	jsr	_announce		; announce our presence, get intent

	; on return from announce, d7 is TRUE if we should install the stub.
	; d6 is TRUE if we should then send an init message to the host.
	; If d7=0 and d6=1 it means "abort!" and don't install new GEMDOS.

	tst.w	d7			; init the stub?
	beq.s	.nostub			; no

	move.l	basepg,-(sp)
	jsr	_sinit
	addq	#4,sp
	st	_dbexists

	tst.w	d6			; cause a stop right away?
	beq.s	.nostub			; no...
	pea.l	_stopm			; yes: message text
	move.w	#MSG_MSG,-(sp)		; message type
	move.w	#$5,-(sp)		; SC_MSG
	move.w	#$b,-(sp)		; fn code 11
	trap	#14			; Xbios(11,SC_MSG,0x7f00,"text");
	add.w	#$a,sp
	bra	.stubdone

* get here when d7=0 (meaning don't install the stub); if d6=1 then
* don't even install this RAM GEMDOS!

.nostub:
	tst.w	d6
	bne	.noroot			; just rts, don't install

.stubdone:
	move.l	resvector,oresvector	; save old valid & vector
	move.l	resvalid,oresvalid
	move.l	#bootmunge,resvector	; set bailout vector
	move.l	#$31415926,resvalid	; set vaild word

	moveq	#-1,d0			; get VDI entry point
	trap	#2
	move.l	d0,vdi
	move.l	#_rte,$88		; clobber old trap 2 vector

	move.l	basepg,a0		; compute memory limits:
	move.l	$18(a0),a1		; a1 = BSS base
	add.l	$1c(a0),a1		; 	+ BSS size
	move.l	a1,_membot		; _membot -> base of new TPA
	move.l	4(a0),_memtop		; _memtop -> top of new TPA

	jsr	_osi			; setup sector buffers, init GEMDOS

;**** set _root and _run addresses in osheader to new address ****

; There is a problem here.  I don't know when it happened or why, but in
; ROM TOS, after running the AUTO folder, the sysbase pointer is reset to
; point at the ROM os header.  This can't really be right, since it means
; no AUTO-folder program can change the OS header.  Notably, WE can't. The
; fix?  Link in to trap 1, and on each call, check to see if the sysbase
; pointer has changed.  If it has, change it back and unlink. This is a bad
; fix, though.

	move.l	_sysbase,a0
	cmp.w	#%0000111001001010,$1e(a0)	; after this date?
	bcs.s	.noroot				; no, don't fool with it.
	move.l	#_root,$20(a0)			; yes, change OS header
						; to point to our root.
	move.l	#_run,$28(a0)			; change _run ptr, too
	move.l	a0,osysbase
	move.l	$84,otrap1
	move.l	#ntrap1,$84

.noroot:
	rts

ntrap1:
	move.l	osysbase,d0		; get sysbase value
	cmp.l	_sysbase,d0		; changed?
	beq	ntrap1_x		; no: link to old handler.
	move.l	osysbase,_sysbase	; yes: change it back
	move.l	otrap1,$84		; and unlink this code.
ntrap1_x:
	move.l	otrap1,a0		; JMP to old trap1 handler
	jmp	(a0)

*
* bootmunge: cause resets to re-load floppy boot sector even when
* the hard-disk is bootable.  (In the startup sequence (in rwabs.c),
* there is a check: if bootdev is >= 2, it doesn't check for bootability
* of the floppy.  Damn shame.
*
* Note that when this vector gets called, the return address is in
* a6; even the stack pointer is meaningless at this point.
*
*

bootmunge: 
	clr.w	_bootdev
	move.l	oresvalid,resvalid
	move.l	oresvector,resvector
	jmp	(a6)

*+
*  Jump to VDI entry point.
*
*-
_GSX_ENTRY:
	move.l	vdi,-(sp)		; "jump" to VDI
	rts

_rte:	rte				; random RTE

    .bss
osysbase:	ds.l	1
otrap1:		ds.l	1
oresvalid:	ds.l	1
oresvector:	ds.l	1
resvecsave:	ds.l	1		; -> original resvector (0 = none)
basepg:		ds.l	1		; -> original basepage
oldssp:		ds.l	1		; = original supervisor stack
vdi:		ds.l	1		; -> VDI entry point
_dbexists:	ds.b	1		; debugger exists flag
.even
