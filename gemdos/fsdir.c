/*
***************************    FSDIR.C     ******************************
*
* $Revision: 2.7 $	$Source: fsdir.c,v $
* =======================================================================
* $Author: apratt $ 	$Date: 91/01/23 17:09:46 $    $Locker:  $
* =======================================================================
*
* $Log: fsdir.c,v $
* Revision 2.7  91/01/23  17:09:46  apratt
* Changed d_left to d_child, d_right to d_next globally.  Removed o_thread,
* d_scan, m_fatofd, m_ofl, and d_dirfil.
*
* Revision 2.6  91/01/23  14:30:00  apratt
* Trimmed logs & comments, changed to compile under GCC or (new) Alcyon.
* 
*************************************************************************
*/

#include "fs.h"

/* dndtouch: lock this dnd by marking it as used in this OS call */

#define dndtouch(dnd) (*(((char *)(dnd))-1) = callno)

void
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
*makdnd(p, b)
DND *p;
FCB *b;
{
  OFD *fd;
  REG DND *p1;
  int temp;
  
  temp = b->f_clust;
  swp68(temp);

    /* don't add duplicate entries */
  for (p1 = p->d_child; p1; p1 = p1->d_next)
    if (xcmps(b->f_name,p1->d_name))		/* same parent, same name */
      return p1;

  fd = p->d_ofd;

  dndtouch(p);			/* lock the dnd we're making a child for */

  p1 = MGET(DND);

  if (p->d_child)
    p1->d_next = p->d_child;
  
  p->d_child = p1;
  p1->d_ofd = NULPTR;
  p1->d_parent = p;
  p1->d_strtcl = b->f_clust;
  swp68(p1->d_strtcl);
  p1->d_drv = p->d_drv;
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
*scan(p, n, att, posp)
DND *p;			/* directory to scan */
char *n;		/* filename */
int att;		/* search attributes */
long *posp;		/* directory position */
{
  REG OFD *fd;
  REG FCB *b;
  DND *p1;
  REG int m;
  long srchpos;
  char d[12];			/* buffer for name and attribute byte */
  
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
   * set srchpos to 0 if directory search, else to *posp.
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
	  (b->f_name[0] != 0xffffffe5)) {	/*   and isn't erased */
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
      if (b && (*n == 0xffffffe5)) {
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
  DND *newp;

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

      if (!(newp = p->d_child))
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
	  if (!(newp = p->d_next))
	    {
	      p = 0;
	      if (pp)
		  p = (DND *)scan(pp, n, FA_SUBDIR, &negone);
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
  REG DND *l;
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
void
makbuf(f, ubufr)
FCB *f;
DTA *ubufr;
{
  ubufr->fattrib = f->f_attrib;
  ubufr->ftime = f->f_time;
  ubufr->fdate = f->f_date;
  swp68(ubufr->ftime);
  swp68(ubufr->fdate);
  ubufr->flength = f->f_fileln;
  swp68l(ubufr->flength);
  (void)packit(f->f_name,ubufr->fname);
}


/*
 *  Initialize a directory sector
 *
 */
FCB
*dirinit(dn)
DND *dn;
{
  REG OFD *fd;
  int num;
  REG int i;
  REG int i2;
  char *s1;
  DMD *dm;
  REG FCB *f1;
  
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

  xmovs(22, dots, &(fcb.f_name[0]));
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
  xmovs(22, dots2, &(fcb.f_name[0]));
  fcb.f_attrib = FA_SUBDIR;

  /* o_date, o_time in 8088 format already; no need to swap them.  */
  fcb.f_time = f->o_dirfil->o_time;
  fcb.f_date = f->o_dirfil->o_date;
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
    } while (f->f_name[0] == 0xffffffe5);
  
  if (f)
    if (f->f_name[0] != 0)
      return(EACCDN);
  
  /* if no parent, it's the root, and you can't rmdir root */
  if (d->d_parent == NULPTR) return EBADRQ;

  /*
   *  Search tree for our DND
   */
  for (d1 = *(q = &d->d_parent->d_child);
       d1 != d;
       d1 = *(q = &d1->d_next) )
    ; /* follow sib-links */
  
  if (d1 != d ||		/* not found? */
      d->d_files ||		/* open files? */
      d->d_child)		/* subdirectory? */
    {
      return EINTRN;		/* ... internal error */
    }
  
  /*
   *  Remove DND from tree
   */
  *q = d->d_next;
  
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
    char *buf = NULL;	/* initialized to shut compiler up */
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
	f = (FCB *)(buf + (pos % dm->m_recsiz));

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

