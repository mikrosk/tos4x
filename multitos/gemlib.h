/*	GEMLIB.H		9/22/92				D.Mui	*/

/*	-----------------------------------------------------------
*	AES Version 4.0	MultiTOS version is written by Derek M. Mui
*	Copyright (C) 1992 
*	Atari (U.S.) Corp
*	All Rights Reserved
*	-----------------------------------------------------------
*/	
						
#define SAVE_ATARI 128		/* Atari specific bytes in DESKTOP.INF file	*/
#define SIZE_AFILE 4192		/* size of DESKTOP.INF file	*/

#define	MAXERR	8		/* maximum critical error object	*/

#define MU_KEYBD 	0x0001	/* mu_flags		*/
#define MU_BUTTON 	0x0002
#define MU_M1 		0x0004
#define MU_M2 		0x0008
#define MU_MESAG 	0x0010
#define MU_TIMER 	0x0020
#define MU_XBUTTON	0x0040

#define AI_NTEXT	0
#define AI_STEXT	1
#define AI_E1		2
#define AI_LANG		3

#define	SHADOW	2		/* thickness of drop shadow in pixels */

#define M_ARROW		0
#define M_CURSOR	1
#define M_BEE		2
#define M_FINGER	3
#define M_FLATHAND	4
#define	M_CROSSHAIR	5	
#define M_TCROSSHAIR	6	/* thick cross hair	*/
#define M_OCROSSHAIR	7	/* outline cross hair	*/
#define M_USERDEFINE	255
#define M_OFF		256
#define M_ON		257
#define	M_SAVEFORM	258
#define	M_RESTORE	259
#define	M_PREVIOUS	260


/*	MENULIB.H	05/04/84 - 11/01/84	Lowell Webster	*/

#define MTH 		1			/* menu thickness	*/
#define THESCREEN 	0
#define THEBAR 		1
#define THEACTIVE 	2
#define THEMENUS ( LWGET(OB_TAIL(THESCREEN)) )

/*** STATE DEFINITIONS FOR menu_state ***********************************/

#define INBAR	1	/* mouse position	outside menu bar & mo dn */
			/* multi wait		mo up | in menu bar	*/
			/* moves		-> 5  ,  ->2		*/

#define OUTTITLE 2  	/* mouse position	over title && mo dn	*/
			/* multiwait		mo up | out title rect	*/
			/* moves		-> 5  ,	->1 ->2  ->3	*/

#define OUTITEM 3 	/* mouse position	over item && mo dn	*/
			/* multi wait		mo up | out item rect	*/
			/* moves		-> 5  , ->1 ->2 ->3 ->4	*/

#define INBARECT 4	/* mouse position	out menu rect && bar && mo dn*/
			/* multi wait	mo up | in menu rect | in menu bar */
			/* moves	-> 5  ,	-> 3	     , -> 2	*/


#define FMD_START 	0	/* Form Library Functions	*/
#define FMD_GROW 	1
#define FMD_SHRINK 	2
#define FMD_FINISH 	3

typedef struct rssofln
{
	WORD	rss_offset;
	WORD	rss_length;
}RSSOFLN;

typedef struct imofln			/* image block structure	*/
{
	WORD	rim_offset;
	WORD	rim_length;
}IMOFLN;

typedef struct rstree
{
	WORD	rst_first;
	WORD	rst_count;
}RSTREE;

/*	Window Library definitions	*/

/* Bit masks of pieces of a window */

#define TOP	0x0001
#define LEFT	0x0002
#define RIGHT	0x0004
#define BOTTOM	0x0008

#define	MAXOBJ	20		/* maximum number of objects in a window */
#define	NUMRECT	80		/* # RLISTs per block of memory allocated */
#define	NUMWIN	8		/* # window structures per block of memory */
#define	HASHSIZ	8		/* size of hash table */


/* Memory descriptor structure */
typedef	struct	memhdr {
    int	    numused;		/* number of window structures used */
    struct  memhdr *mnext;	/* pointer to next memory descriptor */
} MEMHDR;


/* Rectangle list structure */
typedef	struct	rlist {
    struct {
	unsigned rused : 1;	/* bit 0 ->1: slot is currently used */
    } rstatus;
    GRECT   rect;		/* the rectangle dimensions */
    MEMHDR  *rwhere;		/* ptr to memory this RLIST resides in */
    struct  rlist *rnext;	/* ptr to next RLIST */
} RLIST;




/* Window structure */
typedef	struct	window {
    struct {
	unsigned used : 1;	/* bit 0 -> 1: slot is currently used */
	unsigned opened : 1;	/* bit 1 -> 1: window is currently opened */
    } status;			/* window status */
    PD	    *owner;		/* owner of this window */
    PD	    *cowner;		/* cowner of this window, it will change */
				/* from time to time for use in phantom window */
    UWORD   handle;		/* window handle */
    UWORD   kind;		/* flag for components of window */
    OBJECT  *aesobj;		/* for use in AES */
    OBJECT  obj[MAXOBJ];	/* definition of each object */
    WORD    tcolor[MAXOBJ];	/* object colors if window is topped */
    WORD    bcolor[MAXOBJ];	/* object colors if window is in background */
    TEDINFO ttxt;		/* title bar text */
    TEDINFO itxt;		/* info line text */
    TEDINFO mtxt;		/* menu bar text */
    BYTE    tbuf[128];
    BYTE    ibuf[128];
    GRECT   full;		/* coords and size when full */
    GRECT   prev;		/* previous coords and size */
    GRECT   curr;		/* current coords and size */
    RLIST   *fxywh;		/* first rect in rectangle list */
    RLIST   *nxywh;		/* next rect in rectangle list */
				/* slider positions and sizes are in 1-1000
				   range and relative to the scroll bar */
    UWORD   hslpos;		/* horizontal slider position */
    UWORD   vslpos;		/* vertical slider position */
    UWORD   hslsz;		/* horizontal slider size */
    UWORD   vslsz;		/* vertical slider size */
    UWORD   ontop;		/* handle # of window on top */
    UWORD   under;		/* handle # of window under */
    UWORD   nxthndl;		/* next handle # in used */
    UWORD   parent;		/* handle # of parent window */
    UWORD   child;		/* handle # of 1st child window */
    UWORD   sibling;		/* handle # of next sibling window */
    UWORD   type;		/* window's characteristics 	*/
    MEMHDR  *wwhere;		/* ptr to memory this WINDOW resides in */
    struct  window *wnext;	/* ptr to next WINDOW in database */
    BYTE    *drawaddr;
    WORD    w_msg[MSG_SIZE];
} WINDOW;


#define THEGLO struct glstr
THEGLO
{
	FPD	g_fpdx[NFORKS];
	BYTE	g_rawstr[MAX_LEN];	/* used in gemoblib.s	*/
	BYTE	g_tmpstr[MAX_LEN];	/* used in gemoblib.s	*/
	BYTE	g_valstr[MAX_LEN];	/* used in gembind.s	*/
	BYTE	g_fmtstr[MAX_LEN];	/* used in gemoblib.s	*/
	BYTE	g_loc1[256];		/* MAX alert length	*/
	BYTE	g_loc2[256];
	WORD	g_scrap[82];
	BYTE	g_dir[CMDLEN];		/* changed from 82 to 128 */
	UWORD	g_sysglo[G_SIZE];
	BYTE	g_path[CMDLEN];		/* new element		*/
	BYTE	g_dta[60];
	BYTE	s_cmd[CMDLEN];
	BYTE	*s_save;		/* SIZE_AFILE		*/
	UWORD	s_size;
	BYTE	s_tail[CMDLEN];
};
