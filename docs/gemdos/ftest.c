/*
 * ftest: a program for testing TOS system calls
 */

#include "ftest.h"

long args[NARGS];
long vars[10];		/* $0 through $9 */
long last;
int dotime = 0;

char cmdbuf[LINESIZE];

jmp_buf err_jmp;

int devno = 2;

int loadfd = 0;
int transfd = 0;

char *helpstring[] = {
"Type a GEMDOS, BIOS, or XBIOS function name and hit return.",
"When a character is expected, use one char or \\xx (where xx are hex digits)",
"to get any value.",
"",
"When buffers are needed, they will be allocated with a size you specify",
"with (for example) x200 for 200 (hex) bytes.",
"Giving an address rather than a size uses that value.",
"",
"Numbers are normally hex; @nnn is decimal (including @-nnn for negative).",
"In place of numbers you can use a variable: use $N where N is 0-9.",
"Set variables with the set command: \"set 1 $4\" will set variable 1 to the",
"value of variable number four.  The special variable \"$\" holds the return",
"value of the last command you executed."
};

#define NHELPS (sizeof(helpstring)/sizeof(char *))

long _time;

void
get_time()
{
	_time = *(long *)0x4ba;
}

void
main(argc,argv)
int argc;
char *argv[];
{
    qsort(optab,NCMDS,sizeof(struct op),strcmp);

    osi();
    argc--, argv++;
    while (argc && **argv == '-') {
	switch(argv[0][1]) {
	    case 'm': case 'M': devno = 3; break;
	    case 'b': case 'B': devno = 2; break;
	    case 's': case 'S': devno = 1; break;
	    default:
		Cconws("Illegal arg: ");
		Cconws(*argv);
		Cconws("\r\n");
		Pterm0();
	}
	argc--, argv++;
    }

    if (argc) {
	/* load this script as a startup */
	doload(*argv);
	argc--, argv++;
    }

loop:
    if (setjmp(err_jmp)) {
	/* do nothing except re-load err_jmp if we get back here. */
	goto loop;
    }

    while (1) {
	mputs("gtest> ");
	mgets(cmdbuf);
	ui(cmdbuf);
    }
}

extern char *syserr();

void
ui(cmdbuf)
char *cmdbuf;
{
    int i,j;
    long rv;
    long end,start;
    extern long docall();
    long internal();
    int nl = 0;

	for (i=0; i<NCMDS; i++) {
	    if (strcmp(optab[i].name,cmdbuf) == 0) goto gotone;
	}
	mputs("No such command\r\n");
	return;

gotone:
	for (j=0; j<NARGS && optab[i].type[j]; j++) {
	    mgetarg(optab[i].aname[j],optab[i].type[j],j);
	}

	/* do it */

	(void)Supexec(get_time);
	start = _time;

	if (optab[i].trap == -1)
	    rv = internal(i);
	else
	    rv = docall(optab[i].trap,optab[i].fcode,args,
		    optab[i].type,NARGS);

	(void)Supexec(get_time);
	end = _time;

	/* only set last to RV if the command returns a value */
	if (optab[i].ret != NOTUSED) last = rv;

	if (dotime) {
	    mputlong(end-start);
	    mputs(" ticks ");
	    nl = 1;
	}
	if (optab[i].ret != NOTUSED) {
	    nl = 1;
	    mputs("returned ");
	    mputlong(rv);
	    if (rv < 0) {
		mputs(": ");
		mputs(syserr(rv));
	    }
	}
	if (nl) {
	    nl = 0;
	    mputs("\r\n");
	}

	switch (optab[i].ret) {
	  case RSBUF: {
	    char *temp = (char *)args[0];
	    int x = temp[1];
	    temp[x+2] = 0;

	    mputs("Buffer contains ");
	    mputint(x);
	    mputs(" characters:\r\n\"");
	    mputs(&temp[2]);
	    mputs("\"\r\n");
	    break;
	  }
	  case FREAD: {
	    char *temp = (char *)args[2];
	    char hold;
	    if (rv >= 0) {
		mputs("Fread buffer contains ");
		mputlong(rv);
		mputs(" bytes:\r\n\"");
		hold = temp[rv];
		temp[rv] = 0;
		mputs(temp);
		temp[rv] = hold;
		mputs("\"\r\n");
	    }
	    break;
	  }
	  case XDTA: {
	    if (rv == 0) {
		char *dta = (char *)xgetdta();
		mputs("DTA (");
		mputlong((long)dta);
		mputs("):\r\n");
		mputs("Private: ");
		for (i=0; i<10; i++) {
		    mputint(*(int *)(&dta[i*2]));
		    mputs(" ");
		}
		mputs("\r\n");
		mputs(&dta[30]);
		mputs(" attr ");
		mputint(dta[21]);
		mputs(" date ");
		mputint(*(int *)&dta[24]);
		mputs(" time ");
		mputint(*(int *)&dta[22]);
		mputs(" size ");
		mputlong(*(long *)&dta[26]);
		mputs("\r\n");
	    }
	    break;
	  }
	  case DFREE: {
	    if (rv == 0) {
		long *ptr = (long *)args[0];
		mputs("free cl: ");
		mputlong(*ptr++);
		mputs(" total cl: ");
		mputlong(*ptr++);
		mputs(" sect size: ");
		mputlong(*ptr++);
		mputs(" clust size: ");
		mputlong(*ptr);
		mputs("\r\n");
	    }
	    break;
	  }
	  case BUF0: {
	    if (rv >= 0) {
		mputs("Buffer contains: ");
		mputs((char *)args[0]);
		mputs("\r\n");
	    }
	    break;
	  }
	  case FDATIME: {
	    if (rv >= 0) {
		mputs("Timebuf at ");
		mputlong(args[0]);
		mputs(" holds time: ");
		mputint(*(int *)args[0]);
		mputs(" date: ");
		mputint(*(int *)(args[0]+2));
		mputs("\r\n");
	    }
	    break;
	  }
	  case PALETTE: {
	    int *p = (int *)args[2];
	    for (i=0; i<args[1]; i++) {
		mputint(i+args[0]);
		mputs(": ");
		mputint(*p++);
		mputs("\r\n");
	    }
	    break;
	  }
	  case XBPB: {
	    if (rv > 0) {
		int *ptr = (int *)rv;
		mputs("BPB at ");
		mputlong(rv);
		mputs(" contains:");
		mputs("\r\nrecsiz: ");
		mputint(*ptr++);
		mputs("\r\nclsiz:  ");
		mputint(*ptr++);
		mputs("\r\nclsizb: ");
		mputint(*ptr++);
		mputs("\r\nrdlen:  ");
		mputint(*ptr++);
		mputs("\r\nfatsiz: ");
		mputint(*ptr++);
		mputs("\r\nfatrec: ");
		mputint(*ptr++);
		mputs("\r\ndatrec: ");
		mputint(*ptr++);
		mputs("\r\nnumcl:  ");
		mputint(*ptr++);
		mputs("\r\nflags:  ");
		mputint(*ptr);
		mputs("\r\n");
	    }
	    break;
	  }
	  case INT: case LONG: case NOTUSED: break;
	  case IOREC: {
	  	short *ptr = (short *)rv;
		mputs("IOREC at ");
		mputlong(rv);
		mputs(" contains: ");
		mputs("\r\nptr: ");
		mputlong(*((long *)ptr)++);
		mputs("\r\nsiz: ");
		mputint(*ptr++);
		mputs("\r\nhead: ");
		mputint(*ptr++);
		mputs("\r\ntail: ");
		mputint(*ptr++);
		mputs("\r\nlow: ");
		mputint(*ptr++);
		mputs("\r\nhigh: ");
		mputint(*ptr++);

		if (args[0] == 0) {
		    mputs("\r\n\r\nOUTPUT IOREC:");
		    mputs("\r\nptr: ");
		    mputlong(*((long *)ptr)++);
		    mputs("\r\nsiz: ");
		    mputint(*ptr++);
		    mputs("\r\nhead: ");
		    mputint(*ptr++);
		    mputs("\r\ntail: ");
		    mputint(*ptr++);
		    mputs("\r\nlow: ");
		    mputint(*ptr++);
		    mputs("\r\nhigh: ");
		    mputint(*ptr++);
		}
		mputs("\r\n");
		break;
	  }

	  default: {
	    mputs("No code to interpret this kind of return yet.\r\n");
	    break;
	  }
	}
}

long
internal(c)
int c;
{
    int i,j;

    switch(optab[c].fcode) {
	case 1: /* list */
	    for (i=j=0; i<NCMDS; i++,j++) {
		if (j && j > 8) j=0,mputs("\r\n");
		mputs(optab[i].name);
		mputs("\t");
		if (strlen(optab[i].name) > 7) j++;
	    }
	    mputs("\r\n");
	    break;

	case 2: /* quit */
	    err("quit");

	case 3: /* help */
	    for (i=0; i<NHELPS; i++) {
		mputs(helpstring[i]);
		mputs("\r\n");
	    }
	    break;
	case 4: /* load */
	    doload((char *)args[0]);
	    break;
	case 5: /* transcript */
	    dotrans((char *)args[0]);
	    break;
	case 6:	/* dbstop */
	    mputs("Call Debug.\r\n");
	    trap14(11,5,0xf000,"FTEST Debugger trap");
	    break;
	case 7: /* db */
	    mputs("Call Debug.\r\n");
	    trap14(11,5,0xf100,args[0]);
	    break;
	case 8: /* time */
	    dotime ^= 1;
	    break;
	case 9: /* set */
	    vars[args[0]] = args[1];
	    return args[1];
	case 10: /* zabort */
	    if (args[0] == 0) err("Z abort");
	    break;
	case 11: /* miabort */
	    if (args[0] < 0) err("MI abort");
	    break;
	case 12: /* nzabort */
	    if (args[0] != 0) err("NZ abort");
	    break;
	    
	default:
	    mputs("Unimplemented internal function, number ");
	    mputint(c);
	    break;
    }
    return 0;
}

void
mputs(s)
register char *s;
{
    while (*s) mput(*s++);
}

char hex[] = "0123456789ABCDEF";

void
mputlong(l)
long l;
{
    int j;

    for (j=28; j>=0; j-=4) {
	mput(hex[(l>>j) & 0xf]);
    }
}

void
mputint(i)
int i;
{
    int j;
    for (j=12; j >= 0; j -= 4) {
	mput(hex[(i>>j) & 0xf]);
    }
}

void
mput(c)
char c;
{
    if (transfd) (void)Fwrite(transfd,1L,&c);
    (void)Bconout(devno,c);
}

void
mgets(buf)
char *buf;
{
    int i = 0;
    char c;
    long errno;
    int space_breaks = 1;

    while (1) {
	if (loadfd) {
	    if ((errno = Fread(loadfd,1L,&c)) != 1) {
		if (errno < 0) mputs("Read error on load file\r\n");
		else mputs("End of load file\r\n");
		loadfd =  0;
	    }
	}
	if (!loadfd) {
	    c = Bconin(devno) & 0x7f;
	}
	if (c == '\n') continue;
	if (c == '\r' || (space_breaks && c == ' ')) break;
	switch (c) {
	    case '"':
		if (i) goto just_a_char;
		space_breaks = 0;
		mputs("\"\010");
		break;
	    case 8: case 127:
		if (i) {
		    i--;
		    mputs("\010 \010");
		}
		break;

	    case 'U'-'@':
		while (i > 0) {
		    mputs("\010 \010");
		    i--;
		}
		break;

	    case 'C'-'@': Pterm0();
	    default:
just_a_char:
		buf[i++] = c;
		mput(c);
	}
    }
    buf[i] = 0;
    mputs("\r\n");
}

void
mgetarg(name,type,n)
char *name;
int type;
int n;
{
    char buf[LINESIZE], *ptemp;
    long atolx();
    int temp;

    mputs("Arg ");
    mputs(name);
    mputs(": ");

    switch (type) {
      case FMAGIC: {
	mputs("87654321\r\n");
	args[n] = 0x87654321L;
	return;
      }
      case LZERO: case WZERO: {
	mputs("0\r\n");
	args[n] = 0;
	return;
      }
      case RSBUF: {
	if ((ptemp = malloc(82)) == 0) {
	    err("Out of memory");
	}
	*ptemp = 80;
	args[n] = (long)ptemp;
	mputlong((long)ptemp);
	mputs("\r\n");
	return;
      }
      case TIMEBUF: {
	long date, time;
      	mputs("time: ");
      	mgets(buf);
      	if (*buf == 0) *buf = '0', buf[1] = 0;
      	time = atolx(buf);
      	mputs("date: ");
      	mgets(buf);
      	if (*buf == 0) *buf = '0', buf[1] = 0;
      	date = atolx(buf);
      	if ((ptemp = malloc(4)) == 0) {
	    err("Out of memory");
	}
	*(int *)ptemp = time;
	*(int *)(ptemp+2) = date;
	mputs("Timebuf at ");
	mputlong((long)ptemp);
	mputs(" holds ");
	mputint(*(int *)ptemp);
	mputs(" ");
	mputint(*(int *)(ptemp+2));
	mputs("\r\n");
	args[n] = (long)ptemp;
	return;
      }
    }
	

    /* else it's a type requiring user interaction */

    mgets(buf);

    switch (type) {
	case INT:
	case LONG:
	    args[n] = atolx(buf);
	    break;

	case STRING:
	    if ((args[n] = (long)malloc(strlen(buf)+1)) == 0) {
	    	err("Out of memory");
	    }
	    strcpy((char *)args[n],buf);
	    break;

	case CHAR:
	    if (*buf != '\\') args[n] = *buf;
	    else args[n] = atolx(buf+1);
	    break;

      	case BUF: {
	    if (*buf == 0 || *buf == 'x') {
		if (*buf == 0) temp = 0x200;
		else temp = atolx(buf+1);
		if ((ptemp = malloc(temp)) == 0) {
		    err("Out of memory");
		}
		mputs("Buffer: ");
		mputlong((long)ptemp);
		mputs(" length ");
		mputint(temp);
		mputs("\r\n");
	    }
	    else {
		ptemp = (char *)atolx(buf);
	    }
	    args[n] = (long)ptemp;
	    break;
	}
    }
}

void
err(s)
register char *s;
{
    mputs(s);
    mputs("\r\nEXITING\r\n");

    if (transfd) {
	(void)Fclose(transfd);
	transfd = 0;
    }

    /* echo to host as well */
    if (devno != 2) {
	devno = 2;
	mputs(s);
	mputs("\r\n");
    }
    Pterm0();
}

long
atolx(s)
register char *s;
{
    register long rv = 0;
    register int sign = 1;
    register int decimal = 0;

    if (*s == '$') {
	if (!*(s+1)) return last;
	else return vars[*(s+1)-'0'];
    }

    if (*s == '@') {
	decimal = 1;
	s++;
    }

    if (*s == '-') {
	sign = -1;
	s++;
    }
    while (*s) {
	if (decimal) {
	    rv *= 10;
	    if (*s >= '0' && *s <= '9') rv += (*s - '0');
	    else goto err;
	}
	else {
	    rv <<= 4;
	    if (*s >= '0' && *s <= '9') rv += ((*s)-'0');
	    else if (*s >= 'A' && *s <= 'F') rv += ((*s)-('A'-10));
	    else if (*s >= 'a' && *s <= 'f') rv += ((*s)-('a'-10));
	    else {
err:
		mputs("NUMERIC INPUT ERROR; ABORTED.\r\n");
		longjmp(err_jmp,1);
	    }
	}
	s++;
    }
    return rv*sign;
}

void
doload(buf)
char *buf;
{
    int fd;

    if (!*buf) return;
    
    if ((fd = Fopen(buf,0)) < 0) {
	mputs("Error opening ");
	mputs(buf);
	mputs(": ");
	mputs(syserr((long)fd));
	mputs("\r\n");
	return;
    }
    loadfd = fd;
}

void
dotrans(buf)
char *buf;
{
    int fd;

    if (!*buf) return;
    if (strcmp(buf,"off") == 0) {
	if (transfd) {
	    (void)Fclose(transfd);
	}
	transfd = 0;
	return;
    }
    if (transfd) (void)Fclose(transfd);
    transfd = 0;
    if ((fd = Fcreate(buf,0)) < 0) {
	mputs("Error opening ");
	mputs(buf);
	mputs(": ");
	mputs(syserr((long)fd));
	mputs("\r\n");
	return;
    }
    transfd = fd;
}
