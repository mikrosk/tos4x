* sparrequ.s - equates for Sparrow (Falcon/030)
* -----------------------------------------------------------------------
* 920702 kbad

*--- SPARROW memory configuration
sp_config	= $ffff8006	;.b read here to auto-config
* vvmmrrbf  (read-only config register)
* 00	    ST Mono
* 01	    ST Color
* 10	    VGA
* 11	    TV
*   00	    256K DRAMs
*   01	    1M DRAMs
*   10	    4M DRAMs
*     rr    # ROM wait states
*	b   if 1, 32 bit video bus else 16 bit video bus
*        f  # DRAM wait states
					
*--- SPARROW CPU clock select & misc. controls
sp_clock	= $ffff8007	;.b clock select & misc controls
* dvimbs-c  (r/w)
*        c CPU speed (0=8MHz, 1=16MHz)
*      s-- Blitter clock (0=8MHz, 1=16MHz)
*     b--- Blit disable
*    m---- MCUG disable
*   i----- Addr BERR enable
*  v------ powerfail
* d------- bus error timeout (0=16us, 1=32us)

*--- SPARROW video hardware registers

* STe-compatible registers
st_vbash	= $ffff8201	;.b video base hi
st_vbasm	= $ffff8203	;.b video base mid
st_vach		= $ffff8205	;.b video address counter hi
st_vacm		= $ffff8207	;.b video address counter mid
st_vacl		= $ffff8209	;.b video address counter lo
st_sync		= $ffff820a	;.b sync: %%1: 50Hz, %%0: external sync
st_vbasl	= $ffff820d	;.b video base lo
st_hoff		= $ffff820e	;.w horizontal offset (a.k.a. dstride)

st_color0	= $ffff8240	;.w STe palette reg 0	[---- Rrrr Gggg Bbbb]
				;.w 1-f (to 825e)	[---- 0321 0321 0321]
st_shift	= $ffff8260	;.b ST shift mode
st_hbits	= $ffff8265	;.b horizontal pixel scroll

*--- Sparrow registers		;.w
sp_vwrap	= $ffff8210	;.w display line width in words
sp_shift	= $ffff8266	;.w SP shift mode [---- oct Rhvm bbbb]

* Horizontal video control regs
sp_HC	= $ffff8280	;.w Horizontal Counter
sp_HHT	= $ffff8282	;.w H Half-line Total
sp_HBB	= $ffff8284	;.w H Blank Begin
sp_HBE	= $ffff8286	;.w H Blank End
sp_HDB	= $ffff8288	;.w H Display Begin
sp_HDE	= $ffff828a	;.w H Display End
sp_HSS	= $ffff828c	;.w H Sync Start
sp_HFS	= $ffff829e	;.w H Field Sync end
sp_HEE	= $ffff8290	;.w H Equalization End

* Vertical video control regs
sp_VC	= $ffff82a0	;.w Vertical counter
sp_VFT	= $ffff82a2	;.w V Field Total (%%0: interlace off)
sp_VBB	= $ffff82a4	;.w V Blank Begin
sp_VBE	= $ffff82a6	;.w V Blank End
sp_VDB	= $ffff82a8	;.w V Display Begin
sp_VDE	= $ffff82aa	;.w V Display End
sp_VSS	= $ffff82ac	;.w V Sync Start

*--- SPARROW video master control register
sp_VMC	= $ffff82c0	;.w video master control
* -------o bhvcesvv (r/w)
*		 vv as SPconfig, read it for these
*		s-- 0: primary clock (normally 32MHz) 1: secondary clock
*	       e--- equalization pulses off
*             c---- invert Csync
*            v----- invert Vsync
*           h------ invert Hsync
*          b------- as SPconfig, read it for this
*        o -------- burst time (0=4us, 1=2us)

sp_VCO	= $ffff82c2	;.w video timing control
* -------- ----mmir
*                 r repeat lines
*                i- skip lines
*              mm-- dot clock: 0=8MHz, 1=16/12.5MHz, 2=32/25MHz
* (in STe mode, writing st_shift after writing VMC auto-updates VTC)

sp_color0	= $ffff9800	;.l Sparrow palette reg 00:
				; [rrrr rr-- gggg gg-- ---- ---- bbbb bb--]
				; 01-ff (to 9bfc)

*
* Sparrow video XBIOS calls (vtg.o)
*
 .globl _VsetMode,_VgetMonitor,_VsetSync,_VgetSize,_VsetVars
 .globl	_VsetRGB,_VgetRGB,_ValidMode,_SetOverlay,_SetMasks
 .globl	_modecode,_n_rgb

* _VsetMode(WORD modecode)
* 0000000i sopvcbbb
*               ^^^ log2 bits per pixel
*              c--- columns: 1=80 0=40
*             v---- VGA mode
*            p----- 1=PAL 0=NTSC
*           o------ overscan
*          s------- ST compatibility mode
*        i -------- interlace/vertical doubling

*
* Sparrow DSP XBIOS calls (dsp.o)
*
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
