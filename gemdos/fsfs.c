/*
***************************     FSFS.C     ******************************
*
* $Revision: 2.5 $	$Source: /u2/MRS/osrevisions/gemdos/fsfs.c,v $
* =======================================================================
* $Author: apratt $ 	$Date: 90/08/03 13:41:17 $    $Locker:  $
* =======================================================================
*
* $Log: fsfs.c,v $
* Revision 2.5  90/08/03  13:41:17  apratt
* TTOS FINAL RELEASE
* 
* Revision 2.4  90/05/21  12:51:55  apratt
* Added call to flushall() in ixclose rather than having knowledge of
* the buffer structure here.
* 
* Revision 2.3  89/04/17  17:14:26  kbad
* YA header change
* 
* Revision 2.2  89/03/31  04:10:33  kbad
* Don't allow Dcreate to clobber existing file (in ixcreat).
* 
* Revision 2.1  89/02/21  17:19:38  kbad
* *** TOS 1.4  FINAL RELEASE VERSION ***
* 
* Revision 1.9  89/02/21  15:22:19  kbad
* Fixed write of tmpofd (should have been &tmpofd.o_time).
* 
* Revision 1.8  89/02/21  12:29:28  apratt
* Fixed a bug: in close, strtcl & fileln were swapped, written, and
* un-swapped.  If the write failed, they stayed swapped.  Now they're
* copied to a temp OFD (with time & date), swapped, and the temp one
* is written.
* 
* Also changed/sped up the attribute byte stuff, by using ixread's
* trick of returning a pointer to the byte in question in the disk buffers.
* 
* Revision 1.7  88/10/11  15:49:20  apratt
* Added code to handle create of volume labels: deny if not in root dir,
* and delete any other volume label when you create one.  This works
* fine, and lets you create a volume label with the same name as a file,
* or vice-versa, with impunity.  Also, the old-style trick of using
* Fcreate("label",0); Fdelete("label"); Fcreate("newlabel",8) still works.
* (The create/delete pair is useless, but harmless.)
* 
* Revision 1.6  88/10/10  19:06:11  apratt
* Return EACCDN when using Fattrib to set label bit.
* (Used to allow labels but not subdirs or other illegal bits.
* Now labels are totally out of the purview of the OS, except Fsfirst.)
* 
* Revision 1.5  88/09/12  11:55:35  apratt
* Found & killed a bug: Frename("c:\\foo\\x","c:\\") failed BADLY.
* Note no filename after the target c:\.  Now this case is checked.
* The greater symptom is that there should be better validity checking
* of pathnames and filenames.
* 
* Revision 1.4  88/08/08  17:41:02  apratt
* Added call to sftprobe() before Fcreate goes too far.. Before, it
* created the file, THEN said it was out of handles.
* 
* Revision 1.3  88/06/13  15:06:10  apratt
* Header style change
* 
* Revision 1.2  88/05/02  12:43:44  apratt
* Added dirty test before calling flush in close, so clean buffers don't
* get invalidated.  The only place where clean buffers need to be
* invalidated is when a multi-sector write overlaps one, and that happens
* only in xrw.
* 
* Revision 1.1  88/04/26  14:48:20  apratt
* Version used 4/22/88 to make test ROMs, PLUS Frename bug fix.
*
*************************************************************************
*/

/****************************************************************************\
* 									     *
* GEMDOS File System File Operations					     *
* (C)1986 Atari Corp.							     *
* 									     *
* ---- Edit history (reverse order, please): ------------------------------  *
* 									     *
* 19-Apr-1988 akp	Fixed directory rename code (didn't work when the    *
*			dir in question was not in the current directory).   *
* 18-Apr-1988 akp	Fixed Fdatime code -- much better now.		     *
* 23-Mar-1988 akp	Now I realize why the volume label is so strange:    *
*			it's not in the same namespace as the files.  That's *
*			why you can't change it, delete it, or un-label that *
*			file: it might collide with an existing file of the  *
*			same name!  So:					     *
*			* back out deny of Fcreate of same name as label.    *
*			* back out allowing Fattrib of label.		     *
*			* leave in allowing Fattrib to SET label attr if     *
*			  it's the only bit set, and finding the label if    *
*			  that's the only bit in Fsfirst.		     *
* 22-Mar-1988 akp	Deny Fcreate of file with same name as volume label. *
*			Deny xchmod changes to subdirs and those which set   *
*			the subdir bit.  Recoded to allow changes to all     *
*			other files (incl. volume label).  Now returns mode  *
*			of subdirs, rather than saying "file not found".     *
*			Also deny if 0x80 is set and isn't the only bit.     *
*			Fixed fatfinger: attr |= FA_ARCHIVE not = in ixcreat *
* 11-Mar-1988 akp	BUG in xrename -- allows you to rename a file to the *
*			same name as a folder! (True in old roms) -- fixed.  *
*			Added drename into this file.			     *
* 10-Mar-1988 akp	Added check for Frename of a directory -- call	     *
*			drename(oldpath, newname) if so.		     *
* 29-Feb-1988 akp	Fixed ixdel so it stops clearing FAT entries at (and *
*			leaves untouched) values in [fff0..fffe], to leave   *
*			bad-sector marks which have crept into files.        *
* 18-Feb-1988 akp	Fixed Fdatime so it doesn't swap the user's input    *
*			when setting. (Used to leave user's input swapped.)  *
* 17-Feb-1988 akp	Lintified.					     *
*			Bug: xrename doesn't check return code from xcreat.  *
* 03-Feb-1988 akp	Cleaned up REG declarations.			     *
*			Replaced ixwrite with a macro.			     *
* 01-Feb-1988 akp	Backed out O_WRITTEN code.  Now archive bit is set   *
*			in directory only when O_DIRTY was set previously,   *
*			which is when length or start cluster changed.	     *
*			If this works, I may set O_DIRTY on any write.	     *
* 12-Jan-1988 akp	Removed panics: MGET panics when it fails.	     *
* 02-Dec-1987 akp	Backed out 0xfff0..0xffff check because		     *
*			root directory "clusters" fall in this range!  What  *
*			a lose!  Just don't change nonzero FAT entries	     *
*			to anything fff0..ffff!				     *
* 13-Oct-1987 akp	Changed check for -1 in cluter to check for any	     *
*			special FAT value ([0xfff0..0xffff]).		     *
* 11-Oct-1987 akp	Reversed order of flush in ixclose to flush data     *
*			before FAT buffers.				     *
* 22-Oct-1987 akp	Lintified.					     *
* 13-Oct-1987 akp	Added check: don't set ARCHIVE bit if subdirectory.  *
* 07-Oct-1987 akp	Added check of return from ixdel in ixcreate.	     *
*			THIS FIXES THE DUPLICATE-FILE BUG.		     *
* 25-Sep-1987 akp	Added newcl flag setting to all cluster call loops.  *
* 22-Sep-1987 akp	Added setting O_WRITTEN flag in ixwrite, and	     *
*			checking that in ixclose.  If O_WRITTEN, ixclose     *
*			sets the ARCHIVE bit in the attribute byte.	     *
* 21-Sep-1987 akp	Added setting of FA_ARCHIVE bit for file create.     *
* 17-Jan-1986 lmd	Commented and prettified from Digital Research	     *
* 			source code.					     *
* 30-Jan-1986 lmd	Broken out from old FS.C			     *
* 									     *
\****************************************************************************/

#include "fs.h"
#include "gemerror.h"
#include "fsdecl.h"


/*
	Error returns
		EINTRN

	Last modified	SCC	10 Apr 85

NOTE:	I'm not sure that returning immediatly upon an error from ixlseek()
	is the right thing to do.  Some data structures may not be updated
	correctly.  Watch out for this!
	Also, I'm not sure that the EINTRN return is ok.
*/

long
ixclose(x_fd, part)
OFD *x_fd;			/* file to close */
int part;			/* flags */
{
  REG OFD *fd;
  REG OFD *p;
  REG OFD **q;
  REG long tmp;
  REG int i;
  BCB *b;
  OFD tmpofd;

  fd = x_fd;

  /*
   *  Update FCB in directory if the file length
   *  or starting cluster changed.
   *
   */

  if (fd->o_flag & O_DIRTY)
    {
      ixlseek(fd->o_dirfil,fd->o_dirbyt+22); /* seek to spot in FCB */

      tmpofd.o_time = fd->o_time;
      tmpofd.o_date = fd->o_date;
      tmpofd.o_strtcl = fd->o_strtcl;
      tmpofd.o_fileln = fd->o_fileln;

      swp68(tmpofd.o_strtcl);	/* convert to 8086 format */
      swp68l(tmpofd.o_fileln);

      /*
       *  Directories always APPEAR to have a file size of zero
       *  (but normal files don't...)
       */
      if (part & CL_DIR)
	{			/* munge apparent dir file size */
	  tmpofd.o_fileln = 0;
	  ixwrite(fd->o_dirfil, 10L, &tmpofd.o_time);
	}
      else {
	char *p;
	ixwrite(fd->o_dirfil, 10L, &tmpofd.o_time);

	/* get ptr to attr byte in (now-dirty) disk buffer */
	ixlseek(fd->o_dirfil,fd->o_dirbyt+11);	/* seek to attrib byte */
	p = (char *)ixread(fd->o_dirfil,1L,NULPTR);
	if (!(*p & (FA_SUBDIR | FA_ARCHIVE | FA_LABEL))) {
	    *p |= FA_ARCHIVE;	/* change byte in disk buffer in place */
	}
      }

      fd->o_flag &= ~O_DIRTY;	/* AKP: clear the dirty bit */
    }

  /*
   *  "Full" close
   *    - search for file in DND's open-list
   *    - rip it out
   */
  if ((!part) || (part & CL_FULL))
    {
      q = &fd->o_dnode->d_files;
      for (p = *q; p ; p = *(q = &p->o_link))
	if (p == fd)
	  break;

      /*  $BUG$
       *  If someone else also has this file open
       *  then just ripping it out will lose big.
       */
      if (p)
	*q = p->o_link;
      else
	return EINTRN;		/* "cannot happen" */

    }

  /* 
   * Flush all dirty buffers on all drives: 
   * Fclose on a file is guaranteed to do this.
   */

  flushall();

  return(E_OK);
}


/*
 *  Make Open File Descriptor node (OFD)
 *  and return a pointer to it.
 *
 */
OFD
*makofd(x_p)
DND *x_p;
{
  REG DND *p;
  REG OFD *f;

  p = x_p;

  f = MGET(OFD);		/* panics when it fails */
      f->o_strtcl = p->d_strtcl;
      f->o_fileln = 0x7fffffffL;
      f->o_dirfil = p->d_dirfil;
      f->o_dnode = p->d_parent;
      f->o_dirbyt = p->d_dirpos;
      f->o_date = p->d_date;
      f->o_time = p->d_time;
      f->o_dmd = p->d_drv;
      f->o_link = NULL;		/* AKP */
      f->o_flag = 0;		/* AKP */
  return f;
}


/*
 *  Read from file
 *
 */
long
ixread(x_p, x_len, ubufr)
OFD *x_p;		/* open file */
long x_len;		/* #bytes to read */
char *ubufr;		/* -> user buffer */
{
  REG OFD *p;
  REG long len;
  REG long maxlen;

  p = x_p;
  len = x_len;

  /*
   *  Make sure file not opened mode=1 (write-only)
   */
#ifdef RO_FASCISM
  if (p->o_mod == 1)		/* $BUG$ */
    return (EACCDN);
#endif

  if (len > (maxlen = p->o_fileln - p->o_bytnum))
    len = maxlen;		/* ensure request is in range */

  if (len > 0)			/* only bother with non-zero requests */
    return len = xrw(0, p, len, ubufr, xfr2usr);

  return len;
}


/*
 *  Write to file
 *
 *  I made this a macro once, but it's smaller as a procedure call. (AKP 8/88)
 */
long
ixwrite(p, len, ubufr)
OFD *p;				/* open file */
long len;			/* #bytes to write */
char *ubufr;			/* -> user buffer */
{
  return xrw(1, p, len, ubufr, usr2xfr);
}

/*
 *  Make open file for SFT handle h
 *
 */
long
makopn(x_f, dn, h, mod)
FCB *x_f;		/* raw FCB */
DND *dn;		/* directory file is in */
int h;			/* handle number to use */
int mod;		/* open mode */
{
  REG FCB *f;
  REG OFD *p;
  OFD *p2;
  REG DMD *dm;

  f = x_f;

  dm = dn->d_drv;

  p = MGET(OFD);

  /*
   *  Setup OFD and install in SFT
   */
  p->o_mod = mod;		/* open mode */
  p->o_dmd = dm;		/* -> DMD */
  sft[h-NUMSTD].f_ofd = p;	/* setup ptr in system file table */
  p->o_usecnt = 0;		/* reference (open) count = 0 */
  p->o_curcl = 0;		/* current cluster = 0 */
  p->o_curbyt = 0;		/* current file pos = 0 */
  p->o_dnode = dn;		/* -> directory file is in */
  p->o_dirfil = dn->d_ofd;	/* -> directory file */
  p->o_dirbyt = dn->d_ofd->o_bytnum - 32; /* = offset of FCB in directory */

  /*
   *  Hook into directory's open file list
   */
  for (p2 = dn->d_files; p2; p2 = p2->o_link)
    if (p2->o_dirbyt == p->o_dirbyt)
      break; /* same dir, same dcnt */

  p->o_link = dn->d_files;
  dn->d_files = p;

  if (p2)
    { /* steal time,date,startcl,fileln and add to thread */
      xmovs(12, &p2->o_time, &p->o_time);
      p2->o_thread = p;
    }
  else
    {
      p->o_strtcl = f->f_clust;
      swp68(p->o_strtcl);
      p->o_fileln = f->f_fileln;
      swp68l(p->o_fileln);
      p->o_date = f->f_date;
      p->o_time = f->f_time;
    }

  return(h);
}


/*
 *  Create a file
 */
long
ixcreat(name,attr)
char *name;
char attr;
{
  REG DND *dn;
  REG FCB *f;
  REG OFD *fd;
  char *s,n[2],a[11];
  REG int i;
  REG int f2;
  long pos;
  long rc;

  n[0] = 0xe5;
  n[1] = 0;

  /*
   *  Find path;
   *  reject illegal files (empty, or starting with dots)
   */
  if (!(dn = findit(name,&s,0)))
    return(EPTHNF);

  if (eordot(s, '\0'))
    return(EPTHNF);

  /*
   * make sure there's an empty slot for handle (AKP 8/88)
   * Do this before deleting the file! (AKP 10/88)
   */

  if (sftprobe() < 0) return (ENHNDL);

  /*
   *  Make dirfil OFD if one isn't installed there
   */
  if (!(fd = dn->d_ofd))
    dn->d_ofd = (fd = makofd(dn));

  /*
   *  Check if file already exists;
   *  remove it if it does.
   */
  pos = 0;
    if (attr == FA_LABEL) {
    /* create a volume label: first, make sure we're in the root directory */
    /* (make sure this dir's drive's root dir is this dir) */

    if (dn->d_drv->m_dtl != dn) return EACCDN;

    /* second, find & delete any existing volume label */
    if (f = scan(dn,"*.*",FA_LABEL,&pos)) {
	/* there's a volume label here already: delete it. */
	pos -= 32;
	if (rc = ixdel(dn,f,pos)) return rc;
    }
    else pos = 0;
  }
  else if (f = scan(dn,s,~FA_LABEL,&pos))	/* don't match label */
    {
    /* don't create file over existing RO or SUBDIR, dir over existing file */
      if ( (f->f_attrib & (FA_RO | FA_SUBDIR)) || (attr == FA_SUBDIR) )
	return(EACCDN);
      pos -= 32;
      if (rc = ixdel(dn, f, pos)) return rc;
    }
  else
    pos = 0;

  /*
   * Scan for empty space in the directory file (find
   * an empty slot); grow directory if no free slots left.
   */
 rescan:
  if (!(f = scan(dn,n,-1,&pos)))
    {
      /* grow directory (append a cluster) */
      if (fd->o_curcl < 0)
	return(EACCDN);		/* can't grow root dir */

      newcl = TRUE;		/* AKP: new cluster call */
      rc = nextcl(fd, 1);	/* append cluster */
      newcl = TRUE;		/* AKP: just in case */
      if (rc)
	return(EACCDN);

      dirinit(dn);		/* zero new cluster */
      pos = 0;			/* back to the start */
      goto rescan;
    }

  builds(s, a);

  /*
   *  Fill in FCB
   */
  /* set ARCHIVE bit on files except subdirs & labels */
  if (!(attr & (FA_SUBDIR | FA_LABEL))) attr |= FA_ARCHIVE;
  f->f_attrib = attr;
  for (i=0; i<10; i++)		/* clobber "unused" parts */
    f->f_fill[i] = 0;

  f->f_time = time;		/* copy and byteswap time and date */
  swp68(f->f_time);
  f->f_date = date;
  swp68(f->f_date);

  f->f_clust = 0;		/* no starting cluster */
  f->f_fileln = 0;		/* file length = zero */

  pos -= 32;			/* backup to FCB in dir file */
  ixlseek(fd, pos);
  ixwrite(fd, 11L, a);		/* write name, set dirty flag */
  ixclose(fd, CL_DIR);		/* partial close to flush dirty dir sector */
  ixlseek(fd, pos);
  s = ixread(fd, 32L, NULPTR);
  f2 = rc = opnfil(s, dn, (f->f_attrib & FA_RO) ? 0 : 2);

  if (rc < 0)
    return(rc);

  getofd(f2)->o_flag |= O_DIRTY;	/* getofd can't fail */

  return(f2);
}


/*
 *  Open file
 *
 */
long
ixopen(name, mod)
char *name;
int mod;
{
  REG FCB *f;
  REG DND *dn;
  char *s;
  long pos;

  /*
   *  Find path and scan for filename
   */
  if (!(dn = findit(name, &s, 0)))
    return(EFILNF);

  pos = 0;
  if (!(f = scan(dn, s, FA_NORM, &pos)))
    return(EFILNF);

  /*
   *  Check if file is read-only
   *  (and open mode != READ)
   */
  if ((f -> f_attrib & 1) && (mod != 0))
    return (EACCDN);

  return opnfil(f, dn, mod);
}


/*
 *  Get/Set file attributes;
 *
 */
long
xchmod(p,wrt,attr)
char *p;			/* -> filename */
char attr;			/* attribute byte */
int wrt;			/* 0:get, 1:set */
{
  REG OFD *fd;
  REG DND *dn;
  char *s;
  long pos;
  char oattr;

  /*
   *  Get DND containing file
   *  and scan for the file entry
   */
  pos = 0;
  if (!(dn = findit(p,&s,0)) ||
      !scan(dn,s,FA_NORM,&pos))	/* won't find directories or labels */
    return(EFILNF);

  /*
   *  Backup in dirfile to attribute byte
   */
  pos -= 21;
  fd = dn->d_ofd;
  ixlseek(fd, pos);

  ixread(fd,1L,&oattr);			/* get old attribute */
  if (!wrt) return ((long)oattr) & 0xff;
  else {
    /* deny changes which set subdir, label, or illegal bits */
    /* (that is, only allow ARCHIVE, SYSTEM, HIDDEN, and RO bits; */
    /* these bits happen to be FA_NORM.) */
    /* this used to allow setting the LABEL bit -- no more. AKP 10/88 */

    if (attr & ~FA_NORM) return EACCDN;

    ixlseek(fd, pos);
    ixwrite(fd, 1L, &attr);		/* write attribute byte */
    ixclose(fd, CL_DIR);		/* flush dirty directory sector */
  }

  return ((long)attr) & 0xff;
}


/*
 *  Fdatime, Get/Set File Date and Time
 *
 *  $BUG$: this function is rumored not to work
 *
 * 04/18/88 AKP This function didn't check getofd() for zero return
 * (meaning invalid handle).
 *
 * Megamax relies on this function leaving the input buffer alone on
 * a read when the handle isatty, and on changing it (with the file's
 * info) when the handle !isatty.  We can preserve that and still
 * return EIHNDL with the handle refers to a tty.
 *
 * This function used to act on the directory itself, causing an
 * unnecessary disk hit.  Now it just modifies the ofd, which gets
 * written (unmodified) when the file is closed.
 *
 * This function and its documentation don't match: the docs say
 * the handle arg comes first.  Since we can't change the code, we
 * change the documentation.  ...and so it goes.
 *
 * Changed this function name from the nonsensical xgsdtof().
 */

long
xdatime(buf, h, wrt)
int *buf;			/* -> user buffer */
int h;				/* file handle */
int wrt;			/* 0:get, 1:set */
{
  REG OFD *f;
  REG OFD *fd;
  int t[2];			/* buffer to hold user input for swapping */

/*
   *
   *  Get directory file,
   *  see to FCB's date+time area
   * 
  f = getofd(h);

  fd = f->o_dirfil;
  ixlseek(fd,f->o_dirbyt + 22);

  if (!wrt) {			* read date+time into user buffer *
    ixread(fd, 4L, buf);
    swp68(buf[0]);		* convert 68000 <---> 8086 formats *
    swp68(buf[1]);
  }
  else {
      t[0] = buf[0];
      t[1] = buf[1];
      swp68(t[0]);
      swp68(t[1]);
      ixwrite(fd, 4L, t);	* write date+time to file *
      ixclose(fd, CL_DIR);	* flush dirty directory sector *
  }
*/
  /*
   * NEW CODE (AKP): For a read, copy the time & date from the ofd.
   * For a write, copy the user's time & date to ALL OFD'S WITH THE
   * SAME STARTING CLUSTER.  That way, a write to one handle's date&time
   * will read back the same way from another handle.
   *
   * makopn already takes an existing ofd's time&date over the one
   * on disk, so this works fine.  The only place where this
   * doesn't work is when you Fsfirst while the file is still open...
   * So what, big deal.
   */

  if (!(f = getofd(h)) || ((long)f < 0)) return (EIHNDL);

  if (!wrt) {
    buf[0] = f->o_time;
    buf[1] = f->o_date;
    swp68(buf[0]);
    swp68(buf[1]);
    return E_OK;
  }

  /* else it's a write */

  t[0] = buf[0];
  t[1] = buf[1];
  swp68(t[0]);
  swp68(t[1]);
  for (fd = f->o_dnode->d_files; fd; fd = fd->o_link) {
    if (fd->o_strtcl == f->o_strtcl) {
	fd->o_time = t[0];
	fd->o_date = t[1];
	fd->o_flag |= O_DIRTY;
    }
  }
  return E_OK;
}


/*
 *  Delete a file
 *
 */
long
xunlink(name)
char *name;
{
  REG DND *dn;
  char *s;
  long pos;
  REG FCB *f;

  /* first find path */

  /*
   *  Find path and scan for filename
   */
  pos = 0;
  if (!(dn = findit(name,&s,0)) ||
      !(f = scan(dn,s,FA_NORM,&pos)))	/* don't match directories or label */
    return(EFILNF);

  /*
   *  Refuse if file is read-only
   */
  if (f->f_attrib & FA_RO)
    return(EACCDN);

  /*
   *  Back up (in directory file) and clobber the thing
   */
  pos -= 32;
  return(ixdel(dn,f,pos));
}


/*
 *  Internal version of delete-file
 *  (called by ixcreat(), xunlink() and xrmdir()).
 */
long
ixdel(dn, f, pos)
DND *dn;			/* directory file is contained in */
FCB *f;				/* -> file's FCB */
long pos;			/* position of file in directory file */
{
  REG DMD *dm;
  REG unsigned int n;		/* AKP: MUST be unsigned */
  REG unsigned int n2;		/* AKP: MUST be unsigned */
  REG OFD *fd;
  char c;
  unsigned int temp;

  /*
    Traverse the list of files open for this directory node.

    If a file is found that has the same position in the directory as the one
    we are to delete, then scan the system file table to see if this process
    is then owner.  If so, then close it, otherwise abort.

    NOTE that both 'for' loops scan for the entire length of their respective
    data structures, and do not drop out of the loop on the first
    occurence of a match.
    */

  for (fd = dn->d_files; fd; fd = fd->o_link)
    if (fd->o_dirbyt == pos)
      for (n = 0; n < OPNFILES; n++)
	if (sft[n].f_ofd == fd)
	  {
	    if (sft[n].f_own == run)
	      ixclose(fd,0);
	    else
	      return(EACCDN);
	  }
  /*
   * Traverse this file's chain of allocated clusters, freeing them.
   * Note: stop at (and don't touch) entries in the range [0xfff0..0xfffe],
   * and also stop if the entry is 0 (possible for inconsistent filesystems).
   */
  dm = dn->d_drv;
  temp = f->f_clust;
  swp68(temp);
  n = temp;

  newcl = TRUE;			/* AKP: new loop of cluster calls */
  while (n && n != 0xffff)
    {
      n2 = getcl(n,dm);
      if (!n2 || (n2 >= 0xfff0 && n2 != 0xffff)) {
      	/* bad sector mark or other reserved situation: stop now. */
      	break;
      }
      else
      	clfix(n,0,dm);
      n = n2;
    }
  newcl = TRUE;			/* AKP: set this just in case */

  /*
   * Mark the directory entry as erased.
   */
  fd = dn->d_ofd;
  ixlseek(fd,pos);
  c = 0xe5;
  ixwrite(fd,1L,&c);
  ixclose(fd,CL_DIR);

  /*
   * that the preceding routines that do physical disk operations will
   * 'longjmp' on failure at the BIOS level, thereby allowing us to
   * simply return with E_OK.
   */

  return OK;
}


/*
 *  Rename a file
 */
long
xrename(n, p1, p2)
int n;				/* unused */
char *p1;			/* old name */
char *p2;			/* new name */
{
  char *s1,*s2;
  char buf[11];
  REG int hnew;
  REG int att;
  FCB *f;
  DND *dn1,*dn2;
  REG OFD *f1;
  REG OFD *fd;
  REG OFD *fd2;
  REG long rc;
  REG long h1;
  long pos = 0;

  /* try to find the old file */
  if (!(dn1 = findit(p1,&s1,0)))
    return(EPTHNF);

  /* scan, including subdirs, but won't match the volume label */
  if (!(f = scan(dn1,s1,~FA_LABEL,&pos))) return (EFILNF);
  att = f->f_attrib;

  /* the attribute below used to be zero, but this missed directories */
  if (!ixsfirst(p2, ~FA_LABEL, NULPTR))
    return(EACCDN);

  /* find the directory he wants the new file in */
  if (!(dn2 = findit(p2,&s2,0)))
    return(EPTHNF);

  /* s2 is the filename part of the target name. If empty, error! */
  if (!(*s2))
    return(EBADRQ);

  if (dn1->d_drv->m_drvnum != dn2->d_drv->m_drvnum)
    return(ENSAME);

  /* if old file is a directory, use drename */
  if (att == FA_SUBDIR) {
  	if (dn1 != dn2) return EACCDN;
  	return drename(dn1,p1,s2);
  }

  if ((h1 = xopen(p1, 2)) < 0L)
    return (h1);
  f1 = getofd ((int)h1);		/* can't fail */

  fd = f1->o_dirfil;
  buf[0] = 0xe5;
  ixlseek(fd,f1->o_dirbyt);

  if (dn1 != dn2)
    {
      /* get old attribute */
      f = (FCB *) ixread(fd,32L,NULPTR);
      /* erase (0xe5) old file */
      ixlseek(fd,f1->o_dirbyt);
      ixwrite(fd,1L,buf);

      /* copy time/date/clust, etc. */

      ixlseek(fd,f1->o_dirbyt + 22);
      ixread(fd,10L,buf);

      /* att still has the original file's attribute from above */
      hnew = xcreat(p2,att);
      fd2 = getofd(hnew);		/* can't fail */
      ixlseek(fd2->o_dirfil,fd2->o_dirbyt + 22);
      ixwrite(fd2->o_dirfil,10L,buf);
      fd2->o_flag &= ~O_DIRTY;
      xclose(hnew);
      ixclose(fd2->o_dirfil,CL_DIR);
    }
  else
    {
      builds(s2,buf);
      ixwrite(fd,11L,buf);
    }

  if ((rc = xclose((int)h1)) < 0L)
    return(rc);

  return(ixclose(fd,CL_DIR));
}

/***********************************************************************
 *
 * Drename: rename a directory.
 * The arguments are partly digested by xrename.  dp is the DND
 * of the directory in which the rename will take place.  p1 is
 * the full pathname (as passed in initially) to be renamed.
 * s2 is the new name (just the name part).  This has already
 * been checked, and doesn't also exist in dp.
 *
 * Returns EBADRQ for illegal new name.
 *
 * (By Allan Pratt 03/11/88)
 *
 ***********************************************************************/
long
drename(dp, p1, s2)
DND *dp;	/* DND where the files are */
char *p1;	/* old name (full pathname) */
char *s2;	/* new name (just the name part) */
{
    char buf[20];
    char *s;
    REG int i;
    DND *d;

    if (eordot(s2,'\0')) return EBADRQ;

    if (!(d = findit(p1,&s,1))) return EPTHNF;

    builds(s2,buf);
    xmovs(11,buf,d->d_name);

    /* change the file name in the parent */

    ixlseek(d->d_dirfil,d->d_dirpos);
    ixwrite(d->d_dirfil,11L,buf);

    return ixclose(d->d_dirfil,CL_DIR);
}

/*	Function 0x42	f_seek
	
	Error returns
	EIHNDL
	EINVFN
	ixlseek()
	*/

long
xlseek(n,h,flg) /*+ seek file handle h, byte position n */
int h,flg;
long n;
{
  REG OFD *f;

  if (!(f = getofd(h)) || ((long)f < 0))
    return(EIHNDL);

  if (flg == 2)
    n += f->o_fileln;
  else if (flg == 1)
    n += f->o_bytnum;
  else if (flg)
    return(EINVFN);

  return(ixlseek(f,n));
}


/*
  Error returns
  ERANGE
  EINTRN

  Last modified	SCC	10 Apr 85

  NOTE:	This function returns ERANGE and EINTRN errors, which are new error
  numbers I just made up (that is, they were not defined by the BIOS
  or by PC DOS).
  */

long
ixlseek(x_p,x_n)
OFD *x_p;
long x_n;
{
  REG OFD *p;
  REG long n;
  int curnum,curflg;
  REG int clnum;
  REG int clx;
  REG int i;
  REG DMD *dm;

  p = x_p;
  n = x_n;

  if (n > p->o_fileln)
    return(ERANGE);

  if (n < 0)
    return(ERANGE);

  dm = p->o_dmd;
  if (!n)
    {
      clx = 0;
      p->o_curbyt = 0;
      goto fillin;
    }

  /* do we need to start from the beginning ? */

  curflg = (!p->o_curbyt) || (p->o_curbyt == dm->m_clsizb);
  clnum = divmod(&p->o_curbyt,n,dm->m_clblog);

  if (p->o_curcl && (n >= p->o_bytnum))
    {
      curnum = p->o_bytnum >> dm->m_clblog;
      clnum -= curnum;
      clnum += curflg;
      clx = p->o_curcl;
    }
  else
    clx = p->o_strtcl;

  /* AKP: the -1 below was any 0xfff0..0xffff but I backed that out */

  newcl = TRUE;			/* AKP: new loop of cluster calls */
  for (i=1; i < clnum; i++) {
    if ((clx = getcl(clx,dm)) == -1) {
      newcl = TRUE;		/* AKP: set this just in case */
      return(-1);
    }
  }

  /* go one more except on cluster boundary */

  if (p->o_curbyt && clnum)
    clx = getcl(clx,dm);

  newcl = TRUE;			/* AKP: set this just in case */

 fillin:	p->o_curcl = clx;
  p->o_currec = cl2rec(clx,dm);
  p->o_bytnum = n;

  return(n);
}

