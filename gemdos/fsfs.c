/*
***************************     FSFS.C     ******************************
*
* $Revision: 2.17 $	$Source: e:/tos/gd2\RCS\fsfs.c,v $
* =======================================================================
* $Author: apratt $ 	$Date: 1991/05/30 16:06:06 $    $Locker:  $
* =======================================================================
*
* $Log: fsfs.c,v $
* Revision 2.17  1991/05/30  16:06:06  apratt
* Changed use of FN_TRAILOK to FN_DOTSOK, which is what
* was really meant here (in chmod).
*
* Revision 2.16  1991/05/09  17:40:38  apratt
* General stuff.
*
* Revision 2.15  1991/04/30  12:12:38  apratt
* Converted DBCMDs to new infix DB style
*
* Revision 2.14  1991/03/28  17:39:36  apratt
* THIS VERSION BOOTS! DESKTOP OPERATIONS WORK!
*
* Revision 2.13  1991/03/12  18:25:26  apratt
* Making gtest.prg works and lets you test functions in this version
*
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
* Revision 2.7  91/01/23  17:07:46  apratt
* Previously, using Fdatime to write the date/time of a zero-length file
* would write that date/time to any open zero-length file in that dir. Fixed.
* 
* Changed d_left to d_child, d_right to d_next globally.  Removed o_thread,
* d_scan, m_fatofd, m_ofl, and d_dirfil.
* 
* Revision 2.6  91/01/23  14:30:04  apratt
* Trimmed logs & comments, changed to compile under GCC or (new) Alcyon.
* 
*************************************************************************
*/

#include "fs.h"

/*
 * getdfd: if there's a DFD for the file described by
 * the DIR structure, return a pointer to it, else NULL.
 */
DFD 
*getdfd(dir)
DIR *dir;
{
    DFD *dfd;

    for (dfd = dfd_head; dfd; dfd = dfd->dfd_next) {
	if (dfd->dfd_dev == dir->dir_dev &&
	    dfd->dfd_dirrec == dir->dir_recno &&
	    dfd->dfd_diroffs == dir->dir_recoffs) {
		/* same file */
		DBCMD(8|4,"print getdfd: found one;_c");
		return dfd;
	}
    }
    DBCMD(8|4,"print getdfd: did not find one;_c");
    return NULL;
}

/*
 * Create a file.  Called by xcreat and xmkdir.  Returns error codes, fills
 * in dir with a fresh DIR for the file.
 *
 * ERROR CONSIDERATIONS:
 * All disk errors longjmp.  Other errors return their error codes.
 */
long
ixcreat(name,attr,dir)
char *name;
int attr;
DIR *dir;
{
    char *namepart;
    long err;
    FCB *fcb;
    int i;

    /*
     *  Find path;
     *  reject illegal files (empty, or starting with dots)
     */

    namepart = name;
    err = fn2dir(&namepart,dir,FN_NORM);

    /* Any error but EFILNF fails now */
    if (err && err != EFILNF) return err;

    /*
     * Special case for volume label here: only works in RD, and deletes
     * any existing label, not a file with the same name.
     */

    if (attr & FA_LABEL) {
	/* Not coded up yet */
	DBCMD(-1,"print Dont know much about volume labels");
    }

    /*
     * If the file exists, remove it, unless it's open. Don't remove if
     * existing file is RO or subdir, and don't create a subdir over an
     * existing file.
     */

    if (err == 0) {
	/* the file exists; check existing attribs */
	if ((dir->dir_fcb->f_attrib & (FA_RO | FA_SUBDIR)) || 
	    (attr & FA_SUBDIR))
		return EACCDN;

	/* check to see if anybody has it open */
	if (getdfd(dir) != NULL) return EACCDN;

	/* nuke the file, return if can't for some reason */
	if (err = ixdel(dir)) return err;
    }

    /* The file doesn't exist (any more). */

    /*
     * Scan for empty space in the directory file (find an empty slot); 
     * grow directory if no free slots left. This can fail.
     */

    if (err = dirslot(dir)) return err;

    /* write the new file info there, flush back to disk. */

    fcb = dir->dir_fcb;

    if (err = name2fcb(namepart,NULL,fcb)) return err;

    fcb->f_attrib = attr | FA_ARCHIVE;
    for (i=10; i; fcb->f_fill[--i] = 0) ;
    fcb->f_time = realtime;
    swp68(fcb->f_time);
    fcb->f_date = realdate;
    swp68(fcb->f_date);
    fcb->f_clust = 0;
    fcb->f_fileln = 0;
    dirdirty(dir);
    fatdirty(dir->dir_dev);	/* dirslot may have dirtied some FAT */
    return 0;
}


/*
 * Fattrib: Get/Set file attributes.  There are some restrictions on 
 * "set:" mainly, you can't change the "folder" bit, and you can't change
 * the "label" bit of a subdir.  You can get YOURSELF into trouble with
 * this, but you can't get GEMDOS into trouble!
 *
 * QUIET CHANGE FROM ORIGINAL GEMDOS: you can do Fattrib of "." and ".."
 *
 * ERROR CONSIDERATIONS: when writing, we just call dirdirty().
 */

long
xchmod(p,wrt,attr)
char *p;			/* -> filename */
int wrt;			/* 0:get, 1:set */
int attr;			/* attribute byte */
{
    char oattr;
    DIR dir;
    long err;
    DFD *dfd;

    DBCMD(1,"print xchmod -s (lpeek (`a6 + 8)) -x (wpeek (`a6 + c)) "
	    "(wpeek (`a6 + e));_c");

    attr &= 0xff;

    /* Will match anything but a label (incl. "." or ".."); return any error */
    if (err = fn2dir(&p,&dir,FN_DOTSOK)) return err;

    oattr = dir.dir_fcb->f_attrib;
    if (!wrt) return (ulong)oattr;	/* reading */

    /* can't change FA_SUBDIR bit, or label bit of dir */
    if (((attr & FA_SUBDIR) ^ (oattr & FA_SUBDIR)) ||
	((attr & FA_LABEL) && (oattr & FA_SUBDIR)))
	    return EACCDN;

    if (dfd = getdfd(&dir)) dfd->dfd_attrib = attr;

    dir.dir_fcb->f_attrib = attr;
    dirdirty(&dir);

    return (unsigned long)attr;
}


/*
 * Delete a file.  This is the external version: calls ixdel to do the
 * dirty deed.  Simple returns from errors suffice.
 */
long
xunlink(name)
char *name;
{
    DIR dir;
    long err;
    OFD **uft, **uftend;
    OFD *ofd;
    DFD *dfd;
    PD *pd, **ppd;
    int youflag = 0;
    int i;

    DBCMD(1,"print xdelete -s (lpeek (`a6 + 8));_c");

    /* return any error (file not found, bad request, etc.) */
    if (err = fn2dir(&name,&dir,FN_NORM)) return err;

    /*
     *  Refuse if file is read-only or a directory
     */
    if (dir.dir_fcb->f_attrib & (FA_RO | FA_SUBDIR))
	return(EACCDN);

    /*
     * Refuse if the file is open by anybody else.  This involves looking
     * first for a matching DFD, then exhaustively scanning p_uft for EACH
     * PROCESS looking for entries which refer to OFD's which refer to this
     * DFD.
     */

    if (dfd = getdfd(&dir)) {
	/* yes, *somebody* has this file open */
	for (pd = *(ppd = &pdtab[0]); ppd < &pdtab[NUMPDS]; pd = *(++ppd)) {
	    if (pd) {
		uft = &pd->p_uft[0];
		uftend = &pd->p_uft[pd->p_uftsize];
		while (uft < uftend) {
		    ofd = *uft++;
		    if (ofd != NULL && !ofdisatty(ofd) && ofd->o_dfd == dfd) {
			/* got one! */
			if (pd == run) youflag = 1;
			else return EACCDN;
		    }
		}
	    }
	}
    }

    /*
     * OK, nobody else has it open.  If you do, youflag is 1, in which case
     * we have to call xclose for each time you have it open.  If any of
     * these fails, we return the error code.  Hopefully, either the first
     * one will fail or none of them will; otherwise, some of your handles
     * to the file are closed and some are not.
     */
	    

    if (youflag) {
    	for (i=0, uft = &run->p_uft[0], uftend = &run->p_uft[run->p_uftsize];
	     uft < uftend;
	     uft++, i++) {
		ofd = *uft;
		if (ofd != NULL && !ofdisatty(ofd) && ofd->o_dfd == dfd) {
		    (void)xclose(i);
		}
	}
    }

    /* hoo boy! Now nobody has the file open. Freshen bcb & fcb and nuke. */

    dir2dir(&dir);
    return ixdel(&dir);
}


/*
 * Internal version of delete-file.  Takes a dir structure with fresh bcb
 * and fcb fields.  Assumes the file is not open by anyone: caller must
 * check this.  All this function does is e5 out the dir entry and zap the
 * FAT. (called by ixcreat(), xdelete() and xrmdir()).
 *
 * ERROR CONSIDERATIONS: e5 out the directory slot first, so if dirwrite()
 * fails you could at worst end up with lost clusters, not an entry that
 * points to zeros.
 */
long
ixdel(dir)
DIR *dir;
{
    DMD *dm;
    unsigned int n;
    unsigned int n2;
    unsigned int temp;

    /*
     * Mark the directory entry as erased.
     */

    dir->dir_fcb->f_name[0] = 0xe5;
    dirdirty(dir);

    /*
     * Traverse this file's chain of allocated clusters, freeing them.
     * Note: stop at (and don't touch) entries in the range
     * [0xfff0..0xfffe], and also stop if the entry is 0 (possible for
     * inconsistent filesystems).
     */

    dm = &drvtbl[dir->dir_dev];
    temp = dir->dir_fcb->f_clust;
    swp68(temp);
    n = temp;

    newcl = TRUE;			/* AKP: new loop of cluster calls */
    while (n && n != 0xffff) {
	n2 = getcl(n,dm);
	if (!n2 || (n2 >= 0xfff0 && n2 != 0xffff)) {
	    /* bad sector mark or other reserved situation: stop now. */
	    break;
	}
	else clfix(n,0,dm);
	n = n2;
    }
    newcl = TRUE;			/* AKP: set this just in case */

    fatdirty(dir->dir_dev);
    return E_OK;
}

/*
 *  Rename a file.
 *
 * ERROR CONSIDERATIONS:
 * 
 * First we create the new file, then remove the old.  Creating the new
 * file includes calling dirslot, which might fail; this is harmless.  It
 * also involves writing the new slot.  If this fails, then the buffer we
 * wrote  into will be invalidated, so that's OK. If the write to dir2
 * succeeds but the write to dir1 fails, you end up with the same file in
 * two places; tough.  This is worse for Freanme of a directory through the
 * structure. Still tough.
 */
long
xrename(n, p1, p2)
int n;				/* unused */
char *p1;			/* old name */
char *p2;			/* new name */
{
    DIR dir1;
    DIR dir2;
    DMD *dmd;
    long err;
    char attr;
    FCB fcbhold;
    uint cl;

    DBCMD(1,"print xrename (wpeek (`a6 + 8)) "
	    "-s (lpeek (`a6 + a)) (lpeek (`a6 + e));_c");

    /* try to find the old file, return any error. */

    if (err = fn2dir(&p1,&dir1,FN_NORM)) return err;
    fcbhold = *dir1.dir_fcb;		    /* structure copy of FCB */
    attr = fcbhold.f_attrib;
    if (attr & FA_RO) return EACCDN;

    /* try to find the new file; return any error but EFILNF */
    if ((err = fn2dir(&p2,&dir2,FN_NORM)) && err != EFILNF) return err;

    /* if there was NO error in the fn2dir above, the dest file exists! */
    if (!err) return EACCDN;

    if (dir1.dir_dev != dir2.dir_dev) return ENSAME;

    /* at this point, dir2 is fresh, dir1 might not be */

    /* Can you rename an open file? No. Don't even check if directory */
    if (!(attr & FA_SUBDIR) && (getdfd(&dir1) != NULL)) return EACCDN;

    if (dir1.dir_clust == dir2.dir_clust) {
	/* same directory. Copy new name in. Error on illegal file names */
	/* Have to freshen dir1 because its offset filed is old file's slot. */
	DBCMD(0x20,"print same directory, just reuse slot;_c");
	dir2dir(&dir1);
	if (err = name2fcb(p2,NULL,dir1.dir_fcb)) return err;
	dirdirty(&dir1);
	return 0;
    }
    else {
	if (err = dirslot(&dir2)) return err;
	/* copy FCB, then replace name with new name */
	*dir2.dir_fcb = fcbhold;
	if (err = name2fcb(p2,NULL,dir2.dir_fcb)) return err;
	dirdirty(&dir2);

	/* new file was created in dir2; remove from dir1 */
	dir2dir(&dir1);
	*dir1.dir_fcb->f_name = 0xe5;		/* erase old file */
	dirdirty(&dir1);

	if (fcbhold.f_attrib & FA_SUBDIR) {
	    /* we just renamed a subdir; change its .. entry too. */
	    /* construct a dir struct for the second slot of the dir */
	    cl = fcbhold.f_clust;
	    swp68(cl);
	    dir1.dir_clust = cl;
	    dmd = &drvtbl[dir1.dir_dev];
	    if (err = dirfirst(&dir1,dmd)) return err;
	    if (err = dirnext(&dir1,dmd)) return err;
	    dir1.dir_fcb->f_clust = dir2.dir_clust;
	    swp68(dir1.dir_fcb->f_clust);
	    dirdirty(&dir1);
        }
        return E_OK;
    }
}

