/*
***************************      FS.H      ******************************
*
* $Revision: 2.18 $	$Source: e:/tos/gd2\rcs\fs.h,v $
* =======================================================================
* $Author: apratt $ 	$Date: 1991/03/28 17:39:36 $    $Locker:  $
* =======================================================================
*
* $Log: fs.h,v $
* Revision 2.18  1991/03/28  17:39:36  apratt
* THIS VERSION BOOTS! DESKTOP OPERATIONS WORK!
*
* Revision 2.17  1991/03/13  17:51:44  apratt
* Don't know.
*
* Revision 2.16  1991/03/12  18:25:26  apratt
* Making gtest.prg works and lets you test functions in this version
*
* Revision 2.15  1991/02/22  15:29:28  apratt
* generic checkin
*
* Revision 2.14  1991/02/21  03:07:32  apratt
* This version performs this testbed perfectly.
*
* Revision 2.13  1991/02/15  18:45:40  apratt
* CI at the end of the week...
*
* Revision 2.12  1991/02/12  18:20:10  apratt
* *** empty log message ***
*
* Revision 2.11  1991/02/11  19:56:48  apratt
* Checkin lest I lose work (again)
*
* Revision 2.10  91/01/23  17:06:48  apratt
* Use voidfn for "function returning void" in prototypes.  Changed d_left to
* d_child, d_right to d_next globally.  Removed o_thread, d_scan, m_fatofd,
* m_ofl, and d_dirfil.
* 
* Revision 2.9  91/01/23  14:29:50  apratt
* Trimmed logs & comments, changed to compile under GCC or (new) Alcyon.
* 
*************************************************************************
*/

/***********************************************************************\
*									*
*	NOTICE: all structures allocated from the OSPOOL must fit	*
*	in 64 bytes plus block-linking overhead, except for memory	*
*	descriptors, which need to be at most 16 bytes.  If they	*
*	aren't, the ospool code in pool.c will need work.		*
*									*
\***********************************************************************/

/* prototypes and GCC qualifiers */

/*
 * Macros to send debugger messages.  The "level" argument qualifies the
 * message; a one-bit match with the mask _dblev is required. The level
 * numbers are not ordered, they're just a way of selecting which messages
 * you want to see.
 *
 *	Level	    Usage
 *	$ 01	    top level calls
 *	  02	    getrec and flush - disk I/O
 *	  04	    xrw and clusters
 *	  08	    handles
 *	  10	    pool
 *	  20	    _dirnext calls
 *	  40	    process stuff
 *	  80	    memory stuff
 *	FFFFFFFF    really important, "non-maskable" stuff, like panic.
 */

#define DBMSG(level,s) { if (_dblev & (level)) trap14(11,5,0xf000,(s)); }
#define DBCMD(level,s) { if (_dblev & (level)) trap14(11,5,0xf100,(s)); }

#if __STDC__
#define _P(x) x
#define ASSERT(exp) ((exp) ? 0 : __assert (#exp, __FILE__, __LINE__))
#define __assert(exp,file,line) ( \
	sprintf(assertbuf,"Failed assert: \"" exp "\" file %s line %ld",\
		file,(long)line), \
	DBMSG(-1,assertbuf))
extern char assertbuf[];
extern void sprintf();
#define voidfn void
#else
#define _P(x) ()
#define ASSERT(exp) ((exp) ? 0 : DBMSG(-1,"Failed assert"))
#define void char
#define voidfn void
#define volatile
#define const
#endif

/*
 * VERSION NUMBERS
 * Pre-Mega ROMs are something - I don't know.
 *
 * Mega ROMs are 0x1300
 *
 * TOS 1.4 and TOS 1.6 are 0x1500
 *
 * The fixed OS POOL bug is 0x1700 - I don't know if that's in any STe's;
 * it's certainly not in any 192K ROMs.
 * 
 * 0x1800 is for TT TOS of around 5/90.
 * 0x1900 is for TT TOS from 7/19 on (hopefully final TT TOS).
 * 0x2000 is something I'm hacking up (1/91).
 */

/* GEMDOS version number (byte-reversed, nybble-packed, only in fshand.c) */
#define	VERS_NUM	0x2000L

/*
 * Feature-enabling switches
 */

#define TABOUT 1		/* worry about tabs in con.c */

/*
 *  Fundamental(?) constants
 */

#define	MAXDEVS	16		/* max number of block devices */
#define NUMPDS 32		/* max number of unterminated processes */
#define SUPSIZ	(1024+512)	/* common supervisor stack size (in words) */
#define OPNFILES	25	/* size of root process's uft */
#define NUMSTD		6	/* number of standard files */
#define NUMBIOS		3	/* number of BIOS dev handles -1, -2, -3 */
#define	KBBUFSIZ	64	/* size of typeahead buffer; (2^n)-1 */
#define SLASH		'\\'
#define COLON		':'

/* symbolic constants */

#define	NULL	0L
#define	OK	0
#define NULPTR	((void *) 0)
#define TRUE	1
#define FALSE	0

/*
 * Hacky Macros
 *
 */
#define uint unsigned int
#define ulong unsigned long
#define	REG		register
#define swp68(x)	s68(&(x))
#define swp68l(x)	s68l(&(x))
#define MGET(x)		((x*)getbig())
#define GETMD()		((MD *)getsmall())
#define MFREE(p)	freebig(p)
#define xmfreblk(p)	freebig(p)
#define bconstat(a)	trap13(1,(short)a)
#define bconin(a)	trap13(2,(short)a)
#define bconout(a,b)	trap13(3,(short)a,(short)b)
#define bconostat(a)	trap13(8,(short)a)
#define getbpb(a)	(BPB *)trap13(7,(short)a)
#define getmpb(a)	(void)trap13(0,(long)a)
#define mediach(a)	(int)trap13(9,(short)a)
#define setexc(e,h)	(void (*)())trap13(5,e,((long)(h)))
#define gettime()	(ulong)trap14(0x17)

#define min(a,b)	(((a)<(b))?(a):(b))

#define rwabs(a,b,c,d,e) if(rwerr=trap13(4,a,b,c,d,e)){errdrv=e;\
/* ------------------------------------------ */	longjmp(errbuf,rwerr);}

#define cl2rec(cl,dm) (!(cl) ? 0 : (((cl)-2) << (dm)->m_clrlog))
#define realcl2rec(cl,dm) (!(cl) ? (dm)->m_recrd : \
			    ((((cl)-2) << (dm)->m_clrlog) + (dm)->m_recoff[2]))

#define	Panic()		panic()

/*
 * Structure Names
 */
#define OFD	struct _ofd
#define DFD	struct _dfd
#define DIR	struct _dir
#define FCB	struct _fcb
#define BPB	struct _bpb
#define BCB	struct _bcb
#define DMD	struct _dmd
#define MD	struct _md
#define MPB	struct _mpb
#define PD	struct _pd
#define DTA	struct _xdta
#define PRG	struct _prg

/*
 * DTA, used for sfirst/snext
 */

DTA
{
    /* the private part: 21 bytes */
    char dta_sname[11];	/* name-part of FCB to use in search */
    char dta_attr;	/* attrib to use in search */
    uint dta_clust;	/* strtcl of dir slot was found in */
    uint dta_curcl;
    uint dta_recno;
    uint dta_recoffs;
    char dta_dev;

    /* the public part */
    char fattrib;	/* attribute of found file */
    uint ftime, fdate;	/* time & date of found file */
    ulong flength;	/* length of found file */
    char fname[14];	/* name of found file as "base.ext\0" */
};

/*
 * Basepage, "process descriptor"
 */
PD
{
/* 0x00 */
	PD	*p_lowtpa;	/* -> base of TPA */
	void	*p_hitpa;	/* -> end (+1) of TPA */
	ulong	p_tbase;	/* -> text base */
	ulong	p_tlen;		/* size of text segment */
/* 0x10 */
	ulong	p_dbase;	/* -> data base */
	ulong	p_dlen;		/* size of data segment */
	ulong	p_bbase;	/* -> BSS base */
	ulong	p_blen;		/* size of BSS segment */
/* 0x20 */
	DTA	*p_xdta;	/* current DTA (Disk Transfer Address) */
	PD	*p_parent;	/* parent PD */
	ulong	p_hflags;	/* process flags (see P_ below) */
	char	*p_env;		/* at offset 2ch (eat your heart out, Lee) */
/* 0x30 */
	ulong	p_1fill[2];	/* (junk) */
	uint	p_curdrv;	/* current drive */
	uint	p_uftsize;	/* number of OFD pointers at p_uft */
	OFD	**p_uft;	/* ptr to my uft (allocated after env.) */
/* 0x40 */
	uint	p_curdir[MAXDEVS];	/* startcl of cur dir on each drive */
/* 0x60 */
	ulong	p_3fill[2];	/* (junk) */
	ulong	p_dreg[1];	/* dreg[0] */
	ulong	p_areg[5];	/* areg[3..7] */
/* 0x80 */
	char	p_cmdlin[0x80];	/* commandline image */
};

/* macros for handling the OFD field a uft entry */

#define ofdisatty(ofd) (((ulong)(ofd)) & 1)
#define ofddevno(ofd) (((uint)ofd) >> 1)
#define ofdtty(devno) ((OFD *)((devno << 1) | 1))

/*
 * PRG, the header of an executable file
 */
PRG
{
	uint g_magic;
	ulong g_tsize, g_dsize, g_bsize, g_ssize;
	ulong g_junk1;
	ulong g_hflags;
	uint g_absflg;
};

#define P_MAGIC		0x601a

/* bits in g_hflags and p_hflags */

#define P_NOCLRBSS	1
#define P_RAMEXEC	2
#define P_RAMALLOC	4

/*
 * Memory Descriptor
 *
 * AKP 3/3/88: if m_own == 1, the block is on the little-block free list.
 */
MD
{
	MD	*m_link;	/* -> next MD on list */
	void	*m_start;	/* starting address */
	ulong	m_length;	/* number of bytes there */
	PD	*m_own;		/* -> owner's basepage */
};


/*
 * Memory Partition Block
 */
MPB
{
	MD	*mp_mfl;	/* -> first MD on memory free list */
	MD	*mp_mal;	/* -> first MD on memory allocated list */
	MD	*mp_rover;	/* roving allocation pointer (NOT USED) */
};


/*
 * Open File Descriptor
 */

OFD
{
	/* file position and per-open information */

	OFD	*o_next;	/* next in unordered list of OFDs */
	OFD	*o_prev;	/* prev in unordered list of OFDs */
	DFD	*o_dfd;		/* DFD this OFD refers to */
	uint	o_use;		/* use count */
        uint    o_mode;		/* mode file opened in (r, w, r/w) */
	ulong	o_bytnum;	/* byte pointer within file */
	uint	o_curcl;	/* current cluster pointer */
	uint	o_currec;	/* rec number of current cluster */
};


/*
 * Disk File Descriptor
 */

DFD
{
	DFD	*dfd_next;	/* next in unordered list of DFDs */
	DFD	*dfd_prev;	/* prev in unordered list of DFDs */
	uint	dfd_use;

	/* these items are in the same order as the FCB.  In memory, */
	/* time, date, and strtcl are in 8088 format, but length isn't */
	uint	dfd_time, dfd_date, dfd_strtcl;
	ulong	dfd_fileln;

	char	dfd_attrib;	/* attributes, here for setting FA_ARCHIVE */
	char	dfd_dirty;	/* flag: set when dirty */
	uint	dfd_dev;	/* device this file's on */
	uint	dfd_dircl;	/* strtcl of dir this file's in */
	uint	dfd_dirrec;	/* record of slot this file's in */
	uint	dfd_diroffs;	/* offset in dirrec of this file's slot */
};

/*
 * DIR, a description of a slot in a directory.
 *
 * When "fresh" the BCB and FCB fields point to a buffer and a byte
 * in that buffer, respectively.
 */

DIR
{
	uint	dir_dev;	/* the dev the slot is in */
	uint	dir_clust;	/* strtcl of dir the slot is in */
	uint	dir_curcl;	/* cluster the slot is in */
	uint	dir_recno;	/* record the slot is in */
	uint	dir_recoffs;	/* offset into record of the slot */
	BCB	*dir_bcb;	/* BCB of buffer, only if fresh */
	FCB	*dir_fcb;	/* points into buffer, only if fresh */
};

/* flags to fn2dir */
#define FN_NORM 0
#define FN_DOTSOK 1
#define FN_EARLY 2
#define FN_EMPTYOK 3

/*
 * File Control Block
 * as it appears on the disk.
 */
#define FA_RO		0x01		/* file may not be deleted/changed */
#define FA_HIDDEN	0x02		/* these two may be reversed */
#define FA_SYSTEM	0x04
#define FA_LABEL	0x08		/* volume label */
#define FA_SUBDIR	0x10		/* file is a subdirectory */
#define FA_ARCHIVE	0x20		/* archive bit */

#define FA_ALL		0xF7		/* all but label bit */
#define FA_NORM		0xE7		/* all but label & subdir */

#define ERASED		((char)0xe5)

FCB
{
	char	f_name[11];
	char	f_attrib;
	char	f_fill[10];
	uint	f_time;
	uint	f_date;
	uint	f_clust;
	ulong	f_fileln;
};


/*
 * BIOS Parameter Block
 * Describes a volume's organization.
 */
BPB
{
	uint	recsiz;		/* record size in bytes */
	uint	clsiz;		/* #records/cluster */
	uint 	clsizb;		/* #bytes/cluster (recsiz * clsiz) */
	uint	rdlen;		/* root directory length in records */
	uint	fsiz;		/* fat size in records */
	uint	fatrec;		/* first fat record (of last fat) */
	uint	datrec;		/* first data record */
	uint	numcl;		/* number of data clusters available */
	uint	b_flags;	/* bit 0 = 0 for 12-bit fat, 1 for 16-bit */
};


/*
 * Drive Media Descriptor
 * Derived from the BPB.
 * Pity the BPB doesn't include "number of FATs."
 */
DMD
{
	uint	m_recoff[3];	/* record offsets for fat,dir,data */

/* "field names" for elements in m_recoff */
#define m_recfat m_recoff[0]
#define m_recrd m_recoff[1]
#define m_recdata m_recoff[2]

	uint	m_drvnum;	/* drive number */
	uint	m_fsiz;		/* fat size (records?) */
	uint	m_clsiz;	/* cluster size in records */
	uint	m_clsizb;	/* cluster size in bytes */
	uint	m_recsiz;	/* record size in bytes */
	uint	m_numcl;	/* #clusters on media */
	uint	m_clrlog;	/* log2 of clsiz */
	uint	m_clrm;		/* mask: (2^clrlog)-1 */
	uint	m_rblog;	/* log2 of recsiz */
	uint	m_rbm; 		/* mask: (2^rblog)-1 */
	uint	m_clblog;	/* log2 of clsizb */
	uint	m_16;		/* 16 bit fat flag */
};


/*
 * Buffer Control Block
 * Used for buffer cache.
 * This is a published structure.  Well, really the size of the struct
 * and its link field are defined, and the fact that bufdrv == -1 means
 * invalid.
 */
BCB
{
	BCB	*b_link;	/* -> next BCB */
	uint	b_bufdrv;	/* drive (or -1 if block is invalid) */
	uint	b_buftyp;	/* buffer type */
	uint	b_bufrec;	/* record# this block caches */
	uint	b_dirty;	/* 1: dirty (must be written) */
	DMD	*b_dmd;		/* -> DMD for this block's drive */
	char	*b_bufr;	/* -> 512-byte buffer */
};

#define B_INVALID -1	/* invalid flag; goes in b_bufdrv */

struct block {
    struct block *b_next;	/* next block in the heap */
    char b_type;		/* see Bis* predicates below */
    char b_unused;		/* unused */
    union {
	char b_big[64];		/* either one big block, or... */
	MD b_mem[4];		/* four small blocks */
				/* if m_own is 1, little block is free */
    } b_data;
};

#define LSIZE sizeof(struct block)
#define HEADSIZE 6		/* size of header before data */

/* btype predicates */

#define Bisfree(bp) ((bp)->b_type == 0)		/* big and free */
#define Bisused(bp) ((bp)->b_type < 0)		/* big but used */
#define Biscut(bp)  ((bp)->b_type > 0)		/* cut up (have to check */
						/* free-ness individually) */
#define Bmakefree(bp) ((bp)->b_type = 0)
#define Bmakeused(bp) ((bp)->b_type = -1)
#define Bmakecut(bp)  ((bp)->b_type = 1)

typedef long jmp_buf[3];

#include "proto.h"
#include "gemerror.h"
#include "fsdecl.h"

/*
 * prototypes for functions which aren't in C
 */

long trap1 _P(( int,... ));
long trap13 _P(( int,... ));
long trap14 _P(( int,... ));

voidfn s68 _P(( void *word_to_swap ));
voidfn s68l _P(( void *long_to_swap ));
int uc _P(( int ));
voidfn clear _P(( void *start, void *last_plus_1 ));
voidfn usr2xfr _P(( int n, void *d, void *s ));
voidfn xfr2usr _P(( int n, void *s, void *d ));
voidfn upd_tod _P(( void ));

long setjmp _P(( jmp_buf buf ));
long longjmp _P(( jmp_buf buf, long code ));

volatile void gouser _P(( void ));
voidfn dojmp _P(( long addr ));
voidfn clksync _P(( void ));

/*
 * Macros and inlines
 */

/* move 'count' bytes from 's' to 'd' - count must be >0; coded for dbra */
#define xmovs(xcount,xs,xd) ((void)({ \
	int count = xcount; char *s = (char *)xs; char *d = (char *)xd; \
	--count; do { *d++ = *s++; } while (--count != -1); }))

/*
 * dirfirst macro: initialize dir to the first slot in the dir from the dev/cl 
 */

#define dirfirst(dir,dmd) \
    (((dir)->dir_curcl = (dir)->dir_clust), \
     ((dir)->dir_recno = realcl2rec((dir)->dir_clust,(dmd))), \
     ((dir)->dir_recoffs = 0), \
     dir2dir(dir))

/* dirnext macro; see scan.c */

#define dirnext(dir,dmd) \
    (((dir)->dir_fcb++), \
     ((dir)->dir_recoffs += sizeof(FCB)), \
     (((dir)->dir_recoffs < (dmd)->m_recsiz) ? E_OK : _dirnext((dir),(dmd))))

