/*
***************************     SUP.C      ******************************
*
* $Revision: 2.9 $	$Source: e:/tos/gd2\RCS\sup.c,v $
* =======================================================================
* $Author: apratt $ 	$Date: 1991/02/11 19:56:48 $    $Locker:  $
* =======================================================================
*
* $Log: sup.c,v $
* Revision 2.9  1991/02/11  19:56:48  apratt
* Checkin lest I lose work (again)
*
* Revision 2.8  91/01/23  17:08:56  apratt
* Changed d_left to d_child, d_right to d_next globally.  Removed o_thread,
* d_scan, m_fatofd, m_ofl, and d_dirfil.
* 
* Revision 2.7  91/01/23  14:30:36  apratt
* Trimmed logs & comments, changed to compile under GCC or (new) Alcyon.
* 
*************************************************************************
*/

#include "fs.h"

extern char kbchar[3];	/* # of elements in typeahead buffer */
extern long *remptr[3];	/* remove ptr from typeahead buffer */
extern long *insptr[3];	/* insert ptr into typeahead buffer */
extern long glbkbchar[3][KBBUFSZ];	/* typeahead buffer */

static long domediach();

long uptime;
int msec;
long errbuf[3];
char nday[] = 
	/*0 J  F  M  A  M  J  J  A  S  O  N  D  */
	{ 0,31,28,31,30,31,30,31,31,30,31,30,31 } ;


/*
 * Function-table entry
 */
#define FND struct _fnd
FND
{
	long	(*fncall)();
	int	fntyp;
} ;


/*
 * Function Not Implemented;
 * return "Invalid Function Number."
 */
long
ni()
{
	return(EINVFN);
}


/*
 * Return GEMDOS version number.
 */
long
xgetver()
{
	return(VERS_NUM);
}


/*
 * Function "jump" table.
 */
FND funcs[0x58] = {

	/* 0x00 */
	&x0term,0,

	/* console functions */
	/* on these functions, the 0x80 flag indicates std file used */
	/* 0x80 is std in, 0x81 is stdout, 0x82 is stdaux, 0x83 stdprn */
	/* Rawconio (fn 6) is special because it uses BOTH handles. */
	/* The code for this was broken, is fixed. (AKP) */

	/* 0x01 */	/* 0x02 */	/* 0x03 */
	&xconin,0x80,	&xtabout,0x81,	&xauxin,0x82,
	/* 0x04 */	/* 0x05 */	/* 0x06 */
	&xauxout,0x82,	&xprtout,0x83,	&rawconio,0x80,
	/* 0x07 */	/* 0x08 */	/* 0x09 */
	&x7in,0x80,	&x8in,0x80,	&xprt_line,0x81,
	/* 0x0A */	/* 0x0B */
	&readline,0x80,	&xconstat,0x80,

	/* disk functions */
	/* on these functions the 0x80 flag indicates whether a handle */
	/* is required, the low bits represent the parameter ordering, */
	/* as usual. */

			/* 0x0E */
	&ni,0,	&ni,0,	&xsetdrv,0, &ni,0,

	/* extended console functions */
	/* on these functions, the 0x80 flag indicates */
	/* std file used, as above */

	/* 0x10 */		/* 0x11 */
	&xconostat,0x81,	&xprtostat,0x83,
	/* 0x12 */		/* 0x13 */
	&xauxistat,0x82,	&xauxostat,0x82,

	/* 0x14 */	/* 0x15 */
	&xaddalt,1,	&ni,0,
	&ni,0, &ni,0,

		/* 0x19 */	/* 0x1A */
	&ni,0,	&xgetdrv,0,	&xsetdta,1, &ni,0,
	&ni,0, &ni,0, &ni,0, &ni,0,

	/* 0x20 */
	/* xgsps */
	&ni,0,		&ni,0, &ni,0, &ni,0,
	&ni,0, &ni,0, &ni,0, &ni,0,
	&ni,0, &ni,0,
	/* 0x2A */	/* 0x2B */	/* 0x2C */
	&xgetdate,0,	&xsetdate,0,	&xgettime,0,
	/* 0x2D */		/* 0x2F */
	&xsettime,0,	&ni,0,	&xgetdta,0,

	/* 0x30 */	/* 0x31 */
	&xgetver,0,	&xtermres,1, &ni,0, &ni,0,
			/* 0x36 */
	&ni,0, &ni,0,	&xgetfree,1, &ni,0,
		/* 0x39 */	/* 0x3A */	/* 0x3B */
	&ni,0,	&xmkdir,1,	&xrmdir,1,	&xchdir,1,

	/* xclose will handle its own redirection */

	/* 0x3C */	/* 0x3D */	/* 0x3E */
	&xcreat,1,	&xopen,1,	&xclose,0x0,
	/* 0x3F */
	&xread,0x82,

	/* 0x40 */	/* 0x41 */	/* 0x42 */
	&xwrite,0x82,	&xunlink,1,	&xlseek,0x81,
	/* 0x43 */	/* 0x44 */	/* 0x45 */	/* 0x46 */
	&xchmod,1, 	&xfmalloc,1,	&dup,0,		&xforce,0,
	/* 0x47 */	/* 0x48 */	/* 0x49 */
	&xgetdir,1,	&xmalloc,1,	&xmfree,1,
	/* 0x4A */	/* 0x4B */	/* 0x4C */
	&xsetblk,2,	&xexec,3,	&xterm,0, &ni,0,
	/* 0x4E */	/* 0x4F */
	&xsfirst,1,	&xsnext,0,

	/* 0x50 */
#ifdef XMEDIACH
	&xmediach,0,
#else
	&ni,0,
#endif
	&ni,0, &ni,0, &ni,0, &ni,0, &ni,0,
	/* 0x56 */	/* 0x57 */
	&xrename,2,	&xdatime,1
} ;

/*
 * Initialize GEMDOS;
 * called early-on by the BIOS.
 */
void
cinit()
{
REG	PD *r;
REG	int i;
REG	long *p;

	poolinit();
	xminit();
	r = run = &rootpd;

	/* clear the rootpd -- for compatibility with old ROMs which	*/
	/* got it from ospool (and therefore got it clear).		*/

	for (p = (long *)r, i = (sizeof(PD)/4); i; i--) {
		*p++ = 0;
	}

	for (i=0; i<NUMSTD; i++) r->p_uft[i] = biosdev[i];

	kbchar[0] = kbchar[1] = kbchar[2] = 0;
	remptr[0] = insptr[0] = &(glbkbchar[0][0]);
	remptr[1] = insptr[1] = &(glbkbchar[1][0]);
	remptr[2] = insptr[2] = &(glbkbchar[2][0]);
	callno = 0;
}


/*
 * Free a tree of DNDs.
 */
void
freetree(d)
char *d;
{
REG	int i;

	if (d->d_child) freetree(d->d_child);
	if (d->d_next) freetree(d->d_next);
	if (d->d_ofd) xmfreblk(d->d_ofd);
	for (i = 0; i < NCURDIR; i++)
		if (dirtbl[i] == d) dirtbl[i] = 0;
	xmfreblk(d);
}


/*
 * Free open files on a drive.
 *
 * This function DIDN'T WORK AT ALL: q_d (dev being changed) was ignored,
 * and local variable 'DMD *d' was uninitialized but compared against!
 */
void
offree(d)
DMD *d;
{
REG	int i;
REG	OFD *f;

    for (i=0; i < OPNFILES; i++)
	if ((((long) (f = sft[i].f_ofd)) > 0L) && (f->o_dmd == d))
	{
		xmfreblk(f);
		sft[i].f_ofd = 0;
		sft[i].f_own = 0;
		sft[i].f_use = 0;
	}
}


/*
 * Trap Interface;
 * called from assembly-language trap handler.
 *
 * DON'T USE REGISTER VARIABLES HERE BECAUSE IT'S THE TARGET OF A LONGJMP!
 */
long
osif(pw)
int *pw;
{
    char **pb,*pb2,*p;
    char ctmp;
    BCB *bx;
    int typ,h,i,fn;
    int num,max;
    long rc,numl;
    FND *f;

    callno++;			/* AKP: increment once per OS call */

restrt:
    fn = pw[0];

    if (fn > 0x57)
	return(EINVFN);

    if (rc = setjmp(errbuf))
    { /* hard error processing */
	/* is this a media change ? */
	if (rc == E_CHNG)
	{
	    if (rc = domediach(errdrv,rc)) return rc;
	    rwerr = 0;
	    errdrv = 0;
	    goto restrt;
	}

	/* else handle as hard error on disk for now		*/
	/* invalidate all buffers for that device! What the	*/
	/* hell kind of error recovery is that?! (AKP)		*/

	for (i = 0; i < 2; i++)
	    for (bx = bufl[i]; bx; bx = bx->b_link)
		if (bx->b_bufdrv == errdrv)
		    bx->b_bufdrv = -1;
	return(rc);
    }
    f = &funcs[fn];
    typ = f->fntyp;
    if (typ && fn && ((fn<12) || ((fn>=16) && (fn<=19)))) /* std funcs */
    {
	/* special handling for rawio (AKP) */
	if (fn == 6) {
	    typ = 0x80 + (pw[1] != 0xff);
	}
	h = run->p_uft[typ & 0x7f];
	if (h > 0)
	{ /* do std dev function from a file */
	    switch(fn)
	    {
		/* RAWIO by AKP: return 0 at EOF */
		case 6:	if (pw[1] != 0xff)
		        goto rawout;
		    if (xread(h,1L,&ctmp) == 1)
		        return ctmp;
		    else
		        return 0L;

		case 1:
		case 3:
		case 7:
		case 8: xread(h,1L,&ctmp);
		    return(ctmp);

		case 2:
		case 4:
		case 5:
/* FIXED 9/17/87 AKP: write the LOW byte of pw[1], not the high byte */
rawout:			xwrite(h,1L,((char *)&pw[1])+1);
		    return 0;

	    /* Cconws code by AKP: get string length, write	*/
	    /* it all at once, and return write error or -1	*/
	    /* for disk full.					*/

		case 9: {
		    long j, k;
		    pb2 = *((char **) &pw[1]);
		    for(k=0;pb2[k];k++) ;
		    if ((j = xwrite(h,k,pb2)) < 0)
		        return j;
		    else if (j < k) return -1;
		    else return 0;
		}

		case 10:pb2 = *((char **) &pw[1]);
		    max = *pb2++;
		    p = pb2 + 1;
		    for (i = 0; max--; i++,p++)
		    {
			if (xread(h,1L,p) == 1)
			{
			    oscall(0x40,1,1L,p);
			    if (*p == 0x0d)
			    { /* eat the lf */
			        xread(h,1L,&ctmp);
			        break;
			    }
			}
			else
			    break;
		    }
		    *pb2 = i;
		    return(0);

		case 11:
		case 18: {
		    /* input status on a file: AKP */
		    OFD *ofd, *getofd();
		    if ((ofd = getofd(h)) == 0)
		        return 0;   /* not ready */
		    if (ofd->o_bytnum != ofd->o_fileln)
		        return -1;  /* ready */
		    return 0;	/* not ready */
		}
		        
		case 16:
		case 17:
		case 19: return -1;
	    }
	}
	if ((fn == 10) || (fn == 9)) typ = 1;
	else typ = 0;
    }
    if (typ & 0x80)
    {
	if (typ == 0x81)
	    h = pw[3];
	else
	    h = pw[1];

	if (h >= NUMSTD)
	    numl = (long)sft[h-NUMSTD].f_ofd;
	else if (h >= 0)
	{
	    if ((h = run->p_uft[h]) > 0)
		numl = (long)sft[h-NUMSTD].f_ofd;
	    else
		numl = h;
	}
	else
	    numl = h;

	if (!numl)
	    return(EIHNDL); /* invalid handle: media change, etc */

	if (numl < 0L) /* con, aux, prn (-1,-2,-3) */
	{
	    num = numl;
	    pb = (char **) &pw[4];

	    /* only do things on read and write */
	    if (fn == 0x3f) /* read */
	    {
		/* prohibit reads of >32K because cgets can't do it */
		if (pw[2]) return(0);
		if (pw[3] == 1)
		{
		    **pb = conin(num+3);
		    return(1);
		}		
		return(cgets(num+3,pw[3],*pb));
	    }
	    if (fn == 0x40) /* write */
	    {
		/* before TOS 1.4, prohibited writes of >32K */
		pb2 = *pb; /* char * is buffer address */
		num += 3;

		/*
		 * write out a bunch of stuff,
		 * check for ^C ^S (etc) only
		 * on CON:
		 */
		numl = *(long *) &pw[2];
		while ( numl-- )
		    if (num == 2)
		        tabout(num, *pb2++);
		    else bconout(num, *pb2++);
		return(*(long *)&pw[2]);
	    }
	    return(0);
	}
    }
    rc = 0;
    if ((fn == 0x3d) || (fn == 0x3c))  /* open, create */
    {
	p = *((char **) &pw[1]);
	if (ncmps(5,p,"CON:") || ncmps(5,p,"con:")) rc = 0xFFFFL;
	else if (ncmps(5,p,"AUX:") || ncmps(5,p,"aux:")) rc = 0xFFFEL;
	else if (ncmps(5,p,"PRN:") || ncmps(5,p,"prn:")) rc = 0xFFFDL;
    }
    if (!rc)
    {
      typ &= 0x07f;
      switch(typ)
      {
        case 0: rc = (*f->fncall)(pw[1],pw[2]); break;
        case 1: rc = (*f->fncall)(pw[1],pw[2],pw[3],pw[4]); break;
        case 2: rc = (*f->fncall)(pw[1],pw[2],pw[3],pw[4],pw[5],pw[6]);
	break;
        case 3: rc = (*f->fncall)(pw[1],pw[2],pw[3],pw[4],
	     pw[5],pw[6],pw[7]);
	break;

      }
    }
    return(rc);
}


/*
 * Tick Handler;
 * called every so often by the BIOS's
 * timer interrupt handler.
 */
void
tikfrk(n)
int n;
{
REG int curmo;

	uptime += n;
	msec += n;
	if (msec >= 2000)
	{
		/* update time */

		msec -= 2000;
		time++;

		if ((time & 0x1F) != 30)
			return;

		time &= 0xFFE0;
		time += 0x0020;

		if ((time & 0x7E0) != (60 << 5))
			return;

		time &= 0xF81F;
		time += 0x0800;

		/* UNSIGNED below is for stupid old Alcyon compiler */
		if ((unsigned)(time & 0xF800) != (unsigned)(24 << 11))
			return;

		time = 0;

		/* update date */

		if ((date & 0x001F) == 31)
			goto datok;

		date++;			/* bump day */

		if ((date & 0x001F) <= 28)
			return;

		if ((curmo = (date >> 5) & 0x0F) == 2)
		{
		/* 2100 is the next non-leap year divisible by 4, so OK */
			if (!(date & 0x0600))
				if ((date & 0x001F) <= 29)
					return;
				else
					goto datok;
		}

		if ((date & 0x001F) <= nday[curmo])
			return;

datok:		date &= 0xFFE0;		/* bump month */
		date += 0x0021;

		if ((date & 0x01E0) <= (12 << 5))
			return;

		date &= 0xFE00;		/* bump year */
		date += 0x0221;
	}
}

/*
 * NEW FUNCTION 2/88, number 0x50:
 * "CAUSE MEDIA CHANGE" on a logical device.
 *
 * long Causemc(devno)
 * int devno;
 *
 * This function causes GEMDOS to forget everything it knew about
 * the logical device "devno" (where 0=A, 1=B, ...).  All open files
 * are closed, all buffers are invalidated (NOT written to the disk),
 * and an attempt is made to log the drive in again (i.e. read its BPB).
 *
 * The intended use is for programs which fool with the directory structure
 * of a logical device without calling GEMDOS, such as a disk compaction
 * program.  After modifying the disk, it can call Causemc to make
 * GEMDOS forget all its cached information about the device and re-read
 * the FAT and directory structure.
 *
 * RETURNS
 *	0 for success, or if the drive was unknown to begin with
 *		(and therefore there's nothing to forget).
 *
 *	ENSMEM (-39) or ERROR (-1) if the new media can't be logged in.
 *	EDRIVE (-46) if drv is not in the range 0-15.
 *
 */

static long endmediach();

#ifdef XMEDIACH
long
xmediach(drv)
int drv;
{
	if (drv > 15) return EDRIVE;
	* if the drive exists in the first place... *
	if (drvsel & (1 << drv)) {
		return domediach(drv,-1L);	* cause media change *
	}
	else {
		return endmediach(drv,-1L);
	}
}

#endif XMEDIACH

static long
domediach(drv,rc)
int drv;
long rc;
{
	int i;
	DND *dn;
	BCB *bx;
	extern char diruse[];

	/*
	 * Deallocate structures associated
	 * with the drive we just had a
	 * media-change on:
	 *	free up open files;
	 *	free up FAT ofd;
	 *	free up current-directory slots;
	 *	free up DMD;
	 *	free up tree of DNDs.
	 */
	dn = drvtbl[drv]->m_dtl;
	offree(drvtbl[drv]);

	for (i = 0; i < NCURDIR; ++i)
	    if (diruse[i] &&
		dirtbl[i]->d_drv == dn->d_drv)
	    {
		diruse[i] = 0;
		dirtbl[i] = (DND *)0;
	    }

	if (dn) freetree(dn);

	xmfreblk(drvtbl[drv]);
	drvtbl[drv] = 0;

	/*
	 * Invalidate buffers filled with
	 * stuff from that drive:
	 */
	for (i = 0; i < 2; i++)
		for (bx = bufl[i]; bx; bx = bx->b_link)
			if (bx->b_bufdrv == drv)
				bx->b_bufdrv = -1;

	/* then, in with the new */
	return endmediach(drv,rc);
}

static long
endmediach(drv,rc)
int drv;
long rc;
{
	REG BPB *b;

	b = (BPB *)getbpb(drv);

	if (!b)		/* wipe out drive bit */
	{
		drvsel &= ~(1 << drv);
		return(rc);
	}
	if ((log(b,drv))) return (ENSMEM);
	return 0;
}
