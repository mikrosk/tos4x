/*
***************************    FSPROC.C    ******************************
*
* $Revision: 2.12 $	$Source: /u2/MRS/osrevisions/gemdos/fsproc.c,v $
* =======================================================================
* $Author: apratt $ 	$Date: 90/08/03 13:41:51 $    $Locker:  $
* =======================================================================
*
* $Log: fsproc.c,v $
* Revision 2.12  90/08/03  13:41:51  apratt
* TTOS FINAL RELEASE
* 
* Revision 2.11  90/07/19  18:34:53  apratt
* Changed to use hi 4 bits of hflags for minalt, not a field in the
* parent's basepage.  Removed xminalt procedure as it's no longer used.
* 
* Revision 2.10  90/05/21  12:51:40  apratt
* Added code to select eligibility of the environment string: it was
* possible for an alt-RAM eligible program to fail because there wasn't
* enough ST RAM for its env string.
* 
* Old Alcyon doesn't implement unsigned long, so I have to code it
* by hand (in Pminalt).
* 
* Revision 2.9  90/05/08  12:19:44  apratt
* Added Pexec mode 7: just like mode 5 (create basepage), but the
* first arg is the hflags value to use.
* 
* Revision 2.8  90/04/24  11:00:03  apratt
* Removed knowledge of memory data structures; this code now calls 
* xfmalloc, xmchown, xmunhook and xmfreeall.  Also added xminalt (Pminalt),
* for setting the minfast field of the basepage.
* 
* Revision 2.7  89/12/27  14:43:06  apratt
* Split code which handles the second discontiguous memory block out
* to be compiled only ifdef FASTRAM.
* 
* Revision 2.6  89/08/18  17:25:54  apratt
* Fixed an oops in ixterm and initialized g_hflags in xexec for modes
* other than 0 and 3.
* 
* Revision 2.5  89/07/31  11:38:08  apratt
* The log field of this header mysteriously vanished... Fixed now.
* 
* Revision 2.4  89/07/18  14:07:47  apratt
* Added p_hflags handling for BSS clearing and fast RAM TPA's.
*
* Revision 2.3  89/04/17  17:14:49  kbad
* YA header change
* 
* Revision 2.2  89/03/29  15:17:20  apratt
* Added feature: the long at offset $16 in the PRG header is a bitmap
* of flags.  The lowest-order bit means "don't bother to clear my heap"
* when it is set.
* 
* Revision 2.1  89/02/21  17:20:40  kbad
* *** TOS 1.4  FINAL RELEASE VERSION ***
* 
* Revision 1.5  88/09/01  15:58:52  apratt
* added new Pexec mode 6, which is just like mode 4 except that
* it works: it changes the ownership of the memory of the child
* to the child's PID before starting it. Uses xmchown in mem.c.
* 
* Revision 1.4  88/08/16  17:46:08  apratt
* Add check: don't decrement diruse[i] past zero.  This blocks, but
* does not fix, the diruse mismanagement.
* 
* Revision 1.3  88/06/30  13:11:25  apratt
* Added declaration of s1 ifdef PRGNAME in xexec().
* No change if not PRGNAME.
* 
* Revision 1.2  88/06/13  15:06:33  apratt
* Header style change
* 
* Revision 1.1  88/04/26  14:48:25  apratt
* Version used 4/22/88 to make test ROMs
* 
*************************************************************************
*/

/* fsproc.c */

/****************************************************************************\
* 									     *
* GEMDOS Process Management						     *
* (C)1986 Atari Corp.							     *
* 									     *
* ---- Edit history (reverse order, please): ------------------------------  *
* 									     *
* 23-Mar-1988 akp	Attribute in Fsfirst in pexec changed to find all    *
*			files, incl. hidden & system files.		     *
* 19-Feb-1988 akp	Backed out file name after environment string.  Now  *
*			keyed on #defining PRGNAME			     *
* 18-Feb-1988 akp	Lintified (xpgmld returns long).		     *
* 03-Feb-1988 akp	Changed some register declarations.		     *
*			Changed name to "fsproc.c"			     *
* 03-Dec-1987 akp	Added call to clksync to set BIOS clock to GEMDOS's  *
*			at process-terminate time.			     *
* 13-Nov-1987 akp	Added copying of file name after environment's	     *
*			trailing null, a la MSDOS 3.x: word of $0001, then   *
*			the full pathname of the file that was loaded.       *
* 03-Nov-1987 akp	Backed out clrmode, because WRITE depends on heap 0. *
* 02-Nov-1987 akp	Added #include fsdecl.h to declare xread long.	     *
*			This fixes 32K limit on reloc info in .PRG files.    *
* 27-Oct-1987 akp	Added clrmode flag set by negative function codes    *
*			to xexec: -1 means clear only BSS, -2 means clear    *
*			BSS plus 1/4 heap, -3 means clear all (default).     *
*			Also, changed longjmp handling: now frees memory     *
*			if it was allocated, regardless of what error.	     *
*			Hopefully, this will fix read-error-on-PRG bombs.    *
* 21-Oct-1987 akp	Backed out clear change: now clears BSS+heap 	     *
*			as before.					     *
* 13-Oct-1987 akp	Fixed xtermres to call xunhook.			     *
* 29-Sep-1987 akp	Split process routines out from mem.c to here.	     *
* 17-Sep-1987 akp	Changed xpgmld to clear only the declared BSS,       *
*			not the whole TPA, for speed on Megas.               *
*			Also fixed xpgmld not to leave files open.	     *
* 17-Jan-1986 lmd	Commented and prettified from Digital Research	     *
* 			source code.					     *
* 									     *
\****************************************************************************/
#include "fs.h"
#include "fsdecl.h"
#include "gemerror.h"

extern FTAB sft[];
extern long trap13(), setjmp();

/* this is the power of 2 that the TPAsize field represents -- 17 for 128K */
#define FASTCLICK 17

PD *run;

/*
 * Common supervisor stack
 * for all processes.
 * <<< THIS MUST GO AWAY >>>
 */
int supstk[SUPSIZ];

extern long errbuf[3];
long bakbuf[3];
extern MPB pmd;

extern char diruse[];


/*
 *  Bounded String Compare;
 *  make sure `s' and `d' match in the first `n' characters.
 *
 */
ncmps(x_n, x_s, x_d)
int x_n;
char *x_s,*x_d;
{
  REG int n;
  REG char *s;
  REG char *d;

  n = x_n; s = x_s; d = x_d;

  while (n--)
    if (*s++ != *d++)
      return 0;
  
  return 1;
}


/*
 *  Terminate and Stay Resident;
 *  make memory the process allocated "invisible" and
 *  then do a normal terminate.
 *
 */
long
xtermres(blkln, rc)
     int rc;			/* return code */
     long blkln;		/* amount to keep */
{
      xsetblk(0, run, blkln);	/* shrink main block */

  /*
   *  Unhook allocated blocks this process owns
   */
  xmunhook(run);	/* AKP extension */
  xterm(rc);
}	


/*
 *  Terminate the current process
 *
 */
long
xterm(rc)
     unsigned int rc;		/* return code */
{
  REG	PD *r;

  dojmp(trap13(5,0x102,-1L));	/* call terminate vector */
  
  clksync();			/* sync with BIOS clock */
  run = (r = run)->p_parent;
  ixterm(r);
  run->p_dreg[0] = rc;		/* stuff return code */
  gouser();			/* resume parent process */
}


/*
 *  Terminate process with return code of zero
 *
 */
long
x0term()
{
  return xterm(0);
}


/*
 *  Terminate a process;
 *    close standard handles;
 *    close all files the process owns;
 *    release current directory slots the process owns;
 *    release any chunks of memory the process owns.
 *
 */
ixterm(r)
PD *r;			/* -> basepage */
{
  REG	int h;
  REG	int i;
  
  /*
   *  Close standard handles (that are alive)
   */
  for (i = 0; i < NUMSTD; i++)
    if ((h = r->p_uft[i]) > 0)
      xclose(h);
  
  /*
   *  Close handles in the SFT this process has open
   */
  for (i = 0; i < OPNFILES; i++)
    if (r == sft[i].f_own)
      xclose(i+NUMSTD);
  
  /*
   *  Decrement diruse[] slots for directories
   *  used by the process:
   */
  for (i = 0; i < 16; ++i)
    if ((h = r->p_curdir[i]))
      if (diruse[h]) --diruse[h];   /* don't decr past zero */
  
  /*
   *  Free chunks of TPA the process allocated
   *  (including the basepage)
   */
  xmfreeall(r);
}


/*	Function 0x4B	p_exec

	Last modified	SCC	24 May 85
*/

#define MAXMODE 7

/* flag = 0: load&go, 3:load/nogo, 4:justgo, 5:create psp */
/* load&go(cmdlin,cmdtail), load/nogo(cmdlin,cmdtail), justgo(psp) */
/* create psp - user receives a memory partition */

/*
 * Load/Execute a Process
 *
 *	flag   function
 *	 0	load and go, Pexec(0,cmdline,cmdtail,env)
 *	 3	load, don't go, Pexec(3,cmdline,cmdtail,env)
 *	 4	just go, Pexec(4,0L,&psp,0L)
 *	 5	create PSP, Pexec(5,dummy,cmdtail,env)
 *	 6	just go, but also change ownership to the child
 *	 7	create PSP, but first arg is hflags (7,hflags,cmdtail,env)
 *
 * Note: the child should always be started with IPL=0 so you get an
 * HBLANK interrupt just before the child starts.  This is now considered
 * "guaranteed" so debuggers (etc.) can get a foot in the door before
 * the process starts.
 *
 * Note: Don't use register variables here because of setjmp.
 *
 * Pexec mode 6 added 8/30/88 to be what mode 4 was intended to
 * be but wasn't: it changes the ownership of the TPA and environment
 * of the child, and changes _run to the child, so when the child
 * terminates its memory gets freed.  Mode 4 doesn't do this.
 * 
 * This routine is pretty bad about setjmp etc.: it pushes a jmp_buf
 * frame so errors in reading the file are recovered, but when it
 * returns it doesn't pop the frame, so a later longjmp will blow up.
 * Since there can't be a later longjmp in the current GEMDOS this is OK.
 *
 * Mode 7 is new as of 5/90: just like mode 5, but the first argument 
 * is the hflags value to use for the child.  For mode 5, it's zero.
 */

long
xexec(flg,s,t,v)
int flg;		/* function */
char *s;		/* command, &psp */
char *t;		/* tail */
char *v;		/* enviroment string */
{	
	long *p;
	char *b,*e,*env;
	int h,i,j;
	long rc,max;
	long *spl;
	int *spw;
	long xpgmld();
	long hflags;
	long lx;	/* error code for xopen */
	int fh;		/* handle for open file (closed by xpgmld) */
	PRG prg;	/* the PRG header, passed to xpgmld */
	int use;	/* type of RAM we decided to use for TPA (0 or 1) */
	long fastmax, slowmax, minfast;

	p = env = 0;
	fh = 0;

	if (flg && ((flg < 3) || (flg > MAXMODE)))
		return(EINVFN);

	xmovs(sizeof(errbuf),errbuf,bakbuf);

	if (rc = setjmp(errbuf))
	{
		/* AKP: next two lines removed	*/
		/* if (rc != E_CHNG)		*/
		/*	longjmp(bakbuf,rc);	*/

		/* see if we allocated memory in a previous incarnation */

		if (fh) xclose(fh);
		if (p) xmfree(p);
		if (env) xmfree(env);

		longjmp(bakbuf,rc);
	}

	/* new code 6/89 AKP: open file & read in header now */
	/* so we can decide what kind of memory to allocate */
	if ((flg == 0) || (flg == 3)) {
	    if ((fh = lx = xopen(s,0)) < 0) return (lx);
	    lx = xread(fh,(long)sizeof(prg),&prg);
	    if ((lx != sizeof(prg)) || (prg.g_magic != 0x601a)) {
		xclose(fh);
		if (lx < 0) return lx;
		else return EPLFMT;
	    }
	}
	else {
	    /* Set up prg for the modes which don't see a PRG file. */
	    /* Mode 7 has hflags as its first arg; others use 0. */

	    if (flg == 7) prg.g_hflags = (long)s;
	    else prg.g_hflags = 0;

	    /* both create PSP calls will use these fields */
	    prg.g_tsize = prg.g_dsize = prg.g_bsize = 0;
	}

	/* will we need memory and a psp ? */
	if ((flg != 4) && (flg != 6)) {
		/* first, allocate and copy the environment */

		if (!v)
			v = run->p_env;
		for (e = v, i = 0; ; i++)
			if (!(*e++))
				if (!(*e++))
					break;
				else
					i++;	/* add an extra */

		i += 2;
		j = 0;
#ifdef PRGNAME
		if (flg != 5 && flg != 7) {
		    for (e=s; *e++; j++) ;	/* j = strlen(s) */
		    j++;			/*        ... +1 */
		}
#endif PRGNAME

		if ((i+j) & 1)
			j += 1;

		/* select eligibility of memory for environment */
		if (prg.g_hflags & P_RAMEXEC) h = 3;
		else h = 0;

		if (!(e = env = xfmalloc((long)(i+j+2),h)))
			return (ENSMEM);

		/* now copy it */

		while (i--)
			*e++ = *v++;

#ifdef PRGNAME
		if (flg != 5 && flg != 7) {
		    /* AKP: copy name after env */
		    while (*e++ = *s++) ;
		}
#endif PRGNAME

		/* get largest memory partition available */
		/* in the appropriate kind(s) of memory */

		if (prg.g_hflags & P_RAMEXEC) {
		    /* try for fast RAM first */
		    minfast = (((prg.g_hflags & 0xf0000000L) >> 28) & 0xfL);
		    minfast = (minfast+1) << FASTCLICK;
		    minfast += prg.g_tsize + prg.g_dsize + prg.g_bsize;

		    fastmax = xfmalloc(-1L,1);
		    slowmax = xfmalloc(-1L,0);
		    if (fastmax > slowmax || fastmax > minfast) {
			/* enough fast RAM to use; use it */
			max = fastmax;
			use = 1;
		    }
		    else {
			max = slowmax;
			use = 0;
		    }
	        }
	        else {
		    use = 0;
		    max = xfmalloc(-1L,0);
		}

		/*
		 * Ensure room for the basepage + program + some extra
		 * (in this case, "some extra" is 2K)
		 */
		if (max < (prg.g_tsize + prg.g_dsize + prg.g_bsize + 0x900L))
		{
			xmfree(env);
			/* should pop the error-stack frame */
			return(ENSMEM);
		}

		p = xfmalloc(max,use);
		if (flg == 0) {
			xmchown(env,p);
			xmchown(p,p);
		}

		p[0] = p;
		p[1] = ((long) p) + max;

		/*
		 * setup basepage (PD/PSP)
		 */
		for (i = 0, b = p+2; i < 0x100; i++)
			*b++ = 0;

		p[8] = &p[0x20];	/* default p_xdta is p_cmdlin */
		p[10] = prg.g_hflags;
		p[11] = env;

		/* inherit standard files */
		for (i = 0; i < NUMSTD; i++)
			if ((h = run->p_uft[i]) > 0)
				ixforce(i,run->p_uft[i],(PD *)p);
			else
				p->p_uft[i] = h;

		/* and current directory set */
		for (i = 0; i < 16; i++)
			ixdirdup(i,run->p_curdir[i],(PD *)p);

		/* and current drive */
		p->p_curdrv = run->p_curdrv;

		/* copy tail */
		b = p + 0x20;
		for (i = 0; (i < 0x7d) && (*t); i++)
			*b++ = *t++;
		*b++ = 0;
		t = p;
	}

	/* for 3 or 0, need to load, supply baspage containing: */
	/* 	tpa limits, filled in with start addrs,lens */

	if ((flg == 0) || (flg == 3)) {
		if (rc = xpgmld(&prg,fh,t))
		{
			ixterm((PD *)t);
			return(rc);
		}
	}

	if ((flg == 0) || (flg == 4) || (flg == 6))
	{
		p = t;
		p->p_parent = run;
		spl = p->p_hitpa;
		*--spl = p;
		*--spl = 0; /* bogus retadd */

		 /* 10 regs (40 bytes) of zeroes  */

		for (i = 0; i < 10; i++)
			*--spl = 0;

		*--spl = p->p_tbase; /* text start */
		spw = (int *) spl;

		/********************************************************
		 *							*
		 * important: make sure child is started with IPL=0!	*
		 * this is now considered "guaranteed" because of the	*
		 * HBLANK trick used by debuggers (etc.).		*
		 *							*
		 ********************************************************/

		*--spw = 0; /* startup status reg */
		spl = (long *) spw;

		/* initial supervisor stack for this process */
		*--spl = &supstk[SUPSIZ];

		p->p_areg[6-3] = p->p_areg[7-3] = spl;
		p->p_areg[5-3] = p->p_dbase;
		p->p_areg[4-3] = p->p_bbase;
		run = p;

		/* new Pexec mode by AKP 8/30/88: change	*/
		/* ownership of child's memory so it owns it.	*/
		if (flg == 6) {
		    xmchown(run,run);
		    xmchown(run->p_env,run);
		}
		gouser();
	}

	/* sub-func 3 and 5 return here */

	return(t);
}

/*
 *  Load executable file
 *
 */
long
xpgmld(prg, h, x_lp)
PRG *prg;
int h;
long *x_lp;			/* -> basepage */
{
  REG long *lp;
  REG char *r;
  REG char *bssadr;
  REG int n;
  REG long cp;
  REG long i;

  long *p,lp0,lpx,flen,lx,codbas,relst,n0,bsslen,tpasiz;

  lp = x_lp;

  flen = prg->g_tsize + prg->g_dsize;
  p = lp + 2;
  tpasiz = lp[1] - lp[0] - 0x100;
  lp += 0x40;
  lp0 = lpx = lp;
  codbas = lp0;
  bssadr = (char *) (lp0 + flen);
  bsslen = tpasiz - flen;
  
  /*
   *  Check to see if there's enough memory to contain the BSS;
   *  Fill in basepage with text+data+bss start-address and size information.
   */
  if (bsslen < prg->g_bsize) {
    xclose(h);
    return(ENSMEM);
  }

  *p++ = lpx;
  *p++ = prg->g_tsize;
  lpx += prg->g_tsize;

  *p++ = lpx;
  *p++ = prg->g_dsize;
  lpx += prg->g_dsize;

  *p++ = lpx;
  *p++ = prg->g_bsize;
  lpx += prg->g_bsize;

  /*
   *  Read text+data segments,
   *  if the file is absolute, don't do any fixups. (AKP: but do zero BSS)
   */
  xread(h, flen, lp0);
  if (prg->g_absflg)
    goto zrobss;    /* AKP */
  
  /*
   *  Seek to start of fixup information (past symbols);
   *  read offset of first fixup;
   *  if the offset is zero, don't fix anything up.
   */
  xlseek(flen + prg->g_ssize + 0x1c, h, 0);
  xread(h, 4L, &relst);
  if (!relst)
    goto zrobss;

  /*
   *  Compute address of first fixup;
   *  if it's out of range (of text and data) then return an error;
   *  do the first fixup.
   */
  cp = codbas + relst;
  if ((cp < codbas) || (cp >= bssadr)) {
    xclose(h);
    return(EPLFMT);
  }
  *((long *)cp) += codbas;

  /*
   *  Do fixups until we run out.
   */
  do
    {
      /*
       *  If out of range, indicate an error
       */
      if ((cp < codbas) || (cp >= bssadr)) {
	xclose(h);
	return(EPLFMT);
      }
      
      /*
       *  Read another chunk of relocation bytes
       */
      n0 = xread(h, bsslen, bssadr);
      
      for (i = n0, r = bssadr; i ; i--)
	{
	  /*
	   *  if fixup byte is:
	   *	0    end of relocation list
	   *    1    add 0xfe to cp and get next fixup byte
	   *    xx   add to cp, do fixup there, and get next fixup byte
	   *
	   *  (`r' points at reloc item, `cp' is code pointer)
	   */
	  if (!(n = *r++))
	    goto zrobss;	/* end of fixup list */
	  
	  if ((n &= 0x00ff) == 1)
	    cp += 0x0fe;	/* bump cp and get next byte */
	  else
	    {
	      cp += n;		/* bump cp and do fixup */
	      *((long *) cp) += codbas;
	    }
	}
    } while (n0 == bsslen);
  
  /*
   *  Clear BSS (very quickly)
   *
   * New feature as of TOS 1.4: the long at offset $16 in the PRG header
   * is a bitmap of flags: the lowest-order bit means "don't bother to
   * clear my heap" when it's set.
   */

 zrobss:

  /* if lowest bit of hflags is set, clear only declared BSS */
  if (prg->g_hflags & P_NOCLRBSS) clear(bssadr,bssadr+prg->g_bsize);
  else clear(bssadr,bssadr+bsslen);
  xclose(h);
  
  return OK;
}

