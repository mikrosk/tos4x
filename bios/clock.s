.super
******************* Revision Control System *****************************
*
* $Author: ersmith $
* =======================================================================
*
* $Date: 1993/02/25 00:39:44 $
* =======================================================================
*
* $Locker: ersmith $
* =======================================================================
*
* $Log: clock.s,v $
* Revision 2.24  1993/02/25  00:39:44  ersmith
* Changed NVRAM re-initialize to reset to default values, instead of all
* zeros.
*
* Revision 2.23  1992/08/11  00:34:42  kbad
* TOS 4.00 Falcon030 first production version
*
* Revision 2.22  1992/07/27  20:12:04  kbad
* Nearly last Sparrow test BIOS
*
* Revision 2.21  1992/05/18  23:07:48  unknown
* SPARROW now uses motorola clock chip; added stub waketime
*
* Revision 2.20  1992/02/28  01:21:56  apratt
* Oops. When STPAD boots we *do* want to disable off the alarm.
*
* Revision 2.19  1991/10/04  17:58:30  apratt
* This version folds in those things which are new since I put most of clock.s
* into power.prg for quick-turnaround testing.  The key difference is that
* calling Waketime(1) less than 14 seconds into the minute the alarm is set
* for causes a return of -1.  See other comments for discussion of this.
*
* Revision 2.18  1991/10/03  17:53:24  apratt
* More revs; this is the last rev before putting Waketime in power.prg
* for testing.  It'll get folded back into here soon... :-)
*
* Revision 2.17  1991/10/01  20:12:52  apratt
* When you try to set the alarm (Waketime(1)), we now return
* zero for success (i.e. no time to set, or time is in the past,
* or successfully set), and -1 for the special case where you
* are trying to set the alarm for the same minute you're already in.
*
* Revision 2.16  1991/09/30  16:45:58  apratt
* Another rev for STBOOK alarm stuff; see comments above waketime.
*
* Revision 2.15  1991/09/29  23:59:46  apratt
* Added the Waketime() XBIOS call, number 47 ($2f).  See the code
* for documentation of it.  It's meant for STPAD but works for all
* ST's and STe's but not TT (because TT has a different RTC).
* Note that this code now computes and sets day-of-week, but
* never reads it.  DOW participates in the alarm match, so it has
* to be computed when you set the time, and when you set the alarm.
*
* Revision 2.14  1991/09/17  21:48:52  apratt
* For TT TOS, we have stored "year since 1970" in the RTC.
* This is wrong: if you do that then leap years are off by two years.
* We did this originally for the UNIX group's sake, so they could
* represent 1970.  To preserve that (no skin off my nose) the RTC
* for TT now holds "year since 1968."
*
* Revision 2.13  1991/09/12  19:41:34  apratt
* Changed conditionals: ! is bitwise in MAS, so !TT is $FFFFFFFE when TT is 1.
* So we use (TT == 0) instead.  Sigh.
*
* Revision 2.12  1991/09/06  14:50:56  apratt
* Changed all "ifne" to "if" and "ifeq" to "if !" and "endc" to "endif."
*
* Revision 2.11  91/08/15  15:31:13  apratt
* Added code to write GEMDOS' idea of _date and _time every time _getclock is
* called (for either clock chip).  This lets you update those variables
* without doing Settime(Gettime()), which would cause the RTC to lose between
* zero and two seconds each time.
* 
* Fixed the STPAD case where the reset register and test register weren't
* being initialized properly.
* 
* 
* Revision 2.10  91/08/05  15:13:11  apratt
* Added support for STPAD: took out the test (the Ricoh chip is ALWAYS
* there), disabled the 1Hz and 16Hz wave outputs, and changed other code to
* avoid clobbering alarm registers.
* 
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
* $Revision: 2.24 $
* =======================================================================
*
* $Source: d:\tos\bios/RCS/clock.s,v $
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

* TT equate moved to command line

*
* This file switches on the symbols RICOH and MOTO; here is the formula for
* what machines have what parts:
*

RICOH	equ	((TT + SPARROW) == 0)
MOTO	equ	(TT + SPARROW)

	.globl	clktest		; test for clock chip (returns CC/CS)
	.globl	_iclock		; clock setup
	.globl	_setclock	; setclock() BIOS call
	.globl	_getclock	; getclock() BIOS call
	.globl	_date,_time	; GEMDOS date and time variables
	.globl	nv_defs		; default NVM configuration

.if RICOH

*
* STPAD doesn't really probe for the clock chip: there is always one. The
* test clobbers the alarm registers, and this is A Bad Thing.  Also, there
* are bits in both the reset register and the mode register which need
* better handling than was here: 1Hz and 16Hz must be disabled, the alarm
* reset bit must never be set, and the alarm enable bit must be preserved.
* Sigh.
*

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
	beq	iclfai			; yes --- return -1
	moveq	#0,d0			; return 0 for "Ok fine"
iclfai:	rts

*----------------
*
*  Quick "memory" test on useless timer registers will
*  tell us if the chip is alive or not.  A bus error
*  is also a good indication that the chip isn't around....
*
*    Returns:	a0 -> clock hardware base
*		RTC in time bank, not alarm bank
*		RTC test register zeroed
*		(on STPAD: both periodic interrupts off)
*		CC: clock exists
*		CS: clock doesn't exist (bad RAM test)
* 
*    Uses:	d0-d2/a0-a2
*
* Originally, this code didn't have the bus error handling; that
* was added 2/6/89 by AKP.  Don't know why the above comment
* refers to bus errors but doesn't implement them.
*
* Feb 92: for STPAD we do NOT need to preserve the alarm registers or the
* alarm enable.  In fact we want to turn OFF the alarm enable. The alarm
* will be made pending during shutdown.  If your system is on then you
* don't need the alarm output, and in fact you don't want it.  STPADs
* with old ROMs need an AUTO folder program to write %1000 to RTMODE.
*

clktest:
.if STPAD
	move.w	#RTCBASE,a0		; fulfill return requirement
	move.b	#0,RTTEST(a0)		; clobber test register
	move.b	#%1100,RTRES(a0)	; and turn off periodic outputs
	move.b	#%1000,RTMODE(a0)	; select time bank, timer enable
					; this disables alarm! See above.
	moveq.l	#0,d0			; clear the carry bit - clock exists.
	rts
.else
	move.w	#RTCBASE,a0		; a0 -> base of clock chip
	move.l	$8.w,d2			; save bus error vector
	move.l	sp,a2			; save stack pointer for cleaning up
	move.l	#clkerr,$8.w		; write bus error vector
*	move.b	#%1001,RTMODE(a0)	; set "alarm" bank
	bset	#0,RTMODE(a0)		; set "alarm" bank (leave ENs alone)
	move.l	d2,8.w			; no bus error - restore vector
	move.w	#$0a05,d0		; d0 = test pattern
	movep.w	d0,RT01MIN(a0)		; write two registers
	movep.w	RT01MIN(a0),d1		;   and read them back
	and.w	#$0f0f,d1		; clobber crufty bits
	cmp.w	d0,d1			; compare?
	bne	clkfai			; (no --- fail)
	move.b	#%0001,RT01SEC(a0)	; set 16.384Khz CKOUT mode
*	move.b	#%1000,RTMODE(a0)	; set "normal" bank
	bclr.b	#0,RTMODE(a0)		; set "normal" bank (leave ENs alone)
	move.b	#0,RTTEST(a0)		; clobber test register
	rts				; return OK

clkerr:	move.l	a2,sp			; clean off the stack
	move.l	d2,$8.w			; restore the bus error vector
clkfai:	or	#1,ccr			; set carry
	rts				; return "failure"
.endif

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
* When this succeeds, it also writes GEMDOS' idea of date & time
* so they're in synch.  Thus, calling Gettime() has the effect of
* synchronizing the RTC and GEMDOS. (new as of 8/91)
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

	move.w	sr,d2
	or.w	#$0700,sr		; no ints while writing date & time
	move.w	d1,_date		; set GEMDOS' idea of date & time
	swap	d1			; date into high word, time in lower
	move.w	d1,_time
	move.w	d2,sr			; restore ints
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
* Note: as of TOS 2.06 of 9/29/91, this code computes and sets the
* day-of-week register in the clock chip.  This accomodates the STPAD,
* which uses the alarm feature of the RTC, because the day of week
* participates in the alarm match.  Note that the day of week is never
* read, only set.
*

_setclock:
	bsr	clktest			; test for clock chip
	bcs	sclerr			; punt if chip doesn't exist
	lea	read1.w,a1		; a1 -> buffer for clock data to write

	move.w	4(sp),a2		; get the date part of the arg
	bsr	week_day		; compute day-of-week
	move.b	d0,RDDOW(a1)		; write day-of-week in the buffer

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
*    o  zero day-of-week counter (we don't use it) (we do now (AKP))
*    o  clobber 15-stage internal divider to give
*	us one second to work with;
*    o  write 24-hour mode;
*    o  write leap year count (already in D2 at this point);
*    o  write new clock data.
*
	move.b	#%1110,RTRES(a0)	; clobber 15-stage divider and 1Hz/16Hz
					; (but don't touch alarm reset)
	bset.b	#0,RTMODE(a0)		; set "alarm" bank (leave EN's alone)
	move.b	#%0001,RT10MON(a0)	; set 24-hour mode
	move.b	d2,RT01YR(a0)		; write leap-year count
	bclr.b	#0,RTMODE(a0)		; set "normal" bank (leave EN's alone)
	bclr.b	#3,RTMODE(a0)		; disable timer while we're setting it

	moveq	#READS-1,d0		; d0 = count
	moveq	#RT01SEC,d1		; d1 = index to hardware registers
sclp:	move.b	(a1,d0.w),(a0,d1.w)	; copy byte to clock chip
	addq.w	#2,d1			; bump register index
	dbra	d0,sclp

	bset.b	#3,RTMODE(a0)		; enable timer after setting it
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
	.text

*
* Given a GEMDOS date in a2.w, return day-of-week, zero-based
*

week_day:
	moveq	#2,d2		; d2 accumulates leap years. 1/1/80 was Tue
	move.w	a2,d0
	lsr.w	#8,d0
	lsr.w	#1,d0		; d0 is year

	add.w	d0,d2		; d2 += year (1/1 advances 1 wday/year)

	move.w	d0,d1
	lsr.w	#2,d1
	add.w	d1,d2		; d2 += (year/4): add 1 for each leap year
*	addq.w	#1,d2		; add another because 0 was a leap year
* but don't really because this balances the -1 later on

	move.w	a2,d1
	lsr.w	#5,d1
	and.w	#$f,d1		; d1 is month

	and.w	#3,d0		; d0 is year % 4: is this a leap year?
	bne	nosub1		; no.
	cmp.w	#2,d1		; are we in Jan or Feb?
	bhi	nosub1		; no.
	subq	#1,d2		; yes: subtract off leap year counted too soon
nosub1:	
	subq	#1,d1		; make d1 a zero-based month
	add.w	d1,d1		; make d1 an offset into the days-so-far tbl
	add.w	dytbl(PC,d1.w),d2	; add days-so-far to weekday

	move.w	a2,d1
	and.w	#$1f,d1		; d1 is day of month
	add.w	d1,d2		; add days so far this month to d2
*	subq.w	#1,d2		; subtract one off (days are zero-based)
* This is the -1 that is balanced by commenting out the +1 above.

	; now return (d2 % 7)

	divu	#7,d2
	swap	d2
	moveq	#0,d0
	move.w	d2,d0
	rts

dytbl:	dc.w	0					; Jan 1
	dc.w	0+31					; Feb 1
	dc.w	0+31+28					; Mar 1
	dc.w	0+31+28+31				; Apr 1
	dc.w	0+31+28+31+30				; May 1
	dc.w	0+31+28+31+30+31			; Jun 1
	dc.w	0+31+28+31+30+31+30			; Jul 1
	dc.w	0+31+28+31+30+31+30+31			; Aug 1
	dc.w	0+31+28+31+30+31+30+31+31		; Sep 1
	dc.w	0+31+28+31+30+31+30+31+31+30		; Oct 1
	dc.w	0+31+28+31+30+31+30+31+31+30+31		; Nov 1
	dc.w	0+31+28+31+30+31+30+31+31+30+31+30	; Dec 1

*
* New BIOS call "Waketime" (decimal 47, $2f): takes a longword.
*
* Mostly, if that longword (as datime) is in the future, it's written
* to the variable "waketime."  However, some values are special:
*
*      -1: return the current value of the waketime variable.
*	0: clear out waketime, un-set the alarm.
*	1: set the alarm based on waketime.
*
* Returns:
*	0: you won: your time is valid, in the future, and
* sooner than the current value of waketime.
*	1: your time is in the past.
*	2: your time is in the future, but later than waketime.
*	3: you requested that waketime be zeroed and unset, so it was.
*	4: had to set the alarm for the first of that month (see below).
*	5: had to set the alarm for this time tomorrow (see below).
*
* If you call this with "1" as the arg (to set the alarm), the returns are:
*	 0: Success.  Either waketime was zero and no alarm is set,
*	   or the RTC failed (not likely), or the alarm was set.
*	-1: Failure.  You have asked me to set the alarm to "right now."
*	   This return is treated specially in power.prg, the only
*	   legitimate caller of Waketime(1).
*
* Screw cases:
* 
* If you try to set the alarm for THIS MINUTE, on THIS DATE, but in some
* other month, you get in trouble.  Since the alarm only knows
* date/hour/minute, you'd be setting the alarm for RIGHT NOW. (OK, the day of
* week participates, but we haven't computed that yet.)  So we hack this: if
* it's the first of the month, we set the alarm for this time tomorrow (the
* second).  Otherwise we set the alarm for this time on the first of the
* month you're actually trying to set the alarm for.
* 
* We could do this in Waketime(1), so we never end up waking you up when it
* isn't necessary, and in fact we should, but for now it's in
* Waketime(datime).
* 
* If you call Waketime(1) and you are actually in the first 14 seconds of the
* minute it's set for, then we can't turn you off: some program that's
* waiting for this minute might want to run, and besides, setting the alarm
* for "now" makes it fire right away.  So instead we clear waketime and
* return -1, signalling this event.  The code is expected NOT to shut down,
* and instead to crank the event loop so the things that are waiting for this
* minute will see that it's time and do their things, and the ones that are
* waiting for later times will call Waktime(datime).  If none do, then no
* alarm is set (because we cleared waketime).  The user mashes the power
* button again and we really shut down.
* 
* If you're more than 14 seconds into the minute, it's OK to shut down. This
* is because those programs that wanted to know the time have run, and those
* that wanted to set waketime have also run.  In that case, the only way
* waketime could still be "this minute" is if nobody called waketime at all,
* in which case there just isn't any alarm to set.
* 

.bss
waketime: ds.l	1
.text

.globl _waketime
_waketime:
	move.l	4(sp),d0
	beq	clralarm	; Waketime(0): clear the alarm
	cmp.l	#-1,d0
	beq	readalarm	; Waketime(-1): read the current value
	cmp.l	#1,d0
	beq	setalarm	; Waketime(1): set the alarm

*
* OK, it's really a time & date.  Compare with the real time from the RTC
* to see if it's really in the future.  If it is, then check to see if this
* time "wins."   This time "wins" if (A) waketime is currently zero, or (B)
* waketime is in the past (has already happened), or (C) the new time is
* sooner than the current value of waketime.  If the new time wins,
* set waketime to that value.
*
* The new time can only win if it is actually IN THE FUTURE, as opposed to
* being NOT IN THE PAST.  If you try to set the alarm for THIS MINUTE, you
* will fail.  This gets us out of some problems that happen when you try to
* shut down in the same minute that the alarm is set for.
*

	bsr	_getclock
	cmp.l	#-1,d0
	beq	noalarm		; a handy RTS: really "can't happen"

	move.l	4(sp),d1	; get your desired alarm time back
	and.b	#%11100000,d0	; round "now" down to a minute boundary
	and.b	#%11100000,d1	; round your desired time down, too
	cmp.l	d1,d0
	bhs	inpast		; now >= ask: don't do it.

* OK, it's in the future.  But is it sooner than waketime?

	move.l	waketime,d2
	beq	youwin		; no waketime: you win.
	cmp.l	d2,d0		; is waketime in the past?
	bhi	youwin		; yes: you win.
	cmp.l	d2,d1		; is the new time same or sooner than waketime?
	bhs	islater		; no: you lose.

* You win!  There's a hitch: if you're setting the time for THIS MINUTE, on
* THIS DAY, but in some other month or year, we have to be tricky. What we
* do is set the alarm for (A) this time tomorrow or (B) the first day of
* the month you're trying to set the alarm in.  Either will happen before
* the alarm you're asking for.  We pick (A) if you ask for the first
* day of the month you're worried about.  This gets us out of rollover
* computations.

youwin:
	move.l	d0,a0		; temp storage for "now"
	move.l	d1,d2		; get your time to d2
	and.l	#$1fffff,d2	; get rid of year & month
	and.l	#$1fffff,d0	; ditto for "now"
	cmp.l	d2,d0		; same?
	beq	wkspecial	; yes - do special stuff

	move.l	d1,waketime	; set waketime to your request
	moveq.l	#0,d0		; return 0: you won.
	rts

wkspecial:
	and.l	#$1f0000,d2	; d2 is now just date you want
	cmp.l	#$010000,d2	; first of the month?
	beq	wkfirst		; yes.

* You are setting the alarm for THIS MINUTE, THIS DATE, but not the first.
* Set the alarm for "the first of that month."

	and.l	#$ffe0ffff,d1	; mask out date field of your request
	or.l	#$00010000,d1	; set date to "the first"
	move.l	d1,waketime	; set waketime to this value
	moveq.l	#4,d0		; signal success
	rts

* wkfirst: you are setting the alarm for THIS MINUTE, THIS DATE, in a
* different month, and it's the first of that month. Set the alarm for
* "this time tomorrow" which is guaranteed possible just by incrementing
* the date field of "now."

wkfirst:
	move.l	a0,d0		; get "now" back to d0
	add.l	#$00010000,d0	; add one to the date.
	move.l	d0,waketime
	moveq.l	#5,d0		; set to "this time tomorrow"
	rts

inpast:
	moveq.l	#1,d0		; return 1: your request is in the past
	rts

islater:
	moveq.l	#2,d0		; return 2: your request is later
	rts

readalarm:
	move.l	waketime,d0	; Waketime(-1): return the current value
	rts

clralarm:
	bsr	clktest			; probe, load a0 with base address
	bcs	sclerr			; punt if chip doesn't exist
	bclr	#2,RTMODE(a0)		; clear Alarm EN
	move.b	#%1101,RTRES(a0)	; reset alarm
	clr.l	waketime
	moveq.l	#3,d0			; return 3: time zeroed.
	rts

*
* Waketime(1L): Write the clock chip alarm registers and enable the clock
* chip alarm out.  Sets the alarm for "waketime".  This calls week_day to
* compute the day of week it will be and write that, too.
*
* Note that the date and day of week participate, but the month doesn't.
* You're setting the alarm for a Monday which is the 12th, you'll get it
* the next time there's any Monday the 12th, not necessarily the particular
* one you want.
*
* If waketime is set in the past, we set no alarm and return zero.  If
* waketime is set for "right now" (within the first 14 seconds of this same
* minute) this code does not set the alarm and it returns -1.  If waketime
* is set for this minute and you're more than 14 seconds into the minute,
* waketime is cleared, no alarm is set, and we return zero. Otherwise we
* set the alarm and return zero.  power.prg uses this return for special
* things.
*

setalarm:
	bsr	_getclock		; get RTC date & time into d0
	cmp.l	#-1,d0			; did it fail?
	beq	noalarm			; can't set the alarm. Sorry!

	move.l	waketime,d1
	beq	noalarm			; no waketime to set! Bye!
	and.b	#%11100000,d1		; round down to minute boundary
	move.l	d1,d2			; save true time away
	and.b	#%11100000,d0		; round "now" down to minute boundary
	cmp.l	d1,d0			; is waketime in the past?
	bhi	noalarm			; yes: set no alarm and return.
	bne	alok			; not the same minute at all: fine.
* waketime is set for "this minute" -- compare seconds
	and.b	#$1f,d2			; mask only seconds from "now"
	cmp.b	#7,d2			; seconds < 14?
	blo	badnews			; yes: flag the special case
alok:

*
*  Convert time to chip format
*
	move.l	#RTCBASE,a0		; a0 -> base of registers
	bset.b	#0,RTMODE(a0)		; select alarm bank (preserve EN's)

	move.l	waketime,d1		; d1 = GEMDOS format time

	move.w	d1,d0			; d1 = (time >> 5) & $3f
	lsr.w	#5,d0			;    = minutes 0..59
	and.l	#$3f,d0
	divu	#10,d0			; get minutes/10, minutes
	move.b	d0,RT10MIN(a0)		; install minutes/10
	swap	d0
	move.b	d0,RT01MIN(a0)		; install minutes/1

	move.w	d1,d0
	lsr.w	#8,d0			; d0 >>= 11
	lsr.w	#3,d0			;    = hours 0..23
	ext.l	d0			; clobber upper word
	divu	#10,d0			; get hours/10, hours
	move.b	d0,RT10HR(a0)		; install hours/10
	swap	d0
	move.b	d0,RT01HR(a0)		; install hours/1

	move.l	d1,d0
	swap	d0			; get date to d0.w
	and.w	#$1f,d0			; (just the date, ma'am)
	ext.l	d0
	divu	#10,d0
	move.b	d0,RT10DAY(a0)		; install days/10
	swap	d0
	move.b	d0,RT01DAY(a0)		; install days/1

	move.w	waketime,a2		; put date part into a2.w
	bsr	week_day
	move.b	d0,RTDOW(a0)		; write day of week

	bset.b	#2,RTMODE(a0)		; set alarm enable
	bclr.b	#0,RTMODE(a0)		; go back to "time" bank
noalarm:
	moveq.l	#0,d0			; return 0 "I set the alarm."
	rts

*
* Bad News: You are trying to set the alarm, but the alarm would be set for
* the very minute you're in.  We clear waketime and return a flag saying
* this happened.  (We clear waketime because that way, if nobody calls
* Waketime and you shut down, you don't fall into this case again.)
*

badnews:
	clr.l	waketime
	moveq.l	#-1,d0			; Return -1: you tried to set alarm
	rts				; for "this minute" and I won't.

.endif

.if MOTO
*
* This code is for the TT and Sparrow; the clock chip in the TT is the
* Motorola MC146818A; in Sparrow it's a "compatible" Dallas Semiconductor
* DS1287 (not 1287A).
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
	beq	iclkfail	; failed: return -1
	moveq.l	#0,d0		; success: return 0
iclkfail:
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
* When this succeeds, it also writes GEMDOS' idea of date & time
* so they're in synch.  Thus, calling Gettime() has the effect of
* synchronizing the RTC and GEMDOS. (new as of 8/91)
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
	sub.b	#12,d1		; subtract 12 for yr since 1980, not 1968
	bfins	d1,d0{0:7}
	move.w	d2,sr		; restore original IPL

	move.w	sr,d2		; no ints while writing date & time
	or.w	#$0700,sr
	move.w	d0,_time	; set GEMDOS' idea of date & time
	swap	d0
	move.w	d0,_date
	swap	d0
	move.w	d2,sr		; restore ints
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
	add.b	#12,d1		; add 12 for years since 1968, not 1980
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

*
* stub out waketime
*

.globl _waketime
_waketime:
	move.l	4(sp),d0
	beq	wake_clr
	addq.l	#1,d0
	beq	wake_get
	subq.l	#2,d0
	beq	wake_set
	addq.l	#1,d0
wake_clr:
	move.l	d0,waketime
	moveq.l	#0,d0
	rts

wake_get:
	move.l	waketime,d0
	rts

wake_set:
	move.l	d0,waketime
	moveq.l	#0,d0
	rts

.bss
waketime: ds.l	1
.text

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

* FIX: added 2/22/93: set up USA factory configuration

	pea	nv_defs		; use our defaults
	move.w	#16,-(sp)	; write 16 bytes
	move.w	#0,-(sp)	; start at value 0
	move.w	#1,-(sp)	; write NVRAM opcode
	jsr	NVMaccess
	add.l	#10,sp
* end of FIX

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

.endif

