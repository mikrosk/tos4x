/*
***************************     FSFS.C     ******************************
*
* $Revision: 2.8 $	$Source: e:/tos/gd2\RCS\fsfs.c,v $
* =======================================================================
* $Author: apratt $ 	$Date: 1991/02/11 19:56:48 $    $Locker:  $
* =======================================================================
*
* $Log: fsfs.c,v $
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
		return dfd;
	}
    }
    return NULL;
}

/*
 *  Create a file.  Called by xcreat and xmkdir.  Returns error codes,
 *  fills in dir with a fresh DIR for the file.
 *
 * ERROR CONSIDERATIONS:
 * All disk errors longjmp.  Other errors return their error codes.
 */
long
ixcreat(name,attr,dir)
char *name;
char attr;
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

    /* Anything but EFILNF fails now */
    if (err && err != EFILNF) return err;

    /*
     *  Special case for volume label here: only works in RD, and
     *  deletes any existing label, not a file with the same name.
     */

    if (attr & FA_LABEL) {
	/* Not coded up yet */
	ASSERT(0);
    }

    /*
     *  If the file exists, remove it, unless it's open.
     *
     *  Don't remove if existing file is RO or subdir, and don't
     *  create a subdir over an existing file.
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

    /*
     * write the new file info there, flush back to disk.
     */

    fcb = dir->dir_fcb;

    if (err = name2fcb(namepart,NULL,fcb)) return err;

    fcb->f_attrib = attr | FA_ARCHIVE;
    for (i=10; i; fcb->f_fill[--i] = 0) ;
    fcb->f_time = time;
    swp68(time);
    fcb->f_date = date;
    swp68(date);
    fcb->f_clust = 0;
    fcb->f_fileln = 0;
    dirdirty(dir);
    return 0;
}


/*
 *  Open file.  Finds the DIR entry for the file & calls ixopen.
 */

long
xopen(name, mod)
char *name;
int mod;
{
    DIR dir;
    long err;

    /* find the file */
    err = fn2dir(&name,&dir,FN_NORM);
    if (err) return err;

    return ixopen(&dir,mod);
}

/*
 * ixopen: given a DIR entry, open the file.
 *
 *  ERROR CONSIDERATIONS:
 *  Since this function doesn't do any writes, it can't mangle the disk.
 *  You have to pre-allocate an OFD because you know you'll need one,
 *  and free it if you then need a DFD and can't get one, but that's
 *  all that can go wrong.
 */

long
ixopen(dir,mod)
DIR *dir;
int mod;
{
    FCB *fcb;
    int h;
    DFD *dfd;
    OFD *ofd;

    /* fail if opening for mode other than zero and file is RO */
    if ((mod > 0) && (dir->dir_fcb->f_attrib & FA_RO)) return EACCDN;

    /* fail if there are no handles left */
    if (h = sftprobe()) return ENHNDL;

    /* get an OFD first, because we know we'll need one */
    /* and failure should get us out of here NOW. */

    if ((ofd = newofd()) == NULL) return ENHNDL;

    if ((dfd = getdfd(dir)) == NULL) {
	/* no DFD for this file already; get a new one, fill it in */
	if ((dfd = newdfd()) == NULL) {
	    freeofd(ofd);
	    return ENHNDL;
	}

	fcb = dir->dir_fcb;

	dfd->dfd_time = fcb->f_time;
	dfd->dfd_date = fcb->f_date;
	dfd->dfd_strtcl = fcb->f_clust;
	dfd->dfd_fileln = fcb->f_fileln;
	swp68l(fcb->f_fileln);
	dfd->dfd_attrib = fcb->f_attrib;
	dfd->dfd_dev = dir->dir_dev;
	dfd->dfd_dircl = dir->dir_clust;
	dfd->dfd_dirrec = dir->dir_recno;
	dfd->dfd_diroffs = dir->dir_recoffs;
	dfd->dfd_use = 0;
	dfd->dfd_dirty = 0;

	/* link it in */
	dfd->dfd_next = dfd_head;
	dfd_head = dfd;
    }

    /* fill in the OFD */
    ofd->o_next = ofd_head;
    ofd_head = ofd;
    ofd->o_mode = mod;
    ofd->o_curcl = 0;	/* flag meaning r/w clust info uninitialized */
    ofd->o_currec = 0;
    ofd->o_curbyt = 0;
    ofd->o_bytnum = 0;

    ofd->o_use = 1;
    ofd->o_dfd = dfd;
    dfd->dfd_use++;

    /* make handle h refer to this ofd and return h */

    sft[h].f_ofd = ofd;
    sft[h].f_own = run;

    return h;
}

/*
 *  Fattrib: Get/Set file attributes.  There are some restrictions on 
 *  "set:" mainly, you can't change the "folder" bit, and you can't change
 *  the "label" bit of a subdir.  You can get YOURSELF into trouble
 *  with this, but you can't get GEMDOS into trouble!
 *
 * ERROR CONSIDERATIONS: when writing, we just call dirdirty().
 */

long
xchmod(p,wrt,attr)
char *p;			/* -> filename */
int wrt;			/* 0:get, 1:set */
char attr;			/* attribute byte */
{
    char oattr;
    DIR dir;
    long err;

    /* Will match anything but a label; return any error */
    if (err = fn2dir(&p,&dir,FN_NORM)) return err;

    oattr = dir.dir_fcb->f_attrib;
    if (wrt) {
	/* can't change FA_SUBDIR bit, or label bit of dir */
	if (((attr & FA_SUBDIR) ^ (oattr & FA_SUBDIR)) ||
	    ((attr & FA_LABEL) && (oattr & FA_LABEL)))
		return EACCDN;
	dir.dir_fcb->f_attrib = attr;
	dirdirty(dir);
	return (unsigned long)attr;
    }
    else return (unsigned long)oattr;
}


/*
 *  Fdatime, Get/Set File Date and Time
 *
 * Megamax C relies on this function leaving the input buffer alone on
 * a read when the handle isatty, and on changing it (with the file's
 * info) when the handle !isatty.  We can preserve that and still
 * return EIHNDL with the handle refers to a tty.
 *
 * We change the DFD for the open file, not what's on disk.
 * Fsfirst/next has to look for a DFD or it will be out of date.
 *
 * NO DISK ACTIVITY, NO ERROR CONSIDERATIONS.
 */

long
xdatime(buf, h, wrt)
int *buf;			/* -> user buffer */
int h;				/* file handle */
int wrt;			/* 0:get, 1:set */
{
    DFD *dfd;
    int t[2];			/* buffer to hold user input for swapping */

    h = syshnd(h);
    if ((h < 0) || ofdisatty(sft[h].f_ofd)) return EIHNDL;
  
    dfd = sft[h].f_ofd->o_dfd;
    if (!wrt) {
	buf[0] = dfd->dfd_time;
	buf[1] = dfd->dfd_date;
	swp68(buf[0]);
	swp68(buf[1]);
	return E_OK;
    }

    /* else it's a write */

    t[0] = buf[0];
    t[1] = buf[1];
    swp68(t[0]);
    swp68(t[1]);

    dfd->dfd_time = t[0];
    dfd->dfd_date = t[1];
    dfd->dfd_dirty = 1;
    return E_OK;
}

/*
 *  Delete a file.  This is the external version: calls ixdel to
 *  do the dirty deed.  Simple returns from errors suffice.
 */
long
xdelete(name)
char *name;
{
    DIR dir;
    long err;
    FTAB *ftab;
    OFD *ofd;
    DFD *dfd;
    int youflag = 0;
    int sftindex;
    int i;

    /* find normal files only, return any error */
    if (err = fn2dir(&name,&dir,FN_NORM)) return err;

    /*
     *  Refuse if file is read-only
     */
    if (dir.dir_fcb->f_attrib & FA_RO)
	return(EACCDN);

    /*
     * Refuse if the file is open by anybody else.  This involves
     * scanning through the SFT looking for a DFD with a matching dev,
     * dirrec, and diroffs.  We might visit a DFD more than once,
     * but that's OK.  We look through SFT, not the linked list of
     * dfd's, because we need the 'own' field in the SFT.
     */

    for (ftab = &sft[0]; ftab < &sft[OPNFILES]; ftab++) {
	if (ftab->f_own) {
	    ofd = ftab->f_ofd;
	    if (!ofdisatty(ofd)) {
		dfd = ofd->o_dfd;
		if (dfd->dfd_dev == dir.dir_dev &&
		    dfd->dfd_dirrec == dir.dir_recno &&
		    dfd->dfd_diroffs == dir.dir_recoffs) {
			/* same file */
			if (ftab->f_own != run) return EACCDN;
			else youflag = 1;
		}
	    }
	}
    }

    /*
       OK, nobody else has it open.  If you do, youflag is 1, in which
       case we have to call xclose for each time you have it open.  If
       any of these fails, we return the error code.  Hopefully, either
       the first one will fail or none of them will; otherwise, some of
       your handles to the file are closed and some are not. 
       The structure of this is as follows:

	if (you have it open) {
	    for (each slot in SFT) {
		if (slot is valid) {
		    if (!isatty(slot)) {
			if (is the same file) {
			    for (each std handle) {
				if (this std handle referrs to the slot) {
				    close the std handle (return errors)
				    goto handle_is_closed;
				}
			    }
			    (wasn't a std handle)
			    close the handle (return errors)
	handle_is_closed: ;
	                }
	            }
	        }
	    }
	}
     */
	    

    if (youflag) {
	/* for (each SFT slot) */
	for (sftindex = 0, ftab = &sft[0]; 
	     ftab < &sft[OPNFILES];
	     ftab++, sftindex++) {
		/* if (valid) */
		if (ftab->f_own) {
		    ofd = ftab->f_ofd;
		    /* if (!isatty) */
		    if (!ofdisatty(ofd)) {
			/* if (is the same file) */
			dfd = ofd->o_dfd;
			if (dfd->dfd_dev == dir.dir_dev &&
			    dfd->dfd_dirrec == dir.dir_recno &&
			    dfd->dfd_diroffs == dir.dir_recoffs) {
				/* close std if std, else close slot */
				for (i=0; i<NUMSTD; i++) {
				    if (run->p_uft[i] == sftindex) {
					if (err = xclose(i)) return err;
					goto handle_is_closed;
				    }
				}
				/* wasn't a std handle */
				if (err = xclose(sftindex)) return err;
handle_is_closed:		;
			}
		    }
		}
	 }
    }

    /* hoo boy! Now nobody has the file open. Freshen bcb & fcb and nuke. */

    dir2dir(&dir);
    return ixdel(&dir);
}


/*
 *  Internal version of delete-file.  Takes a dir structure with fresh
 *  bcb and fcb fields.  Assumes the file is not open by anyone:
 *  caller must check this.  All this function does is e5 out the
 *  dir entry and zap the FAT.
 *  (called by ixcreat(), xdelete() and xrmdir()).
 *
 *  ERROR CONSIDERATIONS: e5 out the directory slot first, so if
 *  dirwrite() fails you could at worst end up with lost clusters,
 *  not an entry that points to zeros.
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
     * Note: stop at (and don't touch) entries in the range [0xfff0..0xfffe],
     * and also stop if the entry is 0 (possible for inconsistent filesystems).
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

    return E_OK;
}

/*
 *  Rename a file.
 *
 * ERROR CONSIDERATIONS:
 * First we create the new file, then remove the old.  Creating the new file
 * includes calling dirslot, which might fail; this is harmless.  It also
 * involves writing the new slot.  If this fails, then the buffer we wrote 
 * into will be invalidated, so that's OK. If the write to dir2 succeeds but
 * the write to dir1 fails, you end up with the same file in two places;
 * tough.  This is worse for Freanme of a directory through the structure.
 * Still tough.
 */
long
xrename(n, p1, p2)
int n;				/* unused */
char *p1;			/* old name */
char *p2;			/* new name */
{
    DIR dir1;
    DIR dir2;
    long err;
    char attr;
    FCB fcbhold;
    uint cl;

    /* try to find the old file, return any error. */

    if (err = fn2dir(&p1,&dir1,FN_NORM)) return err;
    fcbhold = *dir1.dir_fcb;		    /* structure copy of FCB */
    attr = fcbhold.f_attrib;
    if (attr & FA_RO) return EACCDN;

    /* try to find the dir of the new file; return any error but EFILNF */
    if ((err = fn2dir(&p2,&dir2,FN_NORM)) && err != EFILNF) return err;

    /* if there was NO error in the fn2dir above, the dest file exists! */
    if (!err) return EACCDN;

    if (dir1.dir_dev != dir2.dir_dev) return ENSAME;

    /* at this point, dir2 is fresh, dir1 might not be */

    /* Can you rename an open file? No. Don't even check if directory */
    if (!(attr & FA_SUBDIR) && (getdfd(&dir1) != NULL)) return EACCDN;

    if (dir1.dir_clust == dir2.dir_clust) {
	/* same directory. Copy new name in. Error on illegal file names */
	if (err = name2fcb(p2,NULL,dir2.dir_fcb)) return err;
	dirdirty(&dir2);
	return 0;
    }
    else {
	if (err = dirslot(&dir2)) return err;
	/* copy FCB, then replace name with new name */
	*dir2.dir_fcb = fcbhold;
	if (err = name2fcb(p2,NULL,dir2.dir_fcb)) return err;
	dirdirty(&dir2);

	/* new file was (successfully?) created in dir2; remove from dir1 */
	dir2dir(&dir1);
	*dir1.dir_fcb->f_name = 0xe5;		/* erase old file */
	dirdirty(&dir1);

	if (fcbhold.f_attrib & FA_SUBDIR) {
	    /* we just renamed a subdir; change its .. entry too. */
	    /* construct a dir struct for the second slot of the dir */
	    cl = fcbhold.f_clust;
	    swp68(cl);
	    dir1.dir_recno = cl2rec(cl,&drvtbl[dir1.dir_dev]);
	    dir1.dir_recoffs = sizeof(FCB);

	    /* "freshen" our constructed struct, change strtcl */
	    dir2dir(&dir1);
	    dir1.dir_fcb->f_clust = dir2.dir_clust;
	    swp68(dir1.dir_fcb->f_clust);
	    dirdirty(&dir1);
        }
        return E_OK;
    }
}

/*
 * xlseek: update the read-write pointer of a file.
 * Calls ixlseek on the OFD and new pointer location.
 */

long
xlseek(n,h,flg)
long n;
int h;
int flg;
{
    OFD *ofd;
    int curnum,curflg;
    int clnum;
    int clx;
    int i;
    DMD *dm;

    if ((h = syshnd(h)) < 0) return EIHNDL;
    ofd = sft[h].f_ofd;
    if (ofdisatty(ofd)) return EIHNDL;

    if (flg == 2)
	n += ofd->o_dfd->dfd_fileln;
    else if (flg == 1)
	n += ofd->o_bytnum;
    else if (flg)
	return(EINVFN);

    if (n > ofd->o_dfd->dfd_fileln || n < 0)
	return(ERANGE);

    dm = &drvtbl[ofd->o_dfd->dfd_dev];
    if (!n) {
	clx = 0;
	ofd->o_curbyt = 0;
	goto fillin;
    }

    /* do we need to start from the beginning ? */

    curflg = (!ofd->o_curbyt) || (ofd->o_curbyt == dm->m_clsizb);
    clnum = divmod(&ofd->o_curbyt,n,dm->m_clblog);

    if (ofd->o_curcl && (n >= ofd->o_bytnum)) {
	curnum = ofd->o_bytnum >> dm->m_clblog;
	clnum -= curnum;
	clnum += curflg;
	clx = ofd->o_curcl;
    }
    else {
      clx = ofd->o_dfd->dfd_strtcl;
      swp68(clx);
    }

    /* stop looking (and leave file pointer alone) if you encounter a */
    /* cluster value of zero or $FFFx.  One is also invalid. */
    /* Something like this was put here, then backed out, before. */
    /* Don't know why it was backed out... */

    newcl = TRUE;			/* AKP: new loop of cluster calls */
    for (i=1; i < clnum; i++) {
	if (!(clx = getcl(clx,dm)) || ((clx & 0xfff0) == 0xfff0)) {
	    newcl = TRUE;		/* AKP: set this just in case */
	    return(ERROR);
	}
    }

    /* go one more except on cluster boundary */

    if (ofd->o_curbyt && clnum)
	clx = getcl(clx,dm);

    newcl = TRUE;			/* AKP: set this just in case */

fillin:
    ofd->o_curcl = clx;
    ofd->o_currec = cl2rec(clx,dm);
    ofd->o_bytnum = n;

    return(n);
}
