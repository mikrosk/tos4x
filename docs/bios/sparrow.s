bSCSI		equ	$88	; base of SCSI bus

; SCSI Interface (NCR 5380) for READ operations
SCSIDB		equ	$88+0	; SCSI data bus
SCSIICR		equ	$88+1	; initiator command register
SCSIMR		equ	$88+2	; mode register
SCSITCR		equ	$88+3	; target command register
SCSICR		equ	$88+4	; current SCSI control register
SCSIDSR		equ	$88+5	; DMA status register
SCSIIDR		equ	$88+6	; input data register
SCSIREI		equ	$88+7	; reset error / interrupt


; SCSI Interface (NCR 5380) for WRITE operations
SCSIODR		equ	$88+0	; output data register
;SCSIICR	equ	$88+1	; initiator command register
;SCSIMR		equ	$88+2	; mode register
;SCSITCR	equ	$88+3	; target command register
SCSIISR		equ	$88+4	; ID select register
SCSIDS		equ	$88+5	; start DMA send
SCSIDTR		equ	$88+6	; start DMA target receive
SCSIDIR		equ	$88+7	; start DMA initiator receive


;  Hardware definitions for ACSI DMA channel
WDC		equ	$ffff8604
WDL		equ	$ffff8606
WDCWDL		equ	WDC		; used for long writes
XWDL		equ	WDL-WDC		; offset from wdc to wdl

DMAHI		equ	$ffff8609
DMAMID		equ	DMAHI+2
DMALOW		equ	DMAMID+2
GPIP1		equ	$fffffa01


SCSIID		equ	6		; our (host) SCSI ID


; Macros to talk to the NCR5380 through the ACSI DMA chip

.macro	RSCSI	srcreg,dst	; read from specified register
	move.w	\srcreg,WDL
	move.w	WDC,\dst
.endm

.macro	WSCSI	val,dstreg	; write to specified register
	move.w	\dstreg,WDL
	move.w	\val,WDC
.endm

.macro	WSCSIi	val,dstreg	; write immediate data to specified register
	move.l	#((\val << 16)|(\dstreg)),WDCWDL
.endm


*+
* VOID resetscsi();
*-
	.globl	resetscsi
resetscsi:
	WSCSIi	$80,SCSIICR	; assert RST
	bsr	setscstmout	; wait (at least) 250 ms
.0:	cmp.l	(a0),d1
	bhi.s	.0
	WSCSIi	0,SCSIICR
	bsr	setscltmout	; wait (at least) 1000 ms
.1:	cmp.l	(a0),d1
	bhi.s	.1
	rts



*+
* Reset error/interrupt 
*-
resetint:
	RSCSI	#SCSIREI,d0
	rts
