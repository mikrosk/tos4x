.super
****************** Revision Control System *****************************
*
* $Author: apratt $
* =======================================================================
*
* $Date: 90/05/16 11:54:21 $
* =======================================================================
*
* $Locker:  $
* =======================================================================
*
* $Log: startup.s,v $
* Revision 2.48  90/05/16  11:54:21  apratt
* Added some ifne TT conditionals, so it compiles for not-TT.
* Also changed boot color to dark blue, because light blue was taken.
*
* Revision 2.47  90/05/09  16:45:37  apratt
* Added _FPU cookie; see the comments there for details.
* Boot color: sky blue.
* 
* Revision 2.46  90/04/30  18:44:45  apratt
* Changed Getmpb call to conform to new GEMDOS style: one MD for both
* ST RAM and alternative RAM, with the low bit of the block start address
* nonzero for alt. RAM.
* 
* Noblank and noblank1 clobber Timer B always, so it doesn't survive a rez
* change ever -- see comments there.
* 
* Added nvmaccess call to XBIOS list ($2e).  It's implemented in clock.s.
* 
* Revision 2.45  90/03/19  16:00:50  apratt
* Changed TT to TT+STPLUS w.r.t. SCU: catch & ignore bus errors in the
* init code for SCU so it runs on either STe or Mega STe.
* 
* Fixed the out-of-range check for Bcon* functions: was (devno > maxdev)
* but is now (devno >= maxdev).
* 
* Revision 2.44  90/03/02  17:45:44  apratt
* This rev is the source for the 3/1/90 ROM.
* 
* Revision 2.43  90/03/02  10:39:08  apratt
* Added a comment to the effect that anybody who programs Timer B
* to a value of 1 (that is, interrupt every time) will defeat
* noblank/noblank1 processing.  I don't want to actually WRITE
* to Timer B's data register in noblank, since it would kill
* somebody's real programming, but there is this danger.
* 
* initmfp in bios.s now writes 0 (meaning 256) to Timer B's data
* register, so if NOBODY uses it, it will have a legal value (not 1).
* 
* Revision 2.42  90/03/01  17:10:51  apratt
* Added equates for TTMFP: ttgpip, ttiera, etc.
* Fixed ttwait, stwait for new equates.
* Added use of noblank, rather than vwait: see comments at noblank.
* Noblank1 is similar, but returns via rts.
* Fixed a some things causing STe not to work.
* Removed restriction (in findpackages) that phystop be on a 1K boundary.
* 
* Revision 2.41  90/02/26  17:27:28  apratt
* Fixed up conditionals, using else rather than endc/if. Added stwait,
* using STMFP timer A for delays, suitable for delays during boot
* (applications can use timer A later on). Used calls to dowait in boot,
* (stwait or ttwait as appropriate), to replace ttwait in TT, and
* instruction loops in not-TT. Removed VBLQ1ST once and for all - now
* vblq is always 1st. Hope this doesn't hurt if we ever build ST ROMS
* again! Changed _term to use dc.w's to get what I'm after: a jsr (not
* bsr) to the next instruction.
* 
* Revision 2.40  90/02/22  17:51:41  apratt
* Changed bootup BG color from yellow to magenta.  Added moveq #0,d0
* to clear screen so it doesn't turn green.  Removed twin color
* tables: $f is full-magnitude on STe and TT, and eq to $7 on ST.
* 
* Revision 2.39  90/02/16  16:50:17  apratt
* Fixed an oops in the startup code which made RAM TOSes not work. Also,
* initialize ssp to its ultimate destination (_supstk+supsiz) rather than
* $8000 at reset4.  Also, after reset4, changed to clear from the start
* of the BSS which needs clearing (that is, endosbss) to the true end of
* the BSS: endaesbss in ROM systems, ostext in RAM.
* 
* Default boot-up rez code changed: if no mono detect, ST LOW; else
* ST HIGH or TT HIGH as appropriate.
* 
* MMU code works, and is now enabled.
* 
* Revision 2.38  90/02/02  14:17:54  apratt
* Reordered entire startup sequence to improve clarity and
* function.  Cold boot for TT is defined as "ttscu1 bit 0 is clear."
* This happens on power-up only, not on reset-button or keyboard
* reset.  (Keyboard cold boot clears the bit, though.)  The
* distinction is not well tested.
* 
* Also added code necessary for Bconmap functions to work.
* 
* Revision 2.37  89/12/28  15:35:09  apratt
* Moved the line which sets the refresh rate for fast RAM.  Now
* it's outside the ROM/RAM conditional, and most of all outside
* the coldboot/warmboot conditional.  Turns out fast RAM
* decays faster, so it might not be valid even when slow RAM is.
* This won't hurt anything, since nothing in fast RAM is presumed
* valid across a warm boot.  Not by the OS, anyway.
* 
* Also added 'moveq.l #0,d0' to some of Slavik's calls so they
* don't return garbage in the high parts of d0.
* 
* Revision 2.36  89/12/08  15:45:14  apratt
* Fixed Lozben's fatfinger in _setscreen concerning wvbl.
* Also changed TT background color to blue: it's nonwhite, so you
* know this is not the final ROM (per LT), but it's not black,
* so you can tell your TT is doing something.
* 
* Revision 2.35  89/12/06  14:03:49  apratt
* In the reset-bailout vector test, there are some sanity checks.
* One of them checks to be sure that the high byte of the vector is 00.
* This is OK on ST and STE, but not TT, so I made it conditional.
* 
* Revision 2.34  89/10/23  18:37:17  lozben
* Set the rez shadow register when setting the shifter on the TT.
* 
* Revision 2.33  89/10/03  12:41:40  apratt
* Added VBLQ1ST switch (in *this* file, not switches.s) which, when
* nonzero, moves the VBL queue processing to the beginning of
* the VBLANK handler, not the end.  VDI likes this so it has more
* time to draw the mouse before the beam starts painting it.
* (This was MOVEVBL, then removed, and now it's back.)
* 
* Revision 2.32  89/09/22  16:43:29  apratt
* THIS VERSION REQUIRES TURBO C'S "MAS" ASSEMBLER
* No functional changes from previous revision, which is the last to
* require Alcyon's AS68 assembler.
* 
* Revision 2.31  89/09/21  13:40:41  apratt
* The vbl part of Setscreen() copied the new palette to TT regs
* rather than ST regs -- now it copies to the ST regs always.
* This was a vestige of bit-shifting in software, now unnecessary.
* 
* Revision 2.30  89/09/18  13:35:33  apratt
* Removed LONGFRAME conditional assembly: now LONGFRAME is all there is.
* Removed code which emulated STE color registers; it turns out
* that the TT shifter's ST-compatible registers *are* like STE regs.
* Added code to retry _dmaread if it returns a "retryable" error
* (other than timeout).
* 
* Revision 2.29  89/09/07  16:29:00  apratt
* Changed date & dosdate and added 'check' to date lines.
* 
* Revision 2.28  89/09/05  17:49:47  apratt
* Fixed dumb bug in setpalette code for TT.  Works now.
* 
* Revision 2.27  89/08/30  16:02:43  apratt
* Added def_frb variable, set to the value that the _FRB cookie gets.
* Zero if no fast RAM.  Added moving end_os up by 64K as well as _membot.
* Added code to match the boot spec: scan of bootable devices stops
* when hdv_rw changes.  Cut bomb-handler delay from 1 sec to 0.5 sec.
* 
* Revision 2.26  89/08/30  15:18:42  lozben
* Fixed a bug in _EsetShift().
* 
* Revision 2.25  89/08/29  17:36:45  apratt
* Added code (two lines) to set GEMDOS date/time when XBIOS Settime()
* call is made.
* 
* Revision 2.24  89/08/28  21:01:16  kbad
* Changed mushroom code to get rid of the LUT for initial screen offset,
* since there are only two of them (and TT res offsets are > word length)
* 
* Revision 2.23  89/08/28  19:03:23  kbad
* Fixed(?) bomb handler for all resolutions.  Also fixed a couple of
* fatfingers at dmaboot. (_diskbufp != _dskbufp !!!)
* 
* Revision 2.22  89/08/25  18:46:04  lozben
* Fixed a bug in EsetShift().
* 
* Revision 2.21  89/08/25  15:38:36  apratt
* Added new dma boot code which calls _dmaread, and added _dmaread
* as XBIOS call $2a.
* 
* Revision 2.20  89/08/25  12:23:16  lozben
* EsetShift() now always returns old shift mode register value.
* 
* Revision 2.19  89/08/24  16:54:58  lozben
* Added EgetShift() and EsetShft() xbios function calls. Deleted
* EsetRez() and EsetPhysBase() xbios function calls.
* 
* Revision 2.18  89/08/18  13:44:47  apratt
* All changes are TT only:  added _FRB cookie pointing to a 64K buffer
* in slow RAM for ACSI transfers to/from fast RAM.  Only present if there
* is any fast RAM.
* 
* Changed bomb handler to get the exception number from the stack frame.
* 
* Changed Setcolor and Setpalette so, to the caller, the RGB values
* are like STe (hi-order bit is least significant).
* 
* Revision 2.17  89/07/31  12:08:51  apratt
* Added .globl clrcache directive.
* 
* Revision 2.16  89/07/29  21:40:50  kbad
* Put the reset back at reseth.  It was a gratuitous incomprattibility.
* 
* Revision 2.15  89/07/28  20:59:12  apratt
* Changed delay for DMA command bytes and data to count time from
* power on, not from when we started looking.  This makes warm boots
* happen fast.
* 
* Note that the 'reset' instruction at reseth was taken out.
* I sure hope it wasn't necessary, and some devices (esp. SCSI) really
* hated it.
* 
* Revision 2.14  89/07/27  18:06:22  apratt
* Added kcl_hook and bell_hook variables and initializations.
* Added _SWI cookie and set bit 1 of _SND based on bit 7 of _SWI.
* 
* Revision 2.13  89/07/26  19:42:08  apratt
* Final BIOS for STPLUS: Added cookie jar, full-volume DMA sound,
* added hard-disk boot delay, backed out MOVEVBL.
* 
* Note: _longframe code is still dumb: it checks on every trap & RTE.
* 
* Revision 2.12  89/07/20  15:36:50  apratt
* Changed ttdelay code to use TTMFP timer A.  Also added code to catch
* the return from Rwabs calls and clobber the cache if the operation
* was a read.  (This is a lose for ramdisks and drivers which do it
* on their own, but it's a win because you can use ST drivers.)
* 
* Revision 2.11  89/07/19  13:58:39  apratt
* Added ttwait/ttdelay calls to remove some instruction-loop
* delays.  These entry points are also used by bios.s and flop.s.
* 
* Revision 2.10  89/06/15  15:43:11  apratt
* Changed STPLUSVIDEO to STPLUS, because it covers everything STPLUS
* unique (DMASND covers other things).  Changed version number to 1.6,
* and date to 6/16/89.  Added STPLUS memory sizing.  The BIOS revs
* with this date or earlier are correct for STPLUS (now called STE).
* I think.
* 
* Revision 2.9  89/05/10  14:00:24  apratt
* Added MOVEVBL switch to make vblqueue happen early in vblank.
* Moved memory clearing around so the screen clears early on as before.
* (Previous rev had a substantial delay between power-on and clear screen.)
* 
* Revision 2.8  89/04/17  14:43:48  apratt
* Added mwdata and mwmask equates... Oops.
* 
* Revision 2.7  89/04/17  13:26:22  apratt
* Added the new system variable _sysflags, definition TBD ($5a0)
* 
* Added fast-RAM refresh & sizing for TT.  Includes new system variables
* _ramtop ($5a4), and _ramvalid ($5a8), which is validated with rammagic.
* 
* Added programming the volume/tone generator for a sane volume & tone,
* and to mix the GI sound with the DMA sound.
* 
* Added DMAINV assembly-time switch: set to 1 if DMASND and the DMA chip
* inverts MONOMON when it's IDLE.  Will go away one day.
* 
* Slight changes elsewhere.
* 
* Revision 2.6  89/03/30  04:35:49  kbad
* Changed return code of _term from 1 to -1 ($ffff), "error."
* 
* Revision 2.5  89/03/23  17:32:00  apratt
* Added real memory controller programming and memory sizing for TT.
* The memory sizing is actually not TT-dependent.
* Also fixed some things in the DMA SOUND vblank handler... Now
* it really works.
* 
* Revision 2.4  89/03/22  13:48:22  apratt
* Changed monochrome detect code in vblank -- it would wait until GPIP
* read the same way twice, which might *never* happen.  Now it waits
* until bit 7 of GPIP reads the same way twice, which is more common.
* 
* Revision 2.3  89/03/09  08:32:06  apratt
* Fixed priv handler -- correct one got lost in folding-in process. (TT only)
* 
* Revision 2.2  89/03/08  15:59:37  apratt
* Contains Slavik's Xbios calls & other changes for TT.  Insignificant
* changes if not TT.  Some things are conditional on STPLUSVIDEO+TT,
* which is meant to be an OR of those two assembly-time conditions.
* 
* Revision 2.1  89/02/21  17:23:11  kbad
* *** TOS 1.4  FINAL RELEASE VERSION ***
* 
* Revision 1.35  89/02/17  12:09:32  apratt
* Fixed byte-count for clearing screen at clrm_2, and
* fixed priv handler: must clear & disable caches after clobbering
* the instruction, then restore cacr to its previous value.
* 
* Revision 1.34  89/02/12  20:23:32  kbad
* changed version, date, and dosdate equates from `=' to `equ'.  It seems
* that as68 doesn't like `=' assignments inside conditional statements.  Urk.
* 
* Revision 1.33  89/02/08  17:45:15  apratt
* Backed off screen base to phystop-$25800 for TT (in two places).
* 
* Revision 1.32  89/02/07  13:00:59  apratt
* made priv handler conditional on LONGFRAME, not TT
* 
* Revision 1.31  89/02/06  21:55:55  apratt
* Little (but frustrating!) bug fixes so TT would work.
* 
* Revision 1.30  89/02/06  15:17:41  apratt
* Oops - left out _termtab.
* 
* Revision 1.29  89/02/06  13:22:23  apratt
* Added TT code.  No change if you set TT = 0.  EXCEPT:
* bombs now cause Pterm(-1) to be called, rather than Pterm0().
* TT code is prototypical, esp. in memory sizing.
* 
* Revision 1.28  89/02/06  12:39:45  apratt
* Split STPLUS conditional assembly into STPLUSVIDEO and DMASND, because
* DMASND is true for TT as well, but STPLUSVIDEO isn't.  This
* is in preparation for adding TT conditional assembly.
* 
* Revision 1.27  89/01/23  11:43:21  kbad
* Restored `nop' after jsr in _term, it's required because of dumb AS68.
* 
* Revision 1.26  89/01/13  15:41:07  apratt
* NO CODE CHANGE: just comment changes around trp13tab and trp14tab
* documenting assigned BIOS and XBIOS function numbers.
* 
* Revision 1.25  88/12/30  11:42:22  apratt
* Change for STPLUS only: dbasell was defined as the address of the
* register as a WORD, but was being used as a byte.  Now it's the
* address as a byte.  Also, D.RENN assures me that the register's low-
* order bit will always read as zero, so I don't need to mask it out.
* 
* Revision 1.24  88/12/21  11:01:45  apratt
* Fixed two places where (a5) was used when a5 wasn't clear.
* Oops.  Also updated some comments before 'reset2' with cleverer
* reset-handler instructions (just comment change here).
* 
* Revision 1.23  88/12/13  16:35:41  apratt
* Added lots of (a5)'s for otherwise-long addresses, both low RAM
* and high I/O space.
* 
* Revision 1.22  88/12/13  14:43:44  apratt
* Added some code for STPLUS: more proper use of the low-byte-of-video-base
* register (and an equate for it: dbasell), and DMASND code which works
* for the latest board (with MONOMON and DMASND XORed together) including
* resetting DMASND during the boot, and handling the XOR case during
* boot and in VBLANK.  Also the new default color palette for STPLUS: 7's
* become F's.
* 
* Revision 1.21  88/12/06  17:02:06  apratt
* Added a system variable at $59e: _longframe.  It's zero if you're
* on a 68000, nonzero otherwise.  This is used on entry and exit
* for BIOS/XBIOS (at "traph") so we can deal with the extra word
* on the stack for 680[1-3]0 exception frames.  MASSIVELY UNTESTED,
* and almost no change if you leave LONGFRAME equ 0.
* 
* Revision 1.20  88/12/06  16:24:23  apratt
* Added code for STPLUS to fix the check for MONOMON in the Vblank
* handler: it gets inverted when the DMA sound is active, so this code
* has to un-invert it.  It's not quite bulletproof, but it should be
* pretty damn rare that a spurious reset sneaks through.  Well-nigh
* impossible, I hope.
* 
* Only a tiny code change if not STPLUS.
* 
* Revision 1.19  88/11/28  11:16:44  kbad
* Put the magic back in.  Dungeon Master was depending on the AES magic
* to reclaim the AES BSS after the boot sequence takes it away.  This
* is deemed a Good Feature - 12K is no small potatoes on a 520 ST.
* 
*
* Revision 1.18  88/11/16  15:10:19  apratt
* Added STPLUS assembly-time flag.  Set to 1 for ST PLUS, 0 for ST.
* This flag influences the following:
* Physbase/Setscreen: read & write new low-byte-of-display-base register.
* Setcolor: after reading color register, masks with $0777 for ST, $0fff
* for STPLUS.
* No other changes required for ST PLUS.  Even screen dump is fine.
* 
* Revision 1.17  88/11/02  15:21:19  apratt
* Backed out clearing of _bootdev; caused more pain than it's worth.
* Specifically, people with bootable ramdisks (!) became unhappy.
* 
* Also added code to set GEMDOS time from IKBD if real-time clock chip
* doesn't exist or has a bad time, and if IKBD has a good time.
* JWT says IKBD clock is defined as starting up at 0/0/00, which is
* an unambiguously illegal date.
* 
* Revision 1.16  88/10/12  17:25:57  apratt
* Added table entry for floprate call: see flop.s for more.
* 
* Revision 1.15  88/10/03  15:01:09  kbad
* Incorporated changes for new build method (several things were made
* obsolete -- look for the keyword "newbuild" to find these changes).
* 
* Revision 1.14  88/09/21  15:08:19  apratt
* Whoops.. dmaread claimed to try twice, but really tried once.
* Now it tries twice.
* 
* Revision 1.13  88/09/06  11:39:52  kbad
* Added osconf word for denmark.
* 
* Revision 1.12  88/05/06  16:06:38  apratt
* In dmaread: removed "retry on no error/no data" and replaced it
* with "retry on any error" (except timeout).
* 
* Revision 1.11  88/05/05  13:41:04  apratt
* Added clr.w _bootdev to startup sequence, to fix bootable hard disk
* bug (when using ALT to avoid HD boot, A:\auto doesn't get executed).
* This was because GEMDOS set the current drive based on _bootdev,
* which wasn't getting cleared by anybody.
* 
* Revision 1.10  88/05/03  15:09:56  apratt
* Added comments as relates to the version number and problems with
* First Byte's Kid series of software -- you get address error unless
* the version number is even.  See comments above 'systype' for more
* information.
* 
* Revision 1.9  88/04/28  16:08:09  apratt
* Backed out table entry for Flopwp XBIOS call. See flop.s for more.
* 
* Revision 1.8  88/04/22  13:07:53  apratt
* Fixed dmahi to dmahigh in dmaread (slip of the finger...)
* 
* Revision 1.7  88/04/08  17:45:24  apratt
* Backed out reset bail-out vector fix -- leave it broken.  The workaround
* is to return to the reset code via "jmp $24(a6)" rather than
* with "jmp (a6)" as advertised.  THE RESET CODE CAN'T CHANGE thanks to this.
* 
* Revision 1.6  88/04/05  17:47:50  apratt
* Changed Flopwp call to Xbios $29 because of internal versions of AKP's
* debugger, which uses $28.  Must keep Xbios $11 unused.
* (Newer versions of the debugger use Xbios calls $11 and $F000)
* 
* Revision 1.5  88/03/31  15:58:23  apratt
* <BACKED OUT -- SEE VERSION 1.7 NOTES>
* 
* Also fixed some bsr's to jsr's so gemdos can be far away from here.
* 
* Revision 1.4  88/03/28  11:46:47  apratt
* Added Flopwp call (Xbios call $29).  Actual code is in flop.s
* 
* Revision 1.3  88/03/18  16:16:59  apratt
* Added code to dmaread: retry the read if the first one succeeds (status
* code 0 (no error)) but the DMA counter hasn't changed.
* The removable-media drives we have use this to signal media change.
* 
* Revision 1.2  87/11/25  18:17:00  lozben
* Added new flags for finland, norway, and turkey.
* 
* Revision 1.1  87/11/20  14:24:44  lozben
* Initial revision
* 
*
* Revision 2.57  90/08/03  13:23:45  apratt
* TTOS FINAL RELEASE
* $Revision: 2.48 $
* =======================================================================
*
* $Source: /u2/MRS/osrevisions/bios/startup.s,v $
* =======================================================================
*
* $Source: /u2/MRS/osrevisions/bios/startup.s,v $
*+
*	--- Switch and country definitions (never change these):
*-
* =======================================================================
rom		=	0 ***DON'T  CHANGE***	; system in 192K ROM
ram		=	1 ***DON'T  CHANGE***	; system loaded in RAM

usa		=	0 ***DON'T  CHANGE***
germany		=	1 ***DON'T  CHANGE***
france		=	2 ***DON'T  CHANGE***
uk		=	3 ***DON'T  CHANGE***
spainpal	=	4 ***DON'T  CHANGE***	PAL  version
spain		=	5 ***DON'T  CHANGE***	NTSC version
italy		=	6 ***DON'T  CHANGE***
sweden   	=	7 ***DON'T  CHANGE***
swissfra   	=	8 ***DON'T  CHANGE***
swissger 	=	9 ***DON'T  CHANGE***
turkey		=      10 ***DON'T  CHANGE***
finland		=      11 ***DON'T  CHANGE***
norway		=      12 ***DON'T  CHANGE***
denmark		=      13 ***DON'T  CHANGE***
*+
*		         ***CHANGE THESE (DOWN HERE)***
*************************************************************************
*		||		||		||		||
*		||		||		||		||
*	       \\//	       \\//	       \\//	       \\//
*		\/		\/		\/		\/
*
*

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
* should still be even-numbered, and since the minor vers. number marches
* in step with TT, we're stuck.
*
*-

* The switches TT, STPLUS, systype, and country
* are all moved to the file "switches.s" which is normally a copy
* of one of the canned switch settings files.
* set DMASND to 1 if you want to enable DMA sound: this assumes that
* the chip actually exists (so clearing the control register will
* not cause a bus error) and that MONOMON is XORed with the sound chip's
* IRQ line.

.ifne TT+STPLUS
DMASND		equ	1
.else
DMASND		equ	0
.endc
* have a short-frame processor (68000).  Currently that's only TT.
* set VBLQ1ST if you want the VBL queue to be processed as the first
* thing in VBLANK.

VBLQ1ST		equ	1

.ifeq TT
version		equ	$0106		; version number *MUST BE EVEN*
date		equ	$03301989	; not-TT date, $MMDDYYYY @check@
*			 YYYYYYYMMMMDDDDD
dosdate		equ	%0001001001111110 ; Mar 30, 1989
.else
version		equ	$0300		; version number *MUST BE EVEN*
date		equ	$05221990	; TT date, $MMDDYYYY @check@
*			 YYYYYYYMMMMDDDDD
dosdate		equ	%0001010010110110 ; May 22, 1990
.endc

*******************************************************************************
*+
*  Country-specific configuration word (os_conf)
*
*			%cccccp
*			      p = pal/ntsc (0 = ntsc, 1 = pal)
*			     cc = country (0 = usa, ...)
*
*-
 ifeq country-usa
osconf		equ	%00000
.endc

 ifeq country-germany
osconf		equ	%00011
.endc
* in the makefile.  date and dosdate are imported here for use in
 ifeq country-france
osconf		equ	%00101
.endc
bootcolor	equ	$fff		; WHITE for production ROMs
 ifeq country-uk
osconf		equ	%00111
.endc

 ifeq country-spainpal
osconf		equ	%01001
.endc

 ifeq country-spain
osconf		equ	%01000
.endc

 ifeq country-italy
osconf		equ	%01011
.endc

 ifeq country-sweden
osconf		equ	%01101
.endc

 ifeq country-swissfra
osconf		equ	%01111
.endc

 ifeq country-swissger
osconf		equ	%10001
.endc

 ifeq country-turkey
osconf		equ	%10011
.endc

 ifeq country-finland
osconf		equ	%10101
.endc

 ifeq country-norway
osconf		equ	%10111
.endc

 ifeq country-denmark
osconf		equ	%11001
.endc


*************************************************************************
*									*
*	Copyright 1984, 1985, 1986, 1987 Atari Corp.			:
* which is exported from BIOS.S and imported here for placement		*
* in the OSHEADER.  That way, this file has no country dependencies.	*
*-----									:
* 18-Mar-1987 lmd	Removed call to 'esce' [not important anyway].	:
*			 Clear '_drvbits' on reset.			:
* 16-Mar-1987 lmd	Placed JMP in 'hdrcopy' before the actual header:
*			 and modified 'copy_header' to hack the instrs	:
*			 appropriately.  Four longwords just past the	:
*			 header now contain pointers to critical var-	:
*			 iables, plus one reserved location.		:
* 27-Feb-1987 lmd	Modified header-copy routine to copy the entire	:
*			 header, not just the first $20 bytes of it.	:
*			Also must maintain the size of 'hdrcopy' in BSS.:
* 11-Feb-1987 lmd	Added pointers to "hidden" variables, just after:
*			 the OS header, so we can get to them later.	:
* 10-Feb-1987 lmd	Fixed masking bug in Blitmode().		:
*  9-Feb-1987 lmd	Added blit support (_TEST_BLT, changed blit	:
*			  initialization code slightly, added BIOS call	:
*			  number 64 to get/set blit mode, Blitmode()).	:
*			Added code that moves the character device	:
*			  jump table into RAM, so it can be re-directed	:
*			  later (for shell and window system use in the	:
*			  future).					:
*									:
* 19-jan-1987 rms	Fix to mouse init code. We now send a reset to  :
*			the keyboard after the ikbd response. This code :
*			has been moved to this file.			:
* 13-Jan-1987 lmd	Added 'pun_ptr' and bumped the new memory check	:
*			variable up a longword [for AHDI driver].	:
*  6-Jan-1987 lmd	Added fix to memory clear; position screen at	:
*			end of memory (so it is cleared almost immed-	:
*			iately).  Sped up that clear with multiple	:
*			MOVEM instrs.					:
* 23-Dec-1986 lmd	Set '_date' directly (without calling GEMDOS)	:
* 18-Dec-1986 rms	New feature blt_init. Call to this routine	:
*			to set the system to use the blit chip.		:
*-----									:
* 15-Dec-1986 rms	Due to mixup on hard disk driver legal tos	:
*			roms test, the ascii date in the header of the	:
*			roms needs to be the gemdos date word		:
*-----									:
* 11-Dec-1986 lmd	Fixed bus-error problem in memory size probe.	:
*			Added another cold-reset variable.		:
*			Added RICOH clock chip handler.			:
*			Unused vectored interrupts point to an RTE.	:
*									:
*-----									:
* 14-Apr-1986 lmd	Fixed bug in `dmaread' that locked up DMA bus if:
*			more than one hard disk was attached.		:
*-----									:
* 02-Feb-1985 lmd	Converted from CP/M BIOS.			:
* 24-Feb-1985 lmd	I munge this file every day.			:
* 25-Feb-1985 lmd	Added _cmdload flag (load COMMAND.COM from disk):
* 25-Feb-1985 lmd	Changed _get_mpb, added "hard_reset" conditional:
*			assembly switch.				:
* 27-Feb-1985 lmd	Added hard disk hooks.				:
*  1-Mar-1985 lmd	Added _supstk (from GEMDOS)			:
*  1-Mar-1985 lmd	Added _mediach BIOS function			:
*  4-Mar-1985 lmd	Added 'cartscan' and associated calls to it	:
*  7-Mar-1985 lmd	Integrate new character I/O			:
*  8-Mar-1985 lmd	Critical error handler, random trap hacking	:
*  9-Mar-1985 lmd	BIOS traps are re-entrant to 3 levels, and	:
*			callable from user mode.			:
* 10-Mar-1985 lmd	Consolidated BSS, installed "extended" traps	:
* 15-Mar-1985 lmd	Re-integration with RBIOS.  200hz raw sysTick	:
* 16-Mar-1985 lmd	Warmstart banished.  Procdump on uncaught traps	:
* 27-Mar-1985 lmd	Added "_scrdmp" trap#14 function		:
* 27-Mar-1985 lmd	Added "getshift" trap#13 function		:
*  8-Apr-1985 lmd	Re-integration with serial code			:
*  8-Apr-1985 lmd	Moved floppy/FIFO lock to public basepage	:
*  9-Apr-1985 lmd	get/set shift bits (trap #13, $0b)		:
*  9-Apr-1985 lmd	Added _dskbufp -> _diskbuf			:
* 13-Apr-1985 lmd	Added _autopath (autoexec path pointer)		:
* 15-Apr-1985 lmd	Happy IRS day.					:
* 15-Apr-1985 lmd	Moved _vblqueue to low memory (thank Ghu!)	:
* 17-Apr-1985 lmd	Added _prtblk primitive				:
* 17-Apr-1985 lmd	Hblank (vector interrupt #2) hacks caller's IPL	:
*			to 3.						:
*  1-May-1985 lmd	Added supexec() & wvbl() extended functions	:
*  8-May-1985 lmd	RAM-loaded system wired 'memcntrl' to 512K;	:
*			now it takes whatever the boot ROMs give it.	:
*  9-May-1985 lmd	Added _asc_out to character device table.	:
* 15-May-1985 lmd	Moved _cursconf to escape module.		:
* 23-May-1985 lmd	Added 'magic' parameter -- makes it easy to	:
*			blow the GEM AES away.  Huzzah!			:
* 24-May-1985 lmd	Added mushroom cloud display on processor	:
*			exception, out of sheer boredom.		:
* 28-May-1985 lmd	Added new _prtblk.  Screen dump understands high:
*			quality print mode.				:
*  3-Aug-1985 lmd	Fixed _prtcnt interface, fixed mushroom display :
*			for high-rez mode, new mushroom graphics.	:
* 13-Aug-1985 lmd	Added 'dmaboot()'; attempts to load boot sectors:
*			from devices on the DMA bus (wheee!).		:
* 13-Aug-1985 lmd	Do dos SETDATE() call to set date from word in	:
*			the OS header.  (Kludge, kludge, kludge...)	:
* 28-Aug-1985 lmd	Fix dmaboot(); sector count should have been	:
*			1, not 0.					:
* 28-Aug-1985 lmd	Fix monochrome problem on reset (screen messes	:
*			up) by letting vblank set shiftmd and sshiftmd	:
* 28-Aug-1985 lmd	Inquire ikbd date and time; set system date and	:
*			time from ikbd if reported month and day is	:
*			nonzero.					:
* 29-Aug-1985 lmd	Ikbd date/time hack didn't work because of an	:
*			ikbd bug.  Ripped it out.  F'it.		:
*  3-Sep-1985 lmd	Added 'scr_dump' vector (for foriegn printer    :
*			drivers).  goo goo ga ga ga			:
*  6-Sep-1985 lmd	Fixed "screwed-up-screen" problem, powerup in	:
*			monochrome.					:
*  6-Sep-1985 lmd	Fixed it again.  [well, not really]		:
*  9-Sep-1985 lmd	Monochrome's "window of vulnerability" is longer:
*			than color's -- have to wait 2 to 3 ms extra	:
*			before changing hardware's shift-mode bit, or	:
*			the screen gets screwed up.			:
* 10-Sep-1985 lmd	Increase supstk size to 3K.			:
* 11-Sep-1985 lmd	Force 'sshiftmd' to lowrez on system-reset.	:
* 11-Sep-1985 lmd	Added patch area ($580..$7ff) and user-ram	:
*			variables ($800..$83f).				:
* 11-Sep-1985 lmd	Force 'vblsem' to zero before first wvbl().	:
* 13-Sep-1985 lmd	Use Jim Tittsler's monomon setup code (oh well)	:
*									:
* 16-Oct-1985 lmd	Added vectoring to _prtblk() character output	:
*			bindings.					:
* 16-Oct-1985 lmd	Fixed bug in vbl(), not setting screen location	:
*			correctly from BIOS variable.			:
*									:
* 12-Nov-1985 lmd	Fixed timing bug in PAL setup (PAL ROMS).	:
*			Changed memory controller (memory sizing) to	:
*			handle new (4002) memory controllers.		:
*			Changed PATH back to its original state (with	:
*			the path bug in).				:
*									:
* 16-Nov-1985 lmd	Resurrected RAM packages (soze we can install	:
*			hard disk drivers and similar hacks).  We won't	:
*			tell anybody about them yet...			:
*									:
* may-1-86		Fixed dma read code for reading multi harddisks	|
*									*
		text
*************************************************************************






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
	.globl	kcl_hook		; hook for keyclick sound
.ifeq systype-rom
	.globl	_p_cookie		; pointer to cookie jar
.ifne TT

.if TT
.endif
.endc
.endc
.if (TT == 0)
	.globl	_waketime		; alarm maintenance for STPAD
.endif
.if TT
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
	.globl	initmous		; mouse vector init
	.globl	_mediach		; media change inquiry
	.globl	_proto_bt		; prototype boot sector
	.globl	_flopwr			; write sector(s)
	.globl	_flopver		; verify sector(s)
	.globl	_flopfmt		; format track
	.globl	_floprate		; get/set floppy seek rate code
	.globl	_rand			; generate random number
	.globl	blt_init		; init the blitter chip

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
DEFCSIZE	equ	$10		; default to room for 16 cookies




*--------------	Magic Numbers
resmagic	equ	$31415926	; validates 'resvalid'
diagmagic	equ	$fa52235f	; validate diagnostic cartridge
apmagic		equ	$abcdef42	; validate application cartridge
memmagic	equ	$752019f3	; validates 'memvalid'
memmag2		equ	$237698aa	; validates 'memval2'
memmag3		equ	$5555aaaa	; validates 'memval3'
bootmagic	equ	$1234		; magic checksum for boot sector
rammagic	equ	$1357bd13	; validates 'ramtop'

*---- Floppy state variables:
dfused		equ	0		; nonzero: floppy has been accessed
dcurtrack	equ	dfused+2	; current track#
dseekrt		equ	dcurtrack+2	; floppy's seek-rate


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



*------ Ram configuration equates
*------ ROM addresses:
romstart	equ $fa0000		; lowest ROM address
romend		equ $ff0000		; first	byte not in ROM
bank1		equ $200000		; address of 2Mb second	bank
twomb		equ 1024*2048		; two megabytes
one28		equ $20000		; 128K
memconf		equ	$ffff8001	; memory controller
memconf		equ	$ffff8001	; memory controller

*--- SPARROW memory configuration
SPAR_CONF	equ	$ffff8006	; read here to auto-config

*--- SPARROW video master control register
SPAR_VMC	equ	$ffff82c0	; video master control
.ifne TT
syncmode	equ	$ffff820a	; video	sync mode
.endc
dbaseh		equ	$ffff8201	; display base high
.ifne STPLUS+TT
*--- ST PLUS shifter
shiftmd		=	$ffff8260	; video	shift mode (resolution)
* that the low bit of this register will always read as zero.
ttcolor0	equ	$ffff8400	; TT background color reg
.endc
.endif
*--- configuration switches
.ifne STPLUS+TT
*--- Video base address low byte (not on ST)
* This register can be accessed as byte or word, and D.RENN assures me
.endc
* that the low bit of this register will always read as zero on STe,
*--- DMA chip:
diskctl		equ	$ffff8604	; disk controller data access
fifo		equ	$ffff8606	; DMA mode control
dmahigh		equ	$ffff8609	; DMA base high
dmamid		equ	$ffff860b	; DMA base medium
dmalow		equ	$ffff860d	; DMA base low

*--- 1770 select values:
cmdreg		equ	$80		; 1770/FIFO command register select
trkreg		equ	$82		; 1770/FIFO track register select
secreg		equ	$84		; 1770/FIFO sector register select
datareg		equ	$86		; 1770/FIFO data register select

* and the low three bits as zero on TT.
dbasell		equ	$ffff820d	; addr of low byte of this reg
dstride		equ	$ffff820f	; "offset to next line" in STe

*--- configuration switches (not on ST)
conf_switches	equ	$ffff9200
ttd_conf_switches equ	$ffff8000	; not used if not TT

*------ Bits in "giporta":
xrts	equ	8			; RTS output
dtr	equ	$10			; DTR output
strobe	equ	$20			; Centronics strobe output
gpo	equ	$40			; "general purpose" output

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
ttmfp	equ	$fffffa81
scr	equ	mfp+$27			; sync char
ttgpip	equ	mfp+1			; general purpose I/O
ttaer	equ	mfp+3			; active edge reg
ttddr	equ	mfp+5			; data direction reg
ttiera	equ	mfp+7			; interrupt enable A & B
ttierb	equ	mfp+9
ttipra	equ	mfp+$b			; interrupt pending A & B
ttiprb	equ	mfp+$d
ttisra	equ	mfp+$f			; interrupt inService A & B
ttisrb	equ	mfp+$11
ttimra	equ	mfp+$13			; interrupt mask A & B
ttimrb	equ	mfp+$15
ttvr	equ	mfp+$17			; interrupt vector base
tttacr	equ	mfp+$19			; timer A control
tttbcr	equ	mfp+$1b			; timer B control
tttcdcr	equ	mfp+$1d			; timer C & D control
tttadr	equ	mfp+$1f			; timer A data
tttbdr	equ	mfp+$21			; timer B data
tttcdr	equ	mfp+$23			; timer C data
tttddr	equ	mfp+$25			; timer D data
ttscr	equ	mfp+$27			; sync char
ttucr	equ	mfp+$29			; USART control reg
ttrsr	equ	mfp+$2b			; receiver status
tttsr	equ	mfp+$2d			; transmit status
ttudr	equ	mfp+$2f			; USART data
tttbdr	equ	ttmfp+$21		; timer B data
tttcdr	equ	ttmfp+$23		; timer C data
tttddr	equ	ttmfp+$25		; timer D data
ttscr	equ	ttmfp+$27		; sync char
ttucr	equ	ttmfp+$29		; USART control reg
ttrsr	equ	ttmfp+$2b		; receiver status
tttsr	equ	ttmfp+$2d		; transmit status
ttudr	equ	ttmfp+$2f		; USART data
.ifne DMASND
*--- DMA SOUND REGISTERS (only one interesting one)
*--- 6850 registers:
keyctl	equ	$fffffc00		; keyboard ACIA control
keybd	equ	keyctl+2		; keyboard data
.endc
midictl	equ	$fffffc06		; MIDI ACIA control
.ifne TT+STPLUS


*--- DMA SOUND AND MicroWire REGISTERS
dmasndc	equ	$ffff8900
mwdata	equ	$ffff8922
mwmask	equ	$ffff8924

.endc
*--- SCU REGISTERS: interrupt mask, interrupt state, and two gp regs
.ifne TT
* write here to set refresh rate for fast RAM
ttsysimsk	equ	$ffff8e01	; "sys" int mask in SCU	
.endc
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
sshiftmd:	ds.w	1	; (44c)	 shadow for 'shiftmd' register
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
trp14ret:	ds.l	1	; (486)	 saved return addr for _trap14
criticret:	ds.l	1	; (48a)	 saved return addr for _critic

_cmdload:	ds.w	1	; (482)	 nonzero: load COMMAND.COM from boot
conterm:	ds.b	1	; (484)  console/vt52 bitSwitches (%%0..%%2)
		ds.b	1	; (485)  [unused, reserved]

		ds.w	1	; (486)	 [unused, reserved]
		ds.l	1	; (488)	 [unused, reserved]
		ds.w	1	; (48c)  [unused, reserved]
themd:		ds.l	4	; (48e)	 memory descriptor (MD)
_____md:	ds.w	2	; (49e)  (more MD)
		ds.l	1	; (4be)  reserved for future use

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

*	This space reserved for		:
*	future RAM-loaded fixes		:
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
*	BSS beyond this point		:
*	will change in future		:
* They are not clobbered across reset.	:
*----------------------------------------

.if STPAD
padmagic:	ds.l	1		; $01241960 for STPAD touch driver
padstuff:	ds.l	10*4		; other pad variables (total 40 bytes)
.ifne TT
the_env:	ds.b	20		; space for a small enviroment string
.endc

_upref:		ds.w	1		; boot pref for _dmaboot
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

*  or when the RESET button is pressed,
*  or after a really messy system crash.
*
* There is code here to reset the ACSI chip and leave it in the read state.
.ifeq systype-rom

.endc
	move.w	#$2700,sr		; super mode, no interrupts

.if systype == rom
.if TT
	move.w	#$0100,$ffff8606.w	; reset ACSI chip...
	move.w	#$0000,$ffff8606.w	; ...leave in read state.
.endif


.ifeq systype-rom

* [ROM only]
.endif

.if SPARROW
.endc
	move.b	d0,d1		; d1=vvmmrrbf
	lsl.b	#6,d1		; d1=bf000000
	and.b	#$80,d1		; d1=b0000000
	lsr.b	#6,d0		; d0=000000vv
*  Clobber the PMMU and cache
	move.w	d1,SPAR_VMC	; write to VMC.
.ifne TT
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
	jmp	cartbase+4		; execute diagnostic cartridge
reset1:
.endif
.endc

*+
*  [ROM or RAM, M68030 only]
*  Clobber the cache, the VBR, the FPU, the PMMU
*-
.if M68030
	move.l	#$0808,d0
	movec	d0,cacr			; invalidate & disable both caches

	moveq.l	#0,d0
*	pmove	tdis,tt1
.ifeq systype-rom
	dc.l	$f0390c00,tdis		; has bugs...
.ifne TT

.data
.endc
.text
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
*-
.if systype == rom

.if TT
	btst.b	#0,ttscu1		; this bit set?
	beq	reset3			; no, this is a cold boot.
.endif

	lea	ret_1(pc),a6		; load return addr
	bra	val_memval		; check memory configuration validity
ret_1:	bne	reset3			; (invalid -- don't set anything up)
	move.b	memcntlr.w,memconf	; initialize memory controller
reset2:

*+
*  [still ROM only]

* if STPAD, read the switches register to learn the state of top closed &
* power on.  Clobber resvalid if they are BOTH down, which is a state that
.ifeq TT
* install a reset vector to never-never land; you can't just turn off the
* power and wait for RAM to decay.  Note that other things (modem wake,
* alarm wake, extern wake) can bring the power bit down besides the button;
.endc
*
* Also read the STylus button register & don't jump through resvector
* if both buttons are down.  Well, there's no STylus so this is moot.
*
* There is new code elsewhere that makes this less important: bus error etc.
* during boot vector to "coldboot."
.endc

	move.w	conf_switches,d0	; get conf switches & buttons.
	cmp.b	#$fc,d0			; check just top-closed and power.
	beq	resv2			; if both are down, clobber resvalid
	move.w	$d00004,d0
	and.b	#%00000110,d0		; test for both STylus buttons
	bne	resv1			; if either is up, don't clobber
	cmp.l	#resmagic,resvalid.w	; is resvalid the magic	number?
	bne	reset3			; (no)
	move.l	resvector.w,d0		; d0 = reset bailout vector
.if (M68030 == 0)
	move.b	#$e,(a0)		; deselect disks
	move.b	#7,2(a0)
	bne	reset3			; (they	aren't,	so punt)
.endif
*+
*  If we're on a machine with DMA sound, clobber it
*  and program the volume/tone chip for max vol, etc.
*-

.ifne DMASND
	clr.w	dmasndc		; reset sound chip

* program the volume/tone controller for a sane volume & tone, and
* mix the GI sound in with the DMA sound so it comes out the speaker.

	lea.l	vtpgm(pc),a0
	move.w	(a0)+,mwmask
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

.endc
	jmp	(a0)			; execute reset	bailout
.ifeq systype-rom
.endif

*+
*  Initialize PSG output ports.
*  Make ports A and B output-only;
*  initialize floppy select lines (so
*  that none are selected).
*
* Note: The floppy side and selects are inverted, so writing 1 disables them.
* Other outputs are initialized to zero here: *DTR, *RTS, STROBE,
.ifeq TT
	btst.b	#0,os_conf+1(pc)	; check bit: configured for 50hz?
	lea	giselect,a0		; a0 -> giselect, giwrite-2
	move.b	#7,(a0)			; set porta & portb to output
	move.b	#$c0,2(a0)
	move.b	#$e,(a0)		; select port A
.else
	move.b	#$01,syncmode		; set external sync mode always
* end of TT
.endc
* end of rom/ram
.endc
.endif






notpal:	lea	color0,a1		; a1 ->	hardware reg

.if STPAD
*
* Pad is always mono and needs power control, and we want a picture early
* in the boot sequence so as not to (A) drain power, (B) possibly damage LCD,
* and (C) look bad, so we set it up here, not later as we do for other 
.ifeq systype-rom
* again later when other machines' shiftmds are set.  Note that we don't
* set "shadow shadow" (the RAM variable which holds the value last written
* to the write-only register in "shadow") here, because on cold boots
* it'll be clobbered later (search for "#$400" to see where).
*
* We also read from $d00000, to clear the "conversion done" interrupt
* from the STylus touch-screen hardware.  This is as good a place to
* put that as any...
*
.ifne STPLUS+TT
	clr.b	dbasell		; set lo byte ptr
.endc
	move.b	#$80,$ffff827f		; write LCD and power control
	tst.w	$d00000			; clear "conversion done" int.
.endif

*+
*  Initialize palette registers to
*  their default values.
*-
	lea	color0,a1		; a1 ->	hardware reg
	move.w	#16-1,d0		; setup	16 colors
	lea	colors(pc),a0		; a0 ->	table of default colors
sysic1:	move.w	(a0)+,(a1)+		; copy palette assignment
	dbra	d0,sysic1		; (loop for more colors)


* controller, and tells other things besides: the byte at 8006 (or the high
.ifeq TT
	bne	sp_cold			; no - this is a cold boot

* On Sparrow, detected cold boot.  So determine memory size.
* Take mmb as a number; phystop is 512KB << mmb clamped to 14MB maximum.
sp_cold:
	move.w	SPAR_CONF,d0	; read again just for fun
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
* from test-pattern signatures:
	cmp.l	$00300010,d0		; still there?
	bne	pad_small		; nope, you're small
	cmp.l	$00300014,d1		; also still there?
	beq	pad_big			; yes - you're big (so d5 is fine)
pad_small:
	move.l	#$100000,d5		; we have 1MB
pad_big:
* If neither shadow appears, but the pattern took in the first place,
.ifeq STPLUS
shadow	equ	$200			; look for first shadow at 512 bytes
.else
shadow	equ	$40000			; look for first shadow at 128K
.endc
*
* to be an assembly-time constant, now it's in d7.
*
	move.l	#shadow+8,a0		; pattern matches at first shadow loc?
*

	move.b	#$5a,dbasell		; see if dbasell is RAM
	move.l	#shadow*2+8,a0		; pattern matches at second shadow loc?
					; would put $5a on the bus.
	cmp.b	#$5a,d0			; NOW cmp.b
	bne	memST

	clr.b	dbasell			; try the test again using zero
	tst.w	color0			; color0 is $FFF
	tst.b	dbasell			; read back - should be zero.
	bne	memST

; OK, dbasell holds its value: you're an STe.

cold3:	move.b	d6,memconf		; setup	memory controller
	bra	gotshadow

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
* Routine notes: at the .endc, d5 must hold phystop, and d6 must hold
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

* end of TT / not TT split
.endc
	beq	mt_cold			; definitely a cold boot

*  Determine memory size (once we've setup the memory
*  controller) by probing successive locations until
*  something breaks.  Either we get a bus error (for
*  an non-existant controller) or the pattern we write
*  won't read back correctly (non-existant bank on a
*  controller that works).
ret_2:	beq	reset4			; already sized; don't size or test.
*  This will handle both the 2119 and 4002 memory
*  controllers.  ("Parts iz parts, ey?")
	move.w	#$5,d6			; init d6 for small parts
	move.l	d0,$1008		; clear space first so pattern
	move.l	d0,$100c		; doesn't "happen" to be there
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
	lea	$8000,sp		; initialize SP just this once
	move.l	a0,8			; to catch non-existant controllers
	move.w	#$fb55,d3		; d3 = a nice random number
*  Clear memory from $400 to 'd5' (phystop).
*  Used to put screen at phystop - screen size and clear from top down.
*  Now leaves screen where it is (at 64K) and clears from bottom up,
*  so screen still clears early on.
*  Must preserve d5 = phystop and d6 = mem controller program byte.
	move.w	d0,d2			; d2 = copy of random #
	moveq	#42,d1			; d1 = # words to stuff
	add.w	d3,d2			; generate new random #
	dbra	d1,mt_2			; (stuff more words)

	move.l	a0,a1			; a1 -> end of RAM (as we knew it)
	moveq	#42,d1			; d1 = # words to check
mt_3:	cmp.w	-(a1),d0		; compare word in RAM with ours
	bne	mt_q			; no match: bad bank (we quit)
	clr.w	(a1)			; be tidy, clear out cruft
	add.w	d3,d0			; generate next random #
	dbra	d1,mt_3			; (check more words)

*  Set the system variables memcntlr and phystop.
*  Also set the magic values in the validation variables.
*  On TT, of course, this isn't enough: we aren't done until
*  fast RAM is sized, then we set bit 0 of SCU general register 1.
	move.l	a0,d5			; d5 -> end of RAM (as we know it)

.endif

*+
*  [still ROM only]
*  Clear memory from $400 to 'd5' (phystop). Used to put screen at phystop
*  - screen size and clear from top down. Now leaves screen where it is (at
.ifne TT
*  preserve d5 = phystop and d6 = mem controller program byte.
*-
mem_sized:
	move.w	#$400,a0
	move.l	d5,d4
* contrary: that's dual-purpose, slow, compatibility-mode RAM.  Primary
* RAM starts at $01000000 and is contiguous from there.  The first N bytes
* of it (N>=0) is fast, nybble-mode RAM.  The rest of it is on the VME
* bus.  The VME bus and the RAM you put there is jumpered to start at
	move.l	d0,(a0)+
	cmp.l	d4,a0
	bne	clm_1

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
.endc
mt_pq:	sub.l	d7,a0			; drop down to last successful probe
	cmp.l	#$01000000,a0		; was there any RAM at all?
* end of .ifeq systype-rom for memory sizing
	clr.l	a0			; no - set ramtop to zero.
mt_pr:
.endc

*
* Now that d5 holds the end address of primary RAM, put it someplace
* useful.  I've chosen the next available system variable, which is
* at $5a4, and called it _ramtop: there's RAM from $01000000 to there.
* A zero there means there's no RAM there at all (and it's zero on
* non-TT ST's, of course).
*

.else

* not TT: set the fast-RAM system variables to indicate "no fast RAM"
.endif
	bne	vtloop

nodmasnd:
	move.l	a6,sp			; restore SP in case of bus error.
	move.l	a5,$8
.endif

* Set the variable "I am an ST." For STPAD, no.  For TT, no.  For Sparrow,
* no.  Otherwise, in the ST/STe case, check to see if the low byte video
* address register (dbasell) is RAM.  This is a repeat of the test we did
* to determine the shadow addresses for memory sizing; see that code for
* comments.

.if (TT | STPAD | SPARROW)
	sf	_iamanst
.else
.ifeq systype-rom
	tst.b	dbasel			; read another register to destroy
					; capacitance effects; dbasel is 00.
	move.b	dbasell,d0		; read; don't say cmp.b because that
					; would put $5a on the bus.
	cmp.b	#$5a,d0			; NOW cmp.b
	bne	iset

	clr.b	dbasell			; try the test again using zero
	tst.w	color0			; color0 is $FFF; read to zap the bus
	tst.b	dbasell			; read back - should be zero.
.ifne TT

.endif

*+
*  Clear the memory used by the rest of BIOS, GEMDOS, and AES/VDI.
*  GEMDOS and AES/VDI expect their BSSes to be clear when they start.
*
*  In this file there's a symbol, endosbss, which marks the end
*  of the system variable region.  Since some of these variables
.endc
*  historical reasons, the "BSS clearing" portion of our program
*  starts after this point.
*
*  TOS builds include a symbol, endaesbss, which is the last RAM address
*  used anywhere in the OS.  For a RAM TOS, that's not the one we want:
*  If TT, we allow an extra 16 bytes after the screen, before the end
*  FIRST symbol of the TEXT segment.
*
*-
*  too far.  This $10-byte pad means writing the screen to disk doesn't
*  cause this.
	cmp.l	a0,a1			; at end?
	bne	clrm_1			; (no -- loop for more words)
.ifeq TT
.if M68030
*+
*  [M68030 only]
	sub.l	#$25810,a0		; One TT screen plus $10 bytes.
	move.w	#$2581-1,d1		; clear d1*16 bytes
.endc
*  This has to run after clearing BSS memory.
*-

.ifne STPLUS+TT
	move.b	_v_bas_ad+3.w,dbasell	; load lo byte addr
.endc
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
	lea	os_end-4(pc),a0		; no, use default numbers
.if (TT == 0)
	sub.l	#$8000,a0
	move.w	#$800-1,d1		; d1 = # 16-byte chunks to zero
.else
	sub.l	#$25900,a0		; One TT screen plus $100 bytes.
	move.w	#$2590-1,d1		; clear d1*16 bytes
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
*	clr.w	_bootdev.w		; clear this (NEW 5/5/88)

*--- Disk vectors:
	move.l	#_dskinit,hdv_init.w	; initialization
	move.l	#_boot,hdv_boot.w	; boot-from-device

*--- Prtblk vectors:
.ifeq systype-rom
	move.l	#_lstout,prv_lst.w
.endc
	move.l	#_auxout,prv_aux.w

* Initialize the cookie jar
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
	dc.w	$42c0		; move ccr,d0: illegal on 68000
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
.ifeq TT+STPLUS
* for the movec instruction, so I use the freeze bit of the data cache
	clr.l	(a0)+			; ST video
* data cache) and a 68030 (which does).
	clr.l	(a0)+			; ST machine
.endc
.ifne STPLUS
	movec	d0,cacr		; (un-freeze data cache)
	move.l	#$00010000,(a0)+	; STE video
	bra	cdone1
	move.l	#$00010000,(a0)+	; STE machine
.endc
.ifne TT
	move.l	#"_VDO",(a0)+
	move.l	#$00020000,(a0)+	; TT video
	move.l	#"_MCH",(a0)+
	move.l	#$00020000,(a0)+	; TT machine
.endc
	move.l	#$00010000,d0		; load d0 for normal STe
.ifne TT+STPLUS
* TT and STPLUS have configuration switches.  Set that cookie here.
	tst.b	ttscu1
	move.w	#$0010,d0		; no bus error: set Mega STe lo word


*
* This is a little tricky: the configuration bits can be in two different
* places: one for STPLUS and new TTs, one for old TTs.  The 
* equate to conf_switches is set above for STPLUS and the "other" TTs,
* and ttd_conf_switches is the other one.  If we're on STPLUS, we just
* read the bits.  If we're on TT, we read conf_switches first, guarding
* against bus error.  Bus error means the bits are found at memconf-1
* (memconf is the odd byte). In either case, the bits are in the high byte
* of a word where we don't care about the low byte.
* Furthermore, the "1" state should be the default, since some STEs and TTs
* are/were manufactured with all switches open (or missing!).
*
.ifne STPLUS
* Get here on bus error touching ttscu1 -- we're not a Mega STe.
.endc
.ifne TT

* must find configuration bits in either of two places: one for TTD,
* one for all others.  Each address gives bus error on the other machine.

	move.l	$8,a1
	move.l	sp,a2
	move.l	#conf_berr,$8
	move.w	conf_switches,d0	; get conf bits from normal place
	bra	gotem			; hey! no exception
conf_berr:
	move.w	ttd_conf_switches,d0
gotem:	move.l	a1,$8
	move.l	a2,sp
.endc
	lsr.w	#8,d0			; get conf switches in low byte


.else
	moveq.l	#0,d0
.endc
	clr.w	d0			; set d0 back to "normal STe"
* end of TT+STPLUS configuration switches setting.
	move.l	a2,sp			; restore pre-bus-error stack pointer
	move.l	#gotmch,$8		; and set a new vector
	tst.b	$FFF00039		; read ATASR
.ifeq DMASND
	move.l	#$1,(a0)+		; GI sound only
.else
	move.l	#"_MCH",(a0)+
* d0.b holds the configuration switches as computed above.
* The conditional assembly has gotten a little hairy: TT+STPLUS is,
* at the moment, the same as DMASND, but it might not always be that way.

	moveq.l	#1,d1			; GI sound always present
	btst.l	#$7,d0			; test high-order bit
	sne	d2			; 1 means DMASND output present
	and.b	#$2,d2			; mask off all but the %10 bit
	or.b	d2,d1			; or in a 1 for present, 0 for missing
	move.l	d1,(a0)+		; set _SND value
.endc
* other values are undefined, but will eventually mean stuff like 2.88MB. 
* The low three bytes of the cookie is to be used by vendors who want to
* identify their products; they should register their desires with somebody
* (as of 4/25/91 it's Bill Rehbock).  "ATC" means Atari's 1772-clone that
*
* We're being cagey about this because we don't want to preannounce the
* coprocessor; if found, the cookie value is 0000 0001.  
* at the switches directly if we can help it.  So, like DMASND, you get a
* cookie based on a switch.
*
* In addition, if the switch is thrown, we set nospindelay so the floppy
* BIOS knows you're using an Epson SMD-340 or something like it.  See
* comments in flop.s for the rationale.
* switches.
*

* 	0001 = SFP004 floating-point peripheral
* The FPU cookie: 0002 0000 on a TT if you have a 68881; can be changed 
* 	0003 = 68882 definitely (currently not probed)
* 	0004 = 68040's built-in FPU
* 
* a 6888x coprocessor: a value of %001 means either 68881 or 68882,
* %010 means 68881 explicitly, %011 means 68882 explicitly, and
* %100 means the 68040's built-in floating-point hardware.
*
* The reason for this scheme is that you may actually have both an
* SFP004-equivalent peripheral installed AND a 6888x coprocessor,
* Usually, the low word is zero when you have a 68881, because there's
* no need for S/W emulation.  However, when you have the SFP004, you
* might also have software that turns line-F instructions into the
* corresponding SFP004 commands, and with a 68040, you might have
* software that dealt with the missing FP instructions.
*	0001 = SFP004
* This code always installs SOME cookie so software emulators can just
* find the cookie & change it, rather than installing their own.
* 	0004 = 68881
*	0005 = 68881 + SFP004
*	0006 = 68882
*	0007 = 68882 + SFP004
.ifne TT
.mc68881
* probe for FPU: line-F exception means there is none.
*
	move.l	sp,a2
* instructions, and the high bit of the low word means whatever you've got
* functions which are present in that processor.
	move.l	#$20000,(a0)+
* 	LOW WORD
* 
* 	0000 = no software FPU emulation
	clr.l	(a0)+			; FPU cookie zero means none found
* 		High bit means S/W is 68040-FPU aware.
*
	move.l	a2,sp
* also have software that turns line-F instructions into the corresponding
.else

*
* This code always installs SOME cookie so software emulators can just find
	move.l	#fpuberr,$8		; catch bus error
*
	move.l	#$00010000,(a0)+	; found it: cookie is 0001 0000
	bra	fpudone

fpuberr:
	clr.l	(a0)+			; FPU cookie zero means none found
fpudone:
* violation does, too, but should "never happen." However, it did in some
* machines, so here it is.  I think it actually means there's something
* wrong on the data bus...
.endif

.ifne TT
* If there's fast RAM, put the _FRB cookie in the cookie jar.
* It points to 64K of space available for anybody to do copies
* when attempting a Rwabs from or to fast RAM.
* Don't change this size: RAM-loaded drivers use the same buffer.
	move.l	#nofpu,$2c
	move.l	#nofpu,$34
	fmove.l	fp0,d0			; test a simple FPU inst.
	move.l	#$00020000,(a0)+	; found 6888x: set %10 bit 
	bra	fpudone

nofpu:
	clr.l	(a0)+			; no 6888x found
fpudone:
	move.l	a1,$2c			; clean up after exception (or not).
	move.l	a2,$34
	move.l	a3,sp

* What the heck - probe for SFP004 whether or not you're a TT.

	move.l	$8,a1			; save bus error vector
	move.l	sp,a2			; and SP for cleaning up later
	move.l	#xfpudone,$8		; catch bus error
.endc
	bset.b	#0,-3(a0)		; found SFP004: set %01 bit
	bra	xfpudone

xfpudone:
	move.l	a1,$8			; clean up
	move.l	a2,sp

.if TT
* If there's fast RAM, put the _FRB cookie in the cookie jar. It points to
*  If a diagnostic cartridge is inserted, the "random" vectors
*  (for Bus Error, Address Error, and so on) are left alone.
	tst.l	_ramtop.w		; any fast RAM?
*  Otherwise, the random vectors are pointed to the system critical
*  error handler (_term).  The high byte of the vector (bits 24..31)
*  contains the exception number.  [Yes, this will lose on a 68020.]

*  Trap 2 and Divide-by-zero are pointed at an RTE.
*
*
* There is some fast RAM, so must allocate a 64K disk buffer
* and add its cookie here.  I don't necessarily like allocating the
	move.l	d0,(a0)+		; write pointer to buffer
	add.l	#$10000,d0		; move up by 64K
	move.l	d0,_membot.w		; write new _membot
	move.l	d0,end_os.w		; write new end_os
*--- diagnostic cartridge check:
	cmp.l	#diagmagic,cartbase	; check cartridge magic
	beq	sei2			; (it's there -- leave vectors alone)
.endif
*--- setup 62 vectors:
.ifeq TT
	lea	_term(pc),a1		; a1 -> "terminate process" handler
	add.l	#$02000000,a1		; a1 += vector number (high byte)
	lea	8,a0			; a0 -> interrupt RAM
	move.w	#64-2-1,d0		; d0 = count
	clr.l	(a0)+			; last entry is null
	add.l	#$01000000,a1		; bump vector number in bits 24..31
	move.l	#DEFCSIZE,(a0)+		; with size for its value
.else
* TT: point all exceptions to _term, because the ex number is on
* the stack, in the exception frame type word.
	lea	_term(pc),a1
	lea	8,a0
	move.w	#64-2-1,d0
sei1:	move.l	a1,(a0)+
	dbra	d0,sei1
.endc
*
*  Exception vectors are pointed to the system critical error handler
*
* New code: we set all these exceptions to vector to 'coldboot' on the
* theory that a bus error while TOS is booting is A Bad Thing. We will
* revector the ones that still point to coldboot just before the first
* possible time we could jump to user code.  The theory of setting the
* bomb vectors to coldboot is that the cold boot will fix whatever went
* wrong, like a bogus address in resvector or some other system variable.
*-
	lea	_rte(pc),a3		; a3 -> handy RTE
	lea	_rts(pc),a4		; a4 -> handy RTS

*--- set up bomb vectors to coldboot (in bios.s):

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
*  "The other half" of the BIOS handles character I/O;
*  call its initialization hook.
*  (It can "never fail".  This will get interesting
*   if we ever do a detachable keyboard ....)
*
*
.ifne TT+STPLUS
* TT: have to enable interrupts in SCU also
* STPLUS: ignore bus errors
	lea	_vbl_list.w,a0		; a0 -> default list of vbl locs
	move.l	a0,_vblqueue.w		; install ptr to them
	move.w	#dnvbls-1,d0		; clear vbl vectors
	dbra	d0,avbl

*  vectors have been moved into RAM to make it possible
*  to efficiently intercept them later on.
*
.endc

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

*+
*  "The other half" of the BIOS handles character I/O;
*  call its initialization hook.
*  (It can "never fail".  This will get interesting
*   if we ever do a detachable keyboard ....)
*-

	bsr	initmfp

* never got to the ikbd.  Therefore, the ikbd's mouse and joystick are ENABLED
* to the reset default condition on powerup. For compatibility, we will not
* disable the mouse and joystick on powerup.
*
* NOTE: Furture systems may require a delay BEFORE we preform the software
*	reset. Problems with the ikbd require a 1/200 of a second delay
*	AFTER the ikbd has received a character from the acia. See bios.s
*	ikdbwc for details.
*
	move.w	#$0400,d0	; divide by 50, count 256 = 5ms
	bsr	dowait		; (this is ttwait or stwait as appropriate)
	move.l	#ikbreset,-(sp)	; ikbd reset string
	bsr	dowait		; (this is ttwait or stwait as appropriate)
	dbra	d1,ikbdlp1
	bsr	cartscan		; execute cartridge aps
*+
*  Initialize screen resolution -- algorithm from Jim Tittsler (thank you!)
.ifeq TT
*  If in medium resolution, make color 3 black (color 15 ==> color 3).
*
* This used to read the current rez out of the hardware & set the software
.endif

* a mono monitor, in which case we set high rez (read "ST LOW" at "TT HIGH"
* when on a TT).
.ifeq TT
* As of 5/14/91, TT's with color monitors boot in TT MED, which makes it
* look less like a toy machine with only 40 columns.
*
* The STPAD part of this moved to the place where the sync mode and
	bsr	noblank1		; wait until we're NOT in a vblank
vwt_r:
.endc

.if STPAD
	move.b	#$80,$ffff827f		; write LCD and power control
	move.b	#$80,$889		; $889 is "shadow shadow"
	moveq.l	#2,d1			; STPAD is always mono
.else
.if (TT == 0)
setvb2:	move.l	#reseth,swv_vec.w	; RESET system on monitor change
.else
	moveq.l	#4,d1			; pre-select TT MED rez
.endif

	btst	#7,gpip			; test mono bit
	bne	nomono			; no mono - d1 is fine
.if (TT == 0)
	moveq	#2,d1			; st/mono: choose mode 2 (ST HIGH)
.else
	moveq	#6,d1			; tt/mono: choose mode 6 (TT HIGH)
.endif
.if (TT == 0)
* on ST, you'd better not change mode during a vblank; what we do
* is call noblank1, which returns when it's sure we are NOT in a vblank.
	clr.w	d0			; magic bit# = 0
	bsr	cartscan		; execute cartridge aps
.if STPAD
	bsr	cart1			; (on STPAD, scan 256KB after ROM, too)
.endif
	move.w	#$2300,sr		; go to IPL 3
	moveq	#1,d0			; magic bit# = 1
	bsr	cartscan		; execute cartridge aps
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
priv:	movem.l	d0/a0,-(sp)
	move.l	$a(sp),a0		; get PC of offending instr

* Take 2: copy the dest EA bits and extension words of the instruction into
* a "move.w (a0),ea" instruction elsewhere in memory, point a0 to the
* SR from the exception stack, and jsr there.
	move.b	#$42,(a0)		; clobber the instruction
.ifne TT
* if TT, need to clear caches after this instruction
	cmp.w	#%101000000,d0		; look for mode 5
.endc
	movem.l	(sp)+,d0/a0
	bsr	clrcache
.endif
priv1:	movem.l	(sp)+,d0/a0
.ifne TT
	movem.l	8(sp),d0-d2		; get these off the stack now
	jsr	pspace.w
	move.l	(sp)+,a0		; restore A regs
	move.l	(sp)+,a1
.endc
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
* by AKP and KBAD 11/2/88.  Note that _iclock returns Carry Set on error.
	jmp	_term+$08000000		; strange but true!
	bcc	noikbdclk		; if cc, don't bother with ikbd
	bsr	gettime			; but if cs, get IKBD time
priv2:


*+
*
* NOW WE'RE COOKING!
*	Initialize GEMDOS;
*	Set system date to date the system was built;
*

.if crcstride == 4
; four chips, next letter is bit 1 of offset
	move.b	#'E',d0			; 2nd bit even, say 'E'
	btst	#1,d5
	beq	eok2
	move.b	#'O',d0			; 2nd bit odd, say 'O'
	trap	#1			; Cconws(".\r\n");
.endif
.ifeq systype-rom

.endc
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
.ifeq systype-rom

.endc
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
	add.l	d1,a0			; add the exception number (or 0)
	add.l	d1,a0			; (twice: first ex number is 02)
.ifeq systype-rom
	bne	bloop1
.endc
bloop1:	add.l	d1,a0
	dbra	d0,bloop

****************************************************************************
*
* Now get this baby off the ground! This is the first point where we
* can load in some user code.
*

	bsr	_dskboot		; attempt to boot from disk
	bsr	dmaboot			; attempt to boot from DMA bus
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
	move.l	hdv_boot,a0		; go through boot vector
	trap	#1			; do it
.ifeq systype-rom


	lea	_diskbuf,a0		; a0 -> disk buffer
* When startup fails (or if the exec returns,
.endc
*-
	jmp	reseth			; back to the beginning...

.ifeq systype-rom
* Default enviroment string
* Cannot be more than 20 chars long without modifying
* the declaration for the_env;
* Any char >= $80 terminates the string (and is included in it)
* The last '#' character is replaced by the boot drive's name (A, B, ...)
*
* The path setting here perpetuates a bug in the original release
* of the software.  Fixing the bug made the system behave strangely,
* so we left it in.  The string should be "PATH=#:\\\0\0", not
*
*		to the SCSI DMA bus, and eight devices connected to
*		the ACSI bus.  If a sector is read, and it is executable
*		(word checksum is $1234), then it is executed.  The search
*		stops with the first one which is executable.
	  dc.b	$ff			; end of env string (for our copy)


*		It waits until at least 40 sec after power-up for the
*		data once the device accepts the command.
nullenv: dc.b	0,0			; null string (and enviroment)
*		The old code is included here as comments; 
*		_dmaread is from Minna Lai (thanks!).
*		_dmaread is also available as an XBIOS call ($2a).
sizeikbd	equ	*-ikbreset-1
*		The register set-up when jmp'ing to the root sector
*		is deliberate and should not change.

* Begin old code
**
** 7/89: expanded to provide a long timeout for the ack of the first command
** byte, and an even longer one for the data following a fully-acked command.
** The times are 10 sec for the ack of the first command byte (too long?)
** and 40 sec for the data.
** 	These times are global, in that we wait up to 10/40 sec from the
** time we first started looking for DMA devices.  We still wait
** a minimum of time appropriate to the shortest reasonable timeout, 
** even if we've been looking for more that 10/40 sec.
**-
*+
*dmaboot:
*	moveq	#0,d7		; start with dev #0
*	move.l	_hz_200,-(sp)	; remember when we started looking
*dmb_1:	clr.l	a4		; quick zeropage (inside loop!)
*	bsr	dmaread		; attempt to read boot sector
*	bne	dmb_2		; (failed -- try next dev)
*	move.l	_dskbufp(a4),a0	; a0 -> disk buffer
*	move.w	#$00ff,d1	; checksum $100 words
*	moveq	#0,d0		; checksum = 0
*dmb_3:	add.w	(a0)+,d0	; add (next) word
*	dbra	d1,dmb_3
*	cmp.w	#bootmagic,d0	; is the sector executable?
*	bne	dmb_2		; (nope)
*	move.l	_dskbufp(a4),a0	; a0 -> disk buffer
*	jsr	(a0)
*dmb_2:	add.b	#$20,d7		; next devno
*	bne	dmb_1		; (do all eight devs)
*	addq.l	#4,sp		; pop the memory of when we started
*	rts
*
*
**+
**  dmaread - attempt to read boot sector from DMA bus device
**    Passed:	d7.b = ddd00000
**		('ddd' is the ACSI device number, 0..7)
**		a4.l = 0 for low-RAM and I/O space access
**
**    Returns:	NE: read failed;
**		EQ: successful read,
**		    sector data in (*_dskbufp)[];
**
**    Preserves:	d7.w
**
**    Uses:	everything else
**
**
** Changed 5/88 by Allan Pratt: always retry the operation on a read error.
** This is because some removable media signal media change this way.
** This code does NOT retry on a timeout from the DMA or drive controller.
** (Should it? TBD.) (This code uses a4 as quick zeropage, not a5.)
**
** At 4(sp) when we get here is a long which is the _hz_200 time when
** this whole thing began.  Timeout for acking command bytes is at least
** 10 sec later than this, and timeout for data is at least 40 sec later.
**-
*dmaread:
*	moveq	#1,d5		; set for two iterations (dbra at end)
*
*dmaagain:
*	lea	fifo(a4),a6	; a6 -> DMA control register
*	lea	diskctl(a4),a5	; a5 -> DMA data register
*	st	flock(a4)	; lock up DMA against vblank
*
*	move.l	_dskbufp(a4),-(sp)	; setup DMA pointer
*	move.b	3(sp),dmalow(a4)
*	move.b	2(sp),dmamid(a4)
*	move.b	1(sp),dmahigh(a4)
*	addq	#4,sp
*
*	move.w	#$098,(a6)	; toggle R/W, leave in Read state
*	move.w	#$198,(a6)
*	move.w	#$098,(a6)
*	move.w	#1,(a5)		; write sector count register (= 1)
*
*	move.w	#$088,(a6)	; select dma bus (not SCR)
*
*	move.b	d7,d0		; setup d0.L with devno+command
*	or.b	#$08,d0		; d0.b = devno<<5 .OR. "READ" command bits
*	swap	d0
*	move.w	#$08a,d0
** timeout for the command bytes to ack is max(2000 - _hz_200,10)
*	move.l	#2000,d1
*	sub.l	_hz_200,d1	; d1 = (2000 - _hz_200)
*	moveq.l	#10,d2
*	cmp.l	d2,d1
*	bgt	dmr_wc
*	move.l	d2,d1
*dmr_wc:	move.l	d1,d2		; save in d2 for use later on
** timeout computation done, value in d1 (and d2)
*
*	bsr	wcbyte		; d0.L = xxxxxxxxDDD01000xxxxxxx010001010
*	bne	dmr_q		; (punt on timeout)
*
*	moveq	#3,d6		; (count = 4)
*	lea	dmr_st(pc),a0	; a0 -> bytestream for commands
*dmr_lp:	move.l	(a0)+,d0	; get next command byte
*	move.l	d2,d1		; get timeout value again
*	bsr	wcbyte		; write it
*	bne	dmr_q		; (punt on timeout)
*	dbra	d6,dmr_lp	; (loop for more bytes)
*
*	move.l	#$0000000a,(a5)	; write byte 5 (controlByte = $00)
** timeout for the read to complete is max(8000 - _hz_200,400)
*	move.l	#8000,d1
*	sub.l	_hz_200,d1	; d1 = 8000 - _hz_200
*	move.l	#400,d2
*	cmp.l	d2,d1
*	bgt	dmr_w		; if d1 > 400 use d1 (signed compare!)
*	move.l	d2,d1		; else use 400
*dmr_w:
** timeout computation done, value in d1
*	bsr	wwait		; wait for completion
*	bne	dmr_q		; (punt on timeout)
*
*	move.w	#$08a,(a6)	; select status reg
*	move.w	(a5),d0		; get return code from DMA device
*	and.w	#$00ff,d0	; strip crufty bits
*	beq	dmr_r		; zero, so it's good.
*
*	dbra	d5,dmaagain	; bad read - retry (once)
*
** Fall through if we've already tried twice: give up (return -1).
*
**--- reset DMA, return NE
*dmr_q:
*	moveq	#-1,d0		; return -1 (error)
*dmr_r:	move.w	#$080,(a6)	; cleanup DMA chip for floppy driver
*	tst.b	d0		; (test for NE on return)
*	sf	flock(a4)	; unlock DMA chip
*	rts			; return
*
*
**--- bytes in the command packet:
*dmr_st:	dc.l	$0000008a	; byte 1 (devno = 0, blockno = 0)
*	dc.l	$0000008a	; byte 2 (blockno = 0)
*	dc.l	$0000008a	; byte 3 (blockno = 0)
*	dc.l	$0001008a	; byte 4 (count = 1)
*
*
**+
**  wcbyte - write ACSI command byte, wait for IRQ
**    Passed:	D0.L = command byte and FIFO control
**			bits 16..23 = command byte,
**			bits 0..7 = FIFO control bits
**		d1.l = time to wait in 200Hz ticks before failing
**		a5 -> $ff8604
**		a4 =  $0 (for low-ram access)
**
**
**    Returns:	NE on failure (timeout)
**		EQ on successful ACK
**
**    Uses:	d1
**
**-
*wcbyte:
*	move.l	d0,(a5)		; write WDC, WDL [due to jwt]
*wwait:	add.l	_hz_200(a4),d1	; d1 = time to quit at...
*ww_1:	btst.b	#5,gpip(a4)	; disk done?
*	beq	ww_w		; (yes, return)
*	cmp.l	_hz_200(a4),d1	; timeout?
*	bhi	ww_1		; (not yet -- wait some more...)
*	moveq	#-1,d1		; ensure NE (timeout error) return
*ww_w:	rts
* endc
** end old code

*
* new DMA BOOT code: use _dmaread (in another file) to scan
* devices 8-15, then 0-7 (that is, SCSI, then ACSI).
* First device which has an executable root sector stops the
* process; if it returns, we return (i.e. just jmp to it).
* _dskboot - boot (or return diagnostics)
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

* Before doing anything, dmaboot waits until 90 seconds after 200Hz 
* started ticking. If you hit a key, it falls into the dmaboot code.
*
*		checksum is $1234), then it is executed.  The search stops
* 		set next_bar_time to bar_interval;	(d6)
NINETY_SECONDS	equ	200*90
* 		place the cursor on the last char of this line;
* 		fall through to continuation of bar shrinking;
	move.l	#NINETY_SECONDS,d7	; do this for 90 sec
*             (else fall through to dmab_todone to erase the bar)
dmab_to:
* A simple backspace after the Nth one doesn't work because you may or may
* not be on an N-column display, where the cursor is ALREADY on the
* Nth one.  Sigh.
	move.l	#$00010002,-(sp)
	trap	#$d			; Bconstat(2)
	addq.l	#4,sp

* we jump here when we're counting time and the memory test is done.
	move.l	#$00020002,-(sp)	; Bconin(2)
nomt:

* if (mt_done && _hz_200 >= d6)
	trap	#$d
* this is the end of the memory-test/shrinking bar sequence.  We check
.ifne TT
* Check the keyboard for a user aborting the timeout
	moveq.l	#8,d4			; start with SCSI device 0
.else
	moveq.l	#0,d4			; start with ACSI device 0
.endc
.if STPAD
dmab_todone:
	move.l	d7,_hz_200		; you broke out: write 80 sec
	move.w	#13,-(sp)
	move.l	#$00030002,-(sp)
	move.w	d4,-(sp)		; device number
	move.l	_dskbufp,-(sp)		; buffer
	move.w	#1,-(sp)		; count of one
	clr.l	-(sp)			; sector zero
	jsr	_dmaread
	addq.l	#6,sp

dmab_skip:

* Begin scanning DMA devices for a bootable one.  The sequence of devices
* you scan varies, and is described in dmarfail where the device number is
* updated.  This code uses the first word of the buffer "the_env"
* as scratch space.

.if TT
	jsr	_resetscsi		; reset the SCSI bus
.endif
dmaok:	move.l	_dskbufp,a0
	clr.w	the_env			; zero our device sequencer

.if TT
*
* move boot preference into _upref: hi 5 bits of ttscu1, or
* first word of NVM if valid, else zero.
*
* dma failed or sector isn't bootable ($1234) or didn't change hdv_rw:
dmaloop:
	move.w	#DMAB_RETRIES-1,d1	; retry count (usually 2 total)
	addq.w	#1,d4			; read failed or no exec or no boot
	move.w	d4,d0			; try next dev
	and.w	#7,d0			; if d4 hasn't wrapped to 8 or $10...
	bne	dmaloop			; carry on
	cmp.w	#$8,d4			; at dev 8?
	beq	dmafail			; yes, total failure
	moveq.l	#0,d4			; no, try ACSI bus
	bra	dmaloop
	move.l	_dskbufp.w,-(sp)	;  "  buffer		"
	move.w	#1,-(sp)		;  "  count of one	"
	clr.l	-(sp)			;  "  sector zero	"
	jsr	_dmaread		; read the sector
* We get here if the _dmaread call worked and gave an executable sector.
* We load up the registers and jsr to that sector.  If it returns,
* we check hdv_rw for a change; if it changed, we rts to go on booting
* TOS.  If it didn't change, we try the next device.
	cmp.w	#bootmagic,d1
	beq	dmafound		; success!
	move.l	_dskbufp,a0
*
* dmarfail:  DMAread failed or sector isn't bootable ($1234) or didn't
* change hdv_rw; try the next device.
	moveq.l	#0,d5			; zero user-preference value
	move.l	d4,-(sp)		; save d4
* The device sequence (in hex) is:
*  STPLUS:	10-17, 0-7	(IDE first, then ACSI)
*  TT:		8-f, 0-7	(SCSI first, then ACSI)
	move.l	(sp)+,d4		; restore d4
	cmp.l	hdv_rw,d0		; hdv_rw still the same?
*
* STPAD and STe-PLUS have IDE busses.  On other STPLUSes (Mega STe and
.endc
* Note 9/91: since ST and STPLUS are now the same ROM, we start at IDE in
* all non-TT systems.  It will fail fast for all machines with no IDEbus.
*
* The sequencing is taken care of using a table to turn the sequence number
* into a device number.  A device number of $ff ends the table.  The
* sequence counter is kept in the first word of "the_env" as scratch space.
	addq.w	#1,d4
.if TT
boot_dev_tab:	dc.b	8,9,$a,$b,$c,$d,$e,$f,0,1,2,3,4,5,6,7,$ff
.if SPARROW
boot_dev_tab:	dc.b	$10,$11,8,9,$a,$b,$c,$d,$e,$f,$ff
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
.ifeq TT
	dc.w	$fff			; 0 white
.else
	dc.w	$0cf			; 0 blue - 5/16/90 version
.endc
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
*** ST PLUS:

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
hbl_r:	move.w	(sp)+,d0		; restore d0, back to victim
.ifne DMASND
*-
vbl:
	addq.l	#1,_frclock		; bump frame clock
	subq.w	#1,vblsem		; P(vblsem) -- vblank locked?
	bmi	vblret

	movem.l	d0-d7/a0-a6,-(sp)	; save registers
	addq.l	#1,_vbclock		; bump unblocked-frame clock

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
	beq	v_read2
vbl11:	dbra	d7,vbl10		; loop for more	vectors
v_read2:
.endc

*** non-STPLUS equivalent: just get the input from gpip

.ifeq DMASND
	move.b	gpip,d1			; get "High Rez" input
.endc

*** When DMASND is TRUE:
*** If DMA sound is active, the MONOMON line is inverted (that is,
.ifeq TT
***	READ sound status (to d0)
***	READ gpip (to d1)
***	IF gpip != d1 then try again
***	IF sound status != d0 try again
***	IF d0 != 0 invert d1
***
*** Then proceed with the old code to check for the appropriate value
.endc
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
.ifeq TT
	beq	v_readdone		; don't have it; d1 is right.

	move.w	sr,-(sp)
.endc
v_read1:
	move.b	dmasndc+1,d0		; read sound state once
	move.b	gpip,d1			; get gpip with monomon
	btst	#7,d1
	sne	d1
	move.b	gpip,d2			; still the same?
.ifeq TT
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
.endc

.if (TT == 0)
	and.b	#3,d0			; strip bucky bits
	cmp.b	#2,d0			; low or high rez?
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
.ifne STPLUS+TT
	move.b	_v_bas_ad+3.w,dbasell	; for STPLUS use these 8 bits
.endc
.endif
	bra	swmon2
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

* end of monitor-change stuff, ALL MISSING IF STPAD!
.endif

	jsr	blink			; blink cursor

*--- reload color palettes
	tst.l	colorptr.w		; if(colorptr != NULL)....
	lea	color0,a1
	move.w	#8-1,d1
vbl2:	move.l	(a0)+,(a1)+
	and.w	#$ffff-$700,sr		; enable vbl interrupts
	clr.l	colorptr.w		; zap colorptr
vbl1:
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
wvbl:
	move.w	sr,-(sp)		; save psw
	and.w	#$FBFF,sr		; (IPL &= %011: allow IPL 4)
	move.l	_frclock,d0		; d0 = frame clock
wvbl1:	cmp.l	_frclock,d0		; wait for clock to change
	beq	wvbl1
	move.w	(sp)+,sr		; then restore psw & return
	rts



* There is code to check _longframe and handle
* long frames.  I hope it's true that RTE doesn't care what the offset
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
	lsl.w	#2,d1			; turn d0 into longword index
*
.ifeq TT
	move.l	d1,a0			; (quick and dirty test-for-negative)
*		This is to ensure that you can tell old ROMs from new ones:
*		For the interrogative calls, the fn number must be used
*		to signal the "old ROM" case.
*
* Uses:		d0-d2/a0-a2
* Keeps:	C registers
.endc
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
trp13h:	lea	trp13tab(pc),a0		; a0 -> trap13 jump table

traph:	move.l	savptr,a1		; a1 -> register save area
	move.w	(sp)+,d0		; pop SR and save it
	move.w	d0,-(a1)		; (need in D0 for user-mode test)
	move.l	(sp)+,-(a1)		; save return addr

.if (ONLY_LONGFRAME == 0)
	tst.w	_longframe.w		; long frames?
	beq	trap_1			; nope.
*------ jump table for GEMDOS functions:
	bne	b_supr			; (was in super: use super stack)
	move.l	usp,a7			; use user stack
b_supr:	move.w	(sp)+,d0		; get function#
	cmp.w	(a0)+,d0		; out of range?
	bge	b_exit			; (yes, so punt)
	move.w	d0,d1
.ifeq TT
	dc.l	hdv_rw+$80000000	; 4: [indirect] disk read/write
	move.l	(a0,d1.w),d1		; get pointer to function handler
.if (M68030 == 0)
	dc.l	hdv_bpb+$80000000	; 7: [indirect] get BPB
	bpl	b_1			; points to code
	dc.l	hdv_mediach+$80000000	; 9: [indirect] media change inquiry
.else
	dc.l	tt_rw			; 4: disk read/write (see below)
	dc.l	_setexc			; 5: set exception vector
	dc.l	_tickcal		; 6: return tick calibration
	dc.l	1+hdv_bpb		; 7: [indirect] get BPB
	dc.l	bcostat			; 8: console status (output)
	dc.l	1+hdv_mediach		; 9: [indirect] media change inquiry
.endc
* can't use high byte of address on M68030: use low bit instead.
	bclr.l	#0,d1			; clear & test odd bit
	move.l	d1,a0			; doesn't affect ccr!
	beq	b_1			; was clear before: points to code.
.endif
	move.l	(a0),a0			; indirect through RAM...
*
* BIOS functions are called with a5=0, and I won't back that part out
.ifeq TT
*
b_1:	clr.l	a5			; a5 -> zero page
	jsr	(a0)			; call BIOS function
.endc
* restore registers, cleanup stack and return:
* DO NOT TOUCH D0 HERE: It is either a return value or the fn number itself.

b_exit:	move.l	savptr,a1		; a1 -> register save area
	movem.l	(a1)+,d3-d7/a3-a7	; restore C registers + super stack

.if (ONLY_LONGFRAME == 0)
	tst.w	_longframe.w
	beq	b_exit1
.endif
	clr.w	-(sp)			; push a zero frame word
	dc.l	_getdsb			; 11: get device status block ptr

	move.w	(a1)+,-(sp)		; push old SR
	move.l	a1,savptr		; update save-pointer
	rte				; return to caller


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

	dc.l	unimpl			; 40: used by AKP's DB alpha vers.


*------ jump table for Atari BIOS extensions:
trp14tab:
.ifne TT
.if (TT == 0)
.else
	dc.l	unimpl
.endc
	dc.w	65			; number of entry points
.ifne TT
	dc.w	96			; number of TT entry points
.endif
	dc.l	initmous		; 0: initialize mouse
.endc
	dc.l	unimpl			; 47: unused ($2f)
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

.ifne TT
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
.if TT
	dc.l	NVMaccess		; 46: nvmaccess
.else
	dc.l	unimpl
.endif
.if (TT == 0)
	dc.l	_waketime		; 47: non-TT alarm maintenance
.else
	dc.l	unimpl			; 47: unimpl on TT.
.endif

* 0x30..0x3f: assigned to M.Schmal's MetaDOS

.endc
	dc.l	unimpl			; 49: assigned
.ifne TT
	dc.l	unimpl			; 50: assigned
	dc.l	unimpl			; 51: assigned
	dc.l	unimpl			; 52: assigned
	dc.l	unimpl			; 53: assigned
	dc.l	unimpl			; 54: assigned
	dc.l	unimpl			; 55: assigned
	dc.l	unimpl			; 56: assigned
	dc.l	unimpl			; 57: assigned
	dc.l	unimpl			; 58: assigned
	dc.l	unimpl			; 59: assigned

	dc.l	unimpl			; 60: assigned
	dc.l	unimpl			; 61: assigned
	dc.l	unimpl			; 62: assigned
	dc.l	unimpl			; 63: assigned
	dc.l	Blitmode		; 64: Blitmode(mode)
.endc
.if TT
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
	dc.l	_EgetShift		; 81
	dc.l	_EsetBank		; 82
.ifne TT
	dc.l	_EsetColor		; 83
.endc
	dc.l	_EsetPalette		; 84
	dc.l	_EgetPalette		; 85
	dc.l	_EsetGray		; 86
.ifne TT
	dc.l	_EsetSmear		; 87
.endc
	dc.l	unimpl			; 88: assigned (more more VDI calls)
	dc.l	unimpl			; 89: assigned

	dc.l	unimpl			; 90: assigned
.ifne TT
	dc.l	unimpl			; 91: assigned
.endc
	dc.l	unimpl			; 92: assigned
	dc.l	unimpl			; 93: assigned
	dc.l	unimpl			; 94: assigned
	dc.l	unimpl			; 95: assigned
.ifne TT
.endif
.endc

.if M68030
.ifne TT
.globl maptabsize, maptab
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

nomap:
.endc
*+
	lsl.w	#2,d0			; turn into longword index
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
.ifne TT
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
.endc
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
.ifne	STPLUS+TT
 	move.b	dbasell,d0		; load low byte for STPLUS
.endc

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
	clr.l	a0
.ifeq TT
	bmi	setex1			; punt if (d1 < 0)
	move.l	d1,(a0)			; set vector address
setex1:	rts
.endc

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
.ifne STPLUS+TT
	bne	phydone
.endc
phydone:
	rts				; return pointer in d0


*+
* _logbase - get logical display base
.ifeq TT
*-
_logbase:
	move.l	_v_bas_ad.w,d0	; set software shadow
	rts


.endc
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
*
*-
_setscreen:

*--- set logical location:
	tst.l	4(sp)			; if(logloc < 0) then ignore it
	bmi	f5a
.ifeq STPLUS+TT
*--- set physical location:
.else
	and.w	#$0fff,d0		; STPLUS/TT have other dirty bits
.endc
	tst.w	6(sp)			; if new color is <0, don't set it
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


*+
* _setpalette - set palette (on next vblank)
*	_setpallete(LONG palettePtr)
*
*-
_setpalette:
	move.l	4(sp),colorptr.w	; set software pointer
	rts				; (updated by vbl handler)


.ifeq TT
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
.endc
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

	move.b	shiftmd,d7
	and.w	#$0007,d7
*
	dc.w	$4eb9		; jsr (not bsr!)
	dc.l	savp_2		; target address

savp_2:	move.l	(sp)+,proc_pc.w		; save bogus PC + exception number
	movem.l	d0-d7/a0-a7,proc_regs.w ; common registers
.else
.ifne STPLUS+TT
	move.b	dbasell,d0
.endc
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


	moveq	#29,d7			; wait half a (60Hz) second
dm3:	bsr	wvbl
	dbra	d7,dm3

	rts				; byebye

* shifter
* modes:    0         1         2     3      4     5      6          7
*       320x200x4,640x200x2,640x400x1,na,640x480x4,na,1280x960x1,320x480x8
*mindex:
*dc.w   100*160,  100*160,  200*80,   0, 240*320,  0, 480*160,   240*320

*		disk I/O on odd addresses is very slow.  Lose, lose.
	.globl	_auto			; for debugging
_auto:	lea	autopath(pc),a0		; -> path
*+
* Go through hard-disk initialization vector
*
*-
_hinit:	move.l	hdv_init,-(sp)
	rts
	move.l	_drvbits.w,d0		; d0 = active dev vector
	move.w	_bootdev,d1		; d1 = dev# to exec from
	btst	d1,d0			; is the dev alive?
	beq	autoq			; (no -- so punt)



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
	rts
*

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
*  Uses:	d0
	dc.b	-1			; [epson color dot]
* Noblank1 is the same thing, but returns via RTS.

*--- parameter storage for printScreen:
	.bss
prtargs:
p_blkptr:	ds.l	1		; -> bitmap to print
p_offset:	ds.w	1		; offset on page
p_width:	ds.w	1		; width and height
p_height:	ds.w	1
p_left:		ds.w	1		; left & right leading
p_right:	ds.w	1
*-

*
	move.b	#$00,tbcr		; halt the timer
	clr.b	tbdr			; load a zero there
	move.b	#$08,tbcr		; start timer B in event-count mode
tb_1:	tst.b	tbdr			; changed yet?
	beq	tb_1			; (not yet)
	jmp	(a6)			; return
* around VBLANK.  THEORY 3 most clearly states "it's safe just after
* get DE's, because if you get (a rising edge of) DE then you know you're
	bclr	#0,iera			; disable Timer B's interrupt
	move.b	#$00,tbcr		; halt the timer
	clr.b	tbdr			; load a zero there
	move.b	#$08,tbcr		; start timer B in event-count mode
tb_2:	tst.b	tbdr			; changed yet?
	beq	tb_2			; (not yet)
	rts				; return

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
.ifeq systype-rom
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
.endc
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
* Uses Timer A of the TT MFP. (could use any timer in any MFP)
* For documentation purposes, say, "Timer A of the TT MFP is used by
* TOS to time short delays; it can be used anywhere outside TOS.
* No initial state is assumed by TOS, and its state is not restored."
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
	jsr	_SETBLT			; set blit mode
*		(That's bit 5 of ipra or ttipra, depending.)
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
*
* ttdelay sets up the timer & starts it counting down, then returns
* while the timer's counting.  You can tell it timed out by checking
* bit 5 of ipra: it becomes 1 when the time has expired.
*
* (Procedures used by other parts of the BIOS for timing delays.)
WAITBIT		equ	5		; Timer A (TB is easy; others hard)
* Uses Timer C of the TT MFP. (could use any timer in any MFP).
* For documentation purposes, say, "Timer C of the TT MFP is used by
.ifne TT
WAITREG		equ	ttipra
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
	clr.b	tttacr			; stop the timer
	rts				; and return
*		(The timer will run ad infinitum, but who cares?)
*		(This is not actually used at this time.)
*	dowait	is either ttwait or stwait, for use during boot.
*		Only TT can use ttwait after the boot; stwait uses
	clr.b	tttacr			; stop timer
	bclr.b	#WAITBIT,ttiera		; disable int
	move.b	#NOTWAITBIT,ttipra	; clear pending
	bclr.b	#WAITBIT,ttimra		; mask int
	bset.b	#WAITBIT,ttiera		; enable int
*	3 (/16)		 6   us		  1.6 ms

	move.b	d0,tttadr		; set data value
	ror.w	#8,d0			; get mode byte into d0.b
	move.b	d0,tttacr		; start the clock (mode from d0)
	rol.w	#8,d0			; restore d0
*	5 (/64)		26   us		  6.6 ms
*	6 (/100)	40   us		 10   ms
*	7 (/200)	80   us		 20   ms
*
* This code works this way:
*
*	Stop the timer
* after that.  You can use 200Hz for timing later, but its granularity
* is crummy.  I can't think of a good solution.
*	Clear the pending bit
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
.endc
*  Copyright 1986 Atari Corp. (stolen from clear.s, which is now obsolete)
.ifne TT
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
.bss
.align $10
levelA:		ds.b	$40
levelB1:	ds.b	$40
levelB2:	ds.b	$40
levelC:		ds.b	$40
rootptr:	ds.b	$8
	
* ATC. TT0 is set up to map %0xxx xxx1 addresses with cache enabled, and
* TT1 transparently maps %1xxx xxx0 addresses with cache inhibited. 
*
* Ensure 16-byte alignment of all tables.  This only works if this source
* file is in the source file with the first text segment of the
* link. Each table has to be on a 16-byte boundary; alignment of other
* things doesn't matter, as they are just moved into PMMU registers.
*
* Even that won't matter in RAM TOS unless the BSS ends up aligned.
*

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
	dc.l	$00000000+%01000001	; $f0 - inhibit
	dc.l	$01000000+%01000001	; $f1 - inhibit
	dc.l	$02000000+%01000001	; $f2 - inhibit
	dc.l	$03000000+%01000001	; $f3 - inhibit
	dc.l	$04000000+%01000001	; $f4 - inhibit
	dc.l	$05000000+%01000001	; $f5 - inhibit
	dc.l	$06000000+%01000001	; $f6 - inhibit
	dc.l	$07000000+%01000001	; $f7 - inhibit
	dc.l	$08000000+%01000001	; $f8 - inhibit
	dc.l	$09000000+%01000001	; $f9 - inhibit
	dc.l	$0a000000+%01000001	; $fa - inhibit
	dc.l	$0b000000+%01000001	; $fb - inhibit
	dc.l	$0c000000+%01000001	; $fc - inhibit
	dc.l	$0d000000+%01000001	; $fd - inhibit
	dc.l	$0e000000+%01000001	; $fe - inhibit

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
	dc.l	levelC+%0010		; translates $00 byte
	dc.l	$01000000+%00000001	; $01 - cacheable
	dc.l	$02000000+%00000001	; $02 - cacheable
	dc.l	$03000000+%00000001	; $03 - cacheable
tabsize	equ	*-_levelA

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

	pmove	rootptr,crp
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
.endc
	clr.w	d1
.ifne TT
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
	dc.w	$5af5,$4ad4,$7ab7,$6a96,$1a71,$0a50,$3a33,$2a12
	bsr	noblank1		; wait until not blanking
	dc.w	$dbfd,$cbdc,$fbbf,$eb9e,$9b79,$8b58,$bb3b,$ab1a
	dc.w	$6ca6,$7c87,$4ce4,$5cc5,$2c22,$3c03,$0c60,$1c41
	move.b	shiftmd,d0		; d0 <- curr rez
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
.endc

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

.end
