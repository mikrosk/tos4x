/*
 * testbed for GEMDOS.
 */

#include "fs.h"

long _dblev;

char assertbuf[1024];

short buf[1024];

voidfn
main(argc,argv)
int argc;
char *argv[];
{
	int h;

	osi();

	for (h=0; h<1024; h++) buf[h] = h;

	xmkdir("n:\\subdir");
	h = xcreat("n:\\subdir\\test.file",0);
	xwrite(h,2048,buf);		/* middle only, start of file */
	xwrite(h,2048,buf);		/* middle only, extend file */
	xwrite(h,512,buf);		/* middle only, extend file */
	xclose(h);
	h = xopen("n:\\subdir\\test.file",1);
					/* sequence without extending file */
	xwrite(h,10L,"now is the");	/* tail start at start of sector */
	xwrite(h,2048L,buf);		/* head, mid, and tail */
	xwrite(h,10L," time for ");	/* head start & end in sector */
	xwrite(h,512-20,buf);		/* head ends at end of sector */
	xwrite(h,2048L,buf);		/* middle only */
	xclose(h);
	xdelete("n:\\subdir\\test.fil");
	xrmdir("n:\\subdir");

	DBMSG(-1,"testbed done");
}

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

long
xterm(code)
int code;
{
	DBMSG(-1,"somebody called xterm");
	return 0;
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
#if REAL
	long x = (realdate << 16) | (realtime);
	trap14(0x16,x);
#endif
}

long
cgets(h,len,buf)
int h;
long len;
char *buf;
{
	return 0;
}

long
char_write(h,len,buf)
int h;
long len;
char *buf;
{
	while (len--) trap13(3,h,*buf++);	/* Bconout */
	return E_OK;
}

void
coninit()
{
}

