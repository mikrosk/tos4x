/*
 * GEMDOS functions and externs which will come from real places when they
 * work, but for now are unreal.
 */

#include <osbind.h>
#include "fs.h"

long _dblev;

char assertbuf[1024];

int
uc(c)
int c;
{
	return (c >= 'a' && c <= 'z') ? (c - ('a'-'A')) : c;
}

voidfn
s68(w)
void *w;
{
	char *p = (char *)w;
	char c1 = *p;
	*p = *(p+1);
	*(p+1) = c1;
}

voidfn
s68l(w)
void *w;
{
	char *p = (char *)w;
	char *q = (char *)(w+4);

	char c1, c2;

	c1 = *p;
	*p++ = *--q;
	c2 = *p;
	*p++ = *--q;
	*p++ = c2;
	*p = c1;
}

BCB *bufl[2];

/*
 * slow, stupid clear, but it works for any length block
 */

voidfn
clear(start,end)
void *start, *end;
{
	char *s = start;
	char *e = end;
	while (s < e) *s++ = 0;
}

void
xfr2usr(n,s,d)
uint n;
void *s, *d;
{
	char *s1 = s, *d1 = d;
	while (n--) *d1++ = *s1++;
}

void
usr2xfr(n,d,s)
uint n;
void *d, *s;
{
	char *s1 = s, *d1 = d;
	while (n--) *d1++ = *s1++;
}

uint bootdev = 0;

voidfn
upd_tod()
{
	long x = (realdate << 16) | (realtime);
	trap14(0x16,x);
}

MD initmd;
MD initaltmd;

void
getmpb(mpb)
MPB *mpb;
{
    long size;
    void *base;

    size = Mxalloc(-1L,0) / 2;
    base = (void *)Mxalloc(size,0);
    if (base == NULL) panic1("can't malloc ST RAM");
    initmd.m_link = &initaltmd;
    initmd.m_own = NULL;
    initmd.m_start = base;
    initmd.m_length = size;

    size = Mxalloc(-1L,1) / 2;
    base = (void *)Mxalloc(size,1);
    if (base == NULL) panic1("can't malloc TT RAM");
    initaltmd.m_link = NULL;
    initaltmd.m_own = NULL;
    initaltmd.m_start = base + 1;	/* make odd for alt. RAM */
    initaltmd.m_length = size;

    mpb->mp_mfl = &initmd;
    mpb->mp_mal = NULL;
    mpb->mp_rover = NULL;
}

void
dojmp(addr)
long addr;
{
	void (*p)() = (void (*)())addr;
	(*p)();
}

void
clksync()
{
	;
}

void 
gouser()
{
	DBCMD(-1,"print somebody called gouser!");
}
