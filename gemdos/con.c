/*
***************************     CON.C      ******************************
*
* $Revision: 2.10 $	$Source: e:/tos/gd2\RCS\con.c,v $
* =======================================================================
* $Author: apratt $ 	$Date: 1991/03/28 17:47:08 $    $Locker:  $
* =======================================================================
*
* $Log: con.c,v $
* Revision 2.10  1991/03/28  17:47:08  apratt
* THIS VERSION WORKS! DESKTOP OPS WORK!
*
* Revision 2.9  1991/03/12  18:25:26  apratt
* Making gtest.prg works and lets you test functions in this version
*
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
 * Type-ahead buffers.  Should be one of these per possible ofdisatty value.
 *
 * put(c):
 *  tempput = (kbput+1) % KBBUFSIZ;
 *  if (tempput == kbget) return FULL;
 *  kbput = tempput;
 *  kbqueue[kbput] = c;
 *
 * get:
 *  if (kbget == kbput) return EMPTY;
 *  kbget = (kbget + 1) % KBBUFSIZ;
 *  return kbqueue[kbget];
 */

/*
 * TTYs we know about: PRN, AUX, CON (BIOS devs 0, 1, 2).
 */

#define NTTYS 3

long kbqueue[NTTYS][KBBUFSIZ];
int kbput[NTTYS], kbget[NTTYS];

#ifdef TABOUT
/* column counter (yuck!) only used to backspace over a tab in cgets. */
int kbcol[NTTYS];
#endif

#define qempty(h) (kbput[h] == kbget[h])

#define   ctrlc  0x03
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

/* 
 * You pass _conin arguments like (RAW|NOECHO). At most one of RAW/COOKED
 * and one of ECHO/NOECHO may appear.
 */

#define	RAW	0
#define COOKED	1
#define ECHO	0
#define NOECHO	2

#define iscooked(mode) ((mode) & COOKED)
#define israw(mode) (!iscooked(mode))
#define isnoecho(mode) ((mode) & NOECHO)
#define isecho(mode) (!isnoecho(mode))

void
coninit()
{
	int i;

	for (i=0; i<NTTYS; i++) {
		buflush(i);
#ifdef TABOUT
		kbcol[i] = 0;
#endif
	}
}

/*
 * xNNN calls _NNN with the (small) handle number and mode flags.
 * _NNN checks to see if it isatty; if not, it calls ixread, ixwrite, etc.
 * 	if so, it calls NNN with the BIOS device number.
 *
 * So xconout calls _conout(1,ch,COOKED), xauxout calls _conout(2,ch,cooked),
 * and xprtout calls _conout(3,ch,COOKED)...
 *
 *    _conout (if isatty) calls conout(BIOS handle,char,mode)...
 *    conout() does the actual output.  conout() is also called by other
 * stuff, like cgets and the echoing mode of conin().
 *
 */

long
xconout(ch)
int ch;
{
	return _conout(1,ch,COOKED);
}

long
xauxout(ch)
int ch;
{
	return _conout(2,ch,COOKED);
}

long
xprtout(ch)
int ch;
{
	return _conout(3,ch,COOKED);
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
	int dev;

	if ((ofd = syshnd(1)) == NULL) return EIHNDL;
	if (ofdisatty(ofd)) {
	    dev = ofddevno(ofd);
	    while (*p) conout(dev,*p++,COOKED);
	    return E_OK;
	}
	else {
	    for (p1 = p; *p1++ ; ) ;
	    len = p1 - p;
	    if ((err = xwrite(1,len,p)) != len) return err;
	    return E_OK;
	}
}

/*
 * _conout: given a user handle number and flags, write a char out.
 */

long
_conout(h,ch,flags)
int h, ch, flags;
{
	OFD *ofd;
	char c;
	long err;

	if ((ofd = syshnd(h)) == NULL) return EIHNDL;
	if (ofdisatty(ofd)) {
	    return conout(ofddevno(ofd),ch,flags);
        }
	c = ch;
	if ((err = ixwrite(ofd,1L,&c)) != 1) return err;
	return E_OK;
}

long
char_write(tty,len,buf)
int tty;
long len;
char *buf;
{
    long orig_len = len;
    while (len--) conout(tty,*buf++,COOKED);
    return orig_len;
}

/*
 * conout: call Bconout, with conbrk if iscooked(flags)
 * Called by _conout and cgets and char_write.
 */

long
conout(dev,ch,mode)
int dev;
int ch;
int mode;
{
    if (iscooked(mode)) conbrk(dev,0,mode);	    /* non-blocking mode */
#ifdef TABOUT
    if (ch == tab) kbcol[dev] = (kbcol[dev] + 8) & ~7;
    else if (ch == cr) kbcol[dev] = 0;
    else if (ch == bs) kbcol[dev]--;
    else if (ch >= space) kbcol[dev]++;
#endif
    return bconout(dev,ch);
}

long
xconin()
{
	return _conin(0,COOKED|ECHO);
}

long
xnecin()
{
	return _conin(0,COOKED|NOECHO);
}

long
xauxin()
{
	return _conin(2,RAW|NOECHO);
}

long
xrawcin()
{
	return _conin(0,RAW|NOECHO);
}


long
xrawio(ch)
int ch;
{
	OFD *ofd;
	unsigned char c;
	long err;
	int dev;

	if (ch == 0x00ff) {
	    ofd = syshnd(0);
	    if (ofdisatty(ofd)) {
		dev = ofddevno(ofd);
		if (!qempty(dev) || (dev && bconstat(dev)))
		    return conin(dev,RAW|NOECHO);
		else return 0;
	    }
	    else {
		/* "console input" from a file */
		/* return 0 if at EOF or error, meaning "no input pending" */
		if (err = ixread(ofd,1L,&c) != 1) return 0;
		else return (unsigned long)c;
	    }
	}
	else return _conout(1,ch,RAW);
}

long
_conin(h,mode)
int mode;
int h;
{
	OFD *ofd;
	char c;
	long err;

	if ((ofd = syshnd(h)) == NULL) return EIHNDL;
	else if (ofdisatty(ofd)) return conin(ofddevno(ofd),mode);
	else {
		if ((err = ixread(ofd,1L,&c)) != 1) return err;
		else return c;
	}
}

/*
 * Console Input, in the appropriate mode
 *
 * Calls conbrk in block mode if the queue is empty.
 */
long
conin(dev,mode)
int dev;
int mode;
{
    REG long ch;

    if (iscooked(mode) || qempty(dev)) conbrk(dev,1,mode);

    /* we know !qempty now */
    ch = qrem(dev);

    if (isecho(mode)) bconout(dev,(int)ch);
    return(ch);
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

long
_istat(h)
int h;
{
	OFD *ofd;

	if ((ofd = syshnd(h)) == NULL) return EIHNDL;
	if (ofdisatty(ofd)) return constat(ofddevno(ofd));

	return (ofd->o_bytnum < ofd->o_dfd->dfd_fileln) ? -1 : 0;
}

/*
 * Input status for Bios device h
 */
long
constat(dev)
int dev;
{
	/* AKP: Bconstat(0) is unimplemented in BIOS */
	return( !qempty(dev) ? -1L : (dev ? bconstat(dev) : 0) );
}

long
xconos()
{
	return _ostat(1);
}

long
xauxos()
{
	return _ostat(2);
}

long
xprnos()
{
	return _ostat(3);
}

long
_ostat(h)
int h;
{
	OFD *ofd;
	if ((ofd = syshnd(h)) == NULL) return EIHNDL;
	if (ofdisatty(ofd)) return bconostat(ofddevno(ofd));
	return -1;	/* files are always ready for output */
}

/*
 * conbrk(dev,block,mode): on BIOS dev 'dev', check for input, do bconin, check
 * for ^C (etc.) if iscooked(mode), enqueue if not cooked or nothing special.
 *
 * If block, don't stop until there's something in the queue.  Else stop
 * when !bconstat [should stop when you've read 16 chars, which is a 
 * compromise because reading until !bconstat on a stream with lots of chars
 * can cause indefinite postponement.  Doesn't, though].
 *
 * Also, I don't call bconstat on PRN: (device 0) because it's explicitly
 * not supported by the BIOS.  God help you if you actually try to read
 * from PRN:.
 *
 * The oddity in ^X handling is a holdover from before: ^X causes typeahead
 * to be flushed, but a ^X gets stuck in so cgets sees it.
 */

void
conbrk(dev,block,mode)
int dev;
int block;
int mode;
{
    long ch;
    int stop;
    int c;

    stop = 0;

    while ((block && qempty(dev)) || stop || (dev && bconstat(dev))) {
	c = (ch = bconin(dev)) & 0xFF;
	if (iscooked(mode)) {
	    if ( c == ctrlc ) {
		/* ^C: flush input buffers & call Pterm(-32) */
		buflush(dev);
		xterm(-32);
	    }
	    else if ( c == ctrls ) stop = 1;	/* ^S: set stop flag */
	    else if ( c == ctrlq ) stop = 0;	/* ^Q: clear stop flag */
	    else if ( c == ctrlx ) {		/* ^X: wipe typeahead */
		buflush(dev);
		qins(dev,ch);	/* leave ^X in buffer */
	    }
	    else qins(dev,ch);
	}
	else qins(dev,ch);
    }
}

/*
 * Flush type-ahead buffer.
 */
void
buflush(dev)
int dev;
{
	kbput[dev] = kbget[dev] = 0;
	if (dev) while (bconstat(dev)) (void)bconin(dev);
}

/*
 * qins: add a character to a queue if it'll fit
 */

void
qins(dev,ch)
int dev;
long ch;
{
    int tempput = (kbput[dev] + 1) % KBBUFSIZ;

    /* if queue is full, send a bell to that device */
    if (tempput == kbget[dev]) bconout(dev,7);
    else {
	kbput[dev] = tempput;
	kbqueue[dev][tempput] = ch;
    }
}

long
qrem(dev)
int dev;
{
	if (qempty(dev)) return 0;
	kbget[dev] = (kbget[dev] + 1) % KBBUFSIZ;
	return kbqueue[dev][kbget[dev]];
}

/*
 * Console Output;
 * with control-character expansion.
 */
long
cookdout(dev,ch)
int dev;
int ch;
{
    long s;
    
    ch &= 0xff;				/* hack off like unsigned char */
    if (ch < space && ch != tab) {
	conout(dev,'^',COOKED);
	ch |= 0x40;
    }
    s = conout(dev,ch,COOKED);		/* output the character */
    return s;
}


/***********************************************\
* 					        *
* Read Line, with editing and bounds checking.  *
* 					        *
\***********************************************/

/*
 * Cconrs()
 * Input: p[0]: max length, &p[2]: buffer space.
 * Output: returns actual read length and puts it in p[1].
 */
long
xconrs(p)
unsigned char *p;
{
	OFD *ofd;
	unsigned char c;
	int max, i;
	unsigned char *result_ptr;

	if ((ofd = syshnd(0)) == NULL) return EIHNDL;
	if (ofdisatty(ofd)) {
	    return (p[1] = cgets(ofddevno(ofd),p[0],(char *)&p[2]));
	}

	/* read string from a file... Don't echo it! */
	max = p[0];
	result_ptr = &p[1];
	p += 2;
	for (i=0; max--; i++,p++) {
	    if (ixread(ofd,1L,p) == 1) {
		if (*p == cr) {
		    /* eat the lf, if any, and break */
		    ixread(ofd,1L,&c);
		    /* if not an LF then back up */
		    if (c != lf) ixlseek(-1,ofd,1);
		    break;
		}
		else if (*p == lf) break;
	    }
	    else {
		/* read error or EOF or something */
		break;
	    }
	}
	*result_ptr = i;

	/* returning the number of chars read was an accident before */
	/* but is now official */

	return *result_ptr;
}


/*
 * Read string.
 */
long
cgets(dev,maxlen,buf)
int dev;
long maxlen;
char *buf;
{
    char ch;
    int i, col, col1;
    int retlen;
#ifdef TABOUT
    int initcol = kbcol[dev];
#else
    int initcol = 0;
#endif

    for (retlen = 0; retlen < maxlen; ) {
	switch(ch = conin(dev,COOKED|NOECHO)) {
	    case cr:
	    case lf:
		conout(dev,cr,COOKED); 
		return retlen;

	    case bs:
	    case rub:
		if (retlen) {
		    /* compute (relative) goal column */
		    for (col=initcol, i=0; i<(retlen-1); i++) {
			if (buf[i] >= space) col++;
			else if (buf[i] == tab) col = ((col+8) & ~7);
			else col += 2;
		    }
		    col1 = col;
		    if (buf[i] >= space) col1 += 1;
		    else if (buf[i] == tab) col1 = ((col1+8) & ~7);
		    else col1 += 2;

		    for (i=col1; i > col; i--) {
			conout(dev,bs,COOKED);
			conout(dev,space,COOKED);
			conout(dev,bs,COOKED);
		    }
		    --retlen;
		}
		break;
	    case ctrlc: buflush(dev); xterm(-32);
	    case ctrlx:
		/* compute (relative) goal column */
		for (col=initcol, i=0; i<retlen; i++) {
		    if (buf[i] >= space) col++;
		    else if (buf[i] == tab) col = ((col+8) & ~7);
		    else col += 2;
		}
		while (col-- > initcol) {
		    conout(dev,bs,COOKED);
		    conout(dev,space,COOKED);
		    conout(dev,bs,COOKED);
		}
		retlen = 0;
		break;
	    case ctrlr:
	    case ctrlu:
		conout(dev,'#',COOKED);
		conout(dev,cr,COOKED);
		conout(dev,lf,COOKED);
		for (i=0; i<initcol; i++) conout(dev,' ',COOKED);
		if (ch == ctrlu) retlen = 0;
		else for (i=0; i < retlen; i++) cookdout(dev,buf[i]);
		break;
	    default:
		cookdout(dev,buf[retlen++] = ch);
	}
    }
    return retlen;
}

