.super
****************** Revision Control System *****************************
*
* $Author: ersmith $
* =======================================================================
*
* $Date: 1993/02/25 00:40:26 $
* =======================================================================
*
* $Locker: ersmith $
* =======================================================================
*
* $Log: startup.s,v $
* Revision 2.100  1993/02/25  00:40:26  ersmith
* Fixed the devconnect() call in the startup code, added CTRL-ALT-UNDO during
* bootup to reset NVRAM in case a dumb user (or virus) messed that up.
*
* Revision 2.99  1992/08/11  00:34:42  kbad
* TOS 4.00 Falcon030 first production version
*
* Revision 2.98  1992/07/27  20:12:04  kbad
* Nearly last Sparrow test BIOS
*
* Revision 2.97  1992/07/01  21:48:18  kbad
* last akp revision
*
* Revision 2.96  1992/05/20  22:12:18  unknown
* Added NVMaccess for Sparrow and waketime for all.
*
* Revision 2.95  1992/05/18  23:08:36  unknown
* Sparrow and TT are M68030.
* If sparrow, we go to 16MHz really soon to speed up the boot.
* Sparrow doesn't have microwire any more.
* Changes to the FPU detection code.
* Moved privilege violation handler code so it's not in the startup stream.
* Only branch to dmaboot if systype == rom -- what did we do before?
* Changed user preference code because TT and SPARROW both have NVM.
*
* Revision 2.94  1992/03/11  01:26:14  apratt
* CHanged version number back to x.06; was commented as changed to x.08,
* but was really x.07.  Back to .06 for STPAD ROMs of this date.
*
* Revision 2.93  1992/03/11  01:24:22  apratt
* Clear the high byte of d0.w before writing into sp_VMC.  This wasn't in
* the first one, the one before the cartridge-port check.  In the first
* write, also, write ff8260 to set ST shift mode.
*
* Added comments for meanings of PSG output bits in the place where they're
* set.
*
* Commented out the new code for FPU probe .if STPAD, because I'm building
* STPAD ROMs and the code isn't tested.
*
* Fixed a bug in the code that points "coldboot" vectors to "term."
*
* Revision 2.92  1992/02/29  21:24:18  apratt
* Moved and improved FPU probe and Frestore.  Haven't really tested it.
*
* Fixed the bug that caused coldboot vectors not to revector to _term.
* Moved the coldboot vectoring code to happen as soon as RAM is good.
*
* Took out the Sparrow code that tests and sets the PWRFAIL bit,
* because it doesn't work (yet).
*
* Changed boot_dev_tab to attempt only IDE unit 0 and SCSI unit 0 if Sparrow.
*
* Revision 2.91  1992/02/28  08:24:44  apratt
* Changed TT to M68030 in some places, where it's really CPU dependency we're
* talking about.  This lets us build ROMs for Sparrow/030, which isn't a TT
* in any other way. (Well, it has the same clock chip.)
*
* The Sparrow people in Dallas want the sp_config register to be read
* and the appropriate bits written to VMC even before the diag cart is
* checked, so I moved the code.
*
* I added test-and-set of the Sparrow power-fail bit for cold-boot detection.
*
* I added a hit on color0 to throw Sparrow video more completely into ST mode.
* Hmm, maybe reading isn't enough?
*
* Clear _iamanst if you're on Sparrow.
*
* I made Rwabs go through the tt_rw code (now called m030_rw). It was
* supposed to all along but it didn't.
*
* There is still a bug: if you are a TT and you don't have an FPU you will
* die. The FPU reset code and the FPU probe code need to agree better, and
* need to work when (A) there is no FPU, and (B) the FPU is signalling an
* exception, or will as a result of the probe instruction, and exceptions
* are enabled.
*
* Revision 2.90  1992/02/28  02:00:06  apratt
* Added .globl coldboot to import it.
*
* Revision 2.89  1992/02/28  01:22:40  apratt
* The rev 2.88 log should have looked like this:
*
* Changed version number to 2.08/3.08. (Maintain even version numbers for
* compatibility with nasty old stuff.)
*
* Added tons of Sparrow stuff: initalize memory, video, etc. New MCH, VDO.
*
* Changed the dma boot code to cycle through a table of device numbers to
* attempt, rather than the stupid stuff that was there before.
*
* Here's the log message for revision 2.89:
*
* Vector nasty exceptions during boot to coldboot. Also backed out
* sparrow-special in MicroWire handling, because that HW bug is fixed.
*
* Revision 2.88  1992/02/12  01:31:40  apratt
* ci -u startup.s <slog
* ci -u '-mMuch Sparrow stuff. Also fixed a bug in slow ACSI devices.' dmaread.s
* ci -u '-mAdded SPARROW, removed STPLUS.' mkswitch.e
* ci -u '-mAdded loops .if SPARROW to check the SDMA status bit.' flop.s
* ci -u '-mFixed an RTS/CTS bug in SCC code. See scc_sender.' bios.s
*
* Revision 2.87  1991/11/14  20:33:10  apratt
* Fixed an oops: the ROM CRC check should be done if you have NOT
* been up for 80 seconds yet; instead it was done only if you HAVE
* been up that long.  This version (11/14/91) is the "real" 2.06
* (knock wood!).
*
* Revision 2.86  1991/11/07  00:09:34  apratt
* Evidently not all Mega ST's are created equal.  The one I used here for
* testing STe TOS on an ST worked with Theory 1 for noblank and theory 3 for
* noblank1; others don't. So now noblank uses theory 3 and everybody should
* be happy.
*
* In addition, some Megas do give bus errors at dstride, which I was using to
* probe for ST-vs-STe before RAM was good.  Problem yet to be solved. Idea:
* use dbasell (which at least two kinds of Megas I have *do* dtack) as the
* probe and some other register in the shifter as the control that prevents
* getting a false-positive due to bus capacitance.  That is coded (but
* ill-tested) in this version.
*
* Also, in flop.s, the code writes to the 1772-clock-select register, and
* again, I didn't get a bus error there, but other Megas do, so that will
* have to change.
*
* Finally, I changed the CRC-check code so it only runs if this is a cold
* boot.  The cold-boot detection for this is the same as the hard-disk
* timeout: if _hz_200 reads eighty seconds or more, then you don't get the
* CRC check.  This bailout only works when not TT, because on TT it's quick
* enough, and because without it there's no opportunity to use the ALT key to
* go to ST LOW rez.
*
* Revision 2.85  1991/10/15  14:08:24  apratt
* The test for power-plus-top-closed to subvert resvector on
* STBOOK was wrong: other events can pull the power bit low,
* and if the top was closed, say, when modem-wake happened,
* resvector would be subverted when it wasn't meant to be.
* Now we check for the value $FC explicitly: top-closed and
* power and nothing else.
*
* Revision 2.84  1991/10/01  20:14:24  apratt
* Added code .if STPAD to run the AUTO folder on drive P after running
* the one on bootdev.
*
* Revision 2.83  1991/09/29  23:59:46  apratt
* Added hooks for _waketime XBIOS call in clock.s.  Also commented
* out the code that does a RAM test when you use RAM TOS.
*
* Revision 2.82  1991/09/24  02:24:54  apratt
* STPAD: memory sizing for either 1MB or 4MB.  Also, STylus button bits are
* one when they're UP, not when they're DOWN.
*
* ST: "when is it safe" changed to old-old wait-for-vblank trick after boot;
* during boot, it's "any tick on Timer B."  This is only done if (TT == 0)
* because it's always safe on TT (?).
*
* RAM: we now bra dmaboot even if systype == ram; this lets us do a memory
* test there.
*
* ALL: WVBL now only clears the '4' bit of IPL so it won't drop below 3 if it
* isn't already.  LONG discussion on "when is it safe" at noblank.
*
* This is 2/3.06p, and hopefully the final release for 2/3.06.
*
* Revision 2.81  1991/09/12  19:41:34  apratt
* Changed conditionals: ! is bitwise in MAS, so !TT is $FFFFFFFE when TT is 1.
* So we use (TT == 0) instead.  Sigh.
*
* Revision 2.80  1991/09/06  12:14:10  apratt
* Changed .ifne to just .if, .ifeq to .if !, and .endc to .endif.
* Changed noblank1 so it uses some old code: it waits for 240 ticks
* from timer B (clocked by DE) and then waits for 2ms (using an
* instruction loop) with no ticks.  This works on STe and the old
* method (wait for any tick on timer B, which tells you you're not
* in VBLANK) doesn't.
*
* This is 2.06k / 3.06k, send to Texas for analysis of the monochrome
* video problem which the new noblank solves.
*
* Revision 2.79  91/08/26  17:48:29  apratt
* Changed most uses of _diskbuf into _dskbufp, and exported _dskbufp
* so rwabs.c could use it.
* 
* There is some version-control problem here; recent versions seem to have
* the 80-second timeout code in STPAD as well, when the real thing splits off
* STPAD so you get memory test but no timeout, as in this version.  To get
* 2.06h and i, apply patches by hand and be careful changing the stuff in the
* timeout code.
* 
* This is 2.06j of 8/26/91.
* 
* Revision 2.78  91/08/22  11:30:18  apratt
* fixed an oops for ste mch setting; this is 2.06i
* 
* Revision 2.77  91/08/21  11:20:03  apratt
* STPAD fixes: if both POWER-ON and TOP-CLOSED are down at boot time,
* then DON'T go through resvector.  This defeats the
* shutdown/startup code, which is necessary when things go wrong.
* Also fixed a bug that caused shutdown/startup to initialize
* wrong after a cold boot.
* 
* THIS VERSION IS 3.06h RELEASED TO TEST THIS DATE.
* 
* Revision 2.76  91/08/20  12:27:51  apratt
* STylus buttons are found at $D00004, not $D00006.  Documentation error.
* 
* Revision 2.75  91/08/20  11:47:17  apratt
* Changes for STPAD: clear the conversion-done interrupt during startup,
* vector NMI to RTE because when it happens, Pterm is always the wrong thing
* to do, and check for a stylus-button-click to abort the 80-second timeout
* (because STylus has no keyboard to use for aborting this timeout).
* 
* Revision 2.74  91/08/15  15:31:41  apratt
* Moved STPAD power-control initialization; it was in the wrong place.
* Documented the _MCH cookie better and set it for STe/AT (see _MCH).  Added
* "cart1" processing for STPAD; see cartscan.  Changed memory test and HD
* delay completely; search for "spaghetti" for details.  Explained dmaboot
* device-number sequence (see dmarfail).
* 
* 
* Revision 2.73  91/08/05  15:28:11  apratt
* Added a bad hack for STPAD: fifteen ms after enabling interrupts,
* we clobber kbshift.  This way if you reset with ctl-alt-delete,
* the dmaboot code won't see the alt key still down.  Don't know how
* well this works yet.
* 
* Revision 2.72  91/08/05  14:22:34  apratt
* Changed version system: now version.s exports date and dosdate,
* and it's maintained by biosvers.prg.  startup.s imports these,
* and the high byte of the version number comes from the system type,
* and the low byte from a constant in startup.s.  Also, moved STPAD screen
* init higher, changed spindelay (see flop.s), enabled cache on TT more,
* and added a memory test.
* 
* Revision 2.71  91/06/13  16:27:51  apratt
* changed date to 6/16/91; this is 3.06d.  Also backed out the check that
* said, "If you have a diagnostic cartridge, don't install the bomb vectors."
* Also enabled the cache during CRC checks on TT so they're faster.  Also
* changed the comment for XBIOS call 11 to the effect that it's used by AKP's
* debugger, and XBIOS call 40 as the one KBAD and John Townsend will use for a
* cookie call.
* 
* Revision 2.70  91/05/22  14:53:27  apratt
* Changed date to today.  This is 3.06c.  3.06b had a bug
* in flop.s: some QD debug code was left in, so seeks happened
* at 6ms/step and write precompensation was turned off (both
* only in high density mode).
* 
* Revision 2.69  91/05/21  16:57:58  apratt
* Reset the ACSI chip and leave it in the read state VERY EARLY in the boot,
* between the CPU reset and the reset instruction at the top of the code. 
* Changed the _FDC cookie to match the new def'n.  Set nospindelay (from
* flop.s) if the switch is thrown.
* 
* Made TT's boot up in TT MED so they don't look like game machines.  Fixed
* icon-drawing code appropriately.  Hold down ALT to go back to ST LOW so
* autoboot games get what they expect.
* 
* Fixed CRC message so it identifies the chip just like on the board.
* 
* Revision 2.68  91/05/02  17:40:55  apratt
* Added code to save tbcr in addition to the enable bit from iera
* in noblank1.  Can't hurt, and probably will help: if somebody
* has the interrupt enabled and the counter stopped, and we
* end up leaving the counter running (and restore the enable bit),
* you'll start getting timer B ints!
* 
* Revision 2.67  91/04/26  17:50:25  apratt
* Version number is back to x.06, so we can go out with that number.
* See discussion of even version numbers in the comments.
* 
* Added _FDC cookie; this is tentative, and will become firm on or near May
* 2, 1991.  For now the cookie is installed and the high word is one if
* configuration switch bit 6 is thrown.
* 
* New in-house version number tracking scheme: as soon as there's a release,
* the number is incremented and 'a' gets added; the letter changes when
* necessary.  For rev's release, the letter is dropped.
* 
* Revision 2.66  91/04/24  17:16:37  apratt
* Changed dates and version number for x.07.  Added frestore of null
* state in reset code (comment was there but code wasn't).  Added
* comments to the effect that the PSG outputs being initialized to
* zero are getting zeros on purpose.  Added a write to STPAD power
* control registers.  Changed the delay back to 90 sec -- there was
* no reason to change to 60, and if it ain't broke...  Added a
* ROM CRC check to detect (among other things) incorrect switch
* settings before you burn half a day debugging it.
* 
* Revision 2.65  91/04/11  12:16:03  apratt
* Added drawing of an Atari logo at power up.  Removed USEDB.
* Changed date to 4/9/91; version is x.06.  Changed power-up delay
* from 90 sec to 60 sec.
* 
* Revision 2.64  91/03/27  12:37:43  apratt
* Added STPAD: mostly, this is STPLUS (which should also be set), but sets
* DMASND to zero, adds some magic vars at $840 which Slavik's touch pad
* driver knows about, and short-circuits memory sizing. Also has its own
* cookie: $00010000+STPAD (which should be 1). Also tries the IDE bus, then
* the ACSI bus for booting.  Removes monitor-change code.
* 
* Fixed a bug: the AND to get only the significant bits of the mode register
* was wrong; it was always three bits when it should be just two if not TT.
* 
* Revision 2.63  91/01/31  13:57:42  apratt
* Changed noblank1 to save & restore iera bit 0. Now vers x.06
* 
* Revision 2.62  90/12/07  14:50:23  apratt
* changed version number for 2.05/3.05
* 
* Revision 2.61  90/11/20  18:49:17  apratt
* changed version numbers
* 
* Revision 2.60  90/11/12  16:23:51  apratt
* Changed date & version number, changed code to test result of
* _iclock correctly, and added code to clobber Timer A after
* the boot-up sequence is done with it (for compatibility with
* programs that do enabling steps in an unsafe order).
* 
* Revision 2.59  90/10/15  12:04:40  apratt
* Changed all version numbers, and changed all dates to Oct 12, 1990.
* 
* Also removed PC-relative addressing because MAS has a bug: PC-relative
* addressing to a label that's BEFORE the PC, with arithmetic, generates
* incorrect code.  Example: "move.b label+1(PC),d0" when 'label' is before
* the current PC generates "move.b label+3(PC),d0"
* 
* Revision 2.58  90/08/21  17:15:28  apratt
* This version works in both STe and Mega STe, distinguishing between
* them at runtime by checking for bus error when accessing ttscu1.
* 
* Bconmap is no longer conditional.
* 
* Probe for the SFP004 only if not TT.  Fix the FPU cookie, which was
* broken before, but only on non-TT (whew!).
* 
* This version is NOT country-dependent.  The only country dependency was
* osconf, and that's now an EQU exported from BIOS (which is already
* country dependent).
* 
* Other log messages removed.
* 
* Revision 2.57  90/08/03  13:23:45  apratt
* TTOS FINAL RELEASE
*
* =======================================================================
*
* $Revision: 2.100 $
* =======================================================================
*
* $Source: d:\tos\bios/RCS/startup.s,v $
* =======================================================================
*
*************************************************************************

*************************************************************************
*
*  Conditional assembly switches and system parameters.
*  Change these, depending on the system that is being built,
*  and the addresses things end up at:
*
*  'dosdate' is the date the system was built, in DOS format:
*
*  YYYYYYYMMMMDDDDD:
*		YYYYYYY	= year - 1980
*		   MMMM = month (1-12)
*		  DDDDD = day (1-31)
*
*
* The version number must be even.  This is because at least one line
* of third-party software causes a move from 0 to a2, then a word read
* from (a2) -- this causes address error unless the version number is even.
* In addition, the target of the short branch at reseth must not 
* be more than $3e bytes away, for the same reason (bus error when
* reading RAM address >3fffff).
*
* The software line in question is First Byte's Kid series.  They have
* been notified of this problem (AKP 5/3/88).
*
* As of TT TOS, we have rescinded this restriction, because their software
* doesn't work for other reasons.  However, a TOS which goes in STe or MSTe
* should still be even-numbered, and since the minor vers. number marches
* in step with TT, we're stuck.
*
*-

* The switches TT, SPARROW, STPAD, systype, and country are now set
* on the command line.  switches.s contains rom/ram and country defines

.include "switches.s"

* SPARROW and TT are both M68030.

M68030		equ	(SPARROW | TT)

* ONLY_LONGFRAME gets set when you're on machine that can never
* have a short-frame processor (68000).  Currently that's only TT.

ONLY_LONGFRAME	equ	TT

* DMASND used to be a compile-time constant, but now it's not. It's a
* variable instead: _hasdmasnd.  If it's true, then MONOMON is XORed with
* the DMA sound IRQ line.  This is independent of of whether you have the
* analog hardware outside the sound shifter to actually make sound.

* set the high byte of the version number based on the machine type

.if SPARROW
vershi		equ	$04
verslo		equ	$92
.else

.if TT
vershi		equ	$03
.else
vershi		equ	$02
.endif

* set the low byte of the version number each release.
verslo		equ	$07
.endif


* The date is now in another file, which is updated automatically
* in the makefile.  date and dosdate are imported here for use in
* the OS header.

.globl date
.globl dosdate

version		equ	(vershi * $100) + verslo

bootcolor	equ	$fff		; WHITE for production ROMs

*************************************************************************
*									*
* The country-specific configuration word 'osconf' is now an equate	*
* which is exported from BIOS.S and imported here for placement		*
* in the OSHEADER.  That way, this file has no country dependencies.	*
*									*
*************************************************************************

*------------------------------------------------------------------------
*									:
*	System Initialization for 520, 1040, MEGA STs			:
*	Copyright 1984, 1985, 1986, 1987, 1988, 1989, 1990  Atari Corp.	:
*	All Rights Reserved.						:
*									:
*------------------------------------------------------------------------

*--------------	Exports:
	.globl	_iamanst		; nonzero for ST, zero for STe/TT
	.globl	reseth			; used by keyboard reset code
	.globl	endosbss		; (informative) end OS bss
	.globl	_dumpflg,_prtcnt	; screen dump flag (& its alias)
	.globl	_prtabt			; printer abort flag
	.globl	flock			; floppy/FIFO lock
	.globl	sshiftmd		; shiftmd shadow
	.globl	etv_timer		; timer handoff vector
	.globl	_membot			; (best guess) bottom of TPA
	.globl	_memtop			; top of TPA (first unusable byte)
	.globl	_timr_ms		; system timer calibration (in ms)
	.globl	_vblqueue		; vbl queue
	.globl	_vbclock		; count of unblocked vblank interrupts
	.globl	_frclock		; count of all vblank interrupts
	.globl	_v_bas_ad		; video base addr
	.globl	con_state		; state of conout() parser
	.globl	save_row		; saved row# for cursor X-Y addressing
	.globl	_bufl			; two buffer-list headers
	.globl	_bootdev		; default boot device [0]
	.globl	_cmdload		; nonzero: exec shell on boot device
	.globl	conterm			; terminal emulator bitSwitches
	.globl	_nflops			; "Hey!  Clams got floppies!"
	.globl	_critic			; critical error handler binding for C
	.globl	_hz_200			; 200hz raw system timer tick
	.globl	_dskbufp		; pointer to some space for disk I/O
	.globl	seekrate		; default floppy seek rate
	.globl _fverify			; nonzero: verify on floppy write
	.globl _drvbits			; long bitmap of block devices
	.globl	conterm			; console/vt52 bits

	.globl	_hinit			; go through hdv_init
	.globl _dskboot			; boot from somewhere
	.globl	_fastcpy		; fast copy (for unaligned DMA)
	.globl	_longframe		; when nonzero, we're on 68010 and up.
	.globl	bell_hook		; hook for bell sound
	.globl	kcl_hook		; hook for keyclick sound
	.globl	clrcache		; routine to clear 68030 cache
	.globl	_p_cookie		; pointer to cookie jar
	.globl	xconstat		; used by bconmap

	.globl	_ramtop			; exports for memtest.s
	.globl	end_os
	.globl	phystop

	.globl	_wvbl			; exports for setmode.c

*--------------	Imports:
.if systype == rom
	.globl	endaesbss
.if TT
	.globl	_resetscsi
.endif
.endif

.if SPARROW
	.globl	_Dsp_Init		; initialize DSP
.endif
.if (TT == 0)
	.globl	_waketime		; alarm maintenance for STPAD
.endif
.if (TT | SPARROW)
	.globl	NVMaccess		; read/write/init non-volatile RAM
.endif
	.globl	osconf			; equate imported from BIOS.S
	.globl	_bconmap		; (soon-obsolete) XBIOS call
	.globl	endos, the_magic	; ashes of the build process
	.globl	_dmaread,_dmawrite	; for booting

	.globl	_date,_time		; GEMDOS date and time

	.globl	clktest			; test for clock chip
	.globl	_setclock		; set clock chip
	.globl	_getclock		; get clock chip time
	.globl	_iclock			; initialize clock chip

	.globl	_cursconf		; cursor configuration
	.globl	_asc_out		; "raw" character output to screen
	.globl	pconfig			; printer configuration word
	.globl	_prtblk			; _prtblk primitive
	.globl	_osi			; initialize OS
	.globl	initmfp			; init character I/O
	.globl	esc_init		; init glass tty
	.globl	__esc_init		; init glass tty
	.globl	initmous		; mouse vector init
	.globl	_mediach		; media change inquiry
	.globl	_proto_bt		; prototype boot sector
	.globl	_flopwr			; write sector(s)
	.globl	_flopver		; verify sector(s)
	.globl	_flopfmt		; format track
	.globl	_floprate		; get/set floppy seek rate code
	.globl	_rand			; generate random number
.if (SPARROW == 0)
	.globl	blt_init		; init the blitter chip
.endif
	.globl auxistat			; input-status
	.globl constat
	.globl midstat
	.globl _lstin			; input
	.globl auxin
	.globl conin
	.globl midin
	.globl _lstostat		; output-status
	.globl _auxostat
	.globl conoutst
	.globl ikbdost
	.globl midiost
	.globl _lstout			; output
	.globl _auxout
	.globl conout
	.globl midiwc
	.globl ikbdwc

	.globl midiws			; write MIDI string
	.globl mfpint			; setup MFP interrupt
	.globl iorec			; configure I/O record
	.globl rsconf			; configure RS-232
	.globl keytrans			; store keyboard translation
	.globl settime			; set ikbd date
	.globl gettime			; get ikbd date
	.globl bioskeys			; reset keyboard to power-up defaults
	.globl ikbdws			; write string to ikbd

	.globl	line1010		; line 1010 handler
	.globl	kbshift			; keyboard shift status

	.globl	jdisint
	.globl	jenabint
	.globl	giaccess
	.globl	offgibit
	.globl	ongibit
	.globl	xbtimer
	.globl	dosound
	.globl	setprt
	.globl	kbrate
	.globl	ikbdvecs

	.globl	_supstk			; GEMDOS super stack
	.globl	_diskbuf		; disk buffer

	.globl	_getdsb			; return disk's state pointer
	.globl	_boot			; load and check boot sector
	.globl	_rwabs			; read/write on block dev
	.globl	_getbpb			; get bios parameter block
	.globl	_dskinit		; disk system initialization
	.globl	_flopvbl		; floppy vblank handler
	.globl	_floprd			; read sector(s)
	.globl	blink			; cursor blink (vblank)
	.globl	def_bell		; default bell handler
	.globl	def_click		; default keyclick handler

	.globl	coldboot		; cold-boot handler



*----
* Default System Parameters.
* Do not change these much.
*----
df_seek		equ	$0003		; default seek-rate (3ms)
dnvbls		equ	8		; default number of vbl queue entries
nlevels		equ	5		; max # recursive BIOS calls
savsiz		equ	23		; size (.W) of BIOS trap save-context
DEFCSIZE	equ	$20		; default to room for 32 cookies




*--------------	Magic Numbers
resmagic	equ	$31415926	; validates 'resvalid'
diagmagic	equ	$fa52235f	; validate diagnostic cartridge
apmagic		equ	$abcdef42	; validate application cartridge
memmagic	equ	$752019f3	; validates 'memvalid'
memmag2		equ	$237698aa	; validates 'memval2'
memmag3		equ	$5555aaaa	; validates 'memval3'
bootmagic	equ	$1234		; magic checksum for boot sector
rammagic	equ	$1357bd13	; validates 'ramtop'


*-------------- Seriously bogus magic number:

supsiz		equ	3*1024		; size of _supstk from GEMDOS


*--------------	Data Structures

*---- Cartridge application:
ca_next		equ	0		; (.L) link to next application
ca_flags	equ	4		; (.B) run flags (MSB of ca_init)
ca_init		equ	4		; (.L) pointer to init code
ca_run		equ	8		; (.L) pointer to run code
ca_time		equ	$c		; (.W) DOS-format creation time
ca_date		equ	$e		; (.W) DOS-format creation date
ca_size		equ	$10		; (.L) application size
ca_name		equ	$14		; application name (NNNNNNNN.EEE\0)


*---- NVRAM contents
nv_upref	equ	$00		; UNIX/TOS boot preference
nv_manuf	equ	$02		; factory code, etc.
nv_AKPlang	equ	$06		; _AKP language
nv_AKPkb	equ	$07		; _AKP keyboard
nv_IDTtd	equ	$08		; _IDT time/date pref
nv_IDTsep	equ	$09		; _IDT date separator
nv_dspin	equ	$0a		; spinup delay
nv_iscan	equ	$0b		; IDE scan mask
nv_sscan	equ	$0c		; SCSI scan mask
nv_ascan	equ	$0d		; ACSI scan mask
nv_vmode	equ	$0e		; video mode
nv_used		equ	$10		; # of bytes of NVRAM used


*------ Ram configuration equates
bank1		equ $200000		; address of 2Mb second	bank
twomb		equ 1024*2048		; two megabytes
one28		equ $20000		; 128K



*--------------	Hardware Equates

cartbase	equ $fa0000		; start	of cartridge ROM
cartsize	equ $20000		; size of cartridge (128K)

*--- Memory controller
memconf		equ	$ffff8001	; memory controller

*--- SPARROW equates
.include "sparrequ.s"

*--- Shifter:
syncmode	equ	$ffff820a	; video	sync mode
dbasel		equ	$ffff8203	; display base low
dbaseh		equ	$ffff8201	; display base high
color0		equ	$ffff8240	; color	palette	#0
shiftmd		=	$ffff8260	; video	shift mode (resolution)

.if TT
ttcolor0	equ	$ffff8400	; TT background color reg
shiftmd		=	$ffff8262	; TT shift mode (overrides above equ)
.endif

*--- Video base address low byte (not on ST)
* This register can be accessed as byte or word, and D.RENN assures me
* that the low bit of this register will always read as zero on STe,
* and the low three bits as zero on TT.
dbasell		equ	$ffff820d	; addr of low byte of this reg
dstride		equ	$ffff820f	; "offset to next line" in STe

*--- configuration switches (not on ST)
conf_switches	equ	$ffff9200
ttd_conf_switches equ	$ffff8000	; not used if not TT

*--- GI ("psg") sound chip:
giselect	equ	$ffff8800	; (W) sound chip register select
giread		equ	$ffff8800	; (R) sound chip read-data
giwrite		equ	$ffff8802	; (W) sound chip write-data
gimixer		equ	7		; I/O control/volume control register
giporta		equ	$e		; GI register# for I/O port A
giportb		equ	$f		; Centronics output register

*--- 68901 ("mfp") sticky chip:
mfp	equ	$fffffa00		; mfp base
gpip	equ	mfp+1			; general purpose I/O
aer	equ	mfp+3			; active edge reg
ddr	equ	mfp+5			; data direction reg
iera	equ	mfp+7			; interrupt enable A & B
ierb	equ	mfp+9
ipra	equ	mfp+$b			; interrupt pending A & B
iprb	equ	mfp+$d
isra	equ	mfp+$f			; interrupt inService A & B
isrb	equ	mfp+$11
imra	equ	mfp+$13			; interrupt mask A & B
imrb	equ	mfp+$15
vr	equ	mfp+$17			; interrupt vector base
tacr	equ	mfp+$19			; timer A control
tbcr	equ	mfp+$1b			; timer B control
tcdcr	equ	mfp+$1d			; timer C & D control
tadr	equ	mfp+$1f			; timer A data
tbdr	equ	mfp+$21			; timer B data
tcdr	equ	mfp+$23			; timer C data
tddr	equ	mfp+$25			; timer D data
scr	equ	mfp+$27			; sync char
ucr	equ	mfp+$29			; USART control reg
rsr	equ	mfp+$2b			; receiver status
tsr	equ	mfp+$2d			; transmit status
udr	equ	mfp+$2f			; USART data

*--- TTMFP 68901
ttmfp	equ	$fffffa80

ttgpip	equ	ttmfp+1			; general purpose I/O
ttaer	equ	ttmfp+3			; active edge reg
ttddr	equ	ttmfp+5			; data direction reg
ttiera	equ	ttmfp+7			; interrupt enable A & B
ttierb	equ	ttmfp+9
ttipra	equ	ttmfp+$b		; interrupt pending A & B
ttiprb	equ	ttmfp+$d
ttisra	equ	ttmfp+$f		; interrupt inService A & B
ttisrb	equ	ttmfp+$11
ttimra	equ	ttmfp+$13		; interrupt mask A & B
ttimrb	equ	ttmfp+$15
ttvr	equ	ttmfp+$17		; interrupt vector base
tttacr	equ	ttmfp+$19		; timer A control
tttbcr	equ	ttmfp+$1b		; timer B control
tttcdcr	equ	ttmfp+$1d		; timer C & D control
tttadr	equ	ttmfp+$1f		; timer A data
tttbdr	equ	ttmfp+$21		; timer B data
tttcdr	equ	ttmfp+$23		; timer C data
tttddr	equ	ttmfp+$25		; timer D data
ttscr	equ	ttmfp+$27		; sync char
ttucr	equ	ttmfp+$29		; USART control reg
ttrsr	equ	ttmfp+$2b		; receiver status
tttsr	equ	ttmfp+$2d		; transmit status
ttudr	equ	ttmfp+$2f		; USART data

*--- 6850 registers:
keyctl	equ	$fffffc00		; keyboard ACIA control
keybd	equ	keyctl+2		; keyboard data
midictl	equ	$fffffc06		; MIDI ACIA control
midi	equ	midictl+2		; MIDI data


*--- DMA SOUND AND MicroWire REGISTERS
dmasndc	equ	$ffff8900
mwdata	equ	$ffff8922
mwmask	equ	$ffff8924

*--- SCU REGISTERS: interrupt mask, interrupt state, and two gp regs
ttvmeimsk	equ	$ffff8e0d	; "vme" int mask in SCU
ttsysimsk	equ	$ffff8e01	; "sys" int mask in SCU	
ttvmeistate	equ	$ffff8e0f	; "vme" int state in SCU
ttsysistate	equ	$ffff8e03	; "sys" int state in SCU

ttscu1		equ	$ffff8e09	; general-purpose SCU register 1
ttscu2		equ	$ffff8e0b	; general-purpose SCU register 2

* TT RAM refresh rate -- write in $FFD000xx to set rate.  $E0 is right.
refresh		equ	$ffd000e0

*+
* Dump area
* Processor state is dumped here after an uncaught trap
*
*-
proc_lives	equ	$380			; lives if $12345678
proc_regs	equ	proc_lives+4		; D0-D7/A0-A7
proc_pc		equ	proc_regs+$40		; PC
proc_usp	equ	proc_pc+4		; USP
proc_stk	equ	proc_usp+4		; six words of stack



*+
* Base of system BSS.
* Starts at $400, just above interrupt vector RAM.
*
* These will never change in future releases of the system.
*
*-
		.bss

* "extended" trap vectors:
etv_timer:	ds.l	1	; (400)	 vector for timer interrupt chain
etv_critic:	ds.l	1	; (404)	 vector for critical error chain
etv_term:	ds.l	1	; (408)	 vector for process terminate
etv_xtra:	ds.l	5	; (40c)	 5 reserved vectors

memvalid:	ds.l	1	; (420)	 indicates system state on RESET
memcntlr:	ds.w	1	; (424)	 mem controller config nibble
resvalid:	ds.l	1	; (426)	 validates 'resvector'
resvector:	ds.l	1	; (42a)	 [RESET] bailout vector
phystop:	ds.l	1	; (42e)	 physical top of RAM
_membot:	ds.l	1	; (432)	 bottom of available memory;
_memtop:	ds.l	1	; (436)	 top of available memory;
memval2:	ds.l	1	; (43a)	 validates 'memcntlr' and 'memconf'
flock:		ds.w	1	; (43e)  floppy disk/FIFO lock variable
seekrate:	ds.w	1	; (440)  default floppy seek rate
_timr_ms:	ds.w	1	; (442)  system timer calibration (in ms)
_fverify:	ds.w	1	; (444)  nonzero: verify on floppy write
_bootdev:	ds.w	1	; (446)	 default boot device
palmode:	ds.w	1	; (448)	 nonzero ==> PAL mode
defshiftmd:	ds.w	1	; (44a)	 default video rez (first byte)
sshiftmd:	ds.w	1	; (44c)	 shadow for 'shiftmd' register (byte)
_v_bas_ad:	ds.l	1	; (44e)	 pointer to base of screen memory
vblsem:		ds.w	1	; (452)	 semaphore to enforce mutex in	vbl
nvbls:		ds.w	1	; (454)	 number of deferred vectors
_vblqueue:	ds.l	1	; (456)	 pointer to vector of deferred	vfuncs
colorptr:	ds.l	1	; (45a)	 pointer to palette setup (or NULL)
screenpt:	ds.l	1	; (45e)	 pointer to screen base setup (|NULL)
_vbclock:	ds.l	1	; (462)	 count	of unblocked vblanks
_frclock:	ds.l	1	; (466)	 count	of every vblank

hdv_init:	ds.l	1	; (46a)	 hard disk initialization
swv_vec:	ds.l	1	; (46e)	 video change-resolution bailout
hdv_bpb:	ds.l	1	; (472)	 disk "get BPB"
hdv_rw:		ds.l	1	; (476)	 disk read/write
hdv_boot:	ds.l	1	; (47a)	 disk "get boot sector"
hdv_mediach:	ds.l	1	; (47e)	 disk media change detect

_cmdload:	ds.w	1	; (482)	 nonzero: load COMMAND.COM from boot
conterm:	ds.b	1	; (484)  console/vt52 bitSwitches (%%0..%%2)
		ds.b	1	; (485)  [unused, reserved]

		ds.w	1	; (486)	 [unused, reserved]
		ds.l	1	; (488)	 [unused, reserved]
		ds.w	1	; (48c)  [unused, reserved]
themd:		ds.l	4	; (48e)	 memory descriptor (MD)
_____md:	ds.w	2	; (49e)  (more MD)
savptr:		ds.l	1	; (4a2)	 pointer to register save area

_nflops:	ds.w	1	; (4a6)	 number of disks attached (0, 1+)
con_state:	ds.l	1	; (4a8)  state of conout() parser
save_row:	ds.w	1	; (4ac)  saved row# for cursor X-Y addressing
sav_context:	ds.l	1	; (4ae)  pointer to saved processor context
_bufl:		ds.l	2	; (4b2)  two buffer-list headers
_hz_200:	ds.l	1	; (4ba)  200hz raw system timer tick
		ds.l	1	; (4be)  [unused, reserved]
_drvbits:	ds.l	1	; (4c2)  bit vector of "live" block devices
_dskbufp:	ds.l	1	; (4c6)  pointer to common disk buffer
_autopath:	ds.l	1	; (4ca)  pointer to autoexec path (or NULL)
_vbl_list:	ds.l	8	; (4ce)  initial _vblqueue (to $4ee)
_prtcnt:			; (4ee)  screen-dump flag alias
_dumpflg:	ds.w	1	; (4ee)  screen-dump flag
_prtabt:	ds.w	1	; (4f0)  printer abort flag
_sysbase:	ds.l	1	; (4f2)  -> base of OS
_shell_p:	ds.l	1	; (4f6)  -> global shell info
end_os:		ds.l	1	; (4fa)  -> end of OS memory usage
exec_os:	ds.l	1	; (4fe)  -> address of shell to exec on startup
scr_dump:	ds.l	1	; (502)  -> screen dump code

		.globl	prv_lsto
		.globl	prv_lst
		.globl	prv_auxo
		.globl	prv_aux
*--- character-output vectors for _prtblk():
prv_lsto:	ds.l	1	; (506)	-> _lstostat()
prv_lst:	ds.l	1	; (50a) -> _lstout()
prv_auxo:	ds.l	1	; (50e) -> _auxostat()
prv_aux:	ds.l	1	; (512) -> _auxout()

pun_ptr:	ds.l	1	; (516)  -> hard disk driver phys unit table
memval3:	ds.l	1	; (51a)  memory validation (memval3)

*--- "soft" console vectors
xconstat:	ds.l	8	; (51e)  console status vectors
xconin:		ds.l	8	; (53e)  console input vectors
xcostat:	ds.l	8	; (55e)  console output-status vectors
xconout:	ds.l	8	; (57e)  console output vectors

_longframe:	ds.w	1	; (59e)  if nonzero, we're on 680[1-3]0.
_p_cookie:	ds.l	1	; (5a0)  pointer to the Cookie Jar
_ramtop:	ds.l	1	; (5a4)  top of ram starting at $01000000
_ramvalid:	ds.l	1	; (5a8)  ramtop valid if rammagic ($1357bd13)
bell_hook:	ds.l	1	; (5ac)  handler for bell
kcl_hook:	ds.l	1	; (5b0)  handler for keyclick
*				; (5b4)

* more_os_vars used to go here, but it took up NEGATIVE space, so I
* took it out 12/06/88 AKP.  Don't think this'll break anything.

*----------------------------------------
*					:
*	PATCH AREA, here..$7FF		:
*					:
*	This space reserved for		:
*	future RAM-loaded fixes		:
*	to the operating system.	:
*					:
*
* ROMs for 68030's use $700-$800 for the PMMU page tables: this has the
* advantage of making them protected from user-mode access.
*
*----------------------------------------

.if M68030
.globl	fix_it_up
fix_it_up:	ds.b	$700-$5b4

levelA:		ds.b	$40
levelB1:	ds.b	$40
levelB2:	ds.b	$40
levelC:		ds.b	$40
	
.else
fix_it_up:	ds.b	$800-$5b4
.endif

*----------------------------------------
*					:
*	USER-MODE VARIABLE SPACE	:
*	$800..$83F			:
*					:
*	This space reserved for		:
*	applications requiring		:
*	variable in user RAM.		:
*					:
*	Some cartridges (LOGO and	:
*	BASIC, etc.) will use it	:
*	for BSS.			:
*					:
*----------------------------------------
		.globl	user_vars
user_vars:	ds.b	64		; 64 bytes for carts and things


*----------------------------------------
*					:
*	BSS beyond this point		:
*	will change in future		:
*	revs of the OS.			:
*					:
*					:
* The 164 bytes starting at $840 are	:
* used by the touch driver in STPAD.	:
* They are not clobbered across reset.	:
*----------------------------------------

.if STPAD
padmagic:	ds.l	1		; $01241960 for STPAD touch driver
padstuff:	ds.l	10*4		; other pad variables (total 40 bytes)
.endif

the_env:	ds.b	20		; space for a small enviroment string
savarea:	ds.w	savsiz*nlevels	; register save area
savend:					; end of register sav area
		ds.b	6		; enough for JMP <abs> before hdrcopy
hdrcopy:	ds.b	$40		; copy of OS header ["big enough"]
defcookies:	ds.l	DEFCSIZE*2	; initial cookie jar
_upref:		ds.w	1		; boot pref for _dmaboot
dspin:		ds.b	1		; spinup delay before _dmaboot
iscan:		ds.b	1		; IDE scan mask for _dmaboot
sscan:		ds.b	1		; SCSI scan mask for _dmaboot
ascan:		ds.b	1		; ACSI scan mask for _dmaboot
.if TT
ttmd:		ds.l	4		; the TT MD for fast RAM (see getmpb)
.endif
_hasdmasnd:	ds.b	1		; flag: MONOMON is XORed with IRQ
_iamanst:	ds.b	1		; flag: I am an ST - mainly ST video.
					; used in BIOS to mean "no SCC chip"

endosbss:				; end of "base" BSS


	.text
*+
* System startup parameters
*
* In ROM, these are found at $FC0000.
* In any event, they are found at *(_st_begos).
*
* Some code depends on the size of this, since it is copied into
* RAM to make the hard disk driver happy.
*
*-
ostext:		bra	reseth		;($0)  branch to reset handler
		dc.w	version		;($2)  OS version number
		dc.l	reseth		;($4)  -> system reset handler
os_beg:		dc.l	ostext		;($8)  -> base of OS
os_end:		dc.l	endos		;($c)  -> end of OS memory usage
os_exec:	dc.l	reseth		;($10) -> default shell
os_magic:	dc.l	the_magic	;($14) -> GEM magic (or NULL)
os_date:	dc.l	date		;($18) date the system was built
os_conf:	dc.w	osconf		;($1c) configuration bits
os_dosdate:	dc.w	dosdate		;($1e) DOS-format date the system was built

*+
*  Magic variable region
*    I want to get at these someday
*	-lmd
*
*-
	.globl	_root
	.globl	kbshift
	.globl	_run

	dc.l	_root			;($20) base of GEMDOS pool
	dc.l	kbshift			;($24) -> keyboard shift-state byte
	dc.l	_run			;($28) -> current process
	dc.l	0			;($2c) reserved for future use
sizeof_hdr = *-ostext			; = size of OS header


*+
* reseth - System reset handler
*
*  Gains control of the system upon power-up reset,
*  or when the RESET button is pressed,
*  or after a really messy system crash.
*
* There is code here to reset the ACSI chip and leave it in the read state.
* This is necessary in TT to bring our clone of the 1772 out of its test
* mode.  Shouldn't hurt in non-TT settings, but I make it .if TT for
* safety.  It's only necessary for ROM systems in any case, so it's inside
* ".if systype == rom."
*-

reseth:
	move.w	#$2700,sr		; super mode, no interrupts

.if systype == rom
.if TT
	move.w	#$0100,$ffff8606.w	; reset ACSI chip...
	move.w	#$0000,$ffff8606.w	; ...leave in read state.
.endif
*+
* On Sparrow, we must read sp_config before and after reset.
* Before reset, so that no PMMU lookup is required after reset.
* After reset, so that the memory controller is configured after
* a warm boot, in case a PMMU lookup is required to decode cartbase.
*-
.if SPARROW
	move.w	sp_config,d0		; read to auto-config mem cntrlr
.endif
	reset				; reset	hardware

.if SPARROW
	move.w	sp_config,d0		; read to auto-config mem cntrlr
	move.w	#7,$ffff8940		; @TOWNS@: Added to fix problem in Sparrow
								; hardware. GPIO has no pullup/down resist.
.endif
* [ROM only]
.endif


*+
*  [ROM only]
*  Check for a diagnostic cartridge;
*  if one is inserted, load a return address
*  into A6 and jump to the cart's entry point.
*
*-
.if systype == rom
	cmp.l	#diagmagic,cartbase	; is the magic number there?
	bne	reset1			; (no)
	lea	reset1(pc),a6		; a6 ->	return address
	jmp	cartbase+4		; execute diagnostic cartridge
reset1:
.endif


*+
*  [ROM or RAM, M68030 only]
*  Clobber the cache, the VBR, the PMMU
*-
.if M68030
	move.l	#$0808,d0
	movec	d0,cacr			; invalidate & disable both caches

	moveq.l	#0,d0
	movec	d0,vbr			; zero vector-base register

	pmove	tdis,tc			; clobber PMMU
*	pmove	tdis,tt0
*	pmove	tdis,tt1
	dc.l	$f0390800,tdis		; hand-assembled because MAS
	dc.l	$f0390c00,tdis		; has bugs...
.data
tdis:	dc.l	0
.text
.endif

.if SPARROW
*
* Boot the sparrow up at 16MHz; there is little if any reason not to.
* Makes the boot, including the CRC and RAM tests, faster.
* Also set the sparrow shifter to 16MHz, and turn on address bus errors.
*
* Also, zap sparrow video for a little while here until we can set a
* "real" video mode, since it seems that the POR state of COMBEL is not
* happy with VGA monitors.
* Video is turned off by setting horz sync start to an arbitrary value
* greater than horz halfline total.
*

*	or.b	#1,st_sync	; set external sync

	move.w	#$20,sp_HSS
	move.w	#$10,sp_HHT

	or.b	#$25,sp_clock.w
.endif

*+
*  [ROM only]
*  If this is a warm reset, setup the memory
*  controller configuration register so that
*  the reset-bailout vector has something to
*  stand on ....
*
*  On TT, "warm reset" is checked in bit 0 of SCU general-purpose 
*  register 1.  The SCU regs are cleared on power up, but not by RESET.
*
*  We don't use the SCU on Mega STe, because we can't handle a bus error
*  yet (no RAM), and we want the same ROMs to work with either STe or
*  Mega STe.
*
*  On Sparrow, bit 6 of sp_clock is reset by power up.
*-
.if systype == rom

.if TT
	btst.b	#0,ttscu1		; this bit set?
	beq	reset3			; no, this is a cold boot.
.endif
.if SPARROW
	btst.b	#6,sp_clock
	beq	reset3
.endif


	lea	ret_1(pc),a6		; load return addr
	bra	val_memval		; check memory configuration validity
ret_1:	bne	reset3			; (invalid -- don't set anything up)
	move.b	memcntlr.w,memconf	; initialize memory controller
reset2:

*+
*  [still ROM only]
*  RESET bailout vector check.
*
*  This code is skipped by the test above if we determine it's a cold boot.
*
*  Check to make sure we have a clean, well-bred
*  bailout vector.  The high byte must be zero (not on M68030),
*  it must be even, and cannot be entirely zero.
*
*  NOTE THAT THE "RETURN ADDRESS" IN A6 IS FUNNY.  It points to resvchk,
*  not reset3.  Tough luck: this has to be kept for compatibility's
*  sake.  The workaround is to do this:
*
*	At init time, save the old contents of both resvector and resvalid,
*	then set resvalid to resmagic and resvector to your vector address.
*
*	When your handler is done, restore the saved contents of resvector
*	and resvalid, and then return by "jmp (a6)."  This will re-execute
*	the code below, starting at resvchk.
*	If you were the last guy in the chain, resvaild won't be resmagic 
*	any more, and this code will fall through to reset3.
*
*-
resvchk:
.if STPAD

* if STPAD, read the switches register to learn the state of top closed &
* power on.  Clobber resvalid if they are BOTH down, which is a state that
* should never happen -- this is required to get you home again if you
* install a reset vector to never-never land; you can't just turn off the
* power and wait for RAM to decay.  Note that other things (modem wake,
* alarm wake, extern wake) can bring the power bit down besides the button;
* we have to check for $FC (low two bits low, all others high) explicity.
*
* Also read the STylus button register & don't jump through resvector
* if both buttons are down.  Well, there's no STylus so this is moot.
*
* There is new code elsewhere that makes this less important: bus error etc.
* during boot vector to "coldboot."
*

	move.w	conf_switches,d0	; get conf switches & buttons.
	cmp.b	#$fc,d0			; check just top-closed and power.
	beq	resv2			; if both are down, clobber resvalid
	move.w	$d00004,d0
	and.b	#%00000110,d0		; test for both STylus buttons
	bne	resv1			; if either is up, don't clobber
resv2:
	clr.l	resvalid		; if both are down, clobber resvalid.
resv1:
.endif
	cmp.l	#resmagic,resvalid.w	; is resvalid the magic	number?
	bne	reset3			; (no)
	move.l	resvector.w,d0		; d0 = reset bailout vector
.if (M68030 == 0)
* bits 24..31 don't have to be zero on M68030!
	tst.b	resvector.w		; bits 24..31 must be zero
	bne	reset3			; (they	aren't,	so punt)
.endif
	btst	#0,d0			; the vector must be even
	bne	reset3			; (it isn't, so	punt)
	move.l	d0,a0			; a0 ->	reset handler
	lea	resvchk(pc),a6		; a6 -> WRONG RETURN ADDRESS! See note
	jmp	(a0)			; execute reset	bailout
reset3:
* [ROM only]
.endif

*+
*  Initialize PSG output ports.
*  Make ports A and B output-only;
*  initialize floppy select lines (so
*  that none are selected).
*
* bit 0: *side
* bit 1: *sel0
* bit 2: *sel1
* bit 3: *rts
* bit 4: *dtr
* bit 5: *strobe
* bit 6: *SPKR_DIS (TT,SPARROW), *IDERESET (STPAD)
* bit 7: *LAN (TT), FDD_HIDEN (STPAD), *IDERESET (SPARROW)
*
* Note: The floppy side and selects are inverted, so writing 1 disables them.
* Other outputs are initialized to zero here: *DTR, *RTS, STROBE,
* and for TT: *SPKR_DIS, *LAN; for STPAD: *IDERESET, FDD_HIDEN.
* In some cases this is the only place that initializes these values.
*-
	lea	giselect,a0		; a0 -> giselect, giwrite-2
	move.b	#7,(a0)			; set porta & portb to output
	move.b	#$c0,2(a0)
	move.b	#$e,(a0)		; select port A
	move.b	#7,2(a0)		; write %00000111


* Used to clobber DMA sound here, but we don't know yet that we have it,
* and we don't have RAM yet to catch the bus error.
* So this code has to move somewhere else, and test at runtime whether to
* nuke the DMA sound.

.if systype == rom
*+
*  [ROM only]
*  Determine 50hz or 60hz:
*  The hardware RESETs to 60hz.  Check a bit in the
*  ROM configuration byte to see if we have to twiddle
*  the hardware into 50hz mode.  According to JWT, you
*  should not do this when in vblank, so we call 'noblank'
*  which returns when it's sure we are NOT in a vblank.
*
*-
 .if TT
	move.b	#$01,syncmode		; set external sync mode always
 .else
  .if (SPARROW == 0)
	btst.b	#0,os_conf+1		; check bit: configured for 50hz?
					; MAS BUG: don't use "os_conf+1(PC)"
	beq	notpal			; (nope -- we're good ol' NTSC)
	lea	pal_r(pc),a6		; a6 -> ret addr
	bra	noblank			; make sure we're NOT in vblank
pal_r:	move.b	#$02,syncmode		; then twiddle to 50hz
  .endif
 .endif
* [ROM only]
.endif

notpal:

.if STPAD
*
* Pad is always mono and needs power control, and we want a picture early
* in the boot sequence so as not to (A) drain power, (B) possibly damage LCD,
* and (C) look bad, so we set it up here, not later as we do for other 
* machines.  So we set the shift mode & power register now, and set it
* again later when other machines' shiftmds are set.  Note that we don't
* set "shadow shadow" (the RAM variable which holds the value last written
* to the write-only register in "shadow") here, because on cold boots
* it'll be clobbered later (search for "#$400" to see where).
*
* We also read from $d00000, to clear the "conversion done" interrupt
* from the STylus touch-screen hardware.  This is as good a place to
* put that as any...
*
	move.b	#2,shiftmd		; write "mono" to shifter mode reg.
	move.b	#$80,$ffff827f		; write LCD and power control
	tst.w	$d00000			; clear "conversion done" int.
.endif

*+
*  Initialize palette registers to
*  their default values.
*-
	lea	color0,a1		; a1 ->	hardware reg
	moveq	#16-1,d0		; setup	16 colors
	lea	colors(pc),a0		; a0 ->	table of default colors
sysic1:	move.w	(a0)+,(a1)+		; copy palette assignment
	dbra	d0,sysic1		; (loop for more colors)

.if SPARROW
* Also initialize Sparrow palette
* a0 now points to spcolors (right after colors)

	move.b	#0,sp_shift		; hit the Sparrow shifter
	lea	sp_color0,a1		; initialize the 1st 16 colors
	moveq	#16-1,d0
spsic1:	move.l	(a0)+,(a1)+
	dbra	d0,spsic1
	move.b	#0,shiftmd		; hit the ST shifter
.endif

.if systype == rom
*+
*  [ROM only]
*  Put the screen (temporarily)
*  at $10000, so the icon-drawing routines won't
*  blow away any system variables.
*-
	move.b	#$01,dbaseh	; set high ptr
	clr.b	dbasel		; set low ptr
* On STe and TT, low byte is cleared automatically when others are written.

*+
*  [still ROM based system]
*  Determine how much memory there is, and initialize
*  the memory controller configuration register.
*
*  Algorithm from Jim Tittsler, Art Morgan, et al.
*  but shamelessly modified for the hell of it.
*
*  The bottom 1K of memory is only touched on the first RESET,
*  to size memory and setup the memory controller.  The first 1K
*  is never cleared.
*
*  If not TT, this uses val_memval to check for cold/warm boot.
*  If TT, uses that but also the low bit of SCU general register 1.
*
* The assembly-time conditionals here go as follows:
*
*	if !TT
*	  if SPARROW
*	    (read config switches to auto-config mem controller)
*	    (check for warm/cold; if warm, goto reset4)
*	    (size memory from switches into d5)
*	    (goto mem_sized)
*	  else
*           (get memory controller conf. from RAM; if valid, goto reset4)
*	    if STPAD
*	      (write memconf, d6, d5; fall through)
*	    else
*	      (size memory for ST/STe, write memconf, fall through)
*           endif
*	  endif
*       else
*	  (size memory for TT, write memconf, fall through)
*       endif
*       (lea $8000,sp)
*       (size memory by probing)
*     mem_sized:
*	(clear from $400 to d5)
*	(set memcntrlr from d6 (if not sparrow), phystop from d5)
*	(set memvalid etc. to indicate warm boot)
*       if TT
*	  (size TT RAM)
*	  (write d5 to _ramtop, validate ramvalid, set bit in ttscu1)
*	else
*	  (set _ramtop to "none", validate ramvalid)
*	endif
*
*     reset4:
*
* SPARROW: a read from $FFFF8006 (byte or word) auto-configs the memory 
* controller, and tells other things besides: the byte at 8006 (or the high
* byte of the word there) yields:
*
* vvmm rrbf
*         f  # DRAM wait states
*        b-  16(0) or 32(1) bit video bus
*      rr--  # ROM wait states (0-2, 3 resvd)
*   mm ----  DRAM size
*   00 = 256K parts
*   01 = 1M parts
*   10 = 4M parts
*   11 (reserved)
* vv-- ----  monitor type
* 00 = ST mono
* 01 = ST color
* 10 = VGA
* 11 = TV
*
* vv is not used by the memory configuration, but is used to set the
* master video control register.  Taking mmb as a three-bit number,
* you get memory size in bytes using ((512*1024) << mmb), but clamp
* to 14MB max.
*
*-
.if (TT == 0)

.if SPARROW
	bset.b	#6,sp_clock		; test and set power-fail bit
	beq	sp_cold			; yes, cold-boot
	cmp.l	#memmagic,memvalid.w	; check first magic number
	bne	sp_cold			; no - this is a cold boot
	cmp.l	#memmag2,memval2.w	; check again (for paranoia)
	bne	sp_cold			; no - this is a cold boot
	cmp.l	#memmag3,memval3.w	; check again
	beq	reset4			; ok - warm boot.

* On Sparrow, detected cold boot.  So determine memory size.
* Take mmb as a number; phystop is 512KB << mmb clamped to 14MB maximum.
sp_cold:
	move.w	sp_config,d0	; read again just for fun
	lsr.w	#8,d0		; get switches in low word: d0=vvmmrrbf
	lsr.b	#1,d0		; d0=0vvmmrrb
	move.b	d0,d1
	and.b	#1,d1		; just keep low bit -- d1=b
	lsr.b	#2,d0		; d0=000vvmmr
	and.b	#6,d0		; d0=00000mm0
	or.b	d0,d1		; d1=00000mmb
	move.l	#$80000,d0	; 512KB
	asl.l	d1,d0		; 512K << d1 is the memory size
	cmp.b	#5,d1		; unless mmb was 5
	bne	gotmem		; (no)
	move.l	#1024*1024*14,d0	; ...in which case we cap at 14MB.
gotmem:	move.l	d0,d5		; d5 is phystop

** end of Sparrow clause; we jump to "clear memory from $400 to..." **
*	bra	mem_sized

.else
* (TT == 0) && (SPARROW == 0)

	move.b	memcntlr.w,d6		; d6 = memory controller configuration
	move.b	d6,memconf		; program memory controller with this
					; just in case it's valid
	move.l	phystop.w,d5		; d5 ->	(possible) top of physical mem
	lea	ret_2(pc),a6		; load return address
	bra	val_memval		; get memory controller validation
ret_2:	beq	reset4			; already sized -- don't size or test

.if STPAD

* STPAD memory sizing is different: memory controller config value is
* always $a, and we have either 1MB or 4MB.  In a 1MB machine, the second
* MB is a shadow of the first, but the 3rd and 4th don't respond at all.

	move.b	#$0a,d6
	move.b	d6,memconf
	move.l	#$00400000,d5		; pre-load for 4MB
	move.l	#$06161964,d0
	move.l	#$03251987,d1
	move.l	d0,$00300010		; write a magic number to 3rd MB
	move.l	d1,$00300014		; and another one
	cmp.l	$00300010,d0		; still there?
	bne	pad_small		; nope, you're small
	cmp.l	$00300014,d1		; also still there?
	beq	pad_big			; yes - you're big (so d5 is fine)
pad_small:
	move.l	#$100000,d5		; we have 1MB
pad_big:

* STPAD sizing done, size is in d5

.else
*--- init vars + hardware:
	clr.w	d6			; d6 = configuration byte
	move.b	#$0a,memconf		; setup	controller for 2Mb/2Mb

*--- write test-pattern to both banks:
	move.w	#8,a0			; a0 -> bank0 (skip ROM shadow)
	lea	bank1+8,a1		; a1 -> bank1
	clr.w	d0			; d0 = start of	pattern
fmem1:	move.w	d0,(a0)+		; write	to bank 0
	move.w	d0,(a1)+		; write	to bank 1
	add.w	#$fa54,d0		; bump pattern with a magic number
	cmp.l	#$200,a0		; filled $200 bytes?
	bne	fmem1			; (no, loop)

*+
* Determine size of both banks
* from test-pattern signatures.
*-

* STPLUS is just like ST except the shadows are at different places.
* If a shadow appears at the first shadow place, you know you have small
* parts.  If one appears at the second place, you have medium parts.
* If neither shadow appears, but the pattern took in the first place,
* you have big parts.
*
* Starting with 9/91 ROMs, ST and STPLUS are the same thing, so
* we do this at run time instead of compile time.  "shadow" used
* to be an assembly-time constant, now it's in d7.
*
* We detect ST-vs-STe by seeing if the high 7 bits of dbasell are RAM.
* If so then we're an STe.
*

	move.b	#$5a,dbasell		; see if dbasell is RAM
	tst.b	dbasel			; read another register to destroy
					; capacitance effects; dbasel is 00.
	move.b	dbasell,d0		; read; don't say cmp.b because that
					; would put $5a on the bus.
	cmp.b	#$5a,d0			; NOW cmp.b
	bne	memST

	clr.b	dbasell			; try the test again using zero
	tst.w	color0			; color0 is $FFF
	tst.b	dbasell			; read back - should be zero.
	bne	memST

; OK, dbasell holds its value: you're an STe.

	move.l	#$40000,d7		; set shadow to $40000 for STe
	bra	gotshadow

memST:	move.l	#$200,d7		; set shadow to $200 for ST

gotshadow:

	move.l	#bank1,d1		; d1 = bank offset (start with bank 1)
mem1:	lsr.w	#2,d6			; (shift bank1's size into position)
	move.l	d7,a0
	addq.l	#8,a0			; (compare at shadow+8)
	lea	memr1(pc),a4		; a4 ->	return addr
	bra	memchk			; (check the pattern)
memr1:	beq	mem4			; yes -- small parts
	move.l	d7,a0
	add.l	d7,a0
	addq.l	#8,a0			; (compare at shadow*2+8)
	lea	memr2(pc),a4		; a4 ->	return addr
	bra	memchk			; (check it)
memr2:	beq	mem3			; yes -- medium parts
	move.w	#8,a0			; pattern matches at $8? (ANY parts?)
	lea	memr3(pc),a4		; a4 ->	return addr
	bra	memchk			; (attempt match)
memr3:	bne	mem4			; no --	nothing	in this	bank
	addq.w	#4,d6			; adjust config	byte for big parts
mem3:	addq.w	#4,d6			; adjust config	byte for medium parts
mem4:	sub.l	#bank1,d1		; decrement bank number
	beq	mem1			; repeat check for bank	0
	move.b	d6,memconf		; setup	memory controller

* end of not-stpad clause
.endif
* end of not-sparrow clause
.endif
.else

* TT memory sizing
*
* TT memory controller possibilities:
*	(256Kx4 (=2M) onboard)
*	(256Kx4 onboard) plus (256Kx4 add-on)
*	(256Kx4 onboard strapped at 8M) plus (1Mx4 (=8M) add-on at 0)
*	(1Mx4 onboard)
*	(1Mx4 onboard) plus 256Kx4 strapped at 8M (total 10M) (?)
*
* To quote JWT:
* The algorithm used to set the TT MCU configuration is similar in
* concept to the one used in the ST series, but different in details.
*
* The TT master MCU can be configured to use either 256K or 1M deep
* parts.  To figure out which are actually installed on your board, you
* can:
* 	1) consult a calendar  (1Mx4 DRAMs are not expected in
* 	   production for at _least_ a year  :-)
* 	2) a) set the memory controller for 1M parts
* 	      (i.e. write 0x000a to 0xFFFF8000)
*            b) write a known pattern to RAM
*            c) look for the pattern to be repeated in RAM as though
*               A12 were a don't care:
*               (e.g. write a pattern starting at address 0x00000008,
* 		see if it can be read back from 0x00001008)
* 	      IF there is a repeat
*               THEN you have 256K parts; reset the memory controller
*                 (i.e. write 0x0005 to 0xFFFF8000)
*               ELSE you really do have 1M parts
*
* Routine notes: at the .endif, d5 must hold phystop, and d6 must hold
* the value to put in memconf and memcntlr.
*

	btst.b	#0,ttscu1		; bit is clear for cold boot
	beq	mt_cold			; definitely a cold boot

	move.b	memcntlr.w,d6		; might be warm boot...
	move.l	phystop.w,d5
	lea.l	ret_2(pc),a6
	bra	val_memval
ret_2:	beq	reset4			; already sized; don't size or test.

mt_cold:
	move.w	#$5,d6			; init d6 for small parts
	move.b	#$a,memconf		; but mem cntlr for big
	moveq	#0,d0
	move.l	d0,$1008		; clear space first so pattern
	move.l	d0,$100c		; doesn't "happen" to be there
	move.l	#$06161964,d0
	move.l	d0,$8			; write pattern
	cmp.l	$1008,d0		; shadowed here?
	bne	mt_big			; no, definitely big parts
	move.l	#$04251987,d0
	move.l	d0,$c			; try a different pattern & addr
	cmp.l	$100c,d0		; shadowed here?
	beq	mt_done			; yes - definitely small parts
mt_big:
	move.w	#$a,d6			; not shadowed: big parts.
mt_done:
	move.b	d6,memconf

.endif

*+
*  Determine memory size (once we've setup the memory controller) by
*  probing successive locations until something breaks.  Either we get a
*  bus error (for a non-existent controller) or the pattern we write won't
*  read back correctly (non-existent bank on a controller that works).
*
*  This will handle both the 2119 and 4002 memory controllers.  ("Parts iz
*  parts, ey?")
*
*  STPAD doesn't need this - d5 is already one MB (its size) and d6 is
*  already $a (the memory config value).
*
*  SPARROW also doesn't need this.
*-
.if (SPARROW == 0)
	lea	$8000,sp		; initialize SP just this once
.if (STPAD == 0)
	move.l	8,a4			; a4 = old BUS ERROR vector
	lea	mt_q(pc),a0		; steal BUS ERROR vector
	move.l	a0,8			; to catch non-existant controllers
	move.w	#$fb55,d3		; d3 = a nice random number
	move.l	#$20000,d7		; d7 = 128K
	move.l	d7,a0			; a0 -> first location to probe

mt_1:	move.l	a0,a1			; a1 -> end of RAM (as we know it)
	move.w	d0,d2			; d2 = copy of random #
	moveq	#42,d1			; d1 = # words to stuff
mt_2:	move.w	d2,-(a1)		; stuff a word (or get a BUS ERROR)
	add.w	d3,d2			; generate new random #
	dbra	d1,mt_2			; (stuff more words)

	move.l	a0,a1			; a1 -> end of RAM (as we knew it)
	moveq	#42,d1			; d1 = # words to check
mt_3:	cmp.w	-(a1),d0		; compare word in RAM with ours
	bne	mt_q			; no match: bad bank (we quit)
	clr.w	(a1)			; be tidy, clear out cruft
	add.w	d3,d0			; generate next random #
	dbra	d1,mt_3			; (check more words)

	add.l	d7,a0			; bump up 128K
	bra	mt_1			; check some more

mt_q:	sub.l	d7,a0			; drop down to last successful probe
	move.l	a0,d5			; d5 -> end of RAM (as we know it)
	move.l	a4,8			; restore BUS ERROR vector

* end of if (STPAD == 0)
.endif

* end of if (SPARROW == 0)
.endif

*+
*  [still ROM only]
*  Clear memory from $400 to 'd5' (phystop). Used to put screen at phystop
*  - screen size and clear from top down. Now leaves screen where it is (at
*  64K) and clears from bottom up, so screen still clears early on. Must
*  preserve d5 = phystop and d6 = mem controller program byte.
*
*  I tried clearing only the first meg or so here, but sadly, discovered
*  that *ALL* of memory must be cleared here.  Apparently, other parts
*  of the OS stupidly require it to be clear when they Malloc stuff.
*  So, we'll still clear it all, but we'll do it real fast.
*-
mem_sized:
	lea	$400.w,a4	; start at the bottom
	move.l	d5,d4		; end at the top
	sub.l	a4,d4		; size
	lsr.l	#8,d4		; / 256 = chunk count (good to 16Mb)
	subq.l	#1,d4		; dbra count
	lea	512.w,a5	; leapfrog count
	moveq	#0,d0		; clear 32 bytes worth of regs
	move.l	d0,a0
	moveq	#0,d1
	move.l	d1,a1
	moveq	#0,d2
	move.l	d2,a2
	moveq	#0,d3
	move.l	d3,a3
	lea	256(a4),a4
clm_1:	movem.l	d0-d3/a0-a3,-(a4)   ; clear 32 bytes
	movem.l	d0-d3/a0-a3,-(a4)   ; clear 32 bytes
	movem.l	d0-d3/a0-a3,-(a4)   ; clear 32 bytes
	movem.l	d0-d3/a0-a3,-(a4)   ; clear 32 bytes
	movem.l	d0-d3/a0-a3,-(a4)   ; clear 32 bytes
	movem.l	d0-d3/a0-a3,-(a4)   ; clear 32 bytes
	movem.l	d0-d3/a0-a3,-(a4)   ; clear 32 bytes
	movem.l	d0-d3/a0-a3,-(a4)   ; clear 32 bytes
	adda.l	a5,a4		    ; leapfrog area just cleared
	dbra	d4,clm_1

*+
*  Set the system variables memcntlr and phystop. Also set the magic values
*  in the validation variables. On TT, of course, this isn't enough: we
*  aren't done until fast RAM is sized, then we set bit 0 of SCU general
*  register 1.
*-
.if (SPARROW == 0)
	move.b	d6,memcntlr.w		; save configuration byte
.endif
	move.l	d5,phystop.w		; save physical top-of-memory

	move.l	#memmagic,memvalid.w	; indicate memory was configured
	move.l	#memmag2,memval2.w	; ditto (paranoia variable)
	move.l	#memmag3,memval3.w	; ditto (paranoia extraordinaria)

.if TT

*+
* [still ROM only]
*
* Now size primary RAM.  What? You thought ST RAM was primary RAM? On the
* contrary: that's dual-purpose, slow, compatibility-mode RAM.  Primary RAM
* starts at $01000000 and is contiguous from there.  The first N bytes of
* it (N>=0) is fast, nybble-mode RAM.  The rest of it is on the VME bus. 
* The VME bus and the RAM you put there is jumpered to start at
* $01000000+N.  Alas, there's no way to tell what N is.
*
* Now that fast RAM is refreshing properly, all I need to do is size the
* fast+VME RAM which starts at $01000000.  I'll check on 128K boundaries,
* just for grins and so I can steal code from above.  First bus error or
* compare error and you're out.
*-

	move.l	#mt_p0,$8		; set bus error vector
	move.w	#0,refresh		; set refresh rate (causes berr)
mt_p0:

	move.l	#mt_pq,$8		; BUS ERROR to catch missing cntrlrs
	move.w	#$fb55,d3		; d3 = a nice random number
	moveq.l	#0,d0			; random number seed
	move.l	#$20000,d7		; d7 = 128K
	move.l	#$01020000,a0		; a0 -> first location to probe

mt_p1:	move.l	a0,a1			; a1 -> end of RAM (as we know it)
	move.w	d0,d2			; d2 = copy of random #
	moveq	#42,d1			; d1 = # words to stuff
mt_p2:	move.w	d2,-(a1)		; stuff a word (or get a BUS ERROR)
	add.w	d3,d2			; generate new random #
	dbra	d1,mt_p2		; (stuff more words)

	move.l	a0,a1			; a1 -> end of RAM (as we knew it)
	moveq	#42,d1			; d1 = # words to check
mt_p3:	cmp.w	-(a1),d0		; compare word in RAM with ours
	bne	mt_pq			; no match: bad bank (we quit)
	clr.w	(a1)			; be tidy, clear out cruft
	add.w	d3,d0			; generate next random #
	dbra	d1,mt_p3		; (check more words)

	add.l	d7,a0			; bump up 128K
	bra	mt_p1			; check some more

mt_pq:	sub.l	d7,a0			; drop down to last successful probe
	cmp.l	#$01000000,a0		; was there any RAM at all?
	bne	mt_pr			; yes - fine.
	clr.l	a0			; no - set ramtop to zero.
mt_pr:
	move.l	a0,d5			; d5 -> end of RAM (as we know it)

*
* Now that d5 holds the end address of primary RAM, put it someplace
* useful.  I've chosen the next available system variable, which is
* at $5a4, and called it _ramtop: there's RAM from $01000000 to there.
* A zero there means there's no RAM there at all (and it's zero on
* non-TT ST's, of course).
*

	move.l	d5,_ramtop.w		; store ramtop value
	move.l	#rammagic,_ramvalid.w	; mark as valid

* validate next reset as warm, not cold.

	bset.b	#0,ttscu1

.else

* not TT: set the fast-RAM system variables to indicate "no fast RAM"

	clr.l	_ramtop			; store zero value: no fast RAM
	move.l	#rammagic,_ramvalid.w	; mark as valid
.endif

*
* end of .if systype == rom for memory sizing
*

.endif

*
* reset4 is the target when memory has already been sized and the memory
* controller programmed.  This can happen on a warm boot or on startup
* of a RAM-loaded system.  On TT, getting here means fast RAM is good,
* too.
*
* SSP is set here, because on a warm boot this might be the first time.
*
* We set bus error, address error, and illegal instruction to vector
* to coldboot, because these are the most likely things to have happen
* if some system variable is garbage in an otherwise-warmbooting
* machine.  The hope is that the cold boot will wipe out the offending
* system variable and get you back on the air. Especially important
* for ST BOOK, where you can't just turn off the power.
*

reset4:
	move.l	#_supstk+supsiz,sp	; setup SSP now

*+
*  Initialize interrupt vectors
*
* This was much lower in the boot cycle but I've moved it here because
* we want exceptions during boot to vector to coldboot.
*
* First, all exceptions are vectored to "coldboot."  Then some exceptions
* are vectored to appropriate places: trap 2, Divide-by-zero, and NMI are
* pointed at an RTE, other traps point to their handlers, etc.
*
* Later on (search for "bloop:") we vector those exceptions that still
* point to 'coldboot' so they point to the bomb handler '_term' instead.
*
* We set all these exceptions to vector to 'coldboot' on the theory that a
* bus error while TOS is booting is A Bad Thing.  The theory is that  the
* cold boot will fix whatever went wrong, like a bogus address in resvector
* or some other system variable.  (Well, actually, a bogus resvector will
* have been taken before now, but you know what I mean.)
*-
	lea	_rte(pc),a3		; a3 -> handy RTE
	lea	_rts(pc),a4		; a4 -> handy RTS

*--- set up all vectors to coldboot (in bios.s):

	lea	coldboot,a1		; a1 -> coldboot
	lea	$8,a0			; a0 -> interrupt RAM
	move.w	#64-1,d0		; d0 = count
sei1:	move.l	a1,(a0)+		; write vector
	dbra	d0,sei1			; (loop to write more vectors)

* Divide by zero -> RTE.

	move.l	a3,$14			; divide-by-zero vector -> rte

* Vector NMI to RTE: it's possible to get NMI on STPAD when the
* battery is low, but it's also possible that the threshholds are
* not correct, so in the boot sequence we "disable" NMI.  Bombs
* are never a good response to NMI, so anything that actually uses
* it will install a vector.

	move.l	a3,$7c			; NMI -> RTE

*--- point vectored interrupts at RTEs
sei2:	moveq	#7-1,d0			; d0 = DBRA count
	lea	$64,a1			; a1 -> first slot
sei3:	move.l	#_rte,(a1)+		; point interrupt at RTE
	dbra	d0,sei3			; ... and loop for all 7

*--- install OS interrupt vectors:
	move.l	#vbl,$70		; vblank handler
	move.l	#hbl,$68		; hblank handler
	move.l	a3,$88			; (empty) trap#2 handler
	move.l	#trp13h,$b4		; trap #13 handler
	move.l	#trp14h,$b8		; trap #14 handler
	move.l	#line1010,$28		; line 1010 handler
	move.l	a4,etv_timer.w		; default timer-tick vector -> rts
	move.l	#_critich,etv_critic.w 	; default critical error handler
	move.l	a4,etv_term.w		; default terminate vector -> rts

*+
*  Setup the vblank deferred vector list.
*  (This data structure is ugly,
*   but we seem to be stuck with it).
*
*-
	lea	_vbl_list.w,a0		; a0 -> default list of vbl locs
	move.l	a0,_vblqueue.w		; install ptr to them
	move.w	#dnvbls-1,d0		; clear vbl vectors
avbl:	clr.l	(a0)+			;	one at a time
	dbra	d0,avbl

*+
*  Initialize soft vectors for character devices.  The
*  vectors have been moved into RAM to make it possible
*  to efficiently intercept them later on.
*
*  This only happens in TOS 1.2 and later.  On TT with Bconmap,
*  the vectors for device 1 (the mappable one) get (re-)written
*  by mapinit, which is called by initmfp.
*-

	lea	CHRDEVTAB,a0		; a0 -> routines
	move.w	#xconstat,a1		; a1 -> RAM vectors

	moveq	#(4*8)-1,d0		; = #vectors to install
chdev1:	move.l	(a0)+,(a1)+
	dbra	d0,chdev1

*+
* Initialize the SCU to enable interrupts etc.
* This code runs on all machines; on machines with no SCU
* you get a bus error and bail out right away.
*
* Sparrow note: ttscu doesn't exist, and the system hangs when you touch it.
*-

	move.l	$8,a0
	move.l	sp,a1
	move.l	#scuberr,$8
.if (SPARROW == 0)
	move.b	#$40,ttvmeimsk		; enable int priority 6
	move.b	#$14,ttsysimsk		; enable int priorities 2, 4
.endif

scuberr:
	move.l	a0,$8
	move.l	a1,sp

.if SPARROW
*
* Transfer the sparrow config value to the corresponding bits in VMC (video
* master control): VVmmrrBf goes into BhvcesVV in VMC.
* 
* Also, don't touch ST color palette because that puts us in ST video mode.
* and we don't know yet whether we're VGA.
*

	move.b	sp_config,d0	; d0=vvmmrrbf
	move.b	d0,d1		; d1=vvmmrrbf
	lsl.b	#6,d1		; d1=bf000000
	and.b	#$80,d1		; d1=b0000000
	lsr.b	#6,d0		; d0=000000vv
	or.b	d0,d1		; d1=b00000vv
	move.w	d1,sp_VMC	; write to VMC.
*	tst.w	color0
.endif

* Zap the DMA sound controller, if you have DMA sound in this machine.  You
* can't tell that without probing for it, though, which is why we do it
* here instead of anywhere earlier: you need good RAM for catching the bus
* error.
*
* The _hasdmasnd flag actually means "MONOMON on GPIP bit 7 is XORed with
* the DMASND IRQ signal, and you have to worry about this when you futz
* with MONOMON in VBLANK."  STPAD will DTACK (i.e. no bus error) at the
* controller address, but it doesn't really have DMA sound, so that part
* is an assembly-time conditional.
*
* Monomon matters for sparrow, too, because it has the same monitor-detect
* logic as STe.  Volume/tone used to matter for sparrow, but they took
* it out, so it's gone from here as well.
*

.if SPARROW
	st	_hasdmasnd	; Sparrow always has DMA Sound, never vol/tone
.else
	clr.b	_hasdmasnd	; pre-clear the variable

.if (STPAD == 0)
    	move.l	sp,a6		; save away the stack pointer
	move.l	$8,a5		; and bus error vector
	move.l	#nodmasnd,$8	; set bus error vector
	clr.w	dmasndc		; reset sound chip, bus error if missing
	st	_hasdmasnd	; no bus error; set the flag

* program the volume/tone controller for a sane volume & tone, and
* mix the GI sound in with the DMA sound so it comes out the speaker.

	lea.l	vtpgm(pc),a0
	move.w	(a0)+,d1	; get into a reg for sparrow
	move.w	d1,mwmask
	bra	vtend

* data for the MicroWire interface...  The low high bit is set for
* each of these so we can tell when it's shifted completely out.

*		  addr  cmd  data   lobit
vtpgm:	dc.w	($0600+$01ff)*2		; mask for all cmds
	dc.w	($0400+$00c0+$28)*2+1	; max master volume
	dc.w	($0400+$0140+$14)*2+1	; max left channel volume
	dc.w	($0400+$0100+$14)*2+1	; max right channel volume
	dc.w	($0400+$0080+$06)*2+1	; flat treble
	dc.w	($0400+$0040+$06)*2+1	; flat bass
	dc.w	($0400+$0000+$01)*2+1	; mix GI sound with DMA sound
	dc.w	$0			; end of this list

vtloop:	move.w	d0,mwdata		; write data
vtwait:	tst.w	mwdata			; wait for data == 0
	bne	vtwait
vtend:	move.w	(a0)+,d0
	bne	vtloop

nodmasnd:
	move.l	a6,sp			; restore SP in case of bus error.
	move.l	a5,$8
.endif
.endif

* Set the variable "I am an ST." For STPAD, no.  For TT, no.  For Sparrow,
* no.  Otherwise, in the ST/STe case, check to see if the low byte video
* address register (dbasell) is RAM.  This is a repeat of the test we did
* to determine the shadow addresses for memory sizing; see that code for
* comments.

.if (TT | STPAD | SPARROW)
	sf	_iamanst
.else
	move.b	#$5a,dbasell		; see if dbasell is RAM
	tst.b	dbasel			; read another register to destroy
					; capacitance effects; dbasel is 00.
	move.b	dbasell,d0		; read; don't say cmp.b because that
					; would put $5a on the bus.
	cmp.b	#$5a,d0			; NOW cmp.b
	bne	iset

	clr.b	dbasell			; try the test again using zero
	tst.w	color0			; color0 is $FFF; read to zap the bus
	tst.b	dbasell			; read back - should be zero.
iset:	sne	_iamanst		; if NE, you're an ST.

.endif

*+
*  Clear the memory used by the rest of BIOS, GEMDOS, and AES/VDI.
*  GEMDOS and AES/VDI expect their BSSes to be clear when they start.
*
*  In this file there's a symbol, endosbss, which marks the end
*  of the system variable region.  Since some of these variables
*  are initialized already, and others should not be cleared for
*  historical reasons, the "BSS clearing" portion of our program
*  starts after this point.
*
*  TOS builds include a symbol, endaesbss, which is the last RAM address
*  used anywhere in the OS.  For a RAM TOS, that's not the one we want:
*  it includes the OS itself.  In a RAM TOS, we use ostext, which is the
*  FIRST symbol of the TEXT segment.
*
*-
.if systype == rom
	move.l	#endaesbss,a1		; a1 -> end (true end of BSS segment)
.else
	lea.l	ostext(PC),a1
.endif
	move.l	#endosbss,a0		; a0 -> start (after system vars)
	moveq	#0,d0			; quick zero
clrm_1:	move.w	d0,(a0)+		; clobber a word
	cmp.l	a0,a1			; at end?
	bne	clrm_1			; (no -- loop for more words)

.if M68030
*+
*  [M68030 only]
*  Initialize the PMMU to implement the cache disable bit.
*  Set mmusetup for details on this.
*
*  This has to run after clearing BSS memory.
*-

	bsr	mmusetup
.endif

*+
*  Setup display base,
*  clear display memory.
*
*  If TT, we allow an extra 256 bytes after the screen, before the end
*  of memory.  The reasoning is bogus: it makes some stupid programs
*  run better, and makes SCSI DMA work.  If you DMA right up to the 
*  end of memory, the controller reports a bus error because it prefetched
*  too far.  Second, many double-buffering programs (read games) 
*  only know about the two middle bytes of the screen address, and don't
*  use the Setscreen call, which writes all three.  They think they
*  need to align their screens on 256-byte boundaries, so the low byte
*  of the address is zero.  
*
*  Backing off by 256 bytes means the defualt low byte is zero, and the
*  screen doesn't abut the end of memory, so this solves both problems.
*
*  On Sparrow, this doesn't matter much, because the screen is realloc'ed
*  after initializing GEMDOS.
*-
	move.l	phystop.w,a0		; video_base = phystop - 0x8000
.if TT
	sub.l	#$25900,a0		; One TT screen plus $100 bytes.
	move.w	#$2590-1,d1		; clear d1*16 bytes
.else
	sub.l	#$8000,a0
	move.w	#$800-1,d1		; d1 = # 16-byte chunks to zero
.endif
	move.l	a0,_v_bas_ad.w
	move.b	_v_bas_ad+1.w,dbaseh	; load high addr
	move.b	_v_bas_ad+2.w,dbasel	; load low (really, medium) addr
* assume v_bas_ad ends with 00.  Writing dbaseh or dbasel zeros dbasell.
*	move.b	_v_bas_ad+3.w,dbasell	; (don't need to) load lo byte addr

	moveq	#0,d0
clrm_2:	move.l	d0,(a0)+		; zero a longword
	move.l	d0,(a0)+		; zero a longword
	move.l	d0,(a0)+		; zero a longword
	move.l	d0,(a0)+		; zero a longword
	dbra	d1,clrm_2		; (loop for more longwords)

*+
*  Initialize all kinds of OS variables
*
*-

*--- OS parameters:
	move.l	os_magic(pc),a0		; get pointer to magic
	cmp.l	#$87654321,(a0)		; is the magic there?
	beq	usem			; yes -- use numbers there
	lea	os_end-4,a0		; no, use default numbers
					; MAS BUG: don't use "os_end-4(PC)"
usem:	move.l	4(a0),end_os.w		; init end-of-OS pointer
	move.l	8(a0),exec_os.w		; init default-shell pointer

*--- Disk vectors:
	move.l	#_dskinit,hdv_init.w	; initialization
	move.l	#_rwabs,hdv_rw.w	; read/write absolute sectors
	move.l	#_getbpb,hdv_bpb.w	; get BIOS parameter block
	move.l	#_mediach,hdv_mediach.w ; media change inquiry
	move.l	#_boot,hdv_boot.w	; boot-from-device

*--- Prtblk vectors:
	move.l	#_lstostat,prv_lsto.w
	move.l	#_lstout,prv_lst.w
	move.l	#_auxostat,prv_auxo.w
	move.l	#_auxout,prv_aux.w

*--- Randoms:
	move.l	#_scrdmp,scr_dump.w	; screen-dump vector
	move.l	_v_bas_ad.w,_memtop.w 	; _memtop = _v_bas_ad
	move.l	end_os.w,_membot.w	; set bottom of memory (for DOS)
	move.w	#dnvbls,nvbls.w		; default number of vbl queue entries
	st	_fverify.w		; enable write-verify
	move.w	#df_seek,seekrate.w	; set default seek-rate
	move.l	#_diskbuf,_dskbufp.w	; setup pointer to disk buffer
	move.w	#-1,_prtcnt.w		; initialize print-count
	move.l	#ostext,_sysbase.w	; -> base of OS
	move.l	#savend,savptr.w	; register-save pointer for traps 13&14
	move.l	#_rts,swv_vec.w		; ignore monitor changes for now
	clr.l	_drvbits.w		; clobber "drive-alive" bits
.if systype == ram
	clr.w	_bootdev.w		; clear bootdev
.endif
*
* clear of bootdev backed out 11/2/88 AKP because it prevents tricks
* like bootable RAMdisks.  The no-change lobby wins this time.
*
* Ah, but put back in for RAM TOSes, because otherwise the floppy's
* AUTO folder isn't run when you warm boot with a RAM TOS.
*
	move.l	#def_bell,bell_hook.w	; init def bell handler
	move.l	#def_click,kcl_hook.w	; init def keyclick handler

.if systype == rom
	bsr	copy_header		; kludge OS ROM header
.endif

*+
* Initialize the cookie jar.
*
* This code used to rely on assembly-time conditionals to distinguish ST
* from STe, but now it doesn't.  Instead it relies on the variable
* "_iamanst" which is nonzero if you're an ST.
*-

*+
*
*	_CPU:	680[xx] (00, 10, 20, 30 decimal)
*
*	_MCH:
*		00000000 or nonexistent is ST or Mega ST.
*		00010000 	STe (none of the below variants)
*		    0001	STBOOK/STylus (.if STPAD)
*		    0008	STe/AT (if IDE bus exists)
*		    0010	Mega STe (if SCU exists)
*		00020000	TT (if TT)
*		00030000	Sparrow (.if SPARROW)
*
*	_VDO:
*		00000000 or nonexistent is ST or Mega ST.
*		00010000 is STe
*		00010001 is STBook (STPAD)
*		00020000 is TT
*		00030000 is Sparrow
*-

	lea	defcookies,a0
	move.l	a0,_p_cookie.w

*
* The 68020 user's manual says "unimplemented bits are read as zeroes"
* for the movec instruction, so I use the freeze bit of the data cache
* to probe for the difference between 68020 (which doesn't have a
* data cache) and a 68030 (which does).
*

	move.l	#"_CPU",(a0)+	; probe for CPU type
	moveq.l	#0,d1		; set cpu type == 68000
	move.w	#$10,a2		; vector being used is now illegal-instruction
	move.l	(a2),a3		; save old illegal instruction vector
	move.l	a7,a1		; save ssp
	move.l	#ill_1,(a2)	; game's over after first exception
	move	ccr,d0		; illegal on 68000
	moveq.l	#10,d1		; no exception; 68010 at least
	extb.l	d0		; illegal on 68010
	moveq.l	#20,d1		; no exception; 68020 at least
	movec	cacr,d0		; see if the data cache exists
	bset	#9,d0		; set freeze bit for data cache
	movec	d0,cacr
	movec	cacr,d0		; read it back
	bclr	#9,d0		; test and clear - bit still set?
	beq	cpunot30	; no - it's a 20
	moveq.l	#30,d1		; was still set - it's a 30
	movec	d0,cacr		; (un-freeze data cache)

cpunot30:
ill_1:	move.l	a1,a7		; restore old ssp
	move.l	a3,(a2)		; restore old exception vector
	move.l	d1,(a0)+	; write CPU type in cookie jar
	sne	_longframe+1.w	; and, incidentally, set longframe, too.

.if TT
	move.l	#"_VDO",(a0)+
	move.l	#$00020000,(a0)+
	move.l	#"_MCH",(a0)+
	move.l	#$00020000,(a0)+
.else
.if STPAD
* STPAD is one kind of STPLUS -- if we're that kind, use those values,

	move.l	#"_VDO",(a0)+
	move.l	#$00010001,(a0)+	; STe video w/minor 01 saying STPad.
	move.l	#"_MCH",(a0)+
	move.l	#$00010001,(a0)+	; machine is STe w/minor 01
.else
.if SPARROW
	move.l	#$00030000,d0
	move.b	$ff9201,d1
	btst	#4,d1
	bne	sparcook
	or.w	#1,d0			; minor 1 when bit 4 of $ff9201 is clear
sparcook:
	move.l	#"_VDO",(a0)+
	move.l	d0,(a0)+		; Sparrow video
	move.l	#"_MCH",(a0)+
	move.l	d0,(a0)+		; Sparrow machine
.else
* else decide what kind of ST/STPLUS we are: ST, STe, Mega STe, and STe-PLUS.
	tst.b	_iamanst
	beq	pickste
	move.l	#"_VDO",(a0)+
	clr.l	(a0)+
	move.l	#"_MCH",(a0)+
	clr.l	(a0)+
	bra	cdone1

pickste:
* OK, not an ST; definitely STe video then.
	move.l	#"_VDO",(a0)+
	move.l	#$00010000,(a0)+	; STE video

* distinguish STPLUS from Mega STe by using ttscu1: if bus error,
* it's STPLUS, else it's Mega STe.

	move.l	#$00010000,d0		; load d0 for normal STe
	move.l	$8,a1
	move.l	sp,a2
	move.l	#nomste,$8
	tst.b	ttscu1
	move.w	#$0010,d0		; no bus error: set Mega STe lo word
	bra	gotmch

* Get here on bus error touching ttscu1 -- we're not a Mega STe.
* Probe for the IDE bus; if there, we're STe-PLUS, else STe.

nomste:
	clr.w	d0			; set d0 back to "normal STe"
	move.l	a2,sp			; restore pre-bus-error stack pointer
	move.l	#gotmch,$8		; and set a new vector

	tst.b	$FFF00039		; read ATASR
	move.w	#$0008,d0		; no bus error - we're STe-PLUS

gotmch:	move.l	a1,$8
	move.l	a2,sp
	move.l	#"_MCH",(a0)+
	move.l	d0,(a0)+
cdone1:
.endif
* if !SPARROW
.endif
* if !STPAD
.endif
* if !TT

* OK, the CPU, VDO, and MCH cookies are set.  TT and STPLUS have
* configuration switches.  Set that cookie and use the high bit to set _SND
* and _FDC cookies.

	move.b	#%01111111,d0		; preload "no DMA sound, no hi den"
	tst.b	_iamanst
	bne	noswi

	move.l	#"_SWI",(a0)+

	moveq.l	#0,d0			; pre-load the conf bits
	move.w	conf_switches,d0	; get configuration bits (as word!)
	lsr.w	#8,d0			; shift switches into low byte
	move.l	d0,(a0)+
noswi:

* Switch values are in d0: this fact is used to set _SND below.

.if SPARROW
	moveq.l	#$1f,d1			; Sparrow: PSG|8bit|16bit|CODEC|DSP
.else
	moveq.l	#3,d1			; pre-load "dma and normal sound"
.endif
	move.l	#"_SND",(a0)+
	btst	#7,d0			; test the (possibly fake) sound SWI
	bne	gotsnd
	bclr	#1,d1			; nope, no DMA sound
gotsnd:	move.l	d1,(a0)+		; write sound cookie value

* d0.b still holds the configuration switches as computed above.

*
* Set up an _FDC cookie based on the switch settings.  Bit 6 in the
* switches, when zero, means you have high-density capability.  This is
* defined as "Flopfmt of 18 sectors gives you high-density at 18 sectors"
* and "Protobt type 4 gives you 80 tracks / double sided / 18 spt" and
* Floprd/Flopwr/Flopver work on high-density disks (and auto-detect them)."
* One day we'll have a switch which tells us to install the quad-density
* version of this cookie, meaning all of the above at 36 spt, plus "Protobt
* type 5 gives 36 spt."
*
* The high byte of the value of the _FDC cookie holds a value indicating
* the kinds of drives available: 00 means 720K only, 01 means 1.44MB, and
* other values are undefined, but will eventually mean stuff like 2.88MB. 
* The low three bytes of the cookie is to be used by vendors who want to
* identify their products; they should register their desires with somebody
* (as of 4/25/91 it's Bill Rehbock).  "ATC" means Atari's 1772-clone that
* runs reliably at the higher denisty.
*
* We're being cagey about this because we don't want to preannounce the
* high-density floppy capability, and besides, we don't want people looking
* at the switches directly if we can help it.  So, like DMASND, you get a
* cookie based on a switch.
*
* In addition, if the switch is thrown, we set nospindelay so the floppy
* BIOS knows you're using an Epson SMD-340 or something like it.  See
* comments in flop.s for the rationale.
*

	btst	#$6,d0			; second switch thrown (read as 0)?
	bne	nofdc			; no - don't even install the cookie.

.globl dsb0
	move.b	#$08,dsb0		; set this; see flop.s for more

	move.l	#"_FDC",(a0)+		; install the cookie
	move.l	#$01000000+"ATC",(a0)+	; $01 means 1.44MB; ATC means Atari's.

nofdc:

*
* This is the end of the code that relies on d0 holding the value from the 
* switches.
*

*
* The FPU cookie: 0002 0000 on a TT if you have a 68881; can be changed 
* to 0003 0000 by software if you know you have a 68882 and if you care.
* The 68881 is probed regardless of what machine you're on.
*
* If not TT, this code catches bus error and probes for the SFP004
* coprocessor; if found, the cookie value is 0001 0000.
* If not found, the cookie is installed with value 0000 0000,
* meaning no FPU.  This is to make it easy for software FPU emulators
* to register themselves (see below).
*
* The full definition of this cookie (as of now, 5/90) is as follows:
*
* The high word of the _FPU cookie value contains a description of the
* hardware FP support present in the machine.  

* The low bit of the high word is set if and only if there is an SFP004-
* equivalent floating-point peripheral installed.
*
* In addition, the next three bits (at least) describe the presence of
* a 6888x coprocessor: a value of %001 means either 68881 or 68882,
* %010 means 68881 explicitly, %011 means 68882 explicitly, and
* %100 means the 68040's built-in floating-point hardware.
*
* The reason for this scheme is that you may actually have both an
* SFP004-equivalent peripheral installed AND a 6888x coprocessor,
* if (for example) you have upgraded a Mega STe with a 68020 + 68881.
*
*	HIGH WORD
* 
* 	0000 = no hardware FPU
*	0001 = SFP004
* 	0002 = 68881 or 68882, unsure which
*	0003 = 68881 or 68882, unsure which, plus SFP004
* 	0004 = 68881
*	0005 = 68881 + SFP004
*	0006 = 68882
*	0007 = 68882 + SFP004
*	0008 = 68040
*	0009 = 68040 + SFP004 (unlikely)
*
* All other bits and values are reserved.  It may be that other bits will
* describe the presence of coprocessors with other CPID's.
*
* The low word of the _FPU cookie's value describes software floating point
* which is installed.  Since there isn't any yet, this is somewhat
* nebulous.  However, a zero means there is no software support for line-F
* instructions, and the high bit of the low word means whatever you've got
* is aware of having a 68040, so it will use line-F instructions for those
* functions which are present in that processor.
*
* 	LOW WORD
* 
* 	0000 = no software FPU emulation
* 	other = Atari-assigned software version number.
* 		High bit means S/W is 68040-FPU aware.
*
* Usually, the low word is zero when you have a 68881, because there's no
* need for S/W emulation.  However, when you have the SFP004, you might
* also have software that turns line-F instructions into the corresponding
* SFP004 commands, and with a 68040, you might have software that deals
* with the missing FP instructions.
*
* This code always installs SOME cookie so software emulators can just find
* the cookie & change it, rather than installing their own.
*

	move.l	#"_FPU",(a0)+		; always install SOME cookie

* Frestore a null state to zap that FPU.  This involves catching all the
* possible exceptions that can cause:
*
*	$2c	line-f (there is no FPU)
*	$34	coprocessor protocol violation (Shouldn't Happen)
*	$c0-$d8	misc. exceptions caused by previous FPU instruction

	moveq.l	#0,d7		; pre-clear d7, which will be the _FPU value
	movem.l	$2c,a3		; save existing line-f and protocol viol. vecs
	move.l	$34,a4		; in a3-a4
	move.l	#nofpu,$2c	; write ours
	move.l	#nofpu,$34
	move.l	#$c0,a2
	movem.l	(a2),d0-d6	; save the existing vectors in reggies
	move.l	#yesfpu,a5
	move.l	a5,(a2)+	; rewrite with our vector
	move.l	a5,(a2)+
	move.l	a5,(a2)+
	move.l	a5,(a2)+
	move.l	a5,(a2)+
	move.l	a5,(a2)+
	move.l	a5,(a2)+

	clr.l	-(sp)		; get a quick zero to Frestore
	move.l	sp,a2		; remember the pre-exception stack pointer
	frestore (sp)
yesfpu:
	move.l	#$00020000,d7	; win: set d7 for writing below
nofpu:
	move.l	a2,sp		; clean off exception stack (if any)
	addq	#4,sp		; get rid of that "quick zero"
	move.l	a3,$2c		; restore protocol violation, line-F vectors
	move.l	a4,$34
	movem.l	d0-d6,$c0	; restore all other vectors

	move.l	d7,(a0)+	; write d7 as _FPU cookie's value

* Probe for SFP004 (even in Sparrow); any non-bus-error at the right
* address wins.  Don't do it on Sparrow because it doesn't bus error there.

.if (SPARROW == 0)
	move.l	$8,a1			; save bus error vector
	move.l	sp,a2			; and SP for cleaning up later
	move.l	#sfpdone,$8		; catch bus error
	move.w	$fffffa40,d0		; probe for SFP004
	bset.b	#0,-3(a0)		; found SFP004: set %01 bit

sfpdone:
	move.l	a1,$8			; clean up
	move.l	a2,sp
.endif

.if TT
* If there's fast RAM, put the _FRB cookie in the cookie jar. It points to
* 64K of space available for anybody to do copies when attempting a Rwabs
* between TT RAM and an ACSI device. Don't change this size: RAM-loaded
* drivers use the same buffer.

	tst.l	_ramtop.w		; any fast RAM?
	beq	nofrb			; no - forget it.

*
* There is some fast RAM, so must allocate a 64K disk buffer
* and add its cookie here.  I don't necessarily like allocating the
* buffer here, but it's really the best place for that code. It must
* be after _membot is set, and before the jsr through _hdv_boot.
*

	move.l	#"_FRB",(a0)+		; write cookie ("Fast RAM buffer")
	move.l	_membot.w,d0
	move.l	d0,(a0)+		; write pointer to buffer
	add.l	#$10000,d0		; move up by 64K
	move.l	d0,_membot.w		; write new _membot
	move.l	d0,end_os.w		; write new end_os
nofrb:
.endif

********************
*
* Pull user preferences out of NVRAM, and set _AKP and _IDT cookies.
*
* The Advanced Keyboard Preference cookie indicates keyboard and
* language preference.  The initial value comes out of NVRAM
* on those machines that have NVRAM.
*
* If you don't have NVRAM you don't get this cookie.
*
* The low byte of the cookie value is the keyboard preference code:
*
*	0	usa
*	1	germany
*	2	france
*	3	uk
*	4	spain
*	5	italy
*	6	sweden
*	7	swiss french
*	8	swiss german
*
* Other values are reserved for our use.
*
* The second-lowest byte of the cookie value is the language preference:
*
*	0	English
*	1	German
*	2	French
*	3	<reserved>
*	4	Spanish
*	5	Italian
*	6	Swedish
* 
* If NVRAM is invalid you get zeros (USA).
*
* If (for instance) an AUTO folder program is run to change the keyboard
* layout and/or country preference, it should change the value of this
* cookie.  It can also call a variant of Bioskeys() called Bioskset(code)
* to load up the indicated keyboard map.  This call returns 0 on success,
* and -1 on failure (i.e. 'code' is not known to this BIOS).
*
* Additional info: the Keytrans(unshift,shift,caps) BIOS call still
* returns the base address of a table of keyboard-table pointers, but
* now that table is SIX pointers long; the second three point to
* tables of scan-code/ASCII-code pairs for use when the ALT key is
* down in the unshift, shift, and caps-lock cases, respectively.
*
********************

.if (TT|SPARROW)
nv_prefs:
	link	a6,#(-4-nv_used)	; get some stack space
	move.l	sp,a5
	move.l	a0,(a5)			; save cookie pointer

	pea	4(a5)			; buffer address
	move.w	#nv_used,-(sp)		; count
	clr.l	-(sp)			; start byte 0, read operation
	jsr	NVMaccess(pc)
	move.l	(a5)+,a0		; get coookie pointer
	tst.w	d0
	beq.b	nv_ok

	lea	nv_defs,a5		; use default values
	moveq	#0,d0

nv_ok:	move.w	(a5),_upref.w		; nv_upref
	addq	#nv_AKPlang,a5

	move.l	#"_AKP",(a0)+		; nv_AKP
	move.w	d0,(a0)+
	move.w	(a5)+,(a0)+

	move.l	#"_IDT",(a0)+		; nv_IDT
	move.w	d0,(a0)+
	move.w	(a5)+,(a0)+

	move.l	(a5)+,dspin.w		; nv disk stuff
	moveq	#80,d0			; 80 second cap
	cmp.b	dspin.w,d0		; on spinup delay
	bcc.b	nv_md			; (unsigned byte)
	move.b	d0,dspin.w
nv_md:
	move.w	(a5),d0			; nv_modecode
	bne.b	okmode
	move.w	#$82,d0
okmode:	move.w	d0,_modecode.w

	unlk	a6
.endif

* Mark the end of the cookie jar; all done.

	clr.l	(a0)+			; last entry is null
	move.l	#DEFCSIZE,(a0)+		; with size for its value

*+
*  "The other half" of the BIOS handles character I/O;
*  call its initialization hook.
*  (It can "never fail".  This will get interesting
*   if we ever do a detachable keyboard ....)
*-

	bsr	initmfp

* RMS 03/12/87
* Due to D. Getreu's code on the orginal release of the OS, the disable
* mouse and joystick commands sent to the ikbd after the software reset
* never got to the ikbd.  Therefore, the ikbd's mouse and joystick are ENABLED
* to the reset default condition on powerup. For compatibility, we will not
* disable the mouse and joystick on powerup.
*
* NOTE: Furture systems may require a delay BEFORE we perform the software
*	reset. Problems with the ikbd require a 1/200 of a second delay
*	AFTER the ikbd has received a character from the acia. See bios.s
*	ikdbwc for details.
*
	move.w	#$0400,d0	; divide by 50, count 256 = 5ms
	bsr	dowait		; (this is ttwait or stwait as appropriate)
	move.l	#ikbreset,-(sp)	; ikbd reset string
	move.w	#sizeikbd,-(sp)	; string length
	jsr	ikbdws		; reset keyboard
	addq.l	#6,sp

	move.w	#$0700,d0	; divide by 200, count 256 = 20ms
	move.w	#15-1,d1	; do this 15 times; 15*20ms = 300ms
ikbdlp1:
	bsr	dowait		; (this is ttwait or stwait as appropriate)
	dbra	d1,ikbdlp1

*+
*  Fire up %%2 cartridges
*
*-
	moveq	#2,d0			; bit# = 2
	bsr	cartscan		; execute cartridge aps
.if STPAD
	bsr	cart1			; (on STPAD, scan 256KB after ROM, too)
.endif

*+
*  Initialize screen resolution -- algorithm from Jim Tittsler (thank you!)
*  Init console subsystem.
*  If in medium resolution, make color 3 black (color 15 ==> color 3).
*
* This used to read the current rez out of the hardware & set the software
* shadow to that.  This is bogus: we're RESETTING the machine, and we
* should reset the rez, too.  So... We set low rez, unless there's
* a mono monitor, in which case we set high rez (read "ST LOW" at "TT HIGH"
* when on a TT).
*
* As of 5/14/91, TT's with color monitors boot in TT MED, which makes it
* look less like a toy machine with only 40 columns.
*
* The STPAD part of this moved to the place where the sync mode and
* palette registers are initialized, to get a screen on pad sooner.
* However, we do that stuff again here, too, and write "shadow shadow"
* now, after the code which cleared all of low RAM.
*
* The Sparrow code is a little different; we find out what mode to set
* and hand it off to Setmode, which does the right thing.
* The screen is set to an ST resolution for the carts, the user pref.
* is read later for the actual boot screen.  (Sheesh, there's an awful
* lot of screen-setting going on here for Sparrow!)
*-

.if STPAD
	move.b	#$80,$ffff827f		; write LCD and power control
	move.b	#$80,$889		; $889 is "shadow shadow"
	moveq.l	#2,d1			; STPAD is always mono
.else
 .if TT
	moveq.l	#4,d1			; pre-select TT MED rez
	btst	#7,gpip			; test mono bit
	bne	nomono			; no mono - d1 is fine
	moveq	#6,d1			; tt/mono: choose mode 6 (TT HIGH)
 .else
  .if SPARROW
	moveq	#3,d1			; Sparrow video
	move.w	_modecode.w,d2
	bne.b	nomono
	move.w	#$82,d2			; default modecode (ST, 40 col, 4 bpp)
  .else
	moveq.l	#0,d1			; pre-select low rez
	btst	#7,gpip			; test mono bit
	bne	nomono			; no mono - d1 is fine
	moveq	#2,d1			; st/mono: choose mode 2 (ST HIGH)
  .endif
 .endif
.endif
nomono:


.if 0

.if (TT == 0)
* on ST, you'd better not change mode during a vblank; what we do
* is call noblank1, which returns when it's sure we are NOT in a vblank.
* THEN we can change modes.  (Note: noblank1 clobbers d0.)
*
* This may not be good enough for Sparrow - sometimes it comes up wrong.
* On Sparrow, we do the opposite: wait until we *are* in Vblank.  Setmode
* (called above) waits for vblank to set the registers up, 
*
.if (SPARROW == 0)
	lea.l	nb_r1(PC),a6
	bra	noblank			; wait until we're NOT in a vblank
nb_r1:
.endif
.endif

	move.b	d1,shiftmd		; set hardware
	move.b	d1,sshiftmd.w		; set software
.else
*
* Let's just let Setscreen() handle this, eh?
*
.if (SPARROW == 0)
* @DEBUG: setscreen after _osi, so the debug stub is installed
	move.w	d2,-(sp)		; modecode
	move.w	d1,-(sp)		; rez #
	move.l	_v_bas_ad.w,a0
	move.l	a0,-(sp)		; physbase
	move.l	a0,-(sp)		; logbase
	jsr	_setscreen(pc)
	lea	12(sp),sp
.else
	move.w	d2,_modecode.w
.endif	

.endif

.if (0 & SPARROW)
	tst.w	color0			; hit color 0 to go ST video
.endif

.if (SPARROW == 0)
	bsr	_TEST_BLT		; D0 = 0:no chip, 2:chip exists
	jsr	blt_init		; init the blitter chip (with D0)
	jsr	esc_init		; clear screen, init cursor
.endif

	move.l	#reseth,swv_vec.w	; RESET system on monitor change
	move.w	#1,vblsem.w		; enable vblank processing for real


*+
*  [1] Fire up %%0 cartridges;
*  [2] Enable interrupts;
*  [3] Fire up %%1 cartridges
*
*-
	clr.w	d0			; magic bit# = 0
	bsr	cartscan		; execute cartridge aps
.if STPAD
	bsr	cart1			; (on STPAD, scan 256KB after ROM, too)
.endif
	move.w	#$2300,sr		; go to IPL 3
	moveq	#1,d0			; magic bit# = 1
	bsr	cartscan		; execute cartridge aps
.if STPAD
	bsr	cart1			; (on STPAD, scan 256KB after ROM, too)
.endif

.if STPAD
* HACK HACK HACK
*
* After enabling interrupts, wait between 10 and 15 ms (i.e. 3 ticks)
* to allow characters the keyboard controller is trying to send to come
* through, then clear the kbshift state variable.  This is because
* we can get here via control-alt-delete, and those keys will have
* been down when the keyboard was reset, and the new IKBD controller
* successfully sends "make" codes for those keys when it comes up.
* Having ALT down in DMABOOT is bad, because it inhibits hard disk
* booting.  So we flush out the channel and nuke the state variable.
*

	move.l	_hz_200.w,d0
	addq.l	#3,d0
kbloop:	cmp.l	_hz_200.w,d0
	bhi	kbloop
	clr.b	kbshift
.endif

*
* install a handler for privilege violation which handles move 
* from sr; see the label "priv" later on.
*

	move.l	#priv,$20		; set priv viol exception vector

*+
*
* NOW WE'RE COOKING!
*	Initialize GEMDOS;
*	Set system date to date the system was built;
*	Initialize clock chip;
*	Attempt to boot from floppy;
* [rom]	Attempt to boot from the DMA bus (hard disk or network);
*	if (_cmdload) is nonzero, then exec COMMAND.PRG from boot volume
*		(turns on the cursor first);
*	otherwise, exec \AUTO\*.PRG;
*	kludge up an enviroment string;
*	exec the desktop;
*	if the desktop ever exits to us (or COMMAND.PRG exits)
*		then go back to RESETH and start over ....
*
*
* If Sparrow, we temporarily subvert _memtop here so that GEMDOS
* can manage the screen memory.  (920710 sparrow Setscreen() calls the new
* GEMDOS Srealloc ($15) to allocate the screen.
*-

.if SPARROW
	move.l	phystop.w,_memtop.w
.endif

	jsr	_osi			; initialize DOS

.if SPARROW

DB_STUB = 0
* @DEBUG: cause a stop before setscreen
.if DB_STUB
	pea	Mstop		; message text
	move.w	#$f000,-(sp)	; MSG_MSG
	move.w	#$5,-(sp)	; SC_MSG
	move.w	#$b,-(sp)	; fn code 11
	trap	#$e		; Debug trap
	lea	$a(sp),sp
.endif

	move.w	_modecode.w,-(sp)	; Setscreen(0L,0L,3,modecode)
	move.w	#3,-(sp)
	clr.l	-(sp)
	clr.l	-(sp)
	jsr	_setscreen
	lea	12(sp),sp

* Initialize the DSP & DSP XBIOS calls
	jsr	_Dsp_Init(pc)

* Initialize the sound system
*	moveq	#8,d0			; src=dmaplay, dst=DAC
*	move.l	d0,-(sp)
*
*	moveq	#1,d0			; src clk=int, 1 prescale
*	move.l	d0,-(sp)		
*	move.w	#1,-(sp)		; use protocol

	move.w	#1,-(sp)
	move.w	#0,-(sp)
	move.w	#0,-(sp)
	move.w	#8,-(sp)
	move.w	#0,-(sp)
	jsr	devconnect(pc)
	addq	#6,sp			; leave 2 words on stack
	
	clr.w	(sp)			; setmode(0) (8 bit stereo)
	jsr	setmode(pc)
	move.l	#0x00020080,(sp)	; soundcmd(LTGAIN, 0x80)
	jsr	soundcmd(pc)
	move.w	#3,(sp)			; soundcmd(RTGAIN, 0x80)
	jsr	soundcmd(pc)
	move.l	#0x00060003,(sp)	; soundcmd(SETPRESCALE, 3)
	jsr	soundcmd(pc)
	move.w	#4,(sp)			; soundcmd(ADDEROUT, 3)
	jsr	soundcmd(pc)
	move.w	#5,(sp)			; soundcmd(ADCINPUT, 3)
	jsr	soundcmd(pc)
	addq	#4,sp

.endif

	move.w	os_dosdate,_date	; set file system date
	jsr	_iclock			; initialize clock chip

* new code to read IKBD and set boot-up from there if it's reasonable
* by AKP and KBAD 11/2/88.  Note that _iclock returns -1 on error.

	beq	noikbdclk		; if no error, don't bother with ikbd
	bsr	gettime			; but if no clock chip, get IKBD time
	swap	d0			; if lo byte of hi word (date) is 0,
	tst.b	d0			; ikbd clock hasn't ever been set.
	beq	noikbdclk		; whoops! that's invalid, too!
	move.w	d0,_date		; it's good: set GEMDOS time & date
	swap	d0			; from ikbd time & continue.
	move.w	d0,_time

noikbdclk:

**********************************************************************
*
* At this point, everything is up.  It's no longer OK to use Timer A
* to time short events, and for compatiblity we actually shut it
* down and disable its interrupt.
*

	clr.b	tacr
	bclr.b	#5,iera

**********************************************************************
*
* Enable the cache on a M68030.  It gets turned off again if you hold
* down the alt key before floppy disk boot: this is so floppy-based
* auto-boot games that can't hack having the cache on can run.  The
* idea is that if you are holding down the ALT key, it's because you
* want maximal ST compatibility of the boot phase.
*

.if M68030
	move.l	#$3111,d0
	movec	d0,cacr
.endif

**********************************************************************
*
* Draw an icon on the screen.  It is never cleared from the screen (by us),
* but the text cursor is placed below it so if something loads and prints a
* message before the next screen clear it won't overlap the icon.
* 
* (Note: now that the ROM does a ROM CRC check and a memory test,
* putting the cursor below the icon is a win for internal reasons, too.)
*
* This code uses Line A copy raster form to put the icon on the screen,
* so it'll work in all resolutions.  Since Setscreen() is now used to
* set up the initial boot resolution, the VDI is initialized at this point,
* so it's OK to use Line A.
*

fuji_blit:

NO_LINEA_FUJI = 0

.if NO_LINEA_FUJI
.if TT
colstride	equ	320	; TT MED stride from line to line, 80*4
mstride		equ	160	; TT HIGH stride, 160
.else
colstride	equ	160	; ST LOW stride, 40*4
mstride		equ	80	; ST HIGH stride, 80
.endif

	move.l	#icon_start,a0
	move.l	_v_bas_ad.w,a1
	move.b	sshiftmd.w,d0
	cmp.b	#2,d0
	beq	monoicon
	cmp.b	#6,d0
	beq	monoicon

* colricon:
	add.w	#colstride*4,a1		; bump down four lines
	move.w	#$55,d0			; $56 lines high
ciconl:
	moveq	#$5,d1			; $6 words wide
ciconw:
	move.w	(a0)+,d2
	move.w	d2,(a1)+
	move.w	d2,(a1)+
	move.w	d2,(a1)+
	move.w	d2,(a1)+
	dbra	d1,ciconw
	add.w	#colstride-48,a1	; add stride
	dbra	d0,ciconl
	bra	icondone

monoicon:
	add.w	#mstride*4,a1		; bump down 4 lines down
	move.w	#$55,d0			; $56 lines high
miconl:	moveq	#$b,d1			; $c bytes wide
miconw:	move.b	(a0)+,(a1)+
	dbra	d1,miconw
	add.l	#mstride-12,a1		; add stride
	dbra	d0,miconl
*	bra	icondone		; bra to next instruction

.else
* use Line A to blit the fuji to the screen.
* stack frame (84 bytes)
* 0: contrl array	22: srcfdb	42: dstfdb	62: intin
* $00 opcode	(ign)	$16 fd_addr	$2a fd_addr	$3e wmode
* $02 nptsin	(ign)	$1a fd_w	$2e fd_w	$40 fgcol
* $04 nptsout		$1c fd_h	$30 fd_h	$42 bgcol
* $06 nintin	(ign)	$1e fd_wdwidth	$32 fd_wdwidth	68: ptsin
* $08 nintout		$20 fd_stand	$34 fd_stand	$44 sx1
* $0a subfunction	$22 fd_nplanes	$36 fd_nplanes	$46 sy1
* $0c handle	(ign)	$24 fd_r1	$38 fd_r1	$48 sx2
* $0e -> srcfdb		$26 fd_r2	$3a fd_r2	$4a sy2	
* $12 -> dstfdb		$28 fd_r3	$3c fd_r3	$4c dx1
*							$5e dy1
*							$50 dx2
*							$52 dy2
ICON_BLIT = 1
.if ICON_BLIT
* Use icon_blit function
	lea	ib_ints.w,a0
	move.l	#$00010001,(a0)+	; MD_REPLACE, BLACK
	clr.w	(a0)			; WHITE
	lea	icon_pts,a0
	lea	ib_pts.w,a1
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0),(a1)
	pea	icon_fdb
	bsr	icon_blit
	addq	#4,sp
.else
	dc.w	$a000
	lea	4(a0),a1		; -> linea PB array

ICON_ARRAYS = 0
.if ICON_ARRAYS
	move.l	#icon_ctl,(a1)+
	move.l	#icon_ints,(a1)+
	move.l	#icon_pts,(a1)
.else
	sub.w	#$54,sp			; get some variable space

* Initialize arrays
	moveq	#96,d0			; pixel width
	moveq	#86,d1			; pixel height

	move.l	sp,(a1)+		; CONTRL
	lea	$0e(sp),a2		; fdb pointers in contrl
	lea	$16(sp),a3		; srcfdb
	move.l	a3,(a2)+		; psrcfdb
	move.l	#icon_start,(a3)+	; fd_addr
	move.w	d0,(a3)+		; fd_w
	move.w	d1,(a3)+		; fd_h
	move.w	#6,(a3)+		; fd_wdwidth
	clr.w	(a3)+			; fd_stand
	move.w	#1,(a3)+		; fd_nplanes
	clr.l	(a3)+			; fd_r1, fd_r2
	clr.w	(a3)+			; fd_r3
	move.l	a3,(a2)+		; pdstfdb
	clr.l	(a3)+			; addr
	lea	$10(a3),a3		; the other 8 words don't matter

	move.l	a3,(a1)+		; INTIN
	moveq	#1,d2
	move.w	d2,(a3)+		; MD_REPLACE
	move.w	d2,(a3)+		; fgcol: BLACK
	clr.w	(a3)+			; bgcol: WHITE

	move.l	a3,(a1)+		; PTSIN
	subq	#1,d0
	subq	#1,d1
	clr.l	(a3)+			; sx1 = sy1 = 0
	move.w	d0,(a3)+		; sx2 = 95
	move.w	d1,(a3)+		; sy2 = 85
	moveq	#4,d2
	add.w	d2,d1
	move.l	d2,(a3)+		; dx1 = 0, dy1 = 4
	move.w	d0,(a3)+		; dx2 = 95
	move.w	d1,(a3)+		; dy2 = 85+4
.endif
	clr.w	$36(a0)			; CLIP = 0
	move.w	#1,$74(a0)		; COPYTRAN = 1

	dc.w	$a00e			; copy raster form
.if (ICON_ARRAYS == 0)
	add.w	#$54,sp			; get back stack
.endif

* end of ICON_BLIT case
.endif

* end of NO_LINEA_FUJI case
.endif

.data

icon_start:
	.dc.l	$00000000,$79FF3C00,$00000000
	.dc.l	$00000000,$79FF3C00,$00000000
	.dc.l	$00000000,$79FF3C00,$00000000
	.dc.l	$00000000,$79FF3C00,$00000000
	.dc.l	$00000000,$79FF3C00,$00000000
	.dc.l	$00000000,$79FF3C00,$00000000
	.dc.l	$00000000,$79FF3C00,$00000000
	.dc.l	$00000000,$79FF3C00,$00000000
	.dc.l	$00000000,$79FF3C00,$00000000
	.dc.l	$00000000,$79FF3C00,$00000000
	.dc.l	$00000000,$79FF3C00,$00000000
	.dc.l	$00000000,$79FF3C00,$00000000
	.dc.l	$00000000,$79FF3C00,$00000000
	.dc.l	$00000000,$79FF3C00,$00000000
	.dc.l	$00000000,$79FF3C00,$00000000
	.dc.l	$00000000,$79FF3C00,$00000000
	.dc.l	$00000000,$F9FF3E00,$00000000
	.dc.l	$00000000,$F9FF3E00,$00000000
	.dc.l	$00000000,$F9FF3E00,$00000000
	.dc.l	$00000000,$F9FF3E00,$00000000
	.dc.l	$00000000,$F9FF3E00,$00000000
	.dc.l	$00000000,$F9FF3E00,$00000000
	.dc.l	$00000001,$F9FF3F00,$00000000
	.dc.l	$00000001,$F9FF3F00,$00000000
	.dc.l	$00000001,$F9FF3F00,$00000000
	.dc.l	$00000001,$F9FF3F00,$00000000
	.dc.l	$00000003,$F9FF3F80,$00000000
	.dc.l	$00000003,$F9FF3F80,$00000000
	.dc.l	$00000003,$F9FF3F80,$00000000
	.dc.l	$00000007,$F1FF1FC0,$00000000
	.dc.l	$00000007,$F1FF1FC0,$00000000
	.dc.l	$0000000F,$F1FF1FE0,$00000000
	.dc.l	$0000000F,$F1FF1FE0,$00000000
	.dc.l	$0000001F,$E1FF0FF0,$00000000
	.dc.l	$0000003F,$E1FF0FF8,$00000000
	.dc.l	$0000003F,$E1FF0FF8,$00000000
	.dc.l	$0000007F,$C1FF07FC,$00000000
	.dc.l	$000000FF,$C1FF07FE,$00000000
	.dc.l	$000001FF,$81FF03FF,$00000000
	.dc.l	$000003FF,$81FF03FF,$80000000
	.dc.l	$000007FF,$01FF01FF,$C0000000
	.dc.l	$00000FFE,$01FF00FF,$E0000000
	.dc.l	$00001FFE,$01FF00FF,$F0000000
	.dc.l	$00007FFC,$01FF007F,$FC000000
	.dc.l	$0000FFF8,$01FF003F,$FE000000
	.dc.l	$0003FFF0,$01FF001F,$FF800000
	.dc.l	$001FFFE0,$01FF000F,$FFF00000
	.dc.l	$00FFFFC0,$01FF0007,$FFFE0000
	.dc.l	$00FFFF80,$01FF0003,$FFFE0000
	.dc.l	$00FFFF00,$01FF0001,$FFFE0000
	.dc.l	$00FFFC00,$01FF0000,$7FFE0000
	.dc.l	$00FFF800,$01FF0000,$3FFE0000
	.dc.l	$00FFE000,$01FF0000,$0FFE0000
	.dc.l	$00FF8000,$01FF0000,$03FE0000
	.dc.l	$00FC0000,$01FF0000,$007E0000
	.dc.l	$00E00000,$01FF0000,$000E0000
	.dc.l	$00000000,$00000000,$00000000
	.dc.l	$00000000,$00000000,$00000000
	.dc.l	$00000000,$00000000,$00000000
	.dc.l	$00000000,$00000000,$00000000
	.dc.l	$00000000,$00000000,$00000000
	.dc.l	$0000C07F,$FE030007,$C01E0700
	.dc.l	$0001E07F,$FE07801F,$F81E18C0
	.dc.l	$0003E07F,$FE0F803F,$FC1E1740
	.dc.l	$0003F07F,$FE0FC03F,$FE1E2520
	.dc.l	$0003F07F,$FE0FC03F,$FE1E2620
	.dc.l	$0007F803,$C01FE03C,$1F1E2520
	.dc.l	$0007F803,$C01FE03C,$0F1E1540
	.dc.l	$0007F803,$C01FE03C,$0F1E18C0
	.dc.l	$000F7C03,$C03DF03C,$0F1E0700
	.dc.l	$000F3C03,$C03CF03C,$0F1E0000
	.dc.l	$000F3C03,$C03CF03C,$1E1E0000
	.dc.l	$001E3E03,$C078F83C,$7E1E0000
	.dc.l	$001E1E03,$C078783D,$FC1E0000
	.dc.l	$001E1E03,$C078783D,$F81E0000
	.dc.l	$003E1F03,$C0F87C3D,$E01E0000
	.dc.l	$003FFF03,$C0FFFC3D,$E01E0000
	.dc.l	$003FFF03,$C0FFFC3D,$E01E0000
	.dc.l	$007FFF83,$C1FFFE3C,$F01E0000
	.dc.l	$007FFF83,$C1FFFE3C,$F81E0000
	.dc.l	$00780783,$C1E01E3C,$781E0000
	.dc.l	$00F807C3,$C3E01F3C,$3C1E0000
	.dc.l	$00F007C3,$C3C01F3C,$3E1E0000
	.dc.l	$00F003C3,$C3C00F3C,$1E1E0000
	.dc.l	$01F003E3,$C7C00FBC,$1F1E0000
	.dc.l	$01E001E3,$C78007B8,$0F1E0000

icon_fdb:				; FDB for fuji icon
	dc.l	icon_start		; fd_addr
	dc.w	96,86,6,0,1		; fd_w,fd_h,fd_wd,fd_stand,fd_planes

icon_pts:
	dc.w	0,0,95,85,0,4,95,89


USE_BIOS_MSG = 1
    .text
icondone:
.if USE_BIOS_MSG
	moveq	#7+' ',d7	; code to addr cursor to line 7 (not STLOW)
	tst.b	sshiftmd.w
	bne	gotd7
	moveq	#12+' ',d7	; code for line 12 (STLOW)
gotd7:
	move.l	#$00030002,d6
	move.w	#27,-(sp)
	move.l	d6,-(sp)
	trap	#$d		; Bconout(2,27);
	move.w	#'Y',4(sp)
	move.l	d6,(sp)
	trap	#$d		; Bconout(2,'Y');
	move.w	d7,4(sp)
	move.l	d6,(sp)
	trap	#$d		; Bconout(2,d7);
	move.w	#' ',4(sp)
	move.l	d6,(sp)
	trap	#$d		; Bconout(2,' ');
	addq	#6,sp

.else
* use Cconws to position cursor
	clr.w	-(sp)
	move.l	M0curs,-(sp)	; Cursor move code
	jsr	_getrez		; get aspect ratio
	btst	#1,d0		; if 2 or 7
	bne.b	y91dpi		; ydpi is 91
	addq.b	#5,2(sp)	; else it's 45
y91dpi:	pea	(sp)
	move.w	#9,-(sp)
	trap	#1
	lea	12(sp),sp

.endif

*
* end of icon code
*
**********************************************************************

**********************************************************************
*
* Begin code which checks the ROM CRC's for consistency.  STPLUS has two
* one-megabit (128K) chips, and TT has four one-megabit chips.
*
* This happens for ROM systems only.  You will find toscrc later in 
* this file. It's also conditional on crcstride.
*
* Added 4/24/91 by AKP because I got burned by an incorrect jumper setting.
*
* Changed 5/27/91 to turn on cache in TT so this is faster.
*
* Changed 11/5/91 to check only if _hz_200 < EIGHTY_SECONDS
*   because otherwise warm boots take too long.  But not on TT because
*   otherwise there's no chance to use ALT to go to ST LOW rez.
*   Besides, it's not annoyingly slow on TT, as it is on ST/STe.
*

.if systype == ram
crcstride	equ	0	; no CRC computation if you're in RAM
.else
.if TT
crcstride	equ	4
.else
;
; STPAD is all one chip, so we test it all; all other machines are
; two chips.  It is now officially obsolete to have 6 chips for TOS.
;
.if (STPAD | SPARROW)
crcstride	equ	1
.else
crcstride	equ	2
.endif
.endif
.endif

* the if's above determine whether this code appears, and the stride used.
* (Note again: we don't bail out here on TT even if you've been up a while,
* because otherwise there's no chance to hit ALT to go to ST LOW.)

.if crcstride
.if (TT == 0)
	cmp.l	#EIGHTY_SECONDS,_hz_200
	bhs	crcdone			; skip if we've been alive a while
.endif

.if crcstride == 1
.if STPAD
	move.l	#(256*1024)-2,d7	; PAD roms, 256Kb
.else
	move.l	#(512*1024)-2,d7	; Sparrow ROMs, 512Kb
.endif
.else
	move.l	#(128*1024)-2,d7	; else checksum 128KB per chip
.endif
	move.w	#crcstride-1,d6		; counter - loop crcstride times
	move.l	#ostext,a5		; start address

ckloop:
	move.w	#crcstride,-(sp)	; push stride -- four bytes
	move.l	d7,-(sp)		; push count -- (chip size)-2 bytes.
	move.l	a5,-(sp)		; push start address
	bsr	_toscrc			; compute the CRC
	add.w	#10,sp			; clean off stack
	move.l	a5,a0

* advance a0 to first byte of the checksum: for single-chip TOS
* this is a0+d7; for others it's stride*128K - stride*2.

.if crcstride == 1
	add.l	d7,a0
.else
	add.l	#((crcstride*(128*1024)) - (crcstride*2)),a0
.endif
	move.b	(a0),d1			; get hi byte of CRC from rom
	lsl.w	#8,d1			; ... to high byte of d1.w
	move.b	crcstride(a0),d1	; get lo byte of CRC to d1.b
	cmp.w	d1,d0			; check the CRC
	bne	badcrc
	addq.l	#1,a5			; incr start addr for next time
	dbra	d6,ckloop		; loop on good CRC
	bra	crcdone

crcmsg:		dc.b	"WARNING: BAD ROM CRC IN CHIP ",0
crcmsg1:	dc.b	".",13,10,0
.even

badcrc:	move.l	a5,d5			; put addr in d5 for chip identification
	pea	crcmsg
	move.w	#$9,-(sp)
	trap	#1			; Cconws (God help you if you hit ^C!)
	move.b	#'E',d0
	btst	#0,d5			; low bit even, say 'E'
	beq	eok1
	move.b	#'O',d0			; low bit odd, say 'O'
eok1:
	move.w	d0,2(sp)
	move.w	#2,(sp)
	trap	#1			; Cconout((d5 & 1) ? 'O' : 'E');

.if crcstride == 4
; four chips, next letter is bit 1 of offset
	move.b	#'E',d0			; 2nd bit even, say 'E'
	btst	#1,d5
	beq	eok2
	move.b	#'O',d0			; 2nd bit odd, say 'O'
eok2:
	move.w	d0,2(sp)
	move.w	#2,(sp)
	trap	#1			; Cconout((d5 & 2) ? 'O' : 'E');
.endif

	move.l	#crcmsg1,2(sp)
	move.w	#9,(sp)
	trap	#1			; Cconws(".\r\n");

	addq	#6,sp			; clean stack
	addq.l	#1,a5			; incr start addr for next time
	dbra	d6,ckloop		; go back and check others

crcdone:
.endif

*
* End of CRC computation code
*
************************************************************************

*+
*  Attempt to load a boot sector
*    o  from floppy disk 0 (A:),
*    o  from a device on the ACSI bus
*
*  Then find packages and execute 'em.
*
* But first... If you're on TT and the ALT key is down, go into ST LOW rez.
* The TT (now) boots into TT MED rez so it doesn't look like a toy. The
* ALT key defeats hard-disk booting, and now it also sends you into ST LOW
* so auto-boot and auto-folder games come up in the rez they're used to.
* New as of 5/14/91.
*
* Also, turn off the cache, for maximal ST compatibility during boot.
*
* For M68030 that isn't TT, we just turn off the cache if ALT is down
* at this point.
*
* Flow (combination of compile-time and run-time checks):
* 	if (TT | M68030) {
* 		if (TT) {
* 			if (TT HIGH monitor) goto norezchg;
* 		}
* 		if (!(Kbshift(-1) & ALT_KEY)) goto norezchg;
* 		if (TT) {
* 			Setscreen(0,-1L,-1L);
* 		}
* 		clear cache;
* norezchg:
*	}
*-

.if (TT | M68030)

.if TT
	cmp.b	#$6,sshiftmd.w		; TT HIGH monitor?
	beq	norezchg		; yes - don't even check.
.endif

	move.l	#$000bffff,-(sp)
	trap	#$d			; Kbshift(-1);
	addq	#4,sp
	btst	#3,d0			; ALT key down?
	beq	norezchg		; no.
.if TT
	clr.w	-(sp)
	pea	$ffffffff.w
	pea	$ffffffff.w
	move.w	#$5,-(sp)
	trap	#$e			; Setscreen(-1L,-1L,0);
	add.w	#12,sp
.endif

	move.l	#$0808,d0
	movec	d0,cacr
norezchg:
.endif

.if SPARROW
**SPARROW**
** Reset the SCSI chip before hitting the floppy
**
.globl _resetspscsi
	jsr	_resetspscsi
**
**SPARROW**
.endif


****************************************************************************
*
* This is the first point at which we can read in some user code. Until
* now, any uninitialized error (including "bomb" errors like bus error)
* vectored to coldboot in the hopes of wiping out whatever condition (i.e.
* bogus system variables) caused the bombs. Now we install the "bomb
* handler" vector there, just like it used to be before this change.
*

.if (M68030 == 0)
	move.l	#$01000000,d1	; high byte is exception number if !M68030
.else
	clr.l	d1		; don't add anything if M68030
.endif

	lea.l	_term(PC),a0		; dest vector
	add.l	d1,a0			; add the exception number (or 0)
	add.l	d1,a0			; (twice: first ex number is 02)
	lea.l	$8,a1			; start of places to check
	move.w	#64-1,d0		; count
	move.l	#coldboot,d2
bloop:
	cmp.l	(a1)+,d2		; still vectored to coldboot?
	bne	bloop1			; no, don't touch
	move.l	a0,-4(a1)		; yes, fix up (a1 already incremented)
bloop1:	add.l	d1,a0			; increment exception number (!030)
	dbra	d0,bloop

****************************************************************************
*
* Now get this baby off the ground! This is the first point where we
* can load in some user code.
*

	bsr	_dskboot		; attempt to boot from disk

.if systype == rom
	bsr	dmaboot			; attempt to boot from DMA bus
.endif
	bsr	findpackages		; find RAM packages
	tst.w	_cmdload		; load shell from disk?
	beq	st_1			; (no -- execute GEM in ROM)


*+
*  Bring up COMMAND.PRG:
*    turn on the cursor;
*    do autoexec;
*    exec COMMAND.PRG on boot device.
*
*-
	bsr	_auto			; do auto-exec
.if systype == rom
	move.l	#ostext,_sysbase	; -> base of OS again
.endif
	pea	nullenv(pc)		; null enviroment string
	pea	nullenv(pc)		; null argument string
	pea	cmdname(pc)		; push shell filename
	clr.w	-(sp)			; load-and-go flavor of exec
	bra	st_x			; exec shell ("never return")


*+
*  Bring up the AES:
*    do autoexec;
*    construct an enviroment string;
*    create a basepage for the AES;
*    exec the AES.
*
* Hey! Did you know that _auto resets the SP to _supstk+supsiz?
* It does!  And this is why the bug in calling _toscrc didn't blow us up!
*-
st_1:	bsr	_auto			; do auto-exec
.if STPAD
	bsr	_autop			; do drive P's auto folder
.endif
.if systype == rom
	move.l	#ostext,_sysbase	; -> base of OS again
.endif

	lea	orig_env(pc),a0		; a0 -> original enviroment string
	move.l	#the_env,a1		; a1 -> place to put it
st_2:	cmp.b	#'#',(a0)		; look for drive# character
	bne	st_3			; (not it)
	move.l	a1,a2			; a2 -> place to put drive#
st_3:	move.b	(a0)+,(a1)+		; copy a byte
	bpl	st_2			; loop while not end-of-string

	move.b	_bootdev,d0		; compute drive#, and shove it
	add.b	#'A',d0			; into the env string at the
	move.b	d0,(a2)			; appropriate spot
	pea	the_env			; push address of enviroment string
	pea	nullenv			; no arguments

	pea	nullenv(pc)		; null shell name (in ROM, after all)
	move.w	#5,-(sp)		; createPSP flavor of exec
	move.w	#$4b,-(sp)		; exec function#
	trap	#1			; get pointer to PSP
	add.w	#14,sp			; (clean up cruft)
	move.l	d0,a0			; a0 -> PSP
	move.l	exec_os,8(a0)		; stuff saddr of GEM in PSP

	pea	the_env			; our enviroment string
	move.l	a0,-(sp)		; push addr of PSP
	pea	nullenv(pc)		; null filename
	move.w	#4,-(sp)		; just-go

st_x:	move.w	#$4b,-(sp)		; function = exec
	trap	#1			; do it
	add.w	#14,sp			; cleanup stack


*+
* When startup fails (or if the exec returns,
* which "cannot happen") fake a system reset:
*-
	jmp	reseth			; back to the beginning...


*+
* Default enviroment string
* Cannot be more than 20 chars long without modifying
* the declaration for the_env;
* Any char >= $80 terminates the string (and is included in it)
* The last '#' character is replaced by the boot drive's name (A, B, ...)
*
* The path setting here perpetuates a bug in the original release
* of the software.  Fixing the bug made the system behave strangely,
* so we left it in.  The string should be "PATH=#:\\\0\0", not
* "PATH=\0#:\\\0\0".
*
*-
orig_env: dc.b	"PATH=",0		; default pathname
	  dc.b	"#:\",0			; is the boot device
	  dc.b	0			; terminate env string
	  dc.b	$ff			; end of env string (for our copy)


cmdname: dc.b	"COMMAND.PRG",0		; shell name
gemname: dc.b	"GEM.PRG"		; desktop name
nullenv: dc.b	0,0			; null string (and enviroment)
	even

ikbreset:	dc.b	$80,$01		;reset keyboard,disable
sizeikbd	equ	*-ikbreset-1
	even

*
* clrcache: common subroutine to clear both caches; clobbers d0.
* Called also at the tail end of any Rwabs call with bit 0 clear (reads).
*

clrcache:
	move.w	sr,-(sp)		; save IPL
	or.w	#$0700,sr		; go to IPL 7
	movec	cacr,d0			; get cacr
	or.l	#$808,d0		; set "clear" bits of both caches
	movec	d0,cacr			; put cacr back
	move.w	(sp)+,sr		; restore IPL and 
	rts				; return.

*
* PRIV: handler for privilege violation exception.
*
* We copy pieces of the instruction (ea and extension words) into a
* different instruction and execute that.  This always works and really
* gives you the SR, unlike other solutions which only give CCR or require
* that the insn be in RAM.
*
* What we do is copy the dest EA bits and extension words of the
* instruction into a "move.w d0,ea" instruction elsewhere in memory,
* put the SR from the exception stack into d0, and execute that insn.
* If the original instruction was going to use d0 then we use d1.  Also
* if the original dest was (sp) we spoof that.
*

.bss
.even
pspace:	ds.w	4
.text

priv:	movem.l	d0-d2,-(sp)		; save D regs
	move.l	a1,-(sp)		; save A regs
	move.l	a0,-(sp)
	move.l	$16(sp),a0		; get PC of offending instr
	move.w	(a0),d0			; get the instr itself
	move.w	d0,d1			; copy to d1
	and.w	#$ffc0,d0		; zero the EA bits
	cmp.w	#$40c0,d0		; is it move from sr?
	bne	priv1			; no.

	move.l	#$30004e71,pspace.w	; "move.w d0,<ea> / nop"
	move.l	#$4e714e75,pspace+4.w	; "nop / rts"

	move.w	d1,d0
	and.w	#%111,d0		; isolate register bits
	lsl.w	#8,d0
	lsl.w	#1,d0
	or.w	d0,pspace.w		; OR them in
	move.w	d1,d0
	and.w	#%111000,d0		; isolate mode bits
	lsl.w	#3,d0
	or.w	d0,pspace.w		; OR them in

	moveq	#2,d2			; d2 is size of this instruction

	cmp.w	#%110000000,d0		; look for mode 6
	beq	priv1			; can't handle mode 6
	tst.w	d0			; look for mode 0 (a D register)
	beq	psused0			; yes, use that handler
	cmp.w	#%101000000,d0		; look for mode 5
	beq	pmode5			; yes, one extension word
	cmp.w	#%111000000,d0		; look for mode 7
	bne	pnot7			; not 7: setup done
* handle mode 7
	and.w	#%111,d1		; check for reg 0 or 1
	beq	p71ext			; reg 0: just one ext word
	addq	#2,d2			; count the second ext word
	move.w	4(a0),pspace+4.w	; move second extension word
p71ext:	addq	#2,d2			; count the first ext word
	move.w	2(a0),pspace+2.w	; move first extension word
	bra	psdone

* handle mode 5
pmode5:	addq	#2,d2			; count the first ext word
	move.w	2(a0),pspace+2.w	; move the first ext word

* handle all modes 2-5: if reg not 7, we're done, else use a1=usp
pnot7:	and.w	#%111,d1		; get reg bits
	cmp.w	#%111,d1		; is reg a7?
	bne	psdone

* setup done: change source reg from a7 to a1, and put usp in a1, 
* add to PC on stack, put exception SR in d0, put usp in a1, 
* jsr to pspace, put (possibly changed) a1 back in usp,
* restore d0-d1/a0-a1 and finish.

	move.l	usp,a1
	and.w	#%1111001111111111,pspace.w ; change a7 to a1 in dest of move
	add.l	d2,$16(sp)		; update PC for RTE
.if M68030
	bsr	clrcache
.endif
	move.w	$14(sp),d0		; $14(sp) is exception sr
	jsr	pspace.w
	move.l	a1,usp			; save possibly changed "usp"
	move.l	(sp)+,a0		; restore A regs
	move.l	(sp)+,a1
	movem.l	(sp)+,d0-d2		; restore D regs
	rte

* What's below is the same as what's above, except that d0-d2
* are restored before the call, and (a0) points to the place on
* the exception stack where the SR is: this is used when the dest
* of the move is a D register.

* setup done: add to PC on the stack, put addr of exception SR in a0,
* restore d0-d2 from the stack, change the instruction to a move
* from (a0), jsr to pspace, restore a0-a1, and finish.

psused0:
	add.l	d2,$16(sp)		; update PC for RTE
	or.w	#%010000,pspace.w	; change to move (a0),<ea>
.if M68030
	bsr	clrcache
.endif
	lea.l	$14(sp),a0		; a0 points to exception SR
	movem.l	8(sp),d0-d2		; get these off the stack now
	jsr	pspace.w
	move.l	(sp)+,a0		; restore A regs
	move.l	(sp)+,a1
	add.w	#$c,sp			; "pop" d0-d2 off
	rte

* What's below is the same as what's above, except that a0/a1 are restored
* from their saved values before the jsr to pspace: either might be in the 
* dest ea of the move.

* setup done; add to PC on stack, put exception SR in d0, 
* restore a0/a1, jsr to pspace, restore d0/d1 and finish.

psdone:	add.l	d2,$16(sp)		; update PC for RTE
.if M68030
	bsr	clrcache
.endif
	move.l	(sp)+,a0		; restore A regs
	move.l	(sp)+,a1
	move.w	$c(sp),d0		; $c(sp) is exception sr
	jsr	pspace.w
	movem.l	(sp)+,d0-d2		; restore D regs
	rte

* jump here for priv violations which are not moves from sr, or mode 6.

priv1:	move.l	(sp)+,a0
	move.l	(sp)+,a1
	movem.l	(sp)+,d0-d2
.if M68030
	jmp	_term			; jmp to bomb handler
.else
* 					; jump to non-TT bomb handler
	jmp	_term+$08000000		; strange but true!
.endif

*+
* _dskboot - boot (or return diagnostics)
* Passed:	nothing
* Returns:	D0.W = error number (if nonzero)
*-
_dskboot:
	moveq	#3,d0			; %%3 ap cart
	bsr	cartscan
.if STPAD
	bsr	cart1			; (on STPAD, scan 256KB after ROM, too)
.endif
	move.l	hdv_boot.w,a0		; go through boot vector
	jsr	(a0)
.if systype == rom
	tst.w	d0			; any errors?
	bne	dskb1			; (yes -- punt)
	move.l	_dskbufp.w,a0		; a0 -> disk buffer
	jsr	(a0)			; execute boot sector (it might return)
.endif
dskb1:	rts				; return status


.if systype == rom

*+
*  dmaboot - attempt to boot from a device on the DMA bus
*    Passed:	nothing
*
*    Returns:	maybe-never (although it depends ...)
*
*    Uses:	everything
*
*    Discussion:
*
*		Attempts to read boot sectors from eight devices connected
*		to the SCSI DMA bus, and eight devices connected to the
*		ACSI bus.  If a sector is read, and it is executable (word
*		checksum is $1234), then it is executed.  The search stops
*		with the first one which is executable.
*
*		This code has some strange timeouts: it waits until at
*		least 10 sec after power-up before giving up on a device.
*		It waits until at least 40 sec after power-up for the data
*		once the device accepts the command.
*
*		The old code is included here as comments;  _dmaread is
*		from Minna Lai (thanks!). _dmaread is also available as an
*		XBIOS call ($2a).
*
*		The register set-up when jmp'ing to the root sector is
*		deliberate and should not change.
*
*
* new DMA BOOT code: use _dmaread (in another file) to scan devices 8-15,
* then 0-7 (that is, SCSI, then ACSI). First device which has an executable
* root sector stops the process; if it returns, we return (i.e. just jmp to
* it).
*
* (For STPAD, scan 16-23, then 0-7: IDE, then ACSI.  Never mind that IDE
* can only have units 0 and 1; the others will return "unknown device" so
* fast you won't notice.)
*
* The register set-up when calling the root sector is as follows:
*	d3.l: magic number $444d4172 ("DMAR")
*	d7.b: ACSI device number in hi 3 bits, for ACSI devs
*	d4.w: _dmaread device number
*	d5.w: user-preference value from NVM or input or something
*	others: garbage
*
* _dmaread returns zero for success, -1 for timeout (don't retry),
* and some other (negative) number for retryable errors (like
* media change and reset error, which some drives use to signal
* those conditions).
*
* USER PREFERENCE:
* 
* The high 5 bits of SCU general-purpose register 1 (ttscu1) can be
* set (e.g. by a bootable floppy or a program in either OS) 
* to a value which will be used as the low byte of the "user preference"
* word in d5.  If it's zero, then NVM is checked for validity.  If NVM is
* valid, the first word of NVM is used as the user preference value;
* otherwise, zero is used.
* 
* The SCU value is a "temporary" preference, lost on power-down.
* Since it is cleared only on power-off, you can cold- or warm-boot to your
* heart's content and never lose this "temporary" preference.
* 

*
* Boy, there is some serious spaghetti code here. Here's the deal:
*
*     endtime = 80 seconds;
*     if (now >= endtime) goto all_done;	    (skip everything)
*     memtest_done = FALSE;		    (a5 holds this flag)
* 
* main_loop (label dmab_to):
* 	if (!memtest_done) {
* 	    memtest_done = memtest_next();
* 	    if (!memtest_done) goto done_with_mt_and_bar;
* 	    else {
* 		(memtest just finished)
* 		set bar_interval to one or two seconds; (d5)
* 		set next_bar_time to bar_interval;	(d6)
* 		draw an inverse-video line across the screen;
* 		place the cursor on the last char of this line;
* 		fall through to continuation of bar shrinking;
* 	    }
* 	}
* 	(continuation of bar shrinking here; label nomt)
* 	if (now >= next_bar_time) {
* 	    kill-to-end-of-line (erase the next dot)
* 	    send backspace (move to previous dot)
* 	    next_bar_time += bar_interval;
* 	}
* 
* (done with mt and bar; label dmab_ns):
* 
* 	if (memtest_done && now > end_time) goto dmab_todone;
*	if (STPAD and you hit a STylus button) {
*		goto dmab_abort;
*	}
* 	if (you hit a key) {
* 	    gobble the key;
* dmab_abort:
* 	    if (!memtest_done) {
* 		call mem_abort;
* 		goto "all done";
*             }
*             (else fall through to dmab_todone to erase the bar)
*         }
* 	(didn't hit a key, not timed out yet)
*         goto main_loop;
* 
* dmab_todone:
*         erase the bar: send CR plus clear-to-end-of-line
* all_done:
* 	all done
* 
* The idea is that for each loop, you either do the "next" memory test or
* shrink the line (if it's time), and in any case you check the keyboard and
* clean up if the guy hit a key.  Something subtle here is that the line will
* shrink one dot per loop until it has shrunk down to its correct remaining
* size, given that the memory test took nonzero time to run.
*
* In the STPAD TOS that went to Dusseldorf in 8/91, this didn't happen;
* the memory test did but the timeout didn't.  I now realize that you
* can have an external ACSI device on an STPAD or STBOOK, so of course
* we still have to do this.
*

.globl	mem_test_next
.globl	mem_abort

DMAB_RETRIES	equ	2		; try each device twice total
EIGHTY_SECONDS	equ	200*80		; eighty seconds at 200Hz

dmaboot:
	move.l	#200,d5			; ticks per second
.if (TT|SPARROW)
	moveq	#0,d4
	move.b	dspin.w,d4		; # of seconds
.else
	moveq	#80,d4
.endif
	move.l	d4,d7
	muls.w	d5,d7			; # of ticks
	cmp.l	_hz_200,d7		; Have we already been up >= 80 sec?
	blo	dmab_skip		; yes -- boot this popsicle stand!

	move.w	#0,a5

dmab_to:
	cmpa.w	#0,a5		; a5 is a flag: TRUE when the memory test
				; is done
	bne	nomt
	bsr	mem_test_next
	move.w	d0,a5		; mt returns ne and (d0 != 0) when done
	beq	dmab_ns		; eq: not done, so don't draw the bar

* memory test just finished: draw the bar and watch it shrink.
* go into reverse video
	move.w	#27,-(sp)
	move.l	#$00030002,-(sp)
	trap	#$d
	move.w	#'p',4(sp)
	move.l	#$00030002,(sp)
	trap	#$d

	move.w	#27,4(sp)
	move.l	#$00030002,(sp)
	trap	#$d
	move.w	#'w',4(sp)
	move.l	#$00030002,(sp)
	trap	#$d			; Set discard at end of line flag

.if SPARROW
	btst.b	#3,_modecode+1.w	; test 80 column bit of mode code
.else
	tst.b	sshiftmd		; test (shadow) resolution register
.endif
	bne	dmab_80			; OK, you're in an 80-column rez

	lsl.l	#1,d5			; lo rez: report every 2 seconds
	lsr.l	#1,d4			; and half the total intervals

dmab_80:
	subq	#1,d4			; dbra count

	move.l	d5,d6			; d6 is next time to report at
	move.l	d4,d3			; remember this: we use it twice

dmab_sp:
	move.w	#' ',4(sp)
	move.l	#$00030002,(sp)
	trap	#$d
	dbra	d4,dmab_sp

* output CR to return to left edge
	move.w	#13,4(sp)
	move.l	#$00030002,(sp)
	trap	#$d

* output N-1 spaces; this puts the (invisible) cursor over the last spot.
* A simple backspace after the Nth one doesn't work because you may or may
* not be on an N-column display, where the cursor is ALREADY on the
* Nth one.  Sigh.

	subq.l	#1,d3

dmab_sp2:
	move.w	#' ',4(sp)
	move.l	#$00030002,(sp)
	trap	#$d
	dbra	d3,dmab_sp2

* restore normal video
	move.w	#27,4(sp)
	move.l	#$00030002,(sp)
	trap	#$d
	move.w	#'q',4(sp)
	move.l	#$00030002,(sp)
	trap	#$d
	addq.l	#6,sp

* we jump here when we're counting time and the memory test is done.

nomt:

* if (mt_done && _hz_200 >= d6)
*   output "clear to end of line"
*   output a backspace
*   add 200 to d6

	cmp.l	_hz_200,d6
	bhi	dmab_ns
	move.w	#27,-(sp)
	move.l  #$00030002,-(sp)
	trap	#$d
	move.w	#'K',4(sp)
	move.l	#$00030002,(sp)
	trap	#$d
	move.w	#8,4(sp)
	move.l	#$00030002,(sp)
	trap	#$d
	addq	#6,sp
	add.l	d5,d6

dmab_ns:

* this is the end of the memory-test/shrinking bar sequence.  We check
* to see if we're actually done (gasp!) and also for user interruption.

	cmp.w	#0,a5
	beq	dmab_notime		; if mt not done don't check time
	cmp.l	_hz_200,d7
	bls	dmab_todone		; timeout done

dmab_notime:
* Check the keyboard for a user aborting the timeout

.if STPAD
* on STPAD, check the STylus button for aborting the delay, too.
* STBOOK doesn't really have buttons; we're relying on getting $FF
* from there as a floating bus.

	move.w	$d00004,d0
	not.w	d0			; make the value one-is-down
	and.w	#%00001100,d0		; check both button bits
	bne	dmab_abort		; yes, at least one's down: abort
.endif

 	move.l	#$00010002,-(sp)
	trap	#$d			; poll for char: Bconstat(2)
	addq.l	#4,sp
	tst.l	d0
	beq	dmab_to			; keep waiting for timeout
	move.l	#$00020002,-(sp)	; get the char: Bconin(2)
	trap	#$d
	addq.l	#4,sp
*
* UNDO checking
* if the Undo key is held down, together with CTRL and ALT,
* then re-initialize NVRam (helps out users who have screwed themselves)
*
	and.l	#$00ff0000,d0		; strip out all but scan key
	cmp.l	#$00610000,d0		; look for UNDO
	bne	no_undo
	move.b	kbshift.w,d0		; check for CTRL-ALT
	and.b	#$c,d0
	cmp.b	#$c,d0
	bne	no_undo
	clr.l	-(sp)
	clr.l	-(sp)
	move.w	#$0002,-(sp)		; NVMaccess(2,0,0,0)
	move.w	#$2e,-(sp)		; NVMaccess opcode
	trap	#$e
	add.l	#12,sp
	jmp	coldboot		; do a cold boot

no_undo:
*
* End of UNDO checking
*

dmab_abort:
	cmpa.w	#0,a5			; was memory test done?
	bne	dmab_todone		; yes - don't have to abort it.
	bsr	mem_abort		; clean up after aborting mem test
	move.l	d7,_hz_200		; write eighty seconds so we 
					; don't do this again
	bra	dmab_skip		; and we're done

dmab_todone:
	move.l	d7,_hz_200		; you broke out: write 80 sec
	move.w	#13,-(sp)
	move.l	#$00030002,-(sp)
	trap	#$d			; Bconout(2,cr);
	move.w	#27,4(sp)
	move.l	#$00030002,(sp)
	trap	#$d			; Bconout(2,esc);
	move.w	#'K',4(sp)
	move.l	#$00030002,(sp)
	trap	#$d			; Bconout(2,'K'); (clear to eol)
	addq.l	#6,sp

dmab_skip:


* Begin scanning DMA devices for a bootable one.  The sequence of devices
* you scan varies, and is described in dmarfail where the device number is
* updated.  This code uses the first word of the buffer "the_env"
* as scratch space.

.if TT
	jsr	_resetscsi		; reset the SCSI bus
.endif

	clr.w	the_env			; zero our device sequencer

*
* move boot preference into _upref: hi 5 bits of ttscu1, or
* first word of NVM if valid, else zero.
*

.if TT
* Only TT has TTSCU1
	move.b	ttscu1,d0
	and.w	#$f8,d0
	move.w	d0,_upref.w	; move ttscu1 to _upref, usually zero.
	bne	gotpref
.endif

.if (TT | SPARROW)
* Both TT and SPARROW have NVMAccess
	pea	_upref.w
	move.w	#2,-(sp)
	clr.l	-(sp)
	jsr	NVMaccess(pc)	; NVMaccess(op=0,start=0,count=2,buf=_upref)
	add.w	#$a,sp
	tst.w	d0
	beq	gotpref
	clr.w	_upref.w	; NVM was invalid: zero the preference.
gotpref:

.endif

.if ((TT + SPARROW) == 0)
* If you are neither TT nor Sparrow, then there's no boot pref.
	clr.w	_upref.w	; no way to get pref w/o NVM & SCU.
.endif

dmaloop:
	move.w	#DMAB_RETRIES-1,d1	; retry count (usually 2 total)
dmaretry:
	move.w	d1,-(sp)		; save retry count
	move.w	the_env,d4		; set d4 to the device to try
	move.b	boot_dev_tab(PC,d4.w),d4
	move.w	d4,-(sp)		; put device number on stack
	move.l	_dskbufp.w,-(sp)	;  "  buffer		"
	move.w	#1,-(sp)		;  "  count of one	"
	clr.l	-(sp)			;  "  sector zero	"
	jsr	_dmaread		; read the sector
	add.w	#12,sp
	move.w	(sp)+,d1		; restore retry count
	tst.l	d0
	beq	dmaok			; zero is success
	addq.l	#1,d0			; add one so -1 becomes 1
	dbeq	d1,dmaretry		; retry while ne (not -1) and

* Get here if not zero and not -1, or even if it was -1 but d1 expired.
	bra	dmarfail		; fail when count expires or
*					; some other error happens

* read won; checksum the sector, look for $1234 (bootmagic)
dmaok:	move.l	_dskbufp.w,a0
	move.w	#$ff,d0			; checksum $100 words
	moveq.l	#0,d1
dmachk:	add.w	(a0)+,d1
	dbra	d0,dmachk
	cmp.w	#bootmagic,d1
	beq	dmafound		; success!

*
* dmarfail:  DMAread failed or sector isn't bootable ($1234) or didn't
* change hdv_rw; try the next device.
*
* The device sequence (in hex) is:
*  STPLUS:	10-17, 0-7	(IDE first, then ACSI)
*  TT:		8-f, 0-7	(SCSI first, then ACSI)
*  SPARROW:	10-17, 8-F	(IDE, then SCSI; sigh)
*
* STPAD and STe-PLUS have IDE busses.  On other STPLUSes (Mega STe and
* STe), the IDEbus doesn't exist, and the reads from those devices will all
* fail quickly.
*
* Note 9/91: since ST and STPLUS are now the same ROM, we start at IDE in
* all non-TT systems.  It will fail fast for all machines with no IDEbus.
*
* The sequencing is taken care of using a table to turn the sequence number
* into a device number.  A device number of $ff ends the table.  The
* sequence counter is kept in the first word of "the_env" as scratch space.
*

dmarfail:
	move.w	the_env,d4
	addq.w	#1,d4
	move.w	d4,the_env
	cmp.b	#$ff,boot_dev_tab(PC,d4.w)
	bne	dmaloop			; yes, total failure

dmafail:
	rts

.if TT
boot_dev_tab:	dc.b	8,9,$a,$b,$c,$d,$e,$f,0,1,2,3,4,5,6,7,$ff
.else
.if SPARROW
boot_dev_tab:	dc.b	$10,8,9,$a,$b,$c,$d,$e,$f,$ff
.else
boot_dev_tab:	dc.b	$10,$11,0,1,2,3,4,5,6,7,$ff
.endif
.endif

		.even

* We get here if the _dmaread call worked and gave an executable sector. We
* load up the registers and jsr to that sector.  If it returns, we check
* hdv_rw for a change; if it changed, we rts to go on booting TOS.  If it
* didn't change, we try the next device. When you get here, d4 still has to
* have the _dmaread dev number.

dmafound:
	move.l	_dskbufp.w,a0
	move.l	#$444d4172,d3		; magic number in d3
	move.w	d4,d7			; _dmaread dev number is in d4
	asl.w	#5,d7			; ACSI dev number in hi 3 bits of d7
	move.w	_upref.w,d5		; get user-preference value
	move.l	hdv_rw,-(sp)		; save old value of hdv_rw
	jsr	(a0)			; call the root sector
	move.l	(sp)+,d0		; get old value of hdv_rw
	cmp.l	hdv_rw.w,d0		; hdv_rw still the same?
	beq	dmarfail		; yes - keep looking
	rts				; no - stop looking now

* this is "endif systype == rom"
.endif

*+
* cartscan - scan cartridge memory for runable applications
* Passed:	d0 = bit# to test in application's initialization vector
* Returns:	after all applications have been examined
* Uses:		a0,d0
*
* cart1 is an entry point which uses (ROM start plus 256KB) as the
* "cartridge" base address; this way we can put applications in
* the ROM memory above 256KB.  STPAD only.
*-

.if STPAD
cart1:
	lea	ostext+(256*1024),a0
	bra	cartsx
.endif

cartscan:
	lea	cartbase,a0		; a0 -> cartridge memory
cartsx:
	cmp.l	#apmagic,(a0)+		; correct magic number?
	bne	ca_r			; (no, so return)

ca_1:	btst.b	d0,ca_flags(a0)		; test bit in MSB of INIT address
	beq	ca_2			; (not set, so don't execute)
	movem.l	d0-d7/a0-a6,-(sp)	; save everything
	move.l	ca_init(a0),d0		; a0 -> initialization address
	and.l	#$00ffffff,d0		; mask of MSB (used for flags)
	move.l	d0,a0
	jsr	(a0)			; call cartridge application
	movem.l	(sp)+,d0-d7/a0-a6	; restore everything
ca_2:	tst.l	(a0)			; test link address
	move.l	(a0),a0			; a0 -> next header (or NULL)
	bne	ca_1			; loop on next header
ca_r:	rts


unimpl:
_rts:	rts


*+
* memchk - check pattern written to memory
*	Passed:		d1.l = offset
*			a0 = base of pattern ($1f8 bytes long)
*			a4 -> return address
*
*	Returns:	EQ: the	pattern	matched
*			NE: the	pattern	didn't match
*
*	Uses:		d0.w, a1
*
*	Called-by:	Coldstart memory-sizing	routine.
*-
memchk:
	add.l	d1,a0			; a0 ->	memory to check
	clr.w	d0			; zap pattern seed
	lea	$1f8(a0),a1		; a1 ->	ending address
memchk1: cmp.w	(a0)+,d0		; match?
	bne	memchkr			; (no -- return	NE)
	add.w	#$fa54,d0		; yes -- bump pattern
	cmp.l	a0,a1			; matched entire pattern?
	bne	memchk1			; (no)
memchkr: jmp	(a4)			; "return" to caller



*+
* val_memval - test memory configuration validation
*  Passed:	a6 -> return addressd
*  Returns:	a5 -> 0 (quick zeropage)
*		EQ: memory setup OK
*		NE: memory never configured succesfully
*
*-
val_memval:
	cmp.l	#memmagic,memvalid.w	; check first magic number
	bne	val_mr			; (mismatched -- return NE)
	cmp.l	#memmag2,memval2.w	; check again (for paranoia)
	bne	val_mr
	cmp.l	#memmag3,memval3.w	; check again
val_mr:	jmp	(a6)			; return EQ/NE


*+
* Default palette assignments.
* Sort of corresponding to the GSX spec.
*
* Full-magnitude is f, not 7, because on TT and STe the high bit of the
* nybble is the low bit of the gun value, and on ST it's a don't-care.
*
* The Sparrow color table must be contiguous with the ST color table for
* Sparrow palette initialization code at 'spsic1' to work.
*-

colors:
	dc.w	bootcolor		; 0 - boot color (white in production)
	dc.w	$f00			; 1 red
	dc.w	$0f0			; 2 green
	dc.w	$ff0			; 3 yellow
	dc.w	$00f			; 4 blue
	dc.w	$f0f			; 5 magenta
	dc.w	$0ff			; 6 cyan
	dc.w	$555			; 7 "low white"
	dc.w	$333			; 8 grey
	dc.w	$f33			; 9 light red
	dc.w	$3f3			; 10 light green
	dc.w	$ff3			; 11 light yellow
	dc.w	$33f			; 12 light blue
	dc.w	$f3f			; 13 light magenta
	dc.w	$3ff			; 14 light cyan
	dc.w	$000			; 15 black

.if SPARROW
* Sparrow palette is rrrrrr-- gggggg-- -------- bbbbbb--
spcolors:
*		 rrggxxbb
	dc.l	$ffff00ff		; 0 - boot color (white in production)
	dc.l	$ff000000		; 1 red
	dc.l	$00ff0000		; 2 green
	dc.l	$ffff0000		; 3 yellow
	dc.l	$000000ff		; 4 blue
	dc.l	$ff0000ff		; 5 magenta
	dc.l	$00ff00ff		; 6 cyan
	dc.l	$aaaa00aa		; 7 "low white"
	dc.l	$55550055		; 8 grey
	dc.l	$ff550055		; 9 light red
	dc.l	$55ff0055		; 10 light green
	dc.l	$ffff0055		; 11 light yellow
	dc.l	$555500ff		; 12 light blue
	dc.l	$ff5500ff		; 13 light magenta
	dc.l	$55ff00ff		; 14 light cyan
	dc.l	$00000000		; 15 black
.endif

*+
* hbl - force caller to IPL 3
* Oh-well:	"Yeah, it sucks, but it works" (--lt)
*
* Note:		Hacks caller's IPL to 3 (if it was 0).  This is
*		a kludge against fascist programs and certain
*		debuggers that insist on starting processes up
*		at IPL 0.
*
* Note again:	It is guaranteed that GEMDOS starts programs
* 		up at IPL 0, because it's handy (see GEMDOS comments
*		for more of a reason).
*
*-
hbl:	move.w	d0,-(sp)		; save d0
	move.w	2(sp),d0		; get pushed SR
	and.w	#$0700,d0		; strip crufty bits
	bne	hbl_r			; not IPL 0, so punt
	or.w	#$0300,2(sp)		; force caller to IPL 3
hbl_r:	move.w	(sp)+,d0		; restore d0, back to victim
	rte


*+
* vbl -	vertical blank interrupt handler
*
*-
vbl:
	addq.l	#1,_frclock		; bump frame clock
	subq.w	#1,vblsem		; P(vblsem) -- vblank locked?
	bmi	vblret

	movem.l	d0-d7/a0-a6,-(sp)	; save registers
	addq.l	#1,_vbclock		; bump unblocked-frame clock

*--- reload color palettes
	move.l	colorptr.w,d0		; if(colorptr != NULL)....
	beq	vbl1			; (its NULL, so	don't reload)

.if SPARROW
	bclr	#0,d0			; test & clear bit 0
	beq.b	vb_stc			; if it was 0, set ST palette
	move.w	_n_rgb.w,d1		; move n_rgb longs (set by VsetRGB)
	lea	sp_color0,a1		; to SP palette
	bra.b	vbl3
vb_stc:
.endif
	moveq	#8-1,d1			; move 8 longs
	lea	color0,a1		; to ST palette
vbl3:	move.l	d0,a0			; from colorptr
vbl2:	move.l	(a0)+,(a1)+
	dbra	d1,vbl2
	clr.l	colorptr.w		; zap colorptr
vbl1:

*------	Call deferred interrupt	vectors:
	move.w	nvbls,d7		; d7 = # of deferred vblank vectors
	beq	vbl12			; (punt	if no vectors)
	subq.l	#1,d7			; turn into DBRA count
	move.l	_vblqueue.w,a0		; a0 ->	vectors
vbl10:	move.l	(a0)+,a1		; a1 ->	deferred vector
	cmp.l	#0,a1			; if(a1	== NULL) continue;
	beq	vbl11
	movem.l	d7/a0,-(sp)		; save registers
	jsr	(a1)			; call routine
	movem.l	(sp)+,d7/a0		; restore registers
vbl11:	dbra	d7,vbl10		; loop for more	vectors

*------ Video monitor fail-safe anti-burnout check:
*** When DMASND is TRUE:
*** If DMA sound is active, the MONOMON line is inverted (that is,
*** they XOR).  Therefore, the sequence is as follows:
***	READ sound status (to d0)
***	READ gpip (to d1)
***	IF gpip != d1 then try again
***	IF sound status != d0 try again
***	IF d0 != 0 invert d1
***
*** Then proceed with the old code to check for the appropriate value
*** in bit 7 of d1.
***
*** We have to read sound status more than once because it might be active
*** when we test it, then go inactive before we read MONOMON.  Moreover,
*** it might spike while reading gpip, then settle again.  This sequence
*** doesn't quite ensure lack of trouble, but it does give some hope.
***
*** STPAD doesn't have any of this cruft - you can't change monitors!
***
*** SPARROW doesn't have it either - burn 'em out!
***

.if (STPAD == 0) & (SPARROW == 0)

	move.b	gpip,d1			; get "High Rez" input
	tst.b	_hasdmasnd		; test the "I have DMA sound" flag
	beq	v_readdone		; don't have it; d1 is right.

	move.w	sr,-(sp)
	or.w	#$0700,sr
v_read1:
	move.b	dmasndc+1,d0		; read sound state once
	move.b	gpip,d1			; get gpip with monomon
	btst	#7,d1
	sne	d1
	move.b	gpip,d2			; still the same?
	btst	#7,d2
	sne	d2
	cmp.b	d1,d2
	bne	v_read1			; no - start over
	cmp.b	dmasndc+1,d0		; sound state still the same?
	bne	v_read1			; go try again
	move.w	(sp)+,sr		; restore SR

* d0 now holds good DMA sound state value; d1 holds good I7 value

	btst	#0,d0			; was sound active?
	beq	v_readdone
	not.b	d1			; no - invert it to get true MONOMON

v_readdone:
	move.b	shiftmd,d0		; get current rez

.if (TT == 0)
	and.b	#3,d0			; strip bucky bits
	cmp.b	#2,d0			; low or high rez?
	bge	swmon1			; (high)
.else
	and.b	#7,d0			; strip bucky bits
	cmp.b	#6,d0			; high rez?
	beq	swmon1			; (high)
.endif

*--- low rez: switch to high if gpip%%7 == 0

	btst.l	#7,d1			; bit is zero when there's mono
	bne	swmon3			; no change: punt

* rez was low, but now there's a mono monitor! Go to high rez & bail out.

* This code calls noblank1 to wait until vblank is over before changing
* mode.  Otherwise the monochrome shifter can be 16 bits off. (Maybe
* not needed in TT, but why take chances?)

	bsr	noblank1		; returns when NOT in vblank

.if (TT == 0)
	move.b	#2,d0			; set mode 2 (high rez)
.else
	move.b	#6,d0			; set mode 6 (high rez)
.endif
	bra	swmon2

*--- high rez: switch to low (hopefully defshiftmd) if gpip%%7 == 1
swmon1:	btst.l	#7,d1			; bit is 1 when no mono
	beq	swmon3			; no change (still highrez)
	move.b	defshiftmd.w,d0		; get preferred rez
.if (TT == 0)
	cmp.b	#2,d0			; if high-rez, then force low rez
	blt	swmon2			; (low or med rez)
	clr.b	d0
swmon2:	move.b	d0,sshiftmd.w		; set shadow & hardware shift-mode
	move.b	d0,shiftmd
.else
	cmp.b	#6,d0			; preferred-rez high?
	bne	swmon2			; no, fine.
	clr.b	d0
swmon2:	move.b	d0,sshiftmd.w
	move.b	shiftmd,d1
	and.b	#$f8,d1
	or.b	d0,d1
	move.b	d1,shiftmd
.endif
	move.l	swv_vec.w,a0		; go through "change rez" panic vector
	jsr	(a0)
swmon3:

* end of monitor-change stuff, ALL MISSING IF STPAD or SPARROW!
.endif

	jsr	blink			; blink cursor

*--- reload display base register
	tst.l	screenpt.w		; if(screenpt == NULL) don't;
	beq	vbl5
	move.l	screenpt.w,_v_bas_ad.w	; set OS variable

* This never worked on STe before, because dbasell was being written first.
* Now (9/91) it works, and the write to dbasell is unconditional because
* it's either necessary or harmless on all machines.

	move.b	_v_bas_ad+2.w,dbasel	; load "low" pointer
	move.b	_v_bas_ad+1.w,dbaseh	; load "high" pointer
	move.b	_v_bas_ad+3.w,dbasell	; for STPLUS, TT use these 8 bits
					; (harmless on ST)

*------ Floppy drive-select timeout:
vbl5:	bsr	_flopvbl		; (no args)

*--- monitor screen dump flag
vbl12:	tst.w	_prtcnt.w		; printscreen active?
	bne	no_print		; no

*+
* printScreen
*
* We re-enable vblanks here, until the printScreen finishes.
*
*-
	bsr	_dumpit			; dump screen
no_print:


*--- restore registers & return (and a handy RTE)
	movem.l	(sp)+,d0-d7/a0-a6
vblret:	addq.w	#1,vblsem		; V(vblsem) [release vblank]
_rte:	rte



*+
* wvbl - wait for next vblank
* Passed:	nothing
* Returns:	at beginning of next vblank
* Uses:		D0
* AKP 9/91: drop IPL to somewhere from 0 to 3, not always to zero.
* If we're already at three, the normal level for TOS, it isn't changed.
*-
_wvbl:
wvbl:
	move.w	sr,-(sp)		; save psw
	and.w	#$FBFF,sr		; (IPL &= %011: allow IPL 4)
	move.l	_frclock,d0		; d0 = frame clock
wvbl1:	cmp.l	_frclock,d0		; wait for clock to change
	beq	wvbl1
	move.w	(sp)+,sr		; then restore psw & return
	rts



*+
* _critic - critical error handler binding for C
* Falls-into:	_critich
* (screwy way to save two bytes...)
*
*-
_critic:
	move.l	etv_critic,-(sp)	; jump through critic vector

*+
* _critich - default critical error handler
* Loads -1 into D0 and returns.
*
*-
_critich:
	moveq	#-1,d0			; default return value = ERROR
	rts				; return to trap invoker


*+
* trp13h - GEMDOS BIOS trap handler (trap 13)
* trp14h - Atari BIOS extensions (trap 14)
* traph  - trap handler
*
* On the stack:
*	From super-			From user
*	visor mode:			mode:
*	-----------			------------
*	N(sp) args			N(usp) args
*	6/8(sp) func#			6(usp) func#
*	<frame word if longframe>
*	2(sp) ret			2(ssp) ret
*	 (sp) SR			 (ssp) SR
*
* Returns:	anything in D0
*		If the function number is invalid, RETURNS IT IN D0.
*		This is to ensure that you can tell old ROMs from new ones:
*		For the interrogative calls, the fn number must be used
*		to signal the "old ROM" case.
*
* Uses:		d0-d2/a0-a2
* Keeps:	C registers
*
* Notes:	BIOS traps are re-entrant to 'nlevels' (declared near the
*		beginning of this file).  Attempts to recurse more than
*		'nlevels' will probably result in a crash.
*
*		BIOS calls may be made from user mode.  (This differs from
*		the current GEMDOS spec, which states that BIOS traps are
*		available from supervisor mode only).
*
* There is code to check _longframe and handle  long frames.  
* It seems to be true that RTE doesn't care what the offset
* part of the format/offset word is, because I just push a zero.
* 
*-
trp14h:	lea	trp14tab(pc),a0		; a0 -> trap14 jump table
	bra	traph
trp13h:	lea	trp13tab(pc),a0		; a0 -> trap13 jump table

* save registers, twiddle stack:
traph:	move.l	savptr,a1		; a1 -> register save area
	move.w	(sp)+,d0		; pop SR and save it
	move.w	d0,-(a1)		; (need in D0 for user-mode test)
	move.l	(sp)+,-(a1)		; save return addr

.if (ONLY_LONGFRAME == 0)
	tst.w	_longframe.w		; long frames?
	beq	trap_1			; nope.
.endif
	tst.w	(sp)+			; drop the frame word off the stack
trap_1:
	movem.l	d3-d7/a3-a7,-(a1)	; save C registers + super stack
	move.l	a1,savptr		; update save-area pointer

* make sure we have the right stack, call function:
	btst	#13,d0			; was in user mode?
	bne	b_supr			; (was in super: use super stack)
	move.l	usp,a7			; use user stack
b_supr:	move.w	(sp)+,d0		; get function#
	cmp.w	(a0)+,d0		; out of range?
	bge	b_exit			; (yes, so punt)
	move.w	d0,d1
	lsl.w	#2,d1			; turn d1 into longword index
	move.l	(a0,d1.w),d1		; get pointer to function handler
.if (M68030 == 0)
	move.l	d1,a0			; doesn't affect CC set by move above
	bpl	b_1			; points to code
.else
* can't use high byte of address on M68030: use low bit instead.
	bclr.l	#0,d1			; clear & test odd bit
	move.l	d1,a0			; doesn't affect ccr!
	beq	b_1			; was clear before: points to code.
.endif
	move.l	(a0),a0			; indirect through RAM...
*
* BIOS functions are called with a5=0, and I won't back that part out
* even though we have a good assembler now.
*
b_1:	clr.l	a5			; a5 -> zero page
	jsr	(a0)			; call BIOS function

* restore registers, cleanup stack and return:
* DO NOT TOUCH D0 HERE: It is either a return value or the fn number itself.

b_exit:	move.l	savptr,a1		; a1 -> register save area
	movem.l	(a1)+,d3-d7/a3-a7	; restore C registers + super stack

.if (ONLY_LONGFRAME == 0)
	tst.w	_longframe.w
	beq	b_exit1
.endif
	clr.w	-(sp)			; push a zero frame word
b_exit1:
	move.l	(a1)+,-(sp)		; push return address
	move.w	(a1)+,-(sp)		; push old SR
	move.l	a1,savptr		; update save-pointer
	rte				; return to caller

* trp13tab & trp14tab (BIOS/XBIOS function tables)
* are now at the end of this file.

.if M68030
*+
* m030_rw: call rwabs vector, then clobber cache if it was a read.
* This is a lose, but necessary for old drivers which don't know from caches.
*-
m030_rw:
	btst.b	#0,1(sp)		; test bit 0 of r/w function code
	bne	m030_write		; not read, don't change return PC
	move.l	#m030_rw1,(sp)		; read: cause return to m030_rw1
m030_write:
	move.l	hdv_rw.w,a0		; load vector
	jmp	(a0)			; jump to it

m030_rw1:
	move.l	d0,-(sp)		; save d0
	bsr	clrcache		; clobber the cache
	move.l	(sp)+,d0		; restore d0
	jmp	b_exit			; continue exiting from BIOS
.endif

*+
* supexec - execute some code in supervisor mode
*
*-
supexec:
	move.l	4(sp),a0		; a0 -> code
	jmp	(a0)			; execute it


*+
* Character device I/O
*
* No check is made for "bogus" device numbers.  A wierd device
* number will result in a crash.
*
*-
.globl maptabsize, maptab

bconstat:
	lea	xconstat.w,a0		; a0 -> stat table
	moveq.l	#0,d1			; d0 = offset in device map 
	bra	chsw

bconin:	lea	xconin.w,a0		; a0 -> input table
	moveq.l	#4,d1
	bra	chsw

bcostat:
	lea	xcostat.w,a0		; a0 -> ostat table
	moveq.l	#8,d1
	bra	chsw

bconout:
	lea	xconout.w,a0		; a0 -> output table
	moveq.l	#$c,d1

chsw:	move.w	4(sp),d0		; get device number

	cmp.w	#5,d0			; devs >5 handle new way
	bls	nomap
	subq.l	#6,d0
	cmp.w	maptabsize.w,d0
	bhs	badmap

* d0 is a valid device number; jump to *((*maptab)+(d0*$18)+d1)

	move.l	maptab.w,a0
	asl.w	#3,d0
	add.w	d0,a0
	add.w	d0,d0
	add.w	d0,a0
	move.l	(a0,d1.w),a0
	jmp	(a0)

badmap:	moveq.l	#0,d0			; illegal devno: return 0
	rts

nomap:	lsl.w	#2,d0			; turn into longword index
	move.l	(a0,d0.w),a0		; get address of handler
	jmp	(a0)			; jump to it


*+
* Jump tables for
*	0 - lst: (printer)
*	1 - aux: (rs232)
*	2 - con: (screen)
*	3 - Atari midi
*	4 - Atari keyboard (output only)
*	5 - raw console output (bypass vt52 pressure cooker)
*	6 - unused, reserved
*	7 - unused, reserved
*
* No range checking is performed.  If a bogus device number
* is passed to the BIOS' character I/O handler, the system
* will crash or become funky duex.
*
* BIG BUG: ikbd and midi output status are reversed.  Sorry, kids.
* For compatibility, we won't fix it.  (But we should!)
*
* Bconmap initialization (mapinit), called by initmfp, (re-)writes
* the second column of this table.
*
*-
CHRDEVTAB:
tconstat: dc.l _rts,auxistat,constat,midstat,_rts,_rts,_rts,_rts
tconin:	  dc.l _lstin,auxin,conin,midin,_rts,_rts,_rts,_rts
tcostat:  dc.l _lstostat,_auxostat,conoutst,ikbdost,midiost,_rts,_rts,_rts
tconout:  dc.l _lstout,_auxout,conout,midiwc,ikbdwc,_asc_out,_rts,_rts



*+
* _drvmap - return "active drive" bit vector
* Passed:	nothing
* Returns:	D0.L = a bit vector of live (rwabs'able) block devices
*
*-
_drvmap:
	move.l	_drvbits.w,d0
	rts

*+
* _shift - get/set keyboard shift state
* Synopsis:	LONG _shift(bits)
*		WORD bits
*
* Returns:	D0.B = shift/alt/ctl/shift' bits
*
* Note:		Since the shift bits are changed at interrupt
*		level, any set from a get of the shift state
*		must be done as a critical section.
*
*-
_shift:
	moveq	#0,d0
	move.b	kbshift.w,d0
	move.w	4(sp),d1
	bmi	shifr
	move.b	d1,kbshift.w
shifr:	rts


*+
* _get_mpb - return initial memory parameter block
* Synopsis:	_get_mpb(mpb)
*		MPB *mpb;
*
* Returns:	The properly initialized MPB.
*		The MPB points to an MD somewhere in BSS.  The MD /must/
*		be in RAM since DOS will modify it.
*
* Modified 4/90 to return as many MD's as there are noncontiguous
* pieces of RAM.  In the TT, that's two (that the BIOS can know about).
* This requires agreement with GEMDOS.  The low bit of the starting
* address of any non-ST-ram block should be set.
*-
_get_mpb:
	move.l	4(sp),a0		; a0 -> MPB
	lea	themd.w,a1		; a1 -> MD

*--- initialize MPB:
	move.l	a1,(a0)			; mp_mfl = &themd;
	clr.l	4(a0)			; mp_mal = NULL;
	clr.l	8(a0)			; mp_rover = 0; (not used any more)

*--- initialize MD:
	clr.l	(a1)			; m_link = NULL;
	move.l	_membot.w,4(a1)		; m_start = _membot;
	move.l	_memtop.w,d0		; m_length = _memtop - _membot;
	sub.l	_membot.w,d0
	move.l	d0,8(a1)
	clr.l	$c(a1)			; m_own = NULL;

.if TT
*--- initialize the second MD for fast RAM
	cmp.l	#rammagic,_ramvalid
	bne	nottram
	cmp.l	#$01000000,_ramtop
	bls	nottram

	lea.l	ttmd.w,a2
	move.l	a2,(a1)			; themd.m_link = ttmd;
	clr.l	(a2)			; ttmd.m_link = 0;
	move.l	#$01000001,4(a2)	; ttmd.m_start = start of fast RAM +1
	move.l	_ramtop,d0
	sub.l	#$01000000,d0
	move.l	d0,8(a2)		; ttmd.m_length = (length)
	clr.l	$c(a2)			; ttmd.m_rover (not used any more)
nottram:
.endif
	rts


*+
* _setexc - set exception vector
* Synopsis:	setexc(vecno, addr)
*		If 'addr' < 0, the vector is not set.
*
*		Extended vectors ($100 through $107) are located in the
*		first eight longwords of BSS, at $400.  This is for
*		convienience -- they could really be located anywhere.
*
* Returns:	D0.L = original vector value
*
*-
_setexc:
	move.w	4(sp),d0		; d0 = vector#
	lsl.w	#2,d0			; turn into longword index
	clr.l	a0
	lea	(a0,d0.w),a0		; a0 -> vector
	move.l	(a0),d0			; d0 = current vector address
	move.l	6(sp),d1		; d1 = what_to_change_it_to
	bmi	setex1			; punt if (d1 < 0)
	move.l	d1,(a0)			; set vector address
setex1:	rts


*+
* _tickcal - return system timer calibration value (in ms)
*
*-
_tickcal:
	moveq.l	#0,d0			; cast to unsigned longword
	move.w	_timr_ms.w,d0		; get calibration
	rts


*+
* _physbase - get physical display base
*
*-
_physbase:
	moveq	#0,d0			; cleanup pointer-to-be
	move.b	dbaseh,d0		; load and shift bits 16..23
	lsl.w	#8,d0
	move.b	dbasel,d0		; load and shift bits 8..15
	lsl.l	#8,d0
	tst.b	_iamanst		; see if we're an ST
	bne	phydone
 	move.b	dbasell,d0		; load low byte when non-ST
phydone:
	rts				; return pointer in d0


*+
* _logbase - get logical display base
*
*-
_logbase:
	move.l	_v_bas_ad.w,d0	; set software shadow
	rts

.if SPARROW
* _setscreen and _getrez are in vtg.c
	.globl _setscreen,_getrez
__esc_init:	jmp esc_init		; for C code linked w/ pre-Sparrow VDIs

.else

*+
* _getrez - get current screen rez
*
*-
_getrez:
	moveq	#0,d0			; cleanup dirty bits
.if (STPAD | SPARROW)
* read RAM copy for sparrow because the prototype's bits are reversed
* when read.
	move.b	sshiftmd.w,d0		; read the RAM version
.else
	move.b	shiftmd,d0		; get screen rezolution
.endif

.if (TT == 0)
	and.b	#$03,d0			; strip garbage bits
.else
	and.b	#$07,d0
.endif
	rts				; return rez

*+
* _setscreen - set screen location(s), rez
*	_setscreen(logicalLoc, physicalLoc, rez)
*	LONG logicalLoc, physicalLoc;
*	WORD rez;
*-
_setscreen:

*--- set logical location:
	tst.l	4(sp)			; if(logloc < 0) then ignore it
	bmi	f5a
	move.l	4(sp),_v_bas_ad.w	; set software pointer from logloc

*--- set physical location:
f5a:	tst.l	8(sp)			; if(physloc < 0) then ignore it
	bmi	f5b
	move.b	9(sp),dbaseh		; set bits 16..23 of hardware pointer
	move.b	$a(sp),dbasel		; set bits 8..15 of hardware pointer
 	move.b	$b(sp),dbasell		; STPLUS set low 8 bits, too
					; (harmless on ST)

*--- change screen resolution (clears the screen, clobbers the cursor):
f5b:	tst.w	$c(sp)			; if(rez < 0) then ignore it
	bmi	f5r
	bsr	noblank1		; wait until not in a vblank
	move.b	$d(sp),sshiftmd.w	; set software shadow
.if (TT == 0)
	move.b	sshiftmd.w,shiftmd 	; set hardware location
.else
	move.b	shiftmd,d0
	and.b	#$f8,d0			; clear mode bits
	or.b	$d(sp),d0		; set rez
	move.b	d0,shiftmd		; set hardware rez
.endif
	clr.w	vblsem.w		; disable vblank processing
	jsr	esc_init		; re-initialize glass tty routines
	move.w	#1,vblsem.w		; re-enable vblanks
f5r:	rts
.endif

*+
* _setpalette - set palette (on next vblank)
*	_setpallete(LONG palettePtr)
*
*-
_setpalette:
	move.l	4(sp),colorptr.w	; set software pointer
	rts				; (updated by vbl handler)


*+
* _setcolor - set single color, return old color
*	_setcolor(WORD colorNum, WORD colorValue)
*
* For TT, this call is still useful: it reads and writes the ST-compatible
* color registers, not the TT color registers.  It only does 16 of them,
* though.  The ST-compatible registers shadow 16 of the TT registers
* (which 16 is set with EsetBank) but have the 3 MSBs of the gun value
* in the 3 LSBs of the nybble: rRRRgGGGbBBB (where 'r' is the least-
* significant bit of red).
*-
_setcolor:
	move.w	4(sp),d1		; get color number
	add.w	d1,d1			; turn into word index
	and.w	#$1f,d1			; force color range (prevent buserr)
	lea	color0,a0		; a0 -> base of palette memory
	move.w	(a0,d1.w),d0		; return old color
	tst.b	_iamanst		; decide what mask to use
	beq	ffmask
	and.w	#$0777,d0		; mask dirty bits
	bra	_setc0
ffmask:	and.w	#$0fff,d0		; STPLUS/TT have other dirty bits
_setc0:	tst.w	6(sp)			; if new color is <0, don't set it
	bmi	_setc1			; (punt)
	move.w	6(sp),(a0,d1.w)		; set new color
_setc1:	rts

*+
* puntaes - throw-away AES, restart the system
*  Passed:	nothing
*  Uses:	everything
*  Returns:	if AES was already thrown away
*
*-
puntaes:
	move.l	os_magic(pc),a0		; get pointer to magic
	cmp.l	#$87654321,(a0)		; is the magic still there?
	bne	paes1			; no -- just return

	cmp.l	phystop.w,a0		; is it in ROM?
	bge	paes1			; yes -- we can't do anything about it
	clr.l	(a0)			; clobber AES!
	bra	reseth			; restart the system

paes1:	rts


*+
* _term - terminate current process
* Called-by:	Uncaught traps (bus errors, and so on)
* Saves:	processor state (in a bailout area)
*
*-

_term:

.if (M68030 == 0)
*
* The dc's below do a jsr to savp_2: when we get here the PC has the 
* exception number in the high byte, and the jsr clears that but stacks
* the PC with its exception number.  We use dc's so the assembler
* doesn't optimize the jsr into a bsr or optimize it out completely.
*
	dc.w	$4eb9		; jsr (not bsr!)
	dc.l	savp_2		; target address

savp_2:	move.l	(sp)+,proc_pc.w		; save bogus PC + exception number
	movem.l	d0-d7/a0-a7,proc_regs.w ; common registers
.else

* for M68030, we determine exception number differently: the frame word
* on the stack contains the vector offset.

	movem.l	d0-d7/a0-a7,proc_regs
	move.l	2(sp),proc_pc.w		; save the PC
	move.w	6(sp),d0		; get addr of bsr instruction
	and.w	#$fff,d0
	asr.w	#2,d0
	move.b	d0,proc_pc.w		; write ex # in hi byte of proc_pc
.endif
	move.l	usp,a0			; save USP
	move.l	a0,proc_usp.w
	moveq	#15,d0			; save 16 words off top of
	lea	proc_stk.w,a0		; the stack (enough for
	move.l	sp,a1			; any possible 68000 exception)
savp_1:	move.w	(a1)+,(a0)+		; save a word
	dbra	d0,savp_1
	move.l	#$12345678,proc_lives.w	; set magic number (procdump lives)

* --- draw an appropriate number of 'shrooms on the screen:
	moveq	#0,d1
	move.b	proc_pc.w,d1
	subq	#1,d1			; 2 for bus error, 3 for address, etc.
	bsr	do_shroom

	move.l	#savend,savptr.w	; clobber BIOS top level
	move.w	#$ffff,-(sp)		; -1 ("error") return condition
	move.w	#$4c,-(sp)		; GEMDOS function #$4c: Pterm(code)
	trap	#1			; "terminate process"
	bra	reseth			; on return, reset system


*+
* do_shroom - draw little mushroom clouds on the screen
*  Passed:	d1.w = #shrooms to draw (DBRA count)
*  Returns:	some shrooms on display
*  Uses:	d0-d7/a0-a2
*
*  Discussion:	The graphics ain't all that great.  And this is silly.
*
*-
do_shroom:
.if SPARROW
	lea	ib_ints.w,a0
	move.l	#$00010001,(a0)+	; MD_REPLACE, BLACK
	clr.w	(a0)			; WHITE

	lea	ib_pts.w,a0
	moveq	#15,d6			; x & y span
	clr.l	(a0)+			; sx1 = sy1 = 0
	move.w	d6,(a0)+		; sx2
	move.w	d6,(a0)+		; sy2

	clr.w	(a0)+			; dx1 = 0

	move.l	a0,-(sp)
	dc.w	$a000			; a0 -> line A info
	move.w	-4(a0),d7		; vertical rez
	move.l	(sp)+,a0

	lsr	#1,d7			; / 2
	subq	#8,d7			; - 8
	move.w	d7,(a0)+		; = dy1
	move.w	d6,(a0)+		; dx2 = 15
	add.w	d6,d7			; dy1 + 15
	move.w	d7,(a0)			; = dy2

	addq	#1,d6			; d6 = step
	move.w	d1,d7			; d7 = # of shrooms

	pea	mush_fdb		; pass src fdb

dmlp:	bsr	icon_blit		; blit 'dem shrooms
	add.w	d6,ib_pts+$8.w
	add.w	d6,ib_pts+$c.w
	dbra	d7,dmlp

	addq	#4,sp			; get back stack
.else
* !SPARROW
	move.b	sshiftmd.w,d7
.if TT
	and.w	#$0007,d7		; TT: three significant bits
.else
	and.w	#$3,d7			; ST: two significant bits.
.endif
	add.w	d7,d7			; d7 = rez index

	moveq.l	#0,d0
	move.b	dbaseh,d0
	lsl.w	#8,d0
	move.b	dbasel,d0
	lsl.l	#8,d0
	tst.b	_iamanst		; are we an ST?
	bne	shgotbase		; yes.
	move.b	dbasell,d0		; no - get low byte too
shgotbase:
	move.l	d0,a0
****	add.w	mindex(pc,d7.w),a0	; a0 -> base of mem to draw at
	cmp	#6,d7
	blt	dmlo
	add.l	#76800,a0		; TT rez, center screen
	bra	dms
dmlo:	add.w	#16000,a0		; ST rez, center screen

dms:	lea	mushroom,a1		; a1 -> source form
	move.w	#15,d6			; d6 = scanline count

dm0:	move.w	d1,d2			; d3 = # to draw on this line
	move.l	a0,a2			; save ptr to beg of line
dm1:	move.w	mcount(pc,d7.w),d5	; d5 = #words to replicate
dm2:	move.w	(a1),(a0)+		; draw a word
	dbra	d5,dm2			; (complete single shroom)
	dbra	d2,dm1			; another, on the same line
	addq	#2,a1			; next source word
	add.w	mwidth(pc,d7.w),a2	; next dest line
	move.l	a2,a0
	dbra	d6,dm0			; (loop for next line)

*endif !SPARROW
.endif

	moveq	#29,d7			; wait half a (60Hz) second
dm3:	bsr	wvbl
	dbra	d7,dm3

	rts				; byebye

* shifter
* modes:    0         1         2     3      4     5      6          7
*       320x200x4,640x200x2,640x400x1,na,640x480x4,na,1280x960x1,320x480x8
*mindex:
*dc.w   100*160,  100*160,  200*80,   0, 240*320,  0, 480*160,   240*320

mcount:
dc.w    3,        1,        0,        0, 3,        0, 0,         7
mwidth:
dc.w    160,      160,      80,       0, 320,      0, 160,       320


*+
* icon_blit: use line A copy raster form to blit an icon to the screen
* 4(sp) -> source memory form
*-
    .bss
ib_contrl:	ds.w	7
ib_psfdb:	ds.l	1
ib_pdfdb:	ds.l	1
ib_sfdb:	ds.l	5
ib_dfdb:	ds.l	5
ib_ints:	ds.w	3
ib_pts:		ds.w	8

    .text
icon_blit:
	lea	ib_dfdb.w,a0		; destination is screen
	clr.l	(a0)
	move.l	a0,ib_pdfdb.w
	lea	ib_sfdb.w,a1
	move.l	a1,ib_psfdb.w
	move.l	4(sp),a0
	move.l	(a0)+,(a1)+		; fd_addr
	move.l	(a0)+,(a1)+		; fd_w,fd_h
	move.l	(a0)+,(a1)+		; fd_wdwidth,fd_stand
	move.w	(a0),(a1)		; fd_planes

	dc.w	$a000			; a0 -> line A vars
	clr.w	$36(a0)			; CLIP = 0
	move.w	#1,$74(a0)		; COPYTRAN = 1
	addq	#4,a0			; skip PLANES & WIDTH
	lea	ib_contrl.w,a1
	move.l	a1,(a0)+
	lea	ib_ints.w,a1
	move.l	a1,(a0)+
	lea	ib_pts.w,a1
	move.l	a1,(a0)
	dc.w	$a00e			; copy raster form
	rts


*+
* _fastcpy - "fast" 512-byte copy
* Synopsis:	fastcpy(src, dest)
*
*		Used by _rwabs to fake disk DMA to odd addresses.  Therefore,
*		disk I/O on odd addresses is very slow.  Lose, lose.
*
*-
_fastcpy:
	move.l	4(sp),a0		; a0 -> src
	move.l	8(sp),a1		; a1 -> dest
	move.w	#63,d0			; d0 = move count (64*8 = 512)
fast1:	move.b	(a0)+,(a1)+		; copy 8 bytes at a time
	move.b	(a0)+,(a1)+		;	to minimize loop overhead
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	dbra	d0,fast1
	rts


*+
* Go through hard-disk initialization vector
*
*-
_hinit:	move.l	hdv_init,-(sp)
	rts


autopath:	dc.b	'\AUTO\'
autofile:	dc.b	'*.PRG',0
		dc.w	$1234,$5678,$9abc,$def0
	even

*+
* _auto - exec auto-startup files in the appropriate subdirectory
* _auto1 - exec (with filename args)
* Passed:	a0 -> full filespec (pathname)
*		a1 -> filename part of filespec
*		_drvbits: bit vector of active drives
*		_bootdev: contains device to exec from
*
* Returns:	nothing
*
* Note:		If _drvbits%%_bootdev is zero, _auto simply quits (since
*		the device isn't active....)
*
* Uses:		everything
*
* New as of 8/91: if you hold down the CONTROL key when you boot, the AUTO
* folder won't be run.  It is already the case that the ALT key inhibits
* the hard disk driver from autobooting; the Control key means you get the
* driver, but you don't get AUTO folder programs. The AES will also sense
* the Control key and not load anything off disk: thus, if you have an AUTO
* folder program, an accessory, a Desktop info file, or an AES auto-boot
* application installed which causes your system to bomb, you can recover
* by booting with the Control key down, then removing the offending
* program/configuration.
*-

_auto:	move.l	#$000bffff,-(sp)
	trap	#$d			; Kbshift(-1)
	addq.l	#4,sp
	btst	#2,d0			; test for control key
	bne	autor			; bail out if control key is down

* Don't do any auto folder if the boot device isn't in drvbits
* (i.e. doesn't exist).  Moved from inside _auto1 so we could
* call _auto1 from _autop.

	move.l	_drvbits.w,d0		; d0 = active dev vector
	move.w	_bootdev,d1		; d1 = dev# to exec from
	btst	d1,d0			; is the dev alive?
	beq	autor			; (no -- so punt)
					; bug fix 12/91: was autoq.

	lea	autopath(pc),a0		; -> path
	lea	autofile(pc),a1		; -> filename

_auto1:	move.l	(sp)+,autoret		; copy return addr (used by execlr)
	move.l	a0,pathname.w		; setup filename/pathname ptrs
	move.l	a1,filename.w

	lea	nullenv(pc),a0		; a0 -> \0\0
	move.l	a0,-(sp)		; null enviroment
	move.l	a0,-(sp)		; null command tail
	move.l	a0,-(sp)		; null shell name
	move.w	#5,-(sp)		; Create-PSP subfunction
	move.w	#$4b,-(sp)		; exec function#
	trap	#1			; do DOS call
	add.w	#16,sp

	move.l	d0,a0			; a0 -> PSP
	move.l	#fauto,8(a0)		; initial PC -> autoexec prog

	move.l	a3,-(sp)		; null enviroment
	move.l	d0,-(sp)		; -> PSP
	move.l	a3,-(sp)		; null shell name
	move.w	#4,-(sp)		; just-go
	move.w	#$4b,-(sp)		; function = exec
	trap	#1			; do it
	add.w	#16,sp			; cleanup stack & goodbye
autoq:	move.l	autoret,-(sp)
autor:	rts

*****************************************************************************
*
* AUTOP: execute drive P's auto folder.  Same code as _auto
* but a different pathname.  Fortunately, that means I can
* just load up a0 and a1 and call _auto1!
*

.if STPAD
_autop:	lea.l	apathp(pc),a0
	lea.l	afilep(pc),a1
	bra	_auto1

apathp:	dc.b	"P:\AUTO\"
afilep:	dc.b	"*.PRG",0
	dc.w	$1234,$5678,$9abc,$def0	; AKP: can't tell why these are here.
					; I just copied them from autofile.

.endif

*+
* fauto - exec'd by _auto to do autostartup
*
* Passed:	pathname -> path part of filespec
*		filename -> file part of filespec
*
*-
fauto:
	clr.l	-(sp)			; get into super mode
	move.w	#$20,-(sp)
	trap	#1
	addq	#6,sp			; cleanup
	move.l	d0,a4			; a4 -> saved super stack

*--- free up some memory:
	move.l	4(a7),a6		; a6 -> base page
	lea	$100(a6),sp		; sp -> new, safer addr
	move.l	#$100,-(sp)		; keep $100 (just the basepage)
	move.l	a6,-(sp)		; -> start of mem to keep
	clr.w	-(sp)			; junk word
	move.w	#$4a,-(sp)		; setblock(...)
	trap	#1
	addq	#6,sp
	tst.w	d0
	bne	au_dn			; punt on error

	move.w	#$0007,-(sp)		; find r/o+hidden+system files
	move.l	pathname,-(sp)		; -> filename (on input)
	move.w	#$4e,-(sp)		; searchFirst

	moveq	#8,d7			; d7 = cleanup amount
au1:	pea	autodma			; setup DTA (for search)
	move.w	#$1a,-(sp)
	trap	#1
	addq	#6,sp

	trap	#1			; search first/search next
	add.w	d7,sp			; cleanup stack
	tst.w	d0			; test for match
	bne	au_dn			; (no match -- quit)

*--- construct filename from path and the name we just found:
	move.l	pathname,a0		; copy pathname
	move.l	filename,a2		; a2 -> end+1 of pathname
	lea	autoname,a1
au3:	move.b	(a0)+,(a1)+		; copy path part of name
	cmp.l	a0,a2			; finished?
	bne	au3			; (no)
	lea	autodma+30,a0		; copy fname to end of pathname
au2:	move.b	(a0)+,(a1)+
	bne	au2

	pea	nullenv(pc)		; null enviroment
	pea	nullenv(pc)		; no command tail
	pea	autoname		; -> file to exec
	clr.w	-(sp)			; load-and-go
	move.w	#$4b,-(sp)		; exec(...)
	trap	#1
	add.w	#16,sp

	moveq	#2,d7			; reset cleanup amount
	move.w	#$4f,-(sp)		; searchNext
	bra	au1

*+
* The first GEMDOS process can never terminate.
* This is not a good feature.
* Kludge around it -- re-initialize the stack
* and return to the guy who called us to begin with.
*
*-
au_dn:	lea.l	_supstk+supsiz,sp	; setup supervisor stack
	move.l	autoret,-(sp)		; get return addr
	rts				; just jump there ...


*--- bss for auto-exec:
	.bss
autoret:	ds.l	1		; -> _auto's caller (yeccch)
pathname:	ds.l	1		; -> filespec's pathname
filename:	ds.l	1		; -> filename part of path
autodma:	ds.b	44		; 44 bytes for directory search
autoname:	ds.b	32		; 32 bytes for path+filename
	.even

	.text

*+
* _dumpit: dump screen
*
*-
_dumpit:
	move.l	scr_dump,a0
	jsr	(a0)
	move.w	#$ffff,_prtcnt
	rts


*+
* _scrdmp - printScreen(), front-end to _prtblk()
*  Passed:	nothing
*  Returns:	nothing
*  Uses:	everything
*
*-
_scrdmp:
	move.l	_v_bas_ad.w,p_blkptr.w	; -> screen mem
	clr.w	p_offset.w		; offset = 0
	clr.w	d0
	move.b	sshiftmd.w,d0		; get w & h
	move.w	d0,p_srcres.w
	add.w	d0,d0
	lea	reztab(pc),a0
	move.w	(a0,d0.w),p_width.w	; set display width, height
	move.w	6(a0,d0.w),p_height.w
	clr.w	p_left.w		; left = right = 0
	clr.w	p_right.w
	move.l	#color0,p_colpal.w	; -> hardware palettes
	clr.w	p_masks.w		; default masks ptr

* draft or final mode
	move.w	pconfig.w,d1		; p_dstres = pconfig%%3
	lsr.w	#3,d1
	and.w	#1,d1
	move.w	d1,p_dstres.w

* printer or rs232 port
	move.w	pconfig.w,d1		; p_port = pconfig%%4
	move.w	d1,d0
	lsr.w	#4,d0
	and.w	#1,d0
	move.w	d0,p_port.w

* select printer flavor
	and.w	#7,d1			; p_type = ptype[pconfig & 7]
	move.b	ptype(pc,d1.w),d0
	move.w	d0,p_type

* do it
	pea	prtargs.w		; -> beginning of parameter area
	move.w	#1,_prtcnt.w
	bsr	_prtblk			; print it (finally)
	move.w	#-1,_prtcnt		; _prtcnt back to normal
	addq	#4,sp			; cleanup stack
	rts				; and return


*--- screen resolution table (pixels) for printScreen
reztab:	dc.w	320,640,640		; widths
	dc.w	200,200,400		; heights


*--- printer flavors (based on low 3 bits of pconfig)
ptype:
	dc.b	0			; atari mono dot
	dc.b	2			; atari mono daisy
	dc.b	1			; atari color dot
	dc.b	-1			; [atari color daisy???]
	dc.b	3			; epson mono dot
	dc.b	-1			; [epson mono daisy]
	dc.b	-1			; [epson color dot]
	dc.b	-1			; [epson color daisy]
	.even

*--- parameter storage for printScreen:
	.bss
prtargs:
p_blkptr:	ds.l	1		; -> bitmap to print
p_offset:	ds.w	1		; offset on page
p_width:	ds.w	1		; width and height
p_height:	ds.w	1
p_left:		ds.w	1		; left & right leading
p_right:	ds.w	1
p_srcres:	ds.w	1		; source rez (0, 1, 2)
p_dstres:	ds.w	1		; destination rez (0, 1)
p_colpal:	ds.l	1		; -> color palettes
p_type:		ds.w	1		; printer type (0, 1)
p_port:		ds.w	1		; printer port (0, 1)
p_masks:	ds.l	1		; -> halftone masks

	.text

*+
*  Form to display on system catastrophe
*
*-
mushroom:				; (sic)
	dc.w	%0000011000000000
	dc.w	%0010100100000000
	dc.w	%0000000010000000
	dc.w	%0100100001000000
	dc.w	%0001000111110000
	dc.w	%0000000111110000
	dc.w	%0000011111111100
	dc.w	%0000111111111110
	dc.w	%0000110111111110
	dc.w	%0001111111111111
	dc.w	%0001111111101111
	dc.w	%0000111111101110
	dc.w	%0000111111011110
	dc.w	%0000011111111100
	dc.w	%0000001111111000
	dc.w	%0000000011100000

mush_fdb:
	dc.l	mushroom		; fd_addr
	dc.w	16,16,1,0,1		; fd_w,fd_h,fd_wd,fd_stand,fd_planes


*+
*  This function replaces 'vwait' -- it is not to return until
*  it's sure we are NOT in a vblank.  This is accomplished by
*  programming Timer B to count hblanks, then waiting for it
*  to change.  At the instant of change, we know there's 
*  at least a little time before vblank: long enough.
*
*  Passed:	A6 -> return address
*  Returns:	when sure no vblank is in progress
*  Uses:	no registers; clobbers TBDR
*
* Noblank1 is the same thing, but returns via RTS, and...
*  Uses:	d0, d1, d3, d4; clobbers TBDR
* 
* I tried to implement noblank1 without clobbering Timer B, but it's no
* use. The SCU interrupt state register sometimes seems stuck (I think
* because of the synchronous bus).  On the TT there's another MFP where
* Timer B's input is also the hblank counter, but that's no use on Mega
* STe's and other machines with no second MFP.  So I clobber Timer B (and
* disable its interrupt).  Since this only happens during rez changes, I
* don't think that's a hardship: you couldn't count hblanks reliably when
* changing rez anyway.  If you're using Timer B for timing, well, sorry.
* 
* After version [23].05, the noblank1 code was improved slightly: the old 
* timer B enable bit from iera is saved and restored.  Some programs (NEO)
* enable the interrupt, *then* call Setscreen to change rez.  You can't
* reliably count hblanks across a rez change, but you can have the
* interrupt enabled...
*
* Sigh... Saving the iera is probably only half the battle; now I save the
* timer's control register, too.  You STILL can't count hblanks across the
* rez change, but maybe this will help.  I didn't actually see something
* break because of this, but it can't hurt, right?  (5/2/91; in TOS 3.06)
*
* Background first: Timer B ticks based on the falling edge of DE,
* Display Enable.  That happens at the right edge of the nonblank
* part of a horizontal trace.
*
* Now, here is the Lore of Noblank: you can't bang the shift mode register
* at just any time.  If you do it wrong, an ST monochrome monitor will be
* off by 16 pixels: the image is shifted to the right, and what belongs on
* the right edge appears to the left of the left edge.  There is some time
* when it is "safe" and some time when it is not.  This time may or may not
* be the same for all non-TT shifters.  Nobody is giving me a straight
* answer.  There are competing theories, gleaned from code which has worked
* in the past, as to "when it is safe."  One theory is that it's "safe"
* after VBLANK -- that is, after the interrupt at IPL 4 occurs, and the
* handler executes, and the RTE, it is safe.  That is the theory
* implemented by THEORY 3 below.  THEORY 2 states that it's safe after you
* count 240 ticks on Timer B, then wait for 2ms without any ticks on
* Timer B.  THEORY 1 states that it's safe if you get a tick on Timer B at
* all.
*
* What these theories have in common is the idea that the things to be
* avoided are times when display is actually being produced, and something
* around VBLANK.  THEORY 3 most clearly states "it's safe just after
* VBLANK."  THEORY 2 states "it's safe just BEFORE vblank; that is, just
* after the last DE of a trace."  THEORY 1 states "it's safe any time you
* get DE's, because if you get (a rising edge of) DE then you know you're
* far from VBLANK, and you're in HBLANK during which it's safe."
*
* There is also a possible interaction with syncmode; the code I inherited
* which sets syncmode to 50hz waits until it is safe before doing so.
*
* To reiterate what noblank and noblank1 do: they wait until it is "safe"
* and then they return.  noblank returns by jumping through a6, so you
* can call it before RAM is sized or validated.
*
* Theory 1 doesn't work; people think theories 2 and 3 do.  Theory 3
* involves  waiting for a vblank interrupt, so it's not appropriate during
* the boot sequence.  Unfortunately, for TOS 2.06 released 10/91, Theory 1
* survived in the initial, boot-up delay, which is wrong. Theory 3 was used
* by Setscreen(), but by then it's too late.

* noblank: use THEORY 3, it's safe any time you get no ticks on Timer B
* for 2ms after the last tick you did get.
*
* This code can clobber the heck out of Timer B, because it's only used in
* the boot sequence.  For TT it doesn't really count 2ms, but I don't think
* the TT shifter has this problem.  Does it?

.if TT
* TT: wait for any horiz. blanking pulse.
noblank:
	clr.b	tbcr			; halt the timer
	clr.b	tbdr			; load a zero there
	move.b	#$08,tbcr		; start timer B in event-count mode
tb_0:	tst.b	tbdr			; changed yet?
	beq	tb_0			; (not yet)
	jmp	(a6)			; return
.else
* ST, STe, etc: wait for end of screen (2ms with no hblank pulses)
noblank:
	lea	tbdr,a0
	lea	tbcr,a1
	bclr	#0,iera			; disable Timer B interrupt
	moveq	#1,d4			; d4 = number we want
	clr.b	(a1)			; reset timer B
	move.b	#240,(a0)		; number of lines to wait for
	move.b	#$08,(a1)		; startup timer B, in event-count mode
tb_1:	cmp.b	(a0),d4			; down to desired value?
	bne	tb_1			; (not yet)
tb_2:	move.b	(a0),d4			; get current value
	move.w	#615,d3			; 2ms timeout
tb_3:	cmp.b	(a0),d4			; has timer changed?
	bne	tb_2			; (yes, not a vbl)
	dbra	d3,tb_3			; wait for 2ms w/o change
	move.b	#$10,(a1)		; reset timer B
	jmp	(a6)
.endif

* noblank1: see which theory is un-commented.

noblank1:
* THEORY 1: if you get any ticks on Timer B, it's safe.
*	move.b	iera,d0			; save old iera
*	and.b	#1,d0			; (really only old timer B enable)
*	bclr	#0,iera			; disable Timer B's interrupt
*	swap	d0
*	move.b	tbcr,d0			; save old timer control reg
*	clr.b	tbcr			; halt the timer
*	clr.b	tbdr			; load a zero there
*	move.b	#$08,tbcr		; start timer B in event-count mode
*tb_4:	tst.b	tbdr			; changed yet?
*	beq	tb_4			; (not yet)
*	move.b	d0,tbcr			; restore control register
*	swap	d0
*	or.b	d0,iera			; OR in old enable bit for timer B
*	rts				; return


* THEORY 2: it's safe if you count 240 ticks on Timer B, then "2ms" 
* with NO ticks.
*
*	movem.l	d1/d3/d4,-(sp)
*	move.b	iera,d1			; save old Timer B interrupt enable
*	and.b	#1,d1
*	bclr	#0,iera			; disable Timer B interrupt
*	swap	d1
*	move.b	tbcr,d1			; save old Timer B control reg
*	moveq	#1,d4			; d4 = number we want
*	clr.b	tbcr			; reset timer B
*	move.b	#240,tbdr		; number of lines to wait for
*	move.b	#$08,tbcr		; startup timer B, in event-count mode
*tb_1:	move.b	tbdr,d0			; get contents of data reg
*	cmp.b	d4,d0			; down to desired value?
*	bne	tb_1			; (not yet)
*tb_2:	move.b	tbdr,d4			; get current value
*	move.w	#615,d3			; 2ms timeout
*tb_3:	cmp.b	tbdr,d4			; has timer changed?
*	bne	tb_2			; (yes, not a vbl)
*	dbra	d3,tb_3			; wait for 2ms w/o change
*	move.b	#$10,tbcr		; reset timer B
*	move.b	d1,tbcr			; restore the old control value
*	swap	d1
*	or.b	d1,iera			; restore the old interrupt enable
*	movem.l	(sp)+,d1/d3/d4
*	rts
*

* THEORY 3: it's safe when you get a vblank.  This has the drawback of
* calling wvbl, which can drop the IPL.  It has the advantage of being what
* TOS 1.0 and 1.2 did, and of not clobbering Timer B.

	bra	wvbl

* End of noblank code

*+
* Search for a package, execute it.
*
*	+---------------+
*	|   $12123456	| base + 0, on a 512-byte boundary
*	|		|
*	+---------------+
*	|   -> base	| base + 4
*	|		|
*	+---------------+
*	|   (code)	| base + 8
*	/		/
*	/		/
*	|		|
*	+---------------+
*			  base + 512
*
*	The entire 512-byte block should word-checksum to $5678.
*
*-
findpackages:
	move.l	phystop,a0		; a0 -> top of memory
fpk_n:	sub.w	#512,a0			; down 512 bytes
	cmp.l	#$400,a0		; bottom of memory?
	bls	fpk_r			; (yes -- punt)
	cmp.l	#$12123456,(a0)		; check magic #
	bne	fpk_n			; (no match, try next one)
	cmp.l	4(a0),a0		; self-pointer?
	bne	fpk_n			; (doesn't point to itself, retry)

	clr.w	d0			; zero checksum reg
	move.l	a0,a1			; a1 -> block to checksum
	move.w	#$ff,d1			; do 256 words
fpk_1:	add.w	(a1)+,d0		; sum a word
	dbra	d1,fpk_1		;	... until we're done
	cmp.w	#$5678,d0		; magic number to exec()?
	bne	fpk_n			; (no, retry)
	move.l	a0,-(sp)		; save our precious package pointer
	jsr	8(a0)			; call package's code
	move.l	(sp)+,a0		; restore A0
	bra	fpk_n			; (do more blocks)

fpk_r:	rts



*----------------
*
*  Get ikbd/clock chip time
*  Set ikbd/clock chip time
*
getclock:
	lea	_getclock,a3		; a3 -> clock chip handler
	lea	gettime,a4		; a4 -> ikbd handler
	bra	clkswtch

setclock:
	move.w	4(sp),_date		; set GEMDOS date/time (08/89)
	move.w	6(sp),_time
	lea	_setclock,a3		; a3 -> clock chip handler
	lea	settime,a4		; a4 -> ikbd handler

clkswtch:
	bsr	clktest			; clock chip alive?
	bcc	clks1			; (yes --- use it)
	move.l	a4,a3			; a3 -> ikbd handler
clks1:	jmp	(a3)			; jump to handler

.if systype == rom
*----------------
*
*  Make copy of ROM header
*  and patch it up so AHDI works right.
*
copy_header:
	lea	ostext(pc),a0		; a0 -> ROM header
	lea	hdrcopy,a1		; a1 -> RAM destination
	moveq	#sizeof_hdr-1,d0	; size of OS header - 1
cph1:	move.b	(a0,d0.w),(a1,d0.w)	; copy header to RAM
	dbra	d0,cph1

	move.w	cphjmp(pc),-6(a1)	; craft JMP instr
	move.l	4(a1),-4(a1)		; put addr of JMP into instr
	move.w	cphbra(pc),(a1)		; craft BRA back to JMP
	move.w	$1e(a1),$1c(a1)		; copy offending datestamp

	move.l	a1,_sysbase		; _sysbase -> patched OS header
	rts

cphjmp:	jmp	0
cphbra:	bra	cphjmp
.endif


*+
*
*  BIOS call to test for / configure blitter;
*
*    Synopsis:	WORD Blitmode(mode)
*		WORD mode;
*
*    If 'mode' is non-negative (greater than or equal to zero) then
*    set the current graphics mode to 'mode' (see bit field definitions
*    below).  Regardless of 'mode''s value, return the old graphics
*    mode (the state before any set).
*
*    Bit fields in mode are defined as:
*
*      Bit#	Name
*      ------	----------------
*	0	 BLITMODE: 0=soft mode, 1=hard mode
*	1	 BLITCHIP: 0=no blit chip, 1=blit chip exists
*	2..5	 reserved for future use
*	6	 unused, may be 0 or 1
*	7..14	 reserved for future use
*	15	 must be 0
*
*    If an attempt is made to place the machine in hard blit mode
*    and no blit chip exists (BLITCHIP is zero) then the mode is
*    forced to soft.
*
*    The reserved fields are for future blitter capabilities and
*    other graphics chips.  They should be treated as "don't cares"
*    and should be maintained (intact) because they will acquire
*    meaning in the future.
*
* BUG reported: if you don't have a blitter, Blitmode(-1) returns 0. If you
* then you call Blitmode(1) to set "hard blit mode" and then ask for
* Blitmode(-1) it returns 2, meaning the call has installed a blitter!
*-
	.globl	_GETBLT
	.globl	_SETBLT

Blitmode:
	jsr	_TEST_BLT		; test for blit chip
	move.w	d0,d4			; save blt chip status
	move.w	d0,d5			; save blt chip status
	lsr.w	#1,d5			; blit chip installed mask (0 or 1)
	or.w	#$fffe,d5
	jsr	_GETBLT			; get current blit mode
	move.w	d0,d3			;    into a safe register
	move.w	4(sp),d0		; get request mode
	bmi	Bmd_1			; (don't set if mode is negative)
	and.w	d5,d0			; force to soft mode if no chip
	or.w	d4,d0			; replace installed status
.if SPARROW
	bset	#0,d0			; sparrow: force hard blit!
.endif
	jsr	_SETBLT			; set blit mode

Bmd_1:	move.w	d3,d0			; return "old" blit mode
	rts


*+
*
*  Test for blit chip
*
*	==> D0 = 0, no chip
*		 2, chip exists
*
*  We momentarily subvert the bus-error vector, so interrupts
*  are disabled during the test.
*
*-

BLASTER	equ	$ffff8a00

_TEST_BLT:
	move.w	sr,d1			;  save IPL
	move.w	#0,d0			;  D0 = 0, assume no chip
	clr.l	a0			;  A0 -> zero
	move.l	sp,a2			;  A2 = SP on entry

	or.w	#$0700,sr		; turn off interrupts
	move.l	8(a0),a1		; A1 -> old bus error handler
	move.l	#TB_e,8(a0)		; install temp bus error handler
	tst.w	BLASTER(a0)		; touch blitter
	moveq	#2,d0			; no bus error: indicate chip exists

TB_e:	move.l	a1,8(a0)		; restore original bus error vector
	move.w	d1,sr			; restore IPL

	move.l	a2,sp			;  restore SP
	rts				;  and return

*
* Timer routines for TT by AKP 2/16/89
* (Procedures used by other parts of the BIOS for timing delays.)
*
* Uses Timer C of the TT MFP. (could use any timer in any MFP).
* For documentation purposes, say, "Timer C of the TT MFP is used by
* TOS to time short delays.  It should not be used by applications."
*
* USAGE:
*
*	ttwait	delays for a time specified in D0.W: the high
*		byte is the value for the divider, and the low
*		byte is the value for the countdown.  When
*		the time expires, ttwait returns.  No interrupts
*		are used.
*
*	ttdelay	sets up the delay as for ttwait, but returns immediately.
*		When the time has elapsed, WAITBIT of WAITREG gets set.
*		(That's bit 5 of iprb or ttiprb, depending.)
*		(The timer will run ad infinitum, but who cares?)
*		(This is not actually used at this time.)
*
*	dowait	is either ttwait or stwait, for use during boot.
*		Only TT can use ttwait after the boot; stwait uses
*		STMFP Timer A, which is a no-no after booting.
*
* This table will tell what values to use.  The "divider" column shows
* the possible values for the divider and the division it yields.
* The "units" column tells what size tick you get, which is also
* the timeout value you'll see if you use a countdown of one.  The
* "max" column is the length of a timeout if you use a countdown of zero
* (which means 256).  (All values are rounded.)
*
*	 Divider	 Units		  Max
*	--------	-------		--------
*	1 (/4)		 1.6 us		416   us
*	2 (/10)		 4   us		  1   ms
*	3 (/16)		 6   us		  1.6 ms
*	4 (/50)		20   us		  5   ms
*	5 (/64)		26   us		  6.6 ms
*	6 (/100)	40   us		 10   ms
*	7 (/200)	80   us		 20   ms
*
* This code works this way:
*
*	Stop the timer
*	Disable the interrupt
*	Clear the pending bit
*	Mask the interrupt
*	Enable the interrupt
*	Load the timer's prescale register with the appropriate value
*	Set the timer's mode (starts the timer)
*
* The interrupt is enabled but masked so the first time the timer
* counts down to 0 it'll set the bit in the interrupt-pending register.
* We never actually use this interrupt, just the pending bit.
*

WAITBIT		equ	5		; Timer A
NOTWAITBIT	equ	$df		; ~(1<<WAITBIT)

.if TT
WAITREG		equ	ttiprb

	.globl	ttwait
	.globl	ttdelay
	.globl	dowait

dowait:
ttwait:
	bsr	ttdelay
twait1:	btst.b	#WAITBIT,WAITREG	; while not pending
	beq	twait1			; just wait
	rts				; and return (timer still running)

ttdelay:
	movem.w	d0/d1,-(sp)		; save regs we use, incl input (d0)
	move.w	sr,-(sp)
	or.w	#$0700,sr		; at IPL 7...
	move.b	tttcdcr,d1		; don't disturb timer D's state
	and.b	#$0f,d1
	move.b	d1,tttcdcr		; stop timer C (zero in hi 4 bits)
	bclr.b	#WAITBIT,ttierb		; disable int
	move.b	#NOTWAITBIT,ttiprb	; clear pending
	bclr.b	#WAITBIT,ttimrb		; mask int
	bset.b	#WAITBIT,ttierb		; enable int

	move.b	d0,tttcdr		; set data value
	lsr.w	#4,d0			; get ctl value to hi 4 bits of d0.b
	and.b	#$f0,d0			; clear lo bits of d0.b
	or.b	d0,d1			; OR bits into d1 (which has td's cr)
	move.b	d1,tttcdcr		; move new value into tcdcr
	move.w	(sp)+,sr		; restore IPL
	movem.w	(sp)+,d0/d1		; restore regs
	rts				; and return

.else

*
* ST equivalents for ttwait and ttdelay; they use STMFP Timer A, and therefore
* can only be used during the boot; Timer A is reserved for applications
* after that.
*
* Short delays after boot are sometimes done by relying on counting changes
* in STMFP Timer C's countdown register.
*

WAITREG		equ	ipra

	.globl	stwait
	.globl	stdelay
	.globl	dowait

dowait:
stwait:
	bsr	stdelay
swait1:	btst.b	#WAITBIT,WAITREG
	beq	swait1
	clr.b	tacr
	rts

stdelay:
	move.w	sr,-(sp)
	or.w	#$0700,sr		; at IPL 7...
	clr.b	tacr			; stop timer
	bclr.b	#WAITBIT,iera		; disable int
	move.b	#NOTWAITBIT,ipra	; clear pending
	bclr.b	#WAITBIT,imra		; mask int
	bset.b	#WAITBIT,iera		; enable int
	move.w	(sp)+,sr		; restore IPL

	move.b	d0,tadr			; set data value
	ror.w	#8,d0			; get mode byte into d0.b
	move.b	d0,tacr			; start the clock (mode from d0)
	rol.w	#8,d0			; restore d0
	rts				; and return
.endif

*+
*
*  Quickly zero (lots of) memory.
*  Copyright 1986 Atari Corp. (stolen from clear.s, which is now obsolete)
*
*  Synopsis:	clear(start, end)
*		    LONG start;	    4(sp) -> first location
*		    LONG end;	    8(sp) -> last location + 1
*
*    Uses:	C registers d0-d2/a0-a2
*
*-
	.globl _clear
_clear:
	move.l	4(sp),a0		; a0 -> start
	move.l	8(sp),a1		; a1 -> end+1
	movem.l	d3-d7/a3,-(sp)		; save registers

	moveq	#0,d1			; get lots of cheap zeros
	moveq	#0,d2			; into d1-d7/a3
	moveq	#0,d3
	moveq	#0,d4
	moveq	#0,d5
	moveq	#0,d6
	moveq	#0,d7
	move.w	d7,a3

	move.l	a0,d0			; word align first location
	btst	#0,d0
	beq	clr1			; (not necessary)
	move.b	d1,(a0)+

clr1:	move.l	a1,d0			; d0 = ((a1 - a0) & ~0xff)
	sub.l	a0,d0
	and.l	#$ffffff00,d0		; mask fractional bits, d0 = whole part
	beq	clr3			; if (d0 == 0) do end-fraction;
	lea	(a0,d0.l),a0		; a0 -> end of huge area
	move.l	a0,a2			; a2 -> there, too
	lsr.l	#8,d0			; get 256-byte chunk count

clr2:	movem.l	d1-d7/a3,-(a2)		; clear 32 bytes
	movem.l	d1-d7/a3,-(a2)		; clear 32 bytes
	movem.l	d1-d7/a3,-(a2)		; clear 32 bytes
	movem.l	d1-d7/a3,-(a2)		; clear 32 bytes
	movem.l	d1-d7/a3,-(a2)		; clear 32 bytes
	movem.l	d1-d7/a3,-(a2)		; clear 32 bytes
	movem.l	d1-d7/a3,-(a2)		; clear 32 bytes
	movem.l	d1-d7/a3,-(a2)		; clear 32 bytes
	subq.l	#1,d0			; decrement count
	bne	clr2			; while (d0) clear some more...

clr3:	cmp.l	a0,a1			; while (a0 != a1)
	beq	clr4			; (done)
	move.b	d1,(a0)+		; clear a byte
	bra	clr3

clr4:	movem.l	(sp)+,d3-d7/a3		; restore registers
	rts

.if M68030

************************************************************************
* 
* This section contains code to initialize the MMU in the 68030. Its job is
* to set the "cache disable" bit for areas of memory which are not
* supposed to be cached.
* 
* It is necessary for the following (fairly involved) reason.
* 
* 1. We must run with the "write enable" bit of the cache on. This is
* because we want to be able to write to a place in user mode, then write
* it in super mode, then read it in user mode and not get stale data.
* 
* 2. When running with "write enable" set, a long write to a long
* boundary always allocates a cache line for that address. This is true
* WITHOUT REGARD TO THE CACHE-INHIBIT-IN (CIIN) line. Subsequent reads
* from this address will come from cache, not the I/O bus.
* 
* 3. Setting the cache inhibit bit in the PMMU for those areas requiring
* it solves this problem because the CIOUT (cache-inhibit-out) bit *is*
* tested by the cache logic even on those long-boundary long writes.
* 
* 
* We must set up the following map:
* 
* 	ADDRESS	Cacheable?
* 	000-00E	    yes	    ST RAM, ROM
* 	00F	    no	    ST I/O space
* 	010-7FF	    yes	    Fast RAM, cacheable VME RAM
* 	800-FEF	    no	    Non-cacheable VME space
* 	FF0-FFE	    yes	    ST-image RAM, ROM
* 	FFF	    no	    ST-image I/O space
* 
* The obvious choice for page size, then, is one megabyte.  Three levels
* of MMU are used, corresponding to the three high nybbles of the
* address.  (The fourth level is set up but actually unused: all the
* Level C entries are page descriptors, not table pointers.)
* 
* At level A:
* 
* $0 points to level B's first table.
* $1 through $7 hold "direct map, cache enable" page descriptors.  
* $8 through $E hold "direct map, cache inhibit" page descriptors.
* $F points to level B's second table.
* 
* Level B's first table (from level A's $0 entry):
* 
* $0 holds a pointer to level C.
* $1 through $F hold "direct map, cache enable" page descriptors.
* 
* Level B's second table (from level A's $F entry):
* 
* $0 through $E hold "direct map, cache inhibit" page descriptors.
* $F holds a pointer to level C.
* 
* Level C's (single) table: (maps $00x and $FFx):
* 
* $0 through $E hold "direct map, cache enable" page descriptors.
* $F holds a "direct map, cache inhibit" page descriptor.
* 
* There is no level D table: the translation will never get that far
* before reaching a page descriptor.  However, D level is used, to mark
* the five bits you add to the 32K page size for a total mapping
* granularity of 1MB.
* 
* There is only one root pointer, and we don't use the function code
* bits.
* 
* This is not a zero-cost solution, since the ATC uses the address (less
* the bits which make up the byte index into the page) as the tag: each
* different 32K you touch needs an entry in the ATC, and there are only
* 22 entries in the ATC.  The 23rd page you touch will require four
* memory accesses: three for the table walk and one for the physical
* access.
* 
* This situation can be improved using the Transparent Translation
* Registers. They are set up in a way which is redundant (they do the
* same mapping as the full table) but quicker and without touching the
* ATC. TT0 is set up to map %0xxx xxx1 addresses with cache enabled, and
* TT1 transparently maps %1xxx xxx0 addresses with cache inhibited. 
* These handle (primarily) TT fast RAM, and the first 16MB of
* non-cacheable VME space.  Other megabytes happen to be lumped in there,
* too, but those are the main targets.  TT1 might be re-used to map %0xxx
* xx10 since covers the second 16MB of VME RAM (along with other 16MB
* hunks).
* 
* Since the root pointer and the tables must appear at a 4-byte boundary,
* this file must be included in the first file in the link which has 
* anything in the text segment.  That means STARTUP.S for the most part.
*
* Furthermore, the logical addresses $FFx and $00x map to physical
* $00x, meaning:
* 
*   ONCE YOU SET UP THE MMU YOU CAN'T CHANGE THE FAST RAM REFRESH RATE.
* 
* The translation table is in ROM because that way it can't be corrupted.
* 
* You must copy this table into RAM, since the MMU writes "updated"
* bits to it unconditionally.  You even have to do the copy if you have
* a RAM TOS, since the tables won't be aligned properly otherwise.
*
*************************************************************************

tce	equ	1	; enable
tcsre	equ	0	; don't split super/user
tcfcl	equ	0	; don't use FC bits at top level
tcps	equ	15	; page size is 15 bits (32K)
tcis	equ	0	; initial shift of zero
tctia	equ	4	; four bits in A level
tctib	equ	4	; four bits in B level
tctic	equ	4	; four bits in C level
tctid	equ	5	; five bits in (unused!) D level

tte	equ	1	; enable for TT registers

* NOTE: these tables are copied into RAM at the labels levelA,
* levelB1, levelB2, levelC.  These labels are found just after
* the system variables: $100 bytes starting at $700
*
* The tables must be in RAM because the dirty bits get written,
* and you can't write to ROM.  They must be on 16-byte boundaries.
* Hmm - if the dirty and modified bits of every entry were ALREADY
* set, then the CPU would never attempt to write them, would it?
* Then these could be in ROM!  That would increase compatibility
* by a little.
*
* There used to be a bug here (in 3.06 and older): the levelB2 entries
* were (for instance) $01000000 instead of $f1000000.  This bug was
* masked by the fact that a transparent translation register was used
* to map anything with a high byte of %1xxxxxx0 as non-cacheable, and
* that covered VME space on the TT.
*

.data

_levelA:
	dc.l	levelB1+%0010		; translates $0 nybble
	dc.l	$10000000+%00000001	; $1 - cacheable
	dc.l	$20000000+%00000001	; $2 - cacheable
	dc.l	$30000000+%00000001	; $3 - cacheable
	dc.l	$40000000+%00000001	; $4 - cacheable
	dc.l	$50000000+%00000001	; $5 - cacheable
	dc.l	$60000000+%00000001	; $6 - cacheable
	dc.l	$70000000+%00000001	; $7 - cacheable
	dc.l	$80000000+%01000001	; $8 - cache inhibit
	dc.l	$90000000+%01000001	; $9 - cache inhibit
	dc.l	$a0000000+%01000001	; $A - cache inhibit
	dc.l	$b0000000+%01000001	; $B - cache inhibit
	dc.l	$c0000000+%01000001	; $C - cache inhibit
	dc.l	$d0000000+%01000001	; $D - cache inhibit
	dc.l	$e0000000+%01000001	; $E - cache inhibit
	dc.l	levelB2+%0010		; translates $F nybble

_levelB1:
	dc.l	levelC+%0010		; translates $00 byte
	dc.l	$01000000+%00000001	; $01 - cacheable
	dc.l	$02000000+%00000001	; $02 - cacheable
	dc.l	$03000000+%00000001	; $03 - cacheable
	dc.l	$04000000+%00000001	; $04 - cacheable
	dc.l	$05000000+%00000001	; $05 - cacheable
	dc.l	$06000000+%00000001	; $06 - cacheable
	dc.l	$07000000+%00000001	; $07 - cacheable
	dc.l	$08000000+%00000001	; $08 - cacheable
	dc.l	$09000000+%00000001	; $09 - cacheable
	dc.l	$0a000000+%00000001	; $0a - cacheable
	dc.l	$0b000000+%00000001	; $0b - cacheable
	dc.l	$0c000000+%00000001	; $0c - cacheable
	dc.l	$0d000000+%00000001	; $0d - cacheable
	dc.l	$0e000000+%00000001	; $0e - cacheable
	dc.l	$0f000000+%00000001	; $0f - cacheable

_levelB2:
	dc.l	$f0000000+%01000001	; $f0 - inhibit
	dc.l	$f1000000+%01000001	; $f1 - inhibit
	dc.l	$f2000000+%01000001	; $f2 - inhibit
	dc.l	$f3000000+%01000001	; $f3 - inhibit
	dc.l	$f4000000+%01000001	; $f4 - inhibit
	dc.l	$f5000000+%01000001	; $f5 - inhibit
	dc.l	$f6000000+%01000001	; $f6 - inhibit
	dc.l	$f7000000+%01000001	; $f7 - inhibit
	dc.l	$f8000000+%01000001	; $f8 - inhibit
	dc.l	$f9000000+%01000001	; $f9 - inhibit
	dc.l	$fa000000+%01000001	; $fa - inhibit
	dc.l	$fb000000+%01000001	; $fb - inhibit
	dc.l	$fc000000+%01000001	; $fc - inhibit
	dc.l	$fd000000+%01000001	; $fd - inhibit
	dc.l	$fe000000+%01000001	; $fe - inhibit
	dc.l	levelC+%0010	; translates $FF byte into $00

_levelC:
	dc.l	$00000000+%00000001	; $000/ff0 - enable
	dc.l	$00100000+%00000001	; $000/ff1 - enable
	dc.l	$00200000+%00000001	; $000/ff2 - enable
	dc.l	$00300000+%00000001	; $000/ff3 - enable
	dc.l	$00400000+%00000001	; $000/ff4 - enable
	dc.l	$00500000+%00000001	; $000/ff5 - enable
	dc.l	$00600000+%00000001	; $000/ff6 - enable
	dc.l	$00700000+%00000001	; $000/ff7 - enable
	dc.l	$00800000+%00000001	; $000/ff8 - enable
	dc.l	$00900000+%00000001	; $000/ff9 - enable
	dc.l	$00a00000+%00000001	; $000/ffa - enable
	dc.l	$00b00000+%00000001	; $000/ffb - enable
	dc.l	$00c00000+%00000001	; $000/ffc - enable
	dc.l	$00d00000+%00000001	; $000/ffd - enable
	dc.l	$00e00000+%00000001	; $000/ffe - enable
	dc.l	$00f00000+%01000001	; $00f/fff - inhibit

tabsize	equ	*-_levelA

_rootptr:
	dc.w	$8000,$0002	; limit is unused, Level A=short format
	dc.l	levelA

tcval:	dc.b	(tce << 7) | (tcsre << 1) | (tcfcl)
	dc.b	(tcps << 4) | (tcis)
	dc.w	(tctia << 12) | (tctib << 8) | (tctic << 4) | (tctid)

* tt0: map %0xxxxxx1 transparently, ignore r/w, cache enable, ignore FC
* tt1: map %1xxxxxx0 transparently, ignore r/w, cache inhibit, ignore FC

tt0val:	dc.b	%00000001, %01111110, %00000001 | (tte << 7), %00000111
tt1val:	dc.b	%10000000, %01111110, %00000101 | (tte << 7), %00000111

.text

*
* MMUSETUP is a procedure you BSR to for setting up the MMU any
* time you like.  Do it before enabling the cache, though, or
* the whole write-enable thing can bite you very early on.
*

.globl mmusetup
mmusetup:

	lea.l	levelA,a0
	lea.l	_levelA,a1
	move.w	#(tabsize/4)-1,d0
mmuloop:
	move.l	(a1)+,(a0)+
	dbra	d0,mmuloop

* IF YOU WANT TO MAP $0Fxxxxxx to $00xxxxxx DO IT HERE:
*	clr.b	levelB1+$3c		; change byte $0F to $00 in this entry

	pmove	_rootptr,crp
	pmove	tcval,tc
*
* These lines replaced by hand-assembled constants because mas has bugs
*	pmove	tt0val,tt0
	dc.l	$f0390800, tt0val
*	pmove	tt1val,tt1
	dc.l	$f0390c00, tt1val
	rts

*
* end of ifne TT for MMU code
*
.endif

.if crcstride

* CRC GENERATOR USED IN TT DIAGNOSTICS

* This version computes a CRC on a range with a stride: the input is
* the first address to compute, and the number of bytes TO COMPUTE,
* and the stride between bytes.  If you are on a TT in megabit parts,
* the count arg should be 128K minus two bytes, and the stride should
* be four.

_toscrc:
	move.l	4(sp),a0	; first address
	move.l	8(sp),d2	; number of bytes
	move.w	$c(sp),a1	; stride (a1 is handy)

*-------------------------------
*	generate crc for a block of data
*	entry:	a0.l = start of block
*		d2.l = number of bytes
*	exit:	d0.w = crc
*	regs:	d0,d1,d2,d3,d4,a0,and a2 destroyed

        clr.w	d0
	clr.w	d1
	clr.w	d3
	lea	crctab,a2
crclp:	move.w	d0,d1		;d1=current crc value
	lsl.w	#8,d0		;shift left (low byte in high)
	lsr.w	#8,d1		;shift right (high byte in low)
	move.b	(a0),d3		;get next byte in stream
	add.l	a1,a0		;increment by stride
	eor.b	d3,d1		;eor with right shifted crc (high byte)
	add.w	d1,d1		;*2; faster than lsl.w
	move.w	0(a2,d1.w),d4	;use as offset into crctab
	eor.w	d4,d0		;eor with lsl'd crc
	subq.l	#1,d2		;decr count
	bne	crclp		;until all bytes crc'd
	rts

.data

*	divisor for crc
crctab:
	dc.w	$0000,$1021,$2042,$3063,$4084,$50a5,$60c6,$70e7
	dc.w	$8108,$9129,$a14a,$b16b,$c18c,$d1ad,$e1ce,$f1ef
	dc.w	$1231,$0210,$3273,$2252,$52b5,$4294,$72f7,$62d6
	dc.w	$9339,$8318,$b37b,$a35a,$d3bd,$c39c,$f3ff,$e3de
	dc.w	$2462,$3443,$0420,$1401,$64e6,$74c7,$44a4,$5485
	dc.w	$a56a,$b54b,$8528,$9509,$e5ee,$f5cf,$c5ac,$d58d
	dc.w	$3653,$2672,$1611,$0630,$76d7,$66f6,$5695,$46b4
	dc.w	$b75b,$a77a,$9719,$8738,$f7df,$e7fe,$d79d,$c7bc
	dc.w	$48c4,$58e5,$6886,$78a7,$0840,$1861,$2802,$3823
	dc.w	$c9cc,$d9ed,$e98e,$f9af,$8948,$9969,$a90a,$b92b
	dc.w	$5af5,$4ad4,$7ab7,$6a96,$1a71,$0a50,$3a33,$2a12
	dc.w	$dbfd,$cbdc,$fbbf,$eb9e,$9b79,$8b58,$bb3b,$ab1a
	dc.w	$6ca6,$7c87,$4ce4,$5cc5,$2c22,$3c03,$0c60,$1c41
	dc.w	$edae,$fd8f,$cdec,$ddcd,$ad2a,$bd0b,$8d68,$9d49
	dc.w	$7e97,$6eb6,$5ed5,$4ef4,$3e13,$2e32,$1e51,$0e70
	dc.w	$ff9f,$efbe,$dfdd,$cffc,$bf1b,$af3a,$9f59,$8f78
	dc.w	$9188,$81a9,$b1ca,$a1eb,$d10c,$c12d,$f14e,$e16f
	dc.w	$1080,$00a1,$30c2,$20e3,$5004,$4025,$7046,$6067
	dc.w	$83b9,$9398,$a3fb,$b3da,$c33d,$d31c,$e37f,$f35e
	dc.w	$02b1,$1290,$22f3,$32d2,$4235,$5214,$6277,$7256
	dc.w	$b5ea,$a5cb,$95a8,$8589,$f56e,$e54f,$d52c,$c50d
	dc.w	$34e2,$24c3,$14a0,$0481,$7466,$6447,$5424,$4405
	dc.w	$a7db,$b7fa,$8799,$97b8,$e75f,$f77e,$c71d,$d73c
	dc.w	$26d3,$36f2,$0691,$16b0,$6657,$7676,$4615,$5634
	dc.w	$d94c,$c96d,$f90e,$e92f,$99c8,$89e9,$b98a,$a9ab
	dc.w	$5844,$4865,$7806,$6827,$18c0,$08e1,$3882,$28a3
	dc.w	$cb7d,$db5c,$eb3f,$fb1e,$8bf9,$9bd8,$abbb,$bb9a
	dc.w	$4a75,$5a54,$6a37,$7a16,$0af1,$1ad0,$2ab3,$3a92
	dc.w	$fd2e,$ed0f,$dd6c,$cd4d,$bdaa,$ad8b,$9de8,$8dc9
	dc.w	$7c26,$6c07,$5c64,$4c45,$3ca2,$2c83,$1ce0,$0cc1
	dc.w	$ef1f,$ff3e,$cf5d,$df7c,$af9b,$bfba,$8fd9,$9ff8
	dc.w	$6e17,$7e36,$4e55,$5e74,$2e93,$3eb2,$0ed1,$1ef0
.text

.endif

.if TT
**********************************************************************
*
* TT Video calls
*

*******
*******
ESHIFTMD	equ	$ffff8262	; EST video shift mode regiter
ELUTBANK	equ	$ffff8263	; EST bank select register
ESTLUT		equ	$ffff8400	; start of EST color lookup table regs


* - High byte (bits 16..23), middle byte (bits 8..15), low byte (bits 0..7)
ESTVBH		equ	$ffff8201	; EST Video Base High Byte (= dbaseh)
ESTVBM		equ	$ffff8203	; EST Video Base Middle Byte (= dbasel)
ESTVBL		equ	$ffff820d	; EST Video Base Low Byte



*+
* _EsetShift: - Set the TT shify mode register
*
* Synopsis:	_EsetShift
*		WORD _EsetShift(shftMode)
*		WORD shftMode;
*-
_EsetShift:
	bsr	noblank1		; wait until not blanking
	moveq.l	#0,d0			; pre-clear return code
	move.w	shiftmd,-(sp)		; save return value
	move.w	6(sp),shiftmd		; set shift mode register
	move.w	shiftmd,d0		; d0 <- curr rez
	and.w	#7,d0			; mask off unwanted bits
	move.b	d0,sshiftmd.w		; set software shadow
	clr.w	vblsem.w		; disable vblank processing
	jsr	esc_init		; re-initialize glass tty routines
	move.w	#1,vblsem.w		; re-enable vblank
	move.w	(sp)+,d0		; d0 <- gets old shift mode value
	rts	



*+
* _EgetShift: - Get the TT shify mode register
*
* Synopsis:	_EgetShift
*		WORD _EgetShift()
*-
_EgetShift:
	moveq.l	#0,d0			; pre-clear return code
	move.w	shiftmd,d0		; d0 <- shift mode register value
	rts	


*+
*
* _EsetBank - set the bank number of the EST hardware shift register.
*             Old Bank number is returned in d0.w
*
* Synopsis:	_EsetBank
*		WORD _EsetBank(bankNum)
*		WORD bankNum;
*-
_EsetBank:
	moveq.l	#0,d0			; pre-clear return code
	move.w	ESHIFTMD,d0		; d0 is the return value
	and.w	#$f,d0			; return old bank number
	tst.w	4(sp)			; see if new bank < 0
	bmi	estbnk			; if so, leave without changing bank
	move.b	5(sp),ELUTBANK		; set new bank number
estbnk:	rts



*+
*
* _EsetColor - set EST look up table entry with a new color.
*              Old color is returned d0.w
*
* Synopsis:	_EsetColor
*		WORD _EsetColor(colorNum, color)
*		WORD colorNum, color;
*-
_EsetColor:
	moveq.l	#0,d0			; pre-clear return code
	lea	ESTLUT,a0		; load EST look up table address
	move.w	4(sp),d0		; load table offset
	and.w	#$ff,d0			; offset must be < 256 (prevent buserr)
	add.w	d0,d0			; turn offset into word index
	add.w	d0,a0			; a0 -> color register
	move.w	(a0),d0			; return old color in d0.w
	and.w	#$0fff,d0		; mask dirty bits
	move.w	6(sp),d1		; d2 <- new color
	bmi	stclr			; if color < 0 leave
	move.w	d1,(a0)			; load new color into lut
stclr:	rts



*+
* _EsetPalette - Set the contents of a contiguous set of EST hardware color
*                LookUp Table registers.
*
* Synopsis:	_EsetPalette
*		VOID _EsetPalette(colorNum, count, palettePtr)
*		WORD colorNum, count;
*		LONG palettePtr;
*-
_EsetPalette:
	move.w	4(sp),d0		; d0 <- colorNum
	and.w	#$ff,d0			; colorNum  must be < 256
	move.w	d0,a0			; a0 becomes index for dest.
	adda.w	a0,a0			; make a0 a word index
	sub.w	#256,d0			; d0 = colorNum - 256
	neg.w	d0			; d0 <- maxCount
	move.w	6(sp),d1		; d1 <- count (set by the user)
	cmp.w	d0,d1			; check to see if count > maxCount
	ble	eset_ok			; branch if count is ok
	move.w	d0,d1			; count <- maxCount

eset_ok:
	move.l	8(sp),a1		; a1 <- palettePtr (source)
	lea	ESTLUT(a0),a0		; a0 <- lutPtr (destination)
	bra	eset_dec

eset_loop:
	move.w	(a1)+,(a0)+		; load look up table

eset_dec:
	dbra	d1,eset_loop		; do untill count = -1
	rts
	

*+
* _EgetPalette - Get the contents of a contiguous set of EST hardware color
*                color LookUp Table registers.
*
* Synopsis:	_EgetPalette
*		VOID _EgetPalette(colorNum, count, palettePtr)
*		WORD colorNum, count;
*		LONG palettePtr;
*-
_EgetPalette:
	move.w	4(sp),d0		; d0 <- colorNum
	and.w	#$ff,d0			; colorNum  must be < 256
	move.w	d0,a0			; a0 becomes index for source.
	adda.w	a0,a0			; make a0 a word index
	sub.w	#256,d0			; d0 = colorNum - 256
	neg.w	d0			; d0 <- maxCount
	move.w	6(sp),d1		; d1 <- count (set by the user)
	cmp.w	d0,d1			; check to see if count > maxCount
	ble	eget_ok			; branch if count is ok
	move.w	d0,d1			; count <- maxCount

eget_ok:
	move.l	8(sp),a1		; a1 <- palettePtr (destination)
	lea	ESTLUT(a0),a0		; a0 <- lutPtr (source)
	bra	eget_dec

eget_loop:
	move.w	(a0)+,(a1)+		; load look up table

eget_dec:
	dbra	d1,eget_loop		; do untill count = -1
	rts


*+
*
* _EsetGray - Turn EST hardware shift register, hyper mono bit on/off.
*             old smear value is returned in d0.w.
*
* Synopsis:	_EsetGray
*		WORD _EsetGray(switch)
*		WORD switch;
*-
_EsetGray:
	moveq.l	#0,d0			; pre-clear the return code
	move.b	ESHIFTMD,d1		; d1 <- byte where hyper mono bit is
	move.b	d1,d0			; d0 <- is the return value
	lsr.b	#4,d0			; shift mono bit to the right
	and.b	#1,d0			; isolate mono bit
	bclr.l	#4,d1			; assume hyper mono bit should be (0)
	tst.w	4(sp)			; test the switch parameter
	beq	stgr0			; if switch = 0 set ESHIFTMD
	bmi	stgr1			; leave withoout changing
	bset.l	#4,d1			; set hyper mono bit to on (1)
stgr0:	move.b	d1,ESHIFTMD 		; set the hardware register
stgr1:	rts


*+
*
* _EsetSmear - Turn EST hardware shift register, sample and hold bit on/off.
*              old 
*
* Synopsis:	_EsetSmear
*		WORD _EsetSmear(switch)
*		WORD switch;
*-
_EsetSmear:
	moveq.l	#0,d0			; pre-clear the return code
	move.b	ESHIFTMD,d1		; d1 <- byte where smear bit is
	move.b	d1,d0			; d0 <- is the return value
	add.b	d0,d0			; smear bit (bit 7) loaded into x flag
	subx.w	d0,d0			; if smear bit is on d0 <- ffff else 0
	neg.w	d0			; if smear is on return (1) else (0)
	bclr.l	#7,d1			; assume smear bit should be (0)
	tst.w	4(sp)			; test the switch parameter
	beq	stmr0			; if switch = 0 set ESHIFTMD
	bmi	stmr1			; leave without changing
	bset.l	#7,d1			; set smear bit on (1)
stmr0:	move.b	d1,ESHIFTMD		; set the hardware register
stmr1:	rts

.endif
* End of TT video calls

*------ jump table for BIOS functions:

.if (M68030 == 0)
ibit	equ	$80000000	; on not-M68030, we check hi bit for indirect
.else
ibit	equ	$00000001	; on M68030, we check lo bit for indirect
.endif

trp13tab:
	dc.w	12			; number of entries in jump table
	dc.l	_get_mpb		; 0: get memory parameter block
	dc.l	bconstat		; 1: console status (input)
	dc.l	bconin			; 2: console input
	dc.l	bconout			; 3: console output
.if M68030
	dc.l	m030_rw			; 4: disk read/write with clrcache
.else
	dc.l	hdv_rw + ibit		; 4: [indirect] disk read/write
.endif
	dc.l	_setexc			; 5: set exception vector
	dc.l	_tickcal		; 6: return tick calibration
	dc.l	hdv_bpb + ibit		; 7: [indirect] get BPB
	dc.l	bcostat			; 8: console status (output)
	dc.l	hdv_mediach + ibit	; 9: [indirect] media change inquiry
	dc.l	_drvmap			; 10: get active-drive bit vector
	dc.l	_shift			; 11: get/set keyboard shift bits

* BIOS function $11 is assigned for DIAB630 unless I can get around it.


*------ jump table for Atari BIOS extensions:
trp14tab:
.if (TT+SPARROW == 0)
	dc.w	65			; number of entry points
.else
.if (SPARROW == 0)
	dc.w	96			; number of TT entry points
.else
	dc.w	160
.endif
.endif
	dc.l	initmous		; 0: initialize mouse
	dc.l	_rts			; 1: (reserved)
	dc.l	_physbase		; 2: get physical screen base
	dc.l	_logbase		; 3: get logical screen base
	dc.l	_getrez			; 4: get screen resolution
	dc.l	_setscreen		; 5: set video parameters
	dc.l	_setpalette		; 6: set palette
	dc.l	_setcolor		; 7: set single color
	dc.l	_floprd			; 8: read floppy sector(s)
	dc.l	_flopwr			; 9: write floppy sector
	dc.l	_flopfmt		; 10: format floppy track
	dc.l	_getdsb			; 11: no-op (but returns 0L);
					; 11 is also used by AKP's debugger, DB
	dc.l	midiws			; 12: write string to MIDI port
	dc.l	mfpint			; 13: initialize MFP interrupt
	dc.l	iorec			; 14: set I/O record
	dc.l	rsconf			; 15: configure RS-233 communications
	dc.l	keytrans		; 16: set keyboard translation tables

	dc.l	_rand			; 17: generate 24-bit random number
	dc.l	_proto_bt		; 18: prototype boot sector
	dc.l	_flopver		; 19: floppy verify

	dc.l	_dumpit			; 20: dump screen
	dc.l	_cursconf		; 21: get/set cursor configuration
	dc.l	setclock		; 22: set ikbd/clock chip time
	dc.l	getclock		; 23: get ikbd/clock chip time
	dc.l	bioskeys		; 24: reset keyboard to powerup default
	dc.l	ikbdws			; 25: write string to ikbd

	dc.l	jdisint			; 26: disable mfp interrupt
	dc.l	jenabint		; 27: enable mfp interrupt
	dc.l	giaccess		; 28: read/write sound chip
	dc.l	offgibit		; 29: reset bit in sound chip register
	dc.l	ongibit			; 30: set bit in sound chip register
	dc.l	xbtimer			; 31: initialize mfp timer
	dc.l	dosound			; 32: startup sound daemon
	dc.l	setprt			; 33: get/set printer configuration
	dc.l	ikbdvecs		; 34: return ptr to base of kbd vars
	dc.l	kbrate			; 35: get/set keyboard repeat rate
	dc.l	_prtblk			; 36: _prtblk primitive
	dc.l	wvbl			; 37: wait for next vblank
	dc.l	supexec			; 38: execute in super mode
	dc.l	puntaes			; 39: throw away AES

	dc.l	unimpl			; 40: COOK THIS!  Kbad's cookie call
	dc.l	_floprate		; 41: get/set floppy seek rate

	dc.l	_dmaread		; 42: _dmaread call
	dc.l	_dmawrite		; 43: _dmawrite call
	dc.l	_bconmap		; 44: _bconmap call
	dc.l	unimpl			; 45: bconctl (when ready)
.if (TT | SPARROW)
	dc.l	NVMaccess		; 46: nvmaccess
.else
	dc.l	unimpl
.endif
	dc.l	_waketime		; 47: Waketime

* 0x30..0x3f: assigned to M.Schmal's MetaDOS

	dc.l	unimpl			; 48: Minit(a)
	dc.l	unimpl			; 49: Mopen(a,b)

	dc.l	unimpl			; 50: Mclose(a)
	dc.l	unimpl			; 51: Mread(a,b,c,d)
	dc.l	unimpl			; 52: (?) Mwrite(a,b,c,d)
	dc.l	unimpl			; 53: Mseek(a,b)
	dc.l	unimpl			; 54: Mstatus(a,b)
	dc.l	unimpl			; 55: assigned
	dc.l	unimpl			; 56: assigned
	dc.l	unimpl			; 57: assigned
	dc.l	unimpl			; 58: CDread_aud(a,b,c,d)
	dc.l	unimpl			; 59: CDstart_aud(a,b,c)

	dc.l	unimpl			; 60: CDstop_aud(a)
	dc.l	unimpl			; 61: CDset_songtime(a,b,c,d)
	dc.l	unimpl			; 62: CDget_toc(a,b,c)
	dc.l	unimpl			; 63: CDdisc_info(a,b)
	dc.l	Blitmode		; 64: Blitmode(mode)

.if (TT+SPARROW)
	dc.l	unimpl			; 65: assigned to Arabic TOS
	dc.l	unimpl			; 66: assigned
	dc.l	unimpl			; 67: assigned
	dc.l	unimpl			; 68: assigned
	dc.l	unimpl			; 69: assigned

	dc.l	unimpl			; 70: assigned
	dc.l	unimpl			; 71: assigned end of Arabic TOS
	dc.l	unimpl			; 72: (0x48) assigned
	dc.l	unimpl			; 73: assigned
	dc.l	unimpl			; 74: assigned
	dc.l	unimpl			; 75: assigned
	dc.l	unimpl			; 76: assigned
	dc.l	unimpl			; 77: assigned
	dc.l	unimpl			; 78: assigned
	dc.l	unimpl			; 79: assigned
.endif
.if TT
	dc.l	_EsetShift		; 80: TT shifter stuff
	dc.l	_EgetShift		; 81
	dc.l	_EsetBank		; 82
	dc.l	_EsetColor		; 83
	dc.l	_EsetPalette		; 84
	dc.l	_EgetPalette		; 85
	dc.l	_EsetGray		; 86
	dc.l	_EsetSmear		; 87
	dc.l	unimpl			; 88: assigned (more more VDI calls)
	dc.l	unimpl			; 89: assigned

	dc.l	unimpl			; 90: assigned
	dc.l	unimpl			; 91: assigned
	dc.l	unimpl			; 92: assigned
	dc.l	unimpl			; 93: assigned
	dc.l	unimpl			; 94: assigned
	dc.l	unimpl			; 95: assigned
.endif
.if SPARROW
* 80-87 unimplemented on Sparrow

	dc.l	unimpl,unimpl,unimpl,unimpl,unimpl,unimpl,unimpl,unimpl

* 88-95 Sparrow video calls from vtg.o

	dc.l	_VsetMode		; 88
	dc.l	_VgetMonitor		; 89

	dc.l	_VsetSync		; 90
	dc.l	_VgetSize		; 91
	dc.l	_VsetVars		; 92
	dc.l	_VsetRGB		; 93
	dc.l	_VgetRGB		; 94
	dc.l	_ValidMode		; 95

* 96-127: Sparrow DSP calls from dsp.o

 .globl	_DspDoBlock, 		_DspBlkHandShake,	_DspBlkUnpacked
 .globl	_DspInStream,		_DspOutStream,		_DspIOStream
 .globl	_DspRemoveInterrupts,	_DspGetWordSize,	_DspLock
 .globl	_DspUnlock,		_DspAvailable,		_DspReserve
 .globl	_DspLdProg,		_DspExProg,		_DspExBoot
 .globl	_DspLodToBinary,	_DspTriggerHC,		_DspRequestUniqueAbility
 .globl	_DspGetProgAbility,	_DspFlushSubroutines,	_DspLdSubroutine
 .globl	_DspInqSubrAbility,	_DspRunSubroutine,	_DspHf0
 .globl	_DspHf1,		_DspHf2,		_DspHf3
 .globl	_DspBlkWords,		_DspBlkBytes,		_DspHStat
 .globl	_DspSetVectors,		_DspMultBlocks

	dc.l 	_DspDoBlock			; 96
	dc.l	_DspBlkHandShake	; 97
	dc.l	_DspBlkUnpacked		; 98
	dc.l	_DspInStream		; 99
	dc.l	_DspOutStream		; 100
	dc.l	_DspIOStream		; 101
	dc.l	_DspRemoveInterrupts; 102
	dc.l	_DspGetWordSize		; 103
	dc.l	_DspLock			; 104
	dc.l	_DspUnlock			; 105
	dc.l	_DspAvailable		; 106
	dc.l	_DspReserve			; 107
	dc.l	_DspLdProg			; 108
	dc.l	_DspExProg			; 109
	dc.l	_DspExBoot			; 110
	dc.l	_DspLodToBinary		; 111
	dc.l	_DspTriggerHC		; 112
	dc.l	_DspRequestUniqueAbility ; 113
	dc.l	_DspGetProgAbility	; 114
	dc.l	_DspFlushSubroutines	; 115
	dc.l	_DspLdSubroutine	; 116
	dc.l	_DspInqSubrAbility	; 117
	dc.l	_DspRunSubroutine	; 118
	dc.l	_DspHf0				; 119
	dc.l	_DspHf1				; 120
	dc.l	_DspHf2				; 121
	dc.l	_DspHf3				; 122
	dc.l	_DspBlkWords		; 123
	dc.l	_DspBlkBytes		; 124
	dc.l	_DspHStat			; 125
	dc.l	_DspSetVectors		; 126
	dc.l	_DspMultBlocks		; 127

* 128-151: Sparrow sound calls from spsound.o

 .globl locksnd,unlocksnd,soundcmd,setbuffer
 .globl setmode,settrack,setmontrack,setinterrupt
 .globl buffoper,dsptristate,gpio,devconnect
 .globl sndstatus,buffptr

	dc.l	locksnd			; 128 Open a sound channel
	dc.l	unlocksnd		; 129 Close a sound channel.
	dc.l	soundcmd		; 130 Perform a sound functions.
	dc.l	setbuffer		; 131 Set rec/play buffer location.
	dc.l	setmode			; 132 Set sound 8/16 bit stereo/mono.
	dc.l	settrack		; 133 Set number of tracks.
	dc.l	setmontrack		; 134 Set monitor track.
	dc.l	setinterrupt	; 135 Set interrupt type.
	dc.l	buffoper		; 136 Set rec/play buffer operations.
	dc.l	dsptristate		; 137 Tristates DSP bus
	dc.l	gpio			; 138 Talks to gpio acording to mode.
	dc.l	devconnect		; 139 connects src to dst devices.
	dc.l	sndstatus		; 140 Get current sound status.
	dc.l	buffptr			; 141 Get current buffer offsets.
	dc.l	unimpl			; 142 [reserved]
	dc.l	unimpl			; 143 [reserved]
* 144
; This line has been commented out because it is taken care of below..
; See towns for details..
*	dc.l	unimpl,unimpl,unimpl,unimpl,unimpl,unimpl,unimpl,unimpl

* 152-159: Sparrow VDI video calls

	dc.l	unimpl			; 144
	dc.l	unimpl			; 145
	dc.l	unimpl			; 146
	dc.l	unimpl			; 147
	dc.l	unimpl			; 148
	dc.l	unimpl			; 149
	dc.l	_SetMasks		; 150
	dc.l	_SetOverlay		; 151
.endif

 .data

.if DB_STUB
Mstop:	dc.b	"Stopped.",0
.endif

    .globl mtestmsg
mtestmsg:	dc.b	"Memory Test:",13,10
.if (SPARROW == 0)
		dc.b	"ST RAM "
.endif
		dc.b	0

	.even
M0curs:	dc.l	$1b592720 ; Position cursor at row 7, column 0

	.globl	nv_defs		; used in clock.s
* NVRAM defaults
nv_defs:
	dc.w	0			; _upref
	dc.l	0			; manuf
	dc.w	0			; _AKP
	dc.b	0,'/'		; _IDT
	dc.l	$20ffffff	; spin/scan
	dc.w	0			; _modecode
.end
