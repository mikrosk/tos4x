******************* Revision Control System *****************************
*
* $Author: apratt $
* =======================================================================
*
* $Date: 89/02/27 12:35:02 $
* =======================================================================
*
* $Locker:  $
* =======================================================================
*
* $Log: clock.s,v $
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
* $Revision: 1.4 $
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

	.globl	clktest		; test for clock chip (returns CC/CS)
	.globl	_iclock		; clock setup
	.globl	_setclock	; setclock() BIOS call
	.globl	_getclock	; getclock() BIOS call
	.globl	_date,_time	; GEMDOS date and time variables

RTCBASE	=	$fffffc20	; base address of RTC chip

*
*  Clock chip registers
*
RT01SEC	=	$1		; 1-second counter
RT10SEC	=	$3		; 10-second counter
RT01MIN	=	$5		; 1-minute counter
RT10MIN	=	$7		; 10-minute counter
RT01HR	=	$9		; 1-hour counter
RT10HR	=	$B		; 10-hour counter
RTDOW	=	$D		; day of week
RT01DAY	=	$F		; 1-day counter
RT10DAY	=	$11		; 10-day counter
RT01MON	=	$13		; 1-month counter
RT10MON	=	$15		; 10-month counter
RT01YR	=	$17		; 1-year counter
RT10YR	=	$19		; 10-year counter
RTMODE	=	$1B		; mode bits
RTTEST	=	$1D		; test register (must be 0)
RTRES	=	$1F		; reset register

READS	=	13		; number of reads to do (up to RT10YR)


*
*  Offsets into read buffer;
*  They are in "reverse order" in a misguided
*  attempt to save bytes.  Sue me.
*
RD01SEC	=	$c
RD10SEC	=	$b
RD01MIN	=	$a
RD10MIN	=	$9
RD01HR	=	$8
RD10HR	=	$7
RDDOW	=	$6		; day of week
RD01DAY	=	$5
RD10DAY	=	$4
RD01MON	=	$3
RD10MON	=	$2
RD01YR	=	$1
RD10YR	=	$0


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
	bcs.s	iclfai			; (not around)

*
*  Get clock chip's time
*  and set GEMDOS time from it.
*
	bsr	_getclock		; get chip's idea of the time
	cmp.l	#-1,d0			; bad time?
	beq.s	iclfai			; yes --- punt

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
	bne.s	clkfai			; (no --- fail)
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
	lea	read1,a1		; a1 -> clock data buffer
	lea	read2,a2		; a2 -> alternate clock data buffer
	bsr	readclk			; read clock into &a1

rdagn:	exg	a1,a2			; swap buffer pointers
	bsr	readclk			; read clock into &a1

	moveq	#READS-1,d0		; d0 = DBRA #bytes to compare
cmplup:	move.b	(a1,d0.w),d1		; get first byte
	cmp.b	(a2,d0.w),d1		; ... compare
	bne.s	rdagn			; re-read clock on mismatch
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
	lea	read1,a1		; a1 -> buffer for clock data to write

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
