/*
***************************    FSPROC.C    ******************************
*
* $Revision: 2.13 $	$Source: fsproc.c,v $
* =======================================================================
* $Author: apratt $ 	$Date: 91/01/23 14:30:16 $    $Locker:  $
* =======================================================================
*
* $Log: fsproc.c,v $
* Revision 2.13  91/01/23  14:30:16  apratt
* Trimmed logs & comments, changed to compile under GCC or (new) Alcyon.
*
*************************************************************************
*/

#include "fs.h"

/* this is the power of 2 that the TPAsize field represents -- 17 for 128K */
#define FASTCLICK 17

PD *run;

/*
 * Common supervisor stack
 * for all processes.
 * <<< THIS MUST GO AWAY >>>
 */
int supstk[SUPSIZ];

long bakbuf[3];

/*
 *  Bounded String Compare;
 *  make sure `s' and `d' match in the first `n' characters.
 *
 */
int
ncmps(n, s, d)
int n;
char *s,*d;
{
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
volatile void
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
volatile void
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
volatile void
x0term()
{
  xterm(0);
}


/*
 *  Terminate a process;
 *    close standard handles;
 *    close all files the process owns;
 *    release current directory slots the process owns;
 *    release any chunks of memory the process owns.
 *
 */
void
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
 * Mode 7 is new as of 5/90: just like mode 5, but the first argument 
 * is the hflags value to use for the child.  For mode 5, it's zero.
 *
 * Here's a breakdown of what this routine does:
 *
	catch longjmp so xpgmld read errors get cleaned up

	(0, 3) open file, read header to set hflags and sizes
	(7) set hflags from first arg, zero sizes
	(other) hflags = 0, zero sizes

	(0, 3, 5, 7) 
		allocate & copy environment
		allocate TPA
		set TPA start, TPA size, default DTA, env, hflags, args
		inherit files, current directories

	(0, 3)
		load program, set basepage start&size fields

	(0, 4, 6)
		Set parent pointer, stack top
		Set up gouser frame: reg set, return PC, SR, SSP
		Set basepage areg copies of a7 & a6 to frame end
		set basepage areg copies of a5=dbase, a4=bbase
		Set run to the new basepage
		(0, 6) Change ownership to child
		gouser();

	(3, 5, 7) return basepage address

 * This is probably wrong in at least one respect: inheriting files
 * and directories should happen when the child is being started, not
 * when it's created.  New modes should fix this.
 */

#define pushword(p,w) ((*(--((short *)(p)))) = (w))
#define pushlong(p,l) ((*(--((long *)(p)))) = (l))

long
xexec(mode,s,t,v)
int mode;		/* function */
char *s;		/* file name (0, 3), hflags value (7) or dummy */
char *t;		/* arg tail (0, 3, 5, 7), &psp (4,6) */
char *v;		/* enviroment string (0, 3, 5, 7) */
{	
	PD *pdp;
	char *b,*e,*env;
	int h,i,j;
	long rc,max;
	char *sp;
	long lx;	/* error code for xopen */
	int fh;		/* handle for open file (closed by xpgmld) */
	PRG prg;	/* the PRG header, passed to xpgmld */
	int use;	/* type of RAM we decided to use for TPA (0 or 1) */
	long fastmax, slowmax, minfast;

	pdp = NULPTR;
	env = NULPTR;
	fh = 0;

	if (mode && ((mode < 3) || (mode > MAXMODE)))
		return(EINVFN);

	xmovs(sizeof(errbuf),errbuf,bakbuf);

	if (rc = setjmp(errbuf))
	{
		/* see if we allocated memory in a previous incarnation */

		if (fh) xclose(fh);
		if (pdp) xmfree(pdp);
		if (env) xmfree(env);

		xmovs(sizeof(errbuf),bakbuf,errbuf);
		longjmp(errbuf,rc);
	}

	if ((mode == 0) || (mode == 3)) {
	    if ((fh = lx = xopen(s,0)) < 0) return (lx);
	    lx = xread(fh,(long)sizeof(prg),&prg);
	    if ((lx != sizeof(prg)) || (prg.g_magic != P_MAGIC)) {
		xclose(fh);
		if (lx < 0) return lx;
		else return EPLFMT;
	    }
	}
	else {
	    /* Set up prg for the modes which don't see a PRG file. */
	    /* Mode 7 has hflags as its first arg; others use 0. */

	    if (mode == 7) prg.g_hflags = (long)s;
	    else prg.g_hflags = 0;

	    /* both create PSP calls will use these fields */
	    prg.g_tsize = prg.g_dsize = prg.g_bsize = 0;
	}

	/* will we need memory and a psp ? */
	if ((mode != 4) && (mode != 6)) {
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
		if (mode != 5 && mode != 7) {
		    for (e=s; *e++; j++) ;	/* j = strlen(s) */
		    j++;			/*        ... +1 */
		}
#endif PRGNAME

		if ((i+j) & 1)
			j += 1;

		/* select eligibility of memory for environment */
		if (prg.g_hflags & P_RAMEXEC) h = 3;
		else h = 0;

		if (!(e = env = (char *)xfmalloc((long)(i+j+2),h)))
			return (ENSMEM);

		/* now copy it */

		while (i--)
			*e++ = *v++;

#ifdef PRGNAME
		if (mode != 5 && mode != 7) {
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

		pdp = (PD *)xfmalloc(max,use);

		/*
		 * setup basepage (PD/PSP)
		 */
		clear(pdp,pdp+1);	/* clear 0x100 bytes */

		pdp->p_lowtpa = pdp;
		pdp->p_hitpa = ((char *) pdp) + max;

		/* default p_xdta is p_cmdlin */
		pdp->p_xdta = (DTA *)pdp->p_cmdlin;
		pdp->p_hflags = prg.g_hflags;
		pdp->p_env = env;

		/* inherit standard files */
		for (i = 0; i < NUMSTD; i++)
			if ((h = run->p_uft[i]) > 0)
				ixforce(i,run->p_uft[i],pdp);
			else
				pdp->p_uft[i] = h;

		/* and current directory set */
		for (i = 0; i < 16; i++)
			ixdirdup(i,run->p_curdir[i],pdp);

		/* and current drive */
		pdp->p_curdrv = run->p_curdrv;

		/* copy tail */
		b = pdp->p_cmdlin;
		for (i = 0; (i < 0x7d) && (*t); i++)
			*b++ = *t++;
		*b++ = 0;
	}
	else {
		/* set pdp in those modes where it's an argument */
		pdp = (PD *)t;
	}

	/* for 3 or 0, need to load, supply baspage containing: */
	/* 	tpa limits, filled in with start addrs,lens */

	if ((mode == 0) || (mode == 3)) {
		if (rc = xpgmld(&prg,fh,pdp))
		{
			xclose(fh);
			ixterm(pdp);
			return(rc);
		}
		xclose(fh);
	}

	if ((mode == 0) || (mode == 4) || (mode == 6))
	{
		pdp->p_parent = run;
		sp = pdp->p_hitpa;
		pushlong(sp,(long)pdp);
		pushlong(sp,0L);

		 /* 10 regs (40 bytes) of zeroes  */

		i = 10;
		do { pushlong(sp,0L); } while (--i);

		pushlong(sp,pdp->p_tbase); /* text start */

		/********************************************************
		 *							*
		 * important: make sure child is started with IPL=0!	*
		 * this is now considered "guaranteed" because of the	*
		 * HBLANK trick used by debuggers (etc.).		*
		 *							*
		 ********************************************************/

		pushword(sp,0);		/* startup status reg */

		/* initial supervisor stack for this process */
		pushlong(sp,(long)(&supstk[SUPSIZ]));

		/* areg[N-3] is aN */
		pdp->p_areg[6-3] = pdp->p_areg[7-3] = (long)sp;
		pdp->p_areg[5-3] = pdp->p_dbase;
		pdp->p_areg[4-3] = pdp->p_bbase;

		if (mode == 0 || mode == 6) {
		    xmchown(pdp,pdp);
		    xmchown(pdp->p_env,pdp);
		}
		run = pdp;

		gouser();
	}

	/* sub-func 3 and 5 return here */

	return((long)pdp);
}

/*
 *  Load executable file
 *  The file is open; its handle is h; its header is in prg.
 *  Its read pointer is at the end of the header.
 *  This procedure doesn't close the file.
 */
long
xpgmld(prg, h, lp)
PRG *prg;
int h;
PD *lp;				/* -> basepage */
{
  REG char *r;
  REG char *bssadr;
  REG int n;
  REG long *cp;
  REG long i;
  long relst;		/* relocation start */
  char *codbas;		/* start of text segment */
  long flen,n0,bsslen,tpasiz;

  flen = prg->g_tsize + prg->g_dsize;

  tpasiz = ((long)lp->p_hitpa - (long)lp->p_lowtpa) - 0x100;

  codbas = (char *)(lp+1);
  bssadr = (char *)(codbas + flen);
  bsslen = tpasiz - flen;
  
  /*
   *  Check to see if there's enough memory to contain the BSS;
   *  Fill in basepage with text+data+bss start-address and size information.
   */
  if (bsslen < prg->g_bsize) {
    return(ENSMEM);
  }

  lp->p_tbase = (long)codbas;
  lp->p_tlen = prg->g_tsize;

  lp->p_dbase = (long)codbas+prg->g_tsize;
  lp->p_dlen = prg->g_dsize;

  lp->p_bbase = (long)bssadr;
  lp->p_blen = prg->g_bsize;

  /*
   *  Read text+data segments,
   *  if the file is absolute, don't do any fixups. (AKP: but do zero BSS)
   */
  xread(h, flen, codbas);
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
  cp = (long *)(codbas + relst);
  if (((char *)cp < codbas) || ((char *)cp >= bssadr)) {
    return(EPLFMT);
  }

  /* do the first fixup */
  *cp += (long)codbas;

  /*
   *  Do fixups until we run out.
   */
  do
    {
      /*
       *  Read another chunk of relocation bytes
       */
      n0 = xread(h, bsslen, bssadr);
      
      for (i = n0, r = bssadr; i ; i--) {
	  /*
	   *  if fixup byte is:
	   *	0    end of relocation list
	   *    1    add 0xfe to cp and get next fixup byte
	   *    xx   add to cp, do fixup there, and get next fixup byte
	   *
	   *  (`r' points at reloc item, `cp' is code pointer)
	   */
	  if ((n = *r++) == 0)
	    goto zrobss;	/* end of fixup list */

	  if ((n &= 0x00ff) == 1)
	    ((char *)cp) += 0x0fe;	/* bump cp and get next byte */
	  else {
	      ((char *)cp) += n;	/* bump cp and do fixup */

	      /* If out of range, indicate an error */
	      if (((char *)cp < codbas) || ((char *)cp >= bssadr)) 
		    return(EPLFMT);

	      /* do the fixup */
	      *cp += (long)codbas;
	  }
      }
    } while (n0 == bsslen);
  
 zrobss:

  /* if lowest bit of hflags is set, clear only declared BSS */
  if (prg->g_hflags & P_NOCLRBSS) clear(bssadr,bssadr+prg->g_bsize);
  else clear(bssadr,bssadr+bsslen);
  
  return OK;
}
