/*
 * page-table data structures
 *
 *
 * The root pointer points to a list of pointers to top-level pointer tables.
 * 
 * Each entry in a pointer table points to another pointer table or to
 * a page table, or is a page descriptor.
 * 
 * Since, initially, the logical address space is the physical address space,
 * we only need to worry about 26MB plus 32K for I/O space.
 * 
 * Since we want some pages to be supervisor-accessible, but we don't want
 * a whole separate table for that, we use long-format descriptors.
 * 
 * Initial memory map:
 * 
 * 0	 - membot: S (supervisor only)
 * membot	 - memtop: P (protected TPA)
 * memtop	 - phystop: G (screen)
 * phystop	 - $00E00000: bus error
 * $00E00000- $00E3FFFF: G (ROM)
 * $00E40000- $00FF7FFF: bus error
 * $00FF8000- $00FFFFFF: G (mostly S: I/O space, but that's done in hardware)
 * $01000000- ramtop: P
 * ramtop	 - $7FFFFFFF: G (A32/D32 VME, cacheable)
 * $80000000- $FEFFFFFF: G (A32/D32 VME, non cacheable)
 * $FFxxxxxx	      just like $00xxxxxx.
 * 
 * Here's a final choice of layouts: IS=0, PS=13 (8K), TIA=4, TIB=4, TIC=4,
 * TID=7.  This lets us map out entire unused megabytes at level C, and gives
 * us an 8K page size, which is the largest the '040 can deal with.
 * 
 * This code implements 4+4+4+7, as follows:
 * 
 * tbl_a
 *     0 -> tbl_b0
 *     1-7 -> Cacheable direct (VME) page descriptors
 *     8-E -> Non-cacheable direct (VME) page descriptors
 *     F -> tbl_bf
 * 
 * tbl_b0 table: 16 entries (assumes only 16MB of TT RAM)
 *     0 -> tbl_c00 (16MB of ST RAM address space)
 *     1 -> tbl_c01 (16MB of TT RAM address space)
 *     2-F -> cacheable direct (VME) page descriptors
 * 
 * tbl_bF table: 16 entries (deals with $FF mapping to $00)
 *     0-E -> Non-cacheable direct (VME) page descriptors
 *     F -> tbl_c00 (16MB of ST RAM address space, repeated here as $FF)
 * 
 * tbl_c00 table: ST RAM address space (example assuming 4MB ST RAM)
 *     0-3 -> RAM page tables
 *     4-D -> invalid
 *     E -> direct map, cache enable (ROM)
 *     F -> direct map, cache inhibit (I/O)
 * 
 * tbl_c01 table: TT RAM address space (example assuming 4MB TT RAM)
 *     0-3 -> RAM page tables
 *     4-F -> direct map, cache enable (A32/D32 VME)
 * 
 * One RAM page table is allocated per megabyte of real RAM; each table has
 * 128 entries, which is 8K per page.  For a TT with 4MB ST RAM and 4MB TT RAM
 * that's 8K in page tables.  You can cut this down by not allocating page
 * tables for which the entire megabyte is not accessible (i.e. it's all
 * private memory and it's not YOUR private memory).
 * 
 * You have one of these per process.  When somebody loads into G or S memory
 * or leaves it, you have to go through the page tables of every process
 * updating S bits (for S) and DT (for G) bits.
 * 
 * The top levels are small & easy so replicating them once per process
 * doesn't really hurt us.
 * 
 */

#include "fs.h"

/* one switch turns off this whole file */

#if NO_MEMPROT
void init_tables (void *vptr, MPB *pmd) {}
void init_t2 (void) {}
void mark_region (MD *md, int valid) {}
#else

#define uint unsigned int
#define ulong unsigned long

typedef struct {
	short limit;
	uint zeros:14;
	uint dt:2;		/* INV, PD, or type of next table */
	struct long_desc *tbl_address;
} crp_reg;

/* format of long descriptors, both page descriptors and table descriptors */

typedef struct {
    uint limit;		/* set to $7fff to disable */
    uint unused1:6;
    uint unused2:1;
    uint s:1;		/* 1 grants supervisor access only */
    uint unused3:1;
    uint ci:1;		/* cache inhibit: used in page desc only */
    uint unused4:1;
    uint m:1;		/* modified: used in page desc only */
    uint u:1;		/* accessed */
    uint wp:1;		/* write-protected */
    uint dt:2;		/* type */
} page_type;

typedef struct long_desc {
    page_type page_type;
    struct long_desc *tbl_address;
} long_desc;

typedef struct {
    uint enable:1;
    uint zeros:5;
    uint sre:1;
    uint fcl:1;
    uint ps:4;
    uint is:4;
    uint tia:4;
    uint tib:4;
    uint tic:4;
    uint tid:4;
} tc_reg;

void set_pmmu(tc_reg tc, crp_reg crp);
void flush_pmmu(void);

/*
 * init_tables: pass a pointer into here which is a 16-byte-aligned
 * block of memory big enough to hold all the page tables for one context.
 * That means 8K+(81 overhead descriptors) or 8840 bytes for a 4MB/4MB system.
 *
 * The other argument is a PMD whose free list is examined to decide what
 * pages actually contain TPA RAM.
 *
 * Throughout this function, tptr points to the address of the next table to 
 * use.
 */

tc_reg tc;
crp_reg crp;
long_desc *tbl_c00;	/* third level, handles $00 upper byte */
long_desc *tbl_c01;	/* third level, handles $01 upper byte */

void
init_tables(vptr,pmd)
void *vptr;
MPB *pmd;
{
    long_desc *tptr = (long_desc *)vptr;
    ulong i, j;			/* i must be long or (i << 28) doesn't work */
    ulong p, q;

/*
 * prototype descriptors; field u1 must be all ones, other u? are zero.
 * This is just the first long of a full descriptor; the ".proto" part
 * of the union.
 */
    page_type g_page;
    page_type g_ci_page;
    page_type s_page;
    page_type invalid_page;
    page_type page_ptr;

    long_desc *tbl_a;		/* top-level table */
    long_desc *tbl_b0;	/* second level, handles $0 nybble */
    long_desc *tbl_bf;	/* handles $F nybble */
				/* tbl_c00 and tbl_c01 are globals */

    ulong membot;		/* RAM from 0 to membot is super-only */
    ulong memtop;		/* from membot to memtop is protected */
    ulong phystop;		/* from memtop to phystop is global */
    ulong ramtop;		/* from 0x01000000 to ramtop is protected */
    MD *md;

    g_page.limit = 0x7fff;	/* set nonzero fields: disabled limit */
    g_page.unused1 = 63;	/* ones in this reserved field */
    g_page.unused2 = 0;
    g_page.s = 0;
    g_page.unused3 = 0;
    g_page.ci = 0;
    g_page.unused4 = 0;
    g_page.m = 1;		/* set m and u to 1 so CPU won't do writes */
    g_page.u = 1;
    g_page.wp = 0;
    g_page.dt = 1;		/* descriptor type 1: page descriptor */

    g_ci_page = g_page;
    g_ci_page.ci = 1;

    s_page = g_page;
    s_page.s = 0;		/** leave s bit off for now **/

    invalid_page = g_page;
    invalid_page.dt = 0;

    page_ptr = g_page;
    page_ptr.m = 0;		/* this must be zero in page pointers */
    page_ptr.dt = 3;

    md = pmd->mp_mfl;
    membot = (ulong)md->m_start;
    memtop = membot + md->m_length;
    phystop = *(ulong *)0x42e;
    md = md->m_link;
    if (md) {
	ramtop = (ulong)md->m_start + md->m_length;
    }
    else ramtop = 0;

    tbl_a = tptr;
    tptr += 16;
    tbl_b0 = tptr;
    tptr += 16;
    tbl_bf = tptr;
    tptr += 16;
    tbl_c00 = tptr;
    tptr += 16;
    tbl_c01 = tptr;
    tptr += 16;

    DBCMD(0x80,"print tbl_c00: -x .tbl_c00 tbl_c01: -x .tbl_c01;_c");

    tbl_a[0].page_type = page_ptr;
    tbl_a[0].tbl_address = tbl_b0;

    for (i=1; i<0xf; i++) {
	if (i < 8)  tbl_a[i].page_type = g_page;
	else	    tbl_a[i].page_type = g_ci_page;
	tbl_a[i].tbl_address = (long_desc *)(i << 28);
    }

    /* $F entry of table A refers to table BF */
    tbl_a[0xf].page_type = page_ptr;
    tbl_a[0xf].tbl_address = tbl_bf;

    /* $00 entry refers to tbl_b00, the ST address space table */
    tbl_b0[0].page_type = page_ptr;
    tbl_b0[0].tbl_address = tbl_c00;

    /* $01 entry refers to tbl_c01, the TT RAM address space table */
    tbl_b0[1].page_type = page_ptr;
    tbl_b0[1].tbl_address = tbl_c01;

    /* other $0x entries refer to VME space - global, cacheable */
    for (i=2; i<16; i++) {
	tbl_b0[i].page_type = g_page;
	tbl_b0[i].tbl_address = (long_desc *)(i << 24);
    }

    /* $F0 through $FE are non-cacheable VME space */
    for (i=0; i<0xf; i++) {
	tbl_bf[i].page_type = g_ci_page;
	tbl_bf[i].tbl_address = (long_desc *)((i << 24) | 0xf0000000);
    }

    /* $FF refers to the same thing as $00 */
    tbl_bf[0xf] = tbl_b0[0];

    /* For each megabyte that is RAM, allocate a table */
    /* For TPA, make it super-accessible, because TOS accesses it. */

    for (i = 0, p = 0; p < phystop; i++, p += 0x00100000) {
	/* tptr points to a free table */
	for (q = p, j = 0; j < 128; j++, q += 0x2000) {
	    if (q < membot) {
		tptr[j].page_type = s_page;		/* system */
		tptr[j].tbl_address = (long_desc *)q;
	    }
	    else if (q < memtop) {
		tptr[j].page_type = s_page;	/* TPA (sigh) */
		tptr[j].tbl_address = (long_desc *)(q | 1);
	    }
	    else {
		tptr[j].page_type = g_page;		/* screen */
		tptr[j].tbl_address = (long_desc *)q;
	    }
	}
	tbl_c00[i].page_type = page_ptr;
	tbl_c00[i].tbl_address = tptr;
	tptr += 128;
    }

    /* now for each megabyte from phystop to ROM, mark invalid */
    for ( ; p < 0x00E00000; i++, p += 0x00100000) {
	tbl_c00[i].page_type = invalid_page;
	tbl_c00[i].tbl_address = (long_desc *)p;
    }

    /* fill in the E and F tables */
    tbl_c00[i].page_type = g_page;
    tbl_c00[i].tbl_address = (long_desc *)p;
    i++, p += 0x00100000;
    tbl_c00[i].page_type = g_ci_page;
    tbl_c00[i].tbl_address = (long_desc *)p;

    /* Done with tbl_c00, go on to TT RAM and tbl_c01. */
    /* Make TPA super-accessible, because TOS accesses it. */

    for (i = 0, p = 0x01000000; p < ramtop; p += 0x00100000, i++) {
	/* tptr points to a free table */
	for (q = p, j = 0; j < 128; j++, q += 0x2000) {
	    tptr[j].page_type = s_page;
	    tptr[j].tbl_address = (long_desc *)(q | 1);
	}
	tbl_c01[i].page_type = page_ptr;
	tbl_c01[i].tbl_address = tptr;
	tptr += 128;
    }

    /* fill in the rest of tbl_c01 (A32/D32 VME) */
    for ( ; i < 16; i++, p += 0x00100000) {
	tbl_c01[i].page_type = g_page;
	tbl_c01[i].tbl_address = (long_desc *)p;
    }

    tc.enable = 1;
    tc.zeros = 0;
    tc.sre = 0;
    tc.fcl = 0;
    tc.is = 0;
    tc.tia = 4;
    tc.tib = 4;
    tc.tic = 4;
    tc.tid = 7;			/* 0+4+4+4+7+13 == 32 */
    tc.ps = 13;			/* 8K page size */

    crp.limit = 0x7fff;			/* disable limit function */
    crp.dt = 3;				/* points to valid 8-byte entries */
    crp.tbl_address = tbl_a;

    set_pmmu(tc,crp);
}

/*
 * init_t2 -- second phase of initialization.
 *
 * The first phase builds all the tables.  It marks TPA tables as global.
 * This call goes through the MPB and marks free pages as invalid.  The
 * non-free pages [will] become super-only.
 */

void
init_t2()
{
    MD *p;

    for (p = pmd.mp_mfl; p; p = p->m_link) {
	mark_region(p,0);
    }
}

void
_dump_tree(tbl,level)
long_desc tbl;
int level;
{
    int i, j;
    long_desc *p;

    /* print the level and display the table descriptor */
    DBCMD(-1,"print -n -d wpeek(a6+10);desc (a6+8);_c");

    if (tbl.page_type.dt == 3) {
	if (level == 0) {
	    j = (1 << tc.tia);
	}
	else if (level == 1) {
	    j = (1 << tc.tib);
	}
	else if (level == 2) {
	    j = (1 << tc.tic);
	}
	else {
	    j = (1 << tc.tid);
	}
	++level;
	p = tbl.tbl_address;
	for (i=0; i<j; i++, p++) {
	    _dump_tree(*p,level);
	}
	DBCMD(-1,"print;_c");
    }
}

void
dump_tree()
{
    long_desc tbl;

    /* these are the only parts of the top-level TBL that are used */
    tbl.page_type.dt = crp.dt;
    tbl.tbl_address = crp.tbl_address;

    _dump_tree(tbl,0);
}

#define EIGHT_K 8192L
#define ONE_MEG 0x00100000L
#define SIXTEEN_MEG 0x01000000L
#define LOG2_ONE_MEG 20
#define LOG2_EIGHT_K 13

void
mark_region(md,valid)
MD *md;
int valid;
{
    ulong start = (ulong)md->m_start;
    ulong length = md->m_length;
    ulong i;
    long_desc *base_tbl, *tbl;
    int dt_val;
    extern int mem_initted;

    if (!mem_initted) return;

    if (valid) {
	DBCMD(0x80,"print -n mark_region valid. md: ;"
	       "md lpeek(a6+8);_c");
	dt_val = 1;
    }
    else {
	DBCMD(0x80,"print -n mark_region invalid. md:;"
	       "md lpeek(a6+8);_c");
	dt_val = 0;
    }

    if (start < SIXTEEN_MEG) {
	base_tbl = tbl_c00;
    }
    else {
	base_tbl = tbl_c01;
	start -= SIXTEEN_MEG;
    }

    while (length) {
	/*
	 * The index into the tbl_c?? table is the megabyte number of the
	 * address.
	 */
	i = (start >> LOG2_ONE_MEG);
	tbl = base_tbl[i].tbl_address;

	/*
	 * The index into this table is the page number within this meg.
	 */
	i = ((start & (ONE_MEG-1)) >> LOG2_EIGHT_K);
	if (tbl[i].page_type.dt == dt_val) {
	    /* already where we're setting it! */
	    DBCMD(-1,"print -i ERROR: page already in desired state!");
	}
	tbl[i].page_type.dt = dt_val;
	length -= EIGHT_K;
	start += EIGHT_K;
    }
    flush_pmmu();
}

#endif
