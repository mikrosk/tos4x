/*
***************************     CON.C      ******************************
*
* $Revision: 2.8 $	$Source: e:/tos/gd2\RCS\con.c,v $
* =======================================================================
* $Author: apratt $ 	$Date: 1991/02/15 18:45:40 $    $Locker:  $
* =======================================================================
*
* $Log: con.c,v $
* Revision 2.8  1991/02/15  18:45:40  apratt
* CI at the end of the week...
*
* Revision 2.7  1991/02/12  18:20:10  apratt
* *** empty log message ***
*
* Revision 2.6  1991/02/11  19:56:48  apratt
* Checkin lest I lose work (again)
*
* Revision 2.5  91/01/23  14:29:46  apratt
* Trimmed logs & comments, changed to compile under GCC or (new) Alcyon.
* 
*************************************************************************
*/

#include "fs.h"


/*
 * Type-ahead buffers.
 * They are stupid.  They've gotta come out.
 */
long glbkbchar[3][KBBUFSZ];
char kbchar[3];
long *insptr[3];
long *remptr[3];

int glbcolumn[3];			/* column position */

#define UBWORD(x) (((int)x)&0x00ff)

#define   ctrlc  0x03
#define   ctrle  0x05
#define   ctrlq  0x11
#define   ctrlr  0x12
#define   ctrls  0x13
#define   ctrlu  0x15
#define   ctrlx  0x18

#define   cr      0x0d
#define   lf      0x0a
#define   tab     0x09
#define   rub     0x7f
#define   bs      0x08
#define   space   0x20

#define warmboot() xterm(-32)

coninit()
{
	kbchar[0] = kbchar[1] = kbchar[2] = 0;
	remptr[0] = insptr[0] = &(glbkbchar[0][0]);
	remptr[1] = insptr[1] = &(glbkbchar[1][0]);
	remptr[2] = insptr[2] = &(glbkbchar[2][0]);
}

/* TOP-LEVEL CALLS */

long
xconout(ch)
int ch;
{
	return _conout(1,ch);
}

long
xauxout(ch)
int ch;
{
	return _conout(2,ch);
}

long
xprtout(ch)
int ch;
{
	return _conout(3,ch);
}

long
_conout(h,ch)
int h, ch;
{
	OFD *ofd;
	int dev;
	char c;
	long err;

	if ((ofd = syshnd(h)) == NULL) return EIHNDL;
	if (ofdisatty(ofd)) return bconout(ofddevno(ofd),ch);
	c = ch;
	if ((err = xwrite(h,1L,&c)) != 1) return err;
	return E_OK;
}

long
xconin()
{
	return _conin(COOKED|ECHO,0);
}

long
xnecin()
{
	return _conin(COOKED|NOECHO,0);
}

long
xauxin()
{
	return _conin(RAW|NOECHO,2);
}

long
xrawio(ch)
int ch;
{
	if (ch == 0x00ff) {
		if (_istat(0)) return _conin(RAW|NOECHO,0);
	}
	else return _conout(1,ch);
}

_conin(mode,h)
int mode;
int h;
{
	OFD *ofd;
	char c;
	long err;

	if ((ofd = syshnd(h)) == NULL) return EIHNDL;
	if (ofdisatty(ofd)) return conin(mode,ofddevno(ofd));

	if ((err = xread(h,1L,&c)) != 1) return err;
	return c;
}

/*
 * Cconws()
 */
long
xconws(p)
char *p;
{
	OFD *ofd;
	long err;
	long len;
	char *p1;

	if ((ofd = syshnd(1)) == NULL) return EIHNDL;
	if (ofdisatty(ofd)) {
		while (*p) _conout(0,*p++);
		return E_OK;
	}
	else {
		for (p1 = p; *p1++ ; ) ;
		len = p1 - p;
		if ((err = xwrite(1,len,p)) != len) return err;
		return E_OK;
	}
}


long
xconstat()
{
	return _istat(0);
}

long
xauxis()
{
	return _istat(2);
}

_istat(h)
int h;
{
	OFD *ofd;
	char c;

	if ((ofd = syshnd(h)) == NULL) return EIHNDL;
	if (ofdisatty(ofd)) return constat(ofddevno(ofd));

	return (ofd->o_bytnum < ofd->o_dfd->dfd_fileln);
}

long
xconos()
{
	return _ostat(1);
}

long
xprnos()
{
	return _ostat(3);
}

long
xauxos()
{
	return _ostat(2);
}

long
_ostat(h)
int h;
{
	OFD *ofd;
	if ((ofd = syshnd(h)) == NULL) return EIHNDL;
	if (ofdisatty(ofd)) return bconstat(ofddevno(ofd));
	return 1;
}

/* LOWER-LEVEL CALLS */

/*
 * Input status for Bios device h
 */
long
constat(h)
int h;
{
	/* AKP: Bconstat(0) is unimplemented in BIOS */
	return( kbchar[h] ? -1L : (h ? bconstat(h) : 0) );
}


/*
 * Internal check for ^S, ^Q, ^C, and ^X.
 *
 * AKP: I changed this code to flush the BIOS input (until !bconstat(h))
 * each time it's checked, but I realize that's bad because you could be
 * getting input at 19,200 Baud, and never (rarely) get a chance to flush it.
 *
 * So instead, I gobble up to 16 bytes per call to conbrk, on the hope
 * that this is sufficient for most purposes without causing indefinite
 * postponement.
 *
 * Also, I don't call bconstat on PRN: (device 0) because it's explicitly
 * not supported by the BIOS.
 */

void
conbrk(h,block)
int h;
int block;
{
    REG long ch;
    REG int stop;
    REG int c;

    stop = 0;

    /*********************************************************************/
    /* this will crank the loop as long as there are characters waiting, */
    /* but calls bconin directly if we're in block mode & have nothing   */
    /* queued.  That way we don't have a "while (!bconstat(h)) ;" busy-  */
    /* waiting loop, and it's friendlier on multi-tasking.		 */
    /*********************************************************************/

    while ((block && kbchar[h] == 0) || (h && bconstat(h))) {
	do {
	    c = (ch = bconin(h)) & 0xFF;
	    if ( c == ctrlc ) {
		buflush(h);	/* flush BDOS & BIOS buffers */
		warmboot();	/* (this never returns) */
	    }
	    if ( c == ctrls )
		    stop = 1;
	    else if ( c == ctrlq )
		stop = 0;
	    else if ( c == ctrlx ) {
		/* THIS IS STUPID BEHAVIOR */
		buflush(h);
		qins(h,ch);
	    }
	    else {
		qins(h,ch);
	    }
	} while (stop);
    }
}


/*
 * Flush type-ahead buffer.
 */
void
buflush(h)
int h;
{
	kbchar[h] = 0;
	remptr[h] = insptr[h] = &(glbkbchar[h][0]);
}

/*
 * qins: add a character to a queue if it'll fit, and move insptr.
 */
void
qins(h,ch)
int h;
long ch;
{
    if (kbchar[h] < KBBUFSZ) {
	/* queue isn't full: add to it */
	*insptr[h]++ = ch;
	if (insptr[h] == &glbkbchar[h][KBBUFSZ]) {
	    insptr[h] = &glbkbchar[h][0];
	}
	kbchar[h]++;
    }
    else {
	bconout(h, 7);		/* beep when buffer is full */
    }
}

/*
 * Internal version of Conout.
 */
long
conout(h,ch)
int h;
int ch;
{
    long s;

    conbrk(h,0);		/* check for control-s break */
    s = bconout(h,ch);		/* output character to console */
    if (ch >= ' ') glbcolumn[h]++;	/* keep track of screen column */
    else if (ch == cr) glbcolumn[h] = 0;
    else if (ch == bs) glbcolumn[h]--;
    return s;
}


/*
 * Expand tabs to output device.
 * (WE DON'T NEED THIS).
 */
long
tabout(h,ch)
int h;
int ch;
{
    long s;

    ch &= 0xff;				/* should be unsigned */
    if (ch == tab) do {
	s = conout(h,' ');
    } while (glbcolumn[h] & 7);
    else s = conout(h,ch);
    return s;
}


/*
 * Console Output;
 * with tab and control-character expansion.
 */
long
cookdout(h,ch)
int h;
int ch;
{
    long s;
    
    ch &= 0xff;				/* hack off like unsigned char */
    if (ch == tab) s = tabout(h,ch);	/* if tab, expand it */
    else
    {
	if ( ch < ' ' ) {
            conout( h,'^' );
	    ch |= 0x40;
	}
    	s = conout(h,ch);			/* output the character */
    }
    return s;
}


/*
 * Get Character;
 * from a buffer, or the device itself.
 *
 * AKP: kbchar[h] will always be true when the I/O is in cooked mode,
 * because all cooked I/O calls conbrk in block mode first.  This
 * is so control characters are handled identically when they are
 * buffered and when they aren't.  (The fact is, because if block
 * mode in conbrk, they're all buffered.)
 */
long
getch(h)
int h;
{
	REG long temp;

	if (kbchar[h]) {
		temp = *remptr[h]++;
		kbchar[h]--;
		if (remptr[h] == &glbkbchar[h][KBBUFSZ]) {
		    remptr[h] = &glbkbchar[h][0];
		}
		return(temp);
	}
	else {
	    return (bconin(h));
	}
}


/*
 * Crawcin()
 */
long
xrawcin()
{
	return(getch(run->p_uft[0]+3));
}


/*
 * Console Input;
 * with echo.
 *
 * Calls conbrk in block mode.
 */
long
conin(mode,h)
int mode;
int h;
{
    REG long ch;

	/* not really done yet */
	1+;

    conbrk(h,1);
    conout( h,(int)(ch = getch(h)) );
    return(ch);
}

/*
 * Print line.
 */
long
prt_line(h,p)
int h;
char *p;
{
    long s = 0;

    while( *p ) s = tabout( h, *p++ );
    return s;
}


/***********************************************\
* 					        *
* Read Line, with editing and bounds checking.  *
* 					        *
\***********************************************/

/*
 * Newline, advance to appropriate column on device.
 */
void
newline(h,startcol)
REG int startcol;
REG int h;
{
    conout(h,cr);			/* go to new line */
    conout(h,lf);
    while(startcol) {
	conout(h,' ');
	startcol -= 1;		/* start output at starting column */
    }
}


/*
 * Backup one character;
 * yeah, they're assuming a video terminal.
 */
int
backsp(h,cbuf,retlen, col)
int h;
int retlen;
char *cbuf;
int col;			/* starting console column	*/
{
    REG char	ch;		/* current character	*/
    REG int	i;
    REG char	*p;		/* character pointer	*/

    if (retlen) --retlen;
				/* if buffer non-empty, decrease it by 1 */
    i = retlen;
    p = cbuf;
    while (i--)			/* calculate column position 	*/
    {				/*  across entire char buffer	*/
	ch = *p++;		/* get next char		*/
	if ( ch == tab ) {
	    col += 8;
	    col &= ~7;		/* for tab, go to multiple of 8 */
	}
	else if ( !(ch & ~0x1f) ) col += 2;
				/* control chars put out 2 printable chars */
	else col += 1;
    }
    while (glbcolumn[h] > col) {
	conout(h,bs);		/* backspace until we get to proper column */
	conout(h,' ');
	conout(h,bs);
    }
    return(retlen);
}


/*
 * Cconrs()
 */
long
xconrs(p)	/* function 10 */
char *p;	/* max length, return length, buffer space */
{
	p[1] = cgets(run->p_uft[0]+3,(((int) p[0]) & 0x0ff),&p[2]);
	return p[1];	/* this was an accident before; preserved. AKP 1/91 */
}


/*
 * Read string.
 */
long
cgets(h,maxlen,buf)
int h;
int maxlen;
char *buf;
{
	char ch;
	int i;
	REG int stcol;
	REG int retlen;

	stcol = glbcolumn[h];		/* set up starting column */
	for (retlen = 0; retlen < maxlen; ) {
		conbrk(h,1);	/* use block mode to handle ^C and ^S/^Q */
		switch(ch = getch(h)) {
			case cr:
			case lf: conout(h,cr); goto getout;
			case bs:
			case rub:
				retlen = backsp(h,buf,retlen,stcol);
				break;
			case ctrlx:
				do retlen = backsp(h,buf,retlen,stcol);
				while (retlen);
				break;
			case ctrlu:
				conout(h,'#'); 
				newline(h,stcol);
				retlen = 0;
				break;
			case ctrlr:
				conout(h,'#');
				newline(h,stcol);
				for (i=0; i < retlen; i++)
					cookdout(h,buf[i]);
				break;
			default:
				cookdout(h,buf[retlen++] = ch);
		}
	}
getout:	return(retlen);
}

long
char_write(tty,len,buf)
int tty;
long len;
char *buf;
{
    long orig_len = len;
    if (tty == 2) {
	while (len--) tabout(tty,*buf++);
    }
    else {
	while (len--) bconout(tty,*buf++);
    }
    return orig_len;
}


