/*
***************************    FSDIR.C     ******************************
*
* $Revision: 2.5 $	$Source: /u2/MRS/osrevisions/gemdos/fsdir.c,v $
* =======================================================================
* $Author: apratt $ 	$Date: 90/08/03 13:41:09 $    $Locker:  $
* =======================================================================
*
* $Log: fsdir.c,v $
* Revision 2.5  90/08/03  13:41:09  apratt
* TTOS FINAL RELEASE
* 
* Revision 2.4  90/05/21  12:52:43  apratt
* Changed xrmdir's return when trying to remove the root: was EACCDN, now
* EBADRQ.  EACCDN was interpreted by some programs as "subdirectory not
* empty" which would give a user a bad error message.
* 
* Revision 2.3  90/05/16  10:59:25  apratt
* Added a check so Ddelete of the root doesn't bomb.
* 
* Revision 2.2  89/04/17  17:14:17  kbad
* YA header change
* 
* Revision 2.1  89/02/21  17:19:17  kbad
* *** TOS 1.4  FINAL RELEASE VERSION ***
* 
* Revision 1.6  89/01/24  15:38:28  apratt
* Fixed a bug I introduced.  I caused a search for "A:\*\*.*" to go into
* an infinite loop, constantly looking for "????????.???" in the root
* directory of A:, starting from the beginning each time. This is fixed 
* by short-circuiting the problem: if a directory component contains a '?'
* character, we return EPTHNF early.  (All this in findit().)
* 
* Revision 1.5  88/08/18  17:54:52  apratt
* Changed handling of current directory slots (diruse, dirtbl) to be
* more nearly correct, all in xchdir.  Now it doesn't do anything
* if the chdir fails (before, it decremented the diruse count for
* the current dir).  Also looks for an existing dirtbl slot with
* the right DND before using up a new one.  Also, in all places
* where diruse's were getting decremented, there are now checks
* so it doesn't get decremented from 0 to -1... But with the
* new improved chdir this may never happen anyway.
* 
* Revision 1.4  88/08/16  17:47:30  apratt
* Add check: don't decrement diruse[i] past zero.  This blocks, but
* does not fix, the diruse mismanagement.
* 
* Revision 1.3  88/06/30  13:55:03  apratt
* Removed swap of date & time when creating .. directory entry.
* (It's already swapped in o_time and o_date)
* 
* Revision 1.2  88/06/13  15:06:02  apratt
* Header style change
* 
* Revision 1.1  88/04/26  14:48:19  apratt
* Version used 4/22/88 to make test ROMs
* 
*************************************************************************
*/

/****************************************************************************\
 * 									     *
 * GEMDOS File System Directory Management				     *
 * (C)1986 Atari Corp.							     *
 * 									     *
 * ---- Edit history (reverse order, please): ------------------------------ *
 * 									     *
 * 28-Mar-1988 akp	Added checks to mkdir to be sure it will succeed.    *
 * 24-Mar-1988 akp	Fixed fsfirst so it behaves like before wrt attr.    *
 *			Removed check for MGET error because it panics.	     *
 * 11-Mar-1988 akp	Removed panic for too many current directories.	     *
 *			Changed panic for mkdir to Panic(0).		     *
 * 17-Feb-1988 akp	Lintified.					     *
 * 03-Feb-1988 akp	Changed some register declarations.		     *
 * 12-Jan-1988 akp	Removed panics (MGET panics when it fails, and the   *
 *			other panics "can't happen").  Removed debug msgs.   *
 * 06-Jan-1988 akp	Totally replaced Fsfirst / Fsnext.		     *
 * 29-Dec-1987 akp	Added dndtouch() macro to lock dnd's in use.	     *
 * 28-Dec-1987 akp	More changes; only cache dir's we *use*.	     *
 *			Changed duplicate detection again: xmkdir calls	     *
 *			makdnd before the file's start cluster is known.     *
 *			Current system is slower but infallible: same name,  *
 *			same parent means it's a duplicate.		     *
 * 22-Dec-1987 akp	Changed compare for duplicate entries in makdnd:     *
 *			this has been wrong for a long time.		     *
 * 21-Oct-1987 akp	Lintified					     *
 * 20-Oct-1987 akp	Added DND locking in Fsfirst/Fsnext and makdnd.	     *
 * 22-Sep-1987 akp	Added swp68 of date & time for . and .. in mkdir.    *
 * 17-Jan-1986 lmd	Commented and prettified from Digital Research	     *
 * 			source code.					     *
 * 30-Jan-1986 lmd	Broken out from old FS.C			     *
 * 									     *
 \****************************************************************************/

#include "fs.h"
#include "gemerror.h"
#include "fsdecl.h"

/* dndtouch: lock this dnd by marking it as used in this OS call */

#define dndtouch(dnd) (*(((char *)(dnd))-1) = callno)

ixdirdup(h, dn, p)
int h;			/* current dir slot# */
int dn;			/* directory number */
PD *p;			/* -> basepage */
{
  p->p_curdir[h] = dn;
  diruse[dn]++;
}


/*
 *  Make a child subdirectory (FCB *b) of directory (DND *p).
 *
 */
DND
*makdnd(x_p, x_b)
DND *x_p;
FCB *x_b;
{
  REG DND *p;
  REG FCB *b;
  OFD *fd;
  REG DND *p1;
  int temp;
  
  p = x_p;
  b = x_b;
  temp = b->f_clust;
  swp68(temp);

    /* don't add duplicate entries */
  for (p1 = p->d_left; p1; p1 = p1->d_right)
    if (xcmps(b,p1))		/* same parent, same name */
      return p1;

  fd = p->d_ofd;

  dndtouch(p);			/* lock the dnd we're making a child for */

  p1 = MGET(DND);

  if (p->d_left)
    p1->d_right = p->d_left;
  
  p->d_left = p1;
  p1->d_ofd = NULPTR;
  p1->d_parent = p;
  p1->d_strtcl = b->f_clust;
  swp68(p1->d_strtcl);
  p1->d_drv = p->d_drv;
  p1->d_dirfil = fd;
  p1->d_dirpos = fd->o_bytnum - 32;
  p1->d_fill = 0;
  p1->d_time = b->f_time;
  p1->d_date = b->f_date;
  xmovs(11,b->f_name,p1->d_name);
  
  return(p1);
}


/*
 *  Scan directory
 *
 */
FCB
*scan(x_p, n, att, posp)
DND *x_p;		/* directory to scan */
char *n;		/* filename */
int att;		/* search attributes */
long *posp;		/* directory position */
{
  REG DND *p;
  REG OFD *fd;
  REG FCB *b;
  DND *p1;
  REG int m;
  long srchpos;
  char d[12];			/* buffer for name and attribute byte */
  
  p = x_p;
  p1 = NULPTR;			/* initialize this like old GEMDOS did. */
  dndtouch(p);			/* lock the directory we're scanning in */

  /*
   *  Build crunched filename + attribute byte
   */
  m = 0;
  builds(n, d);
  d[11] = att;

  /*
   *  Make OFD for directory file
   *  if one isn't already there.
   */
  if (!(fd = p->d_ofd))
    p->d_ofd = (fd = makofd(p));

  /*
   * set srchpos to 0 if directory search, else to *posp. (was d_scan)
   */
  if ((srchpos = *posp) == -1) {
    srchpos = 0;
  }

  ixlseek(fd, srchpos);

  while ((b = (FCB *) ixread(fd,32L,NULPTR)) && (b->f_name[0]))
    {
      /* if this slot matches our target and is a subdir, add it */

      if (m = match(d,b->f_name)) {		/* if there's a match... */
	if ((*posp == -1) &&			/*  if looking for a dir */
	  (b->f_name[0] != '.') &&		/*   and not . or .. */
	  (b->f_attrib & FA_SUBDIR) &&		/*   and is subdir */
	  (b->f_name[0] != 0xe5)) {		/*   and isn't erased */
	    if (!(p1 = makdnd(p, b))) {		/*    add to cache. */
		return (NULPTR);
	    }
	}
	break;			/* break on a match (always) */
      }
    }

  /* fall out of here with a match or end of directory */

  /* set *posp to (just past) this match if NOT a dir search */
  if (*posp != -1)
    *posp = fd->o_bytnum;

  if (!m) {
      /* no match: were we looking for erased files? */
      if (b && (*n == 0xe5)) {
	return(b);		/* yes: return b (which is 1st zero slot) */
      }
      return(NULPTR);		/* no: total miss; return null */
  }

  if (*posp == -1) {
      /* match and was a search for a subdir: seek to slot and return it */
      ixlseek(fd,fd->o_bytnum - 32);
      return(((FCB *) p1));
  }
  
  /* match and was not a search for a subdir: return the FCB */
  return(b);
}


/*
 *  Crack open a directory
 *
 */
DND
*dcrack(np)
char **np;			/* -> ->filename (ptr modified on return) */
{
  REG char *n;
  REG int d;
  REG DND *p;
  
  /*
   *  Compute drive number
   */
  n = *np;
  if (n[1] == ':')
    {
      d = uc(n[0]) - 'A';
      n += 2;
    }
  else
    d = run->p_curdrv;
  
  /*
   *  Crack open drive
   */
  if (ckdrv(d) < 0)
    return(0L);
  
  /*
   *  If path begins with a slash start at root directory,
   *  otherwise start at current directory.
   */
  if (*n == SLASH)
    {				/* [D:]\path... */
      p = drvtbl[d]->m_dtl;
      n++;
    }
  else				/* path... */
    p = dirtbl[run->p_curdir[d]];
  
  *np = n;			/* set pointer to rest of filename */
  dndtouch(p);			/* lock this directory */
  return(p);			/* return starting DND */
}


/*
 *  Return DND->directory that a file is in,
 *  or just return DND->directory.
 *
 */
DND
*findit(name, sp, dflag)
char *name;			/* -> filename */
char **sp;			/* set to -> name part of path on return */
int dflag;			/* if true, no file name is present */
{
  char *n;
  REG DND *p;
  REG DND *pp;
  DND **newp;

  REG int i;
  char s[11];
  REG char *ptemp;
  
  /*
   *  Crack open directory and drive
   */
  n = name;
  if (!(p = dcrack(&n))) {
    return(p);
  }

  do
    {
      if (!(i = getpath(n, s, dflag)))
	break;
      
      if (i < 0)
	{
	  if (i == -2) {
	    p = p->d_parent;
	  }
	  i = -i;
	  goto scanxt;
	}

      /* reject any directory component of a path with wildcards (1/89 AKP) */
      ptemp = &s[11];
      while (ptemp > s) if (*(--ptemp) == '?') return NULL;

      if (!(newp = p->d_left))
	newp = ((DND *)scan(p, n, FA_SUBDIR, &negone));

      pp = p;

      if (!(p = newp))
	break;
      
      /*
       *  Check all subdirectories at this level
       */
      while (p && (!xcmps(s,p->d_name))) 
	{
	  /*
	   *  If directory not entirely traversed,
	   *  scan until next match or end
	   */
	  if (!(newp = p->d_right))
	    {
	      p = 0;
	      if (pp)
		  p = scan(pp, n, FA_SUBDIR, &negone);
	    }
	  else {
	    p = newp;
	  }
	}
    scanxt:
      if (*(n = n + i))
	n++;
      else
	break;
    } while (p && i);
  
  /*
   *  p = 0 ==> not found
   *  i = 0 ==> found at p (dnd entry)
   *  n = points at filename
   */
  
  *sp = n;
  if (p) dndtouch(p);	/* lock the directory we just found */
  return(p);
}


/*
 *  Dsetpath(path)
 *    Set current directory
 * 
 * Calling this function with an arg containing a drive letter and colon
 * causes something you don't expect.  The call xchdir("c:\sub1\sub2") when
 * your current drive is D: causes the current directory on C: to be
 * D:\sub1\sub2.  That's right, D:. 
 * 
 * This is a bug, but it can be passed off as a feature: any program which
 * doesn't know about subdirectories (i.e.  only uses drive letters:
 * "c:file.typ") can be fooled into using them. 
 * 
 * To remove this "feature" just remove the statement "p += 2;"
 *
 * In any case, this code used to decrement diruse for the current dir on
 * the drive in question *before* determining that the chdir would succeed. 
 * This caused bad things to happen.
 *
 * Improvements over 8/8/88 are: checking for success before any side effects,
 * and re-using a slot in dirtbl if it already points to the dir in question.
 *
 */

long
xchdir(p)
char *p;
{
  REG long l;
  REG int dr;
  REG int dphy;
  REG int odr;
  char *s;

  /*
   *  Check for device name on the front
   */
  if (p[1] == ':')
    {
      dphy = uc(p[0]) - 'A';
      p += 2;
    }
  else dphy = run->p_curdrv;

  if (!(l = findit(p,&s,1)))
    return(EPTHNF);

  /* remember old cur dir slot on this drive */
  odr = run->p_curdir[dphy];

  /*
   * see if this is already somebody's current directory
   */
  for (dr = 1; dr < NCURDIR; ++dr) {
    if (dirtbl[dr] == l) {
	goto usedr;
    }
  }

  /*
   * Nobody's already using this dir; find an empty slot in dirtbl.
   */
  for (dr = 1; dr < NCURDIR; ++dr) {
    if (!diruse[dr]) {
	dirtbl[dr] = l;
	goto usedr;
    }
  }
  return EPTHNF;	/* no empty current-directory slots */

usedr:
  if (odr) {
    if (diruse[odr]) --diruse[odr];
  }
  diruse[dr]++;
  run->p_curdir[dphy] = dr;
  return OK;
}

/*	Function 0x47	d_getpath
	
	Error returns
	EDRIVE
	
	Last modified	SCC	11 Apr 85
	*/

long
xgetdir(buf,drv) /*+ return text of current dir into specified buffer */
int drv;
char *buf;
{
  REG DND *p;
  
  drv = (drv ? drv-1 : run->p_curdrv);
  
  if (ckdrv(drv) < 0)
    {
      *buf = 0;
      return(EDRIVE);
    }
  
  p = dirtbl[run->p_curdir[drv]];
  buf = dopath(p,buf);
  *--buf = 0;	/* null as last char, not slash */
  
  return OK;
}


/*
 *  Fill in DTA buffer with Fsfirst/Fsnext information
 */
makbuf(x_f, x_ubufr)
FCB *x_f;
DTA *x_ubufr;
{
  REG FCB *f;
  REG DTA *ubufr;

  ubufr = x_ubufr;
  f = x_f;

  ubufr->fattrib = f->f_attrib;
  ubufr->ftime = f->f_time;
  ubufr->fdate = f->f_date;
  swp68(ubufr->ftime);
  swp68(ubufr->fdate);
  ubufr->flength = f->f_fileln;
  swp68l(ubufr->flength);
  packit(f,ubufr->fname);
}


/*
 *  Initialize a directory sector
 *
 */
FCB
*dirinit(x_dn)
DND *x_dn;
{
  REG DND *dn;
  REG OFD *fd;
  int num;
  REG int i;
  REG int i2;
  char *s1;
  DMD *dm;
  REG FCB *f1;
  
  dn = x_dn;
  fd = dn->d_ofd;
  num = (dm = fd->o_dmd)->m_recsiz;
  for (i2 = 1; i2 < dm->m_clsiz; i2++)
    {
      s1 = getrec(fd->o_currec+i2, dn->d_drv, 1);
      for (i = 0; i < num; i++)
	*s1++ = 0;
    }
  f1 = (FCB *) (s1 = getrec(fd->o_currec, dn->d_drv, 1));
  for (i = 0; i < num; i++)
    *s1++ = 0;

  return f1;
}


/*
 *  Dcreate(path)
 *    Make directory
 *
 */
long
xmkdir(s)
char *s;
{
  int h;
  int cl;
  int i;
  long rc;
  OFD *f;
  FCB fcb;

  /*
   *  Create directory file.
   */

  if ((h = rc = ixcreat(s, FA_SUBDIR)) < 0)
    return rc;

  f = getofd(h);		/* can't fail */

  /*
   * Write "." directory entry
   */

  if ((rc = ixwrite(f,1L,dots)) != 1) {
    /* build just the strtcl of an FCB for ixdel - that's all it uses. */
    fcb.f_clust = f->o_strtcl;
    ixdel(f->o_dnode,&fcb,f->o_dirbyt);
    xclose(h);
    return (rc ? rc : EACCDN);		/* full disk -> EACCDN */
  }
  ixlseek(f,0L);			/* seek back to beginning */

  xmovs(22, dots, &fcb);
  fcb.f_attrib = FA_SUBDIR;
  fcb.f_time = time;
  swp68(fcb.f_time);
  fcb.f_date = date;
  swp68(fcb.f_date);
  fcb.f_clust = f->o_strtcl;
  swp68(fcb.f_clust);
  fcb.f_fileln = 0;

  ixwrite(f,32L,&fcb);

  /*
   * Write ".." directory entry
   */
  xmovs(22, dots2, &fcb);
  fcb.f_attrib = FA_SUBDIR;
  fcb.f_time = f->o_dirfil->o_time;	/* o_time & o_date are 8088 format */
  fcb.f_date = f->o_dirfil->o_date;	/* already; no need to swap them.  */
  cl = f->o_dirfil->o_strtcl;
  if (cl < 0) cl = 0;
  swp68(cl);
  fcb.f_clust = cl;
  fcb.f_fileln = 0;

  ixwrite(f,32L,&fcb);

  /*
   * write as many zero fcb's as will fill the cluster.
   */

  clear(&fcb,&fcb+1);

  for (i = (f->o_dmd->m_clsizb / sizeof(FCB)) - 2; i; i--) {
    ixwrite(f,32L,&fcb);
  }

  f->o_fileln = 0;	/* zap file length */
  xclose(h);		/* force flush and write */
  return OK;
}


/*
 *  Ddelete(path)
 *    Remove directory
 *
 *	Error returns
 *		EPTHNF (no such path)
 *		EACCDN (directory not empty)
 *		EINTRN (can't find the DND in the tree)
 *		EBADRQ (attempting to rmdir the root)
 *
 */
long
xrmdir(p)
char *p;
{
  REG DND *d;
  DND *d1;
  REG DND **q;
  REG FCB *f;
  OFD *fd,*f2;
  REG long pos;
  char *s;
  
  if (!(d = findit(p, &s, 1)))
    return(EPTHNF);
  
  if (!(fd = d->d_ofd))
    fd = makofd(d);
  
  ixlseek(fd, 0x40L);		/* seek past "." and ".." */
  
  do
    {
      if (!(f = (FCB *) ixread(fd,32L,NULPTR)))
	break;
    } while (f->f_name[0] == 0x0e5);
  
  if (f)
    if (f->f_name[0] != 0)
      return(EACCDN);
  
  /* if no parent, it's the root, and you can't rmdir root */
  if (d->d_parent == NULPTR) return EBADRQ;

  /*
   *  Search tree for our DND
   */
  for (d1 = *(q = &d->d_parent->d_left);
       d1 != d;
       d1 = *(q = &d1->d_right) )
    ; /* follow sib-links */
  
  if (d1 != d ||		/* not found? */
      d->d_files ||		/* open files? */
      d->d_left)		/* subdirectory? */
    {
      return EINTRN;		/* ... internal error */
    }
  
  /*
   *  Remove DND from tree
   */
  *q = d->d_right;
  
  if (d->d_ofd)
    xmfreblk(d->d_ofd);
  
  d1 = d->d_parent;
  xmfreblk(d);
  ixlseek((f2 = fd->o_dirfil), (pos = fd->o_dirbyt));
  f = (FCB *) ixread(f2,32L,NULPTR);
  
  return(ixdel(d1, f, pos));
}

/************************************************************************
*									*
* Fsfirst / Fsnext							*
*									*
*	This section uses scan for searches in the root directory, and	*
*	uses a cluster / offset scheme for searches in subdirectories.	*
*	This is so it doesn't have to keep pointers to DNDs in the DTA.	*
*									*
************************************************************************/

long
ixsfirst(name,att,addr)
char *name;
int att;
DTA *addr;
{
    char *s;
    REG DND *dn;
    REG FCB *f;
    long pos;

    if (att != 8) att |= (FA_ARCHIVE | FA_RO);

    if (!(dn = findit(name,&s,0)))
	return(EPTHNF);

    /* now scan for filename from start of directory */

    pos = 0;

    if (!(f = scan(dn,s,att,&pos)))
	return(EFILNF);

    if (addr) {
	xmovs(12,s,addr);
	addr->dta_attr = att;		/* attribute field of next search */
	if (dn->d_strtcl < 0) {		/* root directory search */
	    addr->dta_rdpos = pos;
	}
	else {
	    addr->dta_rdpos = 0;
	    addr->dta_clust = dn->d_ofd->o_curcl;
	    addr->dta_pos = dn->d_ofd->o_curbyt;
	}
	addr->dta_rdpos |= dn->d_drv->m_drvnum;
	makbuf(f,addr);
    }

    return OK;
}


/*	Function 0x4F	f_snext */

/*
 * This code uses the DTA wierdly.
 * For root-directory searches, it puts the position of the last
 * match in dta->dta_rdpos, and uses that for the next search.
 * But it ALSO puts the device number there, in the low 4 bits
 * (since offsets are multiples of 0x20).
 */

long
xsnext() /*+ search next, return into dta */
{
    REG DTA *dta; 
    REG DMD *dm; 
    char att; 
    REG unsigned int pos;
    REG unsigned int cl;
    long rdpos;
    REG FCB *f;
    char *buf;
    char d[12];
    REG int first;

    dta = run->p_xdta;
    dm = drvtbl[dta->dta_rdpos & 0xf];
    att = dta->dta_attr;
    pos = dta->dta_pos;
    cl = dta->dta_clust;
    rdpos = dta->dta_rdpos & ~0x0f;
    first = 0;

    if (!dta->dta_sname[0])		/* marked as exhausted? */
    	return ENMFIL;			/* return early. */

    if (rdpos) {		/* marked as root directory search? */
	DND *dn = dm->m_dtl;

	if (!(f = scan(dn,&(dta->dta_sname[0]),att,&rdpos))) {
	    goto notfound;
	}
	else {
	    dta->dta_rdpos = rdpos | dm->m_drvnum;
	    goto found;
	}
    }

    /* end of old code for root-directory searches */

    builds(&dta->dta_sname[0],d);
    d[11] = dta->dta_attr;

    newcl = TRUE;
    first = TRUE;

    /* This code uses pos as the offset into a cluster. */
    /* Since pos is an unsigned, we are assuming that clusters are <= 64K */

    while (1) {
	/* major (per-sector) loop */
	if (first || (pos % dm->m_recsiz) == 0) {
	    first = FALSE;
	    /* get the pos/recsiz'th sector of this cluster */
	    if (pos == dm->m_clsizb) {
		/* last sector of a cluster: go to next cluster */
		pos = 0;
		cl = getcl(cl,dm);
		if (cl == 0xffff) {
		    goto notfound;
		}
	    }

	    /* cl is cluster number, pos is offset within that cluster. */

	    buf = getrec(cl2rec(cl,dm) + pos/dm->m_recsiz,dm,0);
	}

	/* set f to the offset within that sector to start with */
	f = buf + (pos % dm->m_recsiz);

	/* f points to dir slot to start searching at */
	/* if f falls off end of this sector, go back and get another one. */

	do {
	    /* minor (in-sector) loop */
	    if (!(f->f_name[0])) {
		goto notfound;
	    }
	
	    if (match(d,f->f_name)) {
		dta->dta_pos = pos+0x20;
		dta->dta_clust = cl;
		goto found;
	    }
	    else {
		f++;
		pos += sizeof(FCB);
	    }
	} while (pos % dm->m_recsiz);
    }

notfound:
    dta->dta_sname[0] = 0;
    dta->fname[0] = 0;
    newcl = TRUE;	/* just in case */
    return ENMFIL;

found:
    makbuf(f,dta);
    newcl = TRUE;		/* just in case */
    return OK;
}


