/* vtg.c - Sparrow video functions
 * ======================================================================
 * ½ 1992 Atari Corp.
 *
 * 920729 kbad	Fixed macros and a couple of bad table values.
 *		This version works.
 * 920714 kbad	restructured, flagged default-init values ("DEFAULT")
 *		which must initialize to 0 in BSS for ROM code,
 *		made tables char-sized.
 */

/* Imports
 *=======================================================================
 */
#include "portab.h"
#include "sparrow.h"

#undef MLOCAL
#define MLOCAL /* keep locals global for debugging */

/*
 * Hack to circumvent GO's nasty habit of converting register pointers
 * into base register or stack frame offsets.
 */
void *regptr(const void *p);
#pragma inline a0=regptr(a0) { ""; }
#define lptr(l) (regptr((void *)(l)))

/* unsigned a*b/c */
unsigned short umul_div(unsigned int,unsigned int,unsigned int);
#pragma inline d0=umul_div(d0,d1,d2)	{"c0c180c2";}

/*
 * Srealloc bind
 */
void *__pgl(int,long);
#pragma inline d0=__pgl((short),) {register d2,a2; "4e41";}
#define Srealloc(p) __pgl(0x15,(p))

#ifdef TEST
/*
 * Super(), for testing with a standalone program
 */
#define Super(l) __pgl(0x20,(long)(l))
#define esc_init _esc_init
#endif

#ifdef _BIOS
/*
 * If linked with BIOS, turn Vsync() into wvbl(),
 * and use BIOS _esc_init() label.
 */
void wvbl(void);
#define Vsync() wvbl()
#define esc_init _esc_init
#else
/*
 * If linked with VDI, call XBIOS for wvbl(),
 * and use VDI esc_init() function.
 */
void __vxv(int);
#pragma inline __vxv((short)) {register d2,a2; "4e4e";}
#define Vsync() __vxv(37)
#endif

void esc_init(void);

/*
 * System variables with BIOS names
 */

/* Hardware vars */
#define dbaseh	  ((BYTE *)0xffff8201L) /* display base %%16..%%23 */
#define dbasel	  ((BYTE *)0xffff8203L) /* display base %%8..%%15 */
#define dbasell   ((BYTE *)0xffff820dL) /* display base %%0..%%7 */
#define shiftmd   ((BYTE *)0xffff8260L) /* ST shift mode */
#define st_color0 ((WORD *)0xffff8240L)
#define sp_color0 ((long *)0xffff9800L)

/* System vars */
#define sshiftmd ((BYTE *)0x44cL) /* ST shift mode shadow */
#define v_bas_ad ((long *)0x44eL) /* VDI display base */
#define vblsem   ((WORD *)0x452L) /* Vblank semaphore */
#define colorptr ((long *)0x45aL) /* -> palette to set at Vblank */


/* Definitions
 *=======================================================================
 */

GLOBAL int	modecode;   /* @DEFAULT 0 */

/* Sparrow video mode word (modecode)
 * """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
 * The sparrow knowledge tables are taken from the VTG Cookbook with
 * several simplifications.  Always assume a 2us video burst.
 *
 * The mode word is encoded thusly:
 * 0000000i sopvcbbb
 *               ^^^ log2 bits per pixel
 *              c--- columns: 1=80 0=40
 *             v---- VGA mode
 *            p----- 1=PAL 0=NTSC
 *           o------ overscan
 *          s------- ST compatibility mode
 *        i -------- interlace (TV) / vertical doubling (VGA)
 *
 * NOTE: isXXX() macros are logical macros which must result in 0 or 1.
 *	 To test a single bit, (mode & BIT) may be more efficient.
 */

/* log2 bits per pixel values */
#define BPPMASK	0x007	/* modecode mask for log2(bits per pixel) */
#define BPP1	0x000
#define BPP2	0x001
#define BPP4	0x002
#define BPP8	0x003
#define BPP16	0x004
#define BPP32	0x005
#define BPP(m)	((m) & BPPMASK)

/* # of columns */
#define COLMASK	0x008	/* modecode mask for # of columns */
#define COL40	0x000
#define COL80	0x008
#define is40(m)	(((m) & COLMASK) == COL40)
#define is80(m)	(((m) & COLMASK) == COL80)


/* video modes */
#define VIDMASK	0x1f0	/* modecode mask for monitor type & display mode */

/* monitor types */
#define MONMASK	0x010	/* VGA/TV monitor mask */
#define TV	0x000
#define VGA	0x010
#define PAL	0x020
#define isTV(m)  (((m) & MONMASK) == TV)
#define isVGA(m) (((m) & MONMASK) == VGA)
#define isPAL(m) (((m) & PAL) == PAL)

/* display modes */
#define OVERSCAN 0x040	/* h & v res are 1.2 * normal */
#define STMODE	 0x080	/* ST compatible mode */
#define VERTFLAG 0x100	/* Interlace (TV) / Vertical doubling (VGA) */
#define isOVERSCAN(m)	(((m) & OVERSCAN) == OVERSCAN)
#define isSTMODE(m)	(((m) & STMODE) == STMODE)
#define isVMODE(m)	(((m) & VERTFLAG) == VERTFLAG)
/*
 * NOTE: In VGA modes, setting VERTFLAG *halves* the vertical resolution;
 *	in TV modes, setting VERTFLAG *doubles* the vertical resolution.
 */

/*
 * Monitor type macro for VmonType
 */
#define MonType() ((*Config >> 6) & 0x3)
#define MON_MONO    0
#define MON_COLOR   1
#define MON_VGA	    2
#define MON_TV	    3


/* Sparrow video timing registers
 *-----------------------------------------------------------------------
 */

/* Horizontal timing registers */
typedef struct {
	WORD ht;	/* half-line total */
	WORD bb;	/* blank begin */
	WORD be;	/* blank end */
	WORD db;	/* display begin */
	WORD de;	/* display end */
	WORD ss;	/* sync start */
#ifdef EXTENDED_HT
	WORD fs;	/* field sync end */
	WORD ee;	/* equalization end */
#endif
} HTREGS;

/* Vertical timing registers */
typedef struct {
	WORD ft;	/* field total (ft&1 == non-interlace) */
	WORD bb;	/* blank begin */
	WORD be;	/* blank end */
	WORD db;	/* display begin */
	WORD de;	/* display end */
	WORD ss;	/* sync start */
} VTREGS;

/* Hardware and shadow timing registers */
static HTREGS * const sp_h = (HTREGS *)(0xffff8282);
MLOCAL HTREGS xh;
static VTREGS * const sp_v = (VTREGS *)(0xffff82a2);
MLOCAL VTREGS xv;

/* Control register shadows */
MLOCAL WORD xhoff, xvwrap, xvco, xvmc;
MLOCAL long xdoff;

/* Algorithmic timing definitions
 *-----------------------------------------------------------------------
 */
typedef struct {
	long inclk;		/* 1/32MHz, 1/25Mhz, or external */
	long sync_width;	/* HHS-HSS */
	long front_porch;	/* HHS-HBB (includes sync pulse) */
	long back_porch;	/* HBE */
/* HBLANK = sync_width + front_porch + back_porch, or HHS-HBB+HBE */
	long rborder;		/* HBB-HBEI */
	long lborder;		/* HDBI-HBE */
	long display;		/* HDEI-HDBI */
	long line;		/* display + lborder + rborder + HBLANK */
} HTIMING;

HTIMING	htv;	/* timing variables */

/* External values flags (@DEFAULT to 0) */
MLOCAL WORD vtg_user;

/* bits in userdef */
#define USER_HTV    0x0001
#define USER_XV	    0x0002
#define USER_HOFF   0x0004
#define USER_VWRAP  0x0008
#define USER_VCO    0x0010
#define USER_VMC    0x0020


/* VDI screen definition structure
 *-----------------------------------------------------------------------
 */
typedef struct {
	void	*name;		/* $00 */
	WORD	devId;		/* $04 */
	WORD	planes; 	/* $06 */
	WORD	lineWrap;	/* $08 */
	WORD	xRez;		/* $10 */
	WORD	yRez;		/* $12 */
	WORD	xSize;		/* $14 */
	WORD	ySize;		/* $16 */
	WORD	formId; 	/* $18 */
	void	*fntptr;	/* $1a */
	WORD	maxPen; 	/* $1e */
	WORD	colFlag;	/* $20 */
	WORD	palSize;	/* $22 */
	WORD	lookupTable;	/* $24 */
	void	*softRoutines;	/* $26 */
	void	*hardRoutines;	/* $2a */
	void	*curRoutines;	/* $2e */
	void	*base;		/* $32 */
} SCREENDEF;

/* Pixel size for 91 dpi (* 2 for 45 dpi) */
#define DPI91_SIZE 278

void dev_init( SCREENDEF *p );
MLOCAL SCREENDEF sdef;

/* Timing Tables for VTG Configuration
 *=======================================================================
 */

/************************************************************************

The basis of the following is timing information in small units. Let's
try doing things in terms of hundreths of nanoseconds. This will not
cause any problems with any times that occur in video setup.

STE modes will be handled by direct table lookup. Computations will be
done for those modes that are NEW only. This does _NOT_ mean STE and
Sparrow modes as defined in the Sparrow Specification. It means
compatibility modes are in a table. _All_ 2 bit per pixel modes will
be done with STE modes because Sparrow modes can't do it.

As an example:  modecode = VGA|COL80|BPP4;

These tables are in VTG clocks.
There are three timing tables, they give values (in VTG clocks) for
d1, d2, and d3. The sum d1+d2+d3 is the amount of extra time needed
before HDB. HDE needs to be earlier as well as only d3.

*************************************************************************/


/* Table lookup macro */
#define TABVAL(tab,mode)    ((int)(tab)[(mode)&0x1f])


/* D1TAB: account for delay needed for initial video burst.
 *-----------------------------------------------------------------------
 * values are D2TAB+1+fudge
 */
static unsigned char D1TAB[0x20] =
{
80+0+1+80,	/* 0x00 (TV|COL40|BPP1) */
18+1+1+5,	/* 0x01 (TV|COL40|BPP2) */
32+5+1+29,	/* 0x02 (TV|COL40|BPP4) */
16+5+1+29,	/* 0x03 (TV|COL40|BPP8) */
0+3+1+29,	/* 0x04 (TV|COL40|BPP16) */
0, 0, 0,	/* (reserved) */
130+1+1+45,	/* 0x08 (TV|COL80|BPP1) */
8+1+1+13,	/* 0x09 (TV|COL80|BPP2) */
32+5+1+45,	/* 0x0a (TV|COL80|BPP4) */
16+5+1+45,	/* 0x0b (TV|COL80|BPP8) */
0+1+1+45,	/* 0x0c (TV|COL80|BPP16) */
0, 0, 0,	/* (reserved) */
128+0+1+48,	/* 0x10 (VGA|COL40|BPP1) */
16-5+1+5,	/* 0x11 (VGA|COL40|BPP2) */
32+6+1+45,	/* 0x12 (VGA|COL40|BPP4) */
16+6+1+45,	/* 0x13 (VGA|COL40|BPP8) */
0+0+1+49,	/* 0x14 (VGA|COL40|BPP16) */
0, 0, 0,	/* (reserved) */
64+1+1+41,	/* 0x18 (VGA|COL80|BPP1) */
8+2+1+11,	/* 0x19 (VGA|COL80|BPP2) */
16+5+1+37,	/* 0x1a (VGA|COL80|BPP4) */
8+5+1+37,	/* 0x1b (VGA|COL80|BPP8) */
0+8+1+37,	/* 0x1c (VGA|COL80|BPP16) 920714 kbad 30->37*/
0, 0, 0		/* (reserved) */
};

/* D2TAB: delay caused by filling the delay register used for bit scrolling
 *-----------------------------------------------------------------------
 * values are D3TAB+fudge
 */
static unsigned char D2TAB[0x20] =
{
80+0,	/* 0x00 (TV|COL40|BPP1) */
18+1,	/* 0x01 (TV|COL40|BPP2) */
32+5,	/* 0x02 (TV|COL40|BPP4) */
16+5,	/* 0x03 (TV|COL40|BPP8) */
0+3,	/* 0x04 (TV|COL40|BPP16) */
0, 0, 0, /* (reserved) */
130+1,	/* 0x08 (TV|COL80|BPP1) */
8+1,	/* 0x09 (TV|COL80|BPP2) */
32+5,	/* 0x0a (TV|COL80|BPP4) */
16+5,	/* 0x0b (TV|COL80|BPP8) */
0+1,	/* 0x0c (TV|COL80|BPP16) */
0, 0, 0, /* (reserved) */
128+0,	/* 0x10 (VGA|COL40|BPP1) */
16-5,	/* 0x12 (VGA|COL40|BPP2) */
32+6,	/* 0x12 (VGA|COL40|BPP4) */
16+6,	/* 0x13 (VGA|COL40|BPP8) */
0+0,	/* 0x14 (VGA|COL40|BPP16) */
0, 0, 0, /* (reserved) */
64+1,	/* 0x18 (VGA|COL80|BPP1) */
8+2,	/* 0x19 (VGA|COL80|BPP2) */
16+5,	/* 0x1a (VGA|COL80|BPP4) */
8+5,	/* 0x1b (VGA|COL80|BPP8) */
0+8,	/* 0x1c (VGA|COL80|BPP16) */
0, 0, 0	 /* (reserved) */
};

/* D3TAB: delay caused by loading the 8-word pipeline.
 *-----------------------------------------------------------------------
 * NOTE: this table is not used by the code, but is left here for reference.
 */
static unsigned char D3TAB[0x20] =
{
80,	/* 0x00 (TV|COL40|BPP1) */
18,	/* 0x01 (TV|COL40|BPP2) */
32,	/* 0x02 (TV|COL40|BPP4) */
16,	/* 0x03 (TV|COL40|BPP8) */
0,	/* 0x04 (TV|COL40|BPP16) */
0, 0, 0, /* (reserved) */
130,	/* 0x08 (TV|COL80|BPP1) */
8,	/* 0x09 (TV|COL80|BPP2) */
32,	/* 0x0a (TV|COL80|BPP4) */
16,	/* 0x0b (TV|COL80|BPP8) */
0,	/* 0x0c (TV|COL80|BPP16) */
0, 0, 0, /* (reserved) */
128,	/* 0x10 (VGA|COL40|BPP1) */
16,	/* 0x12 (VGA|COL40|BPP2) */
32,	/* 0x12 (VGA|COL40|BPP4) */
16,	/* 0x13 (VGA|COL40|BPP8) */
0,	/* 0x14 (VGA|COL40|BPP16) */
0, 0, 0, /* (reserved) */
64,	/* 0x18 (VGA|COL80|BPP1) */
8,	/* 0x19 (VGA|COL80|BPP2) */
16,	/* 0x1a (VGA|COL80|BPP4) */
8,	/* 0x1b (VGA|COL80|BPP8) */
0,	/* 0x1c (VGA|COL80|BPP16) */
0, 0, 0	 /* (reserved) */
};


/* ratediv: clock rate divisor table
 *-----------------------------------------------------------------------
 * There are three different clocks possible in the video system:
 * 32MHz, 25MHZ, EXTernal.  This table returns the appropriate divisor
 * for the clock in use.
 *
 * The algorithm which generates this table is:
 * switch (BPP(mode))
 * {	case BPP2:		     return 16;
 *	case BPP16: if (isVGA(mode)) return is80(mode) ? 1 : 2;
 *		    else	     return is80(mode) ? 2 : 4;
 *	default:    if (isVGA(mode)) return 2;
 *		    else	     return is80(mode) ? 2 : 4;
 * }
 *
 * Note that the last 3 numbers on each line are actually reserved
 * values, but they're not set to 0 to prevent divide exceptions.
 */
static unsigned char ratediv[0x20] =
{
	4, 16, 4, 4,  4,  4, 4, 4,	/* TV|COL40 */
	2, 16, 2, 2,  2,  2, 2, 2,	/* TV|COL80 */
	2, 16, 2, 2,  2,  2, 2, 2,	/* VGA|COL40 */
	2, 16, 2, 2,  1,  2, 2, 2	/* VGA|COL80 */
};

/* shift counts corresponding to above divisors */
static unsigned char rateshift[0x20] =
{
	2, 4, 2, 2,  2,  0, 0, 0,	/* TV|COL40 */
	1, 4, 1, 1,  1,  0, 0, 0,	/* TV|COL80 */
	1, 4, 1, 1,  1,  0, 0, 0,	/* VGA|COL40 */
	1, 4, 1, 1,  0,  0, 0, 0	/* VGA|COL80 */
};


/* Given a mode, return a rate divisor */
#define getdiv(mode) ( (long)ratediv[(mode) & 0x1f] )
/* Given a mode, return a clock divisor shift count */
#define clkshift(mode) ( (long)rateshift[(mode) & 0x1f] )


/* Functions
 *=======================================================================
 */
static WORD _foo(long var, long clk, long div);
MLOCAL void dovgt(WORD mode);
MLOCAL void set_regs(WORD mode);
MLOCAL WORD mode_yres(WORD mode);
MLOCAL WORD mode_vwrap(WORD mode);
MLOCAL void mode2sdef(WORD mode, SCREENDEF *ps);

GLOBAL WORD VsetMode(WORD mcode);
GLOBAL WORD VgetMonitor(void);
GLOBAL void VsetSync(WORD external);
GLOBAL long VgetSize(WORD mode);
GLOBAL void VsetVars(WORD mask, WORD user, void *vars);
static void vbl_off(void);
static void vbl_on(void);
GLOBAL void VsetRGB(WORD index, WORD count, long *array);
GLOBAL void VgetRGB(WORD index, WORD count, long *array);
GLOBAL WORD ValidMode(WORD trymode);
GLOBAL WORD setscreen(long log, long phys, WORD rez, WORD mode);
GLOBAL WORD getrez(void);

/*
 * void dovtg()
 * """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
 * Do some VTG calculations and setup our values to stuff into VTG
 * registers.
 *
 */

/************************************************************************
    ---------------------------------------------------------------------
    Leonard's comments about how this algorithm works. These are kept
    here for completeness and to make him happy ;-)
    ---------------------------------------------------------------------

	    _____XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX____
      _____|						   |____
     |								|__|
								  HHS
		HDBI				   HDEI        HSS
	HBE					       HBB

    The size of sync is HHS-HSS :HSYNCWIDTH
    The front porch is HHS-HBB (this includes the sync pulse) :HFRONTPORCH
    The back porch is HBE :HBACKPORCH
    Total blanking time is HHS-HBB+HBE
    The right border is HBB-HBEI in width :HRBORDER
    The left border is HDBI-HBE in width :HLBORDER
    The size of the displayed area is HDEI-HDBI :HDISPLAY

    The easiest numbers for me to use are:
	HLINE => HHT=foo(HLINE)/2-2
	HSYNCHWIDTH => HSS=HHT-foo(HSYNCWIDTH)-1
	HBACKPORCH => HBE=foo(HBACKPORCH)
	HLBORDER => HDBI=HBE+foo(HLBORDER)
	HDISPLAY => HDEI=HDBI+foo(HDISPLAY)-HHT
	HFRONTPORCH => HBB=HSS-foo(HFRONTPORCH)

    The standard set is overdetermined.
    It also includes:
	HRBORDER
	HBLANK
    These are related in many ways, such as,

    HBLANK=HSYNCWIDTH+HFRONTPORCH+HBACKPORCH;
    HLINE=HDISPLAY+HLBORDER+HRBORDER+HBLANK;

    This version does no internal consistency checking and will do nothing
    to check for posible problems caused by truncation error

    ---------------------------------------------------------------------
    END OF LEONARD'S COMMENTS
    ---------------------------------------------------------------------
*************************************************************************/

/*-----------------------------------------------------------------------
 * Given a timing variable, rate divisor and shift count,
 * compute a timing register value.
 */
static WORD
_foo(long var, long clk, long div)
{
    return (WORD)( (var/clk) / div );
}

/* Setting functions
 *-----------------------------------------------------------------------
 */
void
set_vmc(WORD v)
{
    if (!(vtg_user & USER_VMC))
	xvmc = v;
}

void
set_vco(WORD v)
{
    if (!(vtg_user & USER_VCO))
	xvco = v;
}


/*=======================================================================*/

MLOCAL void
dovtg(WORD mode)
{
    WORD hdbi, hdei;
    WORD delay, simple, buffer;

/* trivial optimizations: */
    HTREGS *h = regptr(&xh);
    HTIMING *t = regptr(&htv);
    long shift = clkshift(mode);
    long div = getdiv(mode);

/*'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''*/
/* The following macros do the same thing as the _foo() function
 * in more or less efficient ways.  The last foo() definition is
 * the one in use.
 */
/* foo() using function */
#undef foo
#define foo(var) _foo((var),t->inclk,div)

/* inline _foo() using 2 long divides */
WORD ldivdiv(long,long,long);
#pragma inline d0=ldivdiv(d0,d1,d2) {"4c4108004c420800";}
				    /* divs.l d1,d0; divs.l d2,d0 */
#undef foo
#define foo(var) ldivdiv((var),t->inclk,div)

/* inline _foo() using long divide & shift */
WORD divsl_asr(long,long,long);
#pragma inline d0=divsl_asr(d0,d1,d2) {"4c410800e4a0";}
				    /* divs.l d1,d0; asr.l d2,d0 */
#undef foo
#define foo(var) divsl_asr((var),t->inclk,shift)
/*'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''*/

/*
 * Initialize timing values based on monitor type
 */
    if (!(vtg_user & USER_HTV))
    {
#define VGACLK	3972L	/* 25.175 MHz */
    static HTIMING htv_vga = {	VGACLK, 381000L, 64000L, 191000L, 0L,
				0L, VGACLK*640L, 3178000L };
#define PALCLK	3125L	/* 32MHz */
    static HTIMING htv_pal = {	PALCLK, 470000L, 150000L, 514500L, 700000L,
				500000L, PALCLK*640L*2L, 6400000L };
#define NTSCLK	3104L /* 32.21 MHz */
    static HTIMING htv_ntsc = { NTSCLK, 460500L, 174500L, 514500L, 700000L,
				500000L, NTSCLK*640L*2L, 6355550L };

	if (mode & VGA)		t = &htv_vga;
	else if (mode & PAL)	t = &htv_pal;
	else			t = &htv_ntsc;
    }

/*
 * Compute easy registers
 */
    h->ht = foo(t->line)/2 - 2;
    h->ss = h->ht - foo(t->sync_width) - 1;
    h->bb = h->ss - foo(t->front_porch) - 1;

    h->be = foo(t->back_porch) - 1;
    hdbi = h->be + foo(t->lborder);
    hdei = hdbi + foo(t->display) - h->ht;

/* Adjust HBE *after* computing hdbi, hdei (!?) */
    h->be -= (mode & VGA) ? 2 : 1;

/*
 * Adjust for overscan
 * NOTE: this might result in smaller code if table-driven.
 */
    if ((mode & OVERSCAN) && (MonType() != MON_VGA))
    {
	if (BPP(mode) == BPP2)
	{
	    if (mode & COL80)
		hdbi -= 4, hdei += 4;
	    else
		hdbi -= 7, hdei += 9;
	}
	else
	{
	    if (mode & COL80)
		hdbi -= 64, hdei += 64;
	    else
		hdbi -= 32, hdei += 32;
	}
    } 


/* Compute Horizontal Display Begin
 *-----------------------------------------------------------------------
 * This is assumed the first one that is complex.
 * The simple case places Display Begin after the border.
 * This is complicated by the need for starting early to account
 * for delays in the hardware.
 * Let us assume a border of no width.  This means that Display begin
 * needs to be at Blank End minus the sum of the delays.
 * There is another effect, if the delays move the Display Begin to
 * earlier than the end of Sync then we must add HHT plus 512
 * to start delay based on the correct line half.
 */

    delay = TABVAL(D1TAB, mode) + 1; /* ARRRRGGGGHHH!!!! */
    simple = hdbi;
    if (simple - delay < 0)
	simple += h->ht + 2 + 512;
    h->db = simple - delay;


/* Compute Horizontal Display End
 *-----------------------------------------------------------------------
 * This is assumed to be the other one that is complex.
 * The simple case places Display End before the border.
 * This is complicated by the need for starting early to account
 * for buffers in the hardware.
 * Let us assume a border of no width.  This means that Display end
 * needs to be at Blank Begin minus the buffers delays.
 */

    buffer = TABVAL(D2TAB, mode);
    simple = hdei;
    h->de = simple - buffer;

/*
 * KLUDGE values for 2bpp modes.
 * I believe this should go away, since 2bpp modes *should* always
 * result in ST-compatible modes which are hardware-driven.
 */
    if (BPP(mode) == BPP2)
    {
	if (mode & VGA)
	{
	    h->bb = 0x12, h->be = 0x1;
	    if (mode & COL80) h->db = 0x20e, h->de = 0xd;
	    else h->db = 0x20a, h->de = 0x9;
	}
	else if ( (mode & (COL80|STMODE|OVERSCAN)) == COL80 )
	    h->db = 0x2, h->de = 0x20;
    }

/*
 * Set vertical timing shadows based on monitor type.
 */
    if (!(vtg_user & USER_XV))
    {
    static VTREGS xv_vga = { 1049, 1023, 63, 63, 1023, 1045 };
    static VTREGS xv_pal = { 625, 613, 47, 127, 527, 619 };
    static VTREGS xv_ntsc = { 525, 513, 22, 77, 477, 519 };
	VTREGS *vp;

	if (mode & VGA) vp = &xv_vga;
	else if (mode & PAL) vp = &xv_pal;
	else vp = &xv_ntsc;
	xv = *vp;
    }

/*
 * Set control registers
 */

/* VWRAP = Display line width in words = (bits per pixel * columns / 2) */
    if (!(vtg_user & USER_VWRAP))
    {
	WORD xxhoff;
	xvwrap = mode_vwrap(mode);
	if ((mode & (OVERSCAN|VGA)) == (OVERSCAN|VGA))
	{
	/* Adjust VGA overscan modes for pseudo-overscan.
	 * use non-overscanned VWRAP,
	 * horizontal offset:
	 * xhoff = .2 * VWRAP (non-overscan)
	 * display offset:
	 * xdoff = yres * lineWrap / 10 + VWRAP * 2 / 10
	 */
	    long lineWrap = xvwrap * 2;
	    xvwrap = umul_div(xvwrap, 10, 12);
	    xxhoff = xvwrap / 5;
	    xdoff = (long)umul_div(mode_yres(mode), 10, 12) * lineWrap / 10L
		    + (long)xvwrap / 5L;
	}
	else xdoff = xxhoff = 0;
	if (!(vtg_user & USER_HOFF)) xhoff = xxhoff;
    }

    if (!(vtg_user & USER_XV) && (mode & (OVERSCAN|VGA)) == OVERSCAN)
    {
	xv.db -= 40;
	xv.de += 40;
    }
/*
 * VMC: monitor type, clock, sync inverts, bus width & speed
 * NOTE: this is reset later for ST compatible modes, and for
 * non-VGA monitors that are actually TV's.
 */
    set_vmc((mode & VGA) ? 0x186 : 0x181);

/* VCO: first set dotclock, then set doubling/interlace bits */
    switch (mode & (VGA|COL80))
    {
	case (TV|COL40):    set_vco(0); break;	/* 8MHz dotclock */
	case (TV|COL80):
	case (VGA|COL40):   set_vco(4); break;	/* 16/12.5 MHz dotclock */
	case (VGA|COL80):   set_vco(8); break;	/* 32/25 MHz dotclock */
    }

    if (mode & VERTFLAG)
    {
	if (mode & VGA)
	{
	/* repeat lines */
	    set_vco(xvco|1);
	}
	else
	{
	/* skip lines, clear non-interlace bit, make VDB/VDE even */
	    set_vco(xvco|2);
	    if (!(vtg_user & USER_XV))
	    {
		xv.ft &= ~1;
		xv.db &= ~1;
		xv.de &= ~1;
	    }
	}
    }

/* Compatibility Modes
 *-----------------------------------------------------------------------
 * These are special numbers that are used to create compatible STE
 * resolutions. (ST Low, ST Medium, and ST High)
 * NOTE: ST High on color (vga, TV or monitor) uses values computed above.
 */
    if (mode & STMODE)
    {
				   /* ht     bb     be     db     de     ss */
    static HTREGS xh_st_mono =	  { 0x01a, 0x000, 0x000, 0x20f, 0x00c, 0x014 };
    static VTREGS xv_st_mono =	  { 0x3e9, 0x000, 0x000, 0x043, 0x363, 0x3e7 };
    static HTREGS xh_pal_color =  { 0x03e, 0x032, 0x009, 0x23f, 0x01c, 0x034 };
    static VTREGS xv_pal_color =  { 0x271, 0x265, 0x02f, 0x06f, 0x1ff, 0x26b };
    static HTREGS xh_ntsc_color = { 0x03e, 0x032, 0x009, 0x23f, 0x01c, 0x034 };
    static VTREGS xv_ntsc_color = { 0x20d, 0x201, 0x016, 0x04d, 0x1dd, 0x207 };
    static HTREGS xh_vg_color =   { 0x017, 0x012, 0x001, 0x20e, 0x00d, 0x011 };
    static VTREGS xv_vg_color =   { 0x419, 0x3af, 0x08f, 0x08f, 0x3af, 0x415 };

	if (mode & VGA)
	{
	    if (BPP(mode) == BPP1)
	    {
	    /* For ST High, adjust vertical values */
		xv.db += 80;
		xv.de -= 80;
		xv.bb -= 80;
		xv.be += 80;
	    }
	    else
	    {
		*h = xh_vg_color;
		xv = xv_vg_color;
		xvmc = 0x186;
		xvco = (BPP(mode) == BPP4) ? 4 : 8;
	    }
	}
	else
	{
	/* !VGA */
	    if (BPP(mode) == BPP1)
	    {
		if (MonType() == MON_MONO)
		{
		    *h = xh_st_mono;
		    xv = xv_st_mono;
		    xvmc = 0x80;
		    xvco = 8;
		}
		/* TV & Color monitor use computed values */
	    }
	    else
	    {
	    /* ST Medium and ST Low, TV modes */
		*h = (mode & PAL) ? xh_pal_color : xh_ntsc_color;
		xv = (mode & PAL) ? xv_pal_color : xv_ntsc_color;
		xvmc = 0x81;
		xvco = (BPP(mode) == BPP4) ? 0 : 4;
	    }
	}
    }

/*
 * Clear equalization pulses if this is a TV,
 * and set PAL mode if requested.
 */
    if (isTV(mode) && MonType() == MON_TV)
    {
	set_vmc(xvmc | 0x03);    /* Set TV mon. type in VMC */
	set_vmc(xvmc & ~0x08);   /* clear equalization pulses bit */
    }

    if (mode & PAL)
    /* set PAL bit */
	*SYNCMODE |= 0x02;
    else
    /* clear PAL bit */
	*SYNCMODE &= ~0x02;
}
/* End of dovtg() */


/* Set hardware timing registers from shadows
 *-----------------------------------------------------------------------
 */
MLOCAL void
set_regs(WORD mode)
{
    Vsync();

    *sp_h = xh;
    *sp_v = xv;

    if (xdoff)
    {
	union { char c[4]; long l; } sptr;
	sptr.c[0] = 0;
	sptr.c[1] = *dbaseh;
	sptr.c[2] = *dbasel;
	sptr.c[3] = *dbasell;
	sptr.l += xdoff;
	*dbaseh = sptr.c[1];
	*dbasel = sptr.c[2];
	*dbasell = sptr.c[3];
    }
    *HOFF = xhoff;
    *VWRAP = xvwrap;
    *VCO = xvco;
    *VMC = xvmc;

    *SP_Shift = 0; /* clear the cruft from the SP shifter */
    switch (BPP(mode))
    {
	case BPP16:	*SP_Shift = 0x100;	break;
	case BPP8:	*SP_Shift = 0x10;	break;
	case BPP4:
	    if (mode & STMODE)
	    {
		*ST_Shift = 0;
		if (mode & VGA) *VCO |= 0x1;
	    }
	break;
	case BPP2:
	    *ST_Shift = 1;
	/* Reset VWRAP & VCO, since COMBEL does it wrong */
	    *VWRAP = xvwrap;
	    *VCO = xvco | ((mode & (STMODE|VGA)) == (STMODE|VGA));
	break;
	case BPP1:
	    if (MonType() == MON_MONO) *ST_Shift = 2;
	    else *SP_Shift =0x400;
	break;
    }
}


/* Return Y resolution of a mode
 *-----------------------------------------------------------------------
 */
MLOCAL WORD
mode_yres(WORD mode)
{
    WORD y;

    if (isSTMODE(mode))
	y = (BPP(mode) == BPP1) ? 400 : 200;

    else
    {
	if (isVGA(mode))
	    y = (mode & VERTFLAG) ? 240 : 480;
	else /* TV or ST Color */
	    y = isVMODE(mode) ? 400 : 200;

	if (isOVERSCAN(mode))
	    y = y * 12 / 10;
    }

    return y;
}


/* Return VWRAP (words per display line) of a mode
 *-----------------------------------------------------------------------
 */
MLOCAL WORD
mode_vwrap(WORD mode)
{
    WORD vw;
    vw = ((mode & COL80) ? 40 : 20) << BPP(mode);
    if (mode & OVERSCAN) vw = vw * 12 / 10;
    return vw;
}



/*-----------------------------------------------------------------------
 * Set up SCREENDEF struct for a mode.
 */
MLOCAL void
mode2sdef(WORD mode, SCREENDEF *ps)
{
    WORD bpp = BPP(mode);
    WORD mt = MonType();

    /* Clear misc. variables */
    ps->name = ps->fntptr = ps->softRoutines =
    ps->hardRoutines = ps->curRoutines = ps->base = (void *)0L;

    /*
     * Set planes, palette size and num of pens.
     */
    ps->colFlag = (mt == MON_MONO) ? 0 : 1;
    ps->palSize = ((mode & STMODE) || bpp == 2) ? 4096 : 0;
    ps->planes = 1 << bpp;
    ps->maxPen = (ps->planes < 16) ? (1 << ps->planes) : 256;

    /* Line wrap - # of bytes per scan */
    ps->lineWrap = mode_vwrap(mode) * 2;

    /* X & Y Resolution */
    ps->xRez = (mode & COL80) ? 640 : 320;
    if (isOVERSCAN(mode)) ps->xRez = ps->xRez * 12 / 10;
    ps->yRez = mode_yres(mode);

    /*
     * xSize and ySize
     * xSize is doubled in 40 column modes,
     * ySize is doubled if !VGA && VERTFLAG or VGA && !VERTFLAG.
     * (note: isxxx() macros evaluate to 0 or 1)
     */
    ps->xSize = ps->ySize = DPI91_SIZE;
    if (!(mode & COL80))
	ps->xSize *= 2;
    if ( !((mt == MON_MONO) || (isVGA(mode) ^ isVMODE(mode))) )
	ps->ySize *= 2;

    if (bpp == BPP16)
    {
	ps->formId = 3; /* pixel packed */
	ps->lookupTable = 0;
    }
    else
    {
	ps->formId = 2; /* interleaved */
	ps->lookupTable = 1;
    }
}


/* THIS FUNCTION MUST GO AWAY WHEN WE LINK WITH SPARROW VDI */
#if defined(TEST)
void dev_init(SCREENDEF *p) {}
#endif

/************************************************************************/


/* WORD VsetMode( WORD mcode ) 					XBIOS @88
 * ======================================================================
 * This is the XBIOS call VsetMode( int modecode ) that will set the VTG
 * into a specific video mode. If you call this call with a -1 for the
 * modecode value, the call will return the current video mode.
 *
 */
GLOBAL WORD
VsetMode( WORD mcode )
{
    WORD curmode = modecode;
    if (mcode != -1)
    {
	if (BPP(mcode) == BPP1)
	{
	/* Set "safe" mode when going into BPP1 modes */
	    WORD safemode = (modecode & VIDMASK) | (COL40|BPP4);
	    dovtg(safemode);
	    set_regs(safemode);
	}
    /* Now set the requested mode */
	modecode = mcode;
	dovtg(modecode);
	set_regs(modecode);

	mode2sdef(modecode, &sdef);
	dev_init(&sdef);
    }
    return curmode;
}

/* WORD VgetMonitor( void ) 					XBIOS @89
 * ======================================================================
 * This is an XBIOS call that returns the type of the monitor you are
 * currently using. The hardware actually checks this all the time and
 * this call can be made at any time and check accordingly to make
 * changes according to what monitor you have hooked up. Whether the
 * OS will take care of this is up to speculation.
 */
GLOBAL WORD
VgetMonitor( void )
{
    return MonType();
}

#define VSS_CLOCK   0x01
#define VSS_VSYNC   0x02
#define VSS_HSYNC   0x03

/* void VsetSync(WORD external)					XBIOS @90
 * ======================================================================
 * Set internal/external clock and syncs.
 */
GLOBAL void
VsetSync(WORD external)
{
    if (external & VSS_CLOCK)
	*SYNCMODE |= 1;
    else *SYNCMODE &=~1;

    if (external & VSS_VSYNC)
	*SP_Shift |= 0x20;
    else *SP_Shift &= ~0x20;

    if (external & VSS_HSYNC)
	*SP_Shift |= 0x40;
    else *SP_Shift &= ~0x40;
}

/* long VgetSize(WORD mode) 					XBIOS @91
 * ======================================================================
 * This function takes a modecode and returns a size of a screen in
 * bytes.
 */
GLOBAL long
VgetSize( WORD mode )
{
    return (long)mode_vwrap(mode) * (long)mode_yres(mode) * 2;
}


/* void VsetVars(WORD mask, WORD user, void *vars)		XBIOS @92
 *=======================================================================
 * Set or clear external variable usage.
 * ----------------------------------------------------------------------
 * NOTE: This function is PRIVATE, NOT DOCUMENTED, and
 *	 _definitely_ SUBJECT TO CHANGE. Do NOT release information on
 *	 this calls.  It is for Atari use only.
 * ----------------------------------------------------------------------
 */
GLOBAL void
VsetVars(WORD mask, WORD user, void *vars)
{
    if (mask & USER_HTV)
    {
	if (user & USER_HTV)
	{
	    htv = *(HTIMING *)vars;
	    vtg_user |= USER_HTV;
	}
	else vtg_user &= ~USER_HTV;
    }

    if (mask & USER_XV)
    {
	if (user & USER_XV)
	{
	    xv = *(VTREGS *)vars;
	    vtg_user |= USER_XV;
	}
	else vtg_user &= ~USER_XV;
    }

    if (mask & USER_HOFF)
    {
	if (user & USER_HOFF)
	{
	    xhoff = *(WORD *)vars;
	    vtg_user |= USER_HOFF;
	}
	else vtg_user &= ~USER_HOFF;
    }

    if (mask & USER_VWRAP)
    {
	if (user & USER_VWRAP)
	{
	    xvwrap = *(WORD *)vars;
	    vtg_user |= USER_VWRAP;
	}
	else vtg_user &= ~USER_VWRAP;
    }

    if (mask & USER_VCO)
    {
	if (user & USER_VCO)
	{
	    xvco = *(WORD *)vars;
	    vtg_user |= USER_VCO;
	}
	else vtg_user &= ~USER_VCO;
    }

    if (mask & USER_VMC)
    {
	if (user & USER_VMC)
	{
	    xvmc = *(WORD *)vars;
	    vtg_user |= USER_VMC;
	}
	else vtg_user &= ~USER_VMC;
    }
}

/* n_rgb variable, used by vblank routine to determine # of colors to move */
GLOBAL WORD n_rgb;
static long sp_lut[256];

/* The following 2 functions brought to you courtesy of Lattice GO.TTP */

/* disallow vblank */
static void vb_off(void) { *vblsem = 0; }

/* allow vblank */
static void vb_on(void) { *vblsem = 1; }

/* void VsetRGB(index, count, array)				XBIOS @93
 *=======================================================================
 * Set colors by RGB value.
 * Each long in array[] has 4 bytes: 'xRGB'
 */
GLOBAL void
VsetRGB(WORD index, WORD count, long *array)
{
    long cptr;
    WORD nc;

long rgb2sp(long);
#pragma inline d0=rgb2sp(d0) \
    { \
	"e198"; /* rol.l #8,d0 */ \
	"e158"; /* rol.w #8,d0 */ \
    }

WORD rgb2st(long);
#pragma inline d0=rgb2st(d0) \
    { \
	"ea08"; /* lsr.b #5,d0 */ \
	"e618"; /* ror.b #3,d0 */ \
	"e210"; /* roxr.b #1,d0 */ \
	"e098"; /* ror.l #8,d0 */ \
	"ea08"; /* lsr.b #5,d0 */ \
	"e618"; /* ror.b #3,d0 */ \
	"e210"; /* roxr.b #1,d0 */ \
	"e098"; /* ror.l #8,d0 */ \
	"ea08"; /* lsr.b #5,d0 */ \
	"e618"; /* ror.b #3,d0 */ \
	"ea10"; /* roxr.b #5,d0 */ \
	"e198"; /* rol.l #8,d0 */ \
	"e848"; /* lsr.w #4,d0 */ \
	"e998"; /* rol.l #4,d0 */ \
    }

/*
 * Find max # of palette entries.
 * ST modes use the STe palette, which has 16 WORD entires.
 * SP modes < 8 bits per pixel use the SP palette, but are limited
 * to 16 entries, since writes to the palette registers wrap at 16
 * in those modes.  Other SP modes can use all 256 colors.
 */
    nc = ((modecode & STMODE) || BPP(modecode) < BPP8) ? 16 : 256;
    if (index+count <= nc)
    {
    /* Stuff palette shadow array */
	cptr = (long)sp_lut;
	if ((BPP(modecode) == BPP4 && (modecode & STMODE))
	||  (BPP(modecode) == BPP2)
	||  (BPP(modecode) == BPP1 && MonType() == MON_MONO))
	{
	/* To ST palette */
#ifdef _BIOS
	    REG WORD *lut = lptr(cptr);
#else
	    REG WORD *lut = st_color0;
#endif
	    lut += index;
	    while (--count >= 0)
		*lut++ = rgb2st(*array++);
	}
	else
	{
	/* To SP palette: set low bit of BIOS colorptr variable. */
#ifdef _BIOS
	    REG long *lut = lptr(cptr);
#else
	    REG long *lut = sp_color0;
#endif
	    lut += index;
	    while (--count >= 0)
		*lut++ = rgb2sp(*array++);
	    cptr |= 1L;
	}
#ifdef _BIOS
	/* Set colorptr & n_rgb for vblank update */
	vb_off();
	*colorptr = cptr;
	n_rgb = nc - 1;
	vb_on();
#endif
    }
}

/* void VgetRGB(WORD index, WORD count, long *array)		XBIOS @94
 *=======================================================================
 * Get colors by RGB value.
 * Output longs in array[] have 4 bytes: 'xRGB'
 */
GLOBAL void
VgetRGB(WORD index, WORD count, long *array)
{
long sp2rgb(long);
#pragma inline d0=sp2rgb(d0) \
    { \
	"e058"; /* ror.w #8,d0 */ \
	"e098"; /* ror.l #8,d0 */ \
    }

long st2rgb(WORD);
#pragma inline d0=st2rgb(d1) \
    { \
	"7000"; /* moveq     #0,d0 */ \
	"3001"; /* move.w    d1,d0 */ \
	"e948"; /* lsl.w     #4,d0 */ \
	"e308"; /* lsl.b     #1,d0 */ \
	"e718"; /* rol.b     #3,d0 */ \
	"e310"; /* roxl.b    #1,d0 */ \
	"e898"; /* ror.l     #4,d0 */ \
	"e308"; /* lsl.b     #1,d0 */ \
	"e718"; /* rol.b     #3,d0 */ \
	"eb10"; /* roxl.b    #5,d0 */ \
	"e098"; /* ror.l     #8,d0 */ \
	"eb08"; /* lsl.b     #5,d0 */ \
	"e718"; /* rol.b     #3,d0 */ \
	"eb10"; /* roxl.b    #5,d0 */ \
	"4840"; /* swap      d0	*/ \
    }

    if (index+count <= n_rgb+1) /* n_rgb is dbra count */
    {
	if ((BPP(modecode) == BPP4 && (modecode & STMODE))
	||  (BPP(modecode) == BPP2)
	||  (BPP(modecode) == BPP1 && MonType() == MON_MONO))
	{
	/* ST palette */
	    REG WORD *lut = regptr(sp_lut);
	    lut += index;
	    while (--count >= 0)
		*array++ = st2rgb(*lut++);
	}
	else
	{
	/* SP palette */
	    REG long *lut = regptr(sp_lut);
	    lut += index;
	    while (--count >= 0)
		*array++ = sp2rgb(*lut++);
	}
    }

}


/* WORD ValidMode(WORD mode)					XBIOS @95
 *-----------------------------------------------------------------------
 * Return a valid version of a mode code, based on what
 * monitor is attached.  The idea here is to get a similar-looking
 * screen if a VGA mode is set on a non-VGA monitor, or vice versa.
 */
GLOBAL WORD
ValidMode(WORD mode)
{
    WORD    mt = MonType();

    if (mt == MON_MONO)
    {
    /* On ST Mono monitors, only this mode is valid */
	return (STMODE|COL80|BPP1);
    }

    if (modecode & PAL) mode |= PAL;
    else mode &= ~PAL;

    if (mt == MON_VGA)
    {
	if (!(mode & VGA))
	    mode ^= (VGA | VERTFLAG);
	if (mode & STMODE)
	{
	    if (BPP(mode) == BPP1)
		mode &= ~VERTFLAG;
	    else
		mode |= VERTFLAG;
	}
    }
    else
    {
    /* TV or ST Color */
	if (mode & VGA)
	    mode ^= (VGA | VERTFLAG);

	if (mode & STMODE)
	{
	    if (BPP(mode) == BPP1)
		mode |= VERTFLAG;
	    else
		mode &= ~VERTFLAG;
	}
    }
    return mode;
}

/************************************************************************/

/* Return values for Getrez() */
#define DPI45x45 0
#define DPI91x45 1
#define DPI91x91 2
#define DPI45x91 7

/* WORD getrez(void)						XBIOS @4
 *=======================================================================
 * Return a number corresponding to the aspect ratio
 * of the current resolution.
 */
WORD
getrez(void)
{
    if (*sshiftmd == 3)
    {
	WORD y_is91dpi = (sdef.ySize == DPI91_SIZE);
	if (sdef.xSize == DPI91_SIZE)
	    return (y_is91dpi) ? DPI91x91 : DPI91x45;
	else
	    return (y_is91dpi) ? DPI45x91 : DPI45x45;
    }
    else return *sshiftmd;
}

/* WORD VsetScreen(log, phys, rez, mode)			XBIOS @5
 *=======================================================================
 * Set screen pointers and/or resolution.
 * If rez == 3, set Sparrow mode `mode'.
 * If setting a Sparrow mode, and log and phys are both 0L, reallocate
 * the screen if possible (-1 returned on error).
 * As before, if log or phys are -1L, the pointers are not set, and
 * if rez and/or mode are -1, the rez is not changed.
 *
 * Returns last screen mode, or -1 on Srealloc() error.
 */
GLOBAL WORD
setscreen(long log, long phys, WORD rez, WORD mode)
{
    int newmode;

#ifdef TEST
    void *ssp = Super(0L);
#endif

    if (rez == 3 && mode != -1)
    {
    /* For Rez 3, try reallocating Sparrow screen.
     * NOTE:
     *	ValidMode() is called here so that VgetSize() returns
     *	the actual screen size required by the validated mode.
     */
	mode = ValidMode(mode);
	if (log == 0L && phys == 0L
	&& !(log = phys = (long)Srealloc(VgetSize(mode))) )
	    return -1;
    }

    if (log > 0L) 
	*v_bas_ad = log;

    if (phys > 0L)
    {
	union { char c[4]; long l; } sptr;
	sptr.l = phys;
	*dbaseh = sptr.c[1];
	*dbasel = sptr.c[2];
	*dbasell = sptr.c[3];
    }

    switch (rez)
    {
	case -1: newmode = -1;
		break;
	case 0: newmode = (modecode & PAL) | (STMODE|COL40|BPP4);
		goto vmode;
	case 1: newmode = (modecode & PAL) | (STMODE|COL80|BPP2);
		goto vmode;
	case 2: newmode = (modecode & PAL) | (STMODE|COL80|BPP1);
vmode:		newmode = ValidMode(newmode);
		break;
	case 3:	newmode = mode;
		if ((newmode & STMODE) && BPP(newmode) < 3)
		/* -1 (mode inquire) won't end up here */
		    rez = 2 - BPP(newmode);
	break;
	default: return -1;
    }

    if (rez >= 0) *sshiftmd = rez;

    newmode = VsetMode(newmode);
    if (newmode == 88)
    {
    /* If !Sparrow, set hardware shiftmd and reinit VDI */
	char m = *sshiftmd & 0xf8 | rez;
	Vsync();
	*shiftmd = m;
	vb_off();
	esc_init();
	vb_on();
    }

#ifdef TEST
    Super(ssp);
#endif

    return newmode;
}


