/*
***************************    FSDIR.C     ******************************
*
* $Revision: 2.12 $	$Source: e:/tos/gd2\rcs\fsdir.c,v $
* =======================================================================
* $Author: apratt $ 	$Date: 1991/02/22 15:29:28 $    $Locker:  $
* =======================================================================
*
* $Log: fsdir.c,v $
* Revision 2.12  1991/02/22  15:29:28  apratt
* generic checkin
*
* Revision 2.11  1991/02/21  03:07:32  apratt
* This version performs this testbed perfectly.
*
* Revision 2.10  1991/02/15  18:45:40  apratt
* CI at the end of the week...
*
* Revision 2.9  1991/02/12  18:20:10  apratt
* *** empty log message ***
*
* Revision 2.8  1991/02/11  19:56:48  apratt
* Checkin lest I lose work (again)
*
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

/*
 * User-level directory operations
 */

/*
 *  Dsetpath(path)
 *    Set current directory
 * 
 * QUIET CHANGE FROM ORIGINAL GEMDOS:
 *
 * Originally, calling this function with an arg containing a drive letter 
 * and colon causes something you don't expect.  The call 
 * xchdir("c:\sub1\sub2") when your current drive is D: causes the current 
 * directory on C: to become D:\sub1\sub2.  That's right, D:. 
 * 
 * This is not bug, as you can tell in the original code by the careful
 * use of two local variables, one for your current drive and one for the
 * drive mentioned in the argument. The "feature" here is that a program 
 * which doesn't know about subdirs (i.e. only uses drive letters:
 * "c:file.typ") can be fooled into using them (in this case, 
 * "d:\sub1\sub2\file.typ").
 * 
 * This feature is now (1/91) declared obsolete, and calling 
 * Dsetpath("d:\foo") will cause the current directory on d: to 
 * become d:\foo.  It still doesn't change your current drive; it
 * only changes d's current directory.  (Hmm, should it?)
 * Part of the reason is that the current directory for each drive is now
 * represented by the cluster number only, not a reference to a struct.
 */

long
xchdir(p)
char *p;
{
    int drv = run->p_curdrv;
    DIR dir;
    long err;

    if (!*p) return 0;	/* Dsetpath("") is a no-op */
    if (*(p+1) == ':') {
	/* drive spec */
	drv = uc(*p) - 'A';
	if (drv < 0 || drv >= MAXDEVS) return EDRIVE;
	p += 2;
    }
    if (!*p) return E_OK;	/* Dsetpath("") or "c:" is a no-op */
    if (*p == SLASH && !*(p+1)) {
	/* set something to the root directory; can't fail */
	run->p_curdir[drv] = 0;
	return E_OK;
    }

    if (err = fn2dir(&p,&dir,FN_DOTSOK)) return err;

    run->p_curdir[drv] = dir.dir_clust;
    return E_OK;
}

/*
 * xgetdir(buf,drv): return the text of the current dir on 'drv' into buf.
 *
 * This call is bad because it doesn't take the SIZE of the buffer as an arg.
 * We fixed this by adding a new call: Dgetnpath(buf,n,drv) where n is the
 * size of the buffer.  xgetdir calls xgetndir with a LARGE length arg.
 *
 * This code is recursive, and its depth is the depth of your current 
 * directory on that drive.  It could create the text backwards, then reverse
 * it in place, if that would help.  Returns EGENRL if the buffer isn't
 * big enough;
 */

long
xgetdir(buf,drv) /*+ return text of current dir into specified buffer */
char *buf;
int drv;
{
  return xgetndir(buf,0x7fffffffL,drv);
}

long
xgetndir(buf,len,drv)
char *buf;
ulong len;
uint drv;
{
    DIR dir;
    long err;

    if (drv == 0) drv = run->p_curdrv;
    else {
	drv--;
	if (drv >= MAXDEVS) return EDRIVE;
    }

    if (ckdrv(drv)) return EPTHNF;

    dir.dir_dev = drv;
    dir.dir_clust = run->p_curdir[drv];
    if (err = dirfirst(&dir,&drvtbl[drv])) return err;

    *buf = '\0';
    if ((err = _getndir(&buf,len,&dir,&drvtbl[drv])) < 0) 
	return err;
    return E_OK;
}

/*
 * recursive get-current-directory call
 *
 * First call _getndir on the parent of the dir in 'dir,'
 * then put this dir's name in at buf.  Fail if no room.
 * Assume that 'dir' is fresh coming in, and that its FCB
 * points to the "." entry.
 *
 * Each stage returns the remaining len, which is to say
 * the len arg it got minus the length of the name it added.
 * Returns a negative error code for errors.
 */

long
_getndir(pbuf,len,dir,dmd)
char **pbuf;
ulong len;
DIR *dir;
DMD *dmd;
{
    DIR dir2;
    long err;
    uint swapped_cl;
    char *buf, *src;
    uint count;
    FCB *fcb;

    /* return now without doing anything if root dir */
    if (!dir->dir_clust) return len;

    /* set up dir2 as dir's parent */
    dir2.dir_dev = dir->dir_dev;
    dir2.dir_clust = dir->dir_fcb[1].f_clust;	/* f_clust of .. slot */
    swp68(dir2.dir_clust);

    /* "freshen" this new dir */
    if (err = dirfirst(&dir2,dmd)) return err;
    if ((len = _getndir(pbuf,len,&dir2,dmd)) <= 0) return len;

    /* now *pbuf points to the place where dir's name should go. */
    /* scan in dir's parent for a valid slot whose startcl is dir's cl */
    swapped_cl = dir->dir_clust;
    swp68(swapped_cl);

    for (err = dirfirst(&dir2,dmd), fcb = dir2.dir_fcb;
	 (!err && 
	  fcb->f_name[0] != 0 && 
	  fcb->f_name[0] != ERASED &&
	  fcb->f_clust != swapped_cl);
	err = dirnext(&dir2,dmd), fcb = dir2.dir_fcb) /* empty */ ;

    if (fcb->f_name[0] == 0 || err == ENMFIL) {
	/* return ERROR if you fell off without finding the dir! */
	/* it's not really an EINTRN since it's external */
	return ERROR;
    }
    if (err) return err;

    buf = *pbuf;
    *buf++ = SLASH;
    len--;
    src = fcb->f_name;

    for (count = (len < 8 ? len : 8);
	 count && *src != ' ';
	 *buf++ = *src++, --len, --count) /* empty */;

    if (!len) {
	/* null-terminate & return -- buffer too small */
	*buf = 0;
	return 0;
    }

    if (*src != ' ') *buf++ = '.', --len;

    for (count = (len < 3 ? len : 3);
	 count && *src != ' ';
	 *buf++ = *src++, --len, --count) /* empty */;
    *buf = 0;
    return len;
}

/*
 * mkdir: create directory.
 */

long
xmkdir(s)
char *s;
{
    DIR dir;
    long err;
    uint cl;
    uint rec;
    DMD *dmd;
    FCB *fcb;
    FCB fcbhold;
    static char dotdotstr[12] = "..         ";
    int i;
    BCB *bcb;
    uint dirtime, dirdate;

    /* allocate a cluster, initialize it, ixcreat the file, and link them */

    /* first, call fn2dir so we know where this *will* go. */
    /* Fail on anything but EFILNF. */

    if ((err = fn2dir(&s,&dir,FA_NORM)) != EFILNF) {
	if (!err) return EACCDN;
	else return err;
    }

    dmd = &drvtbl[dir.dir_dev];

    /* reset dir to first slot of dir this will go in, to get date & time */
    if (dir.dir_clust) {
	if (err = dirfirst(&dir,dmd)) return err;
	fcbhold = *dir.dir_fcb;		    /* structure copy of first slot */
    }
    else {
	/* parent is root directory */
	fcbhold.f_time = fcbhold.f_date = fcbhold.f_clust = 0;
    }

    /* allocate a new cluster */

    newcl = TRUE;
    if (!(cl = nextcl(0,dmd,TRUE,NULL))) return ERROR;
    newcl = TRUE;
    rec = realcl2rec(cl,dmd);

    /* use the special flag to getrec: don't pre-read the sector */
    fcb = getrec(rec,dmd,2,NULL);

    /* make 'dot' entry */
    xmovs(11,dotdotstr,fcb->f_name);
    fcb->f_name[1] = 0x20;
    fcb->f_attrib = FA_SUBDIR;
    for (i=10; i; fcb->f_fill[--i] = 0) ;

    /* copy current time & date to temps, use them now & later.	   */
    /* You can get in trouble if midnight happens btw these insns! */
    dirtime = realtime;
    dirdate = realdate;
    swp68(dirtime);
    swp68(dirdate);
    fcb->f_time = dirtime;
    fcb->f_date = dirdate;
    swp68(cl);
    fcb->f_clust = cl;
    fcb->f_fileln = 0;

    /* make 'dotdot' entry */
    fcb++;
    xmovs(11,dotdotstr,fcb->f_name);
    fcb->f_attrib = FA_SUBDIR;
    for (i=10; i; fcb->f_fill[--i] = 0) ;
    fcb->f_time = fcbhold.f_time;
    fcb->f_date = fcbhold.f_date;
    fcb->f_clust = fcbhold.f_clust;
    fcb->f_fileln = 0;

    /* zero out the rest of this record */
    fcb++;
    clear(fcb,((char *)fcb)+dmd->m_recsiz);

    /* zero out the rest of the cluster */
    for (i=dmd->m_clsiz-1; i; --i) {
	fcb = getrec(rec+i,dmd,2,&bcb);		/* special flag */
	clear(fcb,((char *)fcb)+dmd->m_recsiz);
    }

    /* flush the new directory's records. The arg is the last record we */
    /* cleared, but it'll flush them all because of flush's semantics.  */
    flush(bcb);

    /* code stolen from ixcreate; at this point we know what dir */
    /* to look for a slot in.  If dirslot fails, the cluster we just */
    /* initialized becomes a lost cluster.  Boo hoo. */

    /*
     * Scan for empty space in the directory file (find an empty slot); 
     * grow directory if no free slots left. This can fail.  Note that
     * dir doesn't have to be fresh on input, but definitely is on out.
     */

    if (err = dirslot(&dir)) return err;

    /*
     * write the new file info there, flush back to disk.
     */

    fcb = dir.dir_fcb;

    /* 's' below is what's left of s from fn2dir(&s,...) */
    if (err = name2fcb(s,NULL,fcb)) return err;

    fcb->f_attrib = FA_SUBDIR;
    for (i=10; i; fcb->f_fill[--i] = 0) ;
    fcb->f_time = dirtime;
    fcb->f_date = dirdate;

    /* set the starting-cluster field of the entry (cl is already swapped) */
    fcb->f_clust = cl;
    fcb->f_fileln = 0;

    dirdirty(&dir);
    fatdirty(dir.dir_dev);
    return E_OK;
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
 * NOTE: check to see if it's somebody's current directory by going through
 * all basepages from 'run' up; later, when there are more processes, this
 * will have to change.  Presumes that exec doesn't "inherit" directories
 * until "go" time, not at "load" time.
 *
 * There are some systems now which change 'run' to implement some limited
 * multi-tasking. These make it possible to remove a directory which is
 * somebody else's current directory.  One way for a user to guard against
 * this is not to have empty directories as their current directories very
 * much.  Still, rm -r will do it.  This is deadly, because your
 * run->p_curdir array isn't checked for validity. [dirfirst could..]
 */
long
xrmdir(p)
char *p;
{
    DIR dir, dir2;
    PD **ppd, *pd;
    long err;
    uint cl;
    DMD *dmd;
    uint dev;
    char c;

    DBCMD(1,"print xrmdir -s (lpeek (+ `a6 8));_c");

    if (err = fn2dir(&p,&dir,FN_NORM)) {
	if (err == EFILNF) return EPTHNF;
	else return err;
    }

    if (!(dir.dir_fcb->f_attrib & FA_SUBDIR)) return EACCDN;

    dev = dir.dir_dev;
    cl = dir.dir_fcb->f_clust;
    swp68(cl);

    /* check to see that nobody has cl as his current dir */
    for (ppd = &pdtab[0], pd = *ppd; ppd < &pdtab[NUMPDS]; pd = *(++ppd)) {
	if (pd && pd->p_curdir[dev] == cl) return EACCDN;
    }

    dmd = &drvtbl[dev];

    /* make 'dir2' refer to the start of the dir to remove */
    dir2.dir_dev = dev;
    dir2.dir_clust = cl;
    if (err = dirfirst(&dir2,dmd)) return err;

    /* advance to .. entry before starting loop */
    if (err = dirnext(&dir2,dmd)) return err;

    /*
     * see if there are any files in this dir (except . and ..) (this loop
     * is structured this way for efficiency & clarity) (so don't give me
     * any heat!)
     */

    while (1) {
	if ((err = dirnext(&dir2,dmd)) != 0) break;
	c = dir2.dir_fcb->f_name[0];
	if (!c) break;
	if (c != ERASED) return EACCDN;
    }

    if (err && err != ENMFIL) return err;

    /* ok, dir is empty: freshen the parent and call ixdel */
    dir2dir(&dir);
    return ixdel(&dir);
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
xsfirst(name,att)
char *name;
int att;
{
    return(ixsfirst(name,att,(DTA *)run->p_xdta));
}

long
ixsfirst(name,att,dta)
char *name;
int att;
DTA *dta;
{
    DIR dir;
    FCB fcb;
    DMD *dmd;
    long err;
    uint m = 0;

    if (err = fn2dir(&name,&dir,FN_EARLY)) return err;

    /* stuff the last part of the name and the attribs into an FCB */
    if (err = name2fcb(name,NULL,&fcb)) return err;
    fcb.f_attrib = att;

    dmd = &drvtbl[dir.dir_dev];
    for (err = dirfirst(&dir,dmd);
	 !err && dir.dir_fcb->f_name[0] && !(m = wmatch(&fcb,dir.dir_fcb));
	 err = dirnext(&dir,dmd)) /* empty loop */ ;

    if (err == ENMFIL || !m) return EFILNF;
    if (err) return err;

    /* fill in the invariants of the search in the DTA */

    xmovs(11,fcb.f_name,dta->dta_sname);
    dta->dta_attr = att;
    dta->dta_dev = dir.dir_dev;
    dta->dta_clust = dir.dir_clust;

    /* now fill in the things that can change, both user and system */
    filldta(dta,&dir);

    return E_OK;
}

/*
 * xsnext
 */

long
xsnext() /*+ search next, return into dta */
{
    DIR dir;
    FCB fcb;
    DTA *dta;
    DMD *dmd;
    long err;
    FCB *pfcb;
    char c;

    dta = run->p_xdta;

    /* fill FCB with search info from DTA */

    if (ckdrv(dta->dta_dev)) return EDRIVE;

    xmovs(11,dta->dta_sname,fcb.f_name);

    fcb.f_attrib = dta->dta_attr;
    dir.dir_dev = dta->dta_dev;
    dir.dir_clust = dta->dta_clust;
    dir.dir_curcl = dta->dta_curcl;
    dir.dir_recno = dta->dta_recno;
    dir.dir_recoffs = dta->dta_recoffs;

    dmd = &drvtbl[dir.dir_dev];
    dir2dir(&dir);

    /* this loop is structured this way for efficiency in */
    /* the face of a compiler that doesn't seem to make the */
    /* favorable assumptions that I would like. */

    while (1) {
	err = dirnext(&dir,dmd);
	if (err) return err;	    /* includes ENMFIL */
	pfcb = dir.dir_fcb;
	c = pfcb->f_name[0];
	if (c == 0) return ENMFIL;
	if (c != ERASED && wmatch(&fcb,pfcb)) {
	    filldta(dta,&dir);
	    return E_OK;
	}
    }
}

voidfn
filldta(dta,dir)
DTA *dta;
DIR *dir;
{
    FCB *fcb;
    int count;
    char *buf, *src;
    DFD *dfd;

    dta->dta_curcl = dir->dir_curcl;
    dta->dta_recno = dir->dir_recno;
    dta->dta_recoffs = dir->dir_recoffs;

    /* move an FCB-style name into a normal string in DTA */

    src = dir->dir_fcb->f_name;
    buf = dta->fname;

    for (count = 8;
	 count && *src != ' ';
	 *buf++ = *src++, --count) /* empty */;

    if (*src != ' ') *buf++ = '.';

    for (count = 3;
	 count && *src != ' ';
	 *buf++ = *src++, --count) /* empty */;
    *buf = 0;

    fcb = dir->dir_fcb;

    /* check for an open file with this rec/recoffs */

    if (dfd = getdfd(dir)) {
	/* take date, time, length, and attr from open file */
	dta->ftime = dfd->dfd_time;
	dta->fdate = dfd->dfd_date;
	dta->flength = dfd->dfd_fileln;
	dta->fattrib = dfd->dfd_attrib;
    }
    else {
	/* fill in date, time, length, and attr from FCB */
	dta->ftime = fcb->f_time;
	dta->fdate = fcb->f_date;
	dta->flength = fcb->f_fileln;
	dta->fattrib = fcb->f_attrib;
	swp68l(dta->flength);
    }
    swp68(dta->ftime);
    swp68(dta->fdate);
}
