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
* $Log: bios.s,v $
* Revision 2.52  1992/08/11  00:34:42  kbad
* TOS 4.00 Falcon030 first production version
*
* Revision 2.51  1992/07/27  20:12:04  kbad
* Nearly last Sparrow test BIOS
*
* Revision 2.50  1992/07/01  21:47:00  kbad
* last akp revision
*
* Revision 2.49  1992/05/20  22:10:16  unknown
* Added some comments to the keyboard BIOS
*
* Revision 2.48  1992/05/18  23:07:12  unknown
* Set M68030 if (SPARROW | TT) -- all Sparrow is 68030
*
* The cold boot code for STPAD and SPARROW now clear 1MB as documented.
*
* Revision 2.47  1992/02/28  08:31:20  apratt
* Changed coldboot so it works for Sparrow.
*
* Revision 2.46  1992/02/28  08:25:20  apratt
* Changed TT to M68030 in some places, where it's really CPU dependency we're
* talking about.  This lets us build ROMs for Sparrow/030, which isn't a TT
* in any other way. (Well, it has the same clock chip.)
*
* Revision 2.45  1992/02/28  02:00:06  apratt
* Added .globl coldboot to export it.
*
* Revision 2.44  1992/02/28  01:22:04  apratt
* Change to coldboot, to clear up to 4MB in STPAD.
*
* Revision 2.43  1992/02/12  01:32:40  apratt
* Fixed an RTS/CTS bug in SCC code. See scc_sender.
*
* Revision 2.42  1991/11/14  23:51:46  apratt
* Added a comment about hidden interaction between ikbdws and ikbdput.
*
* Revision 2.41  1991/11/14  23:42:20  apratt
* Fixed two bugs reported from Germany.  First, the wrong argument was
* pulled off the stack in the SCC Rsconf code, so you couldn't cause a
* break as documented.  Second, the "wait 5ms using a trick" code in
* ikbdwc had two problems, one of logic and one of implementation.
* Now both work.
*
* Revision 2.40  1991/10/22  19:25:30  apratt
* Added a moveq to pre-clear d0 in the Midi Bconin code.  Until now,
* Bconin on MIDI always returned $FFFFFFxx.  Sadly this didn't make it
* into 3.06 or 2.06.  Sigh.
*
* Revision 2.39  1991/10/15  14:08:24  apratt
* Changed Bioskeys so it does something else, too: it nukes
* key repeat.  In the first place, there was no way to do this
* (and it's necessary for STBOOK), and in the second place, this
* is not an unreasonable place to do it, since key repeat is based
* on scan code and you're ostensibly changing the tables with this
* call.
*
* Revision 2.38  1991/09/16  23:44:52  apratt
* Fixed jdisabint twice: first, you can't clear ipra using bclr: it's an
* asynchronous register.  Second, my "fix" back in 89 for clearing isr was
* wrong -- I used asl, not rol, so we were clearing the isr for the interrupt
* in question and all the lower bits in the same isr.  Sigh.
*
* Revision 2.37  1991/09/12  19:41:34  apratt
* Changed conditionals: ! is bitwise in MAS, so !TT is $FFFFFFFE when TT is 1.
* So we use (TT == 0) instead.  Sigh.
*
* Revision 2.36  1991/09/06  14:50:56  apratt
* Changed all "ifne" to "if" and "ifeq" to "if !" and "endc" to "endif."
*
* Revision 2.35  91/08/05  15:26:53  apratt
* Modified coldboot code for STPAD
* 
* Revision 2.34  91/06/20  14:06:47  apratt
* Removed new keyboard code (was conditional on OLDIKBD)
* because I found a way to hook in a TSR to fix overrun without
* changing the keyboard code.
* 
* Revision 2.33  91/06/13  16:29:56  apratt
* Added alt-keypad functionality: hold down ALT, type a decimal number on the
* keypad, and let go of alt to get that ASCII code into the keyboard buffer. 
* The result has zero as the scan code and the kbshift value at the moment
* you let go of ALT (so you can't get ALT itself in there).
* 
* Revision 2.32  91/05/21  16:54:10  apratt
* Changed error handling in midi/ikbd so I could hook in a TSR to fix the
* overrun problems.  The overrun fixing might one day be part of the OS.  The
* change is that the error handler in ikbdvecs gets control BEFORE the byte
* has been read from the chip, so it must read the data to clear the error. 
* Also, if there is an error, the data byte is not presumed valid and is not
* used.  Set OLDIKBD to 1 to get the old behavior back.
* 
* 
* Revision 2.31  91/04/26  17:44:39  apratt
* Removed the STPAD conditional around MIDI code.  Bconmap probably isn't as
* unconditional as it's cracked up to be: it's not been tested when neither
* STPLUS nor TT is true.
* 
* 
* Revision 2.30  91/04/11  12:13:54  apratt
* Removed PAL condition from spain -- now it's always PAL.
* 
* Revision 2.29  91/04/02  12:34:47  apratt
* Folded in some more things from SERPTCH. This is the version for 3.06.
* 
* Revision 2.28  91/03/27  12:33:58  apratt
* Turned on Bconmap for TT+STPLUS rather than just TT. It should really be on
* for ANYTHING.  Also, a bug fix in RSCONF for MFP's: was writing rsmode in
* iorec as word, not byte.  Could be other problems which I haven't handled
* yet, but which are fixed by SERPTCH.
* 
* Took out midi part of ikbd/midi interrupt if STPAD, since pad has no MIDI.
* 
* Revision 2.27  91/01/31  13:50:17  apratt
* Fixed some bugs in serial port handling for SCC.
* 
* Revision 2.26  90/10/15  12:08:02  apratt
* Fixed keyboard tables so they're right: the arrow keys for some countries
* did NOT give ASCII codes of digits when shifted, as the VDI spec says
* they should.  Also, shifted numeric keypad keys gave punctuation
* in some countries, which was wrong.
* 
* Also removed PC-relative addressing because MAS has a bug: PC-relative
* addressing to a label that's BEFORE the PC, with arithmetic, generates
* incorrect code.  Example: "move.b label+1(PC),d0" when 'label' is before
* the current PC generates "move.b label+3(PC),d0"
* 
* Revision 2.25  90/08/21  17:18:59  apratt
* Mega STe support added.
* 
* Bconmap is no longer conditional.
* 
* Osconf is now an EQU exported from here to startup.s, so that file
* isn't country-dependent any more.
* 
* Revision 2.24  90/08/03  15:18:09  apratt
* Fixed an oops in Norway's keyboard table: REAL TTOS FINAL RELEASE!
* 
* Revision 2.23  90/08/03  13:21:50  apratt
* TTOS FINAL RELEASE
* 
* =======================================================================
*
* $Revision: 2.52 $
* =======================================================================
*
* $Source: d:/tos/bios\rcs\bios.s,v $
* =======================================================================
*
*************************************************************************
*************************************************************************
*									*
*		ST SERIES BIOS SOURCE REV. B				*
*									*
*									*
*		copyright 1984,1985,1986 ATARI Corp.			*
*		all rights reserved					*
*									*
*************************************************************************
*									*
*		general equates for the rbp system rom			*
*									*
*************************************************************************

*
* TT and country equates moved to switches.s, which is normally a 
* copy of one of the canned switches files.
* 

.include "switches.s"

* SPARROW and TT are both M68030.

M68030		equ	(SPARROW | TT)

* All keyboards in one ROM? Set ALLKBS.  This also influences OSCONF.
* You better have NVRAM and the NVMaccess call if you set this!
* Also check startup.s for osconf interactions with pal/ntsc.

ALLKBS		equ	(SPARROW | TT)

*******************************************************************************
*+
*  Country-specific configuration word (os_conf).  This equate is exported
*  to STARTUP.S, but placed here so that file doesn't have any country
*  dependency and this one does.
*
*			%cccccp
*			      p = pal/ntsc (0 = ntsc, 1 = pal)
*			     cc = country (0 = usa, ...)
*
* NEW as of 5/92: the special value $ff means "all countries in one ROM."
* You get the keyboard preference from NVRAM byte 2 and language preference
* from NVRAM byte 3.  The pal/ntsc preference comes from, uh, I dunno.
*
*-

.globl osconf

.if ALLKBS

osconf		equ	$ff

.else

.if country == usa
osconf		equ	%00000
.endif

.if country == germany
osconf		equ	%00011
.endif

.if country == france
osconf		equ	%00101
.endif

.if country == uk
osconf		equ	%00111
.endif

.if country == spain
osconf		equ	%01001
.endif

.if country == italy
osconf		equ	%01011
.endif

.if country == sweden
osconf		equ	%01101
.endif

.if country == swissfra
osconf		equ	%01111
.endif

.if country == swissger
osconf		equ	%10001
.endif

.if country == turkey
osconf		equ	%10011
.endif

.if country == finland
osconf		equ	%10101
.endif

.if country == norway
osconf		equ	%10111
.endif

.if country == denmark
osconf		equ	%11001
.endif

.endif

*+ (lmd)
* Imports:
*
*-
	.globl	_iamanst		;nonzero when you are ST, not STe
	.globl	reseth			;used by keyboard-reset routine (AKP)
	.globl	_timr_ms		;timer C calibration
	.globl	etv_timer		;system timer handoff vector
	.globl	_hz_200			;timer c raw tick
	.globl	conterm			;console configuration byte
	.globl	_dumpflg		;flag to signal a screen dump(alt-HELP)
	.globl	bell_hook		;hook for bell handling
	.globl	kcl_hook		;hook for keyclick handling

.if TT
	.globl	ttwait			;wait for some time
.endif
	.globl	dowait			;wait (usable only at boot time)

*+ (dbg)
* Exports:
*
*-
	.globl	kbshift
	.globl	pconfig
	.globl	maptab			; startup.s uses these in Bcon*
	.globl	maptabsize
	.globl	coldboot		; used for bombs during the boot


*************************************************************************
*									*
*			acia register commands				*
*									*
*************************************************************************

rsetacia	equ	%00000011	;reset acia
div64		equ	%00000010	;set to clock line to /64
div16		equ	%00000001	;set to clock line to /16

* note the keyboard and midi units expect 8 bits/1 stop bit/no parity!!

protocol	equ	%00010100	;set to 8 bit/1 stop/no parity

* note keyboard and midi units are init'ed as bar/rts=low,disabled.

rtsld		equ	%00000000	;rts=low, interrupt disabled

* note the keyboard and midi units may be allowed to
*	send interrupts to the host

intron		equ	%10000000	;interrupts enabled


*************************************************************************
*		acia status definitions
*************************************************************************

*	control register "or" mask settings
 
c19200	equ	1
c9600	equ	1
c4800	equ	1
c3600	equ	1
c2400	equ	1
c2000	equ	1
c1800	equ	1
c1200	equ	1
c600	equ	1
c300	equ	1
c200	equ	1
c150	equ	1
c134	equ	1
c110	equ	1
c75	equ	2
c50	equ	2
*	timer data register settings

d19200	equ	1
d9600	equ	2
d4800	equ	4
d3600	equ	5	;3840 baud -- % error of 6.66
d2400	equ	8
d2000	equ	10	;1920 baud -- % error of 4.00
d1800	equ	11	;1745 baud -- % error of 2.50
d1200	equ	16
d600	equ	32
d300	equ	64
d200	equ	96
d150	equ	128
d134	equ	143	;134.26 baud -- % error of 0.19
d110	equ	175	;109.71 baud -- % error of 0.26
d75	equ	64
d50	equ	96

*************************************************************************
*									*
*	g.i. sound chip ay-3-8910 definitions and init code		*
*									*
*************************************************************************

gibase	equ	$ffff8800

*	gi chip register offsets

giselect	equ	gibase+0	;write data register	word
rddata		equ	gibase+0	;byte of register	word
wrdata		equ	gibase+2	;byte of register	word

*	gi register select offset numbers
 
toneaf	equ	0
toneac	equ	1
tonebf	equ	2
tonebc	equ	3
tonecf	equ	4
tonecc	equ	5
noise	equ	6
mixer	equ	7
aamplt	equ	8
bamplt	equ	9
camplt	equ	10
fienvlp	equ	11
crenvlp	equ	12
shenvlp	equ	13
porta	equ	14
*
*	port a  - outputs all!
*
*	d0 - side select
*	d1 - drive select 0
*	d2 - drive select 1
*	d3 - rts for rs-232
*	d4 - dtr for rs-232
*	d5 - centronics	strobe
*	d6 - general purpose output (for TT, it's internal speaker disable)
*	d7 - unassigned output (for Mega STe and TT, it's not lan)
*

portb	equ	15	;parallel i/o port


*************************************************************************
*									*
*	68901 multifunction peripheral chip equates			*
*	(interrupt controller,timers,serial i/o)			*
*									*
*************************************************************************

*	register and base addresses

mfp	equ	$fffffa01		;base address, +1 offset !!!!!!!!

*	system interrupt register offsets

gpip	equ	0			;general purpose i/o
aer	equ	2			;active edge register
ddr	equ	4			;data direction register
iera	equ	6			;interrupt enable register a
ierb	equ	8			;interrupt enable register b
ipra	equ	10			;interrupt pending register a
iprb	equ	12			;interrupt pending register b
isra	equ	14			;interrupt in-service register a
isrb	equ	16			;interrupt in-service register b
imra	equ	18			;interrupt mask register a
imrb	equ	20			;interrupt mask register b
vr	equ	22			;vector register

*	system timer registers offsets

tacr	equ	24			;timer a control register
tbcr	equ	26			;timer b control register
tcdcr	equ	28			;timer c and d control register
tadr	equ	30			;timer a data register
tbdr	equ	32			;timer b data register
tcdr	equ	34			;timer c data register
tddr	equ	36			;timer d data register

*	rs232/rs422/async/sync serial i/o registers offsets

scr	equ	38			;sync character register
ucr	equ	40			;usart control register
rsr	equ	42			;receiver status register
tsr	equ	44			;transmitter status register
udr	equ	46			;usart data register

*	timer relative locations

atimer	equ	0
btimer	equ	1
ctimer	equ	2
dtimer	equ	3


*************************************************************************
*									*
*	last modified	9/17/84						*
*	created	9/04/84							*
*	by	david b. getreu						*
*									*
*	the following is the acia definitions for the keyboard		*
*	and midi interfacing.  the baud rate for the keyboard acia is	*
*	an amazing 7812.5, a new exciting industrial standard.		*
*	anyways, the appropriate chip setting for this acia is /64,	*
*	while that of the midi interface is /16.  it's baud rate is an	*
*	amazing 31250, another new exciting industrial standard.  the	*
*	500 khz signal to the acia comes off of the glue chip to both	*
*	the keyboard and midi acia tx/rx clocks.			*
*									*
*									*
*************************************************************************

keyboard	equ	$fffffc00	;keyboard acia address base
midi		equ	$fffffc04	;midi acia address base

*	register offsets for acias'

comstat	equ	0		;command/status registers
iodata	equ	2		;keyboard data register


*************************************************************************
*			ascii character definitions			*
*************************************************************************

nul	equ	$00
lf	equ	$0a
cr	equ	$0d
space	equ	$20
esc	equ	$1b
bs	equ	$08
tab	equ	$09
del	equ	$7f
xon	equ	$11
xoff	equ	$13

*************************************************************************
*	exception vector assignment table equates and functions		*
*************************************************************************

evsetsp	equ	$00	;power-on reset supervisor stack pointer
evsetpc	equ	$04	;power-on reset initial program counter
buserr	equ	$08	;bus error
adrerr	equ	$0C	;address error
illins	equ	$10	;illegal instruction
zerodiv	equ	$14	;zero divide
chkinst	equ	$18	;chk instruction
trapvf	equ	$1C	;trap on overflow
privldg	equ	$20	;priviledged instruction
trace	equ	$24	;trace mode
lin1010	equ	$28	;line 1010 emulator
lin1111	equ	$2C	;line 1111 emulator
uninit	equ	$3C	;uninitialized interrupt vector
spurint	equ	$60	;spurious interrupt
hblank	equ	$68	;horizontal blank interrupt
vblank	equ	$70	;vertical blank interrupt
trap0	equ	$80	;trap instruction 0
trap1	equ	$84	;trap instruction 1
trap2	equ	$88	;trap instruction 2
trap3	equ	$8C	;trap instruction 3
trap4	equ	$90	;trap instruction 4
trap5	equ	$94	;trap instruction 5
trap6	equ	$98	;trap instruction 7
trap7	equ	$9C	;trap instruction 7
trap8	equ	$A0	;trap instruction 8
trap9	equ	$A4	;trap instruction 9
trap10	equ	$A8	;trap instruction 10
trap11	equ	$AC	;trap instruction 11
trap12	equ	$B0	;trap instruction 12
trap13	equ	$B4	;trap instruction 13
trap14	equ	$B8	;trap instruction 14
trap15	equ	$BC	;trap instruction 15


*************************************************************************
*	interrupt priority table					*
*************************************************************************
*									*
*	priority	vector 		description			*
*	--------	-------		-----------			*
*	0  low		00_0100	*	centronics busy		i0	*
*	1		00_0104		data carrier detect	i1	*
*	2		00_0108	*	clear-to-send 		i2	*
*	3		00_010c		gpu blt done		i3	*
*	4		00_0110		baud rate generator	(d)	*
*	5		00_0114	*	system timer		(c)	*
*	6		00_0118	*	midi/keyboard acia	i4	*
*	7		00_011c		disk dma		i5	*
*	8		00_0120		horizontal blank counter (b)	*
*	9		00_0124	*	tx error			*
*	10		00_0128	*	tx buffer empty			*
*	11		00_012c	*	receive error			*
*	12		00_0130	*	receive buffer full		*
*	13		00_0134		user/application timer	(a)	*
*	14		00_0138		ringer indicator	i6	*
*	15 high		00_013c		monochrome detect	i7	*
*************************************************************************

prtint	equ	$100	;centronics busy		(i0)
dcd232	equ	$104	;dcd rs-232 interrupt vector	(i1)
cts232	equ	$108	;cts rs-232 interrupt vector	(i2)
bltdon	equ	$10C	;graphics blt done interrupt	(i3)
baudrg	equ	$110	;baud rate generator interrupt	timer d
unused	equ	$114	;system clock interrupt		timer c
midkey	equ	$118	;midi/keyboard interrupt	(i4)
dskdma	equ	$11C	;disk dma interrupt		(i5)
hblnkc	equ	$120	;horizontal blank counter	timer b
txderr	equ	$124	;transmitter error interrupt
txbufe	equ	$128	;transmitter buffer empty interrupt
rxderr	equ	$12C	;receiver error interrupt
rxbufe	equ	$130	;receiver buffer full interrupt
sysclk	equ	$134	;free...free...free...		timer a
rng232	equ	$138	;ring indicator rs-232		(i6)
monitr	equ	$13C	;monochrome monitor detect	(i7)


.if TT
ttmfpibase	equ	$140
ttmfp	equ	$fffffa81
.endif

*
*	RS232/midi/keyboard offset equates into i/o buffer record
*
bufptr	equ	0	;buffer location pointer
bufsize	equ	4	;maximum size of this buffer
bufhead	equ	6	;offset to next byte to be taken from
*			;this buffer
buftail	equ	8	;offset to next location available to
*			;insert a new byte
buflow	equ	10	;amount of space in buffer before an "xon" may
*			;be sent to restore normal use of buffer.
bufhigh	equ	12	;amount of space used in buffer that trigger's
*			;the sending of a "xoff" signal to the host
status	equ	28	;copy of midi acia status
rxoff	equ	30	* "xoff" Sent Flag
txoff	equ	31	* "xoff" Received Flag
rsmode	equ	32	* bit 0 = Xon/Xoff Flow Control Enabled
*			* bit 1 = RTS/CTS Flow Control Enabled
sendnow	equ	33	* Buffer Bypass Flag/Data
brate	equ	34	* saved baud rate: returned by Rsconf(-2)
mask	equ	35	; incoming byte mask

rbufsize	equ	$100		* RS-232 I/O Buffer Sizes (bytes)
kinsize		equ	$100
minsize		equ	$80


*************************************************************************
*		operating system memory space				*
*************************************************************************

	.bss

*
*	MFP RS-232 Buffers and I/O Buffer Record
*
ribuffer:	ds.b	rbufsize	;rs-232 input buffer
robuffer:	ds.b	rbufsize	;rs-232 output buffer

*
*	RS-232 I/O Buffer Record
*
ribufptr:	ds.l	1		* Input Buffer Record
ribufsiz:	ds.w	1
ribufhead:	ds.w	1
ribuftail:	ds.w	1
ribuflow:	ds.w	1
ribufhigh:	ds.w	1
*
*	NOTE: THESE TWO BUFFERS MUST REMAIN CONTIGUOUS
*		(Don't Thank Me, Thank Dave!)
*
robufptr:	ds.l	1		* Output Buffer Record
robufsiz:	ds.w	1
robufhead:	ds.w	1
robuftail:	ds.w	1
robuflow:	ds.w	1
robufhigh:	ds.w	1

rsrbyte:	ds.b	1		* Other Associated Variables
tsrbyte:	ds.b	1
rirxoff:	ds.b	1
ritxoff:	ds.b	1
rirsmode:	ds.b	1		* Bit 0 = Flow Control (0=Disabled)
risendnow:	ds.b	1		* flag/char to send NOW
auxbrate:	ds.b	1		* saved brate value for Rsconf(-2)
auxmask:	ds.b	1		* unused


*
*	keyboard rs232 port routines variable space
*
kibufptr:	ds.l	1
kibufsiz:	ds.w	1
kibufhead:	ds.w	1
kibuftail:	ds.w	1
kibuflow:	ds.w	1
kibufhigh:	ds.w	1
kbufrec		equ	kibufptr

kibuffer:	ds.b	kinsize		;keyboard input buffer

*
*	midi rs232 port routines variable space
*
mibufptr:	ds.l	1
mibufsiz:	ds.w	1
mibufhead:	ds.w	1
mibuftail:	ds.w	1
mibuflow:	ds.w	1
mibufhigh:	ds.w	1
mbufrec		equ	mibufptr

mibuffer:	ds.b	minsize		;midi input buffer


*	Acia error handler vectors -- init'ed to point to 'rte' unless
*	changed subsequent to boot-up

* A pointer to this vector table is returned by Kbdvbase, so don't
* be changing it.  Also, kstate is now officially documented as
* coming after ikbdsys.  It always has, but now it's official. See below.
*
* As of 7/12/90, at offset -4 from the Kbdvbase vectors is a RAM vector
* which gets JMPed to when the BIOS has established that the byte
* from the keyboard is really a key make or break event.  (This includes
* shift keys, and mouse-sending-keystrokes keys.)

ikbdkey:	ds.l	1	;this is Kbdvbase()-4 (see above)

* Kbdvbase returns a pointer to midivec.

midivec:	ds.l	1	;midi interrupt handler vector
vkbderr:	ds.l	1	;keyboard error handler address
vmiderr:	ds.l	1	;midi error handler address
statintvec:	ds.l	1	;general ikbd status record interrupt vector
msintvec:	ds.l	1	;mouse interrupt vector
clkintvec:	ds.l	1	;ikbd real-time clock interrupt vector
joyintvec:	ds.l	1	;general joystick interrupt vector
midisys:	ds.l	1	;midi system interrupt handler
ikbdsys:	ds.l	1	;ikbd system interrupt handler
kstate:		ds.b	1	;present state of ikbd reception routine
kindex:		ds.b	1	;index used to count down bytes left to
*				;receive for current state's record
altkp:		ds.w	1	;accumulator for alt-keypad key; <0 is invalid
***
*** Kstate is LOCKED IN at ikbdsys+4 as of 11/18/88.  This has been
*** true by chance since Day 1, but now I'm declaring it official.
*** The only legal operation on this variable is reading, and the
*** only information it's guaranteed to carry is zero for "not processing
*** a packet" and nonzero for "processing a packet."
***
*** The reason:  if you want to replace the BIOS handler with your
*** own, you have to know that the BIOS isn't in the midst of processing
*** a packet from the IKBD.  So you wait for kstate to be zero.
*** If you take over the vector arbitrarily, you might see half of a packet
*** and not understand it, and when you return the vector to its old
*** value the BIOS will be confused because it thinks it's still processing
*** a packet.

*
*	real-time clock command equates
*
settod	equ	$1b
gettod	equ	$1c

*
*	kstate (ikbd's general state variable) values
*

normal	equ	0
statks	equ	1
amouse	equ	2
rmouse	equ	3
clock	equ	4
joyall	equ	5
joy0	equ	6
joy1	equ	7

*
*	array lengths for ikbd subsystem records
*

statdex	equ	7
amdex	equ	5
rmdex	equ	3
clkdex	equ	6
joyadex	equ	3
joydex	equ	1

statrec:	ds.b	statdex
amrec:		ds.b	amdex
mousebuf:	ds.b	rmdex
clkrec:		ds.b	clkdex
joyrec:		ds.b	joyadex

datetime:	ds.l	1	;jdos variable
newtime:	ds.l	1	;jdos variable
oclkrec:	ds.b	clkdex	;used to assemble and send a new t.o.d. record
*				;to the ikbd

kmbuf:		ds.b	3	;key-emulating mouse buffer

* bit assignments in kbshift

KBRSH	EQU	0		* right shift
KBLSH	EQU	1		* left shift
KBCTL	EQU	2		* control key
KBALT	EQU	3		* alternate key
KBCL	EQU	4		* caps lock
KBMRB	EQU	5		* right mouse button (clr/home)
KBMLB	EQU	6		* left mouse button (insert)

kbshift:	ds.b	1

initsize	equ	kbshift-kstate-1	;area to be inited to zero!

skeytran:	ds.l	1	;contains address for unshifted key translation
skeyshif:	ds.l	1	;contains address for shifted key translation
skeycl:		ds.l	1	;contains address for caps-lock key translation

.if ALLKBS
********************
* Three new KB tables as of 5/92 in the international version (i.e. all
* countries in one ROM).  These point to associative tables, which is to
* say two-byte entries: if the scan code matches the first byte then the
* ASCII code comes from the second byte.  The table ends with a null scan
* code.  These three pointers must immediately follow skeycl.

salttran:	ds.l	1	;NEW 5/92: address for unshifted alt-key
saltshif:	ds.l	1	;NEW 5/92: address for shifted alt-key
saltcl:		ds.l	1	;NEW 5/92: address for caps-lock alt-key
.endif

*	mouse init transfer string buffer

transbuf:	ds.b	17	;temporary string buffer for mouse init's

*	keyrepeat variables

timerate	equ	200	;timer c rate in Hz.

keyrep:		ds.b	1
kdelay1:	ds.b	1	;must start on word boundary
kdelay2:	ds.b	1
cdelay1:	ds.b	1	;must start on word boundary
cdelay2:	ds.b	1
tdelay1		equ	15	;delay before key repeat engages
tdelay2		equ	2	;delay before key repeats after
*				;key repeat is activated

*	parallel timeout counter

prt_to:		ds.l	1

tc_rot:		ds.w	1	;divisor byte for timer c interrupt

*
*	Dave Staugas' Sound Driver variables
*
cursnd:		ds.l	1
timer:		ds.b	1
auxd:		ds.b	1

*
*	printer configuration word
*
*	bits 6-15 not defined
*
*	bit 5	-	printer uses (_FORMFEED/SINGLE SHEET)
*	bit 4	-	port to send output to (_ATARI/EPSON)
*	bit 3	-	style of output (_DRAFT/FINAL)
*	bit 2	-	type of printer (_DOT MATRIX/DAISY WHEEL)
*	bit 1	-	type of ink (_MONOCHROME/COLOR)
*	bit 0	-	manufacturer (_ATARI/EPSON COMPATIBLE)
*
*	note all underscored settings are the default and are represented
*	by their corresponding bit set to "0"

pconfig:	ds.w	1

*	Note: Strictly FYI, as CONTERM has moved to STARTUP.S
*	console and terminal flag bits
*	bit 0 - keyclick enabled
*	bit 1 - repeat key function enabled
*	bit 2 - keyboard "^g" bell feature enabled
*	bit 3 - concatenate KBSHIFT to high byte/high word of buffered
*		long word keystroke enable


newtod:	ds.b	1	;handshaking flag for get time of day function


	.page
	.even
	.text

*************************************************************************
*	note:	lengthened printer strobe on time and inserted printer	*
*		redirection code 9/11/85 dbg				*
*************************************************************************
*	note:	french key translation tables modified 8/29/85 dbg	*
*************************************************************************
*									*
*		basic input/output subsystem				*
*		copyright 1984, atari corporation			*
*		all rights reserved.					*
*		atari confidential					*
*									*
*************************************************************************
*************************************************************************
*									*
*	convert ikbd real-time clock format to jdos format		*
*									*
*************************************************************************

jdostime:
	lea	clkrec.w,a0
	bsr	bcdbin
	subi.b	#80,d0		;adjust so that 1980 => 0 for time base
	move.b	d0,d2
	asl.l	#4,d2

	bsr	bcdbin
	add.b	d0,d2
	asl.l	#5,d2

	bsr	bcdbin
	add.b	d0,d2
	asl.l	#5,d2

	bsr	bcdbin
	add.b	d0,d2
	asl.l	#6,d2

	bsr	bcdbin
	add.b	d0,d2
	asl.l	#5,d2

	bsr	bcdbin
	lsr.b	d0		;adjust to provide two second increments...
	add.b	d0,d2		;...another @!#%@#$% kludge, thank you !
	move.l	d2,datetime.w
	move.b	#$0,newtod.w	;clear handshaking flag
	rts

*************************************************************************
*									*
*		get time of day						*
*									*
*	entry:								*
*									*
*	long	gettime()						*
*									*
*************************************************************************

	.globl	gettime

gettime:
	move.b	#-1,newtod.w	;set handshaking flag
	move.b	#gettod,d1	;send get time of day command
	bsr	ikbdput
	move.l	_hz_200.w,a0	; use an A register for
	add.w	#200,a0		; cheap sign-extension (1 sec timeout)
	moveq.l	#0,d0		; return 0.l if we time out
gtod1:	cmp.l	_hz_200.w,a0	; has 1 sec elapsed?
	bcs	gtod2		; give up: no time is coming
	tst.b	newtod.w	;see if the new time of day is in yet...
	bne.b	gtod1
	move.l	datetime.w,d0
gtod2:	rts

*************************************************************************
*									*
*		set time of day						*
*									*
*	entry:								*
*									*
*	void	settime(newtime)					*
*	long	newtime							*
*									*
*************************************************************************

	.globl	settime

settime:
	move.l	4(sp),newtime.w

*************************************************************************
*									*
*	convert jdos format to ikbd real-time clock format		*
*									*
*************************************************************************

	.globl	ikbdtime

ikbdtime:
	lea	oclkrec+clkdex,a0	;point to end of output clock buffer
	move.l	newtime.w,d2	;get time to convert
	move.b	d2,d0		;make a copy for conversion routine
	andi.b	#%00011111,d0	;mask off for pertinent information
	asl.b	d0		;correct for the two second kludge
	bsr.b	binbcd		;convert
	lsr.l	#5,d2		;shift to next information field

	move.b	d2,d0		;make a copy for conversion routine
	andi.b	#%00111111,d0	;mask off for pertinent information
	bsr.b	binbcd		;convert
	lsr.l	#6,d2		;shift to next information field

	move.b	d2,d0		;make a copy for conversion routine
	andi.b	#%00011111,d0	;mask off for pertinent information
	bsr.b	binbcd		;convert
	lsr.l	#5,d2		;shift to next information field

	move.b	d2,d0		;make a copy for conversion routine
	andi.b	#%00011111,d0	;mask off for pertinent information
	bsr.b	binbcd		;convert
	lsr.l	#5,d2		;shift to next information field

	move.b	d2,d0		;make a copy for conversion routine
	andi.b	#%00001111,d0	;mask off for pertinent information
	bsr.b	binbcd		;convert
	lsr.l	#4,d2		;shift to next information field

	move.b	d2,d0		;make a copy for conversion routine
	andi.b	#%01111111,d0	;mask off for pertinent information
	bsr.b	binbcd		;convert
	addi.b	#$80,(a0)	;re-correct for ikbd format from jdos kludge

	move.b	#settod,d1	;send set time-of-day command to ikbd
	bsr	ikbdput		;use "inner circle" entry point!
	moveq	#clkdex-1,d3	;prepare to send new parameters
	lea	oclkrec,a2	;point to parameter list to be sent
	bsr	ikbdstr		;again, use an "inner circle" entry point!
	move.b	#gettod,d1	;send get time-of-day command to ikbd
	bsr	ikbdput		;use "inner circle" entry point!
	rts


*************************************************************************
*									*
*	BINBCD	convert a byte from binary to bcd format		*
*									*
*	entry:	d0.b  - value						*
*		NOTE: No Error Check for Input > 99.			*
*									*
*************************************************************************

	.globl	binbcd

binbcd:
	moveq	#0,d1
	move.b	d0,d1
	divs	#10,d1
	asl	#4,d1
	move	d1,d0
	swap	d1
	add	d1,d0
	move.b	d0,-(a0)	;transfer to output clock buffer
	rts

*************************************************************************
*									*
*		convert a byte from bcd format to binary		*
*									*
*	entry:	a0.l  - pointer to byte					*
*									*
*************************************************************************

	.globl	bcdbin

bcdbin:
	move.b	(a0)+,d0
	move.b	d0,d1
	and	#$0f,d0		* lo-nybble
	and	#$0f0,d1
	asr	#4,d1		* hi-nybble to lo-nybble
	mulu	#10,d1		* 10 * (hi-nybble)
	add	d1,d0		* d0 = 10*(hi-nybble) + lo-nybble
	rts

*************************************************************************
*									*
*		midi output status					*
*									*
*	entry:								*
*									*
*	word	midiost()						*
*									*
*	returns true/okay to send = -1,  false/not ready = 0		*
*									*
*************************************************************************

	.globl	midiost

midiost:
	moveq	#-1,d0		;pre-set to true
	move.b	comstat+midi.w,d2	;grab midi status
	btst.l	#$1,d2
	bne.b	midiox		;status okay to send
	moveq	#$0,d0		;status not okay
midiox:	rts

*************************************************************************
*									*
*		write char to midi port					*
*									*
*	entry:								*
*									*
*	void	midiwc(chr)						*
*	word	chr							*
*									*
*************************************************************************

	.globl	midiwc

midiwc:
	move.w	6(sp),d1
midiput:
	lea	midi.w,a1	;point to midi register base
midput1:
	move.b	comstat(a1),d2	;grab midi status
	btst.l	#$1,d2
	beq.b	midput1
	move.b	d1,iodata(a1)
	rts			;done for now


*************************************************************************
*									*
*		put string to midi routine				*
*									*
*	entry:								*
*									*
*	void	midiws(size,ptr)					*
*	word	size							*
*	long	ptr							*
*									*
*************************************************************************

	.globl	midiws

midiws:
	moveq	#$0,d3
	move.w	4(sp),d3	;get size of string buffer - 1
	move.l	6(sp),a2	;get string address
midp1:
	move.b	(a2)+,d1
	bsr.b	midiput
	dbra	d3,midp1
	rts

*************************************************************************
*									*
*		get midi receiver buffer status				*
*									*
*	entry:								*
*									*
*	word	midstat()						*
*									*
*	-1 signifies true/okay  0 - signifies false/no characters	*
*									*
*************************************************************************

	.globl	midstat

midstat:
	lea	mbufrec.w,a0	;point to midi i/o bufrec
	lea	midi.w,a1	;point to midi register base
	moveq	#-1,d0		;set result to true
	lea	bufhead(a0),a2
	lea	buftail(a0),a3
	cmpm.w	(a3)+,(a2)+	;atomic buffer empty test
	bne.b	midist1		;branch if not, assume d0 is "clr.w"'ed
	moveq	#$0,d0		;set result to false
midist1:
	rts


*************************************************************************
*									*
*		getchar routine for midi port				*
*									*
*	this routine transfers characters from a input queue that is	*
*	filled by an automatic interrupt routine.  the interrupt	*
*	routine handles the actual transfer of the character from the	*
*	i/o port.							*
*									*
*	entry:								*
*									*
*	long	midin()							*
*									*
*	long data returned represents upper three bytes of time stamp	*
*	and least significant byte as data				*
*									*
*************************************************************************

	.globl	midin

midin:

*	assume that a0/a1 are inited by the midstat call for the rest of
*	this routine.

	bsr.b	midstat		;see if key pressed
	tst.w	d0
	beq.b	midin		;wait until byte comes in
	move	sr,-(sp)	;protect this upcoming test
	ori	#$700,sr
	move.w	bufhead(a0),d1	;get current head pointer offset from buffer
	cmp.w	buftail(a0),d1	;head=tail?
	beq.b	mwi2		;yes

*	check for wrap of pointer

	addq.w	#1,d1		;i=h+1
	cmp.w	bufsize(a0),d1	;? i>= current bufsiz?
	bcs.b	mwi1		;no...
	moveq	#$0,d1		;wrap pointer
mwi1:	move.l	bufptr(a0),a1	;get base address of buffer
	and.l	#$0000ffff,d1	;d1.l = (unsigned long)d1.w
	moveq.l	#0,d0		;pre-clear return value (10/91)
	move.b	0(a1,d1.l),d0	;get character
	move.w	d1,bufhead(a0)	;store new head pointer to buffer record
mwi2:	move	(sp)+,sr
	rts

*************************************************************************
*									*
*		parallel i/o port service routine			*
*									*
*	this set of routines is for general parallel i/o		*
*									*
*	entry to listout						*
*									*
*	entry to listin							*
*									*
*	exit from listin						*
*									*
*************************************************************************

	.globl	_lstout

_lstout:
*
*	redirection code added 9/11/85 to take advantage of redirection bit
*
	btst	#4,pconfig.w	;check for I/O redirection of users output
	bne	_auxout		;bit was set, so send output to rs-232 port
*
*
	move.l	_hz_200.w,d2	; d2 = hz_200 - prt_to
	sub.l	prt_to.w,d2	; (compute time since last timeout)
	cmpi.l	#5*200,d2	; do "fake" timeout if we timed out within
	bcs.b	lperr		; the last five seconds

	move.l	_hz_200.w,d2	; d2 = starting time for this char
pt0:	bsr	_lstostat	;go get parallel port status
	tst.w	d0		;...and check for high (busy)
	bne.b	pt1		; port is ready -- print the char

	move.l	_hz_200.w,d3	; d3 = hz_200 - d2
	sub.l	d2,d3
	cmpi.l	#30*200,d3	; check for 30 second delta
	blt.b	pt0		; continue if no timeout

lperr:	moveq	#$0,d0		; return value of 0 indicates timeout
	move.l	_hz_200.w,prt_to.w	; record time of last timeout
	rts

pt1:	move.w	sr,d3		;save status register
	ori.w	#$700,sr	;protect upcoming switching of the port setting
	moveq	#mixer,d1	;get current io enable register contents
	bsr	gientry
	ori.b	#$80,d0	 	;set port b for output
	move.b	#mixer+$80,d1	;set to write to io enable ;;q
	bsr	gientry
	move.w	d3,sr		;restore status register

	move.w	6(sp),d0	;retrieve byte to be sent and...
	move.b	#portb+$80,d1	;write out byte to parallel port ;;q
	bsr	gientry

* go to IPL 7 for duration of strobe, so vblank (etc) can't make it too long.
* added 11/2/88 AKP
	move.w	sr,-(sp)
	or.w	#$700,sr
	bsr.b	strobeon
	bsr.b	strobeon	;9/11/85 added second call just to satisfy
*				;timing requirements of some off brand printer
	bsr.b	strobeoff
	move.w	(sp)+,sr
	moveq	#-1,d0		;set d0=-1 for good transfer status
lexit:	rts

strobeoff:
	moveq	#%00100000,d2	;set strobe off
	bra	onbit	 	;go set it!!

strobeon:
	move.b	#%11011111,d2	;set strobe on ;;q
	bra	offbit		;set strobe now...


	.globl	_lstin

_lstin:
	moveq	#mixer,d1	;get current io enable register contents
	bsr	gientry
	andi.b	#$7f,d0	 	;set port b for input
	move.b	#mixer+$80,d1	;set to write to io enable ;;q
	bsr	gientry

	bsr.b	strobeoff	;busy off!
lstibusy:
	bsr.b	_lstostat	;go get parallel port status
	tst.w	d0		;...and check for high (busy)
	bne.b	lstibusy	;loop till high...
	bsr.b	strobeon
	moveq	#portb,d1	;init to use gientry routine to read
	bra	gientry	 	;now get the byte from the parallel port
*				;d0.l contains the byte of data from the port
*	the 'bra' is implied rts from this routine

*************************************************************************
*									*
*		parallel port status routine				*
*									*
*************************************************************************
	.globl	_lstostat

_lstostat:
	lea	mfp,a0	 	;point to mfp register base
	moveq	#-1,d0		;pre-init to true (parallel port ready)
	btst.b	#$0,gpip(a0)
	beq.b	lst1
	moveq	#$0,d0		;parallel port busy
lst1:	rts



*************************************************************************
*									*
*		auxillary port input status routine			*
*									*
*************************************************************************

	.globl	auxistat

auxistat:
	lea	ribufptr.w,a0	* ptr to RS232 input buffer record

* entry point used by ttistat
inscommon:
	moveq	#-1,d0		* Assume not Empty
	lea	bufhead(a0),a1
	lea	buftail(a0),a0
	cmpm.w	(a0)+,(a1)+	* Atomic Compare
	bne.b	instxit
	moveq	#0,d0		* Input Buffer Empty
instxit:
	rts

*************************************************************************
*									*
*		auxillary input routine					*
*									*
* 02/18/87	Conform to old spec where we put at tail and pull	*
*		from the head. The tail points to the LAST char to	*
*		enter the buffer.					*
*************************************************************************

	.globl	auxin

auxin:
	lea	ribufptr.w,a0	* ptr to RS232 input buffer record
	lea	mfp,a2		* ptr to MFP

* entry point used by ttin, auxin; a0=iorec, a2=mfp (used by kickstart)

incommon:
	bsr	getbyte
	move.w	d0,-(sp)	* Save Input Char.

	tst.b	rsmode(a0)
	beq	xinxit
	move.w	buftail(a0),d0	* IF (Flow Control On) THEN Check Buffer
	sub.w	bufhead(a0),d0
	bpl	xinflo
	add.w	bufsize(a0),d0	* d0 = #bytes Used in Input Buffer
xinflo:	cmp.w	buflow(a0),d0
	bgt	xinxit
	tst.b	rxoff(a0)
	beq	xinxit		* IF (Low-Water AND (Rx OFF)) THEN Control Flow
	bsr	aux_rxok
xinxit:
	move.w	(sp)+,d0
	rts

* aux_rxok: called by incommon when buf was rxoff'ed and drops below
* the low-water mark, but also called by rsconf when you change
* rsmode.  a0=iorec, a2=mfp (used by kickstart).

aux_rxok:
	clr.b	rxoff(a0)
	btst.b	#0,rsmode(a0)
	bne	xinxon		* IF (RTS/CTS Flow Control)
	bra	rtson		* THEN Assert RTS (bra=bsr/rts)
	
xinxon:	move.b	#xon,sendnow(a0)
	bra	kickstart	* (bra=bsr/rts)

*************************************************************************
*									*
*		auxillary port output status routine			*
*									*
*************************************************************************

	.globl	_auxostat

_auxostat:
	lea	robufptr.w,a0	* ptr to RS232 output buffer record

* entry point used by _ttostat
ostcommon:
	move.w	buftail(a0),d1
	bsr	bumptr
	moveq	#-1,d0		* Assume Buffer Room Remains
	cmp.w	bufhead(a0),d1
	bne	ostxit
	moveq	#0,d0		* .. Bad Assumption
ostxit:	rts

*************************************************************************
*									*
*		auxillary output routine				*
*									*
*************************************************************************

	.globl	_auxout

_auxout:
	move.w	6(sp),d0	* get data
	lea	robufptr.w,a0	* ptr to RS232 output buffer record
	bsr	putbyte
	lea	ribufptr.w,a0	* set up regs for kickstart
	lea	mfp,a2

*
*	NOTE: Fall Thru to KICKSTART for Exit!!
*


*
*	KICKSTART   Start Transmission as Needed
*
*	Given:
*		a0 = iorec
*		a2 = mfp base address
*
*	Returns:
*		Transmitter Enabled
*
*	Register Usage:
*		d0, d1 destroyed
*
*	Externals:
*		sender
*
kickstart:
	tst.b	tsr(a2)
	bpl	kikxit		* IF (MFP Empty) THEN
	move	sr,-(sp)
	ori	#$700,sr	* Lock-Out Interrupts
	bsr	sender		* Kick-Start the MFP Interrupt Channel
	move	(sp)+,sr
kikxit:	rts


*************************************************************************
*									*
*		ikbd output status					*
*									*
*	entry:								*
*									*
*	word	ikbdost()						*
*									*
*	returns true/okay to send = -1,  false/not ready = 0		*
*									*
*************************************************************************

	.globl	ikbdost

ikbdost:
	moveq	#-1,d0		;pre-set to true
	move.b	comstat+keyboard,d2	;grab ikbd status
	btst.l	#$1,d2
	bne.b	ikbdox		;status okay to send
	moveq	#$0,d0		;status not okay
ikbdox:
	rts

*************************************************************************
*									*
*		write char to ikbd port					*
*									*
*	entry:								*
*									*
*	void	ikbdwc(chr)						*
*	word	chr							*
*									*
* Update:								*
*	Once ikbd has cleared the character from the acia delay 1/100	*
*	of a sec so that the ikbd can digest the char.			*
*	(Actually, we delay 5ms which is 1/200 sec; long enough. AKP)	*
*									*
*	Ikbdws below calls this code at the entry point ikbdput;	*
*	it assumes that registers d3 and a2 are not clobbered here.	*
*									*
*************************************************************************

	.globl	ikbdwc

ikbdwc:
	move.w	6(sp),d1
ikbdput:
	lea	keyboard,a1	;point to ikbd register base
ikput1:
	move.b	comstat(a1),d2	;grab keyboard status
	btst.l	#$1,d2
	beq.b	ikput1		; not ready

.if (TT == 0)
*
* We used to wait 5ms using a trick.  There were two bugs in that trick,
* one in design and one in implementation.  So here's a new trick.
* 
* Assume that Timer C is still set up the way we set it up: counting down
* from $C0 every 5ms (200Hz).  To wait one tick, we read the countdown
* register and wait for it to change.  To wait 5ms, we do this 192 times.
* We might wait MORE than 5ms this way (if we miss some transitions) but
* we'll never wait less.
*
	lea	mfp+tcdr,a0
	move.w	#191,d0		; do this loop 192 times
ikput2:	move.b	(a0),d2		; get a value
ikput3:	cmp.b	(a0),d2		; changed?
	beq	ikput3		; no - loop
	dbra	d0,ikput2	; yes - load a new value and loop
.else
	move.w	#$0400,d0	; 256 * 20us = 5ms
	bsr	ttwait
.endif
	move.b	d1,iodata(a1)	; now put character
	rts			;done for now


*************************************************************************
*									*
*		put string to ikbd routine				*
*									*
*	entry:								*
*									*
*	void	ikbdws(size,ptr)					*
*	word	size							*
*	long	ptr							*
*									*
* This code calls a hidden entry point in ikbdwc above, called		*
* ikbdput.  Ikbdput may not touch registers a2 or d3.  (Sigh - AKP)	*
*									*
*************************************************************************

	.globl	ikbdws

ikbdws:
	move.w	4(sp),d3
	move.l	6(sp),a2
ikbdstr:
	move.b	(a2)+,d1
	bsr.b	ikbdput
	dbra	d3,ikbdstr
	rts


	.globl	constat

constat:
	lea	kbufrec.w,a0	;point to ikbd buffer record
	moveq	#-1,d0		;set result to true
	lea	bufhead(a0),a2
	lea	buftail(a0),a3
	cmpm.w	(a3)+,(a2)+	;atomic buffer empty test
	bne.b	const1		;branch if not, assume d0 is "clr.w"'ed
	moveq	#$0,d0		;set result to false
const1:
	rts

*
* conin	Console input
*
	.globl	conin

conin:
	bsr.b	constat		;see if key pressed
	tst.w	d0
	beq.b	conin		;wait until key pressed
	move	sr,-(sp)	;protect this upcoming test
	ori	#$700,sr
	move.w	bufhead(a0),d1	;get current head pointer offset from buffer
	cmp.w	buftail(a0),d1	;head=tail?
	beq.b	cwi2		;yes

*	check for wrap of pointer

	addq.w	#4,d1		;i=h+4
	cmp.w	bufsize(a0),d1	;? i>= current bufsiz?
	bcs.b	cwi1		;no...
	moveq	#$0,d1		;wrap pointer
cwi1:	move.l	bufptr(a0),a1	;get base address of buffer
	and.l	#$0000ffff,d1	;d1.l = (unsigned long)d1.w
	move.l	0(a1,d1.l),d0	;get character
	move.w	d1,bufhead(a0)	;store new head pointer to buffer record
cwi2:	move	(sp)+,sr
	rts


	.globl	conoutst

conoutst:
	moveq	#-1,d0
	rts			;jdos requirement

*************************************************************************
*									*
*	routine to set up the general interrupt port registers		*
*		(gpip,are,ddr)						*
*									*
*	algorithm to set up the port					*
*									*
*	1. mask off all interrupts via the imrx registers;		*
*	2. clear all enable and pending bits in the ierx and iprx	*
*		registers;						*
*	3. check the interrupt in-service registers and loop till	*
*		clear;							*
*	4. init the aer register bits as desired (default = 11111111);	*
*	5. init the ddr register bits as desired (default = 10000000);	*
*	6. clear the gpip register;					*
*	7. enable all desired interrupt enable bits;			*
*	8. mask on all desired interrupt mask bits;			*
*									*
*									*
*************************************************************************

	.globl	initmfp

initmfp:
	lea	mfp,a0		;init mfp address pointer

	moveq	#$0,d0		;init to zero for clearing mfp
	movep.l	d0,gpip(a0)	;clear gpip thru iera
	movep.l	d0,ierb(a0)	;clear ierb thru isrb
	movep.l	d0,isrb(a0)	;clear isrb thru vr

	move.b	#$48,vr(a0)	;set mfp autovector and s-bit
	bset.b	#2,aer(a0)	* NOTE: Trigger on Withdrawn CTS

.if TT
	lea	ttmfp,a0	; init TT mfp
	moveq.l	#0,d0
	movep.l	d0,gpip(a0)	; clear TT_gpip thru TT_iera
	movep.l	d0,ierb(a0)	; clear TT_ierb thru TT_isrb
	movep.l	d0,isrb(a0)	; clear isrb thru vr

	move.b	#$58,vr(a0)	; set vector base to $140 and s-bit
.endif

*	init the "b" timer
* This must be initialized with a value other than one, so noblank
* and noblank1 don't wait forever.  God help you if you program the
* timer to a one, then call something which calls noblank!

	clr.b	tbdr		; any value but one is ok here.

*	init the "c" timer

	move.w	#$1111,tc_rot.w	;setup bitstream for /4 on timer c interrupt
	move.w	#20,_timr_ms.w	;set timer calibration value

	moveq	#ctimer,d0	;set to timer C
	moveq	#$50,d1		;set to /64 for 200 hz tick
	move.w	#192,d2		;set to 192
	bsr	setimer		;setup timer and init interrupt vector.....

	lea	timercint,a2	;point to the timer C interrupt routine...
	moveq	#$5,d0		;point to the timer C interrupt number
	bsr	initint

*	init the "d" timer

	moveq	#dtimer,d0	;select the d timer
	moveq	#c9600,d1	;init for /4 for 9600 baud
	moveq	#d9600,d2	;init for 9600 baud
	bsr	setimer		;branch to our timer initialier...
	move.b	#$1,(brate+ribufptr).w	;9600 is baud rate number 1

*	now init the 3 rs232 chip registers
*	(reload a0 with ST MFP base)
*
* 10/89	The init value for tsr was 01, now 05: this means the output state
* 	when the transmitter is enabled but idle is "high" not "Hi-Z"
*	(open collector)... This (finally!) gets rid of the spurious
*	$ff which used to be transmitted when you reset an ST.
*
*	Also, I've added initializing the TTMFP's port and set it to 9600 too.
*	TTMFP has no control lines, so that doesn't matter.
*	The TT's two SCC channels are initialized here, too.
*

	lea.l	mfp,a0
	move.l	#$00880105,d0
	movep.l	d0,scr(a0)	;inits scr,ucr,rsr,tsr

.if TT
	lea.l	ttmfp,a0
	move.l	#$00880105,d0
	movep.l	d0,scr(a0)

	move.b	#c9600,ttmfp+tcdcr	; clobbers TTMFP Timer C...
	move.b	#d9600,ttmfp+tddr
	move.b	#1,(brate+ttribufptr).w	; save in ttmfp's iorec
.endif

	tst.b	_iamanst		; if you're an ST don't do this
	bne	noscc
	bsr	_setupscc		; initialize the SCC controller
noscc:

*	initialize the default rs-232 control line settings

	bsr	dtron
	bsr	rtson

*	initialize the rs-232 buffer record structure

	lea	ribufptr.w,a0
	lea	rs232init,a1
	moveq	#rssize,d0
	bsr	lbmove		;do block move

.if TT
* initialize the rs-232 buffer record structure for TTMFP
	lea	ttribufptr.w,a0
	lea	ttrs232init,a1
	moveq	#rssize,d0
	bsr	lbmove
.endif

*	initialize the midi buffer record structure

	lea	mbufrec.w,a0
	lea	minit,a1
	moveq	#mssize,d0
	bsr	lbmove		;do block move and return

*	mark the altkp accumulator as invalid
	move.w	#-1,altkp

	move.l	#aciaexit,d0
	move.l	d0,vkbderr.w	;init keyboard error handler address
	move.l	d0,vmiderr.w	;init midi error handler address
	move.l	#sysmidi,midivec.w	;point to user midi interrupt vector
	move.l	#vecmidi,midisys.w	;point to system midi interrupt vector
	move.l	#vecikbd,ikbdsys.w	;point to system ikbd interrupt vector
	move.l	#itsakey,ikbdkey.w	;point to "itsakey"

*	init the midi acia next

	move.b	#rsetacia,comstat+midi	;init the acia via master reset

* init the acia to divide by 16x clock, 8 bit data, 1 stop bit, no parity,
* rts low, transmitting interrupt disabled, receiving interrupt enabled

	move.b	#div16+protocol+rtsld+intron,comstat+midi

*	initialize the keyboard acia interrupt vector exception address

	move.b	#%00000111,conterm.w	;enable keyclick,repeat key,bell functions, disable the KBSHIFT concatenation.

	move.l	#jdostime,clkintvec.w
	move.l	#genrts,d0	;generalized rts for ikbd subsystems
	move.l	d0,statintvec.w
	move.l	d0,msintvec.w	;init user mouse interrupt adr to rts
	move.l	d0,joyintvec.w

* init the Bconmap system
	bsr	mapinit

*
*  Sound routine initialization
*
*initsnd:
	moveq	#$0,d0			;init 'd0' to clear sound variables
	move.l	d0,cursnd.w		;clear sound ptr
	move.b	d0,timer.w		;clear delay timer
	move.b	d0,auxd.w		;clear temp value
	move.l	d0,prt_to.w		;init printer timout to 0

	bsr	strobeoff		;init strobe to off (line high!)
	move.b	#tdelay1,cdelay1.w	;init system default key repeat values
	move.b	#tdelay2,cdelay2.w

* within the mouse relative routine

*	initialize the ikbd buffer record structure

	lea	kbufrec.w,a0
	lea	kinit,a1
	moveq	#kssize,d0
	bsr.b	lbmove		;do block move and return

	bsr	bioskeys		;point key translation address to
*					;the rom based translation tables

*	init the acia next

	move.b	#rsetacia,comstat+keyboard	;init the acia via master reset

* now that the vector is initialized, we can allow interrupts to occur!
* init the acia to divide by 64 clock, 8 bit data, 1 stop bit, no parity,
* rts low, transmitting interrupt disabled, receiving interrupt enabled

	move.b	#div64+protocol+rtsld+intron,comstat+keyboard

        move.l  #mfpvectr,a3    ;point to initializing array of exception vec's
        moveq   #$3,d1          ;init branch counter/index
st1:     move.l  d1,d2
        move.l  d1,d0           ;load in interrupt # to setup
	addi.b	#$9,d0		;add constant to point to proper mfp interrupt
        asl.l   #2,d2
        move.l	0(a3,d2),a2
        bsr     initint         ;go to service routine
	dbra	d1,st1
	lea	midikey,a2
        moveq   #$6,d0          ;load in interrupt # to setup
        bsr     initint         ;go to service routine

	lea	ctsint,a2	;point to the CTS interrupt routine...
	moveq	#$2,d0		;point to the CTS interrupt number
	bsr	initint

.if TT
* initialize TTMFP interrupts

	move.l	#ttmfpvectr,a3
	move.w	#ttmfpibase+$24,a0	; +$24 is rs232 tx err vector

	move.l	(a3)+,(a0)+		; copy four vectors
	move.l	(a3)+,(a0)+
	move.l	(a3)+,(a0)+
	move.l	(a3)+,(a0)+

	or.b	#%00011110,ttmfp+iera	; enable RS232 ints
	or.b	#%00011110,ttmfp+imra	; and unmask them
.endif

genrts:	rts

lbmove:
	move.b	(a1)+,(a0)+
	dbra	d0,lbmove
	rts			;and return home

kinit:
	dc.l	kibuffer
	dc.w	kinsize
	dc.w	0
	dc.w	0
	dc.w	kinsize/4
	dc.w	kinsize*3/4

kssize	equ	*-kinit-1

minit:
	dc.l	mibuffer
	dc.w	minsize
	dc.w	0
	dc.w	0
	dc.w	minsize/4
	dc.w	minsize*3/4

mssize	equ	*-minit-1

	.even

rs232init:
	dc.l	ribuffer	;ibufptr
	dc.w	rbufsize	;ibufsiz
	dc.w	0		;ibufhead
	dc.w	0		;ibuftail
	dc.w	rbufsize/2	;ibuflow
	dc.w	rbufsize*3/4	;ibufhigh

	dc.l	robuffer	;obufptr
	dc.w	rbufsize	;obufsiz
	dc.w	0		;obufhead
	dc.w	0		;obuftail
	dc.w	rbufsize/2	;obuflow
	dc.w	rbufsize*3/4	;obufhigh

	dc.b	0		;rsrbyte (or "status")
	dc.b	0		;tsrbyte
	dc.b	0		;rxoff
	dc.b	0		;txoff
	dc.b	1		;rsmode -- Flow Control ON
	dc.b	0		;sendnow
	dc.b	1		;brate: 9600 baud
	dc.b	$ff		;mask: keep all bits

rssize	equ	*-rs232init-1
        .even


mfpvectr:

*	array of exception vector addresses for the above interrupts, including
*	dummy vectors that point to "rte's".

	dc.l	txerror
	dc.l	txrint
	dc.l	rxerror
	dc.l	rcvrint


*************************************************************************
*									*
*			routine to setup a timer			*
*									*
*	algorithm to init a timer					*
*									*
*	1. determine which timer and set d0.b = to timer's index value	*
*	   as shown below;						*
*	2. disable the associated interrupt;				*
*	3. disable the timer itself via it's timer control register;	*
*	4. initialize the timer's data register				*
*	5. repeat step #4 until the data register's contents are	*
*	   verified, per the errata sheet to the 68901 description;	*
*	6. turn on the timer by using the value that you previously	*
*	   stored in d1;						*
*									*
*	note:	the interrupt vector for the associated timer		*
*		is not set in this routine, so it is the user's		*
*		responsiblity to set it if so desired!			*
*									*
*									*
*	registers used:		d0-d3/a0-a3				*
*	registers saved:	d0-d3/a0-a3				*
*	entry:								*
*		d0.l - timer to be set					*
*			0 - timer a					*
*			1 - timer b					*
*			2 - timer c					*
*			3 - timer d					*
*		d1.b - timer's new control setting			*
*		d2.b - timer's data register data			*
*									*
*	exit:	no values to pass					*
*									*
*		d3   - used and abused by call to mskreg routine	*
*		a0.l - set to mfp register base				*
*		a1.l - temporary location for a3			*
*		a2.l - used to pass table address to mskreg routine	*
*		a3.l - used to pass table address to mskreg routine	*
*									*
*************************************************************************

	.globl	setimer

setimer:
	movem.l	d0-d4/a0-a3,-(sp)	;save all registers to be messed with!!
	move.l	#mfp,a0		;set mfp chip address pointer

	move.l	#imrt,a3	;mask off the timer's interrupt maskable bit
	move.l	#imrmt,a2
	bsr.b	mskreg

	move.l	#iert,a3	;mask off the timer's interrupt enable bit
	move.l	#iermt,a2
	bsr.b	mskreg

	move.l	#iprt,a3	;mask off the timer's interrupt pending bit
	move.l	#iprmt,a2
	bsr.b	mskreg

	move.l	#isrt,a3	;mask off the timer's interrupt inservice bit
	move.l	#isrmt,a2
	bsr.b	mskreg

	move.l	#tcrtab,a3	;mask off the timer's control bits
	move.l	#tcrmsk,a2
	bsr.b	mskreg

	exg	a3,a1		;save address pointer for restoring control

	lea	tdrtab,a3	;initialize the timer data register
	moveq	#$0,d3		;to prevent false effective address generation
	move.b	0(a3,d0),d3
verify:
	move.b	d2,0(a0,d3)
	cmp.b	0(a0,d3),d2
	bne.b	verify

	exg	a3,a1		;grab that register address back
	or.b	d1,(a3)		;mask the timer control register value

	movem.l (sp)+,d0-d4/a0-a3	;restore all registers that were saved
	rts

*************************************************************************
*		generalize mask register bit(s) routine			*
*									*
*	entry								*
*	static	d0 - contains the timer #				*
*		d3 - used and abused					*
*		d4 - used and abused					*
*	static	a0 - mfp register base					*
*		a3 - points to table of similar timer registers		*
*	static	a2 - points to table of similar timer data values	*
*************************************************************************

mskreg:
	bsr.b	getmask
	move.b	(a2),d3		;grab mask now
	and.b	d3,(a3)		;and have masked off the desired bit(s)
	rts

getmask:
	moveq	#$0,d3		;to prevent false effective address generation
	adda	d0,a3		;have got pointer to mfp register now
	move.b	(a3),d3		;now have the address offset to mfp
	add.l	a0,d3
	movea.l d3,a3		;now have address pointing to desired mfp reg.
*				;now we get the mask to turn off interrupt
	adda	d0,a2		;have got pointer to mask now
	rts

iert:	dc.b	$6,$6,$8,$8
iprt:	dc.b	$A,$A,$C,$C
isrt:	dc.b	$E,$E,$10,$10
imrt:	dc.b	$12,$12,$14,$14

iermt:	dc.b	$df,$fe,$df,$ef
imrmt	equ	iermt
iprmt	equ	iermt
isrmt	equ	iermt

tcrtab:	dc.b	$18,$1a,$1c,$1c
tcrmsk:	dc.b	$0,$0,$8f,$f8
tdrtab:	dc.b	$1e,$20,$22,$24

	.even

*************************************************************************
*									*
*	initialize mfp interrupt via GEMDOS				*
*									*
*	entry								*
*									*
*	void	mfpint(numint,intvec)					*
*	word	numint							*
*	long	intvec							*
*									*
*									*
*************************************************************************

	.globl	mfpint

mfpint:
	move.w	4(sp),d0
*	move.l	6(sp),a0	*this was the may 29, 1985 release instruction
	move.l	6(sp),a2	;this is the correct instruction
	andi.l	#$f,d0		;to ensure masking of 0-$f

*************************************************************************
*									*
*	routine to init an mfp associated interrupt vector		*
*									*
*	algorithm							*
*									*
*	1. block the interrupt via it's mask bit;			*
*	2. disable the interrupt's enable and pending bits;		*
*	3. check the interrupt's in-service register and loop till	*
*	   clear;							*
*	4. init the interrupt's associated vector;			*
*	5. set the interrupt's enable bit;				*
*	6. set the interrupt's mask bit;				*
*									*
*	entry								*
*		d0 - contains interrupt # to affect			*
*		a2 - contains new vector address			*
*************************************************************************

initint:
	movem.l d0-d2/a0-a2,-(sp)	;save affected registers
	bsr.b	disint		;disable the interrupts
	move.l	d0,d2		;get a copy so as to determine where to...
	asl	#2,d2		;place the a2 address into the int. vector
	addi.l	#$100,d2	;interrupt vector addr = (4 * int) + $000100
	move.l	d2,a1		;transfer the calculated address to a register
	move.l	a2,(a1)		;...that can act upon it thus!<--vector init'ed
	bsr.b	enabint		;enable interrupts
	movem.l (sp)+,d0-d2/a0-a2	;restore affected registers
	rts

*************************************************************************
*									*
*		disable an mfp interrupt via GEMDOS			*
*									*
*	entry								*
*									*
*	void	jdisint(numint)						*
*	word	numint							*
*									*
*************************************************************************

	.globl	jdisint

jdisint:
	move.w	4(sp),d0
	andi.l	#$f,d0		;to ensure masking of 0-$f

*************************************************************************
*		interrupt disable routine				*
*************************************************************************

disint:
	movem.l d0-d1/a0-a1,-(sp)	;save affected registers
	lea	mfp,a0		;set mfp chip address pointer
	lea	imra(a0),a1	;set a1 for the mskoff routine
	bsr.b	bselect		;generate the appropriate bit to clear
	bclr	d1,(a1)		;and clear the bit...
	lea	iera(a0),a1	;set a1 for another mskoff call
	bsr.b	bselect
	bclr	d1,(a1)		;and clear the bit...
* 9/91: don't bclr in ipra - that insn doesn't work on this register.
	lea	isra(a0),a1	;now set up to check for interrupts in progress
	bsr.b	bselect		;get proper a/b version...
* This was "bclr d1,(a1)" but that's illegal when talking to the ISR's.
* Changed 9/89 to write all 1's except d1's bit.
* Fixed 9/91: we were clearing the bit we wanted and all the lower ones
* in the same ISR, using asl not rol.  Oops.
	move.b	#%11111110,d0	;;q
	rol.b	d1,d0
	move.b	d0,(a1)
	movem.l (sp)+,d0-d1/a0-a1	;restore affected registers
	rts

*************************************************************************
*									*
*	enable/re-enable an mfp interrupt via GEMDOS			*
*									*
*	entry								*
*									*
*	void	jenabint(numint)					*
*	word	numint							*
*									*
*************************************************************************

	.globl	jenabint

jenabint:
	move.w	4(sp),d0
	andi.l	#$f,d0		;to ensure masking of 0-$f

*************************************************************************
*		enable interrupt routine				*
*************************************************************************
enabint:
	movem.l d0-d1/a0-a1,-(sp)	;save affected registers
	lea	mfp,a0		;set mfp chip address pointer
	lea	iera(a0),a1	;set up to enable the interrupt enable bit
	bsr.b	bselect
	bset	d1,(a1)		;and set the bit...
	lea	imra(a0),a1	;set up to enable the interrupt enable bit
	bsr.b	bselect
	bset	d1,(a1)		;and set the bit...
	movem.l (sp)+,d0-d1/a0-a1	;restore affected registers
	rts

*************************************************************************
*									*
*	the following routine generates the appropriate bset/bclr #	*
*	for the interrupt # specified in d0.	valid interrupt #'s are	*
*	0 --> 15 as shown in the 68901 chip specification.  It also	*
*	selects between the ixra and the ixrb version of the register	*
*	as is appropriate.						*
*									*
*	entry	d0 - contains the interrupt number			*
*		a1 - contains the pointer to the "ixra" version of	*
*		     the interrupt byte to mask				*
*	exit		d0 - same as upon entry				*
*			d1 - contains the number of the bit		*
*************************************************************************

bselect:
	move.b	d0,d1		* Preserve d0
	cmpi.b	#8,d1
	blt	bslct0		* IF (Int# > 7)
	subq	#8,d1		* THEN Xform to Modulo 8
	rts
bslct0:	addq.l	#2,a1		* ELSE Point to Alternate Register Set
	rts

*************************************************************************
*									*
*		receiver buffer full interrupt routine			*
*		gets data from the rs-232 receiver port			*
*									*
* 02/18/87	Conform to old spec where we put at tail and pull	*
*		from the head. The tail points to the LAST char to	*
*		enter the buffer.					*
*************************************************************************
rcvrint:
	movem.l	d0-d1/a0-a2,-(sp)
	lea	ribufptr.w,a0
	lea	mfp,a2

* entry point used by ttrcvrint
rcvrcommon:
	move.b	rsr(a2),status(a0)	* rsr read required before udr read
	move.b	udr(a2),d0		* d0.b = incoming data byte

	btst.b	#0,rsmode(a0)
	beq	rcvrput		* IF (Xon/Xoff Flow Control) THEN Examine Input
	cmpi.b	#xoff,d0
	bne	rcvr1
	move.b	#-1,txoff(a0)	* IF ("xoff") THEN Stop Transmission
	bra	rcvrxit
rcvr1:	cmpi.b	#xon,d0
	bne	rcvrput
	clr.b	txoff(a0)	* IF ("xon") THEN Resume Transmission
	bra	rcvrkick

rcvrput:
	move.w	buftail(a0),d1
	bsr	bumptr
	cmp.w	bufhead(a0),d1
	beq	rcvrxit		* IF (NOT Buffer Full)
	bsr	putbyte		* THEN Add Byte to Input Buffer

	tst.b	rsmode(a0)
	beq	rcvrxit
	move.w	buftail(a0),d0	* IF (Flow Control On) THEN Check Buffer
	sub.w	bufhead(a0),d0
	bpl	rcvr2
	add.w	bufsize(a0),d0	* d0 = #bytes Used in Input Buffer
rcvr2:	cmp.w	bufhigh(a0),d0
	blt	rcvrxit
	tst.b	rxoff(a0)
	bne	rcvrxit		* IF (High-Water AND (Rx ON)) THEN Control Flow
	move.b	#-1,rxoff(a0)
	btst.b	#0,rsmode(a0)
	bne	rcvxof		* IF (RTS/CTS Flow Control)
	bsr	rtsoff		* THEN Withdraw RTS (NOT Ready to Receive)
	bra	rcvrxit
rcvxof:	move.b	#xoff,sendnow(a0)	* ELSE Send "Xoff"
rcvrkick:
	tst.b	tsr(a2)
	bpl	rcvrxit		* IF (MFP Empty) THEN
*				* a0,a2 are already set up for sender
	bsr	sender		* Kick-Start the MFP Xmitter Interrupt
rcvrxit:
*	bclr.b	#4,isra(a2)	* Reset Interrupt
	move.b	#%11101111,isra(a2)	; was bclr but that's wrong
	movem.l	(sp)+,d0-d1/a0-a2
	rte

*************************************************************************
*									*
*	transmit buffer empty interrupt routine				*
*									*
*************************************************************************
txrint:
	movem.l	d0-d1/a0-a2,-(sp)
	lea	mfp,a2
	lea	ribufptr.w,a0	* load up queue pointer for sender

* entry point used by tttrxint
txrcommon:
	bsr	sender		* Send a Byte from Output Buffer

*	bclr.b	#2,isra(a2)	* Reset Interrupt
	move.b	#%11111011,isra(a2)	; was bclr but that's wrong
	movem.l	(sp)+,d0-d1/a0-a2
	rte

*************************************************************************
*									*
*		Clear-To-Send interrupt routine				*
*									*
*									*
*************************************************************************
ctsint:
	movem.l	d0-d1/a0-a2,-(sp)
	lea	ribufptr.w,a0
	lea	mfp,a2
	btst.b	#1,rsmode(a0)
	beq	ctsxit		* IF (RTS/CTS Flow Control Enabled) THEN

	btst.b	#2,gpip(a2)
	bne	ctsoff		* IF (CTS Asserted)
	clr.b	txoff(a0)	* THEN Re-Enable Transmission
	bset.b	#2,aer(a2)	* Falling Edge Trigger
	tst.b	tsr(a2)
	bpl	ctsxit		* IF (MFP Empty) THEN
*				* a0,a2 already set up for sender
	bsr	sender		* Kick-Start the MFP Xmitter Interrupt
	bra	ctsxit

ctsoff:	move.b	#-1,txoff(a0)	* ELSE Disable Transmission
	bclr.b	#2,aer(a2)	* Rising Edge Trigger

ctsxit:
*	bclr.b	#2,isrb(a2)	* Reset Interrupt
	move.b	#%11111011,isrb(a2)	; was bclr but that's wrong
	movem.l	(sp)+,d0-d1/a0-a2
	rte

*************************************************************************
*	routines to handle tx or rx errors				*
*************************************************************************
rxerror:
	movem.l	d0/a0,-(sp)
	lea	mfp,a0

* entry point used by ttrxerror
rxecommon:
	move.b	rsr(a0),rsrbyte	* Save Receiver Error Status
	move.b	udr(a0),d0	* dummy read
*	bclr	#$3,isra(a0)	* Clear Interrupt
	move.b	#%11110111,isra(a0)	; was bclr but that's wrong
	movem.l	(sp)+,d0/a0
	rte

txerror:
	move.l	a0,-(sp)
	lea	mfp,a0

* entry point used by tttxerror
txecommon:
	move.b	tsr(a0),tsrbyte	* Save Transmitter Error Status
*	bclr	#$1,isra(a0)	* Clear Interrupt
	move.b	#%11111101,isra(a0)	; was bclr but that's wrong
	move.l	(sp)+,a0
	tst.b	tsr+mfp			; dummy read per 68901 book
	rte

*
*	SENDER   Send a Byte from the Output Buffer to the MFP
*
*	Given:
*		a0 = iorec base pointer
*		a2 = MFP Base Pointer
*
*	Returns:
*		Data Sent as Needed
*
*	Register Usage:
*		d0, d1, and a1 destroyed
*
*	Externals:
*		getbyte
*
* 2/18/87	works properly with getbyte modification
* 5/01/90 akp	sends XOFF (via sendnow) even if txoff.

sender:
	move.l	a0,-(sp)
	move.b	sendnow(a0),d0
	beq	sendbuf
	clr.b	sendnow(a0)
	bra	sendwt

sendbuf:
	move.b	rsmode(a0),d0
	and.b	txoff(a0),d0
	bne	sendone		* IF (Flow-Control AND Xoff) THEN Skip
	
	add.w	#(robufptr-ribufptr),a0	* ELSE Send Char From Output Buffer
	move	bufhead(a0),d0
	cmp	buftail(a0),d0
	beq	sendone		* IF (Buffer NOT Empty) THEN
	bsr	getbyte		* Get Byte from Output Buffer

sendwt:	tst.b	tsr(a2)		* WHILE (Xmit Buffer Full) DO Wait
	bpl	sendwt
	move.b	tsr(a2),tsrbyte	* Save Transmitter Status
	move.b	d0,udr(a2)	* Put to MFP
sendone:
	move.l	(sp)+,a0
	rts


*
*	PUTBYTE   Put a Byte Into the Indicated Buffer
*
*	Given:
*		d0 = data byte
*		a0 = ptr to Buffer I/O Record
*
*	Register Usage:
*		a1 and d1 destroyed
*
*	Externals:
*		bumptr
*
* 02/18/87	Conform to old spec where we put at tail and pull
*		from the head. The tail points to the LAST char to
*		enter the buffer. The Head points to the byte BEFORE the
*		char to send.
*
putbyte:
	move.w	buftail(a0),d1
	jsr	bumptr
putwait:
	cmp.w	bufhead(a0),d1
	beq	putwait		* WHILE (Buffer Full) DO Wait
	move.l	bufptr(a0),a1
	and.l	#$0000ffff,d1	; d1.l = (unsigned long)d1.w
	move.b	d0,(a1,d1.l)	* Put to tail
	move.w	d1,buftail(a0)	* Update Tail to Index Last Received Byte
	rts


*
*	GETBYTE   Get a Byte From the Indicated Buffer
*
*	Given:
*		a0 = ptr to Buffer I/O Record
*
*	Returns:
*		d0 = Data Byte (word)
*		Head Bumped
*
*	Register Usage:
*		d1 and a1 destroyed
*
*	Externals:
*		bumptr
*
* 02/18/87	Conform to old spec where we put at tail and pull
*		from the head. The tail points to the LAST char to
*		enter the buffer, the head to the byte BEFORE the char
*		to send.
*
getbyte:
	move.w	bufhead(a0),d1	* REPEAT
	cmp.w	buftail(a0),d1
	beq	getbyte		* UNTIL (Buffer NOT Empty)
	bsr	bumptr		* Now we index byte to send
	move.l	bufptr(a0),a1	* a1 -> output buffer
	moveq	#0,d0
	and.l	#$0000ffff,d1	; d1.l = (unsigned long)d1.w
	move.b	(a1,d1.l),d0	* d0 = data byte from head
	move.w	d1,bufhead(a0)	* Bump Head Index to byte BEFORE char to send
	rts


*
*	RTSON	Enable RTS Signal From GI Chip
*
*	Given:
*		nothing
*
*	Returns:
*		nothing
*
*	Register Usage:
*		d1 and a1 trashed.
*
*	Externals:
*		none
*
rtson:
	lea	giselect,a1
	move	sr,-(sp)
	ori	#$700,sr	* Disable Interrupts
	move.b	#porta,(a1)	* Select Port A
	move.b	(a1),d1		* Read
	and.b	#$0f7,d1	* Clear Bit
	move.b	d1,2(a1)	* Write
	move	(sp)+,sr	* Re-Enable Interrupts
	rts


*
*	RTSOFF	Disable RTS Signal From GI Chip
*
*	Given:
*		nothing
*
*	Returns:
*		nothing
*
*	Register Usage:
*		d1 and a1 trashed.
*
*	Externals:
*		none
*
rtsoff:
	lea	giselect,a1
	move	sr,-(sp)
	ori	#$700,sr	* Disable Interrupts
	move.b	#porta,(a1)	* Select Port A
	move.b	(a1),d1		* Read
	ori.b	#$8,d1		* Set Bit
	move.b	d1,2(a1)	* Write
	move	(sp)+,sr	* Re-Enable Interrupts
	rts


*
*	BUMPTR   Bump Pointer -- Increment an Index (circularly)
*
*	Given:
*		a0 = ptr to Buffer I/O Record
*		d1 = Index to Bump
*
*	Returns:
*		d1 = Updated Index
*
*	Register Usage:
*		d1 altered
*
*	Externals:
*		none
*
bumptr:
	addq.w	#1,d1
	cmp.w	bufsize(a0),d1
	bcs	bumxit		* Unsigned blt
	moveq	#0,d1		* Wraparound
bumxit:	rts



*************************************************************************
*									*
*		get device buffer record				*
*									*
*	entry:								*
*									*
*	long	iorec(device)						*
*	word	device							*
*									*
*	returns pointer to the device's buffer record table		*
*									*
*		device - buffer identification number			*
*			0 - rs232					*
*			1 - ikbd					*
*			2 - midi					*
*			3 - parallel (not really used)			*
*									*
*		device table structure:					*
*									*
*		input buffer address		long			*
*		input buffer size		word			*
*		input buffer head		word			*
*		input buffer tail		word			*
*		input buffer low-water mark	word			*
*		input buffer high-water mark	word			*
*									*
*		output buffer address		long			*
*		output buffer size		word			*
*		output buffer head		word			*
*		output buffer tail		word			*
*		output buffer low-water mark	word			*
*		output buffer high-water mark	word			*
*									*
*************************************************************************

*
* For TT, if the argument is 0 (for RS232), we read the current mapping
* from the variable mapiorec, which is maintained by Bconmap.
*

	.globl	iorec

iorec:
	move.w	4(sp),d1
	beq	auxiorec
	asl.l	#2,d1			;x4=index into devtab space
	move.l	devtab(pc,d1.w),d0	;get device bufrec pointer
	rts

auxiorec:
	move.l	mapiorec.w,d0
	rts

devtab:
	dc.l	ribufptr		; not used for TT
	dc.l	kbufrec
	dc.l	mbufrec

*************************************************************************
*									*
*		configure rs-232 port of MFP				*
*									*
*	entry:								*
*									*
*	long	rsconf(baudrate,flow,ucr,rsr,tsr,scr)			*
*									*
*	word	baudrate - baud rate setting (table index to get	*
*		value for timer D control and data registers) 		*
*									*
*	word	flow -	flow control:	xxxxxxhs			*
*			h - cts/rts/dtr					*
*			s - software xon/xoff				*
*			1 - on, 0 - off					*
*	word	ucr -	MFP ucr register setting			*
*	word	rsr -	MFP rsr register setting			*
*	word	tsr -	MFP tsr register setting			*
*	word	scr -	MFP scr register setting			*
*									*
*	Arguments with value -1 mean "no change" to the corresponding	*
*	setting.							*
*									*
*	If baudrate is -2, the current baud rate is returned.  That is,	*
*	the last nonnegative baudrate value passed to this function.	*
*	(No other arguments are needed, and no changes are made.)	*
*									*
*	Otherwise, returns the old ucr,rsr,tsr,src settings in the	*
*	four bytes of D0.L.						*
*	(THIS WAS ALWAYS THE CASE but was only documented for 4/88.)	*
*									*
* 									*
* This routine has always been broken: the fourth parameter writes to	*
* the SCR byte, but the low-order byte in the return value reads  the	*
* UDR register, so it isn't symmetrical.  Since nobody does synchronous	*
* I/O or uses this call to read the UDR anyway, it's been redocumented	*
* as "should always be -1 on input" and a "don't care" on output.	*
* (Actually using Rsconf causes a spurious read of the UDR, which COULD	*
* cause loss of a pending character, but only if it arrives while at	*
* IPL 7.  This is not likely, and when you're fooling with Rsconf you	*
* aren't in a critical section anyway.  Some rationalization!)  This	*
* involves no code change.						*
* 									*
*************************************************************************

*
* For TT, to accomodate Bconmap, rsconf is a stub which dispatches to
* the function pointer in maprsconf.  For the STMFP port (default),
* this points to auxrsconf.  For not TT, the main routine
* is called rsconf.
*

	.globl	rsconf
	.globl	maprsconf

rsconf:
	move.l	maprsconf.w,a0
	jmp	(a0)

auxrsconf:
	lea.l	ribufptr.w,a0
	lea.l	mfp,a2
*	bra	rscommon	* FALL THROUGH

*
* rscommon: common rsconf entry point for STMFP and TTMFP.
*
* EXPECTS: a0=iorec, a2=mfp.
* RETURNS: see above for rsconf return values
*

rscommon:
	moveq.l	#0,d0		;pre-clear hi word of return value
	cmp.w	#-2,4(sp)	;check for special case: rsconf(-2)
	bne	auxnorm		;no: act normally
	move.b	brate(a0),d0
	rts

auxnorm:
	ori.w	#$700,sr	;no interrupts for now (restored at rte)

*
*	first, we grab the old ucr,rsr,tsr,scr contents
*

	movep.l	ucr(a2),d7

*
*	set flow control mode(s)
*
* I broke this code in TOS 1.4 such that you could never set CTS/RTS
* flow control.  The behavior of this code now is that 0 sets no flow
* control, 1 sets XON/XOFF, 2 sets RTS/CTS, 3 sets XON/XOFF (all as before).
* ANY OTHER VALUE IS NO-OP.  Previously, some other values set XON/XOFF
* and others set no flow control. -1 is the only documented,
* guaranteed no-op, though.
*
* Enabling tx and rx now means setting only the enable bit, not the whole
* byte.  This preserves the status of the other mode bits.
*

	move.w	$6(sp),d0
	cmp.w	#3,d0
	bhi	auxc1		; if d0 unsigned greater than 3 then no-op.
	bne	auxc0		; if d0 not equal to 3 then set mode to d0.
	moveq.l	#1,d0		; else it's three, so set XON/XOFF as before.
auxc0:	cmp.b	rsmode(a0),d0	; is this a change?
	beq	auxc1		; no.

* Changing rsmode (at all!) clears txoff (makes it OK to send) 
* and rxoff (means sending XON or raising RTS if necessary).
* (new as of 5/90)
* 
* NOTE: this is done at IPL 7, so we shouldn't be getting race conditions
* like characters received before we write rsmode's new value.

	move.w	d0,-(sp)	; save new mode while checking

	tst.b	txoff(a0)	; stopped sending?
	beq	auxc0a
	clr.b	txoff(a0)	; start sending
	bsr	sender
auxc0a:
	tst.b	rxoff(a0)	; need to send XON or raise RTS?
	beq	auxc0b		; no.
	bsr	aux_rxok
auxc0b:
	move.w	(sp)+,d0	; get new mode off stack (as word!)
	move.b	d0,rsmode(a0)	; write it (as byte!)

*	set timer baud rate

auxc1:
	tst.w	$4(sp)		;if -1 then don't change
	bmi.b	auxc2
*
*	next, we disable the receiver and transmitter enable bits
*
	bclr.b	#0,rsr(a2)	;disable the receiver
	bclr.b	#0,tsr(a2)	;disable the transmitter

	move.w	$4(sp),d1
	move.b	d1,brate(a0)	;shadow baud rate value now
	move.b	baudctrl(PC,d1.w),d0
	move.b	bauddata(PC,d1.w),d2

	and.b	#%01110000,tcdcr(a2)	; stop the timer
	move.b	d2,tddr(a2)
	or.b	d0,tcdcr(a2)		; start the timer with the new rate

*
*	finally we re-enable the receiver and transmitter enable bits
*
	bset.b	#0,rsr(a2)	;enable the receiver
	bset.b	#0,tsr(a2)	;enable the transmitter

*	set rs-232 registers

auxc2:	tst.w	$8(sp)		;if -1 then don't change
	bmi.b	auxc3
	move.b	$9(sp),ucr(a2)
auxc3:	tst.w	$a(sp)		;if -1 then don't change
	bmi.b	auxc4
	move.b	$b(sp),rsr(a2)
auxc4:	tst.w	$c(sp)		;if -1 then don't change
	bmi.b	auxc5
	move.b	$d(sp),tsr(a2)
auxc5:	tst.w	$e(sp)		;if -1 then don't change
	bmi.b	auxc6
	move.b	$f(sp),scr(a2)
auxc6:
	move.l	d7,d0		;move old contents of rs-232 registers to d0.l

	rts

*	baudrate table - control register setting

baudctrl:
	dc.b	c19200,c9600,c4800,c3600
	dc.b	c2400,c2000,c1800,c1200
	dc.b	c600,c300,c200,c150
	dc.b	c134,c110,c75,c50

*	baudrate table - data register setting

bauddata:
	dc.b	d19200,d9600,d4800,d3600
	dc.b	d2400,d2000,d1800,d1200
	dc.b	d600,d300,d200,d150
	dc.b	d134,d110,d75,d50


.even
.text

**********************************************************************
*
* new console device routines (collectively called BCONMAP)
*
* There are new Bconin/out/stat/ostat device numbers on a TT: 
*
*     devno	meaning
*
*	6	ST-compatible serial port (default).
*	7	SCC Channel B (port 2 on the back of a TT).
*	8	TTMFP serial port (3-wire, not normally wired).
*	9	SCC Channel A (full handshake, not normally wired).
*
* (On Mega STe, 8 is SCC Channel A, and there is no 9.  On other 
* machines, there is no 7-9.)
*
* Bcon calls on device 1 (normally AUX) might actually refer to
* any of these devices, or to a user-installed device (with an
* even higher devno).  You use Bconmap to change the mapping of
* device 1.  Bconmap also changes the mapping of Rsconf() calls, 
* and of Iorec calls with Iorec device number 0.
*
* LONG Bconmap(devno)
* WORD devno;
*
* Map "devno" in as Bcon* device number 1.  Return the old mapping.
* If devno is -1, there's no change; the current mapping is simply
* returned.  Legal values (currently) are 6-9. (9 is the maximum
* device number in ROM; you can have other values if you expand the
* table.)  
*
* If devno is -2, a pointer to the device mapping structure is returned.
* This is only used by programs which need to install new mappable
* handlers.
*
* Other values don't change anything, and return 0.
*
* The mapping is accomplished by writing into the (published) vector 
* table in low memory.  In addition, new indirect pointers are available
* for Iorec and Rsconf.
*
* Here's how it works:
* 
* The device vector tables for Bconin, out, etc. are in low RAM. Bconmap
* changes the contents of those vectors for device 1 (AUX). Bconmap's
* mapping structure is as follows:
* 
* 	struct bconmap {
* 		LONG *maptab;		/* ptr to map table (see below)	*/
* 		WORD maptabsize;	/* number of lines in the table	*/
* 		WORD curmap;		/* device currently mapped in	*/
* 		LONG maprsconf;		/* procedure pointer for Rsconf	*/
* 		LONG mapiorec;		/* value returned by Iorec(0)	*/
* 	};
* 
* The last three entries of this table are private; all users need to
* know about are the first two.
*
* The map table contains a line for each device.  Each line contains
* pointers to the Bconstat, Bconin, Bcostat, and Bconout routines, plus
* the Rsconf routine, plus the Iorec pointer.  The table's size (the
* number of devices) is in maptabsize.  maptabsize is used by all Bcon calls
* to range-check the device number.
* 
* ----------------------------------------------------------------------
*
* A Bconmappable driver must have Bconstat, Bconin, Bcostat, and Bconout
* entry points, plus an iorec, plus an Rsconf function pointer.  You
* install it by writing it into the table pointed to by maptab.  You can
* either overwrite an existing driver (not recommended) or expand the
* table and add your driver. You can expand the table by copying
* it into a larger space, then changing maptab and maptabsize.  You should
* watch out for installing a driver which is already the one currently
* installed.  When installing a brand new driver this isn't a problem,
* but when clobbering an existing driver you should use Bconmap to
* be sure that isn't the current one.
*
* Rsconf args are interpreted for the new devices; the bits which make
* sense are used, the others discarded.  Nothing is returned
* (except in the -2 case, where the last baud rate is returned).
*
* The bits in the Rsconf args which we emulate on the SCC are as follows:
*
* UCR:	bits 6-5: word-length (00=8, 01=7, 10=6, 11=5)
* 	bits 4-3: start/stop (00=n/a, 01=1/1, 10=1/1.5, 11=1/2)
*	bit 2:	  parity (0=no, 1=yes)
*	bit 1:	  parity (0=odd, 1=even)
*
* RSR:	(none: only enable & synch strip are read-write)
*
* TSR:	bit 3:	  break (sends break while 1)
*	(bits 2-1 are transmitter-idle state, bit 0 is enable)
*
* SCR:	(none: this is the synch character register)
*
**********************************************************************

* imports

.globl xconstat

* exports

.globl _bconmap

*
* The bconmap structure:
*

.bss
maptab:		ds.l	1	; pointer to map table
maptabsize:	ds.w	1	; size of map table (number of devices)
curmap:		ds.w	1	; currently-mapped device
maprsconf:	ds.l	1	; current Rsconf procedure pointer
mapiorec:	ds.l	1	; current return value for Iorec(0)

* initially, the map table goes here.  It's filled in by mapinit
defmaptab:	ds.l	$18 * deftabsize

*
* Rom-default filling for maptab.
*
* These get stuffed into the area at xconstat in (published) low RAM.
* Rsconf gets stuffed into maprsconf, and that's used to dispatch
* Rsconf calls.
*
* The last entry here is not a routine pointer, it's an iorec pointer.
* It gets stuffed into the variable mapiorec, and that variable is returned
* as the value of an Iorec(0) call.
*

.text

.if TT
imapvecs:
	dc.l	auxistat,auxin,_auxostat,_auxout,auxrsconf,ribufptr
	dc.l	bistat,bin,bostat,bout,brsconf,chbibufptr
	dc.l	ttistat,ttin,_ttostat,_ttout,ttrsconf,ttribufptr
	dc.l	aistat,ain,aostat,aout,arsconf,chaibufptr

deftabsize	equ	4	; number of lines in imapvecs
defmap		equ	0	; index into imapvecs of ROM-default map

.else
* These are all used for STe; ST uses only the first row.
imapvecs:
	dc.l	auxistat,auxin,_auxostat,_auxout,auxrsconf,ribufptr
	dc.l	bistat,bin,bostat,bout,brsconf,chbibufptr
	dc.l	aistat,ain,aostat,aout,arsconf,chaibufptr

deftabsize	equ	3

* On Sparrow, the default device must be SCCB; the MFP ain't hooked up!
.if SPARROW
defmap		equ	1
.else
defmap		equ	0
.endif

.endif

**********************************************************************

_bconmap:
	moveq.l	#0,d0		; clear hi word of d0
	move.w	4(sp),d1	; get argument
	move.w	curmap.w,d0	; preload return value for -1
	cmp.w	#-1,d1		; Bconmap(-1) returns current map device
	beq	mapend		; just return old number if -1
	move.l	#maptab,d0	; preload return value for -2
	cmp.w	#-2,d1		; Bconmap(-2) returns ptr to bconmap
	beq	mapend		; he wants the pointer
	moveq.l	#0,d0		; preload error code (zero)
	subq.w	#6,d1
	bmi	mapend		; error if < 6
	cmp.w	maptabsize.w,d1
	bhs	mapend		; error if >= maptabsize

* no error; unmap current device (copy pointers into maptab)

	move.w	curmap.w,d1	; d2 = d1 * $18
	subq.w	#6,d1
	asl.w	#3,d1
	move.w	d1,d2
	add.w	d1,d1
	add.w	d1,d2

	move.l	maptab.w,a0
	add.w	d2,a0		; a0 -> base of old vectors

	lea.l	(xconstat+4).w,a1 ; a1 -> dev 1 constat vector
	move.l	(a1),(a0)+
	move.l	$20(a1),(a0)+
	move.l	$40(a1),(a0)+
	move.l	$60(a1),(a0)+
	move.l	maprsconf,(a0)+
	move.l	mapiorec.w,(a0)+

* now map in the new device

	move.w	4(sp),d1	; get new device number again
	subq.w	#6,d1		; d2 = d1 * $18
	asl.w	#3,d1
	move.w	d1,d2
	add.w	d1,d1
	add.w	d1,d2

	move.l	maptab.w,a0
	add.w	d2,a0		; a0 -> base of vectors

* a1 already points to dev 1 vector

	move.l	(a0)+,(a1)		; write Bconstat vector
	move.l	(a0)+,$20(a1)		; conin
	move.l	(a0)+,$40(a1)		; costat
	move.l	(a0)+,$60(a1)		; conout
	move.l	(a0)+,maprsconf.w	; rsconf
	move.l	(a0)+,mapiorec.w	; iorec

	move.w	curmap.w,d0		; get previous value for returning
	move.w	4(sp),curmap.w		; stuff in new curmap value

* old mapping value or error code must be in d0 now for returning

mapend:	rts

*
* mapinit: initialize the whole mapping system.
*
* This (re-)initializes xconstat etc. for device 1 (the mappable one).
*
* SPARROW: Sometime soon, Sparrows will arrive with SCC channel B as their
* one and only serial port.  For compatibility, I think we're going to use
* Bconmap to fake stuff out: it will look like a Mega STe, with STMFP, SCC
* B, and SCC A as your options, but SCC B is the only option you'll be
* allowed to choose.  I am most sorry about the impact this will have on
* users: to some extent, I don't care how hard programmers have to work.
* Currently (5/15/92) all Sparrows have STMFP as the serial port, so this
* code falls out correctly (but just barely).
*

mapinit:
	lea.l	defmaptab.w,a0
	move.l	a0,maptab.w
	move.w	#deftabsize,maptabsize.w

.if (TT == 0)
* We have to check now: if you're really an ST or STPLUS, not a Mega STe,
* we have to set maptabsize to 1, not 3.  We let everything else
* proceed apace.

ttscu1		equ	$ffff8e09

	moveq	#1,d0			; pre-load d0 for STPLUS
	move.l	sp,a1
	move.l	$8,a2
	move.l	#mapierr,$8
	tst.b	ttscu1
	move.w	#deftabsize,d0		; no error: on a Mega STe!
mapierr:
	move.l	a1,sp
	move.l	a2,$8
	move.w	d0,maptabsize.w		; set maptabsize to the right value
.endif

	lea.l	imapvecs(PC),a1

	move.w	#(6*deftabsize)-1,d0	; number of longs to move - 1
iloop:	move.l	(a1)+,(a0)+
	dbra	d0,iloop

	move.w	#(defmap+6),curmap.w

	lea.l	(imapvecs+(defmap*$18)),a1	; MAS BUG: don't use (PC)
	lea.l	(xconstat+4).w,a0
	move.l	(a1)+,(a0)
	move.l	(a1)+,$20(a0)
	move.l	(a1)+,$40(a0)
	move.l	(a1)+,$60(a0)
	move.l	(a1)+,maprsconf.w
	move.l	(a1)+,mapiorec.w

	rts

.if TT

**********************************************************************
*
* 
* This section contains the code to hook the TTMFP serial port in to the
* BIOS. It shares a lot of code with BIOS, including some utility
* routines (getbyte, bumptr) and some major routines (interrupt-level
* receive, transmit).  The common routines always use base registers
* which point to the appropriate MFP or IOREC structure.  Even though the
* code is common, the RTS/CTS code in the mainstream BIOS will never be
* used because it's disabled in the (TT-specific) Rsconf() call.  That
* takes care of the problem of having hard-coded PSG usage in the common
* code.
* 

*************************************************************************

	.globl	ttistat

ttistat:
	lea	ttribufptr.w,a0	* ptr to RS232 input buffer record
	bra	inscommon

*************************************************************************

	.globl	ttin

ttin:
	lea	ttribufptr.w,a0	* ptr to RS232 input buffer record
	lea	ttmfp,a2
	bra	incommon

*************************************************************************

	.globl	_ttostat

_ttostat:
	lea	ttrobufptr.w,a0	* ptr to RS232 output buffer record
	bra	ostcommon

*************************************************************************

	.globl	_ttout

_ttout:
	move.w	6(sp),d0	* get data
	lea	ttrobufptr.w,a0	* ptr to RS232 output buffer record
	bsr	putbyte
	lea	ttribufptr.w,a0
	lea	ttmfp,a2
	bra	kickstart

	.data
	.even

.globl ttmfpvectr
ttmfpvectr:
	dc.l	tttxerror
	dc.l	tttxrint
	dc.l	ttrxerror
	dc.l	ttrcvrint

ttrs232init:
	dc.l	ttribuffer	;ibufptr
	dc.w	rbufsize	;ibufsiz
	dc.w	0		;ibufhead
	dc.w	0		;ibuftail
	dc.w	rbufsize/2	;ibuflow
	dc.w	rbufsize*3/4	;ibufhigh

	dc.l	ttrobuffer	;obufptr
	dc.w	rbufsize	;obufsiz
	dc.w	0		;obufhead
	dc.w	0		;obuftail
	dc.w	rbufsize/2	;obuflow
	dc.w	rbufsize*3/4	;obufhigh

	dc.b	0		;rsrbyte (or "status")
	dc.b	0		;tsrbyte
	dc.b	0		;rxoff
	dc.b	0		;txoff
	dc.b	1		;rsmode -- Flow Control ON
	dc.b	0		;sendnow
	dc.b	1		;initial baud rate
	dc.b	$ff		;initial mask

        .even
	.text

*************************************************************************
*									*
*		ttmfp receiver buffer full interrupt routine		*
*		gets data from the rs-232 receiver port			*
*									*
*************************************************************************
ttrcvrint:
	movem.l	d0-d1/a0-a2,-(sp)
	lea	ttribufptr.w,a0
	lea	ttmfp,a2
	bra	rcvrcommon

*************************************************************************
*									*
*	ttmfp transmit buffer empty interrupt routine			*
*									*
*************************************************************************
tttxrint:
	movem.l	d0-d1/a0-a2,-(sp)
	lea	ttmfp,a2
	lea	ttribufptr.w,a0
	bra	txrcommon

*************************************************************************
*	routines to handle ttmfp tx or rx errors			*
*************************************************************************
ttrxerror:
	movem.l	d0/a0,-(sp)
	lea	ttmfp,a0
	bra	rxecommon

tttxerror:
	move.l	a0,-(sp)
	lea	ttmfp,a0
	bra	txecommon

*************************************************************************

	.globl	ttrsconf

ttrsconf:
	lea	ttribufptr.w,a0
	lea	ttmfp,a2
	bra	rscommon

**********************************************************************

.bss

*
*	TTMFP RS-232 Buffers and I/O Buffer Record
*
ttribuffer:	ds.b	rbufsize	;rs-232 input buffer
ttrobuffer:	ds.b	rbufsize	;rs-232 output buffer

*
*	TTMFP RS-232 I/O Buffer Record
*
.globl ttribufptr
ttribufptr:	ds.l	1		* Input Buffer Record
ttribufsiz:	ds.w	1
ttribufhead:	ds.w	1
ttribuftail:	ds.w	1
ttribuflow:	ds.w	1
ttribufhigh:	ds.w	1
*
*	NOTE: THESE TWO BUFFERS MUST REMAIN CONTIGUOUS
*		(Don't Thank Me, Thank Dave!)
*
ttrobufptr:	ds.l	1		* Output Buffer Record
ttrobufsiz:	ds.w	1
ttrobufhead:	ds.w	1
ttrobuftail:	ds.w	1
ttrobuflow:	ds.w	1
ttrobufhigh:	ds.w	1

ttrsrbyte:	ds.b	1		* Other Associated Variables
tttsrbyte:	ds.b	1
ttrirxoff:	ds.b	1
ttritxoff:	ds.b	1
ttrirsmode:	ds.b	1		* Bit 0 = Flow Control (0=Disabled)
*					* Bit 1 = Handshake (0=Disabled)
ttrisendnow:	ds.b	1
ttbrate:	ds.b	1		* saved baud rate for Rsconf(-2)
ttmask:		ds.b	1		; not used

.even
.text
.endif

*************************************************************************
*									*
* This section contains the code to hook the TT SCC ports into		*
* the Bconmap structure.  It should also be enabled because of STe's	*
* 8530's.  You'd better not call this when you're on ST.		*
*									*
* It's short-circuited if we're actually on a ST or STPLUS,		*
* because maptabsize is reset to 1, so this code is never called.	*
*									*
*************************************************************************

.macro LOG arg
*	move.l	#arg,([logger])
*	add.l	#4,logger
.endm

* DMA SCC control register - this is used only to zero the DMA control 
* so it's not active.

sccctl		equ	$ffff8c14	; DMA control

* SCC register equates

sccac		equ	$ffff8c81	; SCC1 A control (odd-byte)
sccad		equ	$ffff8c83	; SCC1 A data
sccbc		equ	$ffff8c85	; SCC1 B control
sccbd		equ	$ffff8c87	; SCC1 B data

* SCU locations for enabling interrupts
ttvmeintmsk	equ	$ffff8e0d	; "vme" int mask in SCU
ttsysintmsk	equ	$ffff8e01	; "st" int mask in SCU

sccvecval	equ	$60		; value to program for int vector
sccvecbase	equ	$180		; base of interrupt vectors

*
* In addition to the normal and extended fields in the iorec, scc iorecs
* use the 'status' byte to shadow the last incoming ucr from Rsconf,
* so they can return that value when asked; the next byte is wr5, 
* which must be shadowed so we can change pieces of it (e.g.
* word length, stop bits, send break) independently.
*

ucr_shadow	equ	status
wr5		equ	status+1

*
* macros to read/write registers in the SCC pointed to by a2
*

	.macro SCCw xreg,value
	move.b	xreg,(a2)
	move.b	value,(a2)
	.endm

	.macro SCCr xreg,dest
	move.b	xreg,(a2)
	move.b	(a2),dest
	.endm

**********************************************************************
* 
* sccinit: call this routine with inittab in a1 and the channel address
* in a0; the the table is register/value pairs, ending with a
* register number of -1.
*

sccinit:
	move.b	(a1)+,d0
	bmi	sccidone
	move.b	d0,(a0)
	move.b	(a1)+,(a0)
	bra	sccinit
sccidone:
	rts

**********************************************************************
*
* inittab: this table initializes the channel as a normal serial port
* at 9600 baud with rx, tx, and ext interrupts.  See brtab for
* derivation of the baud rate countdown value.
*

.text
inittab:
	dc.b	$4,$44
	dc.b	$1,%00000100	; parity is special condition
	dc.b	$2,sccvecval	; vector base $180
	dc.b	$3,%11000000	; 8 bits/char rx
	dc.b	$5,%11100010	; 8 bits/char tx, DTR on, RTS on
	dc.b	$6,$00
	dc.b	$7,$00
	dc.b	$9,$01		; vector includes status
	dc.b	$a,$00
	dc.b	$b,$50
	dc.b	$c,$18		; BR countdown low byte
	dc.b	$d,$00		; hi byte
	dc.b	$e,$02		; BR source is PCLK
* enables
	dc.b	$e,$03		; enable BR generator (copy plus %1)
	dc.b	$3,%11000001	; enable receiver (copy plus %1)
	dc.b	$5,%11101010	; enable transmitter (copy plus %1000)
*				; this number should also be the default wr5

* interrupts
	dc.b	$f,%00100000	; CTS IE
	dc.b	$0,$10		; reset ext/status
	dc.b	$0,$10		; and again
	dc.b	$1,%00010111	; int enables (tx,ext (like CTS))
	dc.b	$9,%00001001	; MIE, VIS
	dc.b	-1
.even
.text

**********************************************************************
*
* set the PSG bit which selects LAN vs NOT LAN to the NOT LAN position.
*
* On Sparrow, this bit is IDE reset.

.if (SPARROW == 0)
nolan:
	move.w	sr,d1
	or.w	#$0700,sr
	move.b	#porta,giselect
	move.b	giselect,d0
	bset	#7,d0
	move.b	#porta,giselect
	move.b	d0,giselect+2
	move.w	d1,sr
	rts
.endif

**********************************************************************
*
* _setupscc: entry point to set everything up.
*
* On TT's with no SCC DMA chip, even talking to the SCC chip will
* cause a bus error.  This code catches that error and returns,
* but you'd better not try to use the SCC ports for anything!
* This also short-circuits if you're on an STPLUS, not Mega STe.
*
* SPARROW has SCC but no SCU, meaning no ttvmeintmsk register.
* Sigh.
*

.globl _setupscc

_setupscc:
	move.l	$8,a0		; catch bus error
	move.l	sp,a1
	move.l	#sccberr,$8

* the next instruction causes a bus error on TT's that have no SCC
* capability (e.g. no SCC DMA chip), and on STe's, but works fine
* on real TT's and Mega STe's.

	tst.b	sccad		; read from data byte

	move.l	a0,$8		; un-catch bus error
	lea	sccvecbase,a0	; write interrupt vectors
	lea	intvecs(PC),a1
	moveq	#$f,d0
vloop:	move.l	(a1)+,(a0)+
	dbra	d0,vloop

.if TT
* the next instruction (clear sccctl) disables SCC DMA on TT, but
* can't be executed on (Mega-) STe because there's no SCC DMA chip.

	clr.w	sccctl		; disable DMA
.endif

.if (SPARROW == 0)
	bsr	nolan		; select DB9, not lan connector
.endif

* initialize the IORECs: write constant data to each, then change the
* two differences: the input and output buffer pointers

	lea.l	chaibufptr.w,a0
	lea.l	iorecinit(PC),a1
	moveq	#rssize+2,d0
	bsr	lbmove		; do block move
	lea.l	chbibufptr.w,a0
	lea.l	iorecinit(PC),a1
	moveq	#rssize+2,d0
	bsr	lbmove		; do block move
	move.l	#chbibuffer,chbibufptr.w	; fix up the differences
	move.l	#chbobuffer,chbobufptr.w

	lea.l	sccac,a2
	SCCw	#9,#%11000000	; software reset both channels

* wait four PCLK's after resetting SCC - something over 4us should do.
	move.w	#$0104,d0	; 4 * 1.6us > (4*PCLK)
	jsr	dowait

	lea.l	sccac,a0
	lea.l	inittab(PC),a1
	bsr	sccinit		; initialize channel A

	lea.l	sccbc,a0
	lea.l	inittab(PC),a1
	bsr	sccinit		; initialize channel B

*
* Sparrow has SCC but no ttvmeintmsk; otherwise all machines that have
* scc have this register.
*
.if (SPARROW == 0)
	bset.b	#5,ttvmeintmsk	; enable level 5 interrupts (SCC)
.endif
	rts

*
* Talking to SCC caused a bus error; catch it here, restore bus error
* vector, restore ssp, and return.
*

sccberr:
	move.l	a0,$8
	move.l	a1,sp
	rts

**********************************************************************
*
* Interrupt routines; these all save appropriate regs, load
* the channel pointer into a2, the iorec address into a0, then
* branch to the common handler for that interrupt.
*
* The "special" interrupts vector to the same address as the
* receive interrupts: the handling is the same (if you choose
* to ignore the special receive conditions, which we do).
*
* Furthermore, cts interrupts are handled (& ignored) even when
* RTS/CTS flow control is disabled; it would be better to disable
* this interrupt, but it complicates matters some.
*

intbtx:
	movem.l	d0-d1/a0-a2,-(sp)
	lea.l	sccbc,a2	; channel ptr
	lea.l	chbibufptr.w,a0	; iorec ptr
	bra	scctxempty	; jump to common handler

intbex:
	movem.l	d0-d1/a0-a2,-(sp)
	lea.l	sccbc,a2	; channel ptr
	lea.l	chbibufptr.w,a0	; iorec ptr
	bra	sccext		; jump to common handler

intbrx:
	movem.l	d0-d1/a0-a2,-(sp)
	lea.l	sccbc,a2	; channel ptr
	lea.l	chbibufptr.w,a0	; iorec ptr
	bra	sccrxfull	; jump to common handler

intbxx:
	movem.l	d0-d1/a0-a2,-(sp)
	lea.l	sccbc,a2
	lea.l	chbibufptr,a0
	bra	sccrxerr

intatx:
	movem.l	d0-d1/a0-a2,-(sp)
	lea.l	sccac,a2	; channel ptr
	lea.l	chaibufptr.w,a0	; iorec ptr
	bra	scctxempty	; jump to common handler

intaex:
	movem.l	d0-d1/a0-a2,-(sp)
	lea.l	sccac,a2	; channel ptr
	lea.l	chaibufptr.w,a0	; iorec ptr
	bra	sccext		; jump to common handler

intarx:
	movem.l	d0-d1/a0-a2,-(sp)
	lea.l	sccac,a2	; channel ptr
	lea.l	chaibufptr.w,a0	; iorec ptr
	bra	sccrxfull	; jump to common handler

intaxx:
	movem.l	d0-d1/a0-a2,-(sp)
	lea.l	sccac,a2
	lea.l	chaibufptr,a0
	bra	sccrxerr

**********************************************************************
*
* Common interrupt handlers begin here.
*

sccrxfull:
	LOG	"_RX_"
	SCCr	#8,d0		; read the incoming data byte
	and.b	mask(a0),d0	; AND with incoming byte mask
	btst.b	#0,rsmode(a0)	; XON/XOFF flow control?
	beq	rxins		; nope - add to buffer & return
	cmp.b	#xoff,d0	; XOFF?
	bne	notxoff		; no
	LOG	"rxof"
	st	txoff(a0)	; yes: set txoff so we stop sending
	bra	rxdone		; and exit

notxoff:
	cmp.b	#xon,d0		; XON?
	bne	rxins		; nope - add to buffer & return
	LOG	"rxon"
	tst.b	txoff(a0)	; yes: test and clear txoff
	sf	txoff(a0)	; clear txoff so we can send
	bne	rxkick		; go kick the transmitter if txoff was set

* no flow control, or not XON or XOFF
* (or XON when we hadn't received XOFF)
rxins:	move.w	buftail(a0),d1
	bsr	bumptr
	cmp.w	bufhead(a0),d1
	beq	rxdone		; buffer full - can't insert the char
	bsr	putbyte		; insert the char

	tst.b	rsmode(a0)	; any flow control?
	beq	rxdone		; nope - return
	tst.b	rxoff(a0)	; already tried shutting off flow?
	bne	rxdone		; yes - don't try again.

	move.w	buftail(a0),d0	; check for high water
	sub.w	bufhead(a0),d0
	bpl	rxnowrap
	add.w	bufsize(a0),d0
rxnowrap:
	cmp.w	bufhigh(a0),d0
	blt	rxdone		; not over high-water; quit.
	LOG	"high"
	st	rxoff(a0)	; say we've tried to stop flow
	btst.b	#0,rsmode(a0)	; flow mode XON/XOFF?
	bne	rxxoff		; yes - handle it
	move.b	wr5(a0),d0	; get last value written
	bclr	#1,d0		; clear RTS bit
	move.b	d0,wr5(a0)	; save in shadow
	SCCw	#5,d0		; write this new WR5 value
	bra	rxdone

rxxoff:	move.b	#xoff,sendnow(a0)
rxkick:	SCCr	#0,d0		; get status
	btst	#2,d0		; check tx buf empty
	beq	rxdone		; not empty - forget it
	LOG	"rkik"
	bsr	scc_sender	; empty - send already

* all receive interrupt handling ends up here
rxdone:
	SCCw	#0,#%00111000	; reset highest IUS
	LOG	"_rx_"
	movem.l	(sp)+,d0-d1/a0-a2
	rte

sccrxerr:
	LOG	"_RE_"
	SCCr	#1,d0		; read status (don't care what it is)
	SCCr	#8,d0		; read char (don't care what it is)
	SCCw	#0,#%00110000	; error reset
	bra	rxdone		; go reset highest IUS and rte.

**********************************************************************
*
* scc_sender -- routine to send a byte (either the one in sendnow
* or the next one from the buffer) out to the port.  This is called
* when the tx interrupt *might* already have come in and been cleared.
*
* If txoff and rsmode are set, this returns: tx while txoff is a nono!
* If device's tx buf not empty, returns (let the int level send it!).
* If sendnow is zero and obuffer is empty, returns.
* Else writes the char to the tx buf and returns.
*
* Addendum: if sendnow != 0, sends even if txoff flag is set, so you 
* can say XOFF even when host has said XOFF to you.
*
* INPUTS:	a0 -> iorec base pointer
*		a2 -> SCC base (for SCCr, SCCw macros)
*
* USES:		d0, d1, a1
*
* There was a bug here, in 2.06/3.06 and older: since the "transmitter
* empty" interrupt is higher priority than the "external status" interrupt
* (i.e. cts), a series of TE interlupts could come in to fill the tx fifo
* before getting the CTS interrupt.  Since scc_sender tested the software
* flag txoff, rather than the hardware state of the pin, this was a lose.
* Fix: check the hardware state of CTS.
*
* The txoff software flag is not actually checked if your flow mode is
* rts/cts.  It's still set & cleared by the cts interrupt handler, though.
*

scc_sender:
	LOG	"sndr"
	move.l	a0,-(sp)
	tst.b	sendnow(a0)
	bne	scc_notesttxoff

	btst.b	#0,rsmode(a0)	; xon/xoff?
	beq	scc_ckcts	; no - check for rts/cts mode
	tst.b	txoff(a0)	; yes - check txoff flag
	bne	scc_nodata	; txoff is set - don't send.

scc_ckcts:
	btst.b	#1,rsmode(a0)	; rts/cts flow control mode?
	beq	scc_notesttxoff	; no - don't test the txoff flag at all
	SCCr	#0,d0		; yes - get status register
	btst	#5,d0		; test CTS bit
	beq	scc_nodata	; it's low - don't send.
				; else it's high - fall through
scc_notesttxoff:
	SCCr	#0,d0
	btst	#2,d0		; abort if SCC tx buf not empty
	beq	scc_sdone	; (because tx int will come)
	move.b	sendnow(a0),d0	; use sendnow if not zero
	beq	scc_getc
	LOG	"snow"
	clr.b	sendnow(a0)	; clear sendnow (only send it once!)
	bra	scc_gotc
scc_getc:
	LOG	"sbuf"
	add.w	#(chaobufptr-chaibufptr),a0	; advance to output iorec
	move.w	bufhead(a0),d0
	cmp.w	buftail(a0),d0
	beq	scc_nodata	; abort if output buffer empty
	bsr	getbyte		; else get byte (to d0)
scc_gotc:
	SCCw	#8,d0		; write the char to xmit it
scc_nodata:
scc_sdone:
	move.l	(sp)+,a0
	rts

**********************************************************************
*
* tx buffer empty interrupt handler
*
* The 8530 book says to use "reset IUS" at the end of the routine,
* but I think that masks the interrupt caused when you write the first
* byte into an empty tx fifo - the int comes right away, and the
* subsequent "reset IUS" command clears it!
*

scctxempty:
	LOG	"_TX_"
	SCCw	#0,#%00101000	; clear the Tx int
	SCCw	#0,#%00111000	; reset highest IUS
	bsr	scc_sender
	LOG	"_tx_"
	movem.l	(sp)+,d0-d1/a0-a2
	rte

**********************************************************************
*
* external interrupt handler
*
* The only external interrupt which is enabled is CTS, and that is
* only enabled if you ask for it.  This simplifies external interrupt
* handling, as it means we don't have to save the state & compare against
* it to see what changed.
*
* Note that this is enabled even when not using rts/cts - wasteful, but
* shouldn't be so bad...

sccext:
	btst.b	#1,rsmode(a0)
	beq	ext_done
	SCCr	#0,d0		; get status register
	btst	#5,d0		; test CTS bit
	seq	txoff(a0)	; set txoff if CTS went low
	beq	ext_done	; if CTS now low, we're done
	bsr	scc_sender	; else call sender
ext_done:
	SCCw	#0,#%00010000	; reset ext/status interrupts
	SCCw	#0,#%00111000	; reset highest IUS
	movem.l	(sp)+,d0-d1/a0-a2
	rte

**********************************************************************
*
* Bconin, Bconout, Bconstat, Bcostat handlers for SCCs
*

.globl bistat
bistat:
	lea.l	chbibufptr.w,a0
	lea.l	sccbc,a2
	bra	sccistat

.globl bin
bin:	lea.l	chbibufptr.w,a0
	lea.l	sccbc,a2
	bra	sccin

.globl bostat
bostat:
	lea.l	chbibufptr.w,a0
	lea.l	sccbc,a2
	bra	sccostat

.globl bout
bout:
	lea.l	chbibufptr.w,a0
	lea.l	sccbc,a2
	bra	sccout

.globl aistat
aistat:
	lea.l	chaibufptr.w,a0
	lea.l	sccac,a2
	bra	sccistat

.globl ain
ain:
	lea.l	chaibufptr.w,a0
	lea.l	sccac,a2
	bra	sccin

.globl aostat
aostat:
	lea.l	chaibufptr.w,a0
	lea.l	sccac,a2
	bra	sccostat

.globl aout
aout:
	lea.l	chaibufptr.w,a0
	lea.l	sccac,a2
	bra	sccout

**********************************************************************

sccistat:
	moveq.l	#0,d0
	lea	bufhead(a0),a1
	lea	buftail(a0),a0
	cmpm.w	(a0)+,(a1)+
	beq	sccisdone
	moveq.l	#-1,d0
sccisdone:
	rts

**********************************************************************

sccostat:
	move.w	buftail(a0),d1
	bsr	bumptr
	cmp.w	bufhead(a0),d1
	beq	osfull
	moveq.l	#-1,d0
	rts
osfull:	moveq.l	#0,d0
	rts

**********************************************************************

sccin:
	LOG	"_IN_"
	bsr	getbyte
	move.w	d0,-(sp)
	tst.b	rsmode(a0)		; flow control?
	beq	indone			; no - done
	tst.b	rxoff(a0)		; flow stopped?
	beq	indone			; no - done

	move.w	buftail(a0),d0
	sub.w	bufhead(a0),d0
	bpl	innowrap
	add.w	bufsize(a0),d0
innowrap:
	cmp.w	buflow(a0),d0		; fallen below low water?
	bgt	indone			; no - done
	LOG	"unhi"

	bsr	scc_rxok
indone:	move.w	(sp)+,d0		; retrieve char
	LOG	"_in_"
	rts				; and return

**********************************************************************

scc_rxok:
	clr.b	rxoff(a0)		; yes - start flow again
	btst	#0,rsmode(a0)		; flow xon/xoff?
	beq	inrts			; no - it's rts/cts
	LOG	"sxon"
	move.b	#xon,sendnow(a0)	; yes - send xon
	bra	scckickstart		; go do kickstart (bra=bsr/rts)

inrts:	move.b	wr5(a0),d0		; get old wr5 value
	bset	#1,d0			; set RTS
	move.b	d0,wr5(a0)		; save shadow of new value
	SCCw	#5,d0			; write new value
	rts

**********************************************************************

sccout:
	LOG	"_OUT"
	move.w	6(sp),d0
	add.w	#(chaobufptr-chaibufptr),a0
	bsr	putbyte			; put the byte in the output buffer
	sub.w	#(chaobufptr-chaibufptr),a0

scckickstart:
	SCCr	#0,d0			; read status
	btst	#2,d0			; if tx buf not empty 
	beq	nokick			;   skip this
	LOG	"kick"
	move.w	sr,-(sp)		; save IPL
	or.w	#$0700,sr		; go to IPL 7
	bsr	scc_sender		; kick transmitter if necessary
	move.w	(sp)+,sr		; restore IPL
nokick:
	LOG	"_out"
	rts

**********************************************************************

.globl arsconf
arsconf:
	lea	chaibufptr.w,a0
	lea	sccac,a2
	bra	sccrsconf

.globl arsconf
brsconf:
	lea	chbibufptr.w,a0
	lea	sccbc,a2
*	bra	sccrsconf	; bra (to next insn)

sccrsconf:
	moveq.l	#0,d0		;pre-clear hi word of return value
	cmp.w	#-2,4(sp)
	bne	rsnorm
	move.b	brate(a0),d0
	rts

rsnorm:	or.w	#$700,sr	; no ints doing this (restore at RTE)

* set the appropriate bits in d7 for the return from this call:
* for UCR we return the value we saved from the last call to here;
* for TSR we return the "break" bit value from the shadowed wr5.

	moveq	#0,d7
	move.b	ucr_shadow(a0),d7
	asl.w	#8,d7
	swap	d7
	move.b	wr5(a0),d7
	lsr.b	#1,d7		; shift bit 4 into bit 3
	and.b	#%00000100,d7	; clear other bits - they are don't-cares
	asl.w	#8,d7		; shift to high byte of d7.w

* d7.l is now our return value; set rsmode if nonnegative
* See comments at rscommon for some detail.

	move.w	6(sp),d0
	cmp.w	#3,d0
	bhi	rs1		; unsigned >3 is no-op
	bne	rs0		; != 3 means set to this mode
	moveq	#1,d0		; else set xon/xoff
rs0:
	cmp.b	rsmode(a0),d0	; any change?
	beq	rs1		; no

	tst.b	txoff(a0)	; was tx stopped?
	beq	rs0a
	clr.b	txoff(a0)	; yes - clear flag...
	bsr	scc_sender	; ...and really start sending

rs0a:
	tst.b	rxoff(a0)
	beq	rs0b
	move.w	d0,-(sp)
	bsr	scc_rxok	; raise RTS, or send XON to allow sending
	move.w	(sp)+,d0
rs0b:
	move.b	d0,rsmode(a0)

* set baud rate
rs1:	move.w	4(sp),d0
	cmp.w	#$f,d0
	bhi	rs2		; unsigned >15 is no-op
	move.b	d0,brate(a0)
	asl.w	#1,d0		; *2 for word index
	lea.l	brtab,a1
	move.w	(a1,d0.w),d0	; get BR value
	SCCw	#$c,d0		; write low byte
	lsr.w	#8,d0
	SCCw	#$d,d0		; write high byte

* interpret bits in UCR: word length, number of stop bits, parity

rs2:	move.w	8(sp),d0
	bmi	rs3		; negative is no change

* save incoming ucr value in our iorec so we can return it later

	move.b	d0,ucr_shadow(a0)

* decode word-length bits 6-5

* We have 0,1,2 or 3 in bits 6-5 of d1.  These represent 8, 7, 6, and 5
* data bits, and, coincidentally, the number of 0's we need at the top
* of the mask.

	move.b	d0,d1		; get UCR argument
	and.b	#%01100000,d1	; get word-length bits
	lsr.b	#5,d1		; shift; now d2 is number of zeros we want
	moveq.l	#-1,d2		; preload $FF into d2.b
	lsr.b	d1,d2		; lsr.b shifts zeros in the top
	move.b	d2,mask(a0)	; save the mask

* mask is done; now mangle these bits from 68901 format to 8530 format
* (00->11, 01->01, 10->10, 11->00).

	move.b	d0,d1		; get UCR arg again
	and.b	#%01100000,d1	; get word-length bits
	beq	rsflip		; 00 and 11 must be flipped
	cmp.b	#%01100000,d1
	bne	rsnoflip
rsflip:	eor.b	#%01100000,d1
rsnoflip:
	move.b	wr5(a0),d2	; get shadow of wr5
	and.b	#%10011111,d2	; clear word-length bits
	or.b	d1,d2		; OR in new word-length bits
	move.b	d2,wr5(a0)	; save new value in shadow
	SCCw	#5,d2		; write new value

	asl.b	#1,d1		; shift word-length bits up
	or.b	#1,d1		; or in the Rx enable bit
	SCCw	#3,d1		; write rx word size & rx enable

* decode number of stop bits 4-3, plus parity enable (2) plus parity o/e (1)

	move.b	d0,d1
	and.b	#%00011110,d1
	lsr.b	#1,d1		; shift into position

* reverse the order of bits 0 and 1
	bclr	#1,d1		; clear-and-test bit 1
	sne	d2		; set d2 bit 0 to the result
	bclr	#0,d1		; clear-and-test
	bne	rs2a
	bclr	#1,d2
	bra	rs2b
rs2a:	bset	#1,d2
rs2b:	and.b	#%00000011,d2
	or.b	d2,d1		; d1 is now old d1 with bits 0,1 reversed.
	or.b	#%01000000,d1	; OR in the x16 clock value
	SCCw	#4,d1		; and write it to the chip

rs3:

*
* decode rsr (no-op)
*

*
* decode tsr: bit 3 means send break until you write a zero there.
*
* There was a bug here, where we used bit 3 of rsr, not tsr, to cause
* or clear the break condition.  Just a question of getting the wrong
* thing off the stack -- oops.
*
	move.w	$c(sp),d0
	bmi	rs4

	btst	#3,d0
	beq	rs3a

* user wants us to send break (no-op if already sending one)

	bset.b	#4,wr5(a0)	; test & set: was it set before?
	bne	rs4		; yes - this is no-op.
	SCCw	#5,wr5(a0)	; no - write new value
	bra	rs4		; done.

* user wants us to stop sending break (no-op if not sending one)

rs3a:	bclr.b	#4,wr5(a0)	; test & clear: was it clear before?
	beq	rs4		; yes - this is no-op.
	SCCw	#5,wr5(a0)	; no - write new value

rs4:

* finished with the things we can decode.  End of rsconf.

	move.l	d7,d0		; d7 is computed return value from above
	rts


**********************************************************************
*
* Tables that stuff is initilized from.
*
* These are in the text seg so they can be referenced as PC-relative
*

.text

*
* The baud rate table; these numbers are put in WR12/13 as the baud-rate
* countdown value.  They assume you have BR source = PCLK and /16,
* and that PCLK is 32215905Hz/4.
*
* The errors are wrt the ideal baud rate; they should be in spec for
* all devices, I guess.  You could get closer by using the other sources
* for the BR clock, but that would mean two tables, because the sources
* are different for channels A and B.
*

brtab:	dc.w	11	; 19200 -.83%
	dc.w	24	; 9600	-.83%
	dc.w	50	; 4800	-.83%
	dc.w	68	; 3600	+.12%
	dc.w	103	; 2400	+.12%
	dc.w	124	; 2000	+.12%
	dc.w	138	; 1800	+.12%
	dc.w	208	; 1200	+.12%
	dc.w	417	; 600	-.11%
	dc.w	837	; 300	+.005%
	dc.w	1256	; 200	-.03%
	dc.w	1676	; 150	+.005%
	dc.w	1869	; 134	-.01%
	dc.w	2286	; 110	-.002%
	dc.w	3354	; 75	+.005%
	dc.w	5032	; 50	+.005%

intvecs:	dc.l	intbtx,0,intbex,0,intbrx,0,intbrx,0
		dc.l	intatx,0,intaex,0,intarx,0,intarx,0

iorecinit:	dc.l	chaibuffer	; ibufptr
		dc.w	rbufsize	; ibufsiz
		dc.w	0,0		; ibufhead,ibuftail
		dc.w	rbufsize/2	; ibuflow
		dc.w	rbufsize*3/4	; ibufhi

		dc.l	chaobuffer	; ditto, obuf
		dc.w	rbufsize
		dc.w	0,0
		dc.w	rbufsize/2
		dc.w	rbufsize*3/4
		dc.b	%00001000	; ucr_shadow: 8bits/1stop/nopar/even
		dc.b	%11101010	; wr5 shadow: dtr/8bits/txen/rts
		dc.b	0,0		; rxoff,txoff
		dc.b	1,0		; flow,sendnow (rssize ends here)
		dc.b	1		; initial baud rate
		dc.b	$ff		; initial mask

**********************************************************************
*
* BSS
*

.bss

*
*	Channel A Buffers and I/O Buffer Records
*
chaibuffer:	ds.b	rbufsize	;rs-232 input buffer
chaobuffer:	ds.b	rbufsize	;rs-232 output buffer

*
*	Channel A I/O Buffer Record
*
.globl chaibufptr
chaibufptr:	ds.l	1		* Input Buffer Record
chaibufsiz:	ds.w	1
chaibufhead:	ds.w	1
chaibuftail:	ds.w	1
chaibuflow:	ds.w	1
chaibufhigh:	ds.w	1
*
*	NOTE: THESE TWO BUFFERS MUST REMAIN CONTIGUOUS
*		(Don't Thank Me, Thank Dave!)
*
chaobufptr:	ds.l	1		* Output Buffer Record
chaobufsiz:	ds.w	1
chaobufhead:	ds.w	1
chaobuftail:	ds.w	1
chaobuflow:	ds.w	1
chaobufhigh:	ds.w	1

charsrbyte:	ds.b	1		* Other Associated Variables
chawr5:		ds.b	1		* shadow of WR5
chairxoff:	ds.b	1
chaitxoff:	ds.b	1
chairsmode:	ds.b	1		* Bit 0 = Flow Control (0=Disabled)
*					* Bit 1 = Handshake (0=Disabled)
chaisendnow:	ds.b	1
chabrate:	ds.b	1		* saved baud rate for Rsconf(-2)
chamask:	ds.b	1		* mask for incoming chars

*
*	channel B Buffers and I/O Buffer Record
*
chbibuffer:	ds.b	rbufsize	;rs-232 input buffer
chbobuffer:	ds.b	rbufsize	;rs-232 output buffer

*
*	channel B I/O Buffer Record
*
.globl chbibufptr
chbibufptr:	ds.l	1		* Input Buffer Record
chbibufsiz:	ds.w	1
chbibufhead:	ds.w	1
chbibuftail:	ds.w	1
chbibuflow:	ds.w	1
chbibufhigh:	ds.w	1
*
*	NOTE: THESE TWO BUFFERS MUST REMAIN CONTIGUOUS
*		(Don't Thank Me, Thank Dave!)
*
chbobufptr:	ds.l	1		* Output Buffer Record
chbobufsiz:	ds.w	1
chbobufhead:	ds.w	1
chbobuftail:	ds.w	1
chbobuflow:	ds.w	1
chbobufhigh:	ds.w	1

chbrsrbyte:	ds.b	1		* Other Associated Variables
chbwr5:		ds.b	1		* shadow of WR5
chbirxoff:	ds.b	1
chbitxoff:	ds.b	1
chbirsmode:	ds.b	1		* Bit 0 = Flow Control (0=Disabled)
*					* Bit 1 = Handshake (0=Disabled)
chbisendnow:	ds.b	1
chbbrate:	ds.b	1		* saved baud rate for Rsconf(-2)
chbmask:	ds.b	1		* mask for incoming chars

.text

* End of SCC code.  It's in all ROMs now because ST, STe, and Mega STe
* all use the same ROM, and TT has it too.  It could be taken out
* of STPAD.

*************************************************************************
*	revised 05/01/86	Mike Schmal				*
*	Worked in spanish key board					*
*************************************************************************
*	revised 10/11/85 dbg						*
*	fixed incompatibility problem with event reporting between	*
*	5/29/85 TOS and later versions.  This fix maintains the event	*
*	reporting data structure used in 5/29/85 TOS and gives the user	*
*	the header byte at the address pointed to in A0.  The		*
*	interrogate mode still places the joy0 byte at A0, and the joy1	*
*	byte at A0+1.  Note, there is still a one byte offset difference*
*	between the two modes.  It is possible to use both modes at the	*
*	same time and to distinguish between them by checking for an	*
*	$fe or $ff at A0 (event mode) or a value other than that for	*
*	interrogate mode.						*
*************************************************************************
*	revised 8/22/85 dbg						*
*	fixed joy0 & joy1 event reporting offset bug			*
*	changed index handed off at program label "ML35"		*
*************************************************************************
*************************************************************************
*	revised 8/16/85 dbg						*
*	fixed joy0 & joy1 parsing handoff bug				*
*	added identifier for type of joystick information being handed	*
*	off to joyrec as first byte in record buffer			*
*	also reduced the number of registers saved during the interrupt	*
*	to only those actually used.					*
*************************************************************************
*************************************************************************
*	this code handles the midi/keyboard interrupt exception		*
*************************************************************************

	.globl	midikey

midikey:
	movem.l d0-d3/a0-a3,-(sp)	;save all registers (8/16/85 dbg)
keymidi:
	movea.l	midisys.w,a2	;load in system midi handler
	jsr	(a2)		;do it...
	movea.l	ikbdsys.w,a2	;load in system ikbd handler
	jsr	(a2)		;do it...
	btst.b	#$4,gpip+mfp.w ;check for pending interrupt occurance
	beq.b	keymidi		;repeat this interrupt processing
*	bclr.b	#$6,isrb+mfp.w ;clear in-service bit
	move.b	#%10111111,isrb+mfp.w ; was bclr but that's wrong
	movem.l (sp)+,d0-d3/a0-a3	;restore all registers
	rte			;go back to what was happening!

vecmidi:
	lea	mbufrec.w,a0	;point to midi buffer record
	lea	midi.w,a1	;point to midi register base
	movea.l vmiderr.w,a2	;load in the jump vector
	bra	astatus		;goto general acia status check routine

vecikbd:
	lea	kbufrec.w,a0	;point to ikbd buffer record
	lea	keyboard,a1	;point to keyboard register base
	movea.l vkbderr.w,a2	;load in the jump vector
	bra	astatus		;goto general acia status check routine

astatus:
	move.b	comstat(a1),d2	;grab device status
	btst.l	#7,d2		;make sure it was an interrupt request
	beq.b	aciaexit	;nope...it's empty
	btst.l	#0,d2
	beq	mk1
	movem.l	d2/a0-a2,-(sp)
	bsr.b	arcvrint
	movem.l	(sp)+,d2/a0-a2
mk1:	andi.b	#%00100000,d2
	beq	aciaexit
	move.b	iodata(a1),d0
	jmp	(a2)
aciaexit:
	rts

*************************************************************************
*									*
*		acia receiver buffer full interrupt routine		*
*									*
*************************************************************************

	.globl	arcvrint

arcvrint:
	move.b	iodata(a1),d0	;grab data byte from acia data register
	cmpa.l	#kbufrec,a0
	bne	midibyte	;don't treat midi acia data as anything other
*				;than as pure data...
	tst.b	kstate.w
	bne.b	ML3

* new code 7/12/90: if it's the first byte of a packet, bra to kbheader;
* else jump through the vector ikbdkey.  This defaults to "itsakey."

	cmpi.b	#$f6,d0
	bcc	kbheader

	move.l	ikbdkey.w,-(sp)	;jmp without using any regs
	rts			;(because I don't know what's safe)

kbheader:
	subi.b	#$f6,d0		;generate true index into tables now
	andi.l	#$ff,d0		;clear high 3 bytes for indexing
	lea	ikbdev,a3	;point to ikbd device state codes
	move.b	0(a3,d0),kstate.w	;set ikbd state
	lea	ikbdlen,a3	;point to ikbd device buffer length table
	move.b	0(a3,d0),kindex.w	;set ikbd device index counter
	addi.w	#$f6,d0		;re-constitute original value
	cmpi.b	#$f8,d0
	blt.b	ML8
	cmpi.b	#$fb,d0
	bgt.b	ML8
	move.b	d0,mousebuf.w
	rts

*
*	added the compare below to correct for incorrect indexing into the
*	joystick record buffer array
*
*****
ML8:	cmpi.b	#$fd,d0		;>=joystick record header?
	blt.b	ML7		;not a joystick record
	move.b	d0,joyrec.w
*****
ML7:	rts

ikbdev:	dc.b	statks,amouse,rmouse,rmouse,rmouse,rmouse
	dc.b	clock,joyall,joy0,joy1
ikbdlen:
	dc.b	statdex,amdex,rmdex-1,rmdex-1,rmdex-1,rmdex-1
*
*	changed 'joyadex' below to 'joyadex-1' to correct for incorrect
*	indexing into the joystick record buffer array
*
*****
	dc.b	clkdex,joyadex-1,joydex,joydex
*****

	.even
ML3:
	cmpi.b	#joy0,kstate.w
	bcc	ML35		;a joystick 0/1 record byte, not both!
	lea	ikbdparams,a2	;point to ikbd subsystem parameters table
	moveq	#$0,d2
	move.b	kstate.w,d2	;load to generate longword offset
	subq.b	#$1,d2		;kstate.w=1 to 5/ table index is 0 to 4
	asl	d2		; x2
	add.b	kstate.w,d2	; +1
	subq.b	#$1,d2		;kstate.w=1 to 5/ table index is 0 to 4
	asl	#2,d2		; x4

	movea.l	0(a2,d2),a0	;load in subsystem's record pointer
	movea.l	4(a2,d2),a1	;load in subsystem's index base+record pointer
	movea.l	8(a2,d2),a2	;load in subsystem's pointer variable that
*				;contains the pointer to the subsystem's
*				;interrupt routine...
	movea.l	(a2),a2
	moveq	#$0,d2		;clear out 'd2' for address manipulation
	move.b	kindex.w,d2
	suba.l	d2,a1
	move.b	d0,(a1)
	sub.b	#1,kindex.w
	tst.b	kindex.w
	bne.b	ML1
ikserve:
	move.l	a0,-(sp)	;stuff buffer pointer to stack
	jsr	(a2)		;go service the subsystem interrupt routine
	addq	#$4,sp		;re-adjust stack
	clr.b	kstate.w	;reset ikbd state
ML1:	rts

ikbdparams:
	dc.l	statrec
	dc.l	statdex+statrec
	dc.l	statintvec

	dc.l	amrec
	dc.l	amdex+amrec
	dc.l	msintvec

	dc.l	mousebuf
	dc.l	rmdex+mousebuf
	dc.l	msintvec

	dc.l	clkrec
	dc.l	clkdex+clkrec
	dc.l	clkintvec

	dc.l	joyrec

*	10/11/85 dbg	changed the statement below to maintain
*			compatibility with version 5/29/85
*	dc.l	joyadex+joyrec

	dc.l	joyadex+joyrec-1
	dc.l	joyintvec

*	8/16/85 dbg
*	changed 'joyrec+1' below to 'joyrec' to correct for incorrect
*	indexing into the joystick record buffer array
*
*****

*	8/22/85 dbg
*	changed the statement below to the one below it.  This allows proper
*	indexing into the appropriate joystick record byte during
*	"joystick event reporting mode".
*	move.l	#joyrec,d1
*	move.l	#joyrec+1,d1
*
*	the previous change noted above was not necessary.
*

ML35:
	move.l	#joyrec+1,d1
	add.b	kstate.w,d1	;kstate.w reflects joy0 or joy1 state
	subi.b	#joy0,d1
	move.l	d1,a2		;create index to joyrec table for record byte
	move.b	d0,(a2)
	movea.l	joyintvec.w,a2	;get user's joystick interrupt routine adr
	lea	joyrec.w,a0	;send along address of joystick data
	bra.b	ikserve

itsakey:
	move.b	kbshift.w,d1	;load in kbshift.w for manipulation...
* check the special keys
	cmpi.b	#$2A,d0		;left shift?
	bne.b	ari2
	bset	#KBLSH,d1
	bra	ari10
ari2:	cmpi.b	#$AA,d0
	bne.b	ari3
	bclr	#KBLSH,d1
	bra	ari10
ari3:	cmpi.b	#$36,d0		;right shift
	bne.b	ari4
	bset	#KBRSH,d1
	bra.b	ari10
ari4:	cmpi.b	#$B6,d0
	bne.b	ari5
	bclr	#KBRSH,d1
	bra.b	ari10
ari5:	cmpi.b	#$1D,d0		;CTRL
	bne.b	ari6
	bset	#KBCTL,d1
	bra.b	ari10
ari6:	cmpi.b	#$9D,d0
	bne.b	ari7
	bclr	#KBCTL,d1
	bra.b	ari10
ari7:	cmpi.b	#$38,d0		;ALT
	bne.b	ari8
	bset	#KBALT,d1
	bra.b	ari10
ari8:	cmpi.b	#$B8,d0
	bne.b	ari9
* it's the break code for alt!
	bclr	#KBALT,d1
* test here for altkp.
	tst.w	altkp
	bmi	ari10		; no altkp handling

* handle altkp now.  But first, write the new kbshift value.

	move.b	d1,kbshift.w
	move.l	a0,-(sp)	; store kbufrec pointer because we're about
				; to jump into the middle of code that
				; expects it to have been saved.
	moveq.l	#0,d1		; Use zero for the scan code,
	move.w	d1,d0		; (do an unsigned byte fetch to d0),
	move.b	altkp+1,d0	; get the accumulated value,
	move.w	#-1,altkp	; mark as invalid for next time
	bra	conin25		; and put it on the keyboard queue.

ari9:	cmpi.b	#$3A,d0		;CAPS LOCK
	bne.b	ari11
	btst.b	#0,conterm.w
	beq.b	ari9a		;no click please!

* go through kcl_hook to accomplish keyclick; this was an oops until 6/90
* before that, normal keys clicked through kcl_hook but caps-lock didn't.

	movem.l	d0-d2/a0-a2,-(sp)
	move.l	kcl_hook.w,a0
	jsr	(a0)
	movem.l	(sp)+,d0-d2/a0-a2

ari9a:	bchg	#KBCL,d1	;toggle CAPS LOCK state
ari10:	move.b	d1,kbshift.w	;restore new kbshift.w value
	rts			;ignore CAPS LOCK break


********************
*
* The key is not a make or break of a modifier like alt and caps-lock.
*

ari11:	btst.l	#7,d0		;make or break?
	bne.b	ari12		;break

********************
*
* key make code: Set up key repeat
* If already some key repeating, stop only when THAT KEY comes up.
* When any key goes down, start the cdelay1/cdelay2 repeat cycle over for it.
* (This is a change from 11/20 and 4/22: they didn't repeat that second key.)
*

	move.b	d0,keyrep.w	;save for repeat purpose
	move.b	cdelay1,kdelay1.w
	move.b	cdelay2,kdelay2.w
	bra.b	ari16

********************
*
* Key break code; stop repeating if it's the break for the key that
* was repeating.  Then handle break codes for the Insert and Home keys,
* which behave like mouse buttons.
*

ari12:	move.b	d0,d1		; d1 = make code corresponding to d0
	bclr.l	#7,d1
	cmp.b	keyrep.w,d1	; is this break code for the repeating key?
	bne.b	ari18		; no - don't stop the repeating key.

	moveq	#0,d1		; keyrep just came up: stop the repeat.
	move.b	d1,keyrep.w
	move.b	d1,kdelay1.w
	move.b	d1,kdelay2.w

ari18:	cmpi.b	#$c7,d0		;is it a "home" break-code?
	beq.b	ari18a		;yes...allow it to pass
	cmpi.b	#$d2,d0		;is it a "insert" break-code?
	bne	ari14		;no...regular break junk...just rts
ari18a:	btst.b	#KBALT,kbshift.w ;early "ALT" test to prevent double "nulls"
	beq	ari14		;no ALT...so just rts now...

********************
*
* Make code for a normal key or a mouse-spoofing key.
* Give keyclick, translate the key into a longword that goes into kbufrec.
*

ari16:	btst.b	#0,conterm.w
	beq.b	ari16a		;no click please!

* key click: go through the hook (as of 7/89); normally def_click.
	movem.l	d0-d2/a0-a2,-(sp)
	move.l	kcl_hook.w,a1
	jsr	(a1)
	movem.l	(sp)+,d0-d2/a0-a2

ari16a:	move.l	a0,-(sp)	;store kbufrec pointer

	moveq	#$0,d1
	move.b	d0,d1

	movea.l skeytran.w,a0
	andi.w	#$7F,d0
	btst.b	#KBCL,kbshift.w
	beq.b	conin21
	movea.l skeycl.w,a0
conin21:
	btst.b	#KBRSH,kbshift.w
	bne.b	conin22
	btst.b	#KBLSH,kbshift.w
	beq.b	conin23
conin22:
	cmpi.b	#$3b,d0		;see if a possible function key
	bcs.b	conin22a	;unsigned less than lowest function scancode
	cmpi.b	#$44,d0		;see if a possible function key
	bhi.b	conin22a	;unsigned greater than highest function scan
	addi.w	#$19,d1		;add to change to GSX standard
	moveq	#$0,d0		;change to GSX standard
	bra	conin25
conin22a:
	movea.l skeyshif.w,a0
conin23:
	move.b	(a0,d0.w),d0
	btst.b	#KBCTL,kbshift.w	;is the control key down?
	beq.b	conin24a
	cmpi.b	#cr,d0		;is it a carriage return?
	bne.b	conin23a
	moveq	#lf,d0		;change to a linefeed according to GSX spec...
	beq.b	conin24
conin23a:
	cmpi.b	#$47,d1		;convert CONTROL-home to gsx standard
	bne.b	conin23b	;by adding #$30...
	addi.w	#$30,d1
	bra	conin25
conin23b:
	cmpi.b	#$4b,d1		;convert CONTROL-left arrow to gsx standard
	bne.b	conin23c
	moveq	#$73,d1		;change according to gsx spec
	moveq	#$0,d0
	bra	conin25
conin23c:
	cmpi.b	#$4d,d1		;convert CONTROL-right arrow to gsx standard
	bne.b	conin24
	moveq	#$74,d1		;change according to gsx spec
	moveq	#$0,d0
	bra	conin25
conin24:
	cmpi.b	#$32,d0		;convert CONTROL-2 to gsx standard
	bne.b	conin24b
	moveq	#$00,d0		;change according to gsx spec
	bra	conin25
conin24b:
	cmpi.b	#$36,d0		;convert CONTROL-6 to gsx standard
	bne.b	conin24c
	moveq	#$1e,d0		;change according to gsx spec
	bra	conin25
conin24c:
	cmpi.b	#$2d,d0		;convert CONTROL-'-' to gsx standard
	bne.b	conin24a
	moveq	#$1f,d0		;change according to gsx spec
	bra	conin25
*
* DON'T control-ize other keys just yet... wait until after the int'l munge.
*

conin24a:
	btst.b	#KBALT,kbshift.w	;is the alt key down?
	beq	conin25a

	cmp.b	#$67,d1			;is it alt plus keypad?
	blo	notaltkp
	cmp.b	#$70,d1
	bhi	notaltkp
	move.w	altkp,d0		;get accumulated value
	bpl	altkp1
	moveq.l	#0,d0			;use zero if it was negative
altkp1:
	mulu.w	#10,d0			;multiply by 10

	ext.w	d1
	move.b	(a0,d1.w),d1		; (a0 already points to a table)
	sub.b	#'0',d1
	add.b	d1,d0			;add this digit to accumulator
	move.w	d0,altkp		;and store it back
	move.l	(sp)+,a0		;pop saved register
	rts				;and return

* no, it wasn't ALT plus a keypad number key

notaltkp:

********************
*
* New code as of 5/92: in the all-countries cases (TT, SPARROW) we use
* the new variables salttran/saltshif/saltcl as associative lookup tables
* instead of doing the alt-key translation job in code.
*

.if ALLKBS
	move.l	salttran,a0	; pre-load the unshifted case
	move.b	kbshift.w,d2
	and.b	#3,d2		; either shift key?
	beq	anoshift
	move.l	saltshif,a0	; yes - use alt-shift table
	bra	agottab
anoshift:
	btst.b	#KBCL,kbshift.w	; caps lock?
	beq	agottab		; no - use unshifted case
	move.l	saltcl,a0
agottab:
	tst.b	(a0)		; end of table?
	beq	outside		; yes - stop trying
	cmp.b	(a0),d1		; scan code match?
	adda.w	#2,a0		; (does not affect CCR; must not be addq)
	bne	agottab		; loop if it didn't match
* get here if it matched
	move.b	-(a0),d0	; MATCH: load up ASCII code
	bra	conin25a	; and win.

* The null table, for usa, uk, etc.

nullatran:
	dc.b	0

grmatran:
	dc.b	$1a,'@',  $27,'[',  $28,']',  0
grmashif:
	dc.b	$1a,$5c,  $27,'{',  $28,'}',  0	; 5c is '\'
grmacl:
	dc.b	$1a,'@',  $27,'[',  $28,']',  0

spaatran:
	dc.b	$1a,'[',  $1b,']',  $2b,'#',  $28,$81,  $27,$00,  0
spaashif:
	dc.b	$1a,'{',  $1b,'}',  $2b,'@',  $28,$00,  $27,$00,  0
spaacl:
	dc.b	$1a,'[',  $1b,']',  $2b,'#',  $28,$81,  $27,$00,  0

freatran:
	dc.b	$1a,'[',  $1b,']',  $28,$5c,  $2b,'@',  0
freashif:
	dc.b	$1a,'{',  $1b,'}',  $28,$00,  $2b,'~',  0
freacl:
	dc.b	$1a,'[',  $1b,']',  $28,$5c,  $2b,'@',  0

sweatran:
	dc.b	$1a,'[',  $1b,']',  $28,'`',  $2b,'^',  0
sweashif:
	dc.b	$1a,'{',  $1b,'}',  $28,'~',  $2b,'@',  0
sweacl:
	dc.b	$1a,'[',  $1b,']',  $28,'`',  $2b,'^',  0

itaatran:
	dc.b	$1a,'[',  $1b,']',  $2b,$f8,  $60,'`',  0
itaashif:
	dc.b	$1a,'{',  $1b,'}',  $2b,'~',  $60,'`',  0
itaacl:
	dc.b	$1a,'[',  $1b,']',  $2b,$f8,  $60,'`',  0

* This table is used for Swiss keyboards; both Swiss-German & Swiss-French.

swiatran:
	dc.b	$1a,'@',  $27,'[',  $28,']',  $1b,'#', $2b,'~', 0
swiashif:
	dc.b	$1a,$5c,  $27,'{',  $28,'}',  $1b,'#', $2b,'|', 0
swiacl:
	dc.b	$1a,'@',  $27,'[',  $28,']',  $1b,'#', $2b,'~', 0
.even

********************
*
* The table of tables.  The country preference code indexes a row in
* this table; those six longs are moved into the corresponding
* keyboard table pointer variables as seen here and in the Keytrans call.
*

kbtabtab:
	dc.l	usatran, usashif, usacl, nullatran, nullatran, nullatran
	dc.l	grmtran, grmshif, grmcl, grmatran, grmashif, grmacl
	dc.l	fretran, freshif, frecl, freatran, freashif, freacl
	dc.l	uktran,  ukshif,  ukcl,  nullatran, nullatran, nullatran
	dc.l	spatran, spashif, spacl, spaatran, spaashif, spaacl
	dc.l	itatran, itashif, itacl, itaatran, itaashif, itaacl
	dc.l	swetran, sweshif, swecl, sweatran, sweashif, sweacl
	dc.l	swftran, swfshif, swfcl, swiatran, swiashif, swiacl
	dc.l	swgtran, swgshif, swgcl, swiatran, swiashif, swiacl

* This variable needs to be the number of entries in the table above.
* If the preference value is this value or larger, the zero table is used.

NKBDS	equ	9

.else
********************
*
* Old code for translating alt keys into ASCII codes
*

.if country == germany

	cmpi.b	#$1a,d1		;is it a ALT-umlaut?
	bne.b	altger1		;no...
	move.b	#$40,d0		;put in '@', then check the shift keys
	move.b	kbshift.w,d2	;grab current setting
	andi.b	#$3,d2		;KBRSH+KBLSH bits
	beq	conin25a		;process it as unshifted
	move.b	#$5c,d0		;put in '\', instead...it's a alt-shift umlaut!
	bra	conin25a		;process it
altger1:
	cmpi.b	#$27,d1		;is it a ALT-
	bne.b	altger2		;no...
	move.b	#$5b,d0		;put in '[', then check the shift keys
	move.b	kbshift.w,d2	;grab current setting
	andi.b	#$3,d2		;KBRSH+KBLSH bits
	beq	conin25a		;process it as unshifted
	move.b	#$7b,d0		;put in '{', instead...it's a alt-shift umlaut!
	bra	conin25a		;process it
altger2:
	cmpi.b	#$28,d1		;is it a ALT-
	bne.b	outside		;no...
	move.b	#$5d,d0		;put in ']', then check the shift keys
	move.b	kbshift.w,d2	;grab current setting
	andi.b	#$3,d2		;KBRSH+KBLSH bits
	beq	conin25a		;process it as unshifted
	move.b	#$7d,d0		;put in '}', instead...it's a alt-shift umlaut!
	bra	conin25a		;process it

.endif

.if country == spain

	cmpi.b	#$1a,d1		;is it a ALT-umlaut?
	bne.b	altspa1		;no...
	move.b	#$5b,d0		;put in '[', then check the shift keys
	move.b	kbshift.w,d2	;grab current setting
	andi.b	#$3,d2		;KBRSH+KBLSH bits
	beq	conin25a		;process it as unshifted
	move.b	#$7b,d0		;put in '{', instead...it's a alt-shift '
	bra	conin25a		;process it
altspa1:
	cmpi.b	#$1b,d1		;is it a ALT-`
	bne.b	altspa2		;no...
	move.b	#$5d,d0		;put in ']', then check the shift keys
	move.b	kbshift.w,d2	;grab current setting
	andi.b	#$3,d2		;KBRSH+KBLSH bits
	beq	conin25a		;process it as unshifted
	move.b	#$7d,d0		;put in '}', instead...it's a alt-shift `
	bra	conin25a		;process it
altspa2:
	cmpi.b	#$2b,d1		;is it a ALT-\
	bne.b	altspa3		;no...
	move.b	#$23,d0		;put in '#', then check the shift keys
	move.b	kbshift.w,d2	;grab current setting
	andi.b	#$3,d2		;KBRSH+KBLSH bits
	beq	conin25a		;process it as unshifted
	move.b	#$40,d0		;put in '@', instead...it's a alt-shift \
	bra	conin25a		;process it
altspa3:
	cmpi.b	#$28,d1		;is it a ALT-
	bne.b	altspa4		;no...
	move.b	#$81,d0		;put in ']', then check the shift keys
	move.b	kbshift.w,d2	;grab current setting
	andi.b	#$3,d2		;KBRSH+KBLSH bits
	beq	conin25a		;process it as unshifted
	move.b	#$00,d0		;put in $00, instead...it's a alt-shift ;
	bra	conin25a		;process it
altspa4:
	cmpi.b	#$27,d1		;is it a ALT-n~
	bne.b	outside		;no...
	move.b	#$00,d0		;put in $00, instead...it's a alt-shift ;
	bra	conin25a		;process it

.endif

.if country == france

	cmpi.b	#$1a,d1		;is it a ALT-^?
	bne.b	altfr1		;no...
	move.b	#$5b,d0		;put in '[', then check the shift keys
	move.b	kbshift.w,d2	;grab current setting
	andi.b	#$3,d2		;KBRSH+KBLSH bits
	beq	conin25a		;process it as unshifted
	move.b	#$7b,d0		;put in '{', instead...it's a alt-shift ^
	bra	conin25a		;process it
altfr1:	cmpi.b	#$1b,d1		;is it a ALT-$?
	bne.b	altfr2		;no...
	move.b	#$5d,d0		;put in ']', then check the shift keys
	move.b	kbshift.w,d2	;grab current setting
	andi.b	#$3,d2		;KBRSH+KBLSH bits
	beq	conin25a		;process it as unshifted
	move.b	#$7d,d0		;put in '}', instead...it's a alt-shift $
	bra	conin25a		;process it
altfr2:	cmpi.b	#$28,d1		;is it a ALT-
	bne.b	altfr3		;no...
	move.b	#$5c,d0		;put in '\', then check the shift keys
	move.b	kbshift.w,d2	;grab current setting
	andi.b	#$3,d2		;KBRSH+KBLSH bits
	beq	conin25a		;process it as unshifted
	move.b	#nul,d0		;put in 'NUL',instead...it's a alt-shift
	bra	conin25a		;process it
altfr3:	cmpi.b	#$2b,d1		;is it a ALT-#?
	bne.b	outside		;no...
	move.b	#$40,d0		;put in '@', then check the shift keys
	move.b	kbshift.w,d2	;grab current setting
	andi.b	#$3,d2		;KBRSH+KBLSH bits
	beq	conin25a		;process it as unshifted
	move.b	#$7e,d0		;put in '|', instead...it's a alt-shift #
	bra	conin25a		;process it

.endif


.if country == sweden

	cmpi.b	#$1a,d1		;is it a ALT-^?
	bne.b	altsw1		;no...
	move.b	#$5b,d0		;put in '[', then check the shift keys
	move.b	kbshift.w,d2	;grab current setting
	andi.b	#$3,d2		;KBRSH+KBLSH bits
	beq	conin25a		;process it as unshifted
	move.b	#$7b,d0		;put in '{', instead...it's a alt-shift ^
	bra	conin25a		;process it
altsw1:	cmpi.b	#$1b,d1		;is it a ALT-$?
	bne.b	altsw2		;no...
	move.b	#$5d,d0		;put in ']', then check the shift keys
	move.b	kbshift.w,d2	;grab current setting
	andi.b	#$3,d2		;KBRSH+KBLSH bits
	beq	conin25a		;process it as unshifted
	move.b	#$7d,d0		;put in '}', instead...it's a alt-shift $
	bra	conin25a		;process it
altsw2:	cmpi.b	#$28,d1		;is it a ALT-
	bne.b	altsw3		;no...
	move.b	#$60,d0		;put in '`', then check the shift keys
	move.b	kbshift.w,d2	;grab current setting
	andi.b	#$3,d2		;KBRSH+KBLSH bits
	beq	conin25a		;process it as unshifted
	move.b	#$7e,d0		;put in '~',instead...it's a alt-shift
	bra	conin25a		;process it
altsw3:	cmpi.b	#$2b,d1		;is it a ALT-#?
	bne.b	outside		;no...
	move.b	#$5e,d0		;put in '^', then check the shift keys
	move.b	kbshift.w,d2	;grab current setting
	andi.b	#$3,d2		;KBRSH+KBLSH bits
	beq	conin25a		;process it as unshifted
	move.b	#$40,d0		;put in '@', instead...it's a alt-shift #
	bra	conin25a		;process it

.endif


.if country == norway

	cmpi.b	#$1a,d1		;is it a ALT-^?
	bne.b	altsw1		;no...
	move.b	#$5b,d0		;put in '[', then check the shift keys
	move.b	kbshift.w,d2	;grab current setting
	andi.b	#$3,d2		;KBRSH+KBLSH bits
	beq	conin25a		;process it as unshifted
	move.b	#$7b,d0		;put in '{', instead...it's a alt-shift ^
	bra	conin25a		;process it
altsw1:	cmpi.b	#$1b,d1		;is it a ALT-$?
	bne.b	altsw2		;no...
	move.b	#$5d,d0		;put in ']', then check the shift keys
	move.b	kbshift.w,d2	;grab current setting
	andi.b	#$3,d2		;KBRSH+KBLSH bits
	beq	conin25a		;process it as unshifted
	move.b	#$7d,d0		;put in '}', instead...it's a alt-shift $
	bra	conin25a		;process it
altsw2:	cmpi.b	#$28,d1		;is it a ALT-
	bne.b	altsw3		;no...
	move.b	#$60,d0		;put in '`', then check the shift keys
	move.b	kbshift.w,d2	;grab current setting
	andi.b	#$3,d2		;KBRSH+KBLSH bits
	beq	conin25a		;process it as unshifted
	move.b	#$7e,d0		;put in '~',instead...it's a alt-shift
	bra	conin25a		;process it
altsw3:	cmpi.b	#$2b,d1		;is it a ALT-#?
	bne.b	outside		;no...
	move.b	#$5e,d0		;put in '^', then check the shift keys
	move.b	kbshift.w,d2	;grab current setting
	andi.b	#$3,d2		;KBRSH+KBLSH bits
	beq	conin25a		;process it as unshifted
	move.b	#$40,d0		;put in '@', instead...it's a alt-shift #
	bra	conin25a		;process it

.endif


 
.if country == italy

	cmpi.b	#$1a,d1		;is it a ALT-`e ?
	bne.b	altsw1		;no...
	move.b	#'[',d0		;put in '[', then check the shift keys
	move.b	kbshift.w,d2	;grab current setting
	andi.b	#$3,d2		;KBRSH+KBLSH bits
	beq	conin25a	;process it as unshifted
	move.b	#'{',d0		;put in '{', instead...it's a alt-shift-`e
	bra	conin25a	;process it
altsw1:	cmpi.b	#$1b,d1		;is it a ALT-+ ?
	bne.b	altsw2		;no...
	move.b	#']',d0		;put in ']', then check the shift keys
	move.b	kbshift.w,d2	;grab current setting
	andi.b	#$3,d2		;KBRSH+KBLSH bits
	beq	conin25a	;process it as unshifted
	move.b	#'}',d0		;put in '}', instead...it's a alt-shift $
	bra	conin25a	;process it
altsw2:	cmpi.b	#$2b,d1		;is it a ALT-\ ?
	bne.b	altsw3		;no...
	move.b	#$f8,d0		;put in bullet, then check the shift keys
	move.b	kbshift.w,d2	;grab current setting
	andi.b	#$3,d2		;KBRSH+KBLSH bits
	beq	conin25a	;process it as unshifted
	move.b	#'~',d0		;put in '~',instead...it's a alt-shift-\
	bra	conin25a	;process it
altsw3:	cmpi.b	#$60,d1		;is it a ALT-ISO?
	bne.b	outside		;no...
	move.b	#'`',d0		;put in '`'; shifted value is also '`'
	bra	conin25a		;process it

.endif



.if country == swissger

	cmpi.b	#$1a,d1		;is it a ALT-umlaut?
	bne.b	altsw1		;no...
	move.b	#$40,d0		;put in '@', then check the shift keys
	move.b	kbshift.w,d2	;grab current setting
	andi.b	#$3,d2		;KBRSH+KBLSH bits
	beq	conin25a		;process it as unshifted
	move.b	#$5c,d0		;put in '\', instead...it's a alt-shift umlaut!
	bra	conin25a		;process it
altsw1:	cmpi.b	#$27,d1		;is it a ALT-O with two .. on top
	bne.b	altsw2		;no...
	move.b	#$5b,d0		;put in '[', then check the shift keys
	move.b	kbshift.w,d2	;grab current setting
	andi.b	#$3,d2		;KBRSH+KBLSH bits
	beq	conin25a		;process it as unshifted
	move.b	#$7b,d0		;put in '{', instead...it's a alt-shift umlaut!
	bra	conin25a		;process it
altsw2:	cmpi.b	#$28,d1		;is it a ALT-A with two .. on top
	bne.b	altsw3		;no...
	move.b	#$5d,d0		;put in ']', then check the shift keys
	move.b	kbshift.w,d2	;grab current setting
	andi.b	#$3,d2		;KBRSH+KBLSH bits
	beq	conin25a		;process it as unshifted
	move.b	#$7d,d0		;put in '}', instead...it's a alt-shift umlaut!
	bra	conin25a		;process it
altsw3:	cmpi.b	#$1b,d1		;is it a ALT-!
	bne.b	altsw4		;no...
	move.b	#$23,d0		;put in '#', then check the shift keys
	bra	conin25a		;process it
altsw4:	cmpi.b	#$2b,d1		;is it a ALT-$?
	bne.b	outside		;no...
	move.b	#$7e,d0		;put in '~', then check the shift keys
	move.b	kbshift.w,d2	;grab current setting
	andi.b	#$3,d2		;KBRSH+KBLSH bits
	beq	conin25a		;process it as unshifted
	move.b	#$7c,d0		;put in |', instead...it's a alt-shift umlaut!
	bra	conin25a		;process it

.endif


.if country == turkey

	cmpi.b	#$1a,d1		;is it a ALT-umlaut?
	bne.b	altsw1		;no...
	move.b	#$5b,d0		;put in '[', then check the shift keys
	move.b	kbshift.w,d2	;grab current setting
	andi.b	#$3,d2		;KBRSH+KBLSH bits
	beq	conin25a		;process it as unshifted
	move.b	#$7b,d0		;put in '{', instead...it's a alt-shift umlaut!
	bra	conin25a		;process it
altsw1:	cmpi.b	#$27,d1		;is it a ALT-O with two .. on top
	bne.b	altsw2		;no...
	move.b	#$23,d0		;put in '#', then check the shift keys
	move.b	kbshift.w,d2	;grab current setting
	andi.b	#$3,d2		;KBRSH+KBLSH bits
	beq	conin25a		;process it as unshifted
	move.b	#$26,d0		;put in '&', instead...it's a alt-shift umlaut!
	bra	conin25a		;process it
altsw2:	cmpi.b	#$28,d1		;is it a ALT-A with two .. on top
	bne.b	altsw3		;no...
	move.b	#$40,d0		;put in '@', then check the shift keys
	move.b	kbshift.w,d2	;grab current setting
	andi.b	#$3,d2		;KBRSH+KBLSH bits
	beq	conin25a		;process it as unshifted
	move.b	#$7e,d0		;put in '~', instead...it's a alt-shift umlaut!
	bra	conin25a		;process it
altsw3:	cmpi.b	#$1b,d1		;is it a ALT-!
	bne.b	altsw4		;no...
	move.b	#$5d,d0		;put in ']', then check the shift keys
	move.b	kbshift.w,d2	;grab current setting
	andi.b	#$3,d2		;KBRSH+KBLSH bits
	beq	conin25a		;process it as unshifted
	move.b	#$7d,d0		;put in '}', instead...it's a alt-shift umlaut!
	bra	conin25a		;process it
altsw4:	cmpi.b	#$2b,d1		;is it a ALT-$?
	bne.b	altsw5		;no...
	move.b	#$5c,d0		;put in '\', then check the shift keys
	move.b	kbshift.w,d2	;grab current setting
	andi.b	#$3,d2		;KBRSH+KBLSH bits
	beq	conin25a		;process it as unshifted
	move.b	#$7c,d0		;put in '|', instead...it's a alt-shift umlaut!
	bra	conin25a		;process it
altsw5:	cmpi.b	#$35,d1		;is it a ALT-$?
	bne.b	outside		;no...
	move.b	#$3c,d0		;put in '<', then check the shift keys
	move.b	kbshift.w,d2	;grab current setting
	andi.b	#$3,d2		;KBRSH+KBLSH bits
	beq	conin25a		;process it as unshifted
	move.b	#$3e,d0		;put in '>', instead...it's a alt-shift umlaut!
	bra	conin25a		;process it

.endif



.if country == swissfra

	cmpi.b	#$1a,d1		;is it a ALT-umlaut?
	bne.b	altsw1		;no...
	move.b	#$40,d0		;put in '@', then check the shift keys
	move.b	kbshift.w,d2	;grab current setting
	andi.b	#$3,d2		;KBRSH+KBLSH bits
	beq	conin25a		;process it as unshifted
	move.b	#$5c,d0		;put in '\', instead...it's a alt-shift umlaut!
	bra	conin25a		;process it
altsw1:	cmpi.b	#$27,d1		;is it a ALT-O with two .. on top
	bne.b	altsw2		;no...
	move.b	#$5b,d0		;put in '[', then check the shift keys
	move.b	kbshift.w,d2	;grab current setting
	andi.b	#$3,d2		;KBRSH+KBLSH bits
	beq	conin25a		;process it as unshifted
	move.b	#$7b,d0		;put in '{', instead...it's a alt-shift umlaut!
	bra	conin25a		;process it
altsw2:	cmpi.b	#$28,d1		;is it a ALT-A with two .. on top
	bne.b	altsw3		;no...
	move.b	#$5d,d0		;put in ']', then check the shift keys
	move.b	kbshift.w,d2	;grab current setting
	andi.b	#$3,d2		;KBRSH+KBLSH bits
	beq	conin25a		;process it as unshifted
	move.b	#$7d,d0		;put in '}', instead...it's a alt-shift umlaut!
	bra	conin25a		;process it
altsw3:	cmpi.b	#$1b,d1		;is it a ALT-!
	bne.b	altsw4		;no...
	move.b	#$23,d0		;put in '#', then check the shift keys
	bra	conin25a		;process it
altsw4:	cmpi.b	#$2b,d1		;is it a ALT-$?
	bne.b	outside		;no...
	move.b	#$7e,d0		;put in '~', then check the shift keys
	move.b	kbshift.w,d2	;grab current setting
	andi.b	#$3,d2		;KBRSH+KBLSH bits
	beq	conin25a		;process it as unshifted
	move.b	#$7c,d0		;put in |', instead...it's a alt-shift umlaut!
	bra	conin25a		;process it

.endif


.if country == denmark

	cmpi.b	#$1a,d1		;is it a ALT-^?
	bne.b	altden1		;no...
	move.b	#$5b,d0		;put in '[', then check the shift keys
	move.b	kbshift.w,d2	;grab current setting
	andi.b	#$3,d2		;KBRSH+KBLSH bits
	beq	conin25a		;process it as unshifted
	move.b	#$7b,d0		;put in '{', instead...it's a alt-shift ^
	bra	conin25a		;process it
altden1:
	cmpi.b	#$1b,d1		;is it a ALT-$?
	bne.b	altden2		;no...
	move.b	#$5d,d0		;put in ']', then check the shift keys
	move.b	kbshift.w,d2	;grab current setting
	andi.b	#$3,d2		;KBRSH+KBLSH bits
	beq	conin25a		;process it as unshifted
	move.b	#$7d,d0		;put in '}', instead...it's a alt-shift $
	bra	conin25a		;process it
altden2:
	cmpi.b	#$28,d1		;is it a ALT-
	bne.b	altden3		;no...
	move.b	#$5c,d0		;put in '\', then check the shift keys
	move.b	kbshift.w,d2	;grab current setting
	andi.b	#$3,d2		;KBRSH+KBLSH bits
	beq	conin25a		;process it as unshifted
	move.b	#$7c,d0		;put in '|',instead...it's a alt-shift
	bra	conin25a		;process it
altden3:
	cmpi.b	#$2b,d1		;is it a ALT-#?
	bne.b	outside		;no...
	move.b	#$40,d0		;put in '@', then check the shift keys
	move.b	kbshift.w,d2	;grab current setting
	andi.b	#$3,d2		;KBRSH+KBLSH bits
	beq	conin25a		;process it as unshifted
	move.b	#$27,d0		;put in <'>, instead...it's a alt-shift #
	bra	conin25a		;process it

.endif

********************
* Below is the endif for alt-key translation in tables or in code
********************

.endif

outside:
	cmpi.b	#$62,d1		;is it an "alt help" signal to dump the screen?
	bne.b	alt15a		;no...
	addq.w	#1,_dumpflg.w	;yes...switch the signal flag on!...
	movea.l	(sp)+,a0	;restore kbufrec pointer
	bra	ari14		;...and exit
*
*	check the alt-insert/alt-home key make/break combinations, first
*
alt15a:	lea	mauskey1,a2	;get pointer to first alt. mouse scancode table
	moveq	#3,d2		;create countdown
mkloop1:
	cmp.b	0(a2,d2),d1	;is table's scancode value = current value?
	beq	keymaus1	;yes...go preprocess it...
	dbra	d2,mkloop1	;no...loop back to check next table value

	cmpi.b	#$48,d1		;is it an up arrow?
	bne.b	alt11
	move.b	#$0,d1		;x value for up arrow
	move.b	#-8,d2		;y value for up arrow
	move.b	kbshift.w,d0	;grab current setting
	andi.b	#$3,d0		;KBRSH+KBLSH bits
	beq	keymaus
	move.b	#-1,d2		;y value for up arrow
	bra	keymaus
alt11:	cmpi.b	#$4b,d1		;is it an left arrow?
	bne.b	alt12
	move.b	#$0,d2		;y value for left arrow
	move.b	#-8,d1		;x value for left arrow
	move.b	kbshift.w,d0	;grab current setting
	andi.b	#$3,d0		;KBRSH+KBLSH bits
	beq	keymaus
	move.b	#-1,d1		;x value for left arrow
	bra	keymaus
alt12:	cmpi.b	#$4d,d1		;is it an right arrow?
	bne.b	alt13
	move.b	#$8,d1		;x value for right arrow
	move.b	#$0,d2		;y value for right arrow
	move.b	kbshift.w,d0	;grab current setting
	andi.b	#$3,d0		;KBRSH+KBLSH bits
	beq	keymaus
	move.b	#$1,d1		;x value for right arrow
	bra	keymaus
alt13:	cmpi.b	#$50,d1		;is it an down arrow?
	bne.b	alt14
	move.b	#$0,d1		;x value for down arrow
	move.b	#$8,d2		;y value for down arrow
	move.b	kbshift.w,d0	;grab current setting
	andi.b	#$3,d0		;KBRSH+KBLSH bits
	beq	keymaus
	move.b	#$1,d2		;y value for down arrow
	bra	keymaus

alt14:	btst.b	#KBCTL,kbshift.w ; control key?
	bne.b	conin25b	; yup, it gets a control code, not an alt code
	cmpi.b	#$2,d1		; ALT-ize the rest of the keys
	bcs.b	alt1		;not >= the '1' key scancode
	cmpi.b	#$d,d1
	bhi.b	alt1		;not <= the '=' key scancode
	addi.b	#$76,d1		;scancode is a key between '1' key and '=' key
	bra.b	alt2
alt1:	cmpi.b	#$41,d0		;is the key an ascii 'A' or greater?
	bcs.b	alt3		;no...skip to check if 'a'-'z'...
	cmpi.b	#$5a,d0		;is the key an ascii 'Z' or less?
	bhi.b	alt3		;no...skip to check if 'a'-'z'...
alt2:	moveq	#$0,d0
	bra.b	conin25
alt3:	cmpi.b	#$61,d0		;is the key an ascii 'a' or greater?
	bcs.b	conin25		;no...skip to finish normal processing
	cmpi.b	#$7a,d0		;is the key an ascii 'z' or less?
	bhi.b	conin25		;no...skip to finish normal processing
	bra.b	alt2
conin25a:
	btst.b	#KBCTL,kbshift.w ; control key?
	beq.b	conin25		; nope, process the key normally
conin25b:
	andi.w	#$01F,d0	;CTRLize the key

conin25:
	asl.w	#$8,d1		;shift the scan code to the word's high byte
	add.w	d1,d0		;form the outgoing word

	movea.l	(sp)+,a0	;restore kbufrec pointer

	move.w	buftail(a0),d1 ;get current tail pointer offset
	addq	#4,d1		;index = tail + 4
	cmp.w	bufsize(a0),d1	;check to see if buffer should wrap
	bcs.b	ari13		;no...
	moveq	#$0,d1		;wrap pointer
ari13:	cmp.w	bufhead(a0),d1 ;head=tail?
	beq.b	ari14		;yes
	move.l	bufptr(a0),a2	;get buffer pointer

	swap	d0		;put scan/ascii in high word
	clr.w	d0		;clear out low word
	move.b	kbshift.w,d0	;bring in the kbshift data (ctrl/alt/shift)
	swap	d0		;re-adjust order
	lsl.l	#$8,d0		;now do the shuffling to generate the new
	lsr.w	#$8,d0		;improved conin format ($kkss00aa)

*
*	now test for the boot combinations ALT-CTRL-(shift)-DELETE (AKP 2/88)
*

	move.l	d0,d2
	bclr.l	#KBCL+24,d2	;mask off caps-lock state
	swap	d2		;get high word
	cmp.w	#$0c53,d2	;ctl-alt plus delete's scan-code
	beq	reseth
	cmp.w	#$0d53,d2	;ctl-alt-rshft plus delete's scan-code
	beq	coldboot

*
*	now we test the kludge bit (#3) of conterm to see if we really
*	want the kbshift value in the high byte of the high word.
*
	btst.b	#$3,conterm.w
	bne	ari14z		;set, so store this pig!
	andi.l	#$00ffffff,d0	;mask off KBSHIFT byte portion..."sigh"
ari14z:	and.l	#$0000ffff,d1	;d1.l = (unsigned long)d1.w
	move.l	d0,0(a2,d1.l)	;store the data
	move.w	d1,buftail(a0) ;store the new buftail pointer
ari14:	rts

	.globl	def_click
def_click:
	move.l	#keyclk,cursnd.w
	move.b	#0,timer.w
	rts

*
*	improved conin format is:
*
*	%0kkkkkkkssssssss00000000aaaaaaaa
*	 ||||||||{      }{      }{      }
*	 |||||||| \    /  \    /  \    /
*	 |||||||| scancode zeros  asciicode
*	 ||||||||
*	 |||||||---right shift key
*	 ||||||---left shift key
*	 |||||---control key
*	 ||||---ALT key
*	 |||---CAPS lock key
*	 ||---clr/home key -- right mouse button
*	 |---insert key -- left mouse button
*	 |---always zero (reserved)
*

midibyte:
	movea.l	midivec.w,a2	;get contents of midivec for indirect branch
	jmp	(a2)		;jump to midi interrupt handler

sysmidi:
	move.w	buftail(a0),d1 ;get current tail pointer offset
	addq	#1,d1		;index = tail + 1
	cmp.w	bufsize(a0),d1	;check to see if buffer should wrap
	bcs.b	mi13		;no...
	moveq	#$0,d1		;wrap pointer
mi13:	cmp.w	bufhead(a0),d1 ;head=tail?
	beq.b	mi14		;yes
	move.l	bufptr(a0),a2	;get buffer pointer
	and.l	#$0000ffff,d1	;d1.l = (unsigned long)d1.w
	move.b	d0,0(a2,d1.l)	;store the data
	move.w	d1,buftail(a0) ;store the new buftail pointer
mi14:	rts

keymaus1:
	moveq	#KBMRB,d3	;pre-init to "keyboard" right mouse button
	btst	#4,d1		;see if it is a left or right button...
	beq.b	kym1		;it's a right button ($47/$c7)
	moveq	#KBMLB,d3	;it's a left button ($52/$d2)
kym1:	btst	#7,d1		;see if it is a make or break action
	beq.b	kym2		;it's a set button action (make code)
	bclr	d3,kbshift.w	;it's a clear button action (break code)
	bra.b	kym3		;go to further pre-init action...
kym2:	bset	d3,kbshift.w	;it's a set button action (set code)
kym3:	moveq	#$0,d1
	moveq	#$0,d2
*
*	finish up at the actual pseudo mouse routine
*

keymaus:
	lea	kmbuf.w,a0	;point to key-emulating mouse buffer
	movea.l	msintvec.w,a2	;grab mouse interrupt vector
	clr.l	d0
	move.b	kbshift.w,d0	;get current button status
	lsr.b	#KBMRB,d0	;shift right button bit to 'd0'
	addi.b	#$f8,d0		;add relative mouse header
	move.b	d0,0(a0)	;store in first byte of record buffer
	move.b	d1,1(a0)	;store x value in second byte of record buffer
	move.b	d2,2(a0)	;store y value in third byte of record buffer
	jsr	(a2)
	movea.l	(sp)+,a0	;restore kbufrec pointer
	rts

mauskey1:
	dc.b	$47
	dc.b	$c7
	dc.b	$52
	dc.b	$d2

*************************************************************************
*
* COLD cold boot code: copy a bit of code to $C, then jump to it.
* The bit of code clears RAM starting from its own end, until it
* gets a bus error.  On a TT, it then clears all of fast RAM, too.
* In either case, the bus error vector gets set to point to the
* reset vector from address 4.
*
* I was going to worry about ssp, but if ssp is trashed, you won't
* get here either, so don't worry about it.
*
* STPAD doesn't give a bus error at the end of memory: we have to
* compile in the limit of 1MB and clear it from ROM.
*
* Yes, you really have to clear from ROM.  If you cleared 4MB on a 1MB
* machine you would clear out the (shadow of the) bus error vector itself.
* This is also true of SPARROW, which is another machine where if there is
* one megabyte it shadows.
*
* We could check the memory-size bits in Sparrow and see how much there
* is, but we don't. Like STPAD, we clear 1MB regardless.
*
*************************************************************************

.globl coldboot
coldboot:
	move.w	#$2700,sr
.if STPAD | SPARROW
.if M68030
	move.l	#$808,d0		; clobber the cache
	movec	d0,cacr			; (clear & disable)
	moveq.l	#0,d0
	movec	d0,vbr			; write 0 to the vector base address
	pmove	tdis,tc
	dc.l	$f0390800,tdis		; pmove tdis,tt0
	dc.l	$f0390c00,tdis		; pmove tdis,tt1
.data
tdis:	dc.l	0
.text

.endif

	move.l	$4,$8			; set bus error to reset vector
	move.l	#$c,a0			; start clearing at $c
	moveq.l	#0,d0
	move.w	#$fffe,d1		; clear the first megabyte or so
cploop:	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	dbra	d1,cploop
	move.l	$4,a0			; get reset vector from ROM
	jmp	(a0)
.else
.if M68030
	move.l	#$808,d0		; clobber the cache
	movec	d0,cacr			; (clear & disable)
	moveq.l	#0,d0
	movec	d0,vbr			; write 0 to the vector base address
	pmove	tdis,tc
	dc.l	$f0390800,tdis		; pmove tdis,tt0
	dc.l	$f0390c00,tdis		; pmove tdis,tt1
.data
tdis:	dc.l	0
.text

.endif

	move.w	#(coldend-coldcode)/4,d0	; number of longs - 1
	lea.l	coldcode(PC),a0
	move.l	#$c,a1
mloop:	move.l	(a0)+,(a1)+
	dbra	d0,mloop
	jmp	$c			; with no cache this is safe

*
* cold boot code - clear all of slow memory (until bus error),
* then all of fast memory (until bus error) if on a TT.
* 

coldcode:
.if TT
	lea.l	berr1(PC),a0	; TT: bus error goes to second phase
	move.l	a0,$8
.else
	move.l	$4,$8		; not TT: bus error jumps to reset vector
.endif
	lea.l	coldend(PC),a0	; start clearing here
	moveq.l	#0,d0
sloop:	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	bra	sloop

.if TT
berr1:	move.l	$4,$8		; copy reset vector to bus error vector
	lea.l	$01000000,a0
floop:	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	bra	floop
.endif
coldend:
	nop
.endif

*************************************************************************
*									*
*	protocol for accessing a gi sound chip register			*
*									*
*	this bios call must be accessed in supervisor state		*
*	because it affects the 'sr' register				*
*									*
*	entry								*
*									*
*	void	giaccess(data,register)					*
*	word	data,register						*
*									*
*		data -- data register read/write data			*
*									*
*		register -- chip register to select			*
*		d1 = #$0000	;selects read operation of the register *
*		d1 = #$80 .or .xx	;selects write xx to register	*
*		example write to portb - $80 .or. $0f = $8f		*
*									*
*	exit								*
*	read operations							*
*	d0.b -- data register contains byte of date			*
*	write operations						*
*	d0.b -- data register contains a verification of written data	*
*									*
*									*
*************************************************************************

	.globl	giaccess

giaccess:
	move.w	4(sp),d0
	move.w	6(sp),d1
gientry:
	move	sr,-(a7)
	ori	#$0700,sr
	movem.l d1-d2/a0,-(a7)	;save affected registers
	lea	giselect,a0	;init desired gi register addr
	move.b	d1,d2		;make a copy to test for read or write
	andi.b	#$f,d1		;turn off any extraneous bits
	move.b	d1,(a0)		;select register
	asl.b	#1,d2		;shift once for carry bit detection
	bcc.b	giread		;carry clear, so do a read operation
giwrit:	move.b	d0,2(a0)	;init the memory location
giread:	moveq	#$0,d0		;clear out register
	move.b	(a0),d0		;grab the data from the gi register
	movem.l (a7)+,d1-d2/a0	;restore affected registers
	move	(a7)+,sr
	rts			;return with data in d0


*************************************************************************
*		routine to turn on the dtr signal			*
*************************************************************************
	.globl	dtron
dtron:
	move.b	#%11101111,d2	;;q
	bra.b	offbit

*************************************************************************
*									*
*	routine to set any bit in the gi port a area			*
*									*
*	entry								*
*									*
*	void	ongibit(bitnum)						*
*	word	bitnum							*
*									*
*		bitnum - byte size bit mask with desired bit set to "1"	*
*									*
*************************************************************************

	.globl	ongibit

ongibit:
	moveq	#$0,d2
	move.w	4(sp),d2
onbit:	movem.l d0-d2,-(a7)
	move	sr,-(a7)
	ori	#$0700,sr
	moveq	#porta,d1	;get ready to read in the port a contents
	move.l	d2,-(a7)
	bsr.b	gientry		;go get it...
	move.l	(a7)+,d2
	or.b	d2,d0		;set bit(s) on
	move.b	#porta+$80,d1	;setup to write to port a ;;q
	bsr.b	gientry		;go set it and return
	move	(a7)+,sr
	movem.l (a7)+,d0-d2
	rts

*************************************************************************
*									*
*	routine to clear any bit in the gi port a area			*
*									*
*	entry								*
*									*
*	void	offgibit(bitnum)					*
*	word	bitnum							*
*									*
*		bitnum - byte size bit mask with desired bit set to "0"	*
*									*
*************************************************************************

	.globl	offgibit

offgibit:
	moveq	#$0,d2
	move.w	4(sp),d2
offbit:	movem.l d0-d2,-(a7)
	move	sr,-(a7)
	ori	#$0700,sr
	moveq	#porta,d1	;get ready to read in the port a contents
	move.l	d2,-(a7)
	bsr.b	gientry		;go get it...
	move.l	(a7)+,d2
	and.b	d2,d0		;turn bit(s) off
	move.b	#porta+$80,d1	;setup to write to port a ;;q
	bsr.b	gientry		;go set it and return
	move	(a7)+,sr
	movem.l (a7)+,d0-d2
	rts


*************************************************************************
*									*
*		EXTENDED RBP BIOS MOUSE INIT CALL			*
*									*
*	entry:								*
*									*
*	void	initmous(type,param,intvec)				*
*	word	type							*
*	long	param,intvec						*
*									*
*		type - key/abs/rel/off	mouse function requested	*
*			4/  2/  1/  0	value				*
*		param - address of parameter block			*
*		intvec - mouse interrupt vector				*
*									*
*									*
*	parameter block definition:					*
*									*
*	byte 0 - y=0 at top/bottom; if non-zero then y=0 at bottom	*
*		otherwise y=0 at top					*
*	byte 1 - parameter for set mouse buttons command		*
*	byte 2 - x threshold/scale/delta parameter			*
*	byte 3 - y threshold/scale/delta parameter			*
*									*
*	the following bytes are required for the absolute mouse only	*
*									*
*	byte 4 - xmsb for absolute mouse maximum position		*
*	byte 5 - xlsb for absolute mouse maximum position		*
*	byte 6 - ymsb for absolute mouse maximum position		*
*	byte 7 - ylsb for absolute mouse maximum position		*
*	byte 8 - xmsb for absolute mouse initial position		*
*	byte 9 - xlsb for absolute mouse initial position		*
*	byte a - ymsb for absolute mouse initial position		*
*	byte b - ylsb for absolute mouse initial position		*
*									*
*************************************************************************

	.globl	initmouse

initmouse:
*	first we determine if the init is for a absolute, relative, or keycode
*	mouse action.

	tst.w	$4(sp)		;turn mouse off?
	beq.b	im1		;yes...disable mouse
	move.l	$a(sp),msintvec.w	;init the mouse interrupt vector
	move.l	$6(sp),a3
	cmpi.w	#$1,$4(sp)	;relative mouse request?
	beq.b	im2		;yes...
	cmpi.w	#$2,$4(sp)	;absolute mouse request?
	beq.b	im3		;yes...
	cmpi.w	#$4,$4(sp)	;keycode mouse request?
	beq.b	im4		;yes...
	moveq	#$0,d0		;error condition returned -- improper request
	rts
im1:	moveq	#$12,d1		;disable mouse
	bsr	ikbdput
	move.l	#xbtexit,msintvec.w	;re-init the mouse interrupt vector
	bra.b	imexit
im2:
	lea	transbuf.w,a2	;set transfer buffer pointer
	move.b	#$8,(a2)+	;set to relative mouse
	move.b	#$b,(a2)+	;set relative mouse threshold x,y
	bsr.b	setmouse
	moveq	#7-1,d3		;set length of string -1 to transfer
	lea	transbuf.w,a2	;set transfer buffer pointer
	bsr	ikbdstr		;do transfer to ikbd
	bra.b	imexit
im3:
	lea	transbuf.w,a2	;set transfer buffer pointer
	move.b	#$9,(a2)+	;set to absolute mouse
	move.b	4(a3),(a2)+	;set xmsb max
	move.b	5(a3),(a2)+	;set xlsb max
	move.b	6(a3),(a2)+	;set ymsb max
	move.b	7(a3),(a2)+	;set ylsb max
	move.b	#$c,(a2)+	;set absolute mouse scale
	bsr.b	setmouse
	move.b	#$e,(a2)+	;load initial absolute mouse position
	move.b	#$0,(a2)+	;filler load
	move.b	8(a3),(a2)+	;initial xmsb absolute mouse position
	move.b	9(a3),(a2)+	;initial xlsb absolute mouse position
	move.b	$a(a3),(a2)+	;initial ymsb absolute mouse position
	move.b	$b(a3),(a2)+	;initial ylsb absolute mouse position
	moveq	#17-1,d3	;set length of string -1 to transfer
	lea	transbuf.w,a2	;set transfer buffer pointer
	bsr	ikbdstr		;do transfer to ikbd
	bra.b	imexit
im4:
	lea	transbuf.w,a2	;set transfer buffer pointer
	move.b	#$a,(a2)+	;set to mouse keycode mode
	bsr.b	setmouse
	moveq	#6-1,d3		;set length of string -1 to transfer
	lea	transbuf.w,a2	;set transfer buffer pointer
	bsr	ikbdstr		;do transfer to ikbd
imexit:	moveq	#-1,d0		;set to true to indicate good init
	rts
setmouse:
	move.b	2(a3),(a2)+	;set x threshold/scale/delta
	move.b	3(a3),(a2)+	;set y threshold/scale/delta
	moveq	#$10,d1		;setup to determine if top/bottom
	sub.b	0(a3),d1	;set y=0 at ?
	move.b	d1,(a2)+
	move.b	#$7,(a2)+	;set mouse button action
	move.b	1(a3),(a2)+	;mouse button parameter
	rts

*************************************************************************
*									*
*		EXTENDED RBP BIOS TIMER INIT CALL			*
*									*
*	entry:								*
*									*
*	void	xbtimer(id,control,data,intvec)				*
*	word	id,control,data						*
*	long	intvec							*
*									*
*		intvec - timer interrupt vector				*
*		control - timer's control setting			*
*		data - timer's data register setting			*
*		id - timer id	a-0, b-1, c-2, d-3			*
*									*
*	Special Note:							*
*									*
*	In the interest of preserving as many features for the user	*
*	in the future, timer A should be reserved for the end-user	*
*	or independent software vendor's application program.  System	*
*	software or those application needing just a "tick" should	*
*	constrain themselves to timer C, which is adequate for delay	*
*	and other timing uses.  Future hardware may or may not bring	*
*	out the timer A input line out...giving software developers	*
*	another useful aspect of the machine to utilize.		*
*									*
*	The recommended usage of the timers is as follows:		*
*									*
*	Timer A - Reserved for end-users and stand-alone applications.	*
*	Timer B - Reserved for screen graphics, primarily.		*
*	Timer C - Reserved for system timing (GSX,GEM,DESKTOP,ET.AL).	*
*	Timer D - Reserved for baud rate control of RS-232 port,	*
*		 the interrupt vector is available to anyone.		*
*									*
*************************************************************************

	.globl	xbtimer

xbtimer:
	moveq	#$0,d0
	moveq	#$0,d1
	moveq	#$0,d2
	move.w	$4(sp),d0
	move.w	$6(sp),d1
	move.w	$8(sp),d2
	bsr	setimer	 	;setup the timer
	tst.l	$a(sp)		;if >$7fffffff then skip and exit
	bmi.b	xbtexit
	movea.l $a(sp),a2	;setup for initint call
	moveq	#$0,d1		;clear long
	lea	xbtim(PC),a1	;point to timer -> interrupt # translation tab
	andi.l	#$ff,d0		;mask off the highest three bytes in register
	move.b	0(a1,d0),d0	;setup for initint call
	bsr	initint
xbtexit:
	rts

xbtim:	dc.b	$d,$8,$5,$4
	.even

*************************************************************************
*									*
*		KEYBOARD TRANSLATION TABLE CHANGE CALL			*
*									*
*	entry:								*
*									*
*	long	keytrans(unshift,shift,capslock)			*
*	long	unshift,shift,capslock					*
*									*
*		-1 signifies no change to vector			*
*									*
*	exit:								*
*		d0.l - returns pointer to beginning of			*
*			key translation address pointers		*
*		order of pointers is:					*
*		unshifted,shifted,caps-locked				*
*		Note:  buffer space for each table should $80!!		*
*									*
* New info:								*
*	The returned longword points to SIX table pointers; the first	*
* 	three are as above, the next three are ALT-key tables.  The	*
*	alt-key tables consist of scan-code/ASCII-code pairs for	*
*	the unshift, shift, and caps-lock cases.  Each table		*
*	ends with a null scan code.					*
*									*
*************************************************************************

	.globl	keytrans

keytrans:
	tst.l	$4(sp)
	bmi.b	kt1
	move.l	$4(sp),skeytran.w
kt1:	tst.l	$8(sp)
	bmi.b	kt2
	move.l	$8(sp),skeyshif.w
kt2:	tst.l	$c(sp)
	bmi.b	kt3
	move.l	$c(sp),skeycl.w
kt3:	move.l	#skeytran,d0
	rts

*************************************************************************
*									*
*		RESTORE BIOS KEYBOARD TRANSLATION TABLE			*
*									*
*	entry:								*
*									*
*	void	bioskeys()						*
*									*
* This code got a lot worse with internationalization, becuase each	*
* country's table has its own name.  For the one-country case, we	*
* select the names at compile-time; for the many-country case, we	*
* check preferences (NVRAM) now.					*
*									*
* New call: Bioskset(code) does what Bioskeys() does, but for a given	*
* country code.  Returns 0 for success, -1 for error (unknown code).	*
* If you don't have ALLKBS set, always returns -1.			*
*									*
*************************************************************************

	.globl	bioskeys
	.globl	bioskset

.if ALLKBS

.globl NVMaccess

; 920916	towns	changed the starting address of the NVMaccess 
;					call made below. With Falcon TOS, the starting 
;					address changed from 2 to 7. Since we never used
;					the NVRAM _akp settings before Falcon TOS, the 
;					change of location doesn't matter.

bioskeys:
	subq.l	#2,sp		; get space on stack
	move.l	sp,a0
	pea	1(a0)		; push buffer address
	move.w	#1,-(sp)	; count of one
	move.w	#7,-(sp)	; start address of seven (used to be two)
	move.w	#0,-(sp)	; read operation
	bsr	NVMaccess
	add.w	#10,sp
	move.w	(sp)+,d1	; get value read from NVRAM (only d1.b)
	tst.w	d0
	bne	nvinvalid

* value in NVRAM was valid, but if it's larger than the number of countries
* we know about then we use zero

	cmp.b	#NKBDS,d1
	blo	nvok
nvinvalid:
	moveq.l	#0,d1		; invalid: use zero
	bra	nvok

* entry point for the Bioskset(code) call

bioskset:
	move.w	4(sp),d1
	cmp.b	#NKBDS,d1
	blo	nvok
	move.l	#-1,d0
	rts

* continuation point: d1 is a country code, known to be in range.

nvok:
	ext.w	d1
	add.w	d1,d1
	move.w	d1,d0
	add.w	d1,d1
	add.w	d1,d0
	add.w	d0,d0
	add.w	d0,d0		; d0 is now d1*6*4

	move.l	#kbtabtab,a0
	add.w	d0,a0
	move.l	(a0)+,skeytran.w
	move.l	(a0)+,skeyshif.w
	move.l	(a0)+,skeycl.w
	move.l	(a0)+,salttran.w
	move.l	(a0)+,saltshif.w
	move.l	(a0)+,saltcl.w
	moveq.l	#0,d0		; return zero for success

	clr.b	keyrep.w	; also nuke key repeat
	rts
.else

* Non-ALLKBS case: bioskset returns -1 always.

bioskset:
	moveq.l	#-1,d0
	rts

bioskeys:
.if (country == usa)
	move.l	#usatran,skeytran.w
	move.l	#usashif,skeyshif.w
	move.l	#usacl,skeycl.w
.endif

.if (country == uk)
	move.l	#uktran,skeytran.w
	move.l	#ukshif,skeyshif.w
	move.l	#ukcl,skeycl.w
.endif

.if (country == germany)
	move.l	#grmtran,skeytran.w
	move.l	#grmshif,skeyshif.w
	move.l	#grmcl,skeycl.w
.endif

.if (country == france)
	move.l	#fretran,skeytran.w
	move.l	#freshif,skeyshif.w
	move.l	#frecl,skeycl.w
.endif

.if (country == swissfra)
	move.l	#swftran,skeytran.w
	move.l	#swfshif,skeyshif.w
	move.l	#swfcl,skeycl.w
.endif

.if (country == swissger)
	move.l	#swgtran,skeytran.w
	move.l	#swgshif,skeyshif.w
	move.l	#swgcl,skeycl.w
.endif

.if (country == italy)
	move.l	#itatran,skeytran.w
	move.l	#itashif,skeyshif.w
	move.l	#itacl,skeycl.w
.endif

.if (country == spain)
	move.l	#spatran,skeytran.w
	move.l	#spashif,skeyshif.w
	move.l	#spacl,skeycl.w
.endif

.if (country == sweden)
	move.l	#swetran,skeytran.w
	move.l	#sweshif,skeyshif.w
	move.l	#swecl,skeycl.w
.endif

	clr.b	keyrep.w		; also nuke key repeat
	rts
.endif

*************************************************************************
*									*
*		RETURN IKBD SUBSYSTEM INTERRUPT TABLE POINTER		*
*									*
*	entry:								*
*									*
*	long	dosound(ptr) ; returns current IP or zero for none.	*
*	long	ptr	;points to start of sound interpreter table	*
*			;or negative for no change.			*
*									*
*************************************************************************

	.globl	dosound

dosound:
	move.l	cursnd.w,d0		; return current status in D0.L
	move.l	4(sp),d1		; if new ptr < 0, then just return
	bmi	ds_r			; (invalid ptr, so return)
	move.l	d1,cursnd.w		; setup new sound ptr
	clr.b	timer.w		; zap sound timer register
ds_r:	rts

*************************************************************************
*									*
*		SET/RETURN PRINTER CONFIGURATION WORD			*
*									*
*	entry:								*
*									*
*	word	setprt(pconfig)						*
*	word	pconfig	;sets/gets printer information word		*
*									*
*									*
*************************************************************************

	.globl	setprt

setprt:
	move.w	pconfig.w,d0	;get current config word before we change it
	tst.w	4(sp)		;see if we don't change the word
	bmi.b	nosetp		;don't set printer word
	move.w	4(sp),pconfig.w	;set printer config word
nosetp:	rts

*************************************************************************
*									*
*		SET/RETURN KEY REPEAT VALUES				*
*									*
*	entry:								*
*									*
*	word	kbrate(initial,repeat)					*
*	word	initial,repeat						*
*									*
*	initial determines the number of 50 hz cycles to wait before	*
*	a keyrepeat is to commence.  repeat determines the interval	*
*	between keyrepeats after the initial pause.			*
*									*
*************************************************************************

	.globl	kbrate

kbrate:
	move.w	cdelay1.w,d0	;get current initial/repeat values
	tst.w	4(sp)		;see if we don't change the word
	bmi.b	kbrate1		;don't set key repeat values
	move.w	4(sp),d1	;set key repeat values
	move.b	d1,cdelay1.w	;set initial delay
	tst.w	6(sp)		;see if we don't change the word
	bmi.b	kbrate1		;don't set key repeat values
	move.w	6(sp),d1	;set key repeat values
	move.b	d1,cdelay2.w	;set subsequent delay
kbrate1:
	rts

*************************************************************************
*									*
*		RETURN POINTER TO IKBD/MIDI INTERRUPT VECTORS		*
*									*
*	entry:								*
*									*
*	long	ikbdvecs()						*
*		returns a pointer to the midi interrupt vector and	*
*		ikbd subsystem interrupt vector table.  the table	*
*		structure is as follows:				*
*									*
*	midivec		ds.l	1	;midi interrupt handler vector	*
*	vkbderr		ds.l	1	;keyboard error handler address	*
*	vmiderr		ds.l	1	;midi error handler address	*
*	statintvec	ds.l	1	;ikbd status interrupt vector	*
*	msintvec	ds.l	1	;mouse interrupt vector		*
*	clkintvec	ds.l	1	;realtime clk interrupt vector	*
*	joyintvec	ds.l	1	;joystick interrupt vector	*
*	midisys		ds.l	1	;midi system interrupt handler	*
*	ikbdsys		ds.l	1	;ikbd system interrupt handler	*
*									*
*	note:	msintvec is modified via the initmouse system function	*
*		call.  since gem uses this vector, modifying it can be	*
*		fatal while running under gem.  clkintvec is used by	*
*		gemdos.  its pre-inited vector must be restored for	*
*		proper gemdos operation.  Caveat hacker!		*
*									*
*									*
*************************************************************************

	.globl	ikbdvecs

ikbdvecs:
	move.l	#midivec,d0
	rts


*************************************************************************
*									*
*	C Timer interrupt routine to process the PSG sound table	*
*									*
*************************************************************************
*+ (lmd)
* timercint - timer c interrupt handler
* divide 200 Hz interrupt frequency to 50 hz, and do:
*	sound handler processing
*	key-repeat processing;
*	control-g bell and keyclick if enabled via sound handler
*	system timer-tick handoff.
*	updates:	tc_rot (every tick)
*
*	imports:	etv_timer (timer handoff vector)
*			_timr_ms (timer calibration value)
*
*-

timercint:
	add.l	#1,_hz_200	;increment raw tick counter
	rol.w	tc_rot		;rotate divisor bits
	bpl.b	t_punt		;if not 4th interrupt, then return

	movem.l	d0-d7/a0-a6,-(sp)

	bsr.b	sndirq		;process sounds...

	btst.b	#$1,conterm.w	;check for key repeat enabled
	beq.b	krexit		;not enabled

*	process for repeat key function first because it can affect the sound
*	table if enabled and the user is 'using'...

	tst.b	keyrep.w
	beq.b	krexit
	tst.b	kdelay1.w
	beq.b	kr1
	subi.b	#1,kdelay1.w
	bne.b	krexit
kr1:	subi.b	#1,kdelay2.w
	bne.b	krexit
	move.b	cdelay2.w,kdelay2.w
	move.b	keyrep.w,d0
	lea	kbufrec.w,a0
	bsr	ari16		;repeat key stroke and stuff into buffer
krexit:
*+ (lmd)
* Call system timer vector
* (first guy in the system daisy-chain)
*
*-

	move.w	_timr_ms.w,-(sp)	;push #ms/tick
	move.l	etv_timer.w,a0	; get vector
	jsr	(a0)		; call it
	addq	#2,sp		; cleanup stack

tick1:	movem.l	(sp)+,d0-d7/a0-a6
t_punt:
*	bclr.b	#5,isrb+mfp	;clear the interrupt channel
	move.b	#%11011111,isrb+mfp	; was bclr but that's wrong
	rte

********************************************
*
*  Quick & dirty sound stuff
*
*
*  Programmed by Dave Staugas
*		 14 Mar 1985
*
*  To start a sound, load the 32-bit address of the
*			byte stream for that sound in 32-bit
*			"cursnd", & zero the 8-bit "timer"
*
*   Sound interrupt routine
*   Called from timer C irq
*
sndirq:
	movem.l	a0/d0-d1,-(sp)
	move.l	cursnd.w,d0		;get current sound ptr
	beq	snd1			;br to exit if zero, inactive
	movea.l	d0,a0			;ptr to a0
	move.b	timer.w,d0		;check delay timer
	beq.b	snd3			;br over delay timer update if not on
*
	subq.b	#1,d0			;tick off delay timer
	move.b	d0,timer.w		;save new
	bra.b	snd1			;skip sound update this time
snd3:
	move.b	(a0)+,d0		;pick up next sound command
	bmi.b	snd2			;if minus, go do special
*
	move.b	d0,giselect.w		;else, register load command--select this reg
	cmpi.b	#7,d0			;reg. 7 selected?
	bne.b	sn1			;br if no
*
	move.b	(a0)+,d1		;get data to write to reg 7
	andi.b	#$3f,d1			;always leave i/o port settings alone
	move.b	rddata.w,d0		;get mixer contents
	andi.b	#$c0,d0			;mask off non-useful info...
	or.b	d1,d0			;generate new setting
	move.b	d0,wrdata.w		;write data
	bra.b	snd3			;go for next command
sn1:
	move.b	(a0)+,wrdata.w	;write next byte as data directly to reg
	bra.b	snd3			;go for next command
*
*  special case command
*
snd2:
	addq.b	#1,d0			;was command 255?
	bpl.b	snd5			;br if yes--set delay timer
*
	cmpi.b	#129,d0			;was command 128 (before increment)
	bne.b	snd6			;br if not
*
*  command 128
*
	move.b	(a0)+,auxd.w		;128--set aux data from next byte in stream
	bra.b	snd3			;go for next command
*
*  command > 128
*
snd6:
	cmpi.b	#130,d0			;command greater than 129
	bne.b	snd5			;br if yes--must be set timer
*
*  command 129
*
	move.b	(a0)+,giselect.w	;129--select register
	move.b	(a0)+,d0		;get increment step (signed)
	add.b	d0,auxd.w		;add to aux data
	move.b	(a0)+,d0		;get terminating value
	move.b	auxd.w,wrdata.w	;load reg from data in auxd
	cmp.b	auxd.w,d0		;reached end of cycle?
	beq.b	snd4			;br if so
*
*  still within loop, reset sound pointer to iterate for next irq
*
	subq	#4,a0			;back up sound ptr to repeat this command
	bra.b	snd4			;update ptr & exit
*
*  set delay timer
*
snd5:
	move.b	(a0)+,timer.w		;set delay timer from next byter in stream
	bne.b	snd4			;if non-zero, real delay here
	movea.w	#0,a0			;else, sound terminator--set ptr to null
snd4:
	move.l	a0,cursnd.w		;update sound ptr
snd1:
	movem.l	(sp)+,a0/d0-d1		;pop stack & exit
	rts

*+
* this function moved to the end of the BIOS so it's closer to VDI in 
* the link -- otherwise you get 16-bit PC relative overflow because VDI
* does a BSR to here.
*-
	.globl	ringbel

ringbel:
	btst.b	#$2,conterm.w
	beq.b	rgbel
	move.l	bell_hook,a0
	jsr	(a0)
	rts

	.globl	def_bell
def_bell:
	move.l	#bellsnd,cursnd.w
	move.b	#0,timer.w
rgbel:
	rts



*************************************************************************
*									*
*	end of gemdos bios portion					*
*									*
*	Keyboard translation tables					*
*									*
* New as of 5/92: I just duplicated these tables, gave them new		*
* labels, and put them all in the same ROM if ALLKBS.  In that case,	*
* all countries are in one ROM, and you select at run time (in NVRAM)	*
* what keyboard you want to boot with.					*
*									*
*************************************************************************

	.even
	.data

.if ((country == usa) | ALLKBS)

usatran:
	dc.b	$00,$1b,'1','2','3','4','5','6'
	dc.b	'7','8','9','0','-','=',$08,$09
	dc.b	'q','w','e','r','t','y','u','i'
	dc.b	'o','p','[',']',$0D,$00,'a','s'
	dc.b	'd','f','g','h','j','k','l',';'
	dc.b	$27,'`',$00,'\','z','x','c','v'
	dc.b	'b','n','m',',','.','/',$00,$00
	dc.b	$00,$20,$00,$00,$00,$00,$00,$00

	dc.b	$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,'-',$00,$00,$00,'+',$00
	dc.b	$00,$00,$00,$7f,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,'(',')','/','*','7'
	dc.b	'8','9','4','5','6','1','2','3'
	dc.b	'0','.',$0D,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00

usashif:
	dc.b	$00,$1b,'!','@','#','$','%','^'
	dc.b	'&','*','(',')','_','+',$08,$09
	dc.b	'Q','W','E','R','T','Y','U','I'
	dc.b	'O','P','{','}',$0D,$00,'A','S'
	dc.b	'D','F','G','H','J','K','L',':'
	dc.b	'"','~',$00,'|','Z','X','C','V'
	dc.b	'B','N','M','<','>','?',$00,$00
	dc.b	$00,$20,$00,$00,$00,$00,$00,$00

	dc.b	$00,$00,$00,$00,$00,$00,$00,$37
	dc.b	$38,$00,'-',$34,$00,$36,'+',$00
	dc.b	$32,$00,$30,$7f,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,'(',')','/','*','7'
	dc.b	'8','9','4','5','6','1','2','3'
	dc.b	'0','.',$0D,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00

usacl:
	dc.b	$00,$1b,'1','2','3','4','5','6'
	dc.b	'7','8','9','0','-','=',$08,$09
	dc.b	'Q','W','E','R','T','Y','U','I'
	dc.b	'O','P','[',']',$0D,$00,'A','S'
	dc.b	'D','F','G','H','J','K','L',';'
	dc.b	$27,'`',$00,'\','Z','X','C','V'
	dc.b	'B','N','M',',','.','/',$00,$00
	dc.b	$00,$20,$00,$00,$00,$00,$00,$00

	dc.b	$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,'-',$00,$00,$00,'+',$00
	dc.b	$00,$00,$00,$7f,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,'(',')','/','*','7'
	dc.b	'8','9','4','5','6','1','2','3'
	dc.b	'0','.',$0D,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00

.endif


.if ((country == uk) | ALLKBS)

uktran:
	dc.b	$00,$1b,'1','2','3','4','5','6'
	dc.b	'7','8','9','0','-','=',$08,$09
	dc.b	'q','w','e','r','t','y','u','i'
	dc.b	'o','p','[',']',$0D,$00,'a','s'
	dc.b	'd','f','g','h','j','k','l',';'
	dc.b	$27,'`',$00,'#','z','x','c','v'
	dc.b	'b','n','m',',','.','/',$00,$00
	dc.b	$00,$20,$00,$00,$00,$00,$00,$00

	dc.b	$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,'-',$00,$00,$00,'+',$00
	dc.b	$00,$00,$00,$7f,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	'\',$00,$00,'(',')','/','*','7'
	dc.b	'8','9','4','5','6','1','2','3'
	dc.b	'0','.',$0D,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00

ukshif:
	dc.b	$00,$1b,'!','"',$9c,'$','%','^'
	dc.b	'&','*','(',')','_','+',$08,$09
	dc.b	'Q','W','E','R','T','Y','U','I'
	dc.b	'O','P','{','}',$0D,$00,'A','S'
	dc.b	'D','F','G','H','J','K','L',':'
	dc.b	'@',$ff,$00,'~','Z','X','C','V'
	dc.b	'B','N','M','<','>','?',$00,$00
	dc.b	$00,$20,$00,$00,$00,$00,$00,$00

	dc.b	$00,$00,$00,$00,$00,$00,$00,$37
	dc.b	$38,$00,'-',$34,$00,$36,'+',$00
	dc.b	$32,$00,$30,$7f,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	'|',$00,$00,'(',')','/','*','7'
	dc.b	'8','9','4','5','6','1','2','3'
	dc.b	'0','.',$0D,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00

ukcl:
	dc.b	$00,$1b,'1','2','3','4','5','6'
	dc.b	'7','8','9','0','-','=',$08,$09
	dc.b	'Q','W','E','R','T','Y','U','I'
	dc.b	'O','P','[',']',$0d,$00,'A','S'
	dc.b	'D','F','G','H','J','K','L',';'
	dc.b	$27,'`',$00,'#','Z','X','C','V'
	dc.b	'B','N','M',',','.','/',$00,$00
	dc.b	$00,$20,$00,$00,$00,$00,$00,$00

	dc.b	$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,'-',$00,$00,$00,'+',$00
	dc.b	$00,$00,$00,$7f,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	'\',$00,$00,'(',')','/','*','7'
	dc.b	'8','9','4','5','6','1','2','3'
	dc.b	'0','.',$0D,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00


.endif


.if ((country == germany) | ALLKBS)

grmtran:
	dc.b	$00,$1b,'1','2','3','4','5','6'
	dc.b	'7','8','9','0',$9e,$27,$08,$09
	dc.b	'q','w','e','r','t','z','u','i'
	dc.b	'o','p',$81,'+',$0D,$00,'a','s'
	dc.b	'd','f','g','h','j','k','l',$94
	dc.b	$84,'#',$00,'~','y','x','c','v'
	dc.b	'b','n','m',',','.','-',$00,$00
	dc.b	$00,$20,$00,$00,$00,$00,$00,$00

	dc.b	$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,'-',$00,$00,$00,'+',$00
	dc.b	$00,$00,$00,$7f,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	'<',$00,$00,'(',')','/','*','7'
	dc.b	'8','9','4','5','6','1','2','3'
	dc.b	'0','.',$0D,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00

grmshif:
	dc.b	$00,$1b,'!','"',$dd,'$','%','&'
	dc.b	'/','(',')','=','?','`',$08,$09
	dc.b	'Q','W','E','R','T','Z','U','I'
	dc.b	'O','P',$9a,'*',$0D,$00,'A','S'
	dc.b	'D','F','G','H','J','K','L',$99
	dc.b	$8e,'^',$00,'|','Y','X','C','V'
	dc.b	'B','N','M',';',':','_',$00,$00
	dc.b	$00,$20,$00,$00,$00,$00,$00,$00

	dc.b	$00,$00,$00,$00,$00,$00,$00,$37
	dc.b	$38,$00,'-',$34,$00,$36,'+',$00
	dc.b	$32,$00,$30,$7f,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	'>',$00,$00,'(',')','/','*','7'
	dc.b	'8','9','4','5','6','1','2','3'
	dc.b	'0','.',$0D,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00

grmcl:
	dc.b	$00,$1b,'1','2','3','4','5','6'
	dc.b	'7','8','9','0',$9e,$27,$08,$09
	dc.b	'Q','W','E','R','T','Z','U','I'
	dc.b	'O','P',$9a,'+',$0D,$00,'A','S'
	dc.b	'D','F','G','H','J','K','L',$99
	dc.b	$8e,'#',$00,'~','Y','X','C','V'
	dc.b	'B','N','M',',','.','-',$00,$00
	dc.b	$00,$20,$00,$00,$00,$00,$00,$00

	dc.b	$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,'-',$00,$00,$00,'+',$00
	dc.b	$00,$00,$00,$7f,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	'<',$00,$00,'(',')','/','*','7'
	dc.b	'8','9','4','5','6','1','2','3'
	dc.b	'0','.',$0D,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00

.endif

.if ((country == spain) | ALLKBS)

spatran:
	dc.b	$00,$1b,'1','2','3','4','5','6'
	dc.b	'7','8','9','0','-','=',$08,$09
	dc.b	'q','w','e','r','t','y','u','i'
	dc.b	'o','p',$27,$60,$0D,$00,'a','s'
	dc.b	'd','f','g','h','j','k','l',$a4
	dc.b	';',$87,$00,'\','z','x','c','v'
	dc.b	'b','n','m',',','.',$f8,$00,$00
	dc.b	$00,$20,$00,$00,$00,$00,$00,$00

	dc.b	$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,'-',$00,$00,$00,'+',$00
	dc.b	$00,$00,$00,$7f,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	'<',$00,$00,'(',')','/','*','7'
	dc.b	'8','9','4','5','6','1','2','3'
	dc.b	'0','.',$0D,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00

spashif:
	dc.b	$00,$1b,$ad,$a8,$9c,'$','%','/'
	dc.b	'&','*','(',')','_','+',$08,$09
	dc.b	'Q','W','E','R','T','Y','U','I'
	dc.b	'O','P','"','^',$0D,$00,'A','S'
	dc.b	'D','F','G','H','J','K','L',$a5
	dc.b	':','~',$00,'|','Z','X','C','V'
	dc.b	'B','N','M','?','!',$dd,$00,$00
	dc.b	$00,$20,$00,$00,$00,$00,$00,$00

	dc.b	$00,$00,$00,$00,$00,$00,$00,$37
	dc.b	$38,$00,'-',$34,$00,$36,'+',$00
	dc.b	$32,$00,$30,$7f,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	'>',$00,$00,'(',')','/','*','7'
	dc.b	'8','9','4','5','6','1','2','3'
	dc.b	'0','.',$0D,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00

spacl:
	dc.b	$00,$1b,'1','2','3','4','5','6'
	dc.b	'7','8','9','0','-','=',$08,$09
	dc.b	'Q','W','E','R','T','Y','U','I'
	dc.b	'O','P',$27,$60,$0D,$00,'A','S'
	dc.b	'D','F','G','H','J','K','L',$a5
	dc.b	';',$87,$00,'\','Z','X','C','V'
	dc.b	'B','N','M',',','.',$f8,$00,$00
	dc.b	$00,$20,$00,$00,$00,$00,$00,$00

	dc.b	$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,'-',$00,$00,$00,'+',$00
	dc.b	$00,$00,$00,$7f,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	'<',$00,$00,'(',')','/','*','7'
	dc.b	'8','9','4','5','6','1','2','3'
	dc.b	'0','.',$0D,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00

.endif


.if ((country == france) | ALLKBS)

fretran:
	dc.b	$00,$1b,'&',$82,'"',$27,'(',$dd
	dc.b	$8a,'!',$87,$85,')','-',$08,$09	;changed $80 to $87 dbg 8/29/85
	dc.b	'a','z','e','r','t','y','u','i'
	dc.b	'o','p','^','$',$0D,$00,'q','s'
	dc.b	'd','f','g','h','j','k','l','m'
	dc.b	$97,'`',$00,'#','w','x','c','v'
	dc.b	'b','n',',',';',':','=',$00,$00
	dc.b	$00,$20,$00,$00,$00,$00,$00,$00

	dc.b	$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,'-',$00,$00,$00,'+',$00
	dc.b	$00,$00,$00,$7f,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	'<',$00,$00,'(',')','/','*','7'
	dc.b	'8','9','4','5','6','1','2','3'
	dc.b	'0','.',$0D,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00

freshif:
	dc.b	$00,$1b,'1','2','3','4','5','6'
	dc.b	'7','8','9','0',$f8,'_',$08,$09
	dc.b	'A','Z','E','R','T','Y','U','I'
	dc.b	'O','P',$b9,'*',$0D,$00,'Q','S'
	dc.b	'D','F','G','H','J','K','L','M'
	dc.b	'%',$9c,$00,'|','W','X','C','V'
	dc.b	'B','N','?','.','/','+',$00,$00
	dc.b	$00,$20,$00,$00,$00,$00,$00,$00

	dc.b	$00,$00,$00,$00,$00,$00,$00,$37
	dc.b	$38,$00,'-',$34,$00,$36,'+',$00
	dc.b	$32,$00,$30,$7f,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	'>',$00,$00,'(',')','/','*','7'
	dc.b	'8','9','4','5','6','1','2','3'
	dc.b	'0','.',$0D,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00

frecl:
	dc.b	$00,$1b,'&',$90,'"',$27,'(',$dd	;changed $82 to $90 dbg 8/29/85
	dc.b	$8a,'!',$80,$B6,')','-',$08,$09	;changed $85 to $B6 dbg 8/29/85
	dc.b	'A','Z','E','R','T','Y','U','I'
	dc.b	'O','P','^','$',$0D,$00,'Q','S'
	dc.b	'D','F','G','H','J','K','L','M'
	dc.b	$97,'`',$00,'#','W','X','C','V'
	dc.b	'B','N',',',';',':','=',$00,$00
	dc.b	$00,$20,$00,$00,$00,$00,$00,$00

	dc.b	$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,'-',$00,$00,$00,'+',$00
	dc.b	$00,$00,$00,$7f,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	'<',$00,$00,'(',')','/','*','7'
	dc.b	'8','9','4','5','6','1','2','3'
	dc.b	'0','.',$0D,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00

.endif

.if ((country == sweden) | ALLKBS)

swetran:
	.dc.b   0,esc,"1234567890+",$82,bs,tab,'qwertyuiop',$86,$81,cr,0
	.dc.b	"asdfghjkl",$94,$84,"'",0,$5c,'zxcvbnm,.-',0,0,0,space,0
	.dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.dc.b	'-',0,0,0,'+',0,0,0,0,del
	.dc.b	0,0,0,0,0,0,0,0,0,0,0,0
	.dc.b	'<',0,0,'()/*7894561230.',cr
	.dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0

sweshif:
	.dc.b	0,esc,'!"#$%&/()=?',$90,bs,tab,'QWERTYUIOP',$8f,$9a,cr,0
	.dc.b	'ASDFGHJKL',$99,$8e,'*',0,'|ZXCVBNM;:_',0,0,0,space,0
	.dc.b	0,0,0,0,0,0,0,0,0,0,0,0,$37,$38,0
	.dc.b	'-',$34,0,$36,'+',0,$32,0,$30,del
	.dc.b	0,0,0,0,0,0,0,0,0,0,0,0
	.dc.b	'>',0,0,'()/*7894561230.',cr
	.dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0

swecl:
	.dc.b	0,esc,"1234567890+",$90,bs,tab,'QWERTYUIOP',$8f,$9a,cr,0
	.dc.b	"ASDFGHJKL",$99,$8e,"'",0,$5c,'ZXCVBNM,.-',0,0,0,space,0
	.dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.dc.b	'-',0,0,0,'+',0,0,0,0,del
	.dc.b	0,0,0,0,0,0,0,0,0,0,0,0
	.dc.b	'<',0,0,'()/*7894561230.',cr
	.dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0

.endif


.if ((country == italy) | ALLKBS)

itatran:
	dc.b	0,esc,'1','2','3','4','5','6','7','8','9','0',"'",$8d, bs,tab
	dc.b	'q','w','e','r','t','y','u','i','o','p',$8a,'+', cr,0,'a','s'
	dc.b	'd','f','g','h','j','k','l',$95,$85,$97,0,'\','z','x','c','v'
	dc.b	'b','n','m',',','.','-',0,0,0,' ',0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,'-',0,0,0,'+',0
	dc.b	0,0,0,del,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	'<',0,0,'(',')','/','*','7','8','9','4','5','6','1','2','3'
	dc.b	'0','.', cr,0,0,0,0,0,0,0,0,0,0,0,0,0

itashif:
	dc.b	0,esc,'!','"',$9c,'$','%','&','/','(',')','=','?','^', bs,tab
	dc.b	'Q','W','E','R','T','Y','U','I','O','P',$82,'*', cr,0,'A','S'
	dc.b	'D','F','G','H','J','K','L','@','#',$dd,0,'|','Z','X','C','V'
	dc.b	'B','N','M',';',':','_',0,0,0,' ',0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,$37,$38,0,'-',$34,0,$36,'+',0
	dc.b	$32,0,$30,del,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	'>',0,0,'(',')','/','*','7','8','9','4','5','6','1','2','3'
	dc.b	'0','.', cr,0,0,0,0,0,0,0,0,0,0,0,0,0

itacl:
	dc.b	0,esc,'1','2','3','4','5','6','7','8','9','0',"'",$8d, bs,tab
	dc.b	'Q','W','E','R','T','Y','U','I','O','P',$8a,'+', cr,0,'A','S'
	dc.b	'D','F','G','H','J','K','L',$95,$85,$97,0,'\','Z','X','C','V'
	dc.b	'B','N','M',',','.','-',0,0,0,' ',0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,'-',0,0,0,'+',0
	dc.b	0,0,0,del,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	'<',0,0,'(',')','/','*','7','8','9','4','5','6','1','2','3'
	dc.b	'0','.', cr,0,0,0,0,0,0,0,0,0,0,0,0,0

.endif


.if ((country == swissger) | ALLKBS)

swgtran:
        dc.b    0,esc,'1234567890',"'",'^',bs,tab,'qwertzuiop',$81,$B9,cr,0
        dc.b    "asdfghjkl",$94,$84,$DD,0,"$yxcvbnm,.-",0,0,0,space,0
        dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        dc.b    '-',0,0,0,'+',0,0,0,0,del
        dc.b     0,0,0,0,0,0,0,0,0,0,0,0
        dc.b    '<',0,0,'()/*7894561230.',cr
        dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0

swgshif:
        dc.b    0,esc,'+"*',$87,'%&/()=?`',bs,tab,'QWERTZUIOP',$8a,'!',cr,0
        dc.b    'ASDFGHJKL',$82,$85,$f8,0,$9c,'YXCVBNM;:_',0,0,0,space,0
        dc.b     0,0,0,0,0,0,0,0,0,0,0,0
        dc.b    '78',0,'-4',0,'6+',0,'2',0,'0',del
        dc.b     0,0,0,0,0,0,0,0,0,0,0,0
        dc.b    '>',0,0,'()/*7894561230.',cr
        dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0

swgcl:
        dc.b   0,esc,'1234567890',"'",'^',bs,tab,'QWERTZUIOP',$9a,$B9,cr,0
        dc.b    'ASDFGHJKL',$99,$8E,$DD,0,'$YXCVBNM,.-',0,0,0,space,0
        dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        dc.b    '-',0,0,0,'+',0,0,0,0,del
        dc.b     0,0,0,0,0,0,0,0,0,0,0,0
        dc.b    '<',0,0,'()/*7894561230.',cr
        dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0

.endif


.if ((country == swissfra) | ALLKBS)

swftran:
        dc.b    0,esc,'1234567890',"'",'^',bs,tab,'qwertzuiop',$8a,$B9,cr,0
        dc.b    "asdfghjkl",$82,$85,$DD,0,"$yxcvbnm,.-",0,0,0,space,0
        dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        dc.b    '-',0,0,0,'+',0,0,0,0,del
        dc.b     0,0,0,0,0,0,0,0,0,0,0,0
        dc.b    '<',0,0,'()/*7894561230.',cr
        dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0

swfshif:
        dc.b    0,esc,'+"*',$87,'%&/()=?`',bs,tab,'QWERTZUIOP',$81,'!',cr,0
        dc.b    'ASDFGHJKL',$94,$84,$f8,0,$9c,'YXCVBNM;:_',0,0,0,space,0
        dc.b     0,0,0,0,0,0,0,0,0,0,0,0
        dc.b    '78',0,'-4',0,'6+',0,'2',0,'0',del
        dc.b     0,0,0,0,0,0,0,0,0,0,0,0
        dc.b    '>',0,0,'()/*7894561230.',cr
        dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0

swfcl:
        dc.b   0,esc,'1234567890',"'",'^',bs,tab,'QWERTZUIOP',$8a,$B9,cr,0
        dc.b    'ASDFGHJKL',$82,$85,$DD,0,'$YXCVBNM,.-',0,0,0,space,0
        dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        dc.b    '-',0,0,0,'+',0,0,0,0,del
        dc.b     0,0,0,0,0,0,0,0,0,0,0,0
        dc.b    '<',0,0,'()/*7894561230.',cr
        dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0

.endif

********************
* These tables are never used because these countries don't get their own
* ROM any more: turkey, denmark, norway.
********************

.if country == turkey

keytran:
	dc.b	$00,$1b,'+','1','2','3','4','5'
	dc.b	'6','7','8','9','0','-',$08,$09
	dc.b	'f','g',$aa,'i','o','d','r','n'
	dc.b	'h','p','q','w',$0D,$00,'u',$9e
	dc.b	'e','a',$81,'t','k','m','l','y'
	dc.b	$a7,'^',$00,$27,'j',$94,'v','c'
	dc.b	$87,'z','s','b','.',',',$00,$00
	dc.b	$00,$20,$00,$00,$00,$00,$00,$00

	dc.b	$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,'-',$00,$00,$00,'+',$00
	dc.b	$00,$00,$00,$7f,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	'x',$00,$00,'(',')','/','*','7'
	dc.b	'8','9','4','5','6','1','2','3'
	dc.b	'0','.',$0D,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00

keyshif:
	dc.b	$00,$1b,'*','!',$22,$9c,'$','%'
	dc.b	$83,'/','(',')','=','_',$08,$09
	dc.b	'F','G',$a9,'I','O','D','R','N'
	dc.b	'H','P','Q','W',$0D,$00,'U',$9d
	dc.b	'E','A',$9a,'T','K','M','L','Y'
	dc.b	$a6,$60,$00,'?','J',$99,'V','C'
	dc.b	$80,'Z','S','B',':',';',$00,$00
	dc.b	$00,$20,$00,$00,$00,$00,$00,$00

	dc.b	$00,$00,$00,$00,$00,$00,$00,$37
	dc.b	$38,$00,'-',$34,$00,$36,'+',$00
	dc.b	$32,$00,$30,$7f,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	'X',$00,$00,'(',')','/','*','7'
	dc.b	'8','9','4','5','6','1','2','3'
	dc.b	'0','.',$0D,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00

keycl:
	dc.b	$00,$1b,'+','1','2','3','4','5'
	dc.b	'6','7','8','9','0','-',$08,$09
	dc.b	'F','G',$a9,'I','O','D','R','N'
	dc.b	'H','P','Q','W',$0D,$00,'U',$9d
	dc.b	'E','A',$9a,'T','K','M','L','Y'
	dc.b	$a6,'^',$00,$27,'J',$99,'V','C'
	dc.b	$80,'Z','S','B','.',',',$00,$00
	dc.b	$00,$20,$00,$00,$00,$00,$00,$00

	dc.b	$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,'-',$00,$00,$00,'+',$00
	dc.b	$00,$00,$00,$7f,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	'X',$00,$00,'(',')','/','*','7'
	dc.b	'8','9','4','5','6','1','2','3'
	dc.b	'0','.',$0D,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00

.endif



.if country == norway

keytran:
	.dc.b   0,esc,"1234567890+",$82,bs,tab,'qwertyuiop',$86,$81,cr,0
	.dc.b	"asdfghjkl",$b3,$91,"'",0,$5c,'zxcvbnm,.-',0,0,0,space,0
	.dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.dc.b	'-',0,0,0,'+',0,0,0,0,del
	.dc.b	0,0,0,0,0,0,0,0,0,0,0,0
	.dc.b	'<',0,0,'()/*7894561230.',cr
	.dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0

keyshif:
	.dc.b	0,esc,'!"#$%&/()=?',$90,bs,tab,'QWERTYUIOP',$8f,$9a,cr,0
	.dc.b	'ASDFGHJKL',$b2,$92,'*',0,'|ZXCVBNM;:_',0,0,0,space,0
	.dc.b	0,0,0,0,0,0,0,0,0,0,0,0,$37,$38,0
	.dc.b	'-',$34,0,$36,'+',0,$32,0,$30,del
	.dc.b	0,0,0,0,0,0,0,0,0,0,0,0
	.dc.b	'>',0,0,'()/*7894561230.',cr
	.dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0

keycl:
	.dc.b	0,esc,"1234567890+",$90,bs,tab,'QWERTYUIOP',$8f,$9a,cr,0
	.dc.b	"ASDFGHJKL",$b2,$92,"'",0,$5c,'ZXCVBNM,.-',0,0,0,space,0
	.dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.dc.b	'-',0,0,0,'+',0,0,0,0,del
	.dc.b	0,0,0,0,0,0,0,0,0,0,0,0
	.dc.b	'<',0,0,'()/*7894561230.',cr
	.dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0

.endif


.if country == denmark

keytran:
	.dc.b   0,esc,"1234567890+",$ba,bs,tab,'qwertyuiop',$86,'*',cr,0
	.dc.b	"asdfghjkl",$91,$b3,$82,0,'#','zxcvbnm,.-',0,0,0,space,0
	.dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.dc.b	'-',0,0,0,'+',0,0,0,0,del
	.dc.b	0,0,0,0,0,0,0,0,0,0,0,0
	.dc.b	'<',0,0,'()/*7894561230.',cr
	.dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0

keyshif:
	.dc.b	0,esc,'!"',$9c,'$%&/()=?`',bs,tab,'QWERTYUIOP',$8f,'^',cr,0
	.dc.b	'ASDFGHJKL',$92,$b2,$90,0,'~ZXCVBNM;:_',0,0,0,space,0
	.dc.b	0,0,0,0,0,0,0,0,0,0,0,0,$37,$38,0
	.dc.b	'-',$34,0,$36,'+',0,$32,0,$30,del
	.dc.b	0,0,0,0,0,0,0,0,0,0,0,0
	.dc.b	'>',0,0,'()/*7894561230.',cr
	.dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0

keycl:
	.dc.b	0,esc,"1234567890+`",bs,tab,'QWERTYUIOP',$8f,'^',cr,0
	.dc.b	"ASDFGHJKL",$92,$b2,$82,0,'~ZXCVBNM,.-',0,0,0,space,0
	.dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.dc.b	'-',0,0,0,'+',0,0,0,0,del
	.dc.b	0,0,0,0,0,0,0,0,0,0,0,0
	.dc.b	'<',0,0,'()/*7894561230.',cr
	.dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0

.endif

*
*
*  sound data...
*
*
*  format:
*
*	sound data usually is found in byte pairs, the first of which is the command
*	and the second is the argument.  However, some commands take on more than
*	1 argument.
*
*	cmd	function	argument(s)
*
*	00	load reg0	data0
*	01	load reg1	data0
*	02	load reg2	data0
*	03	load reg3	data0
*	04	load reg4	data0
*	05	load reg5	data0
*	06	load reg6	data0
*	07	load reg7	data0	note: b7 & b6 forced set for all data to reg 7
*	08	load reg8	data0
*	09	load reg9	data0
*	0A	load reg10	data0
*	0B	load reg11	data0
*	0C	load reg12	data0
*	0D	load reg13	data0
*
*	
*	80	init temp w/	data0
*
*	81	loop defined
*		by 3 args	data0 as register to load using temp
*				data1 as increment/decrement (signed) of temp
*				data2 as loop terminator value of temp
*
*	82-FF	set delay
*		timer		data0 is # of counts till next update
*					note: if data0 = 0, sound is terminated
*		
*
*
*
	.even
bellsnd:
	.dc.b	0,$34
	.dc.b	1,0
	.dc.b	2,0
	.dc.b	3,0
	.dc.b	4,0
	.dc.b	5,0
	.dc.b	6,0
	.dc.b	7,$FE
	.dc.b	8,$10		;enable envelope, ch a
	.dc.b	9,0
	.dc.b	10,0
	.dc.b	11,0
	.dc.b	12,$10
	.dc.b	13,9		;envelope single attack
	.dc.b	255,0
*
keyclk:
	.dc.b	0,$3B
	.dc.b	1,0
	.dc.b	2,0
	.dc.b	3,0
	.dc.b	4,0
	.dc.b	5,0
	.dc.b	6,0
	.dc.b	9,0		;regs 9 and 10 were not initialized before,
	.dc.b	10,0		;and some sounds changed keyclicks. Fixed?
	.dc.b	7,$FE
	.dc.b	8,$10		;enable envelope, ch a
	.dc.b	13,$3		;envelope single attack
	.dc.b	11,$80
	.dc.b	12,1
	.dc.b	255,0

