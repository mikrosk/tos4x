/*
***************************      FS.H      ******************************
*
* $Revision: 2.9 $	$Source: fs.h,v $
* =======================================================================
* $Author: apratt $ 	$Date: 91/01/23 14:29:50 $    $Locker:  $
* =======================================================================
*
* $Log: fs.h,v $
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

#if __ANSI__
#define _P(x) x
#else
#define _P(x) ()
#define void char
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
 */

/* GEMDOS version number (byte-reversed, nybble-packed, used only in sup.c) */
#define	VERS_NUM	0x1900L

/*
 *  Fundamental constants --- do not change too much
 */
#define	NULL	0L
#define	OK	0
#define NULPTR	((void *) 0)
#define TRUE	1
#define FALSE	0
#define	MAXDEVS	16		/* max number of block devices */
#define SLASH	'\\'		/* path character */

#define SUPSIZ	(1024+512)	/* common supervisor stack size (in words) */
#define OPNFILES	75	/* max open files in system */
#define NCURDIR		40	/* max current directories in use in system */
#define NUMSTD		6	/* number of standard files */
#define	KBBUFSZ		80	/* size of typeahead buffer */


/*
 * Hacky Macros
 *
 */
#define	REG		register
#define swp68(x)	s68(&(x))
#define swp68l(x)	s68l(&(x))
#define MGET(x)		((x*)getbig())
#define GETMD()		((MD *)getsmall())
#define xmfreblk(p)	freebig(p)
#define dirscan(a,c)	((DND *) scan(a,c,0x10,&negone))
#define bconstat(a)	trap13(1,a)
#define bconin(a)	trap13(2,a)
#define bconout(a,b)	trap13(3,a,b)
#define bconostat(a)	trap13(8,a)
#define getbpb(a)	trap13(7,a)
#define getmpb(a)	trap13(0,a)
#define min(a,b)	(((a)<(b))?(a):(b))
#define rwabs(a,b,c,d,e) if(rwerr=trap13(4,a,b,c,d,e)){errdrv=e;\
/* ------------------------------------------ */	longjmp(errbuf,rwerr);}

#define cl2rec(cl,dm) (cl * dm->m_clsiz)

#define	Panic()		panic()

/*
 * divmod: "returns" quotient, sets remainder, for byte -> sect/offs
 * usage:
 *   sector = divmod(&offset,bytenum,dm->m_rblog);
 *
 * bytenum is LONG, and is the byte offset from the start of the section
 * (from start of FAT, Root dir, etc.).
 */

#define divmod(p_rem,divdnd,divsor) \
	(*(p_rem) = ((divdnd)&logmsk[(divsor)]), (divdnd) >> (divsor))

extern long trap13();

/*
 * Structure Names
 */
#define OFD	struct _ofd
#define FCB	struct _fcb
#define BPB	struct _bpb
#define DND	struct _dnd
#define BCB	struct _bcb
#define DMD	struct _dmd
#define MD	struct _md
#define MPB	struct _mpb
#define PD	struct _pd
#define FTAB	struct _ftab
#define DTA	struct _dta
#define PRG	struct _prg

/*
 * DTA, used for sfirst/snext (AKP 1/88)
 */

DTA
{
    /* the private part: 21 bytes */
    char dta_sname[12];	/* filename string being searched for */

    /* low nybble of this long is the device number */
    /* if rest of long is nonzero, this is a root directory search */
    /* on that device; otherwise the search uses dta_pos and dta_clust */
    long dta_rdpos;
    int dta_pos;
    int dta_clust;
    char dta_attr;	/* attribute byte of search */

    /* the public part */
    char fattrib;	/* attribute of found file */
    int ftime, fdate;	/* time & date of found file */
    long flength;	/* length of found file */
    char fname[14];	/* name of found file as "base.ext\0" */
};

/*
 * Basepage, "process descriptor"
 *
 */
PD
{
/* 0x00 */
	PD	*p_lowtpa;	/* -> base of TPA */
	void	*p_hitpa;	/* -> end (+1) of TPA */
	long	p_tbase;	/* -> text base */
	long	p_tlen;		/* size of text segment */
/* 0x10 */
	long	p_dbase;	/* -> data base */
	long	p_dlen;		/* size of data segment */
	long	p_bbase;	/* -> BSS base */
	long	p_blen;		/* size of BSS segment */
/* 0x20 */
	DTA	*p_xdta;	/* current DTA (Disk Transfer Address) */
	PD	*p_parent;	/* parent PD */
	long	p_hflags;	/* process flags (see P_ below) */
	char	*p_env;		/* at offset 2ch (eat your heart out, Lee) */
/* 0x30 */
	char	p_uft[NUMSTD];	/* index into sys file table for std files */
	char	p_minfast;	/* minimum allowable fast RAM (x64K) */
	char	p_curdrv;	/* current drive */
	long	p_1fill[2];	/* (junk) */
/* 0x40 */
	char	p_curdir[16];	/* index into sys dir table */
/* 0x50 */
	long	p_2fill[4];	/* (junk) */
/* 0x60 */
	long	p_3fill[2];	/* (junk) */
	long	p_dreg[1];	/* dreg[0] */
	long	p_areg[5];	/* areg[3..7] */
/* 0x80 */
	char	p_cmdlin[0x80];	/* commandline image */
};


/*
 * PRG, the header of an executable file
 */
PRG
{
	int g_magic;
	long g_tsize, g_dsize, g_bsize, g_ssize;
	long g_junk1;
	long g_hflags;
	int g_absflg;
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
	long	m_length;	/* number of bytes there */
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

#define O_DIRTY 1		/* OFD is dirty */
#define O_COMPLETE 2		/* directory traversal is complete */
OFD
{
	OFD	*o_link;
	int	o_flag;

	int	o_time;    /* the next 4 item must be in same order as FCB */
	int	o_date;
	int	o_strtcl;
	long	o_fileln;

	DMD	*o_dmd;
	DND	*o_dnode;  /* DND of this file's parent */
	OFD	*o_dirfil; /* OFD of parent */
	long	o_dirbyt;  /* pos in dir of this files fcb (dcnt) */

	long	o_bytnum;  /* byte pointer within file */
	int	o_curcl;   /* current cluster pointer */
	int	o_currec;  /* rec number of current cluster */
	int	o_curbyt;  /* byte offset in current cluster */
	int	o_usecnt;  /* use count for inherited files */
	OFD	*o_thread; /* mulitple open thread list */
        int     o_mod;     /* mode file opened in (r, w, r/w) */
};


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
#define FA_NORM		0x27		/* normal search: will match attr 0 */
					/* or as little as a one-bit match. */
FCB
{
	char	f_name[11];
	char	f_attrib;
	char	f_fill[10];
	int	f_time;
	int	f_date;
	int	f_clust;
	long	f_fileln;
};


/*
 * Directory Node Descriptor.
 * These are linked together into a tree
 * that describes the volume's heirarchy.
 */
DND
{
	char	d_name[11];	/* directory name */
	char	d_fill;		/* unused */
	int	d_flag;		/* 0x0c flags */
	int	d_strtcl;	/* 0x0e starting cluster number */
	int	d_time;		/* 0x10 creation time */
	int	d_date;		/* 0x12 creation date */
	OFD	*d_ofd;		/* 0x14 -> OFD of this directory file */
	DND	*d_parent;	/* 0x18 -> parent DND */
	DND	*d_left;	/* 0x1c -> child DND (down the tree) */
	DND	*d_right;	/* 0x20 -> next DND (across the tree) */
	DMD	*d_drv;		/* 0x24 -> drive's DMD */
	OFD	*d_dirfil;	/* 0x28 -> OFD of parent directory file */
	long	d_dirpos;	/* 0x2c offset in parent of this dir */
	long	d_scan;		/* 0x30 current position in dir for DND tree */
	OFD	*d_files;	/* 0x34 -> first open file on this node */
};


/*
 * BIOS Parameter Block
 * Describes a volume's organization.
 */
BPB
{
	int	recsiz;		/* record size in bytes */
	int	clsiz;		/* #records/cluster */
	int 	clsizb;		/* #bytes/cluster (recsiz * clsiz) */
	int	rdlen;		/* root directory length in records */
	int	fsiz;		/* fat size in records */
	int	fatrec;		/* first fat record (of last fat) */
	int	datrec;		/* first data record */
	int	numcl;		/* number of data clusters available */
	int	b_flags;	/* bit 0 = 0 for 12-bit fat, 1 for 16-bit */
};


/*
 * Drive Media Block
 * Derived from the BPB, also contains the
 * root of the volume's directory tree.
 */
DMD
{
	int	m_recoff[3];	/* record offsets for fat,dir,data */
	int	m_drvnum;	/* 0x06 drive number */
	int	m_fatrec;	/* 0x08 record # of start of 2nd FAT (AKP) */
	int	m_fsiz;		/* 0x0a fat size (records?) */
	int	m_clsiz;	/* 0x0c cluster size in records */
	int	m_clsizb;	/* 0x0e cluster size in bytes */
	int	m_recsiz;	/* 0x10 record size in bytes */

	int	m_numcl;	/* 0x12 #clusters on media */
	int	m_clrlog;	/* 0x14 clsiz in rec, log2 is shift */
	int	m_clrm;		/* 0x16 clsiz in rec, mask */
	int	m_rblog;	/* 0x18 recsiz in bytes, shift */
	int	m_rbm; 		/* 0x1a recsiz in bytes, mask */
	int	m_clblog;	/* 0x1c */
	OFD	*m_fatofd;	/* 0x1e -> "fake" OFD for FATs */

	OFD	*m_ofl;		/* 0x22 */
	DND	*m_dtl;		/* 0x26 -> root DND */
	int	m_16;		/* 0x2a 16 bit fat flag */
};


/*
 * Buffer Control Block
 * Used for buffer cache.
 */
BCB
{
	BCB	*b_link;	/* -> next BCB */
	int	b_bufdrv;	/* drive (or -1 if block is invalid) */
	int	b_buftyp;	/* buffer type */
	int	b_bufrec;	/* record# this block caches */
	int	b_dirty;	/* 1: dirty (must be written) */
	DMD	*b_dm;		/* -> DMD for this block's drive */
	char	*b_bufr;	/* -> 512-byte buffer */
};


/*
 * File Table entry
 * Pointed at OFDs when necessary.
 */
FTAB
{
	OFD	*f_ofd;		/* -> the OFD */
	PD	*f_own;		/* file's owner */
	int	f_use;		/* use count */
};

#define CL_DIR 0x0002	/* this is a directory file, flush, do not free */
#define CL_FULL 0x0004  /* even though its a directory, full close */

struct block {
    struct block *b_next;	/* next block in the heap */
    char b_type;		/* see Bis* predicates below */
    char b_callno;		/* used only if the block is big */
    union {
	char b_big[64];		/* either one big block, or... */
	MD b_mem[4];	/* four small blocks */
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

#include "proto.h"
#include "gemerror.h"
#include "fsdecl.h"

/*
 * prototypes for functions which aren't in C
 */

int setjmp _P(( long *jmpbuf ));	/* takes three longs */
void longjmp _P(( long *jmpbuf,int error ));
long trap13 _P(( int,... ));
void s68 _P(( void *word_to_swap ));
void s68l _P(( void *long_to_swap ));
void clear _P(( void *start, void *last_plus_1 ));
void usr2xfr _P(( int n, void *d, void *s ));
void xfr2usr _P(( int n, void *s, void *d ));

volatile void gouser _P(( void ));
void dojmp _P(( long addr ));
void clksync _P(( void ));
void osinit _P(( void ));
long oscall _P(( int,... ));
void upd_tod _P(( void ));
