/*
 * GEMDOS functions and externs which will come from real places when they
 * work, but for now are unreal.
 */

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

long
xterm(code)
int code;
{
	DBMSG(-1,"somebody called xterm");
	return 0;
}

long
x0term()
{
	return xterm(0);
}

long
xtermres(size,rc)
long size;
int rc;
{
	return xterm(0);
}

long 
xexec(code,cmd,tail,env)
int code;
char *cmd, *tail, *env;
{
	DBMSG(-1,"somebody called exec");
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

