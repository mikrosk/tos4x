/*
***************************    FSPROC.C    ******************************
*
* $Revision: 2.21 $	$Source: e:/tos/gd2\RCS\fsproc.c,v $
* =======================================================================
* $Author: apratt $ 	$Date: 1991/11/20 19:44:04 $    $Locker:  $
* =======================================================================
*
* $Log: fsproc.c,v $
* Revision 2.21  1991/11/20  19:44:04  apratt
* Memory protection, first cut (no workee yet)
*
* Revision 2.20  1991/06/20  17:12:50  apratt
* updates for new DB
*
* Revision 2.19  1991/06/18  17:52:02  apratt
* Updated to DB release 3 (new print)
*
* Revision 2.18  1991/05/03  00:17:02  apratt
* Took out xmfree calls on the env and basepage of a process: if the
* terminating process doesn't own its env or basepage then they should
* not be freed.
*
* Revision 2.17  1991/04/30  12:12:38  apratt
* Converted DBCMDs to new infix DB style
*
* Revision 2.16  1991/03/28  17:39:36  apratt
* THIS VERSION BOOTS! DESKTOP OPERATIONS WORK!
*
* Revision 2.15  1991/02/15  18:45:40  apratt
* CI at the end of the week...
*
* Revision 2.14  1991/02/11  19:56:48  apratt
* Checkin lest I lose work (again)
*
* Revision 2.13  91/01/23  14:30:16  apratt
* Trimmed logs & comments, changed to compile under GCC or (new) Alcyon.
* 
*************************************************************************
*/

#include "fs.h"

/* this is the power of 2 that the TPAsize field represents -- 17 for 128K */
#define FASTCLICK 17

PD *run;
int mem_initted;	/* if FALSE then xexec sets TRUE & calls init_t2 */

/*
 * Common supervisor stack
 * for all processes.
 * <<< THIS MUST GO AWAY >>>
 */
int supstk[SUPSIZ];

jmp_buf bakbuf;

/*
 *  Terminate and Stay Resident;
 *  make memory the process allocated "invisible" and
 *  then do a normal terminate.
 *
 */
void
xtermres(blkln, rc)
     int rc;			/* return code */
     long blkln;		/* amount to keep */
{
    DBCMD(1,"print xtermres len: -x (lpeek (`a6 + 8)) rc: -x (wpeek (`a6 + c));_c");

    xmshrink(0, run, blkln);	/* shrink main block */

    /*
     *  Unhook allocated blocks this process owns
     */
    xmunhook(run);
    xterm(rc);
}	


/*
 *  Terminate the current process
 *
 */
void
xterm(rc)
unsigned int rc;
{
    REG	PD *r;

    DBCMD(1,"print xterm rc: -x (wpeek (`a6 + 8));_c");

    dojmp(trap13(5,0x102,-1L));		/* call terminate vector */

    clksync();				/* sync with BIOS clock */
    r = run;
    run = run->p_parent;		/* change run first */
    ixterm(r);				/* close all files, free mem */
    run->p_dreg[0] = rc;		/* stuff return code */
    gouser();				/* resume parent process */
}


/*
 *  Terminate process with return code of zero
 */
void
x0term()
{
    DBCMD(1,"print xterm0;_c");
    xterm(0);
}


/*
 *  Terminate a process;
 *    close all handles;
 *    release any chunks of memory the process owns;
 *    remove from pdtab;
 */
void
ixterm(r)
PD *r;			/* -> basepage */
{
    REG	int i;
  
    DBCMD(0x40,"print ixterm pd: -x (lpeek (`a6 + 8));_c");

    /*
     *  Close all handles (but only bother with open ones)
     */
    for (i = r->p_uftsize - 1; i >= 0; i--) {
	if (r->p_uft[i]) (void)ixclose(i,r);	/* don't care if it fails */
    }

    /*
     *  Free chunks of TPA the process allocated (including the basepage). 
     *  Especially, free the basepage and the environment, which the
     *  process in question may not really own! (These may return EIMBA,
     *  which is fine.)
     */
    xmfreeall(r);

    /*
     * remove this entry from pdtab.
     * It might not be there because it might not have been started.
     */
    for (i=NUMPDS-1; i >= 0; i--) {
	if (pdtab[i] == r) {
	    pdtab[i] = NULL;
	    break;
	}
    }
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
 * when it's created.  New modes should fix this.  Or possibly just
 * changes to old modes!
 *
 * The 'volatile' keyword in the local variable section is there so
 * the compiler does NOT put those things in registers.  That way,
 * the value of the thing in the setjmp clause is the LAST value it
 * was assigned, not an unknown value.  Using that variable is slower
 * than letting the compiler put it in a register, so we keep a copy
 * of some things rather than declaring the "real" one volatile.
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
	PD * volatile v_pdp;	/* volatile holder for pdp */
	char *b,*e,*env;
	char * volatile v_env;	/* volatile holder for env */
	int h,i;
	long rc,max,envsize;
	char *sp;
	long lx;		/* error code for xopen */
	volatile int fh;	/* handle for open file (closed by xpgmld) */
	PRG prg;		/* the PRG header, passed to xpgmld */
	int use;		/* type of RAM we decided to use for TPA (0 or 1) */
	long fastmax, slowmax, minfast;
	OFD **uftstart;

	if (!mem_initted) {
	    mem_initted = 1;
	    DBCMD(1,"print call init_t2;_c");
	    init_t2();
	}

	DBCMD(1,"_dopexec (wpeek (`a6 + 8)) (lpeek (`a6 + a)) "
		   "(lpeek (`a6 + e)) (lpeek (`a6 + 12)) ;_c");

	v_pdp = NULPTR;
	v_env = NULPTR;
	fh = 0;

	if (mode && ((mode < 3) || (mode > MAXMODE)))
	    return(EINVFN);

	/* push a jump-buf level so we can clean up after errors */
	xmovs(sizeof(errbuf),errbuf,bakbuf);

	if (rc = setjmp(errbuf)) {
		DBCMD(0x40,"print longjmp into xexec cleanup;_c");

		/* Close, free, etc., then jump back again. */
		/* Be sure to use the v_ forms of locals which have one! */
		if (fh) xclose(fh);
		if (v_pdp) xmfree(v_pdp);
		if (v_env) xmfree(v_env);

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

		i += 2;		/* add two for null/null */

		if (i & 1) ++i;

		/* select eligibility of memory for environment */
		if (prg.g_hflags & P_RAMEXEC) h = 3;
		else h = 0;

		envsize = i + (OPNFILES * sizeof(OFD *));
		if (!(e = v_env = env = (char *)xfmalloc(envsize,h)))
			return (ENSMEM);

		uftstart = (OFD **)(env + i);

		/* now copy it */

		while (i--)
			*e++ = *v++;

		/* zero the UFT initially */
		clear(e,e+(OPNFILES * sizeof(OFD *)));

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
			DBCMD(0x40,"print use alternative RAM;_c");
			max = fastmax;
			use = 1;
		    }
		    else {
			DBCMD(0x40,"print use ST RAM;_c");
			max = slowmax;
			use = 0;
		    }
	        }
	        else {
		    DBCMD(0x40,"print alternative RAM not eligible;_c");
		    use = 0;
		    max = xfmalloc(-1L,0);
		}

		/*
		 * Ensure room for the basepage + program + some extra
		 * (in this case, "some extra" is 2K)
		 */
		if (max < (prg.g_tsize + prg.g_dsize + prg.g_bsize + 0x900L)) {
		    DBCMD(0x40,"print xexec returns ENSMEM;_c");
		    xmfree(env);
		    /* could pop the error-stack frame, but not nec. */
		    return(ENSMEM);
		}

		v_pdp = pdp = (PD *)xfmalloc(max,use);

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

		/* set uft and uftsize so they're valid for other calls */
		pdp->p_uft = uftstart;
		pdp->p_uftsize = OPNFILES;

		/* inherit standard files */
		for (i=0; i < NUMSTD; i++) {
		    ixforce(i,i,pdp);
		}

		/* and current directory set */
		for (i = 0; i < 16; i++)
			pdp->p_curdir[i] = run->p_curdir[i];

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
		v_pdp = pdp = (PD *)t;
	}

	/* for 3 or 0, need to load, supply baspage containing: */
	/* 	tpa limits, filled in with start addrs,lens */

	if ((mode == 0) || (mode == 3)) {
		if (rc = xpgmld(&prg,fh,pdp)) {
		    DBCMD(0x40,"print xpgmld failed.;_c");
		    xclose(fh);
		    ixterm(pdp);
		    return(rc);
		}
		xclose(fh);
	}

	if ((mode == 0) || (mode == 4) || (mode == 6)) {
	    DBCMD(0x40,"print go phase of pexec;_c");
	    pdp->p_parent = run;
	    sp = pdp->p_hitpa;
	    pushlong(sp,(long)pdp);
	    pushlong(sp,0L);

	    /* 10 regs (40 bytes) of zeroes  */

	    for (i = 10; i--; pushlong(sp,0L)) /* empty */ ;

	    /********************************************************
	     *
	     * important: make sure child is started with IPL=0! this is
	     * now considered "guaranteed" because of the HBLANK trick used
	     * by debuggers (etc.).
	     *
	     ********************************************************/

	    pushlong(sp,pdp->p_tbase);	/* text start */
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

	    /* add this bp to pdtab; fail if can't */

	    for (i=0; i<NUMPDS; i++) {
		if (pdtab[i] == NULL) {
		    pdtab[i] = pdp;
		    break;
		}
	    }
	    if (i == NUMPDS) {
		DBCMD(0x40,"print pdtab is full;_c");
		ixterm(pdp);
		return -1;
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
  REG unsigned char *r;	    /* no sign extension here! */
  REG unsigned char *bssadr;
  REG uint n;
  REG ulong *cp;
  REG ulong i;
  ulong relst;		/* relocation start */
  char *codbas;		/* start of text segment */
  ulong flen,n0,bsslen,tpasiz;

  DBCMD(0x40,"print xpgmld prg: -x (lpeek (`a6 + 8)) -x (wpeek (`a6 + c)) "
	     "-x (lpeek (`a6 + e)) PRG:;prg (lpeek (`a6 + 8));_c");

  flen = prg->g_tsize + prg->g_dsize;

  tpasiz = ((long)lp->p_hitpa - (long)lp->p_lowtpa) - 0x100;

  codbas = (char *)(lp+1);
  bssadr = (char *)(codbas + flen);
  bsslen = tpasiz - flen;
  
  /*
   *  Fill in basepage with text+data+bss start-address and size information.
   */
  lp->p_tbase = (long)codbas;
  lp->p_tlen = prg->g_tsize;

  lp->p_dbase = (long)codbas+prg->g_tsize;
  lp->p_dlen = prg->g_dsize;

  lp->p_bbase = (long)bssadr;
  lp->p_blen = prg->g_bsize;

  /* Read text+data segments. */
  xread(h, flen, codbas);

  /*  if the file is absolute, don't do any fixups, but do zero BSS. */
  if (prg->g_absflg)
    goto zrobss;

  /*
   *  Seek to start of fixup information (past symbols);
   *  read offset of first fixup;
   *  if the offset is zero, don't fix anything up.
   */
  xlseek(flen + prg->g_ssize + sizeof(PRG), h, 0);
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
    DBCMD(0x40,"print xpgmld: first fixup offset is out of range;_c");
    return(EPLFMT);
  }

  /* do the first fixup */
  *cp += (unsigned long)codbas;

  /*
   *  Do fixups until we run out.  The "run out" clause at the end is
   *  "while (n0 == bsslen)" which means we stop when a read succeeded and
   *  didn't use up all of the buffer we gave it (i.e. the file ended
   *  already).  I am subtle, therefore I comment.
   */
  do {
      /*
       *  Read another chunk of relocation bytes
       */
      n0 = xread(h, bsslen, bssadr);
      if (n0 < 0) {
	/* read error which didn't longjmp */
	DBCMD(0x40,"print xpgmld: read error which did not longjmp;_c");
	return n0;
      }

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

	  if (n == 1) ((char *)cp) += 0x0fe;	/* bump cp and get next byte */
	  else if (n & 1) {
	    DBCMD(0x40,"print xpgmld: odd fixup;_c");
	    return EPLFMT;
	  }
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
