.super
******************* Revision Control System *****************************
*
* $Author: apratt $
* =======================================================================
*
* $Date: 90/08/03 13:21:39 $
* =======================================================================
*
* $Locker:  $
* =======================================================================
*
* $Log: clock.s,v $
* Revision 2.9  90/08/03  13:21:39  apratt
* TTOS FINAL RELEASE
*
* Revision 2.8  90/08/01  13:10:44  apratt
* Fixed a bug: check didn't leave regs right when checksum was wrong,
* even though the read operation expected to be able to do the read
* anyway.
* 
* Revision 2.7  90/04/30  18:43:38  apratt
* Added NVMaccess call: see comments for details.
* 
* Revision 2.6  90/02/22  12:23:28  apratt
* Removed ".w" from _time and _date.
* 
* Revision 2.5  89/12/08  15:40:49  apratt
* Changed TT clock code to use bitfield instructions.
* Also fixes a bug: the minutes were set to half the correct value.
* 
* Revision 2.4  89/09/22  16:42:45  apratt
* THIS VERSION REQUIRES TURBO C'S "MAS" ASSEMBLER
* No functional changes from previous revision, which is the last to
* require Alcyon's AS68 assembler.
* 
* Revision 2.3  89/08/29  15:13:19  apratt
* Fixed TT clock code (I hope).
* 
* Revision 2.2  89/08/18  14:28:59  apratt
* Added TT clock code. Not extensively tested. Includes switch for TT,
* set to zero for not TT.
* 
* Revision 2.1  89/02/27  12:36:29  apratt
* *** TOS 1.4  FINAL RELEASE VERSION ***
* 
* Revision 1.4  89/02/27  12:35:02  apratt
* Blasted fatfinger again, in the no-bus-error case in clktest. Fixed.
* 
* Revision 1.3  89/02/17  11:55:46  apratt
* Fixed my fat fingers in clktest.  Also shortened by a few bytes.
* 
* Revision 1.2  89/02/06  13:45:40  apratt
* Added handling for bus error when accessing RTC (because TT has none).
* The handling is harmless for non-TT, so it's not conditional.
* 
* Revision 1.1  87/11/20  14:23:42  lozben
* Initial revision
* 
*
* =======================================================================
*
* $Revision: 2.9 $
* =======================================================================
*
* $Source: /u2/MRS/osrevisions/bios/clock.s,v $
* =======================================================================
*
*************************************************************************

*------------------------------------------------------------------------
*									:
*	RICOH RP5C15 Clock Chip Support					:
*	Copyright 1986 Atari Corp.					:
*	All Rights Reserved						:
*									:
*----									:
*  6-Jan-1987 lmd	Removed check for bus error in 'clktest'.	:
* 23-Dec-1986 lmd	Set '_date' and '_time' directly (without	:
*			calling GEMDOS).				:
* 11-Dec-1986 lmd	Hacked it some more.				:
* 28-Jan-1986 jwt	Hacked it up.					:
*									:
*------------------------------------------------------------------------

* TT equate moved to switches.s

.include "switches.s"

	.globl	clktest		; test for clock chip (returns CC/CS)
	.globl	_iclock		; clock setup
	.globl	_setclock	; setclock() BIOS call
	.globl	_getclock	; getclock() BIOS call
	.globl	_date,_time	; GEMDOS date and time variables

.ifeq TT

RTCBASE	equ	$fffffc20	; base address of RTC chip

*
*  Clock chip registers
*
RT01SEC	equ	$1		; 1-second counter
RT10SEC	equ	$3		; 10-second counter
RT01MIN	equ	$5		; 1-minute counter
RT10MIN	equ	$7		; 10-minute counter
RT01HR	equ	$9		; 1-hour counter
RT10HR	equ	$B		; 10-hour counter
RTDOW	equ	$D		; day of week
RT01DAY	equ	$F		; 1-day counter
RT10DAY	equ	$11		; 10-day counter
RT01MON	equ	$13		; 1-month counter
RT10MON	equ	$15		; 10-month counter
RT01YR	equ	$17		; 1-year counter
RT10YR	equ	$19		; 10-year counter
RTMODE	equ	$1B		; mode bits
RTTEST	equ	$1D		; test register (must be 0)
RTRES	equ	$1F		; reset register

READS	equ	13		; number of reads to do (up to RT10YR)


*
*  Offsets into read buffer;
*  They are in "reverse order" in a misguided
*  attempt to save bytes.  Sue me.
*
RD01SEC	equ	$c
RD10SEC	equ	$b
RD01MIN	equ	$a
RD10MIN	equ	$9
RD01HR	equ	$8
RD10HR	equ	$7
RDDOW	equ	$6		; day of week
RD01DAY	equ	$5
RD10DAY	equ	$4
RD01MON	equ	$3
RD10MON	equ	$2
RD01YR	equ	$1
RD10YR	equ	$0


    .text
*----------------
*
*  Initialize clock (at startup):
*    o  probe for clock chip
*    o  if no chip, return CS;
*    o  reset TEST register, set 16.384Khz CKOUT mode;
*    o  get date/time from chip;
*    o  if invalid date/time, return CS;
*    o  set GEMDOS date/time, return CC.
*
_iclock:
	bsr	clktest			; test for clock chip
	bcs	iclfai			; (not around)

*
*  Get clock chip's time
*  and set GEMDOS time from it.
*
	bsr	_getclock		; get chip's idea of the time
	cmp.l	#-1,d0			; bad time?
	beq	iclfai			; yes --- punt

	move.w	d0,_time		; set GEMDOS time
	swap	d0
	move.w	d0,_date		; set GEMDOS date

	moveq	#0,d0			; return "Ok fine"
	rts

iclfai:	moveq	#-1,d0			; return -1L (error)
	rts


*----------------
*
*  Quick "memory" test on useless timer registers will
*  tell us if the chip is alive or not.  A bus error
*  is also a good indication that the chip isn't around....
*
*    Returns:	a0 -> clock hardware base
*		CC: clock exists
*		CS: clock doesn't exist (bad RAM test)
*
*    Uses:	d0-d2/a0-a2
*
* Originally, this code didn't have the bus error handling; that
* was added 2/6/89 by AKP.  Don't know why the above comment
* refers to bus errors but doesn't implement them.
*
clktest:
	clr.l	a1
	move.w	#RTCBASE,a0		; a0 -> base of clock chip
	move.l	8(a1),d2		; save bus error vector
	move.l	sp,a2			; save stack pointer for cleaning up
	move.l	#clkerr,8(a1)		; write bus error vector
	move.b	#%1001,RTMODE(a0)	; set "alarm" bank
	move.l	d2,8(a1)		; no bus error - restore vector
	move.w	#$0a05,d0		; d0 = test pattern
	movep.w	d0,RT01MIN(a0)		; write two registers
	movep.w	RT01MIN(a0),d1		;   and read them back
	and.w	#$0f0f,d1		; clobber crufty bits
	cmp.w	d0,d1			; compare?
	bne	clkfai			; (no --- fail)
	move.b	#%0001,RT01SEC(a0)	; set 16.384Khz CKOUT mode
	move.b	#%1000,RTMODE(a0)	; set "normal" bank
	move.b	#0,RTTEST(a0)		; clobber test register
	rts				; return OK

clkerr:	move.l	a2,sp			; clean off the stack
	move.l	d2,8(a1)		; restore the bus error vector
clkfai:	or	#1,ccr			; set carry
	rts				; return "failure"




*----------------
*
*  Get clock chip date/time
*
*    Synopsis:	getclock()
*
*	Returns:	d0 = date in high word,
*			     time in low word,
*			     -1L if invalid date
*
*	Uses:		C registers
*
*  The clock must read the same twice in a row to be sure
*  that it didn't roll over during the read.  The date must
*  be checked to see if it's valid.  And so on...
*
_getclock:
	bsr	clktest			; test for clock-there
	bcs	gclfai			; punt on failure
	lea	read1.w,a1		; a1 -> clock data buffer
	lea	read2.w,a2		; a2 -> alternate clock data buffer
	bsr	readclk			; read clock into &a1

rdagn:	exg	a1,a2			; swap buffer pointers
	bsr	readclk			; read clock into &a1

	moveq	#READS-1,d0		; d0 = DBRA #bytes to compare
cmplup:	move.b	(a1,d0.w),d1		; get first byte
	cmp.b	(a2,d0.w),d1		; ... compare
	bne	rdagn			; re-read clock on mismatch
	dbra	d0,cmplup		; (compare all bytes)

*
*  Convert time to GEMDOS format
*
	moveq	#0,d0			; d0 = (RD10SEC*10 + RD1SEC) / 2
	move.b	RD10SEC(a1),d0
	mulu	#10,d0
	add.b	RD01SEC(a1),d0
	asr.w	#1,d0			; (DOS has stupid 2-second resolution)
	move.w	d0,d1

	moveq	#0,d0			; d0 = RD10MIN*10 + RD1MIN
	move.b	RD10MIN(a1),d0
	mulu	#10,d0
	add.b	RD01MIN(a1),d0
	asl.w	#5,d0			; time += d0 << 5
	add.w	d0,d1

	moveq	#0,d0			; d0 = RD10HDR*10 + RD1HR
	move.b	RD10HR(a1),d0
	mulu	#10,d0
	add.b	RD01HR(a1),d0
	asl.w	#8,d0
	asl.w	#3,d0
	add.w	d0,d1			; time += d0 << 11
	swap	d1			; swap time to high word (for now)

*
*  Convert date to GEMDOS format
*
	moveq	#0,d0			; d0 = RD10DAY*10 + RD01DAY
	move.b	RD10DAY(a1),d0
	mulu	#10,d0
	add.b	RD01DAY(a1),d0
	move	d0,d1			; date = d0

	moveq	#0,d0			; d0 = RD10MON*10 + RD01MON
	move.b	RD10MON(a1),d0
	mulu	#10,d0
	add.b	RD01MON(a1),d0
	asl.w	#5,d0
	add.w	d0,d1			; date += d0 << 5

	moveq	#0,d0			; d0 = RD10YR*10 + RD01YR
	move.b	RD10YR(a1),d0
	mulu	#10,d0
	add.b	RD01YR(a1),d0
	asl.w	#8,d0
	asl.w	#1,d0
	add.w	d0,d1			; date += d0 << 9

	swap	d1			; date into high word, time in lower
	move.l	d1,d0			; move to output register
	rts				; ... and return it


*----------------
*
*  readclk -- read READS bytes from clock
*
*    Passed:	a0 - RTCBASE
*		a1 - destination
*
*    Returns:	buffer at 'a1' filled-in with clock
*		    chip register values.
*
*    Uses:	d0-d2
*
readclk:
	moveq	#READS-1,d0		; d0 = count
	moveq	#RT01SEC,d1		; d1 = starting offset
rdlup:	move.b	0(a0,d1.w),d2		; get byte
	and.b	#%00001111,d2		; keep lower nibble
	move.b	d2,(a1,d0.w)		; shove into buffer
	addq	#2,d1			; bump offset
	dbra	d0,rdlup		; loop for more bytes
	rts

gclfai:	moveq	#-1,d0			; return -1L on failure
	rts


*----------------
*
*  Set clock date and time
*
*    _setclock(datetime)
*
*    Passed:	date in high word, time in low word
*
*    Returns:	0, success
*		-1, failure
*
*    Uses:	C registers
*
_setclock:
	bsr	clktest			; test for clock chip
	bcs	sclerr			; punt if chip doesn't exist
	lea	read1.w,a1		; a1 -> buffer for clock data to write

*
*  Convert time to chip format
*
	move.w	6(sp),d1		; d1 = GEMDOS format time
	move.w	d1,d0			; d0 = time & $1f
	and.l	#$1f,d0			;    = second (0..59) / 2
	add.w	d0,d0			; d0 = second 0..59
	divu	#10,d0			; get seconds/10, seconds
	move.b	d0,RD10SEC(a1)		; install seconds/10
	swap	d0
	move.b	d0,RD01SEC(a1)		; install seconds/1

	move.w	d1,d0			; d1 = (time >> 5) & $3f
	lsr.w	#5,d0			;    = minutes 0..59
	and.l	#$3f,d0
	divu	#10,d0			; get minutes/10, minutes
	move.b	d0,RD10MIN(a1)		; install minutes/10
	swap	d0
	move.b	d0,RD01MIN(a1)		; install minutes/1

	lsr.w	#8,d1			; d1 >>= 11
	lsr.w	#3,d1			;    = hours 0..23
	ext.l	d1			; clobber upper word
	divu	#10,d1			; get hours/10, hours
	move.b	d1,RD10HR(a1)		; install hours/10
	swap	d1
	move.b	d1,RD01HR(a1)		; install hours/1

*
*  Convert date to chip format
*
	move.w	4(sp),d1		; d1 = GEMDOS format date
	move.w	d1,d0			; d0 = date & $1f
	and.l	#$1f,d0			;    = day 1..31
	divu	#10,d0			; get days, days/10
	move.b	d0,RD10DAY(a1)		; install days/10
	swap	d0
	move.b	d0,RD01DAY(a1)		; install days/1

	move.w	d1,d0			; d0 = (date >> 5) & $0f
	lsr.w	#5,d0
	and.l	#$0f,d0			;    = month 1..12
	divu	#10,d0			; get months, months/10
	move.b	d0,RD10MON(a1)		; install months/10
	swap	d0
	move.b	d0,RD01MON(a1)		; install months/1

	lsr.w	#1,d1			; d1 >>= 9
	lsr.w	#8,d1			;    = years 80..99/00..79
	ext.l	d1			; clobber upper word
	move.l  d1,d2			; (d2 = years)
	divu	#10,d1			; get years, years/10
	move.b	d1,RD10YR(a1)		; install years/10
	swap	d1
	move.b	d1,RD01YR(a1)		; install years/1

	divu	#4,d2			; d2 = years/4
	swap	d2			; remainder is the leap-year count

*
*  Write the clock data;
*    o  zero day-of-week counter (we don't use it)
*    o  clobber 15-stage internal divider to give
*	us one second to work with;
*    o  write 24-hour mode;
*    o  write leap year count (already in D2 at this point);
*    o  write new clock data.
*
	clr.b	RDDOW(a1)		; clobber day-of-week in buffer
	move.b	#%0010,RTRES(a0)	; clobber 15-stage divider
	move.b	#%1001,RTMODE(a0)	; set "alarm" bank
	move.b	#%0001,RT10MON(a0)	; set 24-hour mode
	move.b	d2,RT01YR(a0)		; write leap-year count
	move.b	#%1000,RTMODE(a0)	; set "normal" bank

	moveq	#READS-1,d0		; d0 = count
	moveq	#RT01SEC,d1		; d1 = index to hardware registers
sclp:	move.b	(a1,d0.w),(a0,d1.w)	; copy byte to clock chip
	addq.w	#2,d1			; bump register index
	dbra	d0,sclp

	moveq	#0,d0			; return 0 = OK
	rts

sclerr:	moveq	#-1,d0			; return -1L = bad
	rts


    .bss
*
*  Two buffers (for comparing clock reads/stuffing clock values)
*
read1:	.ds.b	READS
read2:	.ds.b	READS
	.even

.else

*
* Clock chip in the TT is the Motorola MC146818A
*

RTCA	equ	$ffff8961
RTCD	equ	$ffff8963

* registers

SEC	equ	0
MIN	equ	2
HOUR	equ	4
WKDAY	equ	6
DAY	equ	7
MONTH	equ	8
YEAR	equ	9
REGA	equ	$a
REGB	equ	$b
REGC	equ	$c
REGD	equ	$d

*--------------
*
* Initialize clock at startup:
*   probe for clock chip
*   if missing, return CS
*   else if not VRT (valid RAM and TIME)
*	perform the SET operation with some sane time and date
*   endif
*   Set GEMDOS's time to RTC time
*   return CC.
*

_iclock:
	bsr	clktest		; chip present?
	bcs.b	iclkfail	; missing; give up.

* chip is present; test VRT bit (Valid RAM and Time)

	move.b	#REGD,RTCA
	move.b	RTCD,d0
	btst	#7,d0		; VRT bit set?
	bne	timeok		; yes - it's fine

* VRT is clear - set a sane time & date & initialize the chip
*
*		  YYYYYYYMMMMDDDDDHHHHHMMMMMMSSSSS 6/16/1989
	move.l	#%00010010110010000000000000000000,-(sp)
	bsr	_setclock
	addq	#4,sp

timeok:
	bsr	_getclock
	cmp.l	#-1,d0
	beq	iclkfail
	move.w	d0,_time
	swap	d0
	move.w	d0,_date

	moveq.l	#0,d0
	rts

iclkfail:
	moveq.l	#-1,d0
	rts

*
* Get GEMDOS format of the date and time.  Returns D0.L with date in hi word.
*
*	HHHH HMMM MMMS SSSS
*	YYYY YYYM MMMD DDDD
* 
* Does not validate what it gets from the clock chip, except that if
* the chip test fails or the VRT bit is clear, returns -1L.
*

_getclock:
	bsr	clktest
	bcs	iclkfail	; use a handy error return (above)
	move.b	#REGD,RTCA
	btst.b	#7,RTCD
	beq	gclfail

* You have to reload REGA every time, even if you're reading the same
* register over and over.

	move.w	sr,d2
	move.w	d2,d0
	or.w	#$0700,d0	; d0 is IPL 7 sr, d2 is old sr.

gwait:*	move.w	d2,sr		; allow interrupts
*	nop			; (BRIEFLY!)
*	move.w	d0,sr		; now IPL 7
	move.b	#REGA,RTCA
	btst.b	#7,RTCD	; test UIP bit
	bne	gwait		; wait until it's clear

	moveq.l	#0,d0
	move.l	d0,d1
	move.b	#SEC,RTCA
	move.b	RTCD,d0
	asr.w	#1,d0		; GEMDOS tells times in pairs of seconds
	move.b	#MIN,RTCA
	move.b	RTCD,d1
	bfins	d1,d0{21:6}	; hooray for BF instructions!
	move.b	#HOUR,RTCA
	move.b	RTCD,d1
	bfins	d1,d0{16:5}

	move.b	#DAY,RTCA
	move.b	RTCD,d1
	bfins	d1,d0{11:5}
	move.b	#MONTH,RTCA
	move.b	RTCD,d1
	bfins	d1,d0{7:4}
	move.b	#YEAR,RTCA
	move.b	RTCD,d1
	sub.b	#10,d1		; subtract 10 for yr since 1980, not 1970
	bfins	d1,d0{0:7}
	move.w	d2,sr		; restore original IPL
	rts

gclfail:
	move.l	#-1,d0
	rts

*
* _setclock(newtime)
*
* newtime is a longword with the date in the upper half; date and
* time are GEMDOS format.
*
* SET operation:
*	set SET bit
*	set 32KHz input, 64Hz periodic interrupt (register A)
*	set SET bit again, no interrupt enables, binary data, 24-hr mode,
*		and no DST (silicon can't keep up with Congress).
*		(register B)
*	set the time and date (1970 base year; warranty expires 12/31/2069)
*	set the VRT bit, clear the SET bit
*

_setclock:
	bsr	clktest
	bcs	iclkfail	; use a handy error return (above)
	move.l	4(sp),d0

	move.b	#REGB,RTCA
	move.b	#$80,RTCD	; set the SET bit and clear all else
	move.b	#REGA,RTCA
	move.b	#$2a,RTCD	; set 32KHz input, 64Hz periodic
	move.b	#REGB,RTCA
	move.b	#%10001110,RTCD	; SET, enable SQWE, DM=binary, 24hr

	move.b	#SEC,RTCA
	bfextu	d0{27:5},d1
	add.b	d1,d1
	move.b	d1,RTCD

	move.b	#MIN,RTCA
	bfextu	d0{21:6},d1
	move.b	d1,RTCD

	move.b	#HOUR,RTCA
	bfextu	d0{16:5},d1
	move.b	d1,RTCD

	move.b	#DAY,RTCA
	bfextu	d0{11:5},d1
	move.b	d1,RTCD

	move.b	#MONTH,RTCA
	bfextu	d0{7:4},d1
	move.b	d1,RTCD

	move.b	#YEAR,RTCA
	bfextu	d0{0:7},d1
	add.b	#10,d1		; add 10 for years since 1970, not 1980
	move.b	d1,RTCD

	move.b	#REGB,RTCA
	move.b	#%00001110,RTCD	; clear SET, leave others
	rts

*
* probe for the clock chip.  Returns CS if the chip is missing, cc if found.
*

clktest:
	move.l	sp,a0
	move.l	$8,a1
	move.l	#berr,$8

	move.b	#0,RTCA
	move.b	RTCD,d0		; read seconds register

	move.l	a1,$8		; restore bus error vector
	and	#$fe,ccr	; clear carry bit
	rts			; and return

berr:	move.l	a0,sp		; restore SP after bus error
	move.l	a1,$8		; restore bus error vector
	or	#1,ccr		; set carry bit
	rts			; and return

**********************************************************************
*
* XBIOS call $2e: NVMaccess: read, write, or initialize the non-volatile 
* memory in the RTC chip.
* 
* 	WORD NVMaccess(op,start,count,buffer)
* 	WORD op, start, count;
* 	BYTE *buffer;
* 
* Returns 0 for success, EBADRQ (-5) for range error on args, and 
* EGENRL (-12) if the NVM checksum isn't consistent before a read
* or write.  In the case of a read the data is transferred anyway.
* 
* If the checksum is consistent before a WRITE operation,  the call
* writes the new data,  then recomputes the checksum and writes the
* checksum and its inverse in the appropriate places.
* 
* 	OPCODE	MEANING
* 	   0	READ: copy data from NVM to buffer.
* 	   1	WRITE: copy data from buffer to NVM.
* 	   2	INIT: zero the NVM and initialize the checksum.
* 
**********************************************************************

.globl NVMaccess

NVMaccess:
	moveq	#-5,d0		; pre-load EBADRQ return code
	move.w	4(sp),d1	; get opcode
	beq	nvmread		; 0 is read
	cmp.w	#2,d1
	beq	nvminit		; 2 is init
	bhi	nvmdone		; >2 is illegal

; else opcode is 1, meaning write

	bsr	nvmcheck	; (sets d1=start+e,d2=count,a1=RTCA)
	tst.w	d0
	bne	nvmdone		; bail out on errors
	move.l	$a(sp),a0	; get buffer address
	bra	nvmwe		; bra to end of dbra loop

nvmwl:	move.b	d1,(a1)		; write register number
	move.b	(a0)+,(a2)	; write data
	addq	#1,d1		; incr register number
nvmwe:	dbra	d2,nvmwl

	bsr	nvmgetchk	; write succeeded; get & write checksum
	move.b	#49+$e,(a1)
	move.b	d0,(a2)
	not.b	d0
	move.b	#48+$e,(a1)
	move.b	d0,(a2)
	moveq	#0,d0		; return no error
nvmdone:
	rts

nvmread:
	bsr	nvmcheck	; (sets d1=start+e,d2=count,a1=RTCA,a2=RTCD)
	cmp.w	#-5,d0		; if EBADRQ return now
	beq	nvmdone

	move.l	$a(sp),a0	; else proceed with read & return this d0
	bra	nvmre

nvmrl:	move.b	d1,(a1)
	move.b	(a2),(a0)+
	addq	#1,d1
nvmre:	dbra	d2,nvmrl

	rts

nvminit:
	lea.l	RTCA,a1
	lea.l	RTCD,a2
	moveq	#0,d0
	moveq	#$e,d1
	moveq	#50-1,d2
nvmil:	move.b	d1,(a1)		; clear all 50 RAM locations
	move.b	d0,(a2)
	addq	#1,d1
	dbra	d2,nvmil

	move.b	#48+$e,(a1)	; write FF to location 48
	move.b	#$ff,(a2)
	rts			; return no error (d0 is still 0)

*
* nvmcheck: subroutine common to nvmread and nvmwrite.
* Checks consistency of the NVM, returns EGENRL (-12) if bad.
* Loads start & count off stack & checks range, returns EBADRQ (-5)
* if bad. 
*
* Leaves d1=start+$e, d2=count, a1=RTCA, a2=RTCD, unless returning EBADRQ.
*

nvmcheck:
	bsr	nvmgetchk	; get RTCA to a0, checksum to d0
	move.b	d0,d1
	moveq	#-12,d0		; preload EGENRL return code
	move.b	#49+$e,(a1)
	cmp.b	(a2),d1		; match?
	bne	nvmckdone	; no - return EGENRL
	not.b	d1
	move.b	#48+$e,(a1)
	cmp.b	(a2),d1		; inverse match?
	bne	nvmckdone	; no - return EGENRL

; checksum matches, now check args

	moveq	#-5,d0		; preload EBADRQ return code
	move.w	$a(sp),d1	; get start reg number
	cmp.w	#48,d1
	bhs	nvmckdone	; start >= 48: EBADRQ
	move.w	$c(sp),d2	; get count
	bmi	nvmckdone	; count < 0: EBADRQ
	add.w	d1,d2		; add start
	cmp.w	#48,d2
	bhi	nvmckdone	; (start+count) > 48: EBADRQ
	moveq	#0,d0		; and return zero

; nvmcheck returns through here always; d0 has a return code, and
; the other registers are loaded here for returning.

nvmckdone:
	move.w	$c(sp),d2	; get count back
	move.w	$a(sp),d1	; and start
	add.w	#$e,d1		; add $e to start for true reg num
	rts

nvmgetchk:
	lea	RTCA,a1
	lea	RTCD,a2
	moveq	#0,d0		; pre-clear checksum
	moveq	#$e,d1		; starting reg num is $e
	moveq	#48-1,d2	; count is 48

nvmcl:	move.b	d1,(a1)
	add.b	(a2),d0
	addq	#1,d1
	dbra	d2,nvmcl
	rts			; return checksum in d0

.endc

