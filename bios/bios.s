******************* Revision Control System *****************************
*
* $Author: apratt $
* =======================================================================
*
* $Date: 89/02/06 12:20:25 $
* =======================================================================
*
* $Locker:  $
* =======================================================================
*
* $Log: bios.s,v $
* Revision 1.20  89/02/06  12:20:25  apratt
* Added a timeout to Gettime ... if time doesn't arrive in 1 sec, return 0.
*
* Revision 1.19  88/12/21  12:15:42  apratt
* Added comments around the ctl-alt-delete reset code, and saved 1 word
* nearby.  Big deal.
* 
* Revision 1.18  88/12/13  16:12:13  apratt
* Added (a5) to lots of otherwise-long accesses, both to low RAM and
* high I/O space.
* 
* Revision 1.17  88/11/18  11:04:15  apratt
* Documented with comments the fact that kstate is now officially
* fixed just after ikbdsys (which is to say, after the end of
* the vector list returned by Kbdvbase).  This has always been
* true; now it's official.  See the comment with "11/18/88" in it
* for details.
* 
* Revision 1.16  88/11/08  15:58:27  kbad
* Modified keyboard driver so that ISO keyboards can produce correct
* control keystrokes (previously, control was handled before alt, thus
* rendering the alt-control keystrokes useless).
* 
* Revision 1.15  88/11/02  15:22:35  apratt
* Raised IPL to 7 for the duration of the centronics strobe, so
* another interrupt can't cause the strobe to be active too long.
* 
* Revision 1.14  88/09/06  11:32:32  kbad
* Added DENMARK key table and driver, and fixed SWEDEN '|' on capslock.
* 
* Revision 1.13  88/08/08  17:56:44  apratt
* Removed 32K limit on serial input/output buffers.  Limit
* is now 64K (actually 64K-1 for AUX, MIDI and 64K-4 for KB).
* 
* Revision 1.12  88/07/25  18:21:00  apratt
* Got rid of the damn '.w' after 8 in coldboot code.  Gremlins.
* 
* Revision 1.11  88/07/21  12:17:34  apratt
* Fixed fatfinger in reboot code: adding wrong offset to KBCL
* (was adding 16 bits, but 24 bits is right) meant you could
* never reboot.
* 
* Revision 1.10  88/06/28  16:35:29  apratt
* Inexplicably, no revision actually had the rsconf(-2) code in it.
* Now it's there.
* 
* Revision 1.9  88/05/12  11:33:07  apratt
* Fixed reboot sequences to ignore caps-lock state.
* 
* Revision 1.8  88/05/05  13:42:55  apratt
* Added ctl-alt-rshft-delete cold boot code.
* 
* Revision 1.7  88/04/20  15:05:32  apratt
* Changed the comments around Rsconf; no code changes.
* 
* Revision 1.6  88/04/12  18:22:34  apratt
* Added baudrate variable in BSS (just forgot this...)
* 
* Revision 1.5  88/04/08  17:41:07  apratt
* Added baud-rate interrogation code: Rsconf(-2) will return old baud
* rate index (0-15).
* 
* Also changed key repeat code so it doesn't stop repeating when you
* hit a new key: the new key restarts the cdelay1/cdelay2 cycle, and
* doesn't stop until the repeating key comes up.
* 
* Revision 1.4  88/04/05  17:42:30  apratt
* Fixed ctl-alt-delete sensing.  Produces a warm boot.
* 
* Revision 1.3  88/02/25  17:25:33  apratt
* Added keyboard reset on CONTROL-ALT-DELETE
* 
* Revision 1.2  87/11/25  18:19:12  lozben
* Added flags for new countries: Turkey, Finland, and Norway. Also added
* new keyboard scan codes for Turkey and Norway
* 
* Revision 1.1  87/11/20  14:22:53  lozben
* Initial revision
* 
*
* =======================================================================
*
* $Revision: 1.20 $
* =======================================================================
*
* $Source: /u2/MRS/osrevisions/bios/bios.s,v $
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
* updates: 								*
*	08/06/87 Changed parts of keyboard translation table		*
*		 Warninng put tabs in front of directives.		*
* 	02/18/87 Conform to old spec where we put at tail and pull	*
*		 from the head. The tail points to the LAST char to	*
*		 enter the buffer. (rework rs232 buffer control)  RMS	*
*	02/10/87 Delay 1/100 of a sec in ikbd put char before sending   *
*		 next char. RMS						*
*	01/17/87 Moved software ikbd reset to startup.s RMS		*
*	12/18/86 Bug in binbcd repaired RMS				*
*	08/14/87 Changed some keyboard translations for swissger & fra  *
*	09/23/87 Added keyboard translation tables for TURKEY.          * 
*									*
*************************************************************************
*									*
*		general equates for the rbp system rom			*
*									*
*************************************************************************
USA		equ	0 ***DON'T  CHANGE***
UK		equ	1 ***DON'T  CHANGE***
GERMANY		equ	2 ***DON'T  CHANGE***
FRANCE		equ	3 ***DON'T  CHANGE***
SPAIN		equ	4 ***DON'T  CHANGE***
ITALY		equ	6 ***DON'T  CHANGE***
SWEDEN		equ	5 ***DON'T  CHANGE***
SWISSFRA	equ	7 ***DON'T  CHANGE*** French text swiss/fra keyboard
SWISSGER	equ	8 ***DON'T  CHANGE*** german text swis/ger keyboard
TURKEY		equ     9 ***DON'T  CHANGE***
FINLAND		equ     5 ***DON'T  CHANGE*** same as swedish keyboard
NORWAY		equ    11 ***DON'T  CHANGE***
DENMARK		equ    12

COUNTRY	equ	USA	;set country of origin



*	Revision B Upgrades:
*******************************************************************************
*		Combined various sources into single large BIOS.S file.
*  dependency and this one does.
*		RS-232 handshake and flow-control corrected. Entire RS-232
*		I/O interrupt-handler re-written as original was unredeemable.
*
*
*			%cccccp

.if country == denmark
osconf		equ	%11001
.endif
*+ (lmd)
* Imports:
*
*-
	.globl	_iamanst		;nonzero when you are ST, not STe
	.globl	reseth			;used by keyboard-reset routine (AKP)
	.globl	_hz_200			;timer c raw tick

.if TT
	.globl	ttwait			;wait for some time
.endif
	.globl	dowait			;wait (usable only at boot time)

*+ (dbg)
	.globl	kbshift
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
*	d6 - general purpose output
*	d7 - unassigned output
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
*	Baud rate shadow variable -- returned by Rsconf(-2)
*
baudrate	ds.w	1

*
*************************************************************************

ribuffer	ds.b	rbufsize	;rs-232 input buffer
robuffer	ds.b	rbufsize	;rs-232 output buffer
*
*	MFP RS-232 Buffers and I/O Buffer Record
*
ribuffer:	ds.b	rbufsize	;rs-232 input buffer
ribufptr	ds.l	1		* Input Buffer Record
ribufsiz	ds.w	1
ribufhead	ds.w	1
ribuftail	ds.w	1
ribuflow	ds.w	1
ribufhigh	ds.w	1
ribufsiz:	ds.w	1
ribufhead:	ds.w	1
ribuftail:	ds.w	1
ribuflow:	ds.w	1
robufptr	ds.l	1		* Output Buffer Record
robufsiz	ds.w	1
robufhead	ds.w	1
robuftail	ds.w	1
robuflow	ds.w	1
robufhigh	ds.w	1
robufsiz:	ds.w	1
rsrbyte		ds.b	1		* Other Associated Variables
tsrbyte		ds.b	1
rirxoff		ds.b	1
ritxoff		ds.b	1
rirsmode	ds.b	1		* Bit 0 = Flow Control (0=Disabled)
*					* Bit 1 = Handshake (0=Disabled)
risendnow	ds.b	1
ritxoff:	ds.b	1
risendnow:	ds.b	1		* flag/char to send NOW
auxbrate:	ds.b	1		* saved brate value for Rsconf(-2)
auxmask:	ds.b	1		* unused
kibufptr	ds.l	1
kibufsiz	ds.w	1
kibufhead	ds.w	1
kibuftail	ds.w	1
kibuflow	ds.w	1
kibufhigh	ds.w	1
kibufsiz:	ds.w	1
kibufhead:	ds.w	1
kibuffer	ds.b	kinsize		;keyboard input buffer
kibuflow:	ds.w	1
kibufhigh:	ds.w	1
kbufrec		equ	kibufptr

mibufptr	ds.l	1
mibufsiz	ds.w	1
mibufhead	ds.w	1
mibuftail	ds.w	1
mibuflow	ds.w	1
mibufhigh	ds.w	1
mibufsiz:	ds.w	1
mibufhead:	ds.w	1
mibuffer	ds.b	minsize		;midi input buffer
mibuflow:	ds.w	1
mibufhigh:	ds.w	1
mbufrec		equ	mibufptr

mibuffer:	ds.b	minsize		;midi input buffer


*	Acia error handler vectors -- init'ed to point to 'rte' unless
*
midivec		ds.l	1	;midi interrupt handler vector
vkbderr		ds.l	1	;keyboard error handler address
vmiderr		ds.l	1	;midi error handler address
statintvec	ds.l	1	;general ikbd status record interrupt vector
msintvec	ds.l	1	;mouse interrupt vector
clkintvec	ds.l	1	;ikbd real-time clock interrupt vector
joyintvec	ds.l	1	;general joystick interrupt vector
midisys		ds.l	1	;midi system interrupt handler
ikbdsys		ds.l	1	;ikbd system interrupt handler
kstate		ds.b	1	;present state of ikbd reception routine
kindex		ds.b	1	;index used to count down bytes left to
joyintvec:	ds.l	1	;general joystick interrupt vector

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
statrec		ds.b	statdex
amrec		ds.b	amdex
mousebuf	ds.b	rmdex
clkrec		ds.b	clkdex
joyrec		ds.b	joyadex
statrec:	ds.b	statdex
datetime	ds.l	1	;jdos variable
newtime		ds.l	1	;jdos variable
oclkrec		ds.b	clkdex	;used to assemble and send a new t.o.d. record
joyrec:		ds.b	joyadex

kmbuf		ds.b	3	;key-emulating mouse buffer
newtime:	ds.l	1	;jdos variable
oclkrec:	ds.b	clkdex	;used to assemble and send a new t.o.d. record
*				;to the ikbd

kmbuf:		ds.b	3	;key-emulating mouse buffer

* bit assignments in kbshift

KBRSH	EQU	0		* right shift
KBLSH	EQU	1		* left shift
KBCTL	EQU	2		* control key
kbshift		ds.b	1
KBCL	EQU	4		* caps lock
KBMRB	EQU	5		* right mouse button (clr/home)
KBMLB	EQU	6		* left mouse button (insert)
skeytran	ds.l	1	;contains address for unshifted key translation
skeyshif	ds.l	1	;contains address for shifted key translation
skeycl		ds.l	1	;contains address for caps-lock key translation
initsize	equ	kbshift-kstate-1	;area to be inited to zero!

skeytran:	ds.l	1	;contains address for unshifted key translation
transbuf	ds.b	17	;temporary string buffer for mouse init's
skeycl:		ds.l	1	;contains address for caps-lock key translation

*	mouse init transfer string buffer

transbuf:	ds.b	17	;temporary string buffer for mouse init's
keyrep		ds.b	1
kdelay1		ds.b	1	;must start on word boundary
kdelay2		ds.b	1
cdelay1		ds.b	1	;must start on word boundary
cdelay2		ds.b	1
keyrep:		ds.b	1
kdelay1:	ds.b	1	;must start on word boundary
kdelay2:	ds.b	1
cdelay1:	ds.b	1	;must start on word boundary
cdelay2:	ds.b	1
tdelay1		equ	15	;delay before key repeat engages
prt_to		ds.l	1
*				;key repeat is activated
tc_rot		ds.w	1	;divisor byte for timer c interrupt
*	parallel timeout counter

prt_to:		ds.l	1

cursnd		ds.l	1
timer		ds.b	1
auxd		ds.b	1
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
pconfig		ds.w	1
*
*	note all underscored settings are the default and are represented
*	by their corresponding bit set to "0"

pconfig:	ds.w	1

*	Note: Strictly FYI, as CONTERM has moved to STARTUP.S
*	console and terminal flag bits
*	bit 0 - keyclick enabled
*	bit 1 - repeat key function enabled
newtod	ds.b	1	;handshaking flag for get time of day function
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
	lea	$0,a5		;address pointer to address base
	lea	clkrec(a5),a0
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
	move.l	d2,datetime(a5)
	move.b	#$0,newtod(a5)	;clear handshaking flag
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
	move.b	#$-1,newtod(a5)	;set handshaking flag

	.globl	gettime
	move.l	_hz_200(a5),a0	; use an A register for
gettime:
	move.b	#-1,newtod.w	;set handshaking flag
gtod1:	cmp.l	_hz_200(a5),a0	; has 1 sec elapsed?
	bsr	ikbdput
	tst.b	newtod(a5)	;see if the new time of day is in yet...
	add.w	#200,a0		; cheap sign-extension (1 sec timeout)
	move.l	datetime(a5),d0
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
	move.l	4(sp),newtime(a5)

	.globl	settime

settime:
	move.l	4(sp),newtime.w

*************************************************************************
*									*
*	convert jdos format to ikbd real-time clock format		*
*									*
*************************************************************************
	move.l	newtime(a5),d2	;get time to convert
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
	moveq	#$-1,d0		;pre-set to true
	move.b	comstat+midi(a5),d2	;grab midi status
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

	lea	midi(a5),a1	;point to midi register base

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
	lea	mbufrec(a5),a0	;point to midi i/o bufrec
	lea	midi(a5),a1	;point to midi register base
	moveq	#$-1,d0		;set result to true

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
mwi1	move.l	bufptr(a0),a1	;get base address of buffer
	addq.w	#1,d1		;i=h+1
	bcs.b	mwi1		;no...
	moveq	#$0,d1		;wrap pointer
mwi2	move	(sp)+,sr
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
	btst	#4,pconfig(a5)	;check for I/O redirection of users output
_lstout:
*
*	redirection code added 9/11/85 to take advantage of redirection bit
	move.l	_hz_200(a5),d2	; d2 = hz_200 - prt_to
	sub.l	prt_to(a5),d2	; (compute time since last timeout)
	bne	_auxout		;bit was set, so send output to rs-232 port
*
*
	move.l	_hz_200(a5),d2	; d2 = starting time for this char
pt0	bsr.b	_lstostat	;go get parallel port status
	cmpi.l	#5*200,d2	; do "fake" timeout if we timed out within
	bcs.b	lperr		; the last five seconds

	move.l	_hz_200(a5),d3	; d3 = hz_200 - d2
pt0:	bsr	_lstostat	;go get parallel port status
	tst.w	d0		;...and check for high (busy)
	bne.b	pt1		; port is ready -- print the char

lperr	moveq	#$0,d0		; return value of 0 indicates timeout
	move.l	_hz_200(a5),prt_to(a5)	; record time of last timeout
	cmpi.l	#30*200,d3	; check for 30 second delta
	blt.b	pt0		; continue if no timeout
pt1	move.w	sr,d3		;save status register
lperr:	moveq	#$0,d0		; return value of 0 indicates timeout
	move.l	_hz_200.w,prt_to.w	; record time of last timeout
	rts

	moveq	#mixer+$80,d1	;set to write to io enable
	ori.w	#$700,sr	;protect upcoming switching of the port setting
	moveq	#mixer,d1	;get current io enable register contents
	bsr	gientry
	ori.b	#$80,d0	 	;set port b for output
	moveq	#portb+$80,d1	;write out byte to parallel port
	bsr	gientry
	move.w	d3,sr		;restore status register

	move.w	6(sp),d0	;retrieve byte to be sent and...
	move.b	#portb+$80,d1	;write out byte to parallel port ;;q
	bsr	gientry

* go to IPL 7 for duration of strobe, so vblank (etc) can't make it too long.
* added 11/2/88 AKP
	move.w	sr,-(sp)
	or.w	#$700,sr
	moveq	#$-1,d0		;set d0=-1 for good transfer status
lexit	rts
*				;timing requirements of some off brand printer
strobeoff
	move.w	(sp)+,sr
	moveq	#-1,d0		;set d0=-1 for good transfer status
lexit:	rts
strobeon
	moveq	#%11011111,d2	;set strobe on
	moveq	#%00100000,d2	;set strobe off
	bra	onbit	 	;go set it!!

strobeon:
	move.b	#%11011111,d2	;set strobe on ;;q
	bra	offbit		;set strobe now...


	.globl	_lstin
	moveq	#mixer+$80,d1	;set to write to io enable
_lstin:
	moveq	#mixer,d1	;get current io enable register contents
	bsr	gientry
lstibusy
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
	moveq	#$-1,d0		;pre-init to true (parallel port ready)
	.globl	_lstostat

_lstostat:
lst1	rts
	moveq	#-1,d0		;pre-init to true (parallel port ready)
	btst.b	#$0,gpip(a0)
	beq.b	lst1
	moveq	#$0,d0		;parallel port busy
lst1:	rts



*************************************************************************
*									*
*		auxillary port input status routine			*
*									*
	lea	ribufptr,a0	* ptr to RS232 input buffer record
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
	lea	ribufptr,a0	* ptr to RS232 input buffer record
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
* aux_rxok: called by incommon when buf was rxoff'ed and drops below
* the low-water mark, but also called by rsconf when you change
* rsmode.  a0=iorec, a2=mfp (used by kickstart).
	bsr	rtson		* THEN Assert RTS (Ready to Receive)
	bra	xinxit
	clr.b	rxoff(a0)
	bsr	kickstart	* ELSE Send "xon"
xinxit:
	move.w	(sp)+,d0
	rts
	bne	xinxon		* IF (RTS/CTS Flow Control)
	bra	rtson		* THEN Assert RTS (bra=bsr/rts)
	
xinxon:	move.b	#xon,sendnow(a0)
	bra	kickstart	* (bra=bsr/rts)

*************************************************************************
*									*
*		auxillary port output status routine			*
*									*
	lea	robufptr,a0	* ptr to RS232 output buffer record
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
	lea	robufptr,a0	* ptr to RS232 output buffer record
	.globl	_auxout
	lea	robufptr.w,a0	* ptr to RS232 output buffer record
	bsr	putbyte
	lea	ribufptr.w,a0	* set up regs for kickstart
	lea	mfp,a2

*
*	NOTE: Fall Thru to KICKSTART for Exit!!
*

*		nothing
*	KICKSTART   Start Transmission as Needed
*
*	Given:
*		a0 = iorec
*		a2 = mfp base address
*		d0, d1, a0, a1 and a2 destroyed
*	Returns:
*		Transmitter Enabled
*
*	Register Usage:
*		d0, d1 destroyed
	lea	mfp,a2
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
	moveq	#$-1,d0		;pre-set to true

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
*
	move.w	#$3b6,d2	; delay aprox. 1/200 of a sec
iklp:
	jsr	ikbdret
	dbra	d2,iklp

	dbra	d0,ikput2	; yes - load a new value and loop
ikbdret:
	rts			;done for now
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
*	long	ptr							*
*									*
* This code calls a hidden entry point in ikbdwc above, called		*
* ikbdput.  Ikbdput may not touch registers a2 or d3.  (Sigh - AKP)	*
*									*
	moveq	#$0,d3
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
	lea	kbufrec(a5),a0	;point to ikbd buffer record
	moveq	#$-1,d0		;set result to true
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
cwi1	move.l	bufptr(a0),a1	;get base address of buffer
	addq.w	#4,d1		;i=h+4
	cmp.w	bufsize(a0),d1	;? i>= current bufsiz?
	bcs.b	cwi1		;no...
cwi2	move	(sp)+,sr
cwi1:	move.l	bufptr(a0),a1	;get base address of buffer
	and.l	#$0000ffff,d1	;d1.l = (unsigned long)d1.w
	move.l	0(a1,d1.l),d0	;get character
	move.w	d1,bufhead(a0)	;store new head pointer to buffer record
cwi2:	move	(sp)+,sr
	rts


	.globl	conoutst
	.globl	ringbel

ringbel:
	btst.b	#$2,conterm(a5)
	beq.b	rgbel
	move.l	#bellsnd,cursnd(a5)
	move.b	#0,timer(a5)
rgbel:
	rts


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
* This must be initialized with a value other than one, so noblank
* and noblank1 don't wait forever.  God help you if you program the
* timer to a one, then call something which calls noblank!
	move.w	#$1111,tc_rot(a5)	;setup bitstream for /4 on timer c interrupt
	move.w	#20,_timr_ms(a5)	;set timer calibration value

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
	move.w	#$1,baudrate	;9600 is baud rate number 1 - shadow this.
	moveq	#dtimer,d0	;select the d timer
	moveq	#c9600,d1	;init for /4 for 9600 baud
*
	move.l	#$00880101,d0
*	The TT's two SCC channels are initialized here, too.

	tst.b	_iamanst		; if you're an ST don't do this
	bne	noscc
	bsr	_setupscc		; initialize the SCC controller
	bsr	rtson	

*	initialize the default rs-232 control line settings

	lea	ribufptr(a5),a0
	bsr	rtson

	bsr	lbmove		;do block move and return

	lea	ttrs232init,a1
	moveq	#rssize,d0
	lea	mbufrec(a5),a0
.endif

*	initialize the midi buffer record structure

	move.l	#aciaexit,d0	;init to ikbd and midi error handler address
	move.l	d0,vkbderr(a5)	;init keyboard error handler address
	move.l	d0,vmiderr(a5)	;init midi error handler address
	move.l	#sysmidi,midivec(a5)	;point to user midi interrupt vector
	move.l	#vecmidi,midisys(a5)	;point to system midi interrupt vector
	move.l	#vecikbd,ikbdsys(a5)	;point to system ikbd interrupt vector
	move.l	d0,vmiderr.w	;init midi error handler address
	move.l	#sysmidi,midivec.w	;point to user midi interrupt vector
	move.l	#vecmidi,midisys.w	;point to system midi interrupt vector
	move.l	#vecikbd,ikbdsys.w	;point to system ikbd interrupt vector
	move.l	#itsakey,ikbdkey.w	;point to "itsakey"

*	init the midi acia next

	move.b	#rsetacia,comstat+midi	;init the acia via master reset

* init the acia to divide by 16x clock, 8 bit data, 1 stop bit, no parity,
* rts low, transmitting interrupt disabled, receiving interrupt enabled
	move.b	#%00000111,conterm(a5)	;enable keyclick,repeat key,bell functions, disable the KBSHIFT concatenation.
	move.b	#div16+protocol+rtsld+intron,comstat+midi
	move.l	#jdostime,clkintvec(a5)
*	initialize the keyboard acia interrupt vector exception address
	move.l	d0,statintvec(a5)
	move.l	d0,msintvec(a5)	;init user mouse interrupt adr to rts
	move.l	d0,joyintvec(a5)
	move.l	d0,joyintvec.w
*  Sound routine initialization - uses the pre-init'ed d0.l=0000 !!
* init the Bconmap system
	bsr	mapinit

	move.l	d0,cursnd(a5)		;clear sound ptr
	move.b	d0,timer(a5)		;clear delay timer
	move.b	d0,auxd(a5)		;clear temp value
	move.l	d0,prt_to(a5)		;init printer timout to 0
	moveq	#$0,d0			;init 'd0' to clear sound variables
	move.l	d0,cursnd.w		;clear sound ptr
	move.b	#tdelay1,cdelay1(a5)	;init system default key repeat values
	move.b	#tdelay2,cdelay2(a5)
	move.l	d0,prt_to.w		;init printer timout to 0

	bsr	strobeoff		;init strobe to off (line high!)
	move.b	#tdelay1,cdelay1.w	;init system default key repeat values
	move.b	#tdelay2,cdelay2.w
	lea	kbufrec(a5),a0
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
st1     move.l  d1,d2
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
genrts	rts
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
	dc.b	0		;rsrbyte
	dc.w	0		;obuftail
	dc.w	rbufsize/2	;obuflow
	dc.w	rbufsize*3/4	;obufhigh

	dc.b	0		* sendnow
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
iert	dc.b	$6,$6,$8,$8
iprt	dc.b	$A,$A,$C,$C
isrt	dc.b	$E,$E,$10,$10
imrt	dc.b	$12,$12,$14,$14

iermt	dc.b	$df,$fe,$df,$ef
iprt:	dc.b	$A,$A,$C,$C
isrt:	dc.b	$E,$E,$10,$10
imrt:	dc.b	$12,$12,$14,$14

tcrtab	dc.b	$18,$1a,$1c,$1c
tcrmsk	dc.b	$0,$0,$8f,$f8
tdrtab	dc.b	$1e,$20,$22,$24
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
mfpint
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
	lea	ipra(a0),a1	;yet again...
	bsr.b	bselect
	bclr	d1,(a1)		;and clear the bit...
	bclr	d1,(a1)		;and clear the bit...
	lea	iera(a0),a1	;set a1 for another mskoff call
	bclr	d1,(a1)
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
	lea	ribufptr,a0
*		enter the buffer.					*
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
rcvxof	move.b	#xoff,sendnow(a0)	* ELSE Send "Xoff"
	btst.b	#0,rsmode(a0)
	bne	rcvxof		* IF (RTS/CTS Flow Control)
	bsr	rtsoff		* THEN Withdraw RTS (NOT Ready to Receive)
rcvxof:	move.b	#xoff,sendnow(a0)	* ELSE Send "Xoff"
rcvrkick:
	bclr.b	#4,isra(a2)	* Reset Interrupt
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
	lea	mfp,a2
	lea	ribufptr.w,a0	* load up queue pointer for sender
	bclr.b	#2,isra(a2)	* Reset Interrupt
txrcommon:
	bsr	sender		* Send a Byte from Output Buffer

*	bclr.b	#2,isra(a2)	* Reset Interrupt
	move.b	#%11111011,isra(a2)	; was bclr but that's wrong
	movem.l	(sp)+,d0-d1/a0-a2
	rte

*************************************************************************
*									*
*		Clear-To-Send interrupt routine				*
	lea	ribufptr,a0
*									*
*************************************************************************
ctsint:
	movem.l	d0-d1/a0-a2,-(sp)
	lea	ribufptr.w,a0
	lea	mfp,a2
	btst.b	#1,rsmode(a0)
	beq	ctsxit		* IF (RTS/CTS Flow Control Enabled) THEN

	btst.b	#2,gpip(a2)
	clr.b	txoff(a0)	* THEN Re-Enable Transmission
	bset.b	#2,aer(a2)	* Falling Edge Trigger
	tst.b	tsr(a2)
	bpl	ctsxit		* IF (MFP Empty) THEN
*				* a0,a2 already set up for sender
	bsr	sender		* Kick-Start the MFP Xmitter Interrupt
ctsxit:	bclr.b	#2,isrb(a2)	* Reset Interrupt
	bclr.b	#2,aer(a2)	* Rising Edge Trigger

ctsxit:
*	bclr.b	#2,isrb(a2)	* Reset Interrupt
	move.b	#%11111011,isrb(a2)	; was bclr but that's wrong
	movem.l	(sp)+,d0-d1/a0-a2
	rte

*************************************************************************
	movem.l	d0/a0,-(sp)
	lea	mfp,a0
	bclr	#$3,isra(a0)	* Clear Interrupt
rxecommon:
	move.b	rsr(a0),rsrbyte	* Save Receiver Error Status
	move.b	udr(a0),d0	* dummy read
*	bclr	#$3,isra(a0)	* Clear Interrupt
	move.b	#%11110111,isra(a0)	; was bclr but that's wrong
	movem.l	(sp)+,d0/a0
	move.l	a0,-(sp)
	bclr	#$1,isra(a0)	* Clear Interrupt
* entry point used by tttxerror
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
*		d0, d1, a0 and a1 destroyed
*	Returns:
*		Data Sent as Needed
*
*	Register Usage:
*		d0, d1, and a1 destroyed
*
*		getbyte
	lea	ribufptr,a0
	beq	sendbuf
	clr.b	sendnow(a0)
	bra	sendwt

	move.b	sendnow(a0),d0	* IF (Xon/Xoff Requested)
	beq	sendbuf
	clr.b	sendnow(a0)	* THEN Clear Flag & Send It Now!
	bra	sendwt
sendbuf:
	lea	robufptr,a0	* ELSE Send Char From Output Buffer
	move.b	rsmode(a0),d0
	and.b	txoff(a0),d0
	bne	sendone		* IF (Flow-Control AND Xoff) THEN Skip
	
	add.w	#(robufptr-ribufptr),a0	* ELSE Send Char From Output Buffer
	move	bufhead(a0),d0
	cmp	buftail(a0),d0
	beq	sendone		* IF (Buffer NOT Empty) THEN
	bsr	getbyte		* Get Byte from Output Buffer

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
*			3 - parallel					*
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
*
* For TT, if the argument is 0 (for RS232), we read the current mapping
* from the variable mapiorec, which is maintained by Bconmap.
*
	asl.l	#2,d1		;x4=index into devtab space

iorec:
	move.w	4(sp),d1

	dc.l	ribufptr
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
* cause loss of a pending character, but only if it arrives while at	*
* IPL 7.  This is not likely, and when you're fooling with Rsconf you	*
* the function pointer in maprsconf.  For the STMFP port (default),
* is called rsconf.
*
* RETURNS: see above for rsconf return values
	bne.s	auxnorm		;no: act normally
	move.w	baudrate,d0
rscommon:
	moveq.l	#0,d0		;pre-clear hi word of return value
	cmp.w	#-2,4(sp)	;check for special case: rsconf(-2)
	bne	auxnorm		;no: act normally
	move.b	brate(a0),d0
	lea	ribufptr,a0
	lea	mfp,a1

	rts

auxnorm:
	ori.w	#$700,sr	;no interrupts for now (restored at rte)
	movep.l	ucr(a1),d7
*
*	first, we grab the old ucr,rsr,tsr,scr contents
*

* guaranteed no-op, though.
*
	cmp.w	#$-1,d0
	beq.b	auxc1

	move.b	d0,rsmode(a0)
	beq	auxc0
	and.b	#$0fd,d0
	beq	auxc0		* IF (Anything but Pure RTS/CTS)
	move.b	#1,d0

auxc0:	move.b	d0,rsmode(a0)	* THEN Must be XON/XOFF Protocol
	bhi	auxc1		; if d0 unsigned greater than 3 then no-op.
	bsr	aux_rxok
auxc0b:
	move.w	(sp)+,d0	; get new mode off stack (as word!)
	move.b	d0,rsmode(a0)	; write it (as byte!)

*	set timer baud rate

auxc1:
	moveq	#$0,d0		;pre-init to zero
	move.b	d0,rsr(a1)	;disable the receiver
	move.b	d0,tsr(a1)	;disable the transmitter
*
*	next, we disable the receiver and transmitter enable bits
	move.w	d1,baudrate	;shadow baud rate value now
	lea	baudctrl,a2	;point to baudrate control register settings
	move.b	0(a2,d1.w),d0	;get control mask
	lea	bauddata,a2	;point to baudrate data register settings
	move.b	0(a2,d1.w),d2	;get data reg value
	move.l	d0,d1		;re-assign for "setimer" routine protocol
	moveq	#dtimer,d0		;point to timer D
	bsr	setimer		;set timer D to new baud rate

	and.b	#%01110000,tcdcr(a2)	; stop the timer
	move.b	d2,tddr(a2)
	moveq	#$1,d0		;pre-init to one
	move.b	d0,rsr(a1)	;enable the receiver
	move.b	d0,tsr(a1)	;enable the transmitter
*
*	finally we re-enable the receiver and transmitter enable bits
*
auxc2	tst.w	$8(sp)		;if -1 then don't change
	bset.b	#0,tsr(a2)	;enable the transmitter
	move.b	$9(sp),ucr(a1)
auxc3	tst.w	$a(sp)		;if -1 then don't change

	move.b	$b(sp),rsr(a1)
auxc4	tst.w	$c(sp)		;if -1 then don't change
	move.b	$9(sp),ucr(a2)
	move.b	$d(sp),tsr(a1)
auxc5	tst.w	$e(sp)		;if -1 then don't change
	move.b	$b(sp),rsr(a2)
	move.b	$f(sp),scr(a1)
auxc6
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
* used because it's disabled in the (TT-specific) Rsconf() call.  That
*	revised 05/01/86	Mike Schmal
*	Worked in spanish key board
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
	movem.l d0-d3/a0-a3/a5,-(sp)	;save all registers (8/16/85 dbg)
	clr.l	a5

	movea.l	midisys(a5),a2	;load in system midi handler

	movea.l	ikbdsys(a5),a2	;load in system ikbd handler
	movem.l d0-d3/a0-a3,-(sp)	;save all registers (8/16/85 dbg)
	btst.b	#$4,gpip+mfp(a5) ;check for pending interrupt occurance
	movea.l	midisys.w,a2	;load in system midi handler
	bclr.b	#$6,isrb+mfp(a5) ;clear in-service bit
	movem.l (sp)+,d0-d3/a0-a3/a5	;restore all registers
	btst.b	#$4,gpip+mfp.w ;check for pending interrupt occurance
	beq.b	keymidi		;repeat this interrupt processing
*	bclr.b	#$6,isrb+mfp.w ;clear in-service bit
	lea	mbufrec(a5),a0	;point to midi buffer record
	lea	midi(a5),a1	;point to midi register base
	movea.l vmiderr(a5),a2	;load in the jump vector

vecmidi:
	lea	mbufrec.w,a0	;point to midi buffer record
	lea	kbufrec(a5),a0	;point to ikbd buffer record
	movea.l vmiderr.w,a2	;load in the jump vector
	movea.l vkbderr(a5),a2	;load in the jump vector

vecikbd:
	lea	kbufrec.w,a0	;point to ikbd buffer record
	lea	keyboard,a1	;point to keyboard register base
	movea.l vkbderr.w,a2	;load in the jump vector
	bra	astatus		;goto general acia status check routine
	btst.l	#0,d2		;see if receiver buffer is full
	beq.b	mk1		;nope...it's empty
	move.b	comstat(a1),d2	;grab device status
	bsr.b	arcvrint	;yes...get byte
	movem.l	(sp)+,d2/a0-a2
mk1:	andi.b	#%00100000,d2	;mask off bits already tested
	beq.b	aciaexit	;see if any other status bits are on...
	move.b	iodata(a1),d0	;grab data byte from acia data register
	jmp	(a2)		;yes so branch to pre-inited error subroutine
aciaexit:
	rts
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

	tst.b	kstate(a5)
	move.b	iodata(a1),d0	;grab data byte from acia data register
	cmpa.l	#kbufrec,a0
	bne.b	ML3
	bcs	itsakey		;branch early if it is not a ikbd header!

	move.l	ikbdkey.w,-(sp)	;jmp without using any regs
	rts			;(because I don't know what's safe)
	move.b	0(a3,d0),kstate(a5)	;set ikbd state
kbheader:
	move.b	0(a3,d0),kindex(a5)	;set ikbd device index counter
	andi.l	#$ff,d0		;clear high 3 bytes for indexing
	lea	ikbdev,a3	;point to ikbd device state codes
	move.b	0(a3,d0),kstate.w	;set ikbd state
	lea	ikbdlen,a3	;point to ikbd device buffer length table
	move.b	0(a3,d0),kindex.w	;set ikbd device index counter
	move.b	d0,mousebuf(a5)
	cmpi.b	#$f8,d0
	blt.b	ML8
	cmpi.b	#$fb,d0
	bgt.b	ML8
	move.b	d0,mousebuf.w
	rts

*
*	added the compare below to correct for incorrect indexing into the
	move.b	d0,joyrec(a5)
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
	cmpi.b	#joy0,kstate(a5)
*****

	.even
	move.b	kstate(a5),d2	;load to generate longword offset
	subq.b	#$1,d2		;kstate(a5)=1 to 5/ table index is 0 to 4
	bcc	ML35		;a joystick 0/1 record byte, not both!
	add.b	kstate(a5),d2	; +1
	subq.b	#$1,d2		;kstate(a5)=1 to 5/ table index is 0 to 4
	move.b	kstate.w,d2	;load to generate longword offset
	subq.b	#$1,d2		;kstate.w=1 to 5/ table index is 0 to 4
	asl	d2		; x2
	add.b	kstate.w,d2	; +1
	subq.b	#$1,d2		;kstate.w=1 to 5/ table index is 0 to 4
	asl	#2,d2		; x4

	movea.l	0(a2,d2),a0	;load in subsystem's record pointer
	movea.l	4(a2,d2),a1	;load in subsystem's index base+record pointer
	move.b	kindex(a5),d2
*				;contains the pointer to the subsystem's
*				;interrupt routine...
	sub.b	#1,kindex(a5)
	tst.b	kindex(a5)
	move.b	kindex.w,d2
ikserve	move.l	a0,-(sp)	;stuff buffer pointer to stack
	sub.b	#1,kindex.w
	tst.b	kindex.w
	clr.b	kstate(a5)	;reset ikbd state
ML1	rts
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
ML35
*
	add.b	kstate(a5),d1	;kstate(a5) reflects joy0 or joy1 state
*

ML35:
	movea.l	joyintvec(a5),a2	;get user's joystick interrupt routine adr
	lea	joyrec(a5),a0	;send along address of joystick data
	subi.b	#joy0,d1
	move.l	d1,a2		;create index to joyrec table for record byte
	move.b	d0,(a2)
	move.b	kbshift(a5),d1	;load in kbshift(a5) for manipulation...
	lea	joyrec.w,a0	;send along address of joystick data
	bra.b	ikserve

itsakey:
	bra.b	ari10
ari2	cmpi.b	#$AA,d0
	cmpi.b	#$2A,d0		;left shift?
	bne.b	ari2
	bra.b	ari10
ari3	cmpi.b	#$36,d0		;right shift
ari2:	cmpi.b	#$AA,d0
	bne.b	ari3
	bclr	#KBLSH,d1
ari4	cmpi.b	#$B6,d0
ari3:	cmpi.b	#$36,d0		;right shift
	bne.b	ari4
	bset	#KBRSH,d1
ari5	cmpi.b	#$1D,d0		;CTRL
ari4:	cmpi.b	#$B6,d0
	bne.b	ari5
	bclr	#KBRSH,d1
ari6	cmpi.b	#$9D,d0
ari5:	cmpi.b	#$1D,d0		;CTRL
	bne.b	ari6
	bset	#KBCTL,d1
ari7	cmpi.b	#$38,d0		;ALT
ari6:	cmpi.b	#$9D,d0
	bne.b	ari7
	bclr	#KBCTL,d1
ari8	cmpi.b	#$B8,d0
ari7:	cmpi.b	#$38,d0		;ALT
	bset	#KBALT,d1
	bra.b	ari10
ari9	cmpi.b	#$3A,d0		;CAPS LOCK
	move.b	altkp+1,d0	; get the accumulated value,
	btst.b	#0,conterm(a5)
	bra	conin25		; and put it on the keyboard queue.
	move.l	#keyclk,cursnd(a5)
	move.b	#0,timer(a5)
ari9a	bchg	#KBCL,d1	;toggle CAPS LOCK state
ari10	move.b	d1,kbshift(a5)	;restore new kbshift(a5) value
	jsr	(a0)
ari11	btst.l	#7,d0		;make or break?

ari9a:	bchg	#KBCL,d1	;toggle CAPS LOCK state
ari10:	move.b	d1,kbshift.w	;restore new kbshift.w value
	rts			;ignore CAPS LOCK break
ari11:	btst.l	#7,d0		;make or break?
	bne.b	ari12		;break

	move.b	d0,keyrep(a5)	;save for repeat purpose
	move.b	cdelay1,kdelay1(a5)
	move.b	cdelay2,kdelay2(a5)
* (This is a change from 11/20 and 4/22: they didn't repeat that second key.)

ari12	move.b	d0,d1		; d1 = make code corresponding to d0
	move.b	cdelay1,kdelay1.w
	cmp.b	keyrep(a5),d1	; is this break code for the repeating key?
	bra.b	ari16

ari12:	move.b	d0,d1		; d1 = make code corresponding to d0
	move.b	d1,keyrep(a5)
	move.b	d1,kdelay1(a5)
	move.b	d1,kdelay2(a5)

ari18	cmpi.b	#$c7,d0		;is it a "home" break-code?
	move.b	d1,keyrep.w
	move.b	d1,kdelay1.w
	move.b	d1,kdelay2.w
ari18a	btst.b	#KBALT,kbshift(a5)	;early "ALT" test to prevent double "nulls"
ari18:	cmpi.b	#$c7,d0		;is it a "home" break-code?
	beq.b	ari18a		;yes...allow it to pass
ari16	btst.b	#0,conterm(a5)
	bne	ari14		;no...regular break junk...
	move.l	#keyclk,cursnd(a5)
	move.b	#0,timer(a5)
ari18a:	btst.b	#KBALT,kbshift.w ;early "ALT" test to prevent double "nulls"
ari16a	move.l	a0,-(sp)	;store kbufrec pointer
	move.l	kcl_hook.w,a1
	jsr	(a1)
	movem.l	(sp)+,d0-d2/a0-a2

	movea.l skeytran(a5),a0

	btst.b	#KBCL,kbshift(a5)
	move.b	d0,d1
	movea.l skeycl(a5),a0
conin21 btst.b	#KBRSH,kbshift(a5)
	btst.b	#KBCL,kbshift.w
	btst.b	#KBLSH,kbshift(a5)
	movea.l skeycl.w,a0
conin22	cmpi.b	#$3b,d0		;see if a possible function key
	bne.b	conin22
	btst.b	#KBLSH,kbshift.w
	beq.b	conin23
conin22:
	cmpi.b	#$3b,d0		;see if a possible function key
	bcs.b	conin22a	;unsigned less than lowest function scancode
conin22a
	movea.l skeyshif(a5),a0
conin23	move.b	(a0,d0.w),d0
	btst.b	#KBCTL,kbshift(a5)	;is the control key down?
conin22a:
	movea.l skeyshif.w,a0
conin23:
	move.b	(a0,d0.w),d0
	btst.b	#KBCTL,kbshift.w	;is the control key down?
conin23a
	cmpi.b	#cr,d0		;is it a carriage return?
	bne.b	conin23a
	moveq	#lf,d0		;change to a linefeed according to GSX spec...
	beq.b	conin24
conin23b
	cmpi.b	#$47,d1		;convert CONTROL-home to gsx standard
	bne.b	conin23b	;by adding #$30...
	addi.w	#$30,d1
	bra	conin25
conin23b:
conin23c
	bne.b	conin23c
	moveq	#$73,d1		;change according to gsx spec
	moveq	#$0,d0
	bra	conin25
conin23c:
conin24
	bne.b	conin24
	moveq	#$74,d1		;change according to gsx spec
	moveq	#$0,d0
	bra	conin25
conin24b
	cmpi.b	#$32,d0		;convert CONTROL-2 to gsx standard
	bne.b	conin24b
	moveq	#$00,d0		;change according to gsx spec
	bra	conin25
conin24c
	cmpi.b	#$36,d0		;convert CONTROL-6 to gsx standard
	bne.b	conin24c
	moveq	#$1e,d0		;change according to gsx spec
	bra	conin25
conin24c:
	cmpi.b	#$2d,d0		;convert CONTROL-'-' to gsx standard
	bne.b	conin24a
	moveq	#$1f,d0		;change according to gsx spec
conin24a
	btst.b	#KBALT,kbshift(a5)	;is the alt key down?
* DON'T control-ize other keys just yet... wait until after the int'l munge.
*
	ifeq	COUNTRY-GERMANY
* no, it wasn't ALT plus a keypad number key

notaltkp:

	move.b	kbshift(a5),d2	;grab current setting

	cmpi.b	#$1a,d1		;is it a ALT-umlaut?
	bne.b	altger1		;no...
	move.b	#$40,d0		;put in '@', then check the shift keys
altger1	cmpi.b	#$27,d1		;is it a ALT-
	beq	conin25a		;process it as unshifted
	move.b	#$5c,d0		;put in '\', instead...it's a alt-shift umlaut!
	move.b	kbshift(a5),d2	;grab current setting
altger1:
	cmpi.b	#$27,d1		;is it a ALT-
	bne.b	altger2		;no...
	move.b	#$5b,d0		;put in '[', then check the shift keys
altger2	cmpi.b	#$28,d1		;is it a ALT-
	beq	conin25a		;process it as unshifted
	move.b	#$7b,d0		;put in '{', instead...it's a alt-shift umlaut!
	move.b	kbshift(a5),d2	;grab current setting
altger2:
	cmpi.b	#$28,d1		;is it a ALT-
	bne.b	outside		;no...
	move.b	#$5d,d0		;put in ']', then check the shift keys
	move.b	kbshift.w,d2	;grab current setting
	endc
	beq	conin25a		;process it as unshifted
	ifeq	COUNTRY-SPAIN
	bra	conin25a		;process it

.endif

	move.b	kbshift(a5),d2	;grab current setting

	cmpi.b	#$1a,d1		;is it a ALT-umlaut?
	bne.b	altspa1		;no...
	move.b	#$5b,d0		;put in '[', then check the shift keys
	move.b	kbshift.w,d2	;grab current setting
	andi.b	#$3,d2		;KBRSH+KBLSH bits
	beq	conin25a		;process it as unshifted
	move.b	#$7b,d0		;put in '{', instead...it's a alt-shift '
	move.b	kbshift(a5),d2	;grab current setting
altspa1:
	cmpi.b	#$1b,d1		;is it a ALT-`
	bne.b	altspa2		;no...
	move.b	#$5d,d0		;put in ']', then check the shift keys
	move.b	kbshift.w,d2	;grab current setting
	andi.b	#$3,d2		;KBRSH+KBLSH bits
	beq	conin25a		;process it as unshifted
	move.b	#$7d,d0		;put in '}', instead...it's a alt-shift `
	move.b	kbshift(a5),d2	;grab current setting
altspa2:
	cmpi.b	#$2b,d1		;is it a ALT-\
	bne.b	altspa3		;no...
	move.b	#$23,d0		;put in '#', then check the shift keys
	move.b	kbshift.w,d2	;grab current setting
	andi.b	#$3,d2		;KBRSH+KBLSH bits
	beq	conin25a		;process it as unshifted
	move.b	#$40,d0		;put in '@', instead...it's a alt-shift \
	move.b	kbshift(a5),d2	;grab current setting
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
	endc
	bne.b	outside		;no...
	ifeq	COUNTRY-FRANCE
	bra	conin25a		;process it

.endif

	move.b	kbshift(a5),d2	;grab current setting

	cmpi.b	#$1a,d1		;is it a ALT-^?
	bne.b	altfr1		;no...
	move.b	#$5b,d0		;put in '[', then check the shift keys
altfr1	cmpi.b	#$1b,d1		;is it a ALT-$?
	andi.b	#$3,d2		;KBRSH+KBLSH bits
	beq	conin25a		;process it as unshifted
	move.b	kbshift(a5),d2	;grab current setting
	bra	conin25a		;process it
altfr1:	cmpi.b	#$1b,d1		;is it a ALT-$?
	bne.b	altfr2		;no...
	move.b	#$5d,d0		;put in ']', then check the shift keys
altfr2	cmpi.b	#$28,d1		;is it a ALT-
	andi.b	#$3,d2		;KBRSH+KBLSH bits
	beq	conin25a		;process it as unshifted
	move.b	kbshift(a5),d2	;grab current setting
	bra	conin25a		;process it
altfr2:	cmpi.b	#$28,d1		;is it a ALT-
	bne.b	altfr3		;no...
	move.b	#$5c,d0		;put in '\', then check the shift keys
altfr3	cmpi.b	#$2b,d1		;is it a ALT-#?
	andi.b	#$3,d2		;KBRSH+KBLSH bits
	beq	conin25a		;process it as unshifted
	move.b	kbshift(a5),d2	;grab current setting
	bra	conin25a		;process it
altfr3:	cmpi.b	#$2b,d1		;is it a ALT-#?
	bne.b	outside		;no...
	move.b	#$40,d0		;put in '@', then check the shift keys
	move.b	kbshift.w,d2	;grab current setting
	endc
	beq	conin25a		;process it as unshifted
	move.b	#$7e,d0		;put in '|', instead...it's a alt-shift #
	ifeq	COUNTRY-SWEDEN

.endif


	move.b	kbshift(a5),d2	;grab current setting

	cmpi.b	#$1a,d1		;is it a ALT-^?
	bne.b	altsw1		;no...
	move.b	#$5b,d0		;put in '[', then check the shift keys
altsw1	cmpi.b	#$1b,d1		;is it a ALT-$?
	andi.b	#$3,d2		;KBRSH+KBLSH bits
	beq	conin25a		;process it as unshifted
	move.b	kbshift(a5),d2	;grab current setting
	bra	conin25a		;process it
altsw1:	cmpi.b	#$1b,d1		;is it a ALT-$?
	bne.b	altsw2		;no...
	move.b	#$5d,d0		;put in ']', then check the shift keys
altsw2	cmpi.b	#$28,d1		;is it a ALT-
	andi.b	#$3,d2		;KBRSH+KBLSH bits
	beq	conin25a		;process it as unshifted
	move.b	kbshift(a5),d2	;grab current setting
	bra	conin25a		;process it
altsw2:	cmpi.b	#$28,d1		;is it a ALT-
	bne.b	altsw3		;no...
	move.b	#$60,d0		;put in '`', then check the shift keys
altsw3	cmpi.b	#$2b,d1		;is it a ALT-#?
	andi.b	#$3,d2		;KBRSH+KBLSH bits
	beq	conin25a		;process it as unshifted
	move.b	kbshift(a5),d2	;grab current setting
	bra	conin25a		;process it
altsw3:	cmpi.b	#$2b,d1		;is it a ALT-#?
	bne.b	outside		;no...
	move.b	#$5e,d0		;put in '^', then check the shift keys
	move.b	kbshift.w,d2	;grab current setting
	endc
	beq	conin25a		;process it as unshifted
	move.b	#$40,d0		;put in '@', instead...it's a alt-shift #
	ifeq	COUNTRY-NORWAY

.endif


	move.b	kbshift(a5),d2	;grab current setting

	cmpi.b	#$1a,d1		;is it a ALT-^?
	bne.b	altsw1		;no...
	move.b	#$5b,d0		;put in '[', then check the shift keys
altsw1	cmpi.b	#$1b,d1		;is it a ALT-$?
	andi.b	#$3,d2		;KBRSH+KBLSH bits
	beq	conin25a		;process it as unshifted
	move.b	kbshift(a5),d2	;grab current setting
	bra	conin25a		;process it
altsw1:	cmpi.b	#$1b,d1		;is it a ALT-$?
	bne.b	altsw2		;no...
	move.b	#$5d,d0		;put in ']', then check the shift keys
altsw2	cmpi.b	#$28,d1		;is it a ALT-
	andi.b	#$3,d2		;KBRSH+KBLSH bits
	beq	conin25a		;process it as unshifted
	move.b	kbshift(a5),d2	;grab current setting
	bra	conin25a		;process it
altsw2:	cmpi.b	#$28,d1		;is it a ALT-
	bne.b	altsw3		;no...
	move.b	#$60,d0		;put in '`', then check the shift keys
altsw3	cmpi.b	#$2b,d1		;is it a ALT-#?
	andi.b	#$3,d2		;KBRSH+KBLSH bits
	beq	conin25a		;process it as unshifted
	move.b	kbshift(a5),d2	;grab current setting
	bra	conin25a		;process it
altsw3:	cmpi.b	#$2b,d1		;is it a ALT-#?
	bne.b	outside		;no...
	move.b	#$5e,d0		;put in '^', then check the shift keys
	move.b	kbshift.w,d2	;grab current setting
	endc
	beq	conin25a		;process it as unshifted
	move.b	#$40,d0		;put in '@', instead...it's a alt-shift #
	bra	conin25a		;process it
	ifeq	COUNTRY-ITALY
.endif
	cmpi.b	#$1a,d1		;is it a ALT-^?

	move.b	#$5b,d0		;put in '[', then check the shift keys
	move.b	kbshift(a5),d2	;grab current setting

	beq	conin25a		;process it as unshifted
	move.b	#$7b,d0		;put in '{', instead...it's a alt-shift ^
	bra	conin25a		;process it
altsw1	cmpi.b	#$1b,d1		;is it a ALT-$?
	andi.b	#$3,d2		;KBRSH+KBLSH bits
	move.b	#$5d,d0		;put in ']', then check the shift keys
	move.b	kbshift(a5),d2	;grab current setting
	bra	conin25a	;process it
	beq	conin25a		;process it as unshifted
	move.b	#$7d,d0		;put in '}', instead...it's a alt-shift $
	bra	conin25a		;process it
altsw2	cmpi.b	#$28,d1		;is it a ALT-
	andi.b	#$3,d2		;KBRSH+KBLSH bits
	move.b	#$60,d0		;put in '`', then check the shift keys
	move.b	kbshift(a5),d2	;grab current setting
	bra	conin25a	;process it
	beq	conin25a		;process it as unshifted
	move.b	#$7e,d0		;put in '~',instead...it's a alt-shift
	bra	conin25a		;process it
altsw3	cmpi.b	#$2b,d1		;is it a ALT-#?
	andi.b	#$3,d2		;KBRSH+KBLSH bits
	move.b	#$5e,d0		;put in '^', then check the shift keys
	move.b	kbshift(a5),d2	;grab current setting
	andi.b	#$3,d2		;KBRSH+KBLSH bits
	beq	conin25a		;process it as unshifted
	move.b	#$40,d0		;put in '@', instead...it's a alt-shift #
	move.b	#'~',d0		;put in '~',instead...it's a alt-shift-\
	bra	conin25a	;process it
	endc
	bne.b	outside		;no...
	move.b	#'`',d0		;put in '`'; shifted value is also '`'
	bra	conin25a		;process it
	ifeq	COUNTRY-SWISSGER
.endif



	move.b	kbshift(a5),d2	;grab current setting

	cmpi.b	#$1a,d1		;is it a ALT-umlaut?
	bne.b	altsw1		;no...
	move.b	#$40,d0		;put in '@', then check the shift keys
altsw1	cmpi.b	#$27,d1		;is it a ALT-O with two .. on top
	andi.b	#$3,d2		;KBRSH+KBLSH bits
	beq	conin25a		;process it as unshifted
	move.b	kbshift(a5),d2	;grab current setting
	bra	conin25a		;process it
altsw1:	cmpi.b	#$27,d1		;is it a ALT-O with two .. on top
	bne.b	altsw2		;no...
	move.b	#$5b,d0		;put in '[', then check the shift keys
altsw2	cmpi.b	#$28,d1		;is it a ALT-A with two .. on top
	andi.b	#$3,d2		;KBRSH+KBLSH bits
	beq	conin25a		;process it as unshifted
	move.b	kbshift(a5),d2	;grab current setting
	bra	conin25a		;process it
altsw2:	cmpi.b	#$28,d1		;is it a ALT-A with two .. on top
	bne.b	altsw3		;no...
	move.b	#$5d,d0		;put in ']', then check the shift keys
altsw3	cmpi.b	#$1b,d1		;is it a ALT-!
	andi.b	#$3,d2		;KBRSH+KBLSH bits
	beq	conin25a		;process it as unshifted
	move.b	#$7d,d0		;put in '}', instead...it's a alt-shift umlaut!
altsw4	cmpi.b	#$2b,d1		;is it a ALT-$?
altsw3:	cmpi.b	#$1b,d1		;is it a ALT-!
	bne.b	altsw4		;no...
	move.b	kbshift(a5),d2	;grab current setting
	bra	conin25a		;process it
altsw4:	cmpi.b	#$2b,d1		;is it a ALT-$?
	bne.b	outside		;no...
	move.b	#$7e,d0		;put in '~', then check the shift keys
	move.b	kbshift.w,d2	;grab current setting
	endc
	beq	conin25a		;process it as unshifted
	move.b	#$7c,d0		;put in |', instead...it's a alt-shift umlaut!
	ifeq	COUNTRY-TURKEY

.endif


	move.b	kbshift(a5),d2	;grab current setting

	cmpi.b	#$1a,d1		;is it a ALT-umlaut?
	bne.b	altsw1		;no...
	move.b	#$5b,d0		;put in '[', then check the shift keys
altsw1	cmpi.b	#$27,d1		;is it a ALT-O with two .. on top
	andi.b	#$3,d2		;KBRSH+KBLSH bits
	beq	conin25a		;process it as unshifted
	move.b	kbshift(a5),d2	;grab current setting
	bra	conin25a		;process it
altsw1:	cmpi.b	#$27,d1		;is it a ALT-O with two .. on top
	bne.b	altsw2		;no...
	move.b	#$23,d0		;put in '#', then check the shift keys
altsw2	cmpi.b	#$28,d1		;is it a ALT-A with two .. on top
	andi.b	#$3,d2		;KBRSH+KBLSH bits
	beq	conin25a		;process it as unshifted
	move.b	kbshift(a5),d2	;grab current setting
	bra	conin25a		;process it
altsw2:	cmpi.b	#$28,d1		;is it a ALT-A with two .. on top
	bne.b	altsw3		;no...
	move.b	#$40,d0		;put in '@', then check the shift keys
altsw3	cmpi.b	#$1b,d1		;is it a ALT-!
	andi.b	#$3,d2		;KBRSH+KBLSH bits
	beq	conin25a		;process it as unshifted
	move.b	kbshift(a5),d2	;grab current setting
	bra	conin25a		;process it
altsw3:	cmpi.b	#$1b,d1		;is it a ALT-!
	bne.b	altsw4		;no...
	move.b	#$5d,d0		;put in ']', then check the shift keys
altsw4	cmpi.b	#$2b,d1		;is it a ALT-$?
	andi.b	#$3,d2		;KBRSH+KBLSH bits
	beq	conin25a		;process it as unshifted
	move.b	kbshift(a5),d2	;grab current setting
	bra	conin25a		;process it
altsw4:	cmpi.b	#$2b,d1		;is it a ALT-$?
	bne.b	altsw5		;no...
	move.b	#$5c,d0		;put in '\', then check the shift keys
altsw5	cmpi.b	#$35,d1		;is it a ALT-$?
	andi.b	#$3,d2		;KBRSH+KBLSH bits
	beq	conin25a		;process it as unshifted
	move.b	kbshift(a5),d2	;grab current setting
	bra	conin25a		;process it
altsw5:	cmpi.b	#$35,d1		;is it a ALT-$?
	bne.b	outside		;no...
	move.b	#$3c,d0		;put in '<', then check the shift keys
	move.b	kbshift.w,d2	;grab current setting
	endc
	beq	conin25a		;process it as unshifted
	move.b	#$3e,d0		;put in '>', instead...it's a alt-shift umlaut!
	bra	conin25a		;process it
	ifeq	COUNTRY-SWISSFRA
.endif



	move.b	kbshift(a5),d2	;grab current setting

	cmpi.b	#$1a,d1		;is it a ALT-umlaut?
	bne.b	altsw1		;no...
	move.b	#$40,d0		;put in '@', then check the shift keys
altsw1	cmpi.b	#$27,d1		;is it a ALT-O with two .. on top
	andi.b	#$3,d2		;KBRSH+KBLSH bits
	beq	conin25a		;process it as unshifted
	move.b	kbshift(a5),d2	;grab current setting
	bra	conin25a		;process it
altsw1:	cmpi.b	#$27,d1		;is it a ALT-O with two .. on top
	bne.b	altsw2		;no...
	move.b	#$5b,d0		;put in '[', then check the shift keys
altsw2	cmpi.b	#$28,d1		;is it a ALT-A with two .. on top
	andi.b	#$3,d2		;KBRSH+KBLSH bits
	beq	conin25a		;process it as unshifted
	move.b	kbshift(a5),d2	;grab current setting
	bra	conin25a		;process it
altsw2:	cmpi.b	#$28,d1		;is it a ALT-A with two .. on top
	bne.b	altsw3		;no...
	move.b	#$5d,d0		;put in ']', then check the shift keys
altsw3	cmpi.b	#$1b,d1		;is it a ALT-!
	andi.b	#$3,d2		;KBRSH+KBLSH bits
	beq	conin25a		;process it as unshifted
	move.b	#$7d,d0		;put in '}', instead...it's a alt-shift umlaut!
altsw4	cmpi.b	#$2b,d1		;is it a ALT-$?
altsw3:	cmpi.b	#$1b,d1		;is it a ALT-!
	bne.b	altsw4		;no...
	move.b	kbshift(a5),d2	;grab current setting
	bra	conin25a		;process it
altsw4:	cmpi.b	#$2b,d1		;is it a ALT-$?
	bne.b	outside		;no...
	move.b	#$7e,d0		;put in '~', then check the shift keys
	move.b	kbshift.w,d2	;grab current setting
	endc
	beq	conin25a		;process it as unshifted
	move.b	#$7c,d0		;put in |', instead...it's a alt-shift umlaut!
	ifeq	COUNTRY-DENMARK

.endif


	move.b	kbshift(a5),d2	;grab current setting

	cmpi.b	#$1a,d1		;is it a ALT-^?
	bne.b	altden1		;no...
	move.b	#$5b,d0		;put in '[', then check the shift keys
altden1	cmpi.b	#$1b,d1		;is it a ALT-$?
	beq	conin25a		;process it as unshifted
	move.b	#$7b,d0		;put in '{', instead...it's a alt-shift ^
	move.b	kbshift(a5),d2	;grab current setting
altden1:
	cmpi.b	#$1b,d1		;is it a ALT-$?
	bne.b	altden2		;no...
	move.b	#$5d,d0		;put in ']', then check the shift keys
altden2	cmpi.b	#$28,d1		;is it a ALT-
	beq	conin25a		;process it as unshifted
	move.b	#$7d,d0		;put in '}', instead...it's a alt-shift $
	move.b	kbshift(a5),d2	;grab current setting
altden2:
	cmpi.b	#$28,d1		;is it a ALT-
	bne.b	altden3		;no...
	move.b	#$5c,d0		;put in '\', then check the shift keys
altden3	cmpi.b	#$2b,d1		;is it a ALT-#?
	beq	conin25a		;process it as unshifted
	move.b	#$7c,d0		;put in '|',instead...it's a alt-shift
	move.b	kbshift(a5),d2	;grab current setting
altden3:
	cmpi.b	#$2b,d1		;is it a ALT-#?
	bne.b	outside		;no...
	move.b	#$40,d0		;put in '@', then check the shift keys
	move.b	kbshift.w,d2	;grab current setting
	endc
	beq	conin25a		;process it as unshifted
outside	cmpi.b	#$62,d1		;is it an "alt help" signal to dump the screen?

	addq.w	#1,_dumpflg(a5)	;yes...switch the signal flag on!...

outside:
	cmpi.b	#$62,d1		;is it an "alt help" signal to dump the screen?
	bne.b	alt15a		;no...
	addq.w	#1,_dumpflg.w	;yes...switch the signal flag on!...
alt15a	lea	mauskey1,a2	;get pointer to first alt. mouse scancode table
	bra	ari14		;...and exit
mkloop1	cmp.b	0(a2,d2),d1	;is table's scancode value = current value?
*
alt15a:	lea	mauskey1,a2	;get pointer to first alt. mouse scancode table
	moveq	#3,d2		;create countdown
mkloop1:
	cmp.b	0(a2,d2),d1	;is table's scancode value = current value?
	beq	keymaus1	;yes...go preprocess it...
	move.b	#$-8,d2		;y value for up arrow
	move.b	kbshift(a5),d0	;grab current setting
	cmpi.b	#$48,d1		;is it an up arrow?
	bne.b	alt11
	move.b	#$-1,d2		;y value for up arrow
	move.b	#-8,d2		;y value for up arrow
alt11	cmpi.b	#$4b,d1		;is it an left arrow?
	andi.b	#$3,d0		;KBRSH+KBLSH bits
	beq	keymaus
	move.b	#$-8,d1		;x value for left arrow
	move.b	kbshift(a5),d0	;grab current setting
alt11:	cmpi.b	#$4b,d1		;is it an left arrow?
	bne.b	alt12
	move.b	#$-1,d1		;x value for left arrow
	move.b	#-8,d1		;x value for left arrow
alt12	cmpi.b	#$4d,d1		;is it an right arrow?
	andi.b	#$3,d0		;KBRSH+KBLSH bits
	beq	keymaus
	move.b	#-1,d1		;x value for left arrow
	move.b	kbshift(a5),d0	;grab current setting
alt12:	cmpi.b	#$4d,d1		;is it an right arrow?
	bne.b	alt13
	move.b	#$8,d1		;x value for right arrow
	move.b	#$0,d2		;y value for right arrow
alt13	cmpi.b	#$50,d1		;is it an down arrow?
	andi.b	#$3,d0		;KBRSH+KBLSH bits
	beq	keymaus
	move.b	#$1,d1		;x value for right arrow
	move.b	kbshift(a5),d0	;grab current setting
alt13:	cmpi.b	#$50,d1		;is it an down arrow?
	bne.b	alt14
	move.b	#$0,d1		;x value for down arrow
	move.b	#$8,d2		;y value for down arrow
	move.b	kbshift.w,d0	;grab current setting
alt14	btst.b	#KBCTL,kbshift(a5) ; control key?
	beq	keymaus
	move.b	#$1,d2		;y value for down arrow
	bra	keymaus

alt14:	btst.b	#KBCTL,kbshift.w ; control key?
	bne.b	conin25b	; yup, it gets a control code, not an alt code
	cmpi.b	#$2,d1		; ALT-ize the rest of the keys
alt1	cmpi.b	#$41,d0		;is the key an ascii 'A' or greater?
	cmpi.b	#$d,d1
	bhi.b	alt1		;not <= the '=' key scancode
	addi.b	#$76,d1		;scancode is a key between '1' key and '=' key
alt2	moveq	#$0,d0
alt1:	cmpi.b	#$41,d0		;is the key an ascii 'A' or greater?
alt3	cmpi.b	#$61,d0		;is the key an ascii 'a' or greater?
	cmpi.b	#$5a,d0		;is the key an ascii 'Z' or less?
	bhi.b	alt3		;no...skip to check if 'a'-'z'...
alt2:	moveq	#$0,d0
	bra.b	conin25
conin25a
	btst.b	#KBCTL,kbshift(a5) ; control key?
	cmpi.b	#$7a,d0		;is the key an ascii 'z' or less?
conin25b
	bra.b	alt2
conin25a:
conin25	asl.w	#$8,d1		;shift the scan code to the word's high byte
conin25b:
	andi.w	#$01F,d0	;CTRLize the key

conin25:
	asl.w	#$8,d1		;shift the scan code to the word's high byte
	add.w	d1,d0		;form the outgoing word

	movea.l	(sp)+,a0	;restore kbufrec pointer

ari13	cmp.w	bufhead(a0),d1 ;head=tail?
	addq	#4,d1		;index = tail + 4
	cmp.w	bufsize(a0),d1	;check to see if buffer should wrap
	bcs.b	ari13		;no...
	moveq	#$0,d1		;wrap pointer
	move.w	#$0,d0		;clear out low word
	move.b	kbshift(a5),d0	;bring in the kbshift data (ctrl/alt/shift)
	move.l	bufptr(a0),a2	;get buffer pointer

	swap	d0		;put scan/ascii in high word
	clr.w	d0		;clear out low word
	move.b	kbshift.w,d0	;bring in the kbshift data (ctrl/alt/shift)
	swap	d0		;re-adjust order
	lsl.l	#$8,d0		;now do the shuffling to generate the new
	lsr.w	#$8,d0		;improved conin format ($kkss00aa)

*
	cmp.l	#$0c53001f,d2	;ctl-alt-delete value

	cmp.l	#$0d53001f,d2	;ctl-alt-rshft-delete value
	bclr.l	#KBCL+24,d2	;mask off caps-lock state
	swap	d2		;get high word
	cmp.w	#$0c53,d2	;ctl-alt plus delete's scan-code
	beq	reseth
	cmp.w	#$0d53,d2	;ctl-alt-rshft plus delete's scan-code
	beq	coldboot
	btst.b	#$3,conterm(a5)
	bne.s	ari14z		;set, so store this pig!
*	now we test the kludge bit (#3) of conterm to see if we really
ari14z	and.l	#$0000ffff,d1	;d1.l = (unsigned long)d1.w
*
	btst.b	#$3,conterm.w
ari14	rts
	andi.l	#$00ffffff,d0	;mask off KBSHIFT byte portion..."sigh"
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
	movea.l	midivec(a5),a2	;get contents of midivec for indirect branch
*	 |---always zero (reserved)
*

midibyte:
	movea.l	midivec.w,a2	;get contents of midivec for indirect branch
	jmp	(a2)		;jump to midi interrupt handler

sysmidi:
mi13	cmp.w	bufhead(a0),d1 ;head=tail?
	addq	#1,d1		;index = tail + 1
	cmp.w	bufsize(a0),d1	;check to see if buffer should wrap
	bcs.b	mi13		;no...
	moveq	#$0,d1		;wrap pointer
mi13:	cmp.w	bufhead(a0),d1 ;head=tail?
mi14	rts
	move.l	bufptr(a0),a2	;get buffer pointer
	and.l	#$0000ffff,d1	;d1.l = (unsigned long)d1.w
	move.b	d0,0(a2,d1.l)	;store the data
	move.w	d1,buftail(a0) ;store the new buftail pointer
mi14:	rts

kym1	btst	#7,d1		;see if it is a make or break action
	moveq	#KBMRB,d3	;pre-init to "keyboard" right mouse button
	bclr	d3,kbshift(a5)	;it's a clear button action (break code)
	beq.b	kym1		;it's a right button ($47/$c7)
kym2	bset	d3,kbshift(a5)	;it's a set button action (set code)
kym3	moveq	#$0,d1
	beq.b	kym2		;it's a set button action (make code)
	bclr	d3,kbshift.w	;it's a clear button action (break code)
	bra.b	kym3		;go to further pre-init action...
kym2:	bset	d3,kbshift.w	;it's a set button action (set code)
kym3:	moveq	#$0,d1
	moveq	#$0,d2
	lea	kmbuf(a5),a0	;point to key-emulating mouse buffer
	movea.l	msintvec(a5),a2	;grab mouse interrupt vector
*
	move.b	kbshift(a5),d0	;get current button status
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
* COLD cold boot code: copy a bit of code to $8, then jump to it.	*
	dc.b	$d2
* gets a bus error.  Then it branches to reseth.			*
* COLD cold boot code: copy a bit of code to $C, then jump to it.
* get here either, so don't worry about it.
*
* compile in the limit of 1MB and clear it from ROM.
*
	lea.l	cstart(PC),a0
	move.w	#$f,d0			; move 64 bytes (should be enough)
	move.w	#$8,a1
rloop:	move.l	(a0)+,(a1)+
	dbra	d0,rloop
	clr.l	a5
	jmp	$8(a5)
.text
* this code is copied to address $8, and jumped to with a5 == 0.
* it runs at IPL 7.  It sets the bus error vector and clears RAM
* until it gets a bus error, then jumps to the reset vector,
* found at address $4.  If it's more than 64 bytes long, you'll
* have to change d0 above.
.endif
cstart:
	lea.l	berr(PC),a0
	move.l	a0,$8(a5)
	lea.l	cend(PC),a0
	moveq.l	#0,d0
	move.l	d0,d1
	move.l	d0,d2
	move.l	d0,d3
	move.l	d0,d4
	move.l	d0,d5
	move.l	d0,d6
	move.l	d0,d7
	dbra	d1,cploop
* loop forever (until bus error)
	move.l	#$808,d0		; clobber the cache
cloop:	movem.l	d0-d7,(a0)
	add.w	#(4*8),a0
	bra	cloop
	move.l	#$c,a1
berr:	move.l	$4(a5),a0
	jmp	(a0)
cend:	dc.w	0

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
giwrit	move.b	d0,2(a0)	;init the memory location
giread	moveq	#$0,d0		;clear out register
*	d0.b -- data register contains byte of date			*
*	write operations						*
*	d0.b -- data register contains a verification of written data	*
*									*
*									*
*************************************************************************

	.globl	giaccess

giaccess:
	move.w	4(sp),d0
	moveq	#%11101111,d2
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
onbit	movem.l d0-d2,-(a7)
	.globl	dtron
dtron:
	move.b	#%11101111,d2	;;q
	bra.b	offbit

*************************************************************************
*									*
	moveq	#porta+$80,d1	;setup to write to port a
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
offbit	movem.l d0-d2,-(a7)
	bsr.b	gientry		;go set it and return
	move	(a7)+,sr
	movem.l (a7)+,d0-d2
	rts

*************************************************************************
*									*
	moveq	#porta+$80,d1	;setup to write to port a
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
	move.l	$a(sp),msintvec(a5)	;init the mouse interrupt vector
*	byte 3 - y threshold/scale/delta parameter			*
*									*
*	the following bytes are required for the absolute mouse only	*
*									*
*	byte 4 - xmsb for absolute mouse maximum position		*
*	byte 5 - xlsb for absolute mouse maximum position		*
*	byte 6 - ymsb for absolute mouse maximum position		*
*	byte 7 - ylsb for absolute mouse maximum position		*
*	byte 8 - xmsb for absolute mouse initial position		*
im1	moveq	#$12,d1		;disable mouse
*	byte a - ymsb for absolute mouse initial position		*
	move.l	#xbtexit,msintvec(a5)	;re-init the mouse interrupt vector
*									*
im2
	lea	transbuf(a5),a2	;set transfer buffer pointer
	.globl	initmouse

initmouse:
*	first we determine if the init is for a absolute, relative, or keycode
	lea	transbuf(a5),a2	;set transfer buffer pointer

	tst.w	$4(sp)		;turn mouse off?
im3
	lea	transbuf(a5),a2	;set transfer buffer pointer
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
	lea	transbuf(a5),a2	;set transfer buffer pointer
	move.b	#$8,(a2)+	;set to relative mouse
	move.b	#$b,(a2)+	;set relative mouse threshold x,y
im4
	lea	transbuf(a5),a2	;set transfer buffer pointer
	lea	transbuf.w,a2	;set transfer buffer pointer
	bsr	ikbdstr		;do transfer to ikbd
	bra.b	imexit
	lea	transbuf(a5),a2	;set transfer buffer pointer
	lea	transbuf.w,a2	;set transfer buffer pointer
imexit	moveq	#$-1,d0		;set to true to indicate good init
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
xbtexit rts
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
	move.l	$4(sp),skeytran(a5)
kt1	tst.l	$8(sp)
*									*
	move.l	$8(sp),skeyshif(a5)
kt2	tst.l	$c(sp)
*	long	keytrans(unshift,shift,capslock)			*
	move.l	$c(sp),skeycl(a5)
kt3	move.l	#skeytran,d0
*		-1 signifies no change to vector			*
*									*
*	exit:								*
*		d0.l - returns pointer to beginning of			*
*			key translation address pointers		*
*		order of pointers is:					*
*		unshifted,shifted,caps-locked				*
*		Note:  buffer space for each table should $80!!		*
*									*
*************************************************************************

	.globl	keytrans

keytrans:
	tst.l	$4(sp)
	move.l	#keytran,skeytran(a5)
	move.l	#keyshif,skeyshif(a5)
	move.l	#keycl,skeycl(a5)
	move.l	$8(sp),skeyshif.w
kt2:	tst.l	$c(sp)
	bmi.b	kt3
	move.l	$c(sp),skeycl.w
kt3:	move.l	#skeytran,d0
	rts

*************************************************************************
*	void	dosound(ptr)						*
*		RESTORE BIOS KEYBOARD TRANSLATION TABLE			*
*									*
*	entry:								*
*									*
*	void	bioskeys()						*
*									*
*************************************************************************

	move.l	cursnd(a5),d0		; return current status in D0.L

bioskeys:
	move.l	d1,cursnd(a5)		; setup new sound ptr
	clr.b	timer(a5)		; zap sound timer register
ds_r	rts
	clr.b	keyrep.w		; also nuke key repeat
	rts

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
	move.w	pconfig(a5),d0	;get current config word before we change it
dosound:
	move.l	cursnd.w,d0		; return current status in D0.L
	move.w	4(sp),pconfig(a5)	;set printer config word
nosetp	rts
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
	move.w	cdelay1(a5),d0	;get current initial/repeat values
	tst.w	4(sp)		;see if we don't change the word
	bmi.b	nosetp		;don't set printer word
	move.w	4(sp),pconfig.w	;set printer config word
	move.b	d1,cdelay1(a5)	;set initial delay

*************************************************************************
*									*
	move.b	d1,cdelay2(a5)	;set subsequent delay
kbrate1	rts
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
	clr.l	a5

*	C Timer interrupt routine to process the PSG sound table	*
*									*
	btst.b	#$1,conterm(a5)	;check for key repeat enabled
*+ (lmd)
* timercint - timer c interrupt handler
* divide 200 Hz interrupt frequency to 50 hz, and do:
*	sound handler processing
*	key-repeat processing;
	tst.b	keyrep(a5)
*	system timer-tick handoff.
	tst.b	kdelay1(a5)
*
	subi.b	#1,kdelay1(a5)
*			_timr_ms (timer calibration value)
kr1	subi.b	#1,kdelay2(a5)
*-
	move.b	cdelay2(a5),kdelay2(a5)
	move.b	keyrep(a5),d0
	lea	kbufrec(a5),a0
	rol.w	tc_rot		;rotate divisor bits
	bpl.b	t_punt		;if not 4th interrupt, then return

	movem.l	d0-d7/a0-a6,-(sp)

	bsr.b	sndirq		;process sounds...

	btst.b	#$1,conterm.w	;check for key repeat enabled
	move.w	_timr_ms(a5),-(sp)	;push #ms/tick
	move.l	etv_timer(a5),a0	; get vector
*	process for repeat key function first because it can affect the sound
*	table if enabled and the user is 'using'...

	tst.b	keyrep.w
t_punt:	bclr.b	#5,isrb+mfp	;clear the interrupt channel
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
	move.l	cursnd(a5),d0		;get current sound ptr
tick1:	movem.l	(sp)+,d0-d7/a0-a6
t_punt:
	move.b	timer(a5),d0		;check delay timer
	move.b	#%11011111,isrb+mfp	; was bclr but that's wrong
	rte

	move.b	d0,timer(a5)		;save new
*
*  Quick & dirty sound stuff
*
*
*  Programmed by Dave Staugas
	move.b	d0,giselect(a5)		;else, register load command--select this reg
*
*  To start a sound, load the 32-bit address of the
*			byte stream for that sound in 32-bit
*			"cursnd", & zero the 8-bit "timer"
*
	move.b	rddata(a5),d0		;get mixer contents
*   Called from timer C irq
*
	move.b	d0,wrdata(a5)		;write data
	movem.l	a0/d0-d1,-(sp)
	move.l	cursnd.w,d0		;get current sound ptr
	move.b	(a0)+,wrdata(a5)	;write next byte as data directly to reg
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
	move.b	(a0)+,auxd(a5)		;128--set aux data from next byte in stream
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
	move.b	(a0)+,giselect(a5)	;129--select register
*
	add.b	d0,auxd(a5)		;add to aux data
*
	move.b	auxd(a5),wrdata(a5)	;load reg from data in auxd
	cmp.b	auxd(a5),d0		;reached end of cycle?
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
	move.b	(a0)+,timer(a5)		;set delay timer from next byter in stream
*
snd6:
	cmpi.b	#130,d0			;command greater than 129
	move.l	a0,cursnd(a5)		;update sound ptr
*
*  command 129
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
	ifeq	COUNTRY-USA
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
*************************************************************************

	.even
	.data

.if country == usa

keytran:
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

keyshif:
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
	.endc
	dc.b	'8','9','4','5','6','1','2','3'
	dc.b	'0','.',$0D,$00,$00,$00,$00,$00
	ifeq	COUNTRY-TURKEY

keycl:
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
	dc.b	$00,$00,$00,$00,$00,$00,$00,$37
	dc.b	$38,$00,'-',$34,$00,$36,'+',$00
	dc.b	$32,$00,$30,$7f,$00,$00,$00,$00
	dc.b	'E','A',$9a,'T','K','M','L','Y'

	dc.b	$00,$00,$00,$00,$00,$00,$00,$37
	dc.b	$38,$00,'-',$34,$00,$36,'+',$00
	dc.b	$32,$00,$30,$7f,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00
	.endc
	dc.b	'8','9','4','5','6','1','2','3'
	dc.b	'0','.',$0D,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00
	ifeq	COUNTRY-UK
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



.if country == uk

keytran:
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

keyshif:
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
	.endc
	dc.b	'0','.',$0D,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00
	ifeq	COUNTRY-GERMANY
keycl:
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


.if country == germany

keytran:
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

keyshif:
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
	.endc
	dc.b	'8','9','4','5','6','1','2','3'
	ifeq	COUNTRY-SPAIN
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00

keycl:
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

.if country == spain

keytran:
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

keyshif:
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
	.endc
	dc.b	'8','9','4','5','6','1','2','3'
	dc.b	'0','.',$0D,$00,$00,$00,$00,$00
	ifeq	COUNTRY-FRANCE

keycl:
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


.if country == france

keytran:
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

keyshif:
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
	.endc
	dc.b	'8','9','4','5','6','1','2','3'
	ifeq	COUNTRY-SWEDEN
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00

keycl:
	dc.b	$00,$1b,'&',$90,'"',$27,'(',$dd	;changed $82 to $90 dbg 8/29/85
	dc.b	$8a,'!',$80,$B6,')','-',$08,$09	;changed $85 to $B6 dbg 8/29/85
	dc.b	'A','Z','E','R','T','Y','U','I'
	dc.b	'O','P','^','$',$0D,$00,'Q','S'
	dc.b	'D','F','G','H','J','K','L','M'
	dc.b	$97,'`',$00,'#','W','X','C','V'
	dc.b	'B','N',',',';',':','=',$00,$00
	dc.b	$00,$20,$00,$00,$00,$00,$00,$00

	dc.b	$00,$00,$00,$00,$00,$00,$00,$00
	.dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.dc.b	'-',0,0,0,'+',0,0,0,0,del
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	'<',$00,$00,'(',')','/','*','7'
	dc.b	'8','9','4','5','6','1','2','3'
	dc.b	'0','.',$0D,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00

.endif

.if country == sweden

keytran:
	.dc.b   0,esc,"1234567890+",$82,bs,tab,'qwertyuiop',$86,$81,cr,0
	.dc.b	"asdfghjkl",$94,$84,"'",0,$5c,'zxcvbnm,.-',0,0,0,space,0
	.endc
	.dc.b	'-',0,0,0,'+',0,0,0,0,del
	.dc.b	0,0,0,0,0,0,0,0,0,0,0,0
	ifeq	COUNTRY-NORWAY
	.dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0

keyshif:
	.dc.b	0,esc,'!"#$%&/()=?',$90,bs,tab,'QWERTYUIOP',$8f,$9a,cr,0
	.dc.b	'ASDFGHJKL',$99,$8e,'*',0,'|ZXCVBNM;:_',0,0,0,space,0
	.dc.b	0,0,0,0,0,0,0,0,0,0,0,0,$37,$38,0
	.dc.b	'-',$34,0,$36,'+',0,$32,0,$30,del
	.dc.b	0,0,0,0,0,0,0,0,0,0,0,0
	.dc.b	'>',0,0,'()/*7894561230.',cr
	.dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0

keycl:
	.dc.b	0,esc,"1234567890+",$90,bs,tab,'QWERTYUIOP',$8f,$9a,cr,0
	.dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.dc.b	'-',0,0,0,'+',0,0,0,0,del
	.dc.b	'-',0,0,0,'+',0,0,0,0,del
	.dc.b	0,0,0,0,0,0,0,0,0,0,0,0
	.dc.b	'<',0,0,'()/*7894561230.',cr
	.dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0

.endif
	.dc.b	"ASDFGHJKL",$b2,$92,"'",0,$5c'ZXCVBNM,.-',0,0,0,space,0

.if country == norway

keytran:
	.dc.b   0,esc,"1234567890+",$82,bs,tab,'qwertyuiop',$86,$81,cr,0
	.dc.b	"asdfghjkl",$b3,$91,"'",0,$5c,'zxcvbnm,.-',0,0,0,space,0
	.endc
	.dc.b	'-',0,0,0,'+',0,0,0,0,del
	.dc.b	0,0,0,0,0,0,0,0,0,0,0,0
	ifeq	COUNTRY-ITALY
	.dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0
keyshif:
	.dc.b   0,esc,"1234567890+",$82,bs,tab,'qwertyuiop',$86,$81,cr,0
	.dc.b	"asdfghjkl",$94,$84,"'",0,$5c,'zxcvbnm,.-',0,0,0,space,0
	.dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.dc.b	'-',0,0,0,'+',0,0,0,0,del
	.dc.b	0,0,0,0,0,0,0,0,0,0,0,0
	.dc.b	'<',0,0,'()/*7894561230.',cr
	.dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0
keycl:
	.dc.b	0,esc,"1234567890+",$90,bs,tab,'QWERTYUIOP',$8f,$9a,cr,0
	.dc.b	0,esc,'!"#$%&/()=?',$90,bs,tab,'QWERTYUIOP',$8f,$9a,cr,0
	.dc.b	'ASDFGHJKL',$99,$8e,'*',0,'|ZXCVBNM;:_',0,0,0,space,0
	.dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.dc.b	'-',0,0,0,'+',0,0,0,0,del
	.dc.b	0,0,0,0,0,0,0,0,0,0,0,0
	.dc.b	'>',0,0,'()/*7894561230.',cr
	.dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0


	.dc.b	0,esc,"1234567890+",$90,bs,tab,'QWERTYUIOP',$8f,$9a,cr,0
	.dc.b	"ASDFGHJKL",$99,$8e,"'",0,$60,'ZXCVBNM,.-',0,0,0,space,0
	.dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.dc.b	'-',0,0,0,'+',0,0,0,0,del
	.dc.b	0,0,0,0,0,0,0,0,0,0,0,0
	.dc.b	'<',0,0,'()/*7894561230.',cr
	.dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,'-',0,0,0,'+',0
	.endc
	dc.b	'<',0,0,'(',')','/','*','7','8','9','4','5','6','1','2','3'
	dc.b	'0','.', cr,0,0,0,0,0,0,0,0,0,0,0,0,0
	ifeq	COUNTRY-SWISSGER
keyshif:
	dc.b	0,esc,'!','"',$9c,'$','%','&','/','(',')','=','?','^', bs,tab
	dc.b	'Q','W','E','R','T','Y','U','I','O','P',$82,'*', cr,0,'A','S'
	dc.b	'D','F','G','H','J','K','L','@','#',$dd,0,'|','Z','X','C','V'
	dc.b	'B','N','M',';',':','_',0,0,0,' ',0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,$37,$38,0,'-',$34,0,$36,'+',0
	dc.b	$32,0,$30,del,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	'>',0,0,'(',')','/','*','7','8','9','4','5','6','1','2','3'
	dc.b	'0','.', cr,0,0,0,0,0,0,0,0,0,0,0,0,0

keycl:
	dc.b	0,esc,'1','2','3','4','5','6','7','8','9','0',"'",$8d, bs,tab
	dc.b	'Q','W','E','R','T','Y','U','I','O','P',$8a,'+', cr,0,'A','S'
	dc.b	'D','F','G','H','J','K','L',$95,$85,$97,0,'\','Z','X','C','V'
        dc.b    '78',0,'~4',0,'6#',0,'2',0,'0',del
	dc.b	0,0,0,0,0,0,0,0,0,0,'-',0,0,0,'+',0
        dc.b    '>',0,0,'[]\@{}|4561230.',cr
	dc.b	'<',0,0,'(',')','/','*','7','8','9','4','5','6','1','2','3'
	dc.b	'0','.', cr,0,0,0,0,0,0,0,0,0,0,0,0,0

.endif


.if country == swissger

keytran:
        dc.b    0,esc,'1234567890',"'",'^',bs,tab,'qwertzuiop',$81,$B9,cr,0
        dc.b    "asdfghjkl",$94,$84,$DD,0,"$yxcvbnm,.-",0,0,0,space,0
	.endc
        dc.b    '-',0,0,0,'+',0,0,0,0,del
        dc.b     0,0,0,0,0,0,0,0,0,0,0,0
	ifeq	COUNTRY-SWISSFRA
        dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0

keyshif:
        dc.b    0,esc,'+"*',$87,'%&/()=?`',bs,tab,'QWERTZUIOP',$8a,'!',cr,0
        dc.b    'ASDFGHJKL',$82,$85,$f8,0,$9c,'YXCVBNM;:_',0,0,0,space,0
        dc.b     0,0,0,0,0,0,0,0,0,0,0,0
        dc.b    '78',0,'-4',0,'6+',0,'2',0,'0',del
        dc.b     0,0,0,0,0,0,0,0,0,0,0,0
        dc.b    '>',0,0,'()/*7894561230.',cr
        dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0

keycl:
        dc.b   0,esc,'1234567890',"'",'^',bs,tab,'QWERTZUIOP',$9a,$B9,cr,0
        dc.b    'ASDFGHJKL',$99,$8E,$DD,0,'$YXCVBNM,.-',0,0,0,space,0
        dc.b    '78',0,'~4',0,'6#',0,'2',0,'0',del
        dc.b    '-',0,0,0,'+',0,0,0,0,del
        dc.b    '>',0,0,'[]\@{}|4561230.',cr
        dc.b    '<',0,0,'()/*7894561230.',cr
        dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0

.endif


.if country == swissfra

keytran:
        dc.b    0,esc,'1234567890',"'",'^',bs,tab,'qwertzuiop',$8a,$B9,cr,0
        dc.b    "asdfghjkl",$82,$85,$DD,0,"$yxcvbnm,.-",0,0,0,space,0
	.endc
        dc.b    '-',0,0,0,'+',0,0,0,0,del
	ifeq	COUNTRY-DENMARK
        dc.b    '<',0,0,'()/*7894561230.',cr
        dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0

keyshif:
        dc.b    0,esc,'+"*',$87,'%&/()=?`',bs,tab,'QWERTZUIOP',$81,'!',cr,0
        dc.b    'ASDFGHJKL',$94,$84,$f8,0,$9c,'YXCVBNM;:_',0,0,0,space,0
        dc.b     0,0,0,0,0,0,0,0,0,0,0,0
        dc.b    '78',0,'-4',0,'6+',0,'2',0,'0',del
        dc.b     0,0,0,0,0,0,0,0,0,0,0,0
        dc.b    '>',0,0,'()/*7894561230.',cr
        dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0

keycl:
	.dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.dc.b	'-',0,0,0,'+',0,0,0,0,del
        dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        dc.b    '-',0,0,0,'+',0,0,0,0,del
        dc.b     0,0,0,0,0,0,0,0,0,0,0,0
        dc.b    '<',0,0,'()/*7894561230.',cr
        dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0

.endif

.if country == denmark

keytran:
	.dc.b   0,esc,"1234567890+",$ba,bs,tab,'qwertyuiop',$86,'*',cr,0
	.dc.b	"asdfghjkl",$91,$b3,$82,0,'#','zxcvbnm,.-',0,0,0,space,0
	endc
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
	.dc.b	2,0
	.dc.b	3,0
	.dc.b	4,0
	.dc.b	5,0
	.dc.b	6,0
	.dc.b	7,$FE
*
	.end
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

