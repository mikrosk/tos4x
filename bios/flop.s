.super
******************* Revision Control System *****************************
*
* $Author: kbad $
* =======================================================================
*
* $Date: 1992/08/11 00:34:42 $
* =======================================================================
*
* $Locker:  $
* =======================================================================
*
* $Log: flop.s,v $
* Revision 2.41  1992/08/11  00:34:42  kbad
* TOS 4.00 Falcon030 first production version
*
* Revision 2.40  1992/07/27  20:12:04  kbad
* Nearly last Sparrow test BIOS
*
* Revision 2.39  1992/05/18  23:08:08  unknown
* Added USE_DISK_CHANGE to use that bit.  It's sparrow-only; TT has the bit
* in a different place, and besides, TT can have external floppies that don't
* supply this bit.  The consequence of USE_DISK_CHANGE is that the floppy
* vblank handler gets smaller and never selects a drive (thus no blink).
*
* Also, for Sparrow, the bit which was Drive One Select is no longer touched
* in this code; it's a no-connect for now, but somebody'll find a use for it.
*
* Revision 2.38  1992/02/28  08:25:02  apratt
* Changed TT to M68030 in some places, where it's really CPU dependency we're
* talking about.  This lets us build ROMs for Sparrow/030, which isn't a TT
* in any other way.
*
* Changed TT to (TT | SPARROW) for unconditional access to the denselect
* register.
*
* Added MAXACSI of 14MB for SPARROW.
*
* Revision 2.37  1992/02/12  01:32:28  apratt
* Added loops .if SPARROW to check the SDMA status bit.
*
* Revision 2.36  1991/11/06  21:27:32  apratt
* New code to check _iamanst and avoid hitting denselect if you are.
* This only works if writing denselect on (non-Mega) STe doesn't buserr.
*
* Revision 2.35  1991/10/21  19:03:30  apratt
* Fixed a comment: flopwr to sector 0 sets MC mode to "changed" not
* "unsure."  It always has, but this was commented and documented
* incorrectly for a long time.
*
* Revision 2.34  1991/10/15  14:12:08  apratt
* Changed to probe for FDC every time you call, not just at boot time.
* This is STPAD only, of course.  This way you can boot without a
* floppy attached and still attach one later.
*
* Revision 2.33  1991/10/03  17:53:24  apratt
* Added code for high-density selection on STPAD, which is different from
* other high-density select code.
*
* Revision 2.32  1991/09/12  19:41:34  apratt
* Changed conditionals: ! is bitwise in MAS, so !TT is $FFFFFFFE when TT is 1.
* So we use (TT == 0) instead.  Sigh.
*
* Revision 2.31  1991/09/06  14:49:02  apratt
* Removed a lot of comments and log messages.  Removed SLOWACSI
* conditional -- now we're always SLOWACSI.  Made the "nospindelay"
* field of the dsb truly conditional on HI_DEN.
*
* Changed all "ifne" to "if" and "ifeq" to "if !" and "endc" to "endif."
*
* Revision 2.30  91/08/15  15:31:18  apratt
* In STPAD, do a better "ram test" on the registers in the 1772 before
* deciding that it's there.  If you just write a value to one register, then
* read it back, it's possible you'll read what you wrote because of signal
* persistence, not because the 1772 is there.  So instead we write -1 to trkreg,
* 0 to secreg, then read them back in order.
* 
* 
* Revision 2.29  91/08/05  15:13:36  apratt
* Removed nospindelay global; now spin delay is the first byte of the field
* of the DSB. It has to be first because startup.s sets it for drive 0 when
* the high-density switch is thrown.  It gets ORed into the appropriate
* commands, so its value is the bit to set.  Floprate(drv,-2) sets, -3
* clears, and -4 probes the current setting of that bit.
* 
* Revision 2.28  91/06/13  16:27:09  apratt
* removed tmpdma -- left over from something, took up 4 bytes in BSS and four
* in ROM for a clr.b instruction.
* 
* 
* Revision 2.27  91/05/22  14:56:07  apratt
* Expanded comments about QD switch and TURNED IT OFF because
* it's just for debugging.
* 
* Revision 2.26  91/05/21  16:56:53  apratt
* Changed so the motor spin-up delay is disabled if the BIOS sets the
* nospindelay flag.  Startup.s sets this flag if the switch is thrown. Also
* increased the "absurd" sector count because 36 is not absurd for quad
* density.  QD is slightly implemented here, based on the assembly-time
* switch QD.
* 
* 
* Revision 2.25  91/04/26  17:44:01  apratt
* Added a drop-dead deselect timeout in Vblank after 5 seconds, motor-on or
* not.  This way empty drives do get turned off.
* 
* 
* Revision 2.24  91/04/24  17:23:15  apratt
* Added a new type of return from flopcmds, used only by go2track
* and hence by its callers:  if you return with carry set, it means
* the command timed out, and this usually means there's no disk in
* the drive.  In that case we go directly to flopfail, do not pass
* go, do not retry at the other density.  This works WONDERS for
* the "feel" of a system with no disk in the drive at boot time or
* any other time.
* 
* Revision 2.23  91/04/11  12:12:05  apratt
* Changed MAXACSI for TT to 10MB, not 4MB.  Should it be 10 for STe?
* 
* Revision 2.22  91/03/27  12:36:54  apratt
* Added a check for the dma chip and the 1772 if STPAD.  The missing-ACSI-chip
* test is only necessary for prototype PADs, and may go away soon.
* 
* Made fast-ram handling (actually non-ACSI-ram) happen for any machine.  
* 
* Revision 2.21  90/11/20  18:20:27  apratt
* Removed the one place that reads the denselect register: it's
* WRITE ONLY in Mega STE.  It's shadowed anyway in the DSB, so
* this is no hardship.
* 
* Revision 2.20  90/11/19  19:35:27  apratt
* Fixed a bug which has been here since day 1: on single-drive systems,
* Flopfmt and Flopwr to the boot sector set the state of disk A to "has
* changed" even if you formatted/wrote to disk B.
* 
* Documentation alert: the docs say writing to sector zero causes the flag
* to go to "maybe changed" but it actually goes to "has changed."
* 
* Revision 2.19  90/11/19  15:45:12  apratt
* Changed HI_DEN to be TT+STPLUS - it's available in Mega STe.
* Removed READFIFO, which was unused (was there for an old MCU).
* 
* Revision 2.18  90/08/21  17:26:50  apratt
* Mega STe version: made SLOWACSI true for STPLUS, too.
* 
* Revision 2.17  90/08/03  13:22:58  apratt
* TTOS FINAL RELEASE
* 
* =======================================================================
*
* $Revision: 2.41 $
* =======================================================================
*
* $Source: d:/tos/bios\rcs\flop.s,v $
* =======================================================================
*
*************************************************************************
*------------------------------------------------------------------------
*									:
*	Atari ST							:
*	Floppy Disk Driver						:
*	Copyright 1985, 1986 Atari Corp.				:
*									:
*------------------------------------------------------------------------

.text

* TT and SPARROW switches must be specified on the command line


* SPARROW and TT are both M68030.

M68030		equ	(SPARROW | TT)

*
* There is a new switch as of 5/92: USE_DISK_CHANGE means use the "disk
* changed" output from the drive to determine media change state. In this
* file that just DISABLES the old method, which involved polling the
* write-protect state of each drive.  In order to USE_DISK_CHANGE you have
* to assume that there is only one drive.  Thus it's there for SPARROW and
* FALCON but not TT, even though TT has a (different) disk-change line
* available for Drive A: (only).
*

*USE_DISK_CHANGE	equ SPARROW
USE_DISK_CHANGE	equ 0


*
* There used to be a switch called SLOWACSI which was used when you reset
* the ACSI chip: with it set, you write one of the values that accomplishes
* the reset, then delay for four external bus cycles, then write the other
* value, then delay again.  Now this is unconditional, because it doesn't
* hurt and it takes a compile-time conditional out of this file.
*

* QD switch enables some quad-density test code: as of 5/91 it turns off
* write precomp on HD and QD writes, and remaps the step rate to 12ms
* nominal in HD and QD mode (resulting in 6 or 3).  It's really just for
* test and shouldn't be used in general.

QD	equ	0

*************************************************************************
*									*
* There's a new feature here as of 4/24/91: in go2track we distinguish	*
* between  a missing disk and a disk you can't read by returning NE in	*
* both cases, but CS when the operation times out, and CC when the 1772	*
* returns some error The only caller of flopcmds which cares is		*
* go2track and it returns right away (preserving flags) when it sees	*
* CS. go2track's callers (which is everybody but flopfmt) bail out	*
* right away on CS.							*
*									*
* Old discussion of timeouts:  the 1772 returns record-not-found	*
* after 5 index pulses; we need need to have a longer timeout than	*
* that to differentiate it from the "no-index-pulses" error.  5 index	*
* pulses is one second, plus latency to the first pulse, plus ~1.5	*
* second motor startup if motor was off -- call it 1.5 sec for motor	*
* on, 3 sec for motor off.  (This was broken in TOS 1.6: it was too	*
* short, so you got timeout errors (meaning no index pulses, ergo no	*
* disk) rather than sector-not-found errors, which might be		*
* deliberate for copy protection.					*
*									*
*************************************************************************
*									*
* The 1772 can do a motor-spin-up delay if a command causes the motor	*
* to go from "off" to "on."  We normally do this, but our new		*
* standard HD drive, the Epson SMD-340 high-density drive, masks	*
* index pulses and the read line for .5 sec on its own: the 1772	*
* delay (which is index-pulse based) is not necessary and actually	*
* hurts disk performance (you wait 1.5 sec instead of .5 sec).  So we	*
* expect a flag (nospindelay) to have been set based on something	*
* (the "high-density" configuration switch) and test the flag at	*
* flopcmds: if nonzero, then inhibit the delay.	Since we seek with	*
* verify, the fact that the read-data line is masked means you can't	*
* get in trouble: you can't see a sector ID before the drive is up	*
* to speed.								*
*									*
*************************************************************************

HI_DEN		equ	1		; always enable this code

denselect	equ	$ffff860e	; density bits (WRITE ONLY)
					; (and don't touch at all if _iamanst)

*------ Tunable values (subject to tweaking):
retries		equ	2	; default # of retries - 1
midretry	equ	1	; "middle" retry (when to reseek)

timeout		equ	300	; short	timeout (motor already on) (1.5 sec)
ltimeout	equ	600	; long timeout (to startup motor) (3 sec)

tcdr		equ	$fffffa00+$23

*------ Exports:
	.globl _flopini			; init floppy			func
	.globl _floprd			; read sector			func
	.globl _flopvbl			; vertical blank monitor	func
	.globl _flopwr			; write sector			func
	.globl _flopfmt			; format drive/track		func
	.globl _flopver			; verify sectors		func
	.globl _floprate		; change seek rate for a drive	func

	.globl	_wpstatus		; write-protect state (2 drives)
	.globl	_wplatch		; write-protect latch (2 drives)
	.globl	_motoron		; motor-on status (1 byte, both drives)
	.globl	_acctim			; time (in video frames) of last access
	.globl	dsb0			; startup sets no-spin-delay flag

*------ Imports:
	.globl	flock			; floppy/FIFO lock variable
	.globl	_frclock		; vbl-frame-counter
	.globl	_nflops			; number of floppy drives attached
	.globl	_curflop		; currently inserted floppy
	.globl	_critic			; critical error handler
	.globl	seekrate		; default floppy seek rate
	.globl	_diskmode		; disk change mode
	.globl	_hz_200			; 200 hz timer ticker
	.globl	_iamanst		; byte: true if we're on an ST
.if M68030
	.globl	clrcache		; clear i & d caches on TT
.endif
.if TT
	.globl	ttwait
.endif

_p_cookie	equ	$5a0		; pointer to cookie jar


*------ media change modes:
m_changed	equ	2		; "CHANGED" media
m_unsure	equ	1		; "UNSURE" about media change


*------ Error returns
e_error		equ	-1		; general catchall
e_nready	equ	-2		; drive-not-ready
e_crc		equ	-4		; CRC error
e_seek		equ	-6		; seek error
e_rnf		equ	-8		; record (sector) not found
e_write		equ	-10		; generic write error
e_read		equ	-11		; generic read error
e_wp		equ	-13		; write on write-protected media
e_undev		equ	-15		; unknown device
e_badsects	equ	-16		; bad sectors on format-track
e_insert	equ	-17		; insert_a_disk 


*------ Floppy state variables in DSB:
recal		equ	$ff00		; recalibrate flag (in dcurtrack)

*------ Startup.s assumes that dspinflag is the first thing in this struct!

.if HI_DEN
dspinflag	equ	0		; spinup-delay flag (in hi byte)
dcurtrack	equ	2		; current track#
ddenflags	equ	4		; density flags (usu 0 or 3)
dseekrt		equ	6		; floppy's seek-rate
dsbsiz		equ	8		; (size of a DSB)
.else
dcurtrack	equ	0		; current track#
dseekrt		equ	dcurtrack+2	; floppy's seek-rate
dsbsiz		equ	dseekrt+2	; (size of a DSB)
.endif




*--- DMA chip:
diskctl		equ	$ffff8604	; disk controller data access
fifo		equ	$ffff8606	; DMA mode control / status
dmahigh		equ	$ffff8609	; DMA base high
dmamid		equ	$ffff860b	; DMA base medium
dmalow		equ	$ffff860d	; DMA base low

*--- 1770 select values:
cmdreg		equ	$80		; select command register
trkreg		equ	$82		; select track register
secreg		equ	$84		; select sector register
datareg		equ	$86		; select data register

*--- GI ("psg") sound chip:
giselect	equ	$ffff8800	; (W) sound chip register select
giread		equ	$ffff8800	; (R) sound chip read-data
giwrite		equ	$ffff8802	; (W) sound chip write-data
giporta		equ	$e		; GI register# for I/O port A

*--- 68901 ("mfp") sticky chip:
mfp	equ	$fffffa00		; mfp base
gpip	equ	mfp+1			; general purpose I/O






*+
*
* SYNOPSIS (synopsisi?):
*
* _flopini(dsb, 0L, devno)
* _floprd(dsb, buf, devno, sectno, trackno, sideno, count)
* _flopwr(dsb, buf, devno, sectno, trackno, sideno, count)
* _flopfmt(dsb, buf, devno, spt, trackno, sideno, interlv, magicno, virgin)
* _flopvbl()
* _flopver(dsb, buf, devno, sectno, trackno, sideno, count)
*
* An "EQ" return means success.  Zero is returned in D0.W.
* An "NE" return means failure.  Some negative error number is return in D0.W.
*
* Parameter types (in general):
*	LONG dsb, buf;
*	WORD devno, sectno, trackno, count;
*	WORD spt, interlv, virgin;
*	LONG magicno;
*
*-


*+
* flopini - initialize floppies
* Passed (on the stack):
*	 $c(sp) devno
*	 $8(sp) ->DSB
*	 $4(sp)	->buffer (unused)
*	 $0(sp)	return address
*
* Returns:	EQ if initialization succeeded (drive attached).
*		NE if initialization failed (no drive attached).
*
* This call didn't save any regs before! Now it saves the Alcyon C regs.
* (Feb '91)
*-
_flopini:
	clr.l	_frb			; zero this out until needed
	lea	dsb0,a1			; get ptr to correct DSB
	tst.w	$c(sp)
	beq	fi_1
	lea	dsb1,a1

fi_1:	move.w	seekrate,dseekrt(a1)	; setup default seek rate
.if HI_DEN
	move.w	#3,ddenflags(a1)	; and default density (high)
.endif
	moveq	#e_error,d0		; (default error)
	clr.w	dcurtrack(a1)		; fake clean drive
	clr.w	fastcnt			; this has to go here somewhere!

	move.w	#recal,dcurtrack(a1)	; default = recal drive (it's dirty)

.if STPAD
	bsr	fdcprobe
	beq	init_noflops		; done initializing if no floppies
.endc

	bsr	floplock		; setup parameters
	bsr	select			; select drive and side

	bsr	restore			; attempt restore
	beq	fi_ok			; (quick exit if that won)
	moveq	#10,d7			; attempt seek to track 10
	bsr	hseek1			; (hard seek to 'd7')
	bne	fi_nok			; (failed: drive unusable)
	bsr	restore			; attempt restore after seek
fi_ok:	beq	flopok			; return OK (on win)
fi_nok:	bra	flopfail		; return failure

.if STPAD

*
* init_noflops: this is where we go when we detect that there really are no
* floppies attached to an STBOOK at init time.  Rwabs.c calls init twice,
* once for each physical floppy it probes for.  The first time, we tell it
* we succeeded; the second time, that we failed.  This results in _nflops
* getting set to 1, so you can attach one external floppy (but not two) if
* you boot with none.
*

init_noflops:
	move.w	#$0202,_diskmode	; make both appear "changed."
	moveq.l	#0,d0			; return "success" to rwabs.c,
	tst.w	_nflops.w		; if this is the first time through
	beq	i1
	moveq.l	#e_undev,d0		; else return failure.
i1:	rts
	
*
* entry point for read, write, format, and verify to call when there are
* NO floppies.  This is before regs were saved or anything else.
*

noflop1:
	moveq	#e_nready,d0
	rts

*
* Probe for a floppy disk controller.  We no longer probe to see if there's
* a DMA chip -- we assume it's there, or at any rate that it won't bus
* error.
*
* This routine doesn't change any registers -- it saves and restores
* what it uses.  This includes the FDC registers it probes with.
*

fdcprobe:
	addq.w	#1,flock.w		; say we're busy now
	movem.l	d0-d7/a6,-(sp)
	lea	fifo,a6

	move.w	#trkreg,(a6)
	moveq.l	#0,d7
	bsr	wdiskctl		; write a zero to trkreg
	move.w	#secreg,(a6)
	moveq.l	#-1,d7
	bsr	wdiskctl		; write $FF to secreg
	move.w	#trkreg,(a6)
	bsr	rdiskctl		; read it back
	move.b	d0,d1			; save it for a little bit
	bne	noflop			; nope - no floppies
	move.w	#secreg,(a6)
	bsr	rdiskctl		; read secreg back
	subq.w	#1,flock.w		; un-lock the bus
	tst.b	d1			; was trkreg still 00?
	bne	noflop			; no - no floppies
	cmp.b	#$ff,d0			; still $ff?
					; (leave ccr set)
noflop:
	movem.l	(sp)+,d0-d7/a6		; restore changed regs
					; (doesn't affect ccr)
	eor.w	#4,sr			; flip Z bit
	rts				; EQ means no floppies
.endif

*+
* floprd - read	sector from floppy
* Passed (on the stack):
*	$14(sp) count
*	$12(sp) sideno
*	$10(sp) trackno
*	 $e(sp) sectno
*	 $c(sp) devno
*	 $8(sp)	->DSB
*	 $4(sp) ->buffer
*	 $0(sp)	return address
*
* Returns:	EQ, the read won (on all sectors),
*		NE, the read failed (on some sector).
*-
_floprd:
.if STPAD
	bsr	fdcprobe
	beq	noflop1			; no floppies!
.endif

	bsr	change			; test for disk change
	moveq	#e_read,d0		; set default error#
	bsr	rdfast
	bsr	floplock		; lock floppies, setup parameters
frd1:	bsr	select			; select drive,	setup registers
	bsr	go2track		; seek appropriate track
	bcs	flopfail		; EMPTY DRIVE - FAIL NOW
	bne	frde			; retry on seek failure

frd1a:	move.w	#e_error,curr_err	; set general error#

; reset ACSI chip (see notes)
	move.w	#$190,(a6)
	tst.b	gpip
	tst.b	gpip
	tst.b	gpip
	tst.b	gpip
	move.w	#$090,(a6)
	tst.b	gpip
	tst.b	gpip
	tst.b	gpip
	tst.b	gpip

* why does this write to diskctl not use wdiskctl? Because it's actually
* writing to the DMA chip, not the 1770.
	move.w	#1,diskctl		; set sector count register

	move.w	#$080,(a6)		; startup 1770 "read sector" command
	move.w	#$80,d7
	bsr	wdiskctl

	move.l	_hz_200.w,d7
	add.l	#timeout,d7		; d7 = _hz_200 value to die at

*--- Wait for read completion:
frd2:	btst.b	#5,gpip			; 1770 done yet?
	beq	frd4			; (yes)
	cmp.l	_hz_200.w,d7
	bhi	frd2			; (not timed-out yet)
	move.w	#e_nready,curr_err.w	; set "timeout" error
	bsr	reset1770		; (clobber 1770)
	bra	frde			; (go retry)

*--- check status after read
frd4:	move.w	#$090,(a6)		; examine DMA status register
	move.w	(a6),d0
	btst	#0,d0			; bit zero indicates DMA error
	beq	frde			; (when	its zero -- retry)

	move.w	#$080,(a6)		; examine 1770 status register
	bsr	rdiskctl
	and.b	#$1c,d0			; check	for RNF, checksum, lost-data
	bne	frde1			; (error)

	move.w	#retries,retrycnt.w	; setup retry count
	addq.w	#1,csect.w		; bump sector number
	add.l	#$200,cdma.w		; and DMA pointer for next sector
	subq.w	#1,ccount.w		; if(!--count) return OK;
	beq	flopok
	bsr	select1			; setup sector#, DMA pointer
	bra	frd1a			; read next (no seek)

frde1:	bsr	err_bits		; set error# from 1770 bits
frde:	cmp.w	#midretry,retrycnt.w	; are we on the	"middlemost" retry?
	bne	frd5
	bsr	reseek			; yes, home and	reseek the head
frd5:	subq.w	#1,retrycnt.w		; drop retry count
	bpl	frd1			; (continue if any retries left)
	bra	flopfail		; fail when we run out of patience


*+
* err_bits - set "curr_err" according to 1770 error status
* Passed:	d0 = 1770 status
*
* Returns:	curr_err, containing current error number
*
* Uses:		d1
*-
err_bits:
	moveq	#e_wp,d1		; write protect?
	btst	#6,d0
	bne	eb1

	moveq	#e_rnf,d1		; record-not-found?
	btst	#4,d0
	bne	eb1

	moveq	#e_crc,d1		; CRC error?
	btst	#3,d0
	bne	eb1
	move	def_error.w,d1		; use default error#
eb1:	move.w	d1,curr_err.w		; set current error number & return
	rts


*+
* flopwr - write sector	to floppy
* Passed (on the stack):
*	$14(sp) count
*	$12(sp) sideno
*	$10(sp) trackno
*	 $e(sp) sectno
*	 $c(sp) devno
*	 $8(sp)	->DSB
*	 $4(sp) ->buffer (unused)
*	 $0(sp)	return address
*
* Returns:	EQ, the write won (on all sectors),
*		NE, the write failed (on some sector).
*-
_flopwr:
.if STPAD
	bsr	fdcprobe
	beq	noflop1			; no floppies!
.endif

	bsr	change			; check for disk swap
	moveq	#e_write,d0		; set default error number
	bsr	wrfast
	bsr	floplock		; lock floppies

*+
* If the boot sector is written to,
* set the media change mode to "changed".
* (Kludge, kludge, kludge....)
*-
	move.w	csect.w,d0		; sector 1
	subq	#1,d0
	or.w	ctrack.w,d0		; track 0
	or.w	cside.w,d0		; side 0
	bne	fwr1			; if not boot sector, then OK
	moveq	#m_changed,d0		; set media change mode to unsure
	bsr	setdmode		; (boy, is this /ugly/)

fwr1:	bsr	select			; select drive
	bsr	go2track		; seek
	bcs	flopfail		; EMPTY DRIVE - FAIL NOW
	bne	fwre1			; (retry on seek failure)
fwr1a:	move.w	#e_error,curr_err.w	; set general error#

; reset ACSI chip (see notes)
	move.w	#$090,(a6)
	tst.b	gpip
	tst.b	gpip
	tst.b	gpip
	tst.b	gpip
	move.w	#$190,(a6)		; leave	in WRITE mode
	tst.b	gpip
	tst.b	gpip
	tst.b	gpip
	tst.b	gpip

	move.w	#1,d7			; load sector count register
	bsr	wdiskctl
.if SPARROW
spwait1:
	btst.b	#3,denselect+1		; test DMA status
	bne	spwait1			; delay while it's nonzero.
.endif

	move.w	#$180,(a6)		; load "WRITE SECTOR" command
	move.w	#$a0,d7			; into 1770 cmdreg

.if QD
*
* QD is only slightly implemented here.  We disable write precompensation
* if you're at high density at all.  This is not really what we should
* do, but it is here for testing.
*
	tst.w	dseekrt(a1)
	beq	noqd0
	or.w	#%10,d7			; OR in disable of write precomp
noqd0:
.endif

	bsr	wdiskctl
	move.l	_hz_200.w,d7
	add.l	#timeout,d7		; d7 = _hz_200 value to die at

fwr2:	btst.b	#5,gpip			; done yet?
	beq	fwr4			; (yes,	check status)
	cmp.l	_hz_200.w,d7
	bhi	fwr2			; (still tickin')
	bsr	reset1770		; timed	out -- reset 1770
	bra	fwre			; and retry

fwr4:	move.w	#$180,(a6)		; get 1770 status
	bsr	rdiskctl
	bsr	err_bits		; compute 1770 error bits
	btst	#6,d0			; if write protected, don't retry
	bne	flopfail		; (can't write, so punt)
	and.b	#$5c,d0			; check	WriteProt+RecNtFnd+CHKSUM+LostD
	bne	fwre			; retry on error

	move.w	#retries,retrycnt.w	; setup retry count
	addq.w	#1,csect.w		; bump sector number
	add.l	#$200,cdma.w		; and DMA pointer for next sector
	subq.w	#1,ccount.w		; if(!--count) return OK;
	beq	flopok
	bsr	select1			; setup sector#, DMA pointer
	bra	fwr1a			; write next (no seek)

fwre:	cmp.w	#midretry,retrycnt.w	; re-seek head in "middle" retry
	bne	fwr5			; (not middle retry)
fwre1:	bsr	reseek			; home head and	seek
fwr5:	subq.w	#1,retrycnt.w		; decrement retry count
	bpl	fwr1			; loop if there's still	hope
	bra	flopfail		; otherwise return error status

*+
* _flopfmt - format a track
* Passed (on the stack):
*	$1a(sp)	initial sector data
*	$16(sp)	magic number
*	$14(sp)	interleave		;* if -1 then skew sectors use table
*	$12(sp)	side
*	$10(sp)	track
*	 $e(sp)	spt
*	 $c(sp)	drive
*	 $8(sp)	NOT USED		;* skew table if interleave -1
*	 $4(sp)	dma address
*	 $0(sp)	[return]
*
* Returns:	EQ: track successfully written.  Zero.W-terminated list of
*		bad sectors left in buffer (they might /all/ be bad.)
*
*		NE: could not write track (write-protected, drive failure,
*		or something catastrophic happened).
*
* Note: if the number of sectors is less than 13, assume low density;
* else assume high density.  (Don't know of a drive or controller
* that can handle 12 sectors, but what the heck.)
*-

_flopfmt:
	cmp.l	#$87654321,$16(sp)	; check for magic# on stack
	bne	flopfail		; no magic, so we just saved the world
.if STPAD
	bsr	fdcprobe
	beq	noflop1			; no floppies!
.endif

	bsr	change			; check for disk flip
	moveq	#e_error,d0		; set default error number
	bsr	fmfast
	bsr	floplock		; lock floppies, setup parms
	bsr	select			; select drive and side
	move.w	$e(sp),spt.w		; save sectors-per-track
	move.w	$14(sp),interlv.w	; save interleave factor
	move.w	$1a(sp),virgin.w	; save initial sector data
	move.l	$8(sp),skewtbl.w	; save skew table pointer

*--- put drive into "changed" mode
	moveq	#m_changed,d0		; d0 = "CHANGED"
	bsr	setdmode		; set media change mode

.if HI_DEN
*--- set the density controller bits to the appropriate value
* Set this before calling seek, because it influences the seek-rate
* parameter written to the controller.

	moveq	#$3,d0			; assume hi den first
	cmp.w	#13,spt.w
	bhs	denok
	moveq	#$0,d0			; no, is low
denok:
.if STPAD
	bsr	do_hiden
.else	
.if (TT | SPARROW)
	move.w	d0,denselect
.else
	tst.b	_iamanst
	bne	noden1
	move.w	d0,denselect
noden1:
.endif
.endif
	move.w	d0,ddenflags(a1)
.endif

*--- seek to track (hard seek):
	bsr	hseek			; hard seek to 'ctrack'
	bne	flopfail		; (return error on seek failure)
	move.w	ctrack.w,dcurtrack(a1)	; record current track#

*--- format track, then verify it:
	move.w	#e_error,curr_err.w	; vanilla error mode
	bsr	fmtrack			; format track
	bne	flopfail		; (return error on seek failure)
	move.w	spt.w,ccount.w		; set number of sectors to verify
	move.w	#1,csect.w		; starting sector# = 1
	bsr	verify1			; verify sectors

*--- if there are any bad sectors, return /that/ error...
	move.l	cdma.w,a2		; a2 -> bad sector list
	tst.w	(a2)			; any bad sectors?
	beq	flopok			; no -- return OK
	move.w	#e_badsects,curr_err.w	; set error number
	bra	flopfail		; return error


*+
* fmtrack - format a track
* Passed:	variables setup by _flopfmt
* Returns:	NE on failure, EQ on success
* Uses:		almost everything
* Called-by:	_flopfmt
*
*-
fmtrack:
	move.w	#e_write,def_error.w	; set default error number
	move.l	cdma.w,a2		; a2 ->	prototyping area
	move.l	skewtbl.w,a3		; a3 -> skewtbl (if nesssary!)

* lines below added by AKP 3/88 for Intel 82072 compatibility
* then backed out 6/88 because 10-sector formats stopped working.
*
*	move.w	#80-1,d1		; 80 x $4e as GAP 4a
*	move.w	#$4e,d0
*	bsr	wmult
*
*	move.w	#12-1,d1		; 12 x $00 as sync
*	clr.w	d0
*	bsr	wmult
*
*	move.b	#$f6,d0			; 3 x $C2 as IAM preamble
*	move.b	d0,(a2)+
*	move.b	d0,(a2)+
*	move.b	d0,(a2)+
*
*	move.b	#$fc,(a2)+		; 1 x $fc as IAM
*
* end of lines added by AKP for 82072 compatibility

.if QD
	move.w	#240-1,d1		; 4x low-den track leadin
	cmp.w	#26,spt.w
	bhs	d1ok
.endif

	moveq	#120-1,d1		; 2x low-den track leadin
	cmp.w	#13,spt.w
	bhs	d1ok
	moveq	#60-1,d1		; use recommended track-leadin size
d1ok:
	moveq	#$4e,d0
	bsr	wmult

	clr.w	d3			; init for uses with skew table
	tst.w	interlv.w		; if NEG
	bmi	use_skewtbl		; use skew table

	moveq	#1,d3			; start	with sector 1, first pass

*--- address mark
ot3:	move.w	d3,d4			; d4 = starting	sector (this pass)
ot1:	moveq	#12-1,d1		; 12 x $00
	clr.b	d0
	bsr	wmult
	moveq	#3-1,d1			; 3 x $f5
	moveq	#$fffffff5,d0		; (really just $f5; mas complains)
	bsr	wmult
	move.b	#$fe,(a2)+		; $fe -- address mark intro
	move.b	ctrack+1.w,(a2)+	; track#
	move.b	cside+1.w,(a2)+		; side#
	move.b	d4,(a2)+		; sector#
	move.b	#$02,(a2)+		; sector size (512)
	move.b	#$f7,(a2)+		; write	checksum

*--- gap between AM and data:
	moveq	#22-1,d1		; 22 x $4e
	moveq	#$4e,d0
	bsr	wmult
	moveq	#12-1,d1		; 12 x $00
	clr.b	d0
	bsr	wmult
	moveq	#3-1,d1			; 3 x $f5
	moveq	#$fffffff5,d0		; (really just $f5; mas complains)
	bsr	wmult

*--- data block:
	move.b	#$fb,(a2)+		; $fb -- data intro
	move.w	#256-1,d1		; 256 x virgin.W (initial sector data)
ot2:	move.b	virgin.w,(a2)+		; copy high byte
	move.b	virgin+1.w,(a2)+	; copy low byte
	dbra	d1,ot2			; fill 512 bytes
	move.b	#$f7,(a2)+		; $f7 -- write checksum
	moveq	#40-1,d1		; 40 x $4e
	moveq	#$4e,d0
	bsr	wmult


	tst.w	interlv.w		; if interlv is NEG use skew table
	bmi	use_skewtbl		; 

	add.w	interlv.w,d4		; bump sector#
	cmp.w	spt.w,d4		; if(d4	<= spt)	then_continue;
	ble	ot1			; proto	more sectors this pass
	add.w	#1,d3			; bump pass start count
	cmp.w	interlv.w,d3		; if(d3	<= interlv) then_continue;
	ble	ot3

* end-of-track: write 4e into the buffer a lot (1400 in regular density,
* 2800 in high density.

end_track:
.if QD
	move.w	#5600,d1		; quad-density value
	cmp.w	#26,spt.w
	bhs	etok
.endif

	move.w	#2800,d1		; high-density value
	cmp.w	#13,spt.w
	bhs	etok
	move.w	#1400,d1		; low-density value
etok:
	moveq	#$4e,d0			; end-of-track trailer
	bsr	wmult

*--- setup to write the track:
	move.b	cdma+3.w,dmalow		; load dma pointer
	move.b	cdma+2.w,dmamid
	move.b	cdma+1.w,dmahigh

; reset ACSI chip (see notes)
	move.w	#$090,(a6)		; select sector-count register
	tst.b	gpip
	tst.b	gpip
	tst.b	gpip
	tst.b	gpip
	move.w	#$190,(a6)
	tst.b	gpip
	tst.b	gpip
	tst.b	gpip
	tst.b	gpip

	moveq	#$60,d7			; (absurd sector count)
	bsr	wdiskctl
.if SPARROW
spwait2:
	btst.b	#3,denselect+1
	bne	spwait2
.endif
	move.w	#$180,(a6)		; select 1770 cmd register

	move.w	#$f0,d7			; write	format_track command

.if QD
*
* QD is only slightly implemented here: the clock selection must be done
* externally, but internally you have to disable write precompensation.
* So here it is.  Also in the normal write call.
*
	cmp.w	#26,spt.w		; QD?
	ble	noqd1
	or.w	#%10,d7			; disable write precomp for QD	
noqd1:
.endif

	bsr	wdiskctl
	move.l	_hz_200.w,d7
	add.l	#timeout,d7		; d7 = _hz_200 value to die at

*--- wait for 1770 to complete
otw1:	btst.b	#5,gpip			; is 1770 done?
	beq	otw2			; (yes)
	cmp.l	_hz_200.w,d7
	bhi	otw1			; (still tickin')
	bsr	reset1770		; timed	out -- reset 1770
oterr:	moveq	#1,d7			; return NE (error status)
	rts

*--- use skew table passed in to us
use_skewtbl:
	cmp.w	spt.w,d3		; are we through all tracks
	beq	end_track		; this way out

	move.w	d3,d6
	add.w	d6,d6			; work index
	move.w	(a3,d6.w),d4		; d4 = a skew table entry
	addq.w	#1,d3			; inc skew table index in this case
	bra	ot1			; write next track to buffer

*--- see if the write-track won:
otw2:	move.w	#$190,(a6)		; check	DMA status bit
	move.w	(a6),d0
	btst	#0,d0			; if its zero, there was a DMA error
	beq	oterr			; (so return NE)
	move.w	#$180,(a6)		; get 1770 status
	bsr	rdiskctl
	bsr	err_bits		; set 1770 error bits
	and.b	#$44,d0			; check	for writeProtect & lostData
	rts				; return NE on 1770 error

*------ write 'D1+1' copies of D0.B into A2, A2+1, ...
wmult:	move.b	d0,(a2)+		; record byte in proto buffer
	dbra	d1,wmult		; (do it again)
	rts

*+
* _flopver - verify sectors on a track
*	$14(sp) count
*	$12(sp) sideno
*	$10(sp) trackno
*	 $e(sp) sectno
*	 $c(sp) devno
*	 $8(sp)	->DSB
*	 $4(sp) ->buffer (at least 1K long)
*	 $0(sp)	return address
*
* Returns:	NULL.W-terminated list of bad sectors in the buffer if D0 == 0,
*		OR some kind of error (D0 < 0).
*
*-
_flopver:
.if STPAD
	bsr	fdcprobe
	beq	noflop1			; no floppies!
.endif

	bsr	change			; hack disk change
	moveq	#e_read,d0		; set default error#
	bsr	vrfast
	bsr	floplock		; lock floppies, setup parameters
	bsr	select			; select floppy
	bsr	go2track		; go to track
	bne	flopfail		; (punt if that fails)
					; (incl. EMPTY DRIVE - FAIL NOW)

	bsr	verify1			; verify some sectors
	bra	flopok			; return "OK"


*+
* verify1 - verify sectors on a single track
* Passed:	csect = starting sector#
*		ccount = number of sectors to verify
*		cdma -> 1K buffer (at least)
*
* Returns:	NULL.W-terminated list of bad sectors (in the buffer)
*		(buffer+$200..buffer+$3ff used as DMA buffer)
*
* Enviroment:	Head seeked to the correct track;
*		Drive and side already selected;
*		Motor should be spinning (go2track and fmttrack do this).
*
* Uses:		Almost everything.
*
* Called-by:	_flopfmt, _flopver
*
*-
verify1:
	move.w	#e_read,def_error.w	; set default error number
	move.l	cdma.w,a2		; a2 -> start of bad sector list
	add.l	#$200,cdma.w		; bump buffer up 512 bytes

*--- setup for (next) sector
tvrlp:	move.w	#retries,retrycnt.w	; init sector-retry count
	move.w	#secreg,(a6)		; load 1770 sector register
	move.w	csect.w,d7		; with 'csect'
	bsr	wdiskctl

*--- setup for sector read
tvr1:	move.b	cdma+3.w,dmalow		; load dma pointer
	move.b	cdma+2.w,dmamid
	move.b	cdma+1.w,dmahigh
	move.w	#$190,(a6)

; reset ACSI chip (see notes)
	tst.b	gpip
	tst.b	gpip
	tst.b	gpip
	tst.b	gpip
	move.w	#$090,(a6)
	tst.b	gpip
	tst.b	gpip
	tst.b	gpip
	tst.b	gpip

	move.w	#1,d7			; set DMA sector count to 1
	bsr	wdiskctl

	move.w	#$080,(a6)		; load 1770 command register
	move.w	#$80,d7			; with ReadSector command
	bsr	wdiskctl
	move.l	_hz_200.w,d7
	add.l	#timeout,d7		; d7 = _hz_200 value to die at

*--- wait for command completion
tvr2:	btst.b	#5,gpip			; test for 1770	done
	beq	tvr4			; (yes,	it completed)
	cmp.l	_hz_200.w,d7
	bhi	tvr2			; (still counting down)
	bsr	reset1770		; reset	controller and return error
	bra	tvre

*--- got "done" interrupt, check DMA status:
tvr4:	move.w	#$090,(a6)		; read DMA error status
	move.w	(a6),d0
	btst	#0,d0			; if DMA_ERROR is zero,	then retry
	beq	tvre

* --- check 1770 completion status (see if it's happy):
	move.w	#$080,(a6)		; read 1770 status register
	bsr	rdiskctl
	bsr	err_bits		; set error# from 1770 register
	and.b	#$1c,d0			; check	for record-not-found, crc-err,
	bne	tvre			;	and lost data; return on error

*--- read next sector (or return if done)
tvr6:	addq.w	#1,csect.w		; bump sector count
	subq.w	#1,ccount.w		; while(--count) read_another;
	bne	tvrlp
	sub.l	#$200,cdma.w		; readjust DMA pointer
	clr.w	(a2)			; terminate bad sector list
	rts				; and return EQ

*--- read failure: retry or record bad sector
tvre:	cmp.w	#midretry,retrycnt.w	; re-seek head?
	bne	tvr5			; (no)
	bsr	reseek			; yes: back to home and	then back
tvr5:	subq.w	#1,retrycnt.w		;	to the current track...
	bpl	tvr1
	move.w	csect.w,(a2)+		; record bad sector
	bra	tvr6			; do next sector


*+
* _flopvbl - floppy vblank handler
* Deselects floppies after the motor stops.
*-
_flopvbl:
	lea	fifo,a6			; a6 -> fifo
	st.b	_motoron.w		; assume motor is on
	tst.w	flock.w			; floppies locked?
	bne	fvblr			; (yes,	so don't touch them)

.if STPAD
	bsr	fdcprobe
	beq	fvblr			; no floppies!
.endif

	move.l	_frclock.w,d0		; check a drive every 8 jiffies
	move.b	d0,d1			; (save jiffy count)
	and.b	#7,d1			; time yet?
	bne	fvblr			; (no)
	move.w	#cmdreg,(a6)		; select 1770 command/status register

.if (USE_DISK_CHANGE == 0)
*------ write-protect monitor:
*--- select drive, record its WP status:
	lsr.b	#3,d0			; use bit 4 as drive# to check
	and.w	#1,d0			; (keep only bit 0)
	lea	_wpstatus.w,a0		; a0 -> write-protect status table
	add.w	d0,a0			; a0 -> WP-status table entry

	cmp.w	_nflops.w,d0		; if(d0 == _nflops == 1)
	bne	fvbl2			;	d0 = 0;
	clr.w	d0
fvbl2:	addq.b	#1,d0			; turn into drive-select bits
	lsl.b	#1,d0			; (magic shift left)
	eor.b	#7,d0			; invert select bits, select side 0
	bsr	setporta		; set port A (d2 = old bits)
	bsr	rdiskctl		; get 1770 status
	move.w	d0,d1			; (into d1)
	btst	#6,d1			; test Write-Protect status bit
	sne.b	(a0)			; set WP status to $00 or $FF...
	move.b	d2,d0			; restore old drive-select bits
	bsr	setporta		; (uses d1!)

fvbl1:	move.w	_wpstatus.w,d0		; or _wpstatus into _wplatch
	or.w	d0,_wplatch.w		; (catch any WP transitions)
.endif

*------ floppy deselect test:
*
* Note: if dselflg is nonzero, then we know that one floppy is selected, so
* we don't need to go through the selection process.
*
	tst.w	deselflg.w		; floppies already deselected?
	bne	fvblr1			; (yes, so don't do it again)

* New test: if _hz_200 has deseltime or later, then delselect them.
* This removes us from dependence on the motor-on output of the 1772,
* which never goes away if there's no disk in the drive (on some drives).
* (New as of 4/24/91)

	move.l	_hz_200.w,d0		; get current time
	cmp.l	deseltime,d0		; is it at or past drop-dead time?
	bhs	dodesel			; yes, so drop dead.

	bsr	rdiskctl		; read 1770 status register

	btst	#7,d0			; is the motor still on?
	bne	fvblr			; (yes,	so don't deselect)
dodesel:
	move.b	#7,d0			; deselect both	drives
	bsr	setporta		; (set bits 0..3 in portA of PSG)
	move.w	#1,deselflg.w		; indicate floppies deselected
fvblr1:	clr.w	_motoron.w		; indicate motor is OFF
fvblr:	rts				; back to vbl



*+
* floplock - lock floppies and setup floppy parameters
*
* Passed (on the stack):
*	$18(sp) - count.W (sector count)
*	$16(sp) - side.W (side#)
*	$14(sp) - track.W (track#)
*	$12(sp) - sect.W (sector#)
*	$10(sp) - dev.W (device#)
*	 $c(sp) - obsolete.L
*	  8(sp) - dma.L (dma pointer)
*	  4(sp) - ret1.L (caller's return address)
*	  0(sp) - ret.L (floplock's return address)
*
* Passed:	D0.W = default error number
*-
floplock:
	movem.l	d3-d7/a3-a6,regsave	; save C registers

	lea	fifo,a6			; a6 -> fifo
	st	_motoron.w		; kludge motor state = ON
	move.w	d0,def_error.w		; set default error number
	move.w	d0,curr_err.w		; set current error number
	move.w	#1,flock.w		; tell vbl not to touch floppies
	move.l	8(sp),cdma.w		; cdma -> /even/ DMA address
	move.w	$10(sp),cdev.w		; save device# (0 .. 1)
	move.w	$12(sp),csect.w		; save sector# (1 .. 9,	usually)
	move.w	$14(sp),ctrack.w	; save track# (0 .. 39 .. 79 ..)
	move.w	$16(sp),cside.w		; save side# (0	.. 1)
	move.w	$18(sp),ccount.w	; save sector count (1..spt)
	move.w	#retries,retrycnt.w	; setup retry count

*--- pick a DSB:
	lea	dsb0.w,a1
	tst.w	cdev.w
	beq	flock2
	lea	dsb1.w,a1

*--- recalibrate drive (if it needs it)
flock2:	tst.w	dcurtrack(a1)		; if (curtrack < 0) recalibrate()
	bpl	flockr

	bsr	select			; select drive & side
	clr.w	dcurtrack(a1)		; we're optimistic -- assume winnage
	bsr	restore			; attempt restore
	beq	flockr			; (it won)
	moveq	#10,d7			; attempt seek to track 10
	bsr	hseek1
	bne	flock1			; (failed)
	bsr	restore			; attempt restore again
	beq	flockr			; (it won)
flock1:	move.w	#recal,dcurtrack(a1)	; complete failure (what can we do?)
flockr:	rts


*+
* flopfail - unlock floppies and return	error.
*
*-
flopfail:
	moveq	#m_unsure,d0		; disk change mode = UNSURE
	bsr	setdmode		; set media change mode
	move.w	curr_err.w,d0		; get current error number
	ext.l	d0			; extend to long
	bra	unlok1			; clobber floppy lock & return

*+
* flopok - unlock floppies and return success status:
*
*-
flopok:	clr.l	d0			; return 0 (success)
unlok1:	move.l	d0,-(sp)		; (save return value)
.if M68030
	bsr	clrcache		; clobber the cache (also trash d0)
.endif
	move.w	#datareg,(a6)		; force WP to real-time mode
	move.w	dcurtrack(a1),d7	; dest-track = current track
	bsr	wdiskctl
	move.w	#$10,d6			; cmd = seek w/o verify
	bsr	flopcmds		; do it (can't fail)

*
* _acctim (last floppy access time) is used by rwabs:mediach() for a grace
* period for media change.  Previously the 200Hz timer was used, but this
* could cause problems (esp. in game s/w) if the 200Hz timer is disabled. 
* Since floppy write protect status (used to set media state) is checked by
* the floppy vblank handler, we now use the frame clock (updated EVERY
* vblank) for _acctim.  890206 kbad
*
* In addition, the drop-dead time to deselect the drives regardless of
* motor-on is set here to be five seconds in the future.  Setting it once
* here at the end of an access is sufficient because the VBLANK routine
* which checks it can't run while flock is set, so it'll never deselect the
* drive during an access.
*

	move.l	_hz_200,d0		; get time
	add.l	#200*5,d0		; add five seconds
	move.l	d0,deseltime		; save

	move.w	cdev.w,d0		; set last-access time for 'cdev'
	lsl.w	#2,d0
	lea	_acctim.w,a0
	move.l	_frclock.w,(a0,d0.w)
	cmp.w	#1,_nflops.w		; if (nflops == 1) set other time, too
	bne	unlok2
	move.l	_frclock.w,4(a0)	; set last-accessed time for floppy 1

unlok2:	move.l	(sp)+,d0		; restore return value
	movem.l	regsave.w,d3-d7/a3-a6	; restore C registers
	clr.w	flock			; unlock floppies
	bsr	unfast			; do tail copy if necessary
	rts



*+
* hseek  - seek to 'ctrack' without verify
* hseek1 - seek to 'd7' without verify
* hseek2 - seek to 'd7' without verify, keep current error number
*
* Returns:	NE on seek failure ("cannot happen"?)
*		EQ if seek wins
*
* Uses:		d7, d6, ...
* Jumps-to:	flopcmds
* Called-by:	_flopfmt, _flopini
*
*-
hseek:	move.w	ctrack,d7		; dest track = 'ctrack'
hseek1:	move.w	#e_seek,curr_err	; possible error = "seek error"
hseek2:	move.w	#datareg,(a6)		; write destination track# to data reg
	bsr	wdiskctl
	move.w	#$10,d6			; execute "seek" command
	bra	flopcmds		; (without verify...can't fail)


*+
* reseek - home	head, then reseek track
* Returns:	EQ/NE on success/failure
* Falls-into:	go2track
*
*-
reseek:
	move.w	#e_seek,curr_err	; set "seek error"
	bsr	restore			; restore head
	bne	go2trr			; (punt if home fails)

	clr.w	dcurtrack(a1)		; current track = 0
	move.w	#trkreg,(a6)		; set "current track" reg on 1770
	clr.w	d7
	bsr	wdiskctl

	move.w	#datareg,(a6)		; seek out to track five
	move.w	#5,d7
	bsr	wdiskctl		; dest track = 5
	move.w	#$10,d6
	bsr	flopcmds		; seek w/o verify (can't fail)

* a seek with no verify can't fail! Why do we bother to check?

	bne	go2trr			; return error on seek failure

* at this point we don't really know that dcurtrack is 5 - the seek could
* have failed and we wouldn't know.

	move.w	#5,dcurtrack(a1)	; set current track#

*+
* go2track - seek proper track
* Passed:	Current floppy parameters (ctrack, et al.)
* Returns:	EQ/NE on success/failure
* Calls:	flopcmds
*-
go2track:

.if HI_DEN
	move.w	#1,go2count		; init hi-den retry count
go2retry:
.endif
	move.w	#e_seek,curr_err	; set "seek error"
	move.w	#datareg,(a6)		; set destination track# in
	move.w	ctrack.w,d7		;  1770's data register
	bsr	wdiskctl		; (write track#)
	moveq	#$14,d6			; execute 1770 "seek_with_verify"
	bsr	flopcmds		; (include seek-rate bits)

	bcs	go2trr			; return CS NOW if empty drive

.if (HI_DEN == 0)
	bne	go2trr			; timeout - failed (return NE)
	and.b	#$18,d7			; check for error bits
	bne	go2trr			; error - failed (return NE)
.else
	bne	go2bad			; timeout - failed (return NE)
	and.b	#$18,d7			; check for error bits
	beq	go2ok			; none - all OK (return EQ)

*
* Seek-with-verify failed.  Might be because we're using the
* wrong density.  Try the other one.
*
* NOTE: density register is WRITE ONLY: don't read it!
*
go2bad:
	move.w	ddenflags(a1),d0	; get the current density
	and.w	#3,d0			; mask off unused bits
	eor.w	#3,d0			; flip wanted bits
	move.w	d0,ddenflags(a1)	; to control register and to dsb
.if STPAD
	bsr	do_hiden
.else
.if (TT | SPARROW)
	move.w	d0,denselect
.else
	tst.b	_iamanst
	bne	noden2
	move.w	d0,denselect
noden2:
.endif
.endif
	subq.w	#1,go2count		; decrement failure countdown
	bne	go2trr			; really failed! (return NE)
	bsr	restore			; try again, but restore first.
	bra	go2retry

go2ok:
.endif

	move.w	ctrack.w,dcurtrack(a1)	; update current track number
	clr.w	d7			; return EQ for no error
go2trr:	rts				; return EQ/NE on succes/failure


*+
* restore - home head
* Passed:	nothing
* Returns:	EQ/NE on success/failure
* Calls:	flopcmds
*
* high-density note: the 1772 restore command returns when TRK00
* bit is 1.  It doesn't actually read anything.
*-
restore:
	clr.w	d6			; $00 = 1770 "restore" command
	bsr	flopcmds		; do restore
	bne	res_r			; punt on timeout
	btst	#2,d7			; test TRK00 bit
	eor	#$04,ccr		; flip Z bit (return NE if bit is zero)
	bne	res_r			; punt if didn't win
	clr.w	dcurtrack(a1)		; set current track#
res_r:	rts



*+
* flopcmds - floppy command (or-in seek	speed bits from	database)
* Passed:	d6.w = 1770 command
* Sets-up:	seek bits (bits 0 and 1) in d6.w
* Falls-into:	flopcmd
* Returns:	EQ/NE on success/failure
*-

.if HI_DEN
.if (QD == 0)
rtmap:	dc.b	1,1,0,0			; see _floprate for mode on this
.else
rtmap:	dc.b	1,1,1,1			; QD table: gives 6ms at HD, 3ms at QD
.endif
.endif

flopcmds:
	move.w	dseekrt(a1),d0		; get floppy's seek rate bits
	and.w	#3,d0

.if HI_DEN
; if hi-den, remap the seek rate
	tst.w	ddenflags(a1)
	beq	nomap
	lea	rtmap,a0		; (MAS has PC-relative bugs)
	move.b	(a0,d0.w),d0		; remap the rate
nomap:
.endif

	or.b	d0,d6			; OR the rate into the command
.if HI_DEN
	or.b	dspinflag(a1),d6	; OR in the spinup flag
.endif

*+
* flopcmd - execute 1770 command (with timeout)
* Passed:	d6.w = 1770 command
*
* Returns:	EQ/NE on success/failure
*		d7 = 1770 status bits
*
*-
flopcmd:

.if HI_DEN
; set density based on the DSB pointer in a1
.if STPAD
	move.w	ddenflags(a1),d0
	bsr	do_hiden
.else
.if (TT | SPARROW)
	move.w	ddenflags(a1),denselect
.else
	tst.b	_iamanst
	bne	noden3
	move.w	ddenflags(a1),denselect
noden3:
.endif
.endif
.endif

	move.l	_hz_200.w,d7
	add.l	#timeout,d7		; setup	timeout	count (assume short)
	move.w	#cmdreg,(a6)		; select 1770 command register
	bsr	rdiskctl		; read it to clobber READY status
	btst	#7,d0			; is motor on?
	bne	flopcm			; (yes, keep short timeout)
	move.l	_hz_200.w,d7
	add.l	#ltimeout,d7		; extra timeout for motor startup
flopcm:	bsr	wdiskct6		; write	command	(in d6)

flopc1:	cmp.l	_hz_200.w,d7
	blo	flopcto			; (yes,	reset and return failure)
	btst.b	#5,gpip			; 1770 completion?
	bne	flopc1			; (not yet, so wait some more)
	bsr	rdiskct7		; return EQ + 1770 status in d7
	clr.w	d6
	rts
flopcto:
	bsr	reset1770		; bash controller
	moveq	#0,d6			; and return NE and CS (empty)
	subq	#1,d6			; set carry so we return NE and CS
	rts


.if STPAD
*
* STPAD-only routine to set high-density select bit in PSG (bit 7) based on
* d0.w (zero: low density (clear the bit); nonzero: high density (set the
* bit)).
*

do_hiden:
	tst.w	d0			; hi den?
	bne	padhi1

* padlo1: select low density.  This means zeroing bit 7 of PSG port A
	clr.b	d0			; clear the bit
	bra	padden1
padhi1:	move.b	#$80,d0			; set the bit
padden1:
	move.w	sr,d2
	move.b	#$e,giselect
	move.b	giread,d1		; read current value
	bclr	#7,d1			; clear the bit
	or.b	d0,d1			; OR in new value
	move.b	#$e,giselect
	move.b	d1,giwrite		; write our new value
	move.w	d2,sr
	rts
.endif

*+
* reset1770 - reset disk controller after a catastrophe
* Passed:	nothing
* Returns:	nothing
* Uses:		d7
*-
reset1770:
	move.w	#cmdreg,(a6)		; execute 1770 "reset" command
	move.w	#$d0,d7
	bsr	wdiskctl
.if TT
	move.w	d0,-(sp)
	move.w	#$0114,d0		; 25 * 1.6us > 32us
	bsr	ttwait			; delay 32us after reset
	move.w	(sp)+,d0
.else
*
* Wait >32us using a trick:  assume that Timer C is still as BIOS 
* programmed it, counting down 5ms in 192 ticks.  Each tick is then
* 26us, and waiting for three of these is a wait of from 52us to
* 78us.  (Only two ticks means waiting from 26us to 52us, which
* doesn't guarantee a long-enough delay.)  We might wait longer
* if we miss ticks, but it doesn't matter.  It isn't bloody likely
* that we'll be EXACTLY in step, running every 5ms +- 26us,
* and therefore always see the same value.
*

	move.w	#2,d0			; do this loop 3 times
r1770:	move.b	tcdr,d1
r1770a:	cmp.b	tcdr,d1
	beq	r1770a			; wait for a change
	dbra	d0,r1770		; loop d0 times
.endif
	bsr	rdiskct7		; return 1770 status in	d7
	rts


*+
* select - setup drive select, 1770 and	DMA registers
* Passed:	cside, cdev
* Returns:	appropriate drive and side selected
*-
select:
	clr.w	deselflg.w		; floppies NOT deselected
	move.w	cdev.w,d0		; get device number
	addq.b	#1,d0			; add and shift	to get select bits
	lsl.b	#1,d0			; into bits 1 and 2
	or.w	cside.w,d0		; or-in	side number (bit 0)
	eor.b	#7,d0			; negate bits for funky	hardware select
	and.b	#7,d0			; strip	anything else out there
	bsr	setporta		; do drive select

	move.w	#trkreg,(a6)		; setup	1770 track register
	move.w	dcurtrack(a1),d7	;	from current track number
	bsr	wdiskctl

*--- alternate entry point: setup R/W parameters on 1770
select1:
	move.w	#secreg,(a6)		; setup	requested sector_number	from
	move.w	csect.w,d7		;	caller's parameters
	bsr	wdiskctl
	move.b	cdma+3.w,dmalow		; setup	DMA chip's DMA pointer
	move.b	cdma+2.w,dmamid
	move.b	cdma+1.w,dmahigh
	rts


*+
* setporta - set floppy	select bits in PORT A on the sound chip
* Passed:	d0.b (low three	bits)
* Returns:	d1 = value written to port A
*		d2 = old value read from port A
* Uses:		d1
*
* External entry point for C: _setporta() takes arg on stack, returns in d0.
*
* If not sparrow, we allow this call to mess with the three low bits
* of PSG port A, but leave the rest alone.  If sparrow, we can only
* mess with two bits (there is no Drive 1 select any more).
*-
setporta:
	move	sr,-(sp)		; save our IPL
	or	#$0700,sr		; start	critical section
	move.b	#giporta,giselect	; select port on GI chip
	move.b	giread,d1		; get current bits
	move.b	d1,d2			; save old bits for caller
.if SPARROW
	and.b	#$fc,d1			; zero low two bits of current value
	and.b	#$3,d0			; zero all but two bits of new value
.else
	and.b	#$f8,d1			; zero low three bits of current value
	and.b	#$7,d0			; zero all but three bits of new value
.endif
	or.b	d0,d1			; or-in	our new	bits
	move.b	#giporta,giselect	; re-select port A (AKP 5/92)
	move.b	d1,giwrite		; and write 'em	back out there
	move	(sp)+,sr		; restore IPL to terminate CS, return
	rts

.globl _setporta
_setporta:
	move.w	4(sp),d0
	bsr	setporta
	move.w	d2,d0
	rts


*+
* Primitives to	read/write 1770	controller chip	(DISKCTL register).
*
* The 1770 can't keep up with full-tilt	CPU accesses, so
* we have to surround reads and	writes with delay loops.
* This is not really as slow as it sounds.
*
* rdiskctl used to save the flags, too, but nobody cared, so now
* it doesn't. (AKP 9/89)
*
* there were calls to rwdelay before AND AFTER each hit on the register,
* bit this is unnecessary, so I took the post-access delays out.
*-
wdiskct6:				; write	d6 to diskctl
	bsr	rwdelay			;	delay
	move.w	d6,diskctl		;	write it
	rts

wdiskctl:				; write	d7 to diskctl
	bsr	rwdelay			;	delay
	move.w	d7,diskctl		;	write it
	rts

rdiskct7:				; read diskctl into d7
	bsr	rwdelay			;	delay
	move.w	diskctl,d7		;	read it
	rts

rdiskctl:				; read diskctl into d0
	bsr	rwdelay			;	delay
	move.w	diskctl,d0
	rts

rwdelay:
.if TT
	move.w	d0,-(sp)		; save counter register
	move.w	#$0119,d0		; 25 * 1.6us > 32us
	bsr	ttwait
	move.w	(sp)+,d0		; restore register
.else
* wait for >32us using a trick; see reset1770 for why this works.

	movem.l	d0-d1,-(sp)
	move.w	#2,d0			; do this loop 3 times
rwd1:	move.b	tcdr,d1
rwd2:	cmp.b	tcdr,d1
	beq	rwd2			; wait for a change
	dbra	d0,rwd1			; loop d0 times
	movem.l	(sp)+,d0-d1
.endif
	rts



*+
* change - check to see if the "right" floppy has been inserted
* On the stack:
*	$10(sp) - dev.W (device#)
*	 $c(sp) - dsb.L (pointer to Device State Block)
*	  8(sp) - dma.L (dma pointer)
*	  4(sp) - ret1.L (caller's return address)
*	  0(sp) - ret.L (change's return address)
*
* Returns:	both media "might have changed" condition
*		and "grace" timers expired.
*
* Uses:		C registers
*
*-
change:
	cmp.w	#1,_nflops		; if there are zero or two floppies
	bne	ch_r			;       then do nothing (return OK)
	move.w	$10(sp),d0		; if cdev == _curflop
	cmp.w	_curflop,d0		; (...current disk == current drive?)
	beq	ch_ok1			; then return OK (but use drive #0)

*--- ask the user to stick in the other floppy (via critical error handler)
	move.w	d0,-(sp)		; push disk# we want inserted
	move.w	#e_insert,-(sp)		; push "INSERT_A_DISK" error number
	bsr	_critic			; use critical error handler and
	add.w	#4,sp			;	hope somebody handles it
	move.w	#$ffff,_wplatch		; set "might have changed" on both drvs

*	; code added 4/27/88 AKP
	lea.l	_acctim,a0		; set last-access time to "long ago"
	clr.l	(a0)+			; so the grace period in mediach
	clr.l	(a0)			; is always expired.

	move.w	$10(sp),_curflop	; set current disk#
ch_ok1:	clr.w	$10(sp)			; use drive 0
ch_r:	rts


*+
* setdmode - set drive-change mode
* Passed:	d0.b = mode to put current drive in (0, 1, 2)
* Uses:		a0
*
* This had a bug: it set the state of the drive in cdev,
* but on a single-floppy system that is always 0.  It should
* set the state of the LOGICAL drive, which in single-drive
* systems can be found in _curflop.
*-
setdmode:
	lea	_diskmode,a0		; a0 -> disk mode table
	move.b	d0,-(sp)		; (save mode)
	move.w	cdev.w,d0		; d0.w = drive# (index into table)
	cmp.w	#1,_nflops		; one floppy?
	bne	dmode1			; no - d0 is fine
	move.w	_curflop,d0		; yes - d0 must come from _curflop
dmode1:	move.b	(sp)+,(a0,d0.w)		; set drive's mode
	rts


*+
* Floprate - read / change the seek rate of a drive
*
* Usage: oldrate = Floprate(devno,newrate);
* Returns old rate.  Sets new rate if newrate is not -1, else leaves it alone.
*
* This call is new with TOS 1.4.  You have to do this by hand for older TOSes:
*	DRIVE	RAM TOS		11/20/85	4/22/87
*	  A	 6cb		  a09		  a4f
*	  B	 6cf		  a0d		  a53
*
* The values that make sense to the 1772 are:
*
*     VALUE    LOW-DEN	HIGH-DEN    QUAD-DEN
*	00	 6 ms	  3   ms     1.5  ms
*	01	12 ms	  6   ms     3    ms
*	02	 2 ms	  1   ms     0.5  ms
*	03	 3 ms	  1.5 ms     0.75 ms
*
* This code does not range-check the value you set, or the drive ID:
* drive zero -> zero, nonzero -> one.
*
* FOR HIGH-DENSITY DRIVES:  The seek rate parm is taken to be a LOW-DEN
* seek rate; when there is a HIGH-DEN disk in the drive, we map the input
* value to the appropriate 1772 value, with errors on the slow side: 3->0,
* 2->0, 1->1 (what can you do?), and 0->1. This is done in rtmap in
* flopcmds.
*
* For quad density, all values are mapped to 1 (3ms).  What can you do?
*
* New feature: if the rate is -2, that drive's no-spinup-delay flag is set.
* A rate of -3 clears the flag, and -4 interrogates the current setting. 
* When the startup sees that you've thrown the configuration switch
* declaring high-density drives, it sets the no-spinup-delay flag for
* physical drive 0.  If drive 1 also should not have the spinup-delay flag
* set, make this call.
*
*-

_floprate:
	lea.l	dsb0,a1			; get dsb0 first
	tst.w	4(sp)			; was that right?
	beq	rate1			; yes.
	lea.l	dsb1,a1			; no - use dsb1
rate1:	move.w	dseekrt(a1),d0		; get the old rate
	move.w	6(sp),d1		; get the desired rate
	cmp.w	#-1,d1			; no change?
	beq	ratedone		; yes
	cmp.w	#-2,d1			; set no-spinup-delay flag?
	beq	setspinup
	cmp.w	#-3,d1			; clear no-spinup-delay flag?
	beq	clrspinup
	cmp.w	#-4,d1			; interrogate no-spinup-delay flag?
	beq	getspinup
	move.w	d1,dseekrt(a1)		; no - do change it.
ratedone:
	ext.l	d0			; clear high part of return code
	rts				; and return.

setspinup:
.if HI_DEN
	move.b	#$08,dspinflag(a1)	; set the no-spin-delay flag.
.endif
	moveq.l	#0,d0			; return zero for fun
	rts

clrspinup:
.if HI_DEN
	clr.b	dspinflag(a1)		; clear the flag
.endif
	moveq.l	#0,d0			; return zero for fun
	rts

getspinup:
.if HI_DEN
	tst.b	dspinflag(a1)		; return 0 or -1, not the flag itself.
	sne	d0
	ext.w	d0
	ext.l	d0
.else
	moveq.l	#0,d0
.endif
	rts

*+
* Flopwp - check write-protect mode of a disk
* This can cause the "insert disk X" message.
*
* Usage: Flopwp(devno)
* Returns 1 if the WP state of the indicated drive is TRUE (proteted).
*
* Needs to call "change" with a slightly funny stack frame.
*
* The code to check WP state is stolen from flopvbl.
*-
*
*_flopwp:
*	sub.w	#$8,sp		; "push" 3 dummy longs
*	bsr	change		; get right disk in drive
*				; this can change the devno on the stack!
*	add.w	#$8,sp		; clean up stack
*	move.w	$4(sp),d0	; get (possibly new) dev number
*	and.w	#$1,d0		; keep only bit 0
*	lea	_wpstatus.w,a0
*	add.w	d0,a0		; a0 -> WP status table entry
*
*	addq.b	#1,d0		; turn into drive-select bits
*	lsl.b	#1,d0		; (magic shift left)
*	eor.b	#7,d0
*	bsr	setporta	; (d2 = old bits)
*	move.w	diskctl,d0	; get WP state from bit 6 of disk ctl
*	btst	#6,d0
*	sne.b	d0		; d0 = $00 or $ff
*	move.b	d0,(a0)		; wpstatus = $00 or $ff
*	move.b	d2,d0		; d0 = old bits
*	bsr	setporta	; restore old select bits
*
*	move.w	_wpstatus.w,d0
*	or.w	d0,_wplatch.w	; (catch WP transitions)
*	move.b	(a0),d0		; reload the WP status as return value.
*	ext.w	d0
*	ext.l	d0
*	rts

***********************************************************************
*
* code to handle fast vs slow ram:
*
*	In each case, if the buffer address is in slow RAM, return.
*	Else...
*
*	rdfast: change the buffer pointer on the stack to point to 
* _FRB, set fastbuf to the old buffer pointer, set fastcnt to the 
* sector count.
*
*	wrfast: copy from the original buffer address to _FRB
* buffer and change the buffer pointer.  Clear fastcnt (no tail copy).
*
*	fmfast: (format) save & change dma address, set fastcnt to 1
* (for copying the result list).
*
*	vrfast: (verify) same as fmfast.
*
* The common code which returns from all these services calls "unfast"
* which performs the "tail copy" if necessary: if fastcnt is not zero,
* that many sectors are copied from _FRB to fastbuf.  Unfast does not
* use d0.  Unfast pre-clears fastcnt for the next Flop call.  Flopini
* clears it to begin with.
*
* This code must not clobber d0, which may contain a return value
* destined for the caller.
*
* This code checks for an FRB cookie the first time it's needed.
* If there is no FRB cookie, it dies horribly.  It pops the stack
* back to the caller's level and returns e_error.
* (It must check for the cookie at "run time" because alternative
* RAM can be added after boot time.)
*

.if TT
MAXACSI	equ	$00A00000		; max addr for TT: 10MB.
.else
.if SPARROW
MAXACSI equ	$00E00000		; max addr for Sparrow: 14MB.
.else
MAXACSI	equ	$00400000		; max addr where ACSI DMA works
.endif
.endif

unfast:
	move.w	fastcnt,d1
	beq	undone
.if M68030
	move.l	d0,-(sp)		; clrcache clobbers d0 so save it
	bsr	clrcache		; after DMA read, must clear cache.
	move.l	(sp)+,d0		; restore d0
.endif
	clr.w	fastcnt			; make sure count is zero next time
	move.l	fastbuf,a0
	move.l	_frb,a1
unmove:	asl.w	#5,d1			; d1 is now number of 16's of bytes
	subq.w	#1,d1
unloop:	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	dbra	d1,unloop
undone:	rts

* rdfast - the buffer address is at 8(sp), count at $18(sp)
* Change the pointer and set up for the copy at unfast time.

rdfast:	cmp.l	#MAXACSI,8(sp)
	bcs	undone			; never mind
	bsr	getfrb
	move.l	8(sp),fastbuf		; after op, copy to user's buffer
	move.l	_frb,8(sp)		; actual DMA to _FRB
	move.w	$18(sp),fastcnt		; count
	rts

* wrfast - the buffer address is at 8(sp), count at $18(sp)
* Change the pointer and do the copy.

wrfast:	cmp.l	#MAXACSI,8(sp)
	bcs	undone
	bsr	getfrb
	move.l	8(sp),a1		; src = user's buffer
	move.l	_frb,a0			; dest = _FRB
	move.l	a0,8(sp)		; actual DMA from _FRB
	move.w	$18(sp),d1		; count
	bra	unmove			; copy, then rts to caller

* fmfast, vrfast are the same - (format) buffer address at 8(sp), 
* count is 1 for copy of bad-sector list at end.

vrfast:
fmfast:	cmp.l	#MAXACSI,8(sp)
	bcs	undone
	bsr	getfrb
	move.l	8(sp),fastbuf		; after op, copy to user's buffer
	move.l	_frb,8(sp)		; actual DMA to _FRB
	move.w	#1,fastcnt		; count is one sector
	rts

*
* routine to get the _FRB cookie if there is one (see cookie jar spec)
*

getfrb:
	tst.l	_frb			; already done this?
	bne	gotfrb			; yes, bail out.
	move.l	_p_cookie,a0		; no; get base of cookie jar
	cmp.w	#0,a0			; no cookie jar?
	beq	getf2			; yow! no cookie jar! bail out.
getf1:	tst.l	(a0)			; end of cookie jar?
	beq	getf2			; yes, die horribly
	cmp.l	#"_FRB",(a0)+		; no; match our cookie?
	beq	getfdone		; yes, copy ptr & return
	addq.l	#4,a0			; no, advance to next cookie
	bra	getf1			; and loop

getfdone:
	move.l	(a0)+,_frb		; copy ptr
gotfrb:	rts				; and return.

* bad news - no FRB cookie when it's needed!

getf2:	addq.l	#8,sp			; pop 2 levels of bsr's
	moveq.l	#-12,d0			; return general failure
	rts				; to caller (usu. Rwabs)

*--------------	Floppy RAM usage:
	.bss
retrycnt:	ds.w	1		; retry	counter		(used)
_wpstatus:	ds.b	2		; WP status (2 drives)	status
_wplatch:	ds.b	2		; WP latch (2 drives)	status
_acctim:	ds.l	2		; last access counter
deseltime:	ds.l	1		; 200Hz time to de-select drives
_motoron:	ds.w	1		; motor-on-P (both drives)  status
deselflg:	ds.w	1		; deselect flag		state

cdev:		ds.w	1		; device #		parm
ctrack:		ds.w	1		; track	number		parm
csect:		ds.w	1		; sector number		parm
cside:		ds.w	1		; side number		parm
ccount:		ds.w	1		; sector count		parm
cdma:		ds.l	1		; DMA address		parm

spt:		ds.w	1		; #sectors_per_track	flopfmt	parm
interlv:	ds.w	1		; interleave factor	flopfmt	parm
virgin:		ds.w	1		; fill data for sectors	flopfmt parm
skewtbl:	ds.l	1		; pointer to skew table if interlv=-1

def_error:	ds.w	1		; default error number
curr_err:	ds.w	1		; current error number

regsave:	ds.l	9		; save area for C registers
dsb0:		ds.b	dsbsiz		; floppy 0's DSB
dsb1:		ds.b	dsbsiz		; floppy 1's DSB

.if HI_DEN
go2count:	ds.w	1		; countdown for go2track den select
.endif

_frb:		ds.l	1		; frb address to use (zero until set)
fastbuf:	ds.l	1		; buffer address for copy at end
fastcnt:	ds.w	1		; # 512-byte chunks to copy at end
