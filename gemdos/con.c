/*
***************************     CON.C      ******************************
*
* $Revision: 2.4 $	$Source: /u2/MRS/osrevisions/gemdos/con.c,v $
* =======================================================================
* $Author: apratt $ 	$Date: 90/08/03 13:40:23 $    $Locker:  $
* =======================================================================
*
* $Log: con.c,v $
* Revision 2.4  90/08/03  13:40:23  apratt
* TTOS FINAL RELEASE
* 
* Revision 2.3  89/07/18  14:09:59  apratt
* Changed the conbrk loop so if you're in block mode and nothing's
* waiting, you don't wait in a Bconstat loop, you call Bconin outright.
* 
* Revision 2.2  89/04/17  17:13:29  kbad
* YA header change
* 
* Revision 2.1  89/02/21  17:17:39  kbad
* *** TOS 1.4  FINAL RELEASE VERSION ***
* 
* Revision 1.3  88/06/13  15:05:38  apratt
* Header style change
* 
* Revision 1.2  88/05/04  11:45:33  apratt
* Added 'return' keyword to printer output (Cprnout), because old desktop
* (and God knows who else) relied on getting the BIOS return code back
* from this.  The return code is undocumented, and is 0 for success and
* -1 for failure (timeout).  In fact, the return is unspecified if the
* printer->serial port hack bit is set.
* 
* Revision 1.1  88/04/26  14:48:15  apratt
* Version used 4/22/88 to make test ROMs
* 
*************************************************************************
*/

/****************************************************************************\
* 									     *
* GEMDOS Console System							     *
* (C)1986 Atari Corp.							     *
* 									     *
* ---- Edit history (reverse order, please): ------------------------------  *
* 									     *
* 14-Mar-1988 akp	Marked ^X handling as stupid but left it in.	     *
*			Removed &0xff from bconin() -- fat fingers.	     *
*			Worked out unsigned char without using the type,     *
*			because of the lack of unsigned char in Alcyon	     *
*			version 4.04.					     *
* 02-Mar-1988 akp	Fixed ^C handling again: added block mode to conbrk. *
*			This is so ctl-char handling is identical for	     *
*			buffered and unbuffered characters.		     *
*			Also: swallow up to 16 bytes per call to (non-       *
*			blocking) conbrk rather than the whole input buffer, *
*			becaues otherwise you get indefinite postponement    *
*			on high-speed input devices (19.2Kbaud AUX:).	     *
* 18-Feb-1988 akp	Lintified.					     *
* 17-Feb-1988 akp	Fixed stupid semi-circular queue.		     *
*			Full/empty condition is the count; insptr and remptr *
*			are POSTincremented with wrap.  Both full and empty  *
*			buffers have insptr == remptr; use kbchar[h] to	     *
*			check the state.				     *
* 03-Feb-1988 akp	Changed some register declarations.		     *
* 29-Jan-1988 akp	Moved calls to conbrk so they cause a break at the   *
*			right time (before the ^C is read, not after).	     *
* 21-Oct-1987 akp	Cleaned up for lint (not very much).		     *
* 15-Jan-1986 lmd	Commented and prettified from Digital Research	     *
* 			source code.  This file pretty much needs to	     *
* 			be completely re-written.			     *
* 									     *
\****************************************************************************/
#include "fs.h"
#include "fsdecl.h"


/*
 * Type-ahead buffers.
 * They are stupid.  They've gotta come out.
 */
long glbkbchar[3][KBBUFSZ];
char kbchar[3];
long *insptr[3];
long *remptr[3];

int glbcolumn[3];			/* column position */

extern PD *run;

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

/*
 * Console Input Status.
 */
long
constat(h)
int h;
{
	/* AKP: printer never has input pending.  Stupid BIOS. */
	return( kbchar[h] ? -1L : (h ? bconstat(h) : 0) );
}


/*
 * Console Input Status
 * (another level up...).
 */
long
xconstat()
{
	return(constat(run->p_uft[0]+3));
}


/*
 * Console Output Status.
 */
long
xconostat()
{
	return(bconostat(run->p_uft[1]+3));
}


/*
 * Printer Output Status.
 */
long
xprtostat()
{
	return(bconostat(run->p_uft[3]+3));
}


/*
 * Auxillary Input Status.
 */
long
xauxistat()
{
	return(constat(run->p_uft[2]+3));
}


/*
 * Auxillary Output Status.
 */
long
xauxostat()
{
	return(bconostat(run->p_uft[2]+3));
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
conbrk(x_h,x_block)
int x_h;
int x_block;
{
    REG int h;
    REG int block;
    REG long ch;
    REG int stop;
    REG int c;
    REG int count;

    h = x_h;
    block = x_block;

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
	    if ( c == ctrlc )
	    {
		buflush(h);	/* flush BDOS & BIOS buffers */
		warmboot();	/* (this never returns) */
	    }
	    if ( c == ctrls )
		    stop = 1;
	    else if ( c == ctrlq )
		stop = 0;
	    else if ( c == ctrlx )
	    {
		/* THIS IS STUPID BEHAVIOR */
		buflush(h);
		qins(h,ch);
	    }
	    else
	    {
		qins(h,ch);
	    }
	} while (stop);
    }
}


/*
 * Flush type-ahead buffer.
 */
buflush(h)
int h;
{
	kbchar[h] = 0;
	remptr[h] = insptr[h] = &(glbkbchar[h][0]);
}

/*
 * qins: add a character to a queue if it'll fit, and move insptr.
 */
qins(x_h,ch)
REG int x_h;
long ch;
{
    REG int h;

    h = x_h;
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
conout(x_h,x_ch)
int x_h;
int x_ch;
{
    REG int h;
    REG int ch;

    h = x_h;
    ch = x_ch;

    conbrk(h,0);		/* check for control-s break */
    bconout(h,ch);		/* output character to console */
    if (ch >= ' ') glbcolumn[h]++;	/* keep track of screen column */
    else if (ch == cr) glbcolumn[h] = 0;
    else if (ch == bs) glbcolumn[h]--;
}


/*
 * Console Output;
 * with tab expansion.
 * [is that a feature???]
 */
long
xtabout(ch)
int ch;
{
	tabout(run->p_uft[1]+3,ch & 0xff);
}


/*
 * Expand tabs to output device.
 * (WE DON'T NEED THIS).
 */
long
tabout(x_h,x_ch)
int x_h;
int x_ch;
{
    REG int h;
    REG int ch;

    h = x_h;
    ch = x_ch;

    ch &= 0xff;				/* should be unsigned */
    if (ch == tab) do
	conout(h,' ');
    while (glbcolumn[h] & 7);
    else conout(h,ch);
}


/*
 * Console Output;
 * with tab and control-character expansion.
 */
cookdout(x_h,x_ch)
int x_h;
int x_ch;
{
    REG int h;
    REG int ch;
    
    h = x_h;
    ch = x_ch & 0xff;			/* hack off like unsigned char */
    if (ch == tab) tabout(h,ch);	/* if tab, expand it */
    else
    {
	if ( ch < ' ' )
	{
            conout( h,'^' );
	    ch |= 0x40;
	}
    conout(h,ch);			/* output the character */
    }
}


/*
 * Auxillary Output.
 */
long
xauxout(ch)
int ch;
{
	bconout(run->p_uft[2]+3,ch);
}


/*
 * Printer Output.
 *
 * Explicitly returns the return code from the BIOS, because BIOS
 * returns 0 for success, !0 for parallel port timeout.
 * ('return' keyword added 5/88 AKP)
 */
long
xprtout(ch)
int ch;
{
	return bconout(run->p_uft[3]+3,ch);
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
getch(x_h)
int x_h;
{
	REG int h;
	REG long temp;

	h = x_h;
	if (kbchar[h])
	{
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
 * Direct Console Input;
 * no echoing.
 */
long
x7in()
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
conin(x_h)
int x_h;
{
    REG int h;
    REG long ch;

    h = x_h;
    conbrk(h,1);
    conout( h,(int)(ch = getch(h)) );
    return(ch);
}

/*
 * Console Input.
 */
long
xconin()
{
	return(conin(run->p_uft[0]+3));
}


/*
 * Console Input;
 * without echo.
 */
long
x8in()
{
	REG int h;
	REG long ch;

	h = run->p_uft[0]+3;
	conbrk(h,1);
	ch = getch(h);
	return(ch);
}


/*
 * Auxillary Input.
 */
long
xauxin()
{
	return(bconin(run->p_uft[2]+3));
}


/*
 * Raw Console Input and Output.
 */
long
rawconio(parm)
int parm;
{
REG	int i;

	if (parm == 0xFF)
	{
		i = run->p_uft[0]+3;
		return(constat(i) ? getch(i) : 0L);
	}
	bconout(run->p_uft[1]+3, parm);
}


/*
 * Print String;
 * to terminating null.
 */
long
xprt_line(p)
char *p;
{
	prt_line(run->p_uft[1]+3,p);
}


/*
 * Print line.
 */
prt_line(x_h,x_p)
int x_h;
char *x_p;
{
    REG int h;
    REG char *p;

    h = x_h;
    p = x_p;
    while( *p ) tabout( h, *p++ );
}


/***********************************************\
* 					        *
* Read Line, with editing and bounds checking.  *
* 					        *
\***********************************************/

/*
 * Newline, advance to appropriate column on device.
 */
newline(h,startcol)
REG int startcol;
REG int h;
{
    conout(h,cr);			/* go to new line */
    conout(h,lf);
    while(startcol)
    {
	conout(h,' ');
	startcol -= 1;		/* start output at starting column */
    }
}


/*
 * Backup one character;
 * yeah, they're assuming a video terminal.
 */
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
	if ( ch == tab )
	{
	    col += 8;
	    col &= ~7;		/* for tab, go to multiple of 8 */
	}
	else if ( !(ch & ~0x1f) ) col += 2;
				/* control chars put out 2 printable chars */
	else col += 1;
    }
    while (glbcolumn[h] > col)
    {
	conout(h,bs);		/* backspace until we get to proper column */
	conout(h,' ');
	conout(h,bs);
    }
    return(retlen);
}


/*
 * Read Line from Console.
 */
long
readline(x_p)	/* function 10 */
char *x_p;	/* max length, return length, buffer space */
{
	REG char *p;

	p = x_p;
	p[1] = cgets(run->p_uft[0]+3,(((int) p[0]) & 0x0ff),&p[2]);
}


/*
 * Read string.
 */
cgets(x_h,maxlen,buf)
int x_h;
int maxlen;
char *buf;
{
	char ch;
	int i;
	REG int h;
	REG int stcol;
	REG int retlen;

	h = x_h;
	stcol = glbcolumn[h];		/* set up starting column */
	for (retlen = 0; retlen < maxlen; )
	{
		conbrk(h,1);	/* use block mode to handle ^C and ^S/^Q */
		switch(ch = getch(h))
		{
			case cr:
			case lf: conout(h,cr); goto getout;
			case bs:
			case rub:
				retlen = backsp(h,buf,retlen,stcol);
				break;
/*			case ctrlc: warmboot(); /* never happens */
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
