/*
***************************      FS.H      ******************************
*
* $Revision: 2.11 $	$Source: e:/tos/gd2\RCS\fs.h,v $
* =======================================================================
* $Author: apratt $ 	$Date: 1991/02/11 19:56:48 $    $Locker:  $
* =======================================================================
*
* $Log: fs.h,v $
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

#define DBMSG(s) trap14(11,5,0xf000,(s))

#if __STDC__
#define _P(x) x
#define ASSERT(exp) ((exp) ? 0 : __assert (#exp, __FILE__, __LINE__))
#define __assert(exp,file,line) \
	DBMSG("Failed assert \"" exp "\" file " #file " line " #line)
#define voidfn void
#else
#define _P(x) ()
#define ASSERT(exp) ((exp) ? 0 : DBMSG("Failed assert"))
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

/* GEMDOS version number (byte-reversed, nybble-packed, used only in sup.c) */
#define	VERS_NUM	0x2000L

#define	NULL	0L
#define	OK	0
#define NULPTR	((void *) 0)
#define TRUE	1
#define FALSE	0
#define	MAXDEVS	16		/* max number of block devices */
#define SLASH	'\\'		/* path character */

/*
 *  Fundamental(?) constants
 */

#define SUPSIZ	(1024+512)	/* common supervisor stack size (in words) */
#define OPNFILES	75	/* max open files in system */
#define NCURDIR		40	/* max current directories in use in system */
#define NUMSTD		6	/* number of standard files */
#define NUMBIOS		3	/* number of BIOS dev handles -1, -2, -3 */
#define	KBBUFSZ		80	/* size of typeahead buffer */
#define SLASH		'\\'
#define COLON		':'

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
#define xmfreblk(p)	freebig(p)
#define bconstat(a)	trap13(1,a)
#define bconin(a)	trap13(2,a)
#define bconout(a,b)	trap13(3,a,b)
#define bconostat(a)	trap13(8,a)
#define getbpb(a)	trap13(7,a)
#define getmpb(a)	trap13(0,a)
#define mediach(a)	trap13(9,a)
#define min(a,b)	(((a)<(b))?(a):(b))

#define rwabs(a,b,c,d,e) if(rwerr=trap13(4,a,b,c,d,e)){errdrv=e;\
/* ------------------------------------------ */	longjmp(errbuf,rwerr);}

#define cl2rec(cl,dm) (!(cl) ? 0 : (((cl) * (dm)->m_clsiz) + (dm)->m_recoff[2]))

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
#define FTAB	struct _ftab
#define DTA	struct _dta
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
	uint	p_curdir[MAXDEVS];	/* startcl of cur dir on each drive */
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

OFD
{
	/* file position and per-open information */

	OFD	*o_next;	/* next in unordered list of OFDs */
	int	o_use;		/* use count */
        int     o_mode;		/* mode file opened in (r, w, r/w) */
	DFD	*o_dfd;		/* DFD this OFD refers to */
	long	o_bytnum;	/* byte pointer within file */
	uint	o_curcl;	/* current cluster pointer */
	uint	o_currec;	/* rec number of current cluster */
	uint	o_curbyt;	/* byte offset in current cluster */
};

/*
 * Disk File Descriptor
 */

DFD
{
	DFD	*dfd_next;	/* next in unordered list of DFDs */
	int	dfd_use;

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
 * dirfirst macro: initialize dir to the first slot in the dir from the dev/cl 
 */

#define dirfirst(dir,dmd) \
    (((dir)->dir_curcl = (dir)->dir_clust), \
     ((dir)->dir_recno = cl2rec((dir)->dir_clust,(dmd))), \
     ((dir)->dir_recoffs = 0), \
     dir2dir(dir))

/* dirnext macro; see scan.c */

#define dirnext(dir,dmd) \
    (((dir)->dir_fcb++), \
     ((dir)->dir_recoffs += sizeof(FCB)), \
     (((dir)->dir_recoffs < (dmd)->m_recsiz) ? E_OK : _dirnext((dir),(dmd))))

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
	int	f_time;
	int	f_date;
	int	f_clust;
	long	f_fileln;
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
 * Drive Media Descriptor
 * Derived from the BPB.
 * Pity the BPB doesn't include "number of FATs."
 */
DMD
{
	int	m_recoff[3];	/* record offsets for fat,dir,data */

/* "field names" for elements in m_recoff */
#define m_recfat m_recoff[0]
#define m_recrd m_recoff[1]
#define m_recdata m_recoff[2]

	int	m_drvnum;	/* drive number */
	int	m_fsiz;		/* fat size (records?) */
	int	m_clsiz;	/* cluster size in records */
	int	m_clsizb;	/* cluster size in bytes */
	int	m_recsiz;	/* record size in bytes */
	int	m_numcl;	/* #clusters on media */
	int	m_clrlog;	/* log2 of clsiz */
	int	m_clrm;		/* mask: (2^clrlog)-1 */
	int	m_rblog;	/* log2 of recsiz */
	int	m_rbm; 		/* mask: (2^rblog)-1 */
	int	m_clblog;	/* log2 of clsizb */
	int	m_16;		/* 16 bit fat flag */
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
	int	b_bufdrv;	/* drive (or -1 if block is invalid) */
	int	b_buftyp;	/* buffer type */
	int	b_bufrec;	/* record# this block caches */
	int	b_dirty;	/* 1: dirty (must be written) */
	DMD	*b_dmd;		/* -> DMD for this block's drive */
	char	*b_bufr;	/* -> 512-byte buffer */
};

#define B_INVALID -1	/* invalid flag; goes in b_bufdrv */

/*
 * File Table entry
 * Pointed at OFDs when necessary.
 */
FTAB
{
	PD	*f_own;		/* file's owner */
	OFD	*f_ofd;		/* -> the OFD */
};

/* macros for handling the OFD field of an sft entry */

#define ofdisatty(ofd) (((long)(ofd)) & 1)
#define ofddevno(ofd) ((short)((((unsigned long)(ofd)) >> 1)))
#define ofdmaketty(ofd,devno) ((ofd) = (OFD *)(((devno) << 1) | 1))


struct block {
    struct block *b_next;	/* next block in the heap */
    char b_type;		/* see Bis* predicates below */
    char b_callno;		/* used only if the block is big */
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

#include "proto.h"
#include "gemerror.h"
#include "fsdecl.h"

/*
 * prototypes for functions which aren't in C
 */

long trap13 _P(( int,... ));
long trap14 _P(( int,... ));

int uc _P(( int ));
int setjmp _P(( long *jmpbuf ));	/* takes three longs */
voidfn longjmp _P(( long *jmpbuf,int error ));
long trap13 _P(( int,... ));
voidfn s68 _P(( void *word_to_swap ));
voidfn s68l _P(( void *long_to_swap ));
voidfn clear _P(( void *start, void *last_plus_1 ));
voidfn usr2xfr _P(( int n, void *d, void *s ));
voidfn xfr2usr _P(( int n, void *s, void *d ));

volatile void gouser _P(( void ));
voidfn dojmp _P(( long addr ));
voidfn clksync _P(( void ));
voidfn osinit _P(( void ));
long oscall _P(( int,... ));
voidfn upd_tod _P(( void ));
