/* kballoc.c - fast allocator for LC5 based on AKP's nalloc2.c
 * ===========================================================================
 * $Log: kballoc.c,v $
 * Revision 1.2  1993/03/08  20:07:02  ersmith
 * REAL MultiTOS 1.01
 *
 * Revision 1.1  1993/02/24  23:52:46  ersmith
 * 1 meg floppy MultiTOS
 *
 * 911025 kbad added mavail(), mheap()
 * 910508 kbad
 */

/*
 * General-purpose memory allocator compatible with MWC but much faster. In
 * addition, blocks are coalesced when they're freed, and if this results
 * in an arena no allocated blocks, it's returned to the OS.
 *
 * The functions here have the same names and bindings as the MWC
 * memory manager, which is the same as the UNIX names and bindings
 * plus lmalloc etc.
 *
 * malloc() calls are satisfied by using Malloc() to get large arenas,
 * which are then chopped up and returned from malloc().
 *
 * There is a little protection here against using "too many" blocks, but
 * the TOS 1.0 / TOS 1.2 limits on allocating blocks are a great reason to
 * upgrade to TOS 1.4.  The protection is in MAXARENA and minarena;
 * see those comments for details.  There are no guarantees.
 *
 * Placed unsupported in the public domain by Allan Pratt, April 22, 1991.
 */

#define DEBUGON 0	/* 1 to make mdump() available */
#define NOISY	0	/* 1 to write tracking chars to stdout */
#define VALIDATE 0	/* 1 for SLOW validity checks on malloc/free */

#include <osbind.h>

#if 0	/* DEBUGON */
#include <stdio.h>
#else
typedef unsigned long size_t;
#endif

#if 0	/* NOISY && DEBUGON */
#define DBconout(c) Cconout(c)
#else
#define DBconout(c) /**/
#endif

#if 0	/* DEBUGON	*/
#define ding() Bconout(2,'\a');
#endif

/*
 * Portability & debug assist definitions
 */
#define REG	register
#define MLOCAL	static
#define GLOBAL	/* */
#define VOID	/* */ /* void for ANSI, else empty comment */
#if 0
typedef void	*VOIDP;	/* void* for ANSI, else char* */
#else
typedef char	*VOIDP;
#define __NOPROTO
#endif

#ifndef NULL
#define NULL	((VOIDP)0L)
#endif

#undef __PROTO

#ifndef __NOPROTO
#define __PROTO(a) a
#else
#define __PROTO(a) ()
#endif

VOIDP	lmalloc __PROTO(( long ));
VOID	free __PROTO(( VOIDP ));
VOIDP	malloc __PROTO(( size_t ));
VOIDP	lcalloc __PROTO(( long, long ));
VOIDP	calloc __PROTO(( size_t, size_t ));
VOIDP	lrealloc __PROTO(( VOIDP, long ));
VOIDP	realloc __PROTO(( VOIDP, size_t ));
VOID	mdump( VOID );
long	mavail( VOID );
VOID	mheap __PROTO(( VOIDP, size_t ));

#define ALIGN (sizeof(short)-1)

/* ---------------------------------------------------------------------------
 * block header: every memory block has one.
 * A block is either allocated or on the free
 * list of the arena.  There is no allocated list: it's not necessary.
 * The next pointer is only valid for free blocks,
 * for allocated blocks it contains ALLOC_MAGIC.
 *
 * Zero-length blocks are possible; they hold space which might 
 * get coalesced usefully later on.
 */
typedef struct block
{
#if VALIDATE
	struct block *b_valid;
#endif
	struct block *b_next;   /* NULL for last guy; next alloc or next free */
	long b_size;
} BLOCK;

#define ALLOC_MAGIC	((BLOCK*)0x614C6F43L) /* 'aLoC' */
#define FREE_MAGIC	((BLOCK*)0x46724565L) /* 'FrEe' */

/* ---------------------------------------------------------------------------
 * arena header: every arena has one.  Each arena is always completely
 * filled with blocks; the first starts right after this header.
 */
typedef struct arena
{
	struct arena *a_next;
	long a_size;
	struct block *a_ffirst; /* head of free list */
#if VALIDATE
	struct block *a_afirst; /* head of alloc list */
#endif
} ARENA;

/* ---------------------------------------------------------------------------
 * Arena linked-list pointer, and block size.  The block size is initialized
 * to Malloc(-1L)/20 when you start up, because somebody said that 20
 * Malloc blocks per process was a reasonable maximum.  This is hopelessly
 * unbalanced: 25K on a 520ST and 200K on a Mega 4, so it's tempered by
 * the constant MAXARENA as the largest minimum you'll get (I chose 100K).
 */
MLOCAL ARENA *a_first = NULL;
MLOCAL ARENA *a_heap = NULL;
MLOCAL long minarena = 0;

#if 0
#define MAXARENA (100L*1024L)
#else
#define MAXARENA (32*1024L)
#endif

#if VALIDATE
/* ---------------------------------------------------------------------------
 * Validate ALL arenas & blocks of memory. Return 0 if any are invalid.
 */
MLOCAL int mvalid(VOID)
{
REG	ARENA	*a;
REG	BLOCK	*b, *valid;

	for (a = a_first; a; a = a->a_next)
	{
		for (valid = FREE_MAGIC, b = a->a_ffirst; b; b = b->b_next)
			if (b->b_valid != valid) return 0;
		for (valid = ALLOC_MAGIC, b = a->a_afirst; b; b = b->b_next)
			if (b->b_valid != valid) return 0;
	}
	return 1;
}
#endif

/*
 * memory initializor
 */
GLOBAL VOID initkballoc()
{
	a_first = NULL;
	a_heap = NULL;
	minarena = 0;
}

/* ---------------------------------------------------------------------------
 * First-fit allocator.
 * If a large enough block is available in an arena, return it,
 * else get a new arena of max(minarena, size) bytes.
 */
GLOBAL VOIDP lmalloc(size)
REG long size;
{
REG	ARENA	*a;
REG	BLOCK	*b, *mb, **q;
REG	long	temp, minsize;

	DBconout('A');

	/* validate & align size */
	if (size < 0) return NULL;
	size = (size+ALIGN) & ~ALIGN;

#if VALIDATE
	if (!mvalid()) { ding(); return NULL; }
#endif

	/* Search through all arenas for a big enough block. */
	minsize = size + sizeof(BLOCK);
	a = a_first;
	mb = NULL;
	while (a && !mb)
	{
		/* Look for a big enough block in this arena */
		b = *(q = &a->a_ffirst);
		while (b && !mb)
		{
			if (b->b_size >= size)
			{
			/* Big enough block.
			 * If it can be cut, split it into alloc & free parts,
			 * else just unlink it from the free list.
			 */
				mb = b;
				if (mb->b_size >= minsize)
				{
					DBconout('c');
					b = (BLOCK*)(((char*)(b+1)) + size);
					b->b_size = mb->b_size - minsize;
					b->b_next = mb->b_next;
					*q = b;
#if VALIDATE
					b->b_valid = FREE_MAGIC;
#endif
					mb->b_size = size;
				}
				else
				{
					DBconout('w');
					*q = mb->b_next;
				}
			}
			else b = *(q = &b->b_next);
		}
		if (!mb) a = a->a_next;
	}

	if (!mb)
	{
	/*
	 * No block available:
	 * get a new arena unless using static heap
	 */
		if (a_heap) return NULL;

		if (!minarena)
		{
			minarena = (long)Malloc(-1L) / 20;
			if (minarena > MAXARENA) minarena = MAXARENA;
		}

		if (size < minarena)
		{
			DBconout('m');
			temp = minarena;
		}
		else
		{
			DBconout('s');
			temp = size;
		}

		if ( !(a = (ARENA*)Malloc(sizeof(ARENA)+sizeof(BLOCK)+temp)) )
		{
			DBconout('x');
			return NULL;
		}

		a->a_next = a_first;
		a->a_size = temp + sizeof(BLOCK);
#if VALIDATE
		a->a_afirst = NULL;
#endif
		a_first = a;
		mb = (BLOCK*)(a+1);
		mb->b_next = NULL;
		mb->b_size = size;
	
		if (temp >= minsize)
		{
		/* Space left over, set up a free block */
			DBconout('c');
			b = a->a_ffirst = (BLOCK*)((char*)(mb+1) + size);
			b->b_next = NULL;
			b->b_size = temp - minsize;
#if VALIDATE
			b->b_valid = FREE_MAGIC;
#endif
		}
		else a->a_ffirst = NULL;
	}

#if VALIDATE
	/* link the new block into the alloc list */
	mb->b_valid = ALLOC_MAGIC;
	mb->b_next = a->a_afirst;
	a->a_afirst = mb;
#else
	mb->b_next = ALLOC_MAGIC;
#endif
	return ++mb;
}


/* ---------------------------------------------------------------------------
 * free with address validation
 * Blocks are coalesced, and empty arenas are returned to the system.
 */
GLOBAL VOID free(xfb)
VOIDP xfb;
{
	ARENA	*a, **qa;
REG	BLOCK	*b, *pb, *fb;
#if VALIDATE
	BLOCK	**qb;
#endif

	DBconout('F');
	fb = ((BLOCK*)xfb)-1;

#if VALIDATE
	if (mvalid() && fb->b_valid == ALLOC_MAGIC)
#else
	if (fb->b_next == ALLOC_MAGIC)
#endif
		a = *(qa = &a_first);
	else
		a = NULL;

	/* Find the arena this block lives in */
	while ( a && (fb < (BLOCK*)a || fb > (BLOCK*)(((char*)a)+a->a_size)) )
		a = *(qa = &a->a_next);

	if (!a)
	{
#if DEBUGON
		printf("\a\033H\nBogus free($%p)\n", xfb);
#endif
		return; /* Failure */
	}

	/*
	 * Found it!
	 * `a' is this block's arena
	 */
#if VALIDATE
	fb->b_valid = FREE_MAGIC;
	/* unlink fb from the allocated list */
	for (b = *(qb = &a->a_afirst); b && b != fb; b = *(qb = &b->b_next))
	;
	*qb = b->b_next;
#endif

	/* set pb to the previous free block in this arena, b to next */
	for (pb = NULL, b = a->a_ffirst;
		 b && (b < fb);
		 pb = b, b = b->b_next)
	;

	fb->b_next = b;

	/* Coalesce backward:
	 * if any prev,
	 *   if adjacent, absorb
	 *   else link
	 * else make fb the head of the free list.
	 */
	if (pb)
	{
		if ((BLOCK*)(((char*)(pb+1)) + pb->b_size) == fb)
		{
		/* absorb adjacent block */
			DBconout('b');
			pb->b_size += sizeof(BLOCK) + fb->b_size;
			fb = pb;
		}
		else pb->b_next = fb;
	}
	else a->a_ffirst = fb;

	/* Coalesce forward: if the next block is adjacent, absorb it */
	if (b && (BLOCK*)(((char*)(fb+1)) + fb->b_size) == b)
	{
		DBconout('f');
		fb->b_size += sizeof(BLOCK) + b->b_size;
		fb->b_next = b->b_next;
	}

	/* If, after coalescing, this arena is entirely free, Mfree it! */
	if ( !a_heap
	&&	a->a_ffirst == (BLOCK*)(a+1)
	&&	(a->a_ffirst->b_size + sizeof(BLOCK)) == a->a_size )
	{
		DBconout('!');
		*qa = a->a_next;
		Mfree(a);
	}
}

/* ---------------------------------------------------------------------------
 */
GLOBAL VOIDP malloc(size)
size_t size;
{
	return (lmalloc((long)size));
}

/* ---------------------------------------------------------------------------
 */
GLOBAL VOIDP lcalloc(count,size)
long count;
REG long size;
{
	VOIDP	buf;
REG	long	frag, *lp;
	char	*cp;

	size *= count;
	if ( (buf = lmalloc(size)) != NULL )
	{
	/* clear longs, then leftovers */
		lp = (long*)buf;
		frag = (size & 3) + 1;
		size = (size >> 2) + 1;
		while (--size) *lp++ = 0;
		cp = (char*)lp;
		while (--frag) *cp++ = 0;
	}
	return buf;
}

/* ---------------------------------------------------------------------------
 */
GLOBAL VOIDP calloc(count,size)
size_t count, size;
{
	return lcalloc((long)count,(long)size);
}

/* ---------------------------------------------------------------------------
 * This realloc is really dumb: just calls malloc for a new block.
 * No attempt is made to take advantage of
 * an adjacent free block, either forward or back.
 */
GLOBAL VOIDP lrealloc(xrb,size)
VOIDP xrb;
REG long size;
{
REG	BLOCK	*rb = (BLOCK*)xrb;
REG	BLOCK	*b;
REG	long	frag, *ls, *ld;
	char	*cs, *cd;

	DBconout('R');

	/* validate & align size */
	if (size < 0) return NULL;
	size = (size+ALIGN) & ~ALIGN;

	ls = (long*)rb; 	/* save start address of original block */
	rb--;				/* get block header address */

	/* get a new block and copy */
	if ((b = (BLOCK*)(ld = lmalloc(size))) == NULL) return NULL;

	if (rb->b_size < size) size = rb->b_size;
	frag = (size & 3) + 1;
	size = (size >> 2) + 1;
	while (--size) *ld++ = *ls++;
	cs = (char*)ls;
	cd = (char*)ld;
	while (--frag) *cd++ = *cs++;

	free(rb+1);
	DBconout('r');
	return b;
}

/* ---------------------------------------------------------------------------
 */
GLOBAL VOIDP realloc(ptr,size)
VOIDP ptr;
size_t size;
{
	return lrealloc(ptr,(long)size);
}

/* ---------------------------------------------------------------------------
 */
#if DEBUGON
GLOBAL ARENA *watch_arena = NULL;

GLOBAL VOID mdump( VOID )
{
REG	ARENA *a;
REG	BLOCK *b;
	int i;

puts("\033H");
	for (a = a_first; a; a = a->a_next)
	{
		if (watch_arena && a != watch_arena) continue;
		printf("\n\033K\033p$%p[%lx]\033q\n\033K", a, a->a_size);
		if (a->a_ffirst)
		{
			for (i=0, b = a->a_ffirst; b; b = b->b_next)
			{
				printf("$%p[%05lx]$%p %s",
						b, b->b_size, (char*)(b+1)+b->b_size,
						(++i == 3) ? i=0,"\n\033K" : "");
				if (b->b_size > a->a_size) ding();
			}
		}
	}
	printf("\n\033K");
}

#endif

/* ---------------------------------------------------------------------------
 * Return the total number of bytes of memory available for allocation.
 */
GLOBAL long mavail( VOID )
{
	long	*p, *prev;
	long	chunk, total;
	ARENA	*a;
	BLOCK	*b;

	/* Total the amount of free space in arenas. */
	total = 0L;
	for (a = a_first; a; a = a->a_next)
		for (b = a->a_ffirst; b; b = b->b_next)
			total += b->b_size;

	/*
	 * If not using static heaps, 
	 * find the total amount of GEMDOS free memory:
	 * Malloc() all available blocks, then free 'em.
	 */
	if (!a_heap)
	{
		prev = NULL;
		while ( (chunk = (long)Malloc(-1L)) > 0L )
		{
			total += chunk;
			p = Malloc(chunk);
			*p = (long)(prev);
			prev = p;
		}
		while ((p = prev) != NULL)
		{
			prev = *(long **)p;
			Mfree(p);
		}
	}

	return total;
}

/* ---------------------------------------------------------------------------
 * Add a static heap.
 */
GLOBAL VOID mheap(add, size)
VOIDP add;
size_t size;
{
REG	ARENA	*a;
REG	BLOCK	*b;

	if (size <= sizeof(ARENA)+sizeof(BLOCK)) return;

	a = (ARENA*)add;
	a->a_next = a_first;
	b = a->a_ffirst = (BLOCK*)(a+1);
	a->a_size = size - sizeof(ARENA);
	b->b_size = a->a_size - sizeof(BLOCK);
	b->b_next = NULL;
#if VALIDATE
	a->a_afirst = NULL;
	b->b_valid = FREE_MAGIC;
#endif

	a_first = a_heap = a;
}
