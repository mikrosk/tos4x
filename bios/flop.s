******************* Revision Control System *****************************
*
* $Author: kbad $
* =======================================================================
*
* $Date: 89/02/06 23:07:08 $
* =======================================================================
*
* $Locker:  $
* =======================================================================
*
* $Log: flop.s,v $
* Revision 1.11  89/02/06  23:07:08  kbad
* Changed _acctim (last floppy access time) to use video frame counter
* instead of 200Hz clock.  Safer that way, since floppy WP is checked
* at vblank time -- this way mediach() will work even if 200Hz is disabled.
*
* Revision 1.10  88/12/22  12:56:27  apratt
* Added (a5)'s to save some words & some time (as if it mattered in 
* floppy code...)
* 
* Revision 1.9  88/10/12  17:23:15  apratt
* Added the Floprate call: oldrate = Floprate(devno,newrate) where
* newrate == -1 if you don't want to change it.
* 
* Revision 1.8  88/06/28  16:27:21  apratt
* Removed extra index information because it made 10-sector
* formatting not work.  Better to be compatible with our own
* programs than to try to be compatible with crummy PC drives.
* 
* Revision 1.7  88/04/28  16:06:39  apratt
* Backed out Flopwp XBIOS call... Turned out to be a flop.
* (I didn't want the Desktop to use this one Flop call, because it's possible
* that somebody installed an Rwabs-level driver for drives A and B.)
* 
* Revision 1.6  88/04/27  13:36:26  apratt
* Added code to set last-access time of both drives to "long ago"
* when you change logical disks in a physical drive, so the next call
* to mediach() won't think it's still in the "grace period."
* 
* Revision 1.5  88/04/05  17:45:52  apratt
* Tested Flopwp call; it returns TRUE when there is no disk in the drive.
* This can be overcome by doing a READ to make sure there *is* a disk
* in the drive.  The read should come from GEMDOS (e.g. Fsfirst("A:\\*.*",-1))
* rather than BIOS to be sure that media change is processed.
* 
* Revision 1.4  88/04/04  15:39:24  apratt
* Didn't do anything: don't know why it was locked.
* 
* Revision 1.3  88/03/28  11:45:48  apratt
* Added check-floppy-state Xbios call.  Can cause "insert other floppy"
* message, so use this only when you would cause a swap anyway.
* 
* Revision 1.2  88/03/25  11:49:50  apratt
* This version has more index information per Intel controller spec
* in the format-track code.  THIS IS UNTESTED AND MIGHT NOT WORK.
* 
* Revision 1.1  87/11/20  14:23:48  lozben
* Initial revision
* 
*
* =======================================================================
*
* $Revision: 1.11 $
* =======================================================================
*
* $Source: /u2/MRS/osrevisions/bios/flop.s,v $
* =======================================================================
*
*************************************************************************
*------------------------------------------------------------------------
*									:
*	Atari ST							:
*	Floppy Disk Driver						:
*	Copyright 1985, 1986 Atari Corp.				:
*									:
*----									:
* 15-Aug-1986 lmd	Fixed floprd(), now returns CRC error correctly.:
*									:
* 15-Apr-1986 lmd	Removed das_boot conditional assembly.		:
*			Re-write _floprd() to fix CRC/LOST DATA problem.:
*			Fixed multiple-sector retry problem (retry count:
*			only applies to current sector.)		:
*									:
* 07-Apr-1986 RMS	New feature to _flopfmt -if interlv is a NEG	:
*			number then 'filler' points to a skew table	:
*----									:
* 22-Feb-1985 lmd	Added write-protect and motor-on monitoring.	:
* 22-Feb-1985 lmd	Substituted format-track for format-disk.	:
* 23-Feb-1985 lmd	Multiple-sector DMA in _floprd.			:
* 25-Feb-1985 lmd	_flopwr understands "ccount" (but cannot do	:
*			multi-sector DMA -- a hardware constraint).	:
* 25-Feb-1985 lmd	Added "virgin" parameter to _flopfmt		:
* 27-Feb-1985 lmd	_flopwr() can write an entire track in one	:
*			revolution of the disk....			:
* 28-Feb-1985 lmd	_floprd() doesn't do reseek on seek error	:
*			(it takes too long)				:
*  4-Mar-1985 lmd	Added "bad sector" return to _flopfmt		:
*  7-Mar-1985 lmd	Fixed bug in _flopfmt bad sector return		:
*  8-Mar-1985 lmd	Fixed "floplock" and "flopulok" to save and	:
*			restore C registers.				:
* 10-Mar-1985 lmd	Added "disk flip" code (hook to _critic)	:
* 13-Mar-1985 lmd	If single-floppy system, copy drive 0's write-	:
*			protect transitions to drive 1.			:
* 13-Mar-1985 lmd	Set _wplatch after disk flip			:
* 13-Mar-1985 lmd	Return reasonable error numbers			:
* 17-Mar-1985 lmd	Added _flopver()				:
* 21-Mar-1985 lmd	dasBoot assembly switches, default seek rate	:
* 22-Mar-1985 lmd	format_track sets media change mode to CHANGED	:
* 22-Mar-1985 lmd	a write to the boot sector sets the media	:
*			change mode to UNSURE.				:
* 28-Mar-1985 lmd	Force write-protect to "real time" mode		:
*			on any exit from the driver.			:
*  1-Apr-1985 lmd	Moved floppy DSBs to here.			:
*  1-Apr-1985 lmd	Based variables off of zero-page		:
*  8-Apr-1985 lmd	Moved flock out of here to public basepage	:
* 30-Apr-1985 lmd	Disk errors set media-change mode to UNSURE	:
*  1-May-1985 lmd	Bug in _flopini; mis-use of args on stack	:
*  6-May-1985 lmd	Set _motoron nonzero on any floppy command.	:
*			Added _acctim[] timer variables.		:
*									:
*------------------------------------------------------------------------
	text


HI_DEN		equ	1		; always enable this code
retries		equ	2		; default # of retries - 1
midretry	equ	1		; "middle" retry (when to reseek)
timeout		equ	$40000		; short	timeout (motor already on)
ltimeout	equ	$60000		; long timeout (to startup motor)
retries		equ	2	; default # of retries - 1

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
	.globl	_iamanst		; byte: true if we're on an ST
	.globl	clrcache		; clear i & d caches on TT
.if TT
	.globl	ttwait
.endif

_p_cookie	equ	$5a0		; pointer to cookie jar


*------ media change modes:
m_changed	equ	2		; "CHANGED" media
m_unsure	equ	1		; "UNSURE" about media change


*------ Error returns
e_error		equ	-1		; general catchall
e_crc		equ	-4		; CRC error
e_seek		equ	-6		; seek error
e_rnf		equ	-8		; record (sector) not found
e_write		equ	-10		; generic write error
e_read		equ	-11		; generic read error
e_wp		equ	-13		; write on write-protected media
dcurtrack	equ	0		; current track#
dspinflag	equ	0		; spinup-delay flag (in hi byte)
dcurtrack	equ	2		; current track#
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
*	 $0(sp)	return address
*

	bsr	restore			; attempt restore
	beq	fi_ok			; (quick exit if that won)
	moveq	#10,d7			; attempt seek to track 10
	bsr	hseek1			; (hard seek to 'd7')
	bne	fi_nok			; (failed: drive unusable)

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
	move.w	#$0202,_diskmode.w	; make both appear "changed."
	moveq.l	#0,d0			; return "success" to rwabs.c,
	tst.w	_nflops.w		; if this is the first time through
	

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
	bsr	rdiskctl		; read it back
	move.b	d0,d1			; save it for a little bit
	move.w	#secreg,(a6)
	bsr	rdiskctl		; read secreg back
	subq.w	#1,flock.w		; un-lock the bus
	bne	noflop			; no - no floppies
	cmp.b	#$ff,d0			; still $ff?
					; (leave ccr set)
	move.w	#$090,(a6)		; toggle DMA data direction,
	move.w	#$190,(a6)		;	leave hardware in READ state
	move.w	#$090,(a6)
*	 $8(sp)	->DSB
*	 $4(sp) ->buffer
*	 $0(sp)	return address
*
	move.l	#timeout,d7		; set timeout count
* Returns:	EQ, the read won (on all sectors),
.if STPAD
frd2:	btst.b	#5,gpip(a5)		; 1770 done yet?
	beq	noflop1			; no floppies!
	subq.l	#1,d7			; decrement timeout counter
	bne	frd2			; (not timed-out yet)
	move.w	#e_nready,curr_err(a5)	; set "timeout" error
	moveq	#e_read,d0		; set default error#
	bsr	rdfast
	bsr	floplock		; lock floppies, setup parameters
frd1:	bsr	select			; select drive,	setup registers
frd4:	move.w	#$090,(a6)		; examine DMA status register
	bcs	flopfail		; EMPTY DRIVE - FAIL NOW
	bne	frde			; retry on seek failure

frd1a:	move.w	#e_error,curr_err	; set general error#

; reset ACSI chip (see notes)
	move.w	#$190,(a6)
	tst.b	gpip
	tst.b	gpip
	move.w	#retries,retrycnt(a5)	; setup retry count
	addq.w	#1,csect(a5)		; bump sector number
	add.l	#$200,cdma(a5)		; and DMA pointer for next sector
	subq.w	#1,ccount(a5)		; if(!--count) return OK;
	tst.b	gpip
	tst.b	gpip

* why does this write to diskctl not use wdiskctl? Because it's actually
* writing to the DMA chip, not the 1770.
frde:	cmp.w	#midretry,retrycnt(a5)	; are we on the	"middlemost" retry?

	move.w	#$080,(a6)		; startup 1770 "read sector" command
frd5:	subq.w	#1,retrycnt(a5)		; drop retry count
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
	bne.s	eb1
	move.w	(a6),d0
	btst	#0,d0			; bit zero indicates DMA error
	beq	frde			; (when	its zero -- retry)
	bne.s	eb1
	move.w	#$080,(a6)		; examine 1770 status register
	bsr	rdiskctl
	and.b	#$1c,d0			; check	for RNF, checksum, lost-data
	bne.s	eb1
	move	def_error(a5),d1	; use default error#
eb1:	move.w	d1,curr_err(a5)		; set current error number & return
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
*-
err_bits:
	btst	#6,d0
	bne	eb1

	moveq	#e_rnf,d1		; record-not-found?
	btst	#4,d0
	bne	eb1

	move.w	csect(a5),d0		; sector 1

	or.w	ctrack(a5),d0		; track 0
	or.w	cside(a5),d0		; side 0
	move	def_error.w,d1		; use default error#
eb1:	move.w	d1,curr_err.w		; set current error number & return
	rts


*+
* Passed (on the stack):
fwr1a:	move.w	#e_error,curr_err(a5)	; set general error#
	move.w	#$190,(a6)		; toggle DMA chip to clear status
	move.w	#$090,(a6)
	move.w	#$190,(a6)		; leave	in WRITE mode
	bsr	fdcprobe
	beq	noflop1			; no floppies!
.endif

	or.w	cside.w,d0		; side 0
	move.l	#timeout,d7		; d7 = timeout count
	bsr	setdmode		; (boy, is this /ugly/)
fwr2:	btst.b	#5,gpip(a5)		; done yet?
fwr1:	bsr	select			; select drive
	subq.l	#1,d7			; decrement timeout count
	bne	fwr2			; (still tickin')
	bne	fwre1			; (retry on seek failure)
fwr1a:	move.w	#e_error,curr_err.w	; set general error#

; reset ACSI chip (see notes)
	move.w	#$090,(a6)
	tst.b	gpip
	tst.b	gpip
	tst.b	gpip
	move.w	#1,d7			; load sector-count register
	move.w	#$190,(a6)		; leave	in WRITE mode
	bsr	wdiskctl
	move.w	#retries,retrycnt(a5)	; setup retry count
	addq.w	#1,csect(a5)		; bump sector number
	add.l	#$200,cdma(a5)		; and DMA pointer for next sector
	subq.w	#1,ccount(a5)		; if(!--count) return OK;
.endif

	move.w	#$180,(a6)		; load "WRITE SECTOR" command
	move.w	#$a0,d7			; into 1770 cmdreg
fwre:	cmp.w	#midretry,retrycnt(a5)	; re-seek head in "middle" retry
.if QD
*
fwr5:	subq.w	#1,retrycnt(a5)		; decrement retry count
* if you're at high density at all.  This is not really what we should
* do, but it is here for testing.
*

	tst.w	dseekrt(a1)
	beq	noqd0
	or.w	#%10,d7			; OR in disable of write precomp
noqd0:
.endif
*	$14(sp)	interleave		** if -1 then skew sectors use table
	bsr	wdiskctl
	move.l	_hz_200.w,d7
	add.l	#timeout,d7		; d7 = _hz_200 value to die at

*	 $8(sp)	NOT USED		** skew table if interleave -1
	beq	fwr4			; (yes,	check status)
	cmp.l	_hz_200.w,d7
	bhi	fwr2			; (still tickin')
	bsr	reset1770		; timed	out -- reset 1770
	bra	fwre			; and retry

fwr4:	move.w	#$180,(a6)		; get 1770 status
	bsr	rdiskctl
	bne	fwre			; retry on error

	move.w	#retries,retrycnt.w	; setup retry count
	addq.w	#1,csect.w		; bump sector number
	add.l	#$200,cdma.w		; and DMA pointer for next sector
	bra	fwr1a			; write next (no seek)

	bne	fwr5			; (not middle retry)
fwre1:	bsr	reseek			; home head and	seek
	move.w	$e(sp),spt(a5)		; save sectors-per-track
	move.w	$14(sp),interlv(a5)	; save interleave factor
	move.w	$1a(sp),virgin(a5)	; save initial sector data
	move.l	$8(sp),skewtbl(a5)	; save skew table pointer
*+
* _flopfmt - format a track
* Passed (on the stack):
*	$1a(sp)	initial sector data
*	$16(sp)	magic number
*-

_flopfmt:
	move.w	ctrack(a5),dcurtrack(a1)	; record current track#
	bne	flopfail		; no magic, so we just saved the world
.if STPAD
	move.w	#e_error,curr_err(a5)	; vanilla error mode
	beq	noflop1			; no floppies!
.endif
	move.w	spt(a5),ccount(a5)	; set number of sectors to verify
	move.w	#1,csect(a5)		; starting sector# = 1
	moveq	#e_error,d0		; set default error number
	bsr	fmfast
	bsr	floplock		; lock floppies, setup parms
	move.l	cdma(a5),a2		; a2 -> bad sector list
	move.w	$e(sp),spt.w		; save sectors-per-track
	move.w	$14(sp),interlv.w	; save interleave factor
	move.w	#e_badsects,curr_err(a5) ; set error number
	move.l	$8(sp),skewtbl.w	; save skew table pointer

*--- put drive into "changed" mode
	moveq	#m_changed,d0		; d0 = "CHANGED"
	bsr	setdmode		; set media change mode

.if HI_DEN
*--- set the density controller bits to the appropriate value
* Set this before calling seek, because it influences the seek-rate
* parameter written to the controller.

	moveq	#$3,d0			; assume hi den first
	move.w	#e_write,def_error(a5)	; set default error number
	move.l	cdma(a5),a2		; a2 ->	prototyping area
	move.l	skewtbl(a5),a3		; a3 -> skewtbl (if nesssary!)
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
	move.w	#60-1,d1		; 60 x $4e (track leadin)
	move.b	#$4e,d0
* Returns:	NE on failure, EQ on success
* Uses:		almost everything
* Called-by:	_flopfmt
	tst.w	interlv(a5)		; if NEG
*-
fmtrack:
	move.w	#1,d3			; start	with sector 1, first pass
	move.l	cdma.w,a2		; a2 ->	prototyping area
	move.l	skewtbl.w,a3		; a3 -> skewtbl (if nesssary!)

ot1:	move.w	#12-1,d1		; 12 x $00
* then backed out 6/88 because 10-sector formats stopped working.
*
	move.w	#3-1,d1			; 3 x $f5
	move.b	#$f5,d0
*	bsr	wmult
*
	move.b	ctrack+1(a5),(a2)+	; track#
	move.b	cside+1(a5),(a2)+	; side#
*	bsr	wmult
*
*	move.b	#$f6,d0			; 3 x $C2 as IAM preamble
*	move.b	d0,(a2)+
*	move.b	d0,(a2)+
	move.w	#22-1,d1		; 22 x $4e
	move.b	#$4e,d0
*	move.b	#$fc,(a2)+		; 1 x $fc as IAM
	move.w	#12-1,d1		; 12 x $00
* end of lines added by AKP for 82072 compatibility

	move.w	#3-1,d1			; 3 x $f5
	move.b	#$f5,d0
	cmp.w	#26,spt.w
	bhs	d1ok
.endif

	moveq	#120-1,d1		; 2x low-den track leadin
ot2:	move.b	virgin(a5),(a2)+	; copy high byte
	move.b	virgin+1(a5),(a2)+	; copy low byte
	moveq	#60-1,d1		; use recommended track-leadin size
d1ok:
	move.w	#40-1,d1		; 40 x $4e
	move.b	#$4e,d0

	clr.w	d3			; init for uses with skew table
	tst.w	interlv.w		; if NEG
	tst.w	interlv(a5)		; if interlv is NEG use skew table

	moveq	#1,d3			; start	with sector 1, first pass
	add.w	interlv(a5),d4		; bump sector#
	cmp.w	spt(a5),d4		; if(d4	<= spt)	then_continue;
ot3:	move.w	d3,d4			; d4 = starting	sector (this pass)
ot1:	moveq	#12-1,d1		; 12 x $00
	cmp.w	interlv(a5),d3		; if(d3	<= interlv) then_continue;
	bsr	wmult
	moveq	#3-1,d1			; 3 x $f5
*--- end-of-track
	move.b	ctrack+1.w,(a2)+	; track#
	move.w	#1400,d1		; 1401 x $4e --	end of track trailer
	move.b	#$4e,d0
	moveq	#3-1,d1			; 3 x $f5
	moveq	#$fffffff5,d0		; (really just $f5; mas complains)
	bsr	wmult
	move.b	cdma+3(a5),dmalow(a5)	; load dma pointer
	move.b	cdma+2(a5),dmamid(a5)
	move.b	cdma+1(a5),dmahigh(a5)
	move.w	#$190,(a6)		; toggle R/W flag and
	move.w	#$090,(a6)		; select sector-count register
	move.w	#$190,(a6)
	move.w	#$1f,d7			; (absurd sector count)
	cmp.w	spt.w,d4		; if(d4	<= spt)	then_continue;
	ble	ot1			; proto	more sectors this pass
	cmp.w	interlv.w,d3		; if(d3	<= interlv) then_continue;
	cmp.w	#13,spt.w
	move.l	#timeout,d7		; d7 = timeout value
etok:
	moveq	#$4e,d0			; end-of-track trailer
otw1:	btst.b	#5,gpip(a5)		; is 1770 done?

	subq.l	#1,d7			; if(--d7) continue;
	bne	otw1
	move.b	cdma+2.w,dmamid
	move.b	cdma+1.w,dmahigh

; reset ACSI chip (see notes)
	move.w	#$090,(a6)		; select sector-count register
	tst.b	gpip
	cmp.w	spt(a5),d3		; are we through all tracks
	tst.b	gpip
	tst.b	gpip
	move.w	#$190,(a6)
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
	beq	end_track		; this way out

	add.w	d6,d6			; work index
	move.w	(a3,d6.w),d4		; d4 = a skew table entry
	addq.w	#1,d3			; inc skew table index in this case
	bra	ot1			; write next track to buffer
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
	move.w	#e_read,def_error(a5)	; set default error number
	move.l	cdma(a5),a2		; a2 -> start of bad sector list
	add.l	#$200,cdma(a5)		; bump buffer up 512 bytes
* Returns:	NULL.W-terminated list of bad sectors in the buffer if D0 == 0,
*		OR some kind of error (D0 < 0).
tvrlp:	move.w	#retries,retrycnt(a5)	; init sector-retry count
*-
	move.w	csect(a5),d7		; with 'csect'
.if STPAD
	bsr	fdcprobe
	beq	noflop1			; no floppies!
tvr1:	move.b	cdma+3(a5),dmalow(a5)	; load dma pointer
	move.b	cdma+2(a5),dmamid(a5)
	move.b	cdma+1(a5),dmahigh(a5)
	move.w	#$090,(a6)		; toggle R/W (leave in W state)
	moveq	#e_read,d0		; set default error#
	move.w	#$090,(a6)
* verify1 - verify sectors on a single track
* Passed:	csect = starting sector#
*		ccount = number of sectors to verify
*		cdma -> 1K buffer (at least)
*
	move.l	#timeout,d7		; set timeout value
*
* Enviroment:	Head seeked to the correct track;
tvr2:	btst.b	#5,gpip(a5)		; test for 1770	done
*		Motor should be spinning (go2track and fmttrack do this).
	subq.l	#1,d7			; decrement timeout count
	bne	tvr2			; (still counting down)
*
* Called-by:	_flopfmt, _flopver
*
*-
verify1:
	move.w	#e_read,def_error.w	; set default error number
	move.l	cdma.w,a2		; a2 -> start of bad sector list
	add.l	#$200,cdma.w		; bump buffer up 512 bytes

*--- check 1770 completion status (see if it's happy):
tvrlp:	move.w	#retries,retrycnt.w	; init sector-retry count
	move.w	#secreg,(a6)		; load 1770 sector register
	move.w	csect.w,d7		; with 'csect'
	bsr	wdiskctl

*--- setup for sector read
tvr1:	move.b	cdma+3.w,dmalow		; load dma pointer
tvr6:	addq.w	#1,csect(a5)		; bump sector count
	subq.w	#1,ccount(a5)		; while(--count) read_another;
	move.w	#$190,(a6)
	sub.l	#$200,cdma(a5)		; readjust DMA pointer
; reset ACSI chip (see notes)
	tst.b	gpip
	tst.b	gpip
	tst.b	gpip
tvre:	cmp.w	#midretry,retrycnt(a5)	; re-seek head?
	move.w	#$090,(a6)
	tst.b	gpip
tvr5:	subq.w	#1,retrycnt(a5)		;	to the current track...
	tst.b	gpip
	move.w	csect(a5),(a2)+		; record bad sector
	bra.s	tvr6			; do next sector
	bsr	wdiskctl

	move.w	#$080,(a6)		; load 1770 command register
	move.w	#$80,d7			; with ReadSector command
	bsr	wdiskctl
	move.l	_hz_200.w,d7
	add.l	#timeout,d7		; d7 = _hz_200 value to die at
	clr.l	a5			; a5 -> zeropage base
	lea	fifo(a5),a6		; a6 -> fifo
	st.b	_motoron(a5)		; assume motor is on
	tst.w	flock(a5)		; floppies locked?
	bhi	tvr2			; (still counting down)
	bsr	reset1770		; reset	controller and return error
	bra	tvre
	move.l	_frclock(a5),d0		; check a drive every 8 jiffies
*--- got "done" interrupt, check DMA status:
tvr4:	move.w	#$090,(a6)		; read DMA error status
	move.w	(a6),d0
	btst	#0,d0			; if DMA_ERROR is zero,	then retry
	beq	tvre
*--- select drive, record it's WP status:
* --- check 1770 completion status (see if it's happy):
	move.w	#$080,(a6)		; read 1770 status register
	lea	_wpstatus(a5),a0	; a0 -> write-protect status table
	bsr	err_bits		; set error# from 1770 register
	and.b	#$1c,d0			; check	for record-not-found, crc-err,
	cmp.w	_nflops(a5),d0		; if(d0 == _nflops == 1)

*--- read next sector (or return if done)
tvr6:	addq.w	#1,csect.w		; bump sector count
	subq.w	#1,ccount.w		; while(--count) read_another;
	bne	tvrlp
	sub.l	#$200,cdma.w		; readjust DMA pointer
	move.w	diskctl(a5),d0		; get 1770 status
	btst	#6,d0			; test Write-Protect status bit
*--- read failure: retry or record bad sector
tvre:	cmp.w	#midretry,retrycnt.w	; re-seek head?
	bsr	setporta
	bsr	reseek			; yes: back to home and	then back
fvbl1:	move.w	_wpstatus(a5),d0	; or _wpstatus into _wplatch
	or.w	d0,_wplatch(a5)		; (catch any WP transitions)
	move.w	csect.w,(a2)+		; record bad sector
	bra	tvr6			; do next sector

	tst.w	deselflg(a5)		; floppies already deselected?
*+
* _flopvbl - floppy vblank handler
	bsr	fdcprobe
.endif

	move.l	_frclock.w,d0		; check a drive every 8 jiffies
	move.b	d0,d1			; (save jiffy count)
	move.w	#1,deselflg(a5)		; indicate floppies deselected
fvblr1:	clr.w	_motoron(a5)		; indicate motor is OFF
	move.w	#cmdreg,(a6)		; select 1770 command/status register

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
	clr.l	a5			; a5 -> zeropage base
	lea	fifo(a5),a6		; a6 -> fifo
	st	_motoron(a5)		; kludge motor state = ON
	move.w	d0,def_error(a5)	; set default error number
	move.w	d0,curr_err(a5)		; set current error number
	move.w	#1,flock(a5)		; tell vbl not to touch floppies
	move.l	8(sp),cdma(a5)		; cdma -> /even/ DMA address
	move.w	$10(sp),cdev(a5)	; save device# (0 .. 1)
	move.w	$12(sp),csect(a5)	; save sector# (1 .. 9,	usually)
	move.w	$14(sp),ctrack(a5)	; save track# (0 .. 39 .. 79 ..)
	move.w	$16(sp),cside(a5)	; save side# (0	.. 1)
	move.w	$18(sp),ccount(a5)	; save sector count (1..spt)
	move.w	#retries,retrycnt(a5)	; setup retry count
	move.l	_hz_200.w,d0		; get current time
	cmp.l	deseltime,d0		; is it at or past drop-dead time?
	lea	dsb0(a5),a1
	tst.w	cdev(a5)
	bsr	rdiskctl		; read 1770 status register
	lea	dsb1(a5),a1
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
flock1	move.w	#recal,dcurtrack(a1)	; complete failure (what can we do?)
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
	move.w	curr_err(a5),d0		; get current error number
*-
	bra.s	unlok1			; clobber floppy lock & return
	movem.l	d3-d7/a3-a6,regsave	; save C registers

	lea	fifo,a6			; a6 -> fifo
	st	_motoron.w		; kludge motor state = ON
	move.w	d0,def_error.w		; set default error number
	move.w	d0,curr_err.w		; set current error number
	move.w	#1,flock.w		; tell vbl not to touch floppies
	move.w	$14(sp),ctrack.w	; save track# (0 .. 39 .. 79 ..)
	move.w	$16(sp),cside.w		; save side# (0	.. 1)
	move.w	$18(sp),ccount.w	; save sector count (1..spt)
	move.w	#retries,retrycnt.w	; setup retry count
	bsr	flopcmds		; do it
*--- pick a DSB:
	lea	dsb0.w,a1
* _acctim (last floppy access time) is used by rwabs:mediach() for a
* grace period for media change.  Previously the 200Hz timer was used,
* but this could cause problems (esp. in game s/w) if the 200Hz timer
* is disabled.  Since floppy write protect status (used to set media state)
* is checked by the floppy vblank handler, we now use the frame clock
* (updated EVERY vblank) for _acctim.  890206 kbad
* 
	move.w	cdev(a5),d0		; set last-access time for 'cdev'

	lea	_acctim(a5),a0
	move.l	_frclock(a5),(a0,d0.w)
	cmp.w	#1,_nflops(a5)		; if (nflops == 1) set other time, too
*
	move.l	_frclock(a5),4(a0)	; set last-accessed time for floppy 1
flopfail:
	moveq	#m_unsure,d0		; disk change mode = UNSURE
	movem.l	regsave(a5),d3-d7/a3-a6	; restore C registers
	move.w	curr_err.w,d0		; get current error number
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
	bra	flopcmds		; (without verify...)
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
	bsr	flopcmds		; seek

* hseek1 - seek to 'd7' without verify
* hseek2 - seek to 'd7' without verify, keep current error number
*
* Returns:	NE on seek failure ("cannot happen"?)
*		EQ if seek wins
*
* Uses:		d7, d6, ...
* Jumps-to:	flopcmds
* Called-by:	_flopfmt, _flopini
	bsr	wdiskctl
	move.w	#$10,d6			; execute "seek" command
	move.w	ctrack(a5),d7		;  1770's data register


*+
	bne	go2trr			; return error on seek failure
	move.w	ctrack(a5),dcurtrack(a1) ; update current track number
	and.b	#$18,d7			; check	for RNF, CRC_error, lost_data
.if HI_DEN
	move.w	#1,go2count		; init hi-den retry count
go2retry:

.endif
	move.w	#e_seek,curr_err	; set "seek error"
	move.w	#datareg,(a6)		; set destination track# in
	move.w	ctrack.w,d7		;  1770's data register
* Falls-into:	flopcmds
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
	move.w	d0,denselect		; write back new value
	move.w	d0,denselect
	bsr	restore			; try again, but restore first.
	bra	go2retry
	and.b	#3,d0			; OR into command
	or.b	d0,d6
* restore - home head
* bit is 1.  It doesn't actually read anything.
*-
restore:
	clr.w	d6			; $00 = 1770 "restore" command
	bsr	flopcmds		; do restore
	bne	res_r			; punt on timeout
	btst	#2,d7			; test TRK00 bit
	eor	#$04,ccr		; flip Z bit (return NE if bit is zero)
	bne	res_r			; punt if didn't win
	move.l	#timeout,d7		; setup	timeout	count (assume short)
.if (QD == 0)
rtmap:	dc.b	1,1,0,0			; see _floprate for mode on this
.else
rtmap:	dc.b	1,1,1,1			; QD table: gives 6ms at HD, 3ms at QD
	move.l	#ltimeout,d7		; extra timeout for motor startup

flopcmds:
flopc1:	subq.l	#1,d7			; timeout?
	beq	flopcto			; (yes,	reset and return failure)

.if HI_DEN
; if hi-den, remap the seek rate
	tst.w	ddenflags(a1)
	beq	nomap
	lea	rtmap,a0		; (MAS has PC-relative bugs)
	move.b	(a0,d0.w),d0		; remap the rate
	moveq	#1,d6			; and return NE

	or.b	d0,d6			; OR the rate into the command
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
	move.w	#15,d7			; wait for 1770	to stop	convulsing
r1770:	dbra	d7,r1770		; (short delay loop)
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
	clr.w	deselflg(a5)		; floppies NOT deselected
	move.w	cdev(a5),d0		; get device number
	rts
.endif
	or.w	cside(a5),d0		; or-in	side number (bit 0)
*+
* reset1770 - reset disk controller after a catastrophe
* Passed:	nothing
* Returns:	nothing
* Uses:		d7
*-
reset1770:
	clr.b	tmpdma(a5)		; zero bits 24..32 of target DMA addr
	move.w	#cmdreg,(a6)		; execute 1770 "reset" command
	move.w	#$d0,d7
	bsr	wdiskctl
.if TT
	move.w	csect(a5),d7		;	caller's parameters
	move.w	#$0114,d0		; 25 * 1.6us > 32us
	move.b	cdma+3(a5),dmalow(a5)	; setup	DMA chip's DMA pointer
	move.b	cdma+2(a5),dmamid(a5)
	move.b	cdma+1(a5),dmahigh(a5)
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

wdiskct6:				* write	d6 to diskctl
	move.w	dcurtrack(a1),d7	;	from current track number
	bsr	wdiskctl
	bra	rwdelay			;	delay and return
*--- alternate entry point: setup R/W parameters on 1770
wdiskctl:				* write	d7 to diskctl
	move.w	#secreg,(a6)		; setup	requested sector_number	from
	move.w	csect.w,d7		;	caller's parameters
	bra	rwdelay			;	delay and return
	move.b	cdma+3.w,dmalow		; setup	DMA chip's DMA pointer
rdiskct7:				* read diskctl into d7
	move.b	cdma+1.w,dmahigh
	rts
	bra	rwdelay			;	delay and return

rdiskctl:				* read diskctl into d0
* setporta - set floppy	select bits in PORT A on the sound chip
	move.w	diskctl,d0		;	read it
* Uses:		d1
	move	sr,-(sp)		; save flags
	move.w	d7,-(sp)		; save counter register
	move.w	#$20,d7			; 0x20 seems about right...
rwdly1:	dbra	d7,rwdly1		; busy-loop: give 1770 time to settle
	move.w	(sp)+,d7		; restore register, flags, and return
	move	(sp)+,sr
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
*+
* change - check to see if the "right" floppy has been inserted
	lea	_diskmode(a5),a0	; a0 -> disk mode table
*	$10(sp) - dev.W (device#)
	move.w	cdev(a5),d0		; d0.w = drive# (index into table)
	move.b	(sp)+,(a0,d0.w)		; set drive's mode
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
*	00	 6 ms
*	01	12 ms
*	02	 2 ms
*	03	 3 ms
	move.w	#e_insert,-(sp)		; push "INSERT_A_DISK" error number
	clr.l	(a0)+			; so the grace period in mediach
	clr.l	(a0)			; is always expired.
setdmode:
	lea	_diskmode.w,a0		; a0 -> disk mode table
	move.b	d0,-(sp)		; (save mode)
	lea.l	dsb0,a0			; get dsb0 first
	cmp.w	#1,_nflops		; one floppy?
	beq.s	rate1			; yes.
	lea.l	dsb1,a0			; no - use dsb1
rate1:	move.w	dseekrt(a0),d0		; get the old rate
	rts

	beq.s	ratedone		; yes
	move.w	d1,dseekrt(a0)		; no - do change it.
*	DRIVE	RAM TOS		11/20/85	4/22/87
*	  A	 6cb		  a09		  a4f
*	  B	 6cf		  a0d		  a53
*
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
*	lea	_wpstatus(a5),a0
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
*	move.w	_wpstatus(a5),d0
*	or.w	d0,_wplatch(a5)	; (catch WP transitions)
	rts

getspinup:
.if HI_DEN
	tst.b	dspinflag(a1)		; return 0 or -1, not the flag itself.

* wrfast - the buffer address is at 8(sp), count at $18(sp)
* Change the pointer and do the copy.

wrfast:	cmp.l	#MAXACSI,8(sp)
	bcs	undone
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
skewtbl:	ds.l	1		: pointer to skew table if interlv=-1
	move.l	_frb,8(sp)		; actual DMA to _FRB
tmpdma:		ds.l	1		; temp for hardware DMA image
	move.w	#1,fastcnt		; count is one sector
	rts

*
* routine to get the _FRB cookie if there is one (see cookie jar spec)
*
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
	bss
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
