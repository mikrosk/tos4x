.super
******************* Revision Control System *****************************
*
* $Author: apratt $
* =======================================================================
*
* $Date: 90/08/03 13:22:48 $
* =======================================================================
*
* $Locker:  $
* =======================================================================
*
* $Log: dmaread.s,v $
* Revision 1.8  90/08/03  13:22:48  apratt
* TTOS FINAL RELEASE
*
* Revision 1.7  90/03/06  16:09:16  apratt
* Moved .globl _resetscsi into the TT conditional; otherwise
* MAS thinks it's external, even though it's never used!
* 
* Revision 1.6  90/03/02  17:46:34  apratt
* This rev is the source for the 3/1/90 ROM.
* 
* Revision 1.5  90/03/01  17:27:00  apratt
* Checkin of Minna's changes, including adding better spin-up delays
* and the dmawrite call.
* 
* Revision 1.4  89/09/22  16:42:55  apratt
* THIS VERSION REQUIRES TURBO C'S "MAS" ASSEMBLER
* No functional changes from previous revision, which is the last to
* require Alcyon's AS68 assembler.
* 
* Revision 1.3  89/09/07  16:30:02  apratt
* Added delay after (potentially) resetting ACSI DMA chip; see SLOWACSI
* code in flop.s.
* 
* Revision 1.2  89/08/25  16:49:18  apratt
* Moved lastacstm from text seg to bss.
* 
* Revision 1.1  89/08/25  16:45:32  apratt
* Initial revision
* 
*
* =======================================================================
*
* $Revision: 1.8 $
* =======================================================================
*
* $Source: /u2/MRS/osrevisions/bios/dmaread.b,v $
* =======================================================================
*
*************************************************************************

* TT equate is in switches.s

.include "switches.s"

;+
; DMAREAD(), DMAWRITE() - 
;	New XBIOS calls to read from or write to hard disk on the
; ACSI or SCSI bus.  This is a low-level read/write which does not
; do a lot of checking.  Amount of data requested on each ACSI read
; or write _must_ be smaller than or equal to 254 sectors.  On SCSI,
; all I/O are done by handshaking.
;
; Jul-24-1989	ml.	Started this from AHDI 3.50 of Jul 24 1989.
; Aug-23-1989	ml.	Added in code to do hand-shake I/O, instead of
;			DMA.
; Dec-11-1989	ml.	Adjusted timeouts.
; Feb-08-1990	ml.	Updated according to corrections made to the
;			TT driver (DRIVER.PRG v3.63)
;			Renamed as dmarw() after adding code to handle
;			writes also.
; Feb-28-1990	ml.	Split dmarw() to become dmaread() and dmawrite()
;			as requested by AKP.  Modified timeout handling.
;			If system was up for less than UPTIME clicks, use
;			UPTIME as timeout counter rather than the regular
;			SC?TMOUT value.
; Mar-02-1990	ml.	Undid (again?!!) modifications made since Feb 28.
;			Will use regular SC?TMOUT values.  Bios will keep
;			calling _dmaread() at boot time until the drive
;			responses, Bios' timeout count expires, or when 
;			Bios receive a quit message from the user.
;
;-

.globl	_dmaread
.globl	_dmawrite


flock	equ	$43e		; FIFO lock variable
_hz_200	equ	$4ba		; system 200hz timer
READ	equ	$08		; opcode for Read
WRITE	equ	$0a		; opcode for Write
NCMD	equ	6		; normal command length (6 bytes)
MAXSCSI	equ	15		; highest SCSI unit#
MAXACSI	equ	7		; highest ACSI unit#
EUNDEV	equ	(-15)		; error code for unknown device
EREADF	equ	(-11)		; error code for read fault
EWRITF	equ	(-10)		; error code for write fault


;+
; Declarations
;-
.bss
_cmdblk:	ds.b	10	; command block
lastacstm:	ds.l	1	; controller last accessed time
cachexst:	ds.b	1	; 0: no cache	1: cache exists
rwflag:		ds.b	1	; 0: read	1: write
.even

.text

;+
; dmaread() - read from a DMA device.
; dmawrite() - write to a DMA device.
;
; LONG	sectnum		$4(sp).l
; WORD	count		$8(sp).w
; BYTE	*buf;		$a(sp).l	$b(sp)=high $c(sp)=mid $d(sp)=low
; WORD	pdev;		$e(sp).w
;
; Returns 0 for success.
; Returns a negative number for failure: 
;	EUNDEV (-15L) for unknown device (bad dev number)
;	EREADF (-11L) for read failure
;	EWRITF (-10L) for write failure
;	-1L for timed-out
;
; Comments:
;	Right now, only ACSI and SCSI devices are supported.
;-
	.globl	_dmaread
_dmaread:
	move.b	#0,rwflag		; rwflag = 0 => a read
	move.w	#READ,d1		; d1 = opcode for READ
	bra.b	dmarw
	
	.globl	_dmawrite
_dmawrite:
	move.b	#1,rwflag		; rwflag = 1 => a write
	move.w	#WRITE,d1		; d1 = opcode for WRITE
	
dmarw:	moveq	#EUNDEV,d0		; assume it's an unknown device

.ifeq TT
	cmpi.w	#MAXACSI,$e(sp)		; unit# > ACSI unit# 0-7?
.else
	cmpi.w	#MAXSCSI,$e(sp)		; unit# > SCSI unit# 8-15?
.endc
	bhi.b	rwend			; if so, return with error

	lea	_cmdblk,a0		; a0 -> beginning of command block
	move.b	d1,(a0)+		; byte 0 = opcode
	move.b	5(sp),(a0)+		; byte 1 = msb of logical block addr
	move.b	6(sp),(a0)+		; byte 2 = logical block addr
	move.b	7(sp),(a0)+		; byte 3 = lsb of logical block addr
	move.b	9(sp),(a0)+		; byte 4 = transfer length (in blocks)
	clr.b	(a0)			; byte 5 = control byte
	move.w	$e(sp),d0		; d0 = physical unit number
	moveq	#0,d1			; clear d1
	move.w	8(sp),d1		; d1 = transfer length (in bytes)
	lsl.l	#8,d1			;    = # blocks * 512
	add.l	d1,d1
	moveq	#NCMD,d2		; d2 = length of command
	movea.l	$a(sp),a0		; a0 = read buffer
	tst.b	rwflag			; read or write?
	bne.b	rw0			; it's a write
	bsr	_dorcmd			; send a receive data command
	bra.b	rw1
rw0:	bsr	_dowcmd			; send a write data command

rw1:	
.ifne	TT
	move.w	sr,-(sp)		; go to IPL 7
	ori	#$700,sr		; no interrupts right now please
	movec	cacr,d1			; d1 = (cache control register)
	ori.w	#$0808,d1		; dump both the I and D cache
	movec	d1,cacr			; update cache control register
	move.w	(sp)+,sr		; restore interrupt state
.endc
	tst.w	d0			; successful?
	beq.b	rwend			; if no error, return
	bmi.b	rwend			; if timed-out, return
					; else, there's an error
	moveq	#EREADF,d0		; assume it's a read error
	tst.b	rwflag			; read or write?
	beq.b	rwend			; if read, done
	moveq	#EWRITF,d0		; else, it's a write error
rwend:	rts


;+
; dorcmd() - send a command which will receive data from the target
;
; Passed:
;	d0.w = physical unit number
;	d1.l = transfer length (in bytes)
;	d2.w = command length (NCMD or LCMD)
;	a0.l = buffer address
;-
_dorcmd:
.ifne TT
	cmp.w	#MAXACSI,d0		; unit# > ACSI unit# 0 - 7?
	bls.b	rcacsi			; if not, it's an ACSI device
	bsr	_rcvscsi		; else, it's a SCSI device
	rts
.endc
rcacsi:	bsr	_rcvacsi		; it's an ACSI device
	rts


;+
; dowcmd() - send a command which will write data to the target
;
; Passed:
;	d0.w = physical unit number
;	d1.l = transfer length (in bytes)
;	d2.w = command length (NCMD or LCMD)
;	a0.l = buffer address
;-
_dowcmd:
.ifne	TT
	cmp.w	#MAXACSI,d0		; unit# > ACSI unit# 0 - 7?
	bls.b	wracsi			; if not, it's an ACSI device
	bsr	_wrtscsi		; else, it's a SCSI device
	rts
.endc
wracsi:	bsr	_wrtacsi		; it's an ACSI device
	rts

	

;+++++++++++++++++++++++++++++++;
;				;
;	ACSI specific		;
;				;
;+++++++++++++++++++++++++++++++;

;+
;  Hardware definitions for ACSI
;-
WDC		equ	$ffff8604
WDL		equ	$ffff8606
WDCWDL		equ	WDC		; used for long writes
XWDL		equ	WDL-WDC		; offset from wdc to wdl

DMAHI		equ	$ffff8609
DMAMID		equ	DMAHI+2
DMALOW		equ	DMAMID+2
GPIP		equ	$fffffa01


;+
;  Tunable (delay) values for ACSI
;-
ACLTMOUT	equ	600		; long-timeout (3 s)
ACSTMOUT	equ	20		; short-timeout (100 ms)


;+
; LONG _qdone() - Wait for command byte handshake
; LONG _fdone() - Wait for operation complete
; Passed:	nothing
;
; Returns:	EQ: no timeout
;		MI: timeout condition
;
; Uses:		D0
;
;-
_fdone:	move.l	#ACLTMOUT,d0
	bra	qd0

_qdone:	move.l	#ACSTMOUT,d0

qd0:	add.l	_hz_200,d0
qd1:	cmp.l	_hz_200,d0		; timeout?
	bcs	qdq			; (i give up, return NE)
	btst	#5,GPIP			; interrupt?
	bne	qd1			; (not yet)

	moveq	#0,d0			; return EQ (no timeout)
	rts

qdq:	moveq	#-1,d0
	rts


;+
; Wait for end of SASI command
;
; Passed:	d1 value to be written to wdl
;
; Returns:	EQ: success (error code in D0.W)
;		MI: timeout (-1 in D0.W)
;		NE: failure (SASI error code in D0.W)
;
; Uses:		d0
;-
_endcmd:
	bsr	_fdone			; wait for operation complete
	bmi	endce			; (timed-out, so complain)

.ifne	TT				; dump D cache
	move.w	sr,-(sp)		; go to IPL 7
	ori.w	#$700,sr		; no interrupts right now kudasai
	movec	cacr,d0			; d0 = (cache control register)
	ori.w	#$800,d0		; dump the D cache
	movec	d0,cacr			; update cache control register
	move.w	(sp)+,sr		; restore interrupt state
.endc

	move.w	d1,WDL
	move.w	WDC,d0			; get the result
	and.w	#$00ff,d0		; (clean it up), if non-zero should
					; do a ReadSense command to learn more
endce:	move.l	_hz_200,lastacstm	; update controller last accessed time
	addq.l	#2,lastacstm		; lastacstm = _hz_200 + 2;
	rts				


;+
;  Handle command timeout;
;  Unlock DMA chip and return completion status;
;-
_hdone:	move.w	#$80,WDL	; Landon's code seems to presume we put 
				;  $80 there
	clr	flock		; NOW, signal that we are done
	rts


;+
; delay()
;	5 - 10ms kludge delay for message byte sent back by controller.
;-
_delay:	move.l	d0,-(sp)		; preserve d0
	move.l	lastacstm,d0		; d0 = controller last accessed time
wait:	cmp.l	_hz_200,d0		; while (_hz_200 <= lastacstm)
	bcc	wait			;	wait()
	move.l	(sp)+,d0		; restore d0
	rts


;+
; rcvacsi() - send a ACSI command which receives data from target.
;
; Passed:
;	d0.w = physical unit number
;	d1.l = transfer length (in bytes)
;	d2.w = command length (NCMD or LCMD)
;	a0.l = buffer address
;
; Comments:
;	This routine assumes that if you are transferring more than 16
; bytes, and a multiple of 16 bytes.
;-
_rcvacsi:
	st	flock			; lock FIFO
	bsr	_delay			; delay if necessary
	movea.l	#WDC,a1			; a1 = pointer to DMA chip

	bsr	setadma			; set DMA pointer
	move.w	#$190,XWDL(a1)	;WDL	; toggle DMA chip to direction
	bsr	rstdelay		; delay
	move.w	#$090,XWDL(a1)	;WDL	;  for receiving data
	bsr	rstdelay		; delay
	bsr	setacnt			; set DMA count

	lea	_cmdblk,a0		; a0 = address of command block
	moveq	#0,d1			; direction of DMA is IN
	bsr	sblkacsi		; send the command block
raend:	bra	_hdone			; cleanup after IRQ


;+
; wrtacsi() - send an ACSI command which will write data to the target
;
; Passed:
;	d0.w = physical unit number
;	d1.l = transfer length (in bytes)
;	d2.w = command length (NCMD or LCMD)
;	a0.l = buffer address
;-
_wrtacsi:
	st	flock			; lock FIFO
	bsr	_delay
	movea.l	#WDC,a1			; a1 = pointer to DMA chip

	bsr	setadma			; set DMA pointer
	move.w	#$90,XWDL(a1)	;WDL	; toggle DMA chip for "send"
	bsr	rstdelay		; delay 
	move.w	#$190,XWDL(a1)	;WDL
	bsr	rstdelay		; delay
	bsr	setacnt			; set DMA count
	
	move.l	#$0100,d1		; d1 = direction of DMA is OUT
	bsr	sblkacsi		; send the command block

waend:	bra	_hdone			; cleanup after IRQ


;+
; sblkacsi() - send command block
;
; Passed:
;	d0.w = physical unit number
;	d1.l = direction of DMA ($0000 for IN or $0100 for OUT)
;	d2.w = command length (NCMD or LCMD)
;	a1.l = pointer to DMA chip
;
; Returns:
;	d0.l =  0 if successful
;	d0.l = -1 if timeout
;
; Trashes:
;	d0, d1, d2, a2
;-
sblkacsi:
	move.b	#$88,d1			; next byte is the opcode
	move.w	d1,XWDL(a1)	;WDL

	move.b	#$8a,d1			; following bytes are operands
	lea	_cmdblk,a2		; a2 = address of command block
					; integrate unit # into cmd blk
	lsl.b	#5,d0			; shift unit number into place
	or.b	d0,(a2)			; first command byte = unit # | opcode
					; control byte is sent seperately
	subq.w	#2,d2			; and dbra likes one less 
sa1:	swap	d1			; d1.hw = operand
	move.b	(a2)+,d1		; d1.lw = tells controller next byte
	swap	d1			;	  is an operand
	move.l	d1,(a1)		;WDCWDL
	bsr	_qdone
	bmi	sbaend			; if timeout, returns
	dbra	d2,sa1			; else send rest of command block

	move.w	d1,XWDL(a1)	;WDL	; get ready to send control byte
	move.b	#0,d1			; signal sending control byte
	swap	d1			; d1.hw = control byte
	move.b	(a2),d1			; d1.lw = tells controller it's end
	swap	d1			;	  of command
	move.l	d1,(a1)			; send it

	move.b	#$8a,d1			; d1 = wdl value
	bsr	_endcmd			; wait for command completion
sbaend: rts				; heading home


;+
; setadma() - set the ACSI DMA pointer
;
; Passed:
;	a0.l = buffer address
;-
setadma:
	move.l	a0,-(sp)		; move it on stack
	move.b	3(sp),DMALOW		; set low-byte of address
	move.b	2(sp),DMAMID		; set mid-byte of address
	move.b	1(sp),DMAHI		; set high-byte of address
	addq.l	#4,sp			; clean up stack
	rts


;+
; setacnt() - set the ACSI DMA counter
;
; Passed:
;	d1.l = count (in bytes)
;	a1.l = pointer to DMA chip
;-
setacnt:
	move.l	d1,-(sp)		; save transfer length (in bytes)
	lsr.l	#8,d1			; find transfer length (in blocks)
	add.l	d1,d1			; d1 >>= 9 = transfer len (in blocks)
	move.w	d1,(a1)		;WDC	; set DMA count
	move.l	(sp)+,d1		; restore transfer length (in bytes)
sacend:	rts


;+
; Rstdelay()
;	After talking to the DMA chip in a way that may reset it, 
; we need a 8 8Mhz clocks (ie. 1 microsec) delay, before we can
; talk to the chip again.
;-
rstdelay:
	tst.b	GPIP			; delay for 1 microsec
	tst.b	GPIP			; this amounts to 16 16Mhz clocks
	tst.b	GPIP
	tst.b	GPIP
	rts


.ifne	TT

;+++++++++++++++++++++++++++++++;
;				;
;	SCSI specific		;
;				;
;+++++++++++++++++++++++++++++++;

.globl	_resetscsi

; Definitions
REGBASE	equ	1	; most are on odd part of data bus
REGSTEP	equ	2	; most registers are on word boundaries


; SCSI Interface (NCR 5380) for READ operations
bSCSI	equ	$FFFF8780+REGBASE
SCSIDB	equ	bSCSI+($00*REGSTEP)	; current SCSI data bus
SCSIICR	equ	bSCSI+($01*REGSTEP)	; initiator command register
SCSIMR	equ	bSCSI+($02*REGSTEP)	; mode register
SCSITCR	equ	bSCSI+($03*REGSTEP)	; target command register
SCSICR	equ	bSCSI+($04*REGSTEP)	; current SCSI control register
SCSIDSR	equ	bSCSI+($05*REGSTEP)	; DMA status register
SCSIIDR	equ	bSCSI+($06*REGSTEP)	; input data register
SCSIREI	equ	bSCSI+($07*REGSTEP)	; reset error / interrupt

; SCSI Interface (NCR 5380) for WRITE operations
SCSIODR	equ	bSCSI+($00*REGSTEP)	; output data register
;SCSIICR	bSCSI+($01*REGSTEP)	; initiator command register
;SCSIMR		bSCSI+($02*REGSTEP)	; mode register
;SCSITCR	bSCSI+($03*REGSTEP)	; target command register
SCSIISR	equ	bSCSI+($04*REGSTEP)	; ID select register
SCSIDS	equ	bSCSI+($05*REGSTEP)	; start DMA send
SCSIDTR	equ	bSCSI+($06*REGSTEP)	; start DMS target receive
SCSIDIR	equ	bSCSI+($07*REGSTEP)	; start DMA initiator receive

; SCSI DMA Controller
SDMACTL		equ	$FFFF8714	; WORD

;+
; Tunable (delay) values (in number of _hz_200 ticks) for SCSI
;-
SCLTMOUT	equ	201		; long-timeout (at least 1000 ms)
SCSTMOUT	equ	51		; short-timeout (at least 250 ms)

;+
; rcvscsi() - send a SCSI command which receives data back.
;
; Passed:
;	d0.w = physical unit number
;	d1.l = transfer length (in bytes)
;	d2.w = command length (NCMD or LCMD)
;	a0.l = buffer address
;-
_rcvscsi:
	move.l	a0,-(sp)		; save buffer address
	andi.w	#7,d0			; mask off the flags to get unit num
	bsr	sblkscsi		; send command block
	movea.l	(sp)+,a0		; restore buffer address
	tst.w	d0			; successful?
	bmi.b	rsend			; if not successful, return

	movea.l	a0,a1			; a1 -> buffer to read into
	movea.l	#bSCSI,a2		; a2 -> 5380
	move.b	#1,SCSITCR		; set data in phase
	move.b	SCSIREI,d0		; clear potential interrupt

rs0:	bsr	setscstmout		; set up short timeout
	bsr	w4req			; wait for REQ to come
	bmi.b	rsend			; if timed out, returns
	btst	#3,5*REGSTEP(a2)	; still in data in phase?
	beq	w4stat			; no, go get status
	move.b	(a2),(a1)+		; read the data byte
	bsr	doack
	bra.b	rs0			; do next byte
rsend:	rts


;+
; wrtscsi() - send a SCSI command which will write data to the target
;
; Passed:
;	d0.w = physical unit number
;	d1.l = transfer length (in bytes)
;	d2.w = command length (NCMD or LCMD)
;	a0.l = buffer address
;-
_wrtscsi:
	andi.w	#7,d0			; mask off the flags to get unit num
	move.l	a0,-(sp)		; save beginning buffer address
	move.w	d2,-(sp)		; save command length
	bsr	sblkscsi		; send command block
	move.w	(sp)+,d2		; restore command length
	move.l	(sp)+,a0		; a0 = where DMA ends
	tst.w	d0			; successful?
	bmi.b	wsend			; if failure, return

	movea.l	a0,a1			; a1 -> buffer to write from
	movea.l	#bSCSI,a2		; a2 -> 5380
	move.b	#0,SCSITCR		; set data out phase
	move.b	SCSIREI,d0		; clear potential interrupt

ws0:	bsr	setscstmout
	bsr	w4req			; wait for REQ to come
	bmi.b	wsend			; if timed out, returns
	btst	#3,5*REGSTEP(a2)	; still in data out phase?
	beq	w4stat			; no, go get status
	move.b	(a1)+,(a2)		; write the data byte
	bsr	doack
	bra.b	ws0			; do next byte
wsend:	rts



;+
; sblkscsi() - send command block
;
; Passed:
;	d0.w = physical unit number
;	d2.w = command length (NCMD or LCMD)
;
; Returns:
;	d0.l =  0 if successful
;	d0.l = -1 if timeout
;-
sblkscsi:
	move.l	d2,-(sp)		; save command length
	move.w	d0,-(sp)		; physical unit #
	bsr	selscsi			; select the unit
	addq	#2,sp			; clean up stack
	move.l	(sp)+,d2		; restore command length
	tst.w	d0			; selection successful?
	bmi.b	sbsend			; if timed out, return
					; else proceed
	move.b	#2,SCSITCR		; assert C/D
	move.b	#1,SCSIICR		; assert data bus

	lea	_cmdblk,a1		; a1 -> command block
	subq.w	#1,d2			; dbra likes one less

	bsr	setscstmout		; set a short timeout
ss1:	move.b	(a1)+,d0		; d0.b = byte to be sent
	bsr	hshake			; write that byte
	tst.w	d0
	bmi.b	sbsend			; if timed-out, returns
	dbra	d2,ss1			; until whole command block is sent
	moveq	#0,d0			; all operations successful
sbsend: rts				; heading home


;+
; BOOLEAN selscsi(SCSIUnit) 
; WORD SCSIUnit;
;-
selscsi:
	bsr	setscstmout		; set up a short timeout
sels0:	btst	#6,SCSICR		; STILL busy from last time?
	beq.b	sels1			; if not, it's available
	cmp.l	(a0),d1			; timeout?
	bhi.b	sels0			; not yet, wait some more
	bra.b	sels4			; else, return error

sels1:	move.b	#0,SCSITCR		; data out phase
	move.b	#0,SCSIISR		; no interrupt from selection
	move.b	#$0c,SCSIICR		; assert BSY and SEL
; set dest SCSI IDs
	clr.w	d0
	move.w	4(sp),d1		; get the SCSI unit desired
	bset	d1,d0			; set the appropriate bit
	move.b	d0,SCSIODR		; (real code would set ours too)

	move.b	#$0d,SCSIICR		; assert BUSY, SEL and data bus
	andi.b	#$FE,SCSIMR		; clear arbitrate bit
	andi.b	#$F7,SCSIICR		; clear BUSY

* there must be two "deskew delays" here, but that's only 100ns total...
* the following computations take at least that long before we read
* SCSICR again.

	bsr	setscstmout		; use short timeout
sels3:	btst	#6,SCSICR		; wait for bus to be busy
	bne.b	sels5
	cmp.l	(a0),d1
	bhi.b	sels3

sels4:	moveq	#-1,d0			; time out
	bra.b	sels6
	
sels5:	clr.w	d0			; selection successful
sels6:	move.b	#$0,SCSIICR		; clear SEL and data bus assertion
	rts


;+
; w4stat - wait for status byte and message byte.
;
; Returns:
;	d0.l = returned status or timeout error
;-
w4stat:	bsr	setscstmout		; set up time-out for REQ and ACK
	move.b	#3,SCSITCR		; status in phase
	move.b	SCSIREI,d0		; clear potential interrupt

	bsr	w4req			; wait for status byte
	bmi.b	w4iend			; if timed-out, returns
	moveq	#0,d0			; clear d0
	move.b	SCSIDB,d0		; get the status byte
	bsr	setscstmout		; set up time-out for REQ and ACK
	move.l	d0,-(sp)		; save the status byte
	bsr	doack			; signal that status byte is here
	tst.w	d0			; timed-out?
	beq.b	wst4			; if not, wait for message byte

wst3:	addq.l	#4,sp			; else clean up stack
	bra.b	w4iend			; and return

wst4:	bsr	setscstmout		; set up timeout for REQ and ACK
	bsr	w4req			; wait for message byte
	bmi.b	wst3			; if timed-out, returns

	move.b	SCSIDB,d0		; get and ignore message byte
	bsr	doack			; signal that message byte is here
	tst.w	d0			; timed-out?
	bmi.b	wst3			; if so, return timeout
w4i5:	move.l	(sp)+,d0		; recall the status byte
w4iend:	rts


;+
; w4req() - wait for REQ to come
;
; Passed:
;	d1.l = expiration time
;	a0.l = address of _hz_200
;
; Returns:
;	 0 - if successful
;	-1 - times out
;-
w4req:
wr0:	btst	#5,SCSICR		; waiting for REQ to come
	bne.b	wr1			; if REQ comes, done
	cmp.l	(a0),d1			; time's up?
	bhi.b	wr0			; if not, wait some more
	moveq	#-1,d0			; else, returns timed out
	bra.b	w4rend
wr1:	moveq	#0,d0			; returns successful
w4rend:	rts


;+
; doack() - assert ACK
;
; Passed:
;	d1.l = expiration time
;	a0.l = address of _hz_200
;
; Returns:
;	 0 - if successful
;	-1 - times out
;-
doack:	ori.b	#$11,SCSIICR		; assert ACK (and data bus)
da0:	btst	#5,SCSICR		; wait for REQ to go away
	beq.b	da1			; if REQ goes away, done
	cmp.l	(a0),d1			; time's up?
	bhi.b	da0			; if not, wait some more
	moveq	#-1,d0			; else returns timed out
	bra.b	doaend
da1:	moveq	#0,d0			; returns successful
doaend:	andi.b	#$ef,SCSIICR		; clear ACK
	rts


;+
; hshake() - hand shake a byte over to the controller
;
; Passed:
;	d0.b = byte to be handed over
;	d1.l = expiration time
;	a0.l = address of _hz_200
;
; Returns:
;	Whatever w4req() or doack() returns, which is:
;		 0 - if successful
;		-1 - times out
;-
hshake:	move.w	d0,-(sp)		; preserve d0.w
	bsr	w4req			; wait for REQ to come
	bmi.b	hsend			; if timed out, returns
	move.b	1(sp),SCSIDB		; write a byte out to data bus
	bsr	doack			; assert ACK
hsend:	addq.l	#2,sp			; clean up stack
	rts


*+
* VOID resetscsi();
*-

_resetscsi:
	move.b	#$80,SCSIICR	; assert RST
	bsr	setscstmout	; wait (at least) 250 ms
rst0:	cmp.l	(a0),d1
	bhi.b	rst0
	move.b	#$00,SCSIICR
	bsr	setscltmout	; wait (at least) 1000 ms
rst1:	cmp.l	(a0),d1
	bhi.b	rst1
	rts


;+
; setscstmout - set up a timeout count for the SCSI for SCSTMOUT ticks
;
; Returns:
;	a0.l = address of _hz_200 clock
;	d1.l = expiration time
;-
setscstmout:
	movea.l	#_hz_200,a0	; a0 -> 200 hz clock
	move.l	#SCSTMOUT,d1	; d0 = SCSTMOUT _hz_200 clicks
	add.l	(a0),d1		; d0 = curr time + # clicks to wait
	rts


;+
; setscltmout - set up a timeout count for the SCSI for SCLTMOUT long
;
; Returns:
;	a0.l = address of _hz_200 clock
;	d1.l = expiration time
;-
setscltmout:
	movea.l	#_hz_200,a0	; a0 -> 200 hz clock
	move.l	#SCLTMOUT,d1	; d0 = SCLTMOUT _hz_200 clicks
	add.l	(a0),d1		; d0 = curr time + # clicks to wait
	rts
	rts
.endc


