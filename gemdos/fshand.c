/*
***************************    FSHAND.C    ******************************
*
* $Revision: 2.19 $	$Source: d:/tos/dos\rcs\fshand.c,v $
* =======================================================================
* $Author: kbad $ 	$Date: 1992/07/27 20:09:24 $    $Locker:  $
* =======================================================================
*
* $Log: fshand.c,v $
* Revision 2.19  1992/07/27  20:09:24  kbad
* Lattice compiled Sparrow GEMDOS
*
* Revision 2.18  1991/12/11  20:16:44  unknown
* Changed FN_NORM to SCAN_NORM in one place
*
* Revision 2.17  1991/06/18  17:52:02  apratt
* Updated to DB release 3 (new print)
*
* Revision 2.16  1991/05/30  16:06:06  apratt
* Cash uftsize to signed when comparing against a handle
* coming from the user, which could be a (negative) character
* device number.
*
* Revision 2.15  1991/05/28  15:10:00  apratt
* Fixed again - the special case where currec points past curcl
* can have happened before a call to ixlseek, so you have to
* deal with it at the front end as well as the back end.
*
* Revision 2.14  1991/05/09  17:40:38  apratt
* General stuff.
*
* Revision 2.13  1991/04/30  12:12:38  apratt
* Converted DBCMDs to new infix DB style
*
* Revision 2.12  1991/04/05  18:38:22  apratt
* Misc fixes making it work
*
* Revision 2.11  1991/03/28  17:39:36  apratt
* THIS VERSION BOOTS! DESKTOP OPERATIONS WORK!
*
* Revision 2.10  1991/03/12  18:25:26  apratt
* Making gtest.prg works and lets you test functions in this version
*
* Revision 2.9  1991/02/22  15:29:28  apratt
* generic checkin
*
* Revision 2.8  1991/02/21  03:07:32  apratt
* This version performs this testbed perfectly.
*
* Revision 2.7  1991/02/15  18:45:40  apratt
* CI at the end of the week...
*
* Revision 2.6  1991/02/12  18:20:10  apratt
* *** empty log message ***
*
* Revision 2.5  1991/02/11  19:56:48  apratt
* Checkin lest I lose work (again)
*
* Revision 2.4  91/01/23  14:30:08  apratt
* Trimmed logs & comments, changed to compile under GCC or (new) Alcyon.
* 
*************************************************************************
*/

#include "fs.h"

char biosdev[NUMSTD] = { 2, 2, 1, 0, 2, 2 };

/*
 * return the index of an available slot in this user's UFT.
 * Don't return one < NUMSTD.
 */

int
uftprobe()
{
    int i, size;
    OFD **fptr;

    size = run->p_uftsize;
    for (i = NUMSTD, fptr = &run->p_uft[NUMSTD];
    	 i < size;
    	 i++, fptr++) {
	    if (*fptr == NULL) {
		DBCMD(8,"print uftprobe succeeds;_c");
		return i;
	    }
    }
    DBCMD(8,"print uftprobe fails;_c");
    return -1;
}

/*
 * Given a handle number from the user, return something sensible.
 *
 * Old-style TTY device numbers -1 (CON:), -2 (AUX:), and -3 (PRN:)
 * are turned into new-style device numbers (one's complement of
 * the BIOS device number).
 *
 * INPUT			OUTPUT
 * h <= -NUMBIOS		NULL
 * -NUMBIOS < h < 0		(OFD *)((~(h+3)) << 1) (old->new TTY style)
 * else				run->p_uft[h] (poss isatty or null)
 *
 * ...where run->p_uft[h] is an ofd: ofdisatty, real pointer, or NULL.
 */

OFD
*syshnd(h)
int h;
{
	/* we cast uftsize to signed because h is signed */
	if (h <= -NUMBIOS || h >= (signed)run->p_uftsize) {
	    DBCMD(8,"print syshnd -x (wpeek (`a6 + 8)) >> NULL;_c");
	    return NULL;			/* too small/big */
	}
	if (h < 0) {
	    DBCMD(8,"print syshnd -x (wpeek (`a6 + 8)) >> BIOS dev;_c");
	    return ofdtty(h+3);		/* old-style BIOS dev */
        }
	DBCMD(8,"print syshnd -x (wpeek (`a6 + 8)) >> "
		"-x lpeek(lpeek(lpeek(.run)+3c) + (4 * wpeek(a6+8)));_c");
	return run->p_uft[h];
}

/*
 * The idea of dup & force is that you might redirect and un-redirect
 * stdout as follows:
 *
 *	old_stdout = Fdup(1);	(save old handle away someplace)
 *	new_stdout = Fcreate(stdout_file_name,2);
 *	Fforce(1,new_stdout);	(make stdout refer to new file)
 *
 *	( ... now stdout is redirected ...)
 *
 *	Fforce(1,old_stdout);	(this closes 1, then restores it)
 *	Fclose(new_stdout);	(see note)
 *	Fclose(old_stdout);	(don't need to remember old handle any more)
 *
 * Note: the Fclose of new_stdout could happen after the Fforce, too.
 * You do need as many closes as there are opens and dups.
 *
 * There are no restrictions on the handles you can dup or force any more.
 */

/*
 * Duplicate handle.
 */
long
xdup(h)
int h;
{
	int i;
	OFD *ofd;
	PD *_run = run;

	DBCMD(1,"print xdup -x (wpeek (`a6 + 8));_c");
	if ((h<0) ||
	    (h >= _run->p_uftsize) ||
	    ((ofd = _run->p_uft[h]) == NULL))
		return(EIHNDL);

	if ((i = uftprobe()) < 0) return ENHNDL;

	ofd = _run->p_uft[h];
	_run->p_uft[i] = ofd;

	/* is there an equivalent to o_use++ for TTY's? */
	if (!ofdisatty(ofd)) ofd->o_use++;	/* OFD used again now */

	return(i);
}


/*
 * Force handle: force 'std' to be the same thing that 'h' is.
 * No restrictions on what handles you can force to what others.
 */
long
xforce(std,h)
int std,h;
{
	DBCMD(1,"print xforce -x (wpeek (`a6 + 8)) to -x (wpeek (`a6 + a));_c");
	return(ixforce(std,h,run));
}

/*
 * ixforce: called by xforce and pexec, takes the additional arg:
 * the PD in which the force takes place.  'dest' is in pd, 'src'
 * is in run.
 *
 * You *can* Fforce(0,-1) to make stdout refer to CON: -- this is
 * for compatibility (?).
 */
long
ixforce(dest,src,pd)
int dest;
int src;
PD *pd;
{
	long err;
	PD *_run = run;
	OFD *ofd;

	if ((dest < 0) || (dest >= pd->p_uftsize))
		return(EIHNDL);

	if (src < -NUMBIOS || src >= _run->p_uftsize) {
	    /* too small/big */
	    return EIHNDL;
	}

	/* Fforce of something to itself is a no-op, but succeeds. */
	if (src == dest && pd == _run) return 0;

	if (src < 0) {
	    ofd = ofdtty(src+3);
	}
	else {
	    ofd = _run->p_uft[src];
	    if (ofd == NULL) return EIHNDL;	/* src is closed! */


	    if (pd == _run && _run->p_uft[dest]) {
		/* close whatever 'dest' points to already, */
		/* but only if not spawning a new process,  */
		/* and it points to SOMETHING.		    */

		if (err = xclose(dest)) return err;
	    }
	}
	/* now copy it over, and increase use count */
	/* is there an equivalent to o_use++ for TTY's? */
	pd->p_uft[dest] = ofd;
	if (!ofdisatty(ofd)) ofd->o_use++;
	return E_OK;
}

/*
 * Fclose(h):
 *	Closes handle h.
 *	A no-op for BIOS devices (-ve h).
 *	Otherwise closes what the handle refers to, cascading use counts
 * down until one doesn't drop to zero.
 *	Closing "standard" handles is not recommended practice, but for now
 * results in that thing resuming its default meaning (like CON:).
 *
 * We don't actually decrement any use counts or close anything until the
 * close works.  A failed close keeps the file open!
 *
 * This function is documented as flushing all buffers on all devices.
 * It doesn't do that yet, partly because it is called from several places.
 * Maybe it will set a flag so that'll be done on the way out of GEMDOS.
 *
 * Close and ixclose are split out so ixterm can call ixclose to operate in
 * a basepage other than run, e.g. in a partially-constructed basepage 
 * which couldn't be finished because of an error.
 */

long
xclose(h)
int h;
{
    return ixclose(h,run);
}

long
ixclose(h,pd)
int h;
PD *pd;
{
    OFD *ofd;
    DFD *dfd;

    DBCMD(1,"print ixclose -x (wpeek (`a6 + 8)) -x (lpeek (`a6 + a));_c");

    /*
     * A while ago, I "guaranteed" that any close would flush all dirty
     * sectors on all drives ... do that first. See xsync(). This will
     * longjmp on errors before the file is closed.  If it succeeds, the
     * rest of the close can't encounter an error.
     *
     * If you want close to "succeed" no matter what, then set h and ofd
     * before calling xsync and catch the longjmp.  The danger is that any
     * error, including e.g. write-protect on ANOTHER drive, will still
     * close the file and lots of things will be inconsistent.
     */

    xsync();

    if (h < -NUMBIOS || h >= pd->p_uftsize) return EIHNDL;
    if (h < 0) return E_OK;	    /* "close" an old-style TTY */

    if ((ofd = pd->p_uft[h]) == NULL) return EIHNDL;	/* not open */

    /* mark as closed NOW, but see below: h<NUMSTD gets reopened */
    pd->p_uft[h] = NULL;

    if (ofdisatty(ofd)) {
	/* close a new-style char device; really do nothing for now,  */
	/* but see below: we reopen h onto BIOS dev if it's a std hdl */
    }
    else {
	/*
	 * Decrement use counts, free blocks.
	 */
	if (--ofd->o_use == 0) {
	    DBCMD(8,"print ofd->o_use dropped to 0;_c");
	    dfd = ofd->o_dfd;
	    if (--dfd->dfd_use == 0) {
		DBCMD(8,"print dfd->d_use dropped to 0;_c");
		/* unlink this DFD from dfd_head */
		if (dfd->dfd_prev) {
		    dfd->dfd_prev->dfd_next = dfd->dfd_next;
		}
		else dfd_head = dfd->dfd_next;
		if (dfd->dfd_next) {
		    dfd->dfd_next->dfd_prev = dfd->dfd_prev;
		}
		freebig(dfd);
	    }
	    /* unlink this block from ofd_head */
	    if (ofd->o_prev) {
		ofd->o_prev->o_next = ofd->o_next;
	    }
	    else ofd_head = ofd->o_next;
	    if (ofd->o_next) {
		ofd->o_next->o_prev = ofd->o_prev;
	    }
	    freebig(ofd);
	}
    }

    /* Now re-open the handle on its default BIOS device if < NUMSTD and */
    /* only if pd == run; otherwise we're terminating so don't bother.	 */
    if (h < NUMSTD && pd == run) {
	/* h was a std handle; we need to reopen it on a char dev. */
	DBCMD(8,"print re-open handle on BIOS dev;_c");
	pd->p_uft[h] = ofdtty(biosdev[h]);
    }

    DBCMD(8,"print end of xclose:;uft (lpeek(.run));_c");
    return E_OK;
}   

/*
 * Free open files on a drive.  Part of the media-change procedure.
 * Frees open files without flushing them or making anything dirty.
 */
void
offree(dev)
uint dev;
{
    OFD *ofd;
    DFD *dfd;
    PD *pd, **ppd;
    OFD **uft, **uftend;
    

    for (pd = *(ppd = &pdtab[0]); ppd < &pdtab[NUMPDS]; pd = *(++ppd)) {
	if (pd) {
	    uft = &pd->p_uft[0];
	    uftend = &pd->p_uft[pd->p_uftsize];
	    while (uft < uftend) {
		ofd = *uft;
		if (ofd != NULL &&
		    !ofdisatty(ofd) &&
		    ofd->o_dfd->dfd_dev == dev) {
			/* got one; unlink & free the ofd */
			*uft = NULL;
			if (--ofd->o_use == 0) {
			    dfd = ofd->o_dfd;
			    if (--dfd->dfd_use == 0) {
				/* unlink & free the DFD */
				if (dfd->dfd_prev) {
				    dfd->dfd_prev->dfd_next = dfd->dfd_next;
				}
				else dfd_head = dfd->dfd_next;
				if (dfd->dfd_next) {
				    dfd->dfd_next->dfd_prev = dfd->dfd_prev;
				}
				freebig(dfd);
			    }
			    /* unlink & free the OFD */
			    if (ofd->o_prev) {
				ofd->o_prev->o_next = ofd->o_prev;
			    }
			    else ofd_head = ofd->o_next;
			    if (ofd->o_next) {
				ofd->o_next->o_prev = ofd->o_prev;
			    }
			    freebig(ofd);
			}
		}
		uft++;
	    }
	}
    }
}

long
xsync()
{
    DFD *dfd;
    DIR dir;
    long err;
    FCB *fcb;

    /* update all dirty DFD's -- mark BCB's dirty so flushall writes them */
    for (dfd = dfd_head; dfd; dfd = dfd->dfd_next) {
	if (dfd->dfd_dirty) {
	    dir.dir_dev = dfd->dfd_dev;
	    dir.dir_clust = dfd->dfd_dircl;
	    dir.dir_recno = dfd->dfd_dirrec;
	    dir.dir_recoffs = dfd->dfd_diroffs;
	    if (err = dir2dir(&dir)) return err;
	    fcb = dir.dir_fcb;
	    fcb->f_attrib = dfd->dfd_attrib;
	    fcb->f_time = dfd->dfd_time;
	    fcb->f_date = dfd->dfd_date;
	    fcb->f_clust = dfd->dfd_strtcl;
	    fcb->f_fileln = dfd->dfd_fileln;
	    swp68l(fcb->f_fileln);
	    dir.dir_bcb->b_dirty = 1;
	    dfd->dfd_dirty = 0;
	}
    }

    flushall();
    return E_OK;
}

/*
 * long Fread(handle,count,buffer)
 *  read 'count' bytes from 'handle' to 'buffer'
 *
 * Calls cgets or xrw as appropriate.
 * Cuts the request down so it doesn't fall of EOF before calling xrw.
 */

long
xread(h,len,ubufr)
int h;
ulong len;
void *ubufr;
{
	OFD *ofd;

	DBCMD(1,"print xread -x (wpeek (`a6 + 8)) -x (lpeek (`a6 + a)) "
		"-x (lpeek (`a6 + e));_c");

	if ((ofd = syshnd(h)) == NULL) return EIHNDL;
	if (!len) return 0;
	if (ofdisatty(ofd)) {
	    return cgets(ofddevno(ofd),len,ubufr);
	}
	return ixread(ofd,len,ubufr);
}

/* ixread split out of read because some console routines use it. */

long
ixread(ofd,len,ubufr)
OFD *ofd;
ulong len;
void *ubufr;
{
	long maxlen;

	if (len > (maxlen = (ofd->o_dfd->dfd_fileln - ofd->o_bytnum)))
	    len = maxlen;
	if (len) return xrw(0, ofd, len, ubufr, xfr2usr);
	else return 0;
}

/*
 * long Fwrite(handle,count,buffer)
 *  read 'count' bytes from 'handle' to 'buffer'
 *
 * May be called with 'handle' -ve or referring through PD to a BIOS dev.
 *
 * Calls char_write or xrw, as appropriate.
 */

long
xwrite(h,len,ubufr)
int h;
long len;
void *ubufr;
{
	OFD *ofd;

	DBCMD(1,"print xwrite -x (wpeek (`a6 + 8)) -x (lpeek (`a6 + a)) "
		"-x (lpeek (`a6 + e));_c");

	if ((ofd = syshnd(h)) == NULL) return EIHNDL;
	if (!len) return 0;
	if (ofdisatty(ofd))
	    return char_write(ofddevno(ofd),len,ubufr);

	return ixwrite(ofd,len,ubufr);
}

/* ixwrite split out because console routines use it */

long
ixwrite(ofd,len,ubufr)
OFD *ofd;
long len;
void *ubufr;
{
	long err;
	DFD *dfd;

#if RO_FACISM
	if (!(ofd->o_flag & O_WRITE)) return EACCDN;
#endif

	err = xrw(1,ofd,len,ubufr,usr2xfr);

	/* update date, time, and archive bit on writes which write   */
	/* (this means a write which succeeds partway doesn't update) */
	if (err > 0) {
	    dfd = ofd->o_dfd;
	    dfd->dfd_date = realdate;
	    dfd->dfd_time = realtime;
	    swp68(dfd->dfd_date);
	    swp68(dfd->dfd_time);
	    dfd->dfd_attrib |= FA_ARCHIVE;
	    dfd->dfd_dirty = 1;
	}
	return err;
}

/*
 * Create File and open it for reading and writing.
 * Create `name' with the given name and attribute byte, and return a handle.
 * If the attribute includes read-only, then the (empty!) file is opened
 * for reading only (!).
 *
 * Creating a read-only file is actually useful: you can use it as a locking
 * mechanism in a multi-tasking environment.
 *
 *	ACQUIRE LOCK: Fcreate("lock",FA_RO);
 *
 *	RELEASE LOCK: Fattrib("lock",1,0);	(make writable)
 *	(and optionally Fdelete("lock");)
 *
 * The acquire operation will fail if the lock file exists, and succeed
 * atomically if it doesn't.
 */
long
xcreat(name,attr)
char *name;
int attr;
{
	long err;
	DIR dir;

	DBCMD(1,"print xcreat -s (lpeek (`a6 + 8)) -x (wpeek (`a6 + c));_c");

	/* deny creates of subdirs; also of labels with any other bit set */
	if ((attr & FA_SUBDIR) || ((attr & FA_LABEL) && (attr != FA_LABEL)))
		return EBADRQ;

	/* ttyopen returns -1 if NOT a TTY name, else opens it */
	if ((err = ttyopen(name)) != -1) return err;

	if (err = ixcreat(name, attr, &dir)) return err;
	return ixopen(&dir,((attr & FA_RO) ? 0 : 2));
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

    DBCMD(1,"print xopen -s (lpeek (`a6 + 8)) -x (wpeek (`a6 + c));_c");

    /* ttyopen returns -1 if NOT a tty name, else opens it */
    if ((err = ttyopen(name)) != -1) return err;

    /* find the file */
    err = fn2dir(&name,&dir,SCAN_NORM);
    if (err) return err;
    else if (dir.dir_fcb->f_attrib & FA_SUBDIR) return EACCDN;

    return ixopen(&dir,mod);
}

/*
 * ttyopen: if the name matches a TTY name, create an entry in your user
 * file table holding a "pointer" which ofdisatty and return the handle
 * number. Else return -1.
 */

const struct ttyn {
    const char ttyname[3];
    const char ttynum;
} ttynames[] = {
    { "CON", 2 },
    { "con", 2 },
    { "AUX", 1 },
    { "aux", 1 },
    { "PRN", 0 },
    { "prn", 0 }
};

long
ttyopen(name)
char *name;
{
    const struct ttyn *ttyp;
    const char *p1, *p2;
    int i;

    /* fail if name doesnt match XXX:\0 pattern */
    p1 = name;
    if (!*p1++ || !*p1++ || !*p1++ || *p1++ != ':' || *p1) {
	return -1;
    }

    ttyp = &ttynames[0];
    i = (sizeof(ttynames) / sizeof(struct ttyn));
    while (i--) {
	p1 = name;
	p2 = &ttyp->ttyname[0];
	if (*p1++ == *p2++ && 
	    *p1++ == *p2++ &&
	    *p1++ == *p2++) {
		if ((i = uftprobe()) == -1) return ENHNDL;
		run->p_uft[i] = ofdtty(ttyp->ttynum);
		return i;
	}
	ttyp++;
    }
    return -1;
}
		

/*
 * ixopen: given a DIR entry, open the file.
 *
 * ERROR CONSIDERATIONS:
 * 
 * Since this function doesn't do any writes, it can't mangle the disk. We
 * allocate an OFD early because we know we'll need one, and free it if we
 * then need a DFD and can't get one, but that's all that can go wrong.
 */

long
ixopen(dir,mod)
DIR *dir;
uint mod;
{
    FCB *fcb;
    int h;
    DFD *dfd;
    OFD *ofd;

    DBCMD(8,"print ixopen dir: -x (lpeek (`a6 + 8)) mode -x (wpeek (`a6 + c));"
	    "dirf (lpeek (`a6 + 8));_c");

    /* fail if opening for mode other than zero and file is RO */
    if (mod && (dir->dir_fcb->f_attrib & FA_RO)) return EACCDN;

    /* fail if there are no handles left */
    if ((h = uftprobe()) < 0) return ENHNDL;

    /* get an OFD first, because we know we'll need one */
    /* and failure should get us out of here NOW. */

    if ((ofd = MGET(OFD)) == NULL) return ENHNDL;

    if ((dfd = getdfd(dir)) == NULL) {
	/* no DFD for this file already; get a new one, fill it in */
	if ((dfd = MGET(DFD)) == NULL) {
	    MFREE(ofd);
	    return ENHNDL;
	}

	fcb = dir->dir_fcb;

	dfd->dfd_time = fcb->f_time;
	dfd->dfd_date = fcb->f_date;
	dfd->dfd_strtcl = fcb->f_clust;
	dfd->dfd_fileln = fcb->f_fileln;
	swp68l(dfd->dfd_fileln);
	dfd->dfd_attrib = fcb->f_attrib;
	dfd->dfd_dev = dir->dir_dev;
	dfd->dfd_dircl = dir->dir_clust;
	dfd->dfd_dirrec = dir->dir_recno;
	dfd->dfd_diroffs = dir->dir_recoffs;
	dfd->dfd_use = 0;
	dfd->dfd_dirty = 0;

	/* link it in to dfd_head */
	dfd->dfd_next = dfd_head;
	dfd->dfd_prev = 0;
	if (dfd_head) dfd_head->dfd_prev = dfd;
	dfd_head = dfd;
    }

    /* fill in the OFD */
    ofd->o_mode = mod;
    ofd->o_curcl = 0;	/* flag meaning r/w clust info uninitialized */
    ofd->o_currec = 0;
    ofd->o_bytnum = 0;

    ofd->o_use = 1;
    ofd->o_dfd = dfd;
    dfd->dfd_use++;

    /* link it in to ofd_head */
    ofd->o_next = ofd_head;
    ofd->o_prev = 0;
    if (ofd_head) ofd_head->o_prev = ofd;
    ofd_head = ofd;

    /* make handle h refer to this ofd and return h */

    run->p_uft[h] = ofd;

    DBCMD(8,"print end of ixopen:;uft lpeek(.run);_c");
    return h;
}

/*
 * xlseek: update the read-write pointer of a file. Calls ixlseek on the
 * OFD and new pointer location.
 *
 * For tty's, returns zero.  Some programs use this to determine isatty.
 */

long
xlseek(n,h,flg)
long n;
int h;
int flg;
{
    OFD *ofd;

    DBCMD(1,"print xlseek -x (lpeek (`a6 + 8)) -x (wpeek (`a6 + c)) "
	    "-x (wpeek (`a6 + e));_c");

    if ((ofd = syshnd(h)) == NULL) return EIHNDL;
    if (ofdisatty(ofd)) return 0;

    return ixlseek(n,ofd,flg);
}

/* ixlseek split out from above because console I/O uses it */

long
ixlseek(n,ofd,flg)
long n;
OFD *ofd;
int flg;
{
    DFD *dfd;
    ulong new;	/* file-relative cluster number that byte n is in */
    ulong old;	/* file-relative cluster number that curbyt is in */
    ulong clcount;	/* number of clusters to advance from curcl */
    uint rec;
    DMD *dmd;
    uint curcl;
    int eof_flag = 0;

    dfd = ofd->o_dfd;

    if (flg == 2)
	n += dfd->dfd_fileln;
    else if (flg == 1)
	n += ofd->o_bytnum;
    else if (flg)
	return(EINVFN);

    if (n > dfd->dfd_fileln || n < 0)
	return(ERANGE);

    /* no-op if you aren't really seeking. */
    if (n == ofd->o_bytnum) return n;

    dmd = &drvtbl[dfd->dfd_dev];

    /* set OFD r/w pointer fields to the right values */
    /* the first "if" takes care of zero-length files. */
    if (!n) ofd->o_curcl = 0;	/* flag meaning beginning of file */
    else {
	new = n >> dmd->m_clblog;
	old = ofd->o_bytnum >> dmd->m_clblog;
	if (new < old) {
	    curcl = dfd->dfd_strtcl;
	    swp68(curcl);
	    clcount = new;
	}
	else {
	    /* (new >= old) */
	    curcl = ofd->o_curcl;
	    if (!curcl) {
		curcl = dfd->dfd_strtcl;
		swp68(curcl);
	    }
	    else if (((ofd->o_currec & dmd->m_clrm) == 0) &&
		     (ofd->o_bytnum < dfd->dfd_fileln) &&
		     (ofd->o_currec >= (cl2rec(curcl,dmd) + dmd->m_clsiz))) {
		/*
		 * last read/write ended at a cluster boundary which was
		 * not end of file.  Update curcl to the true values: the
		 * first record of the next cluster after what curcl is
		 * now.
		 */
		if ((curcl = nextcl(curcl,dmd,0)) == 0) {
		    /* nextcl returns zero on EOF and bad cluster and error */
		    return ERROR;
		}
	    }

	    /* curcl is now the right number */

	    if (n == dfd->dfd_fileln && (n & (dmd->m_clsizb-1)) == 0) {
		/*
		 * seek to end of file which is end of cluster: This is
		 * flagged in xrw as a special case, where the recno is one
		 * GREATER than the last record in curcl. "New" will have
		 * been set above to one cluster more than are in the file,
		 * so we bump it down and set a flag which gets used later.
		 * We do it here because if new < old then this can't
		 * happen -- you aren't seeking to end of file, are you?
		 */
		new--;
		eof_flag = 1;
		DBCMD(8,(&dfd,&new,&old,&n,  /* force these to be on stack */
			"print seek to eof at cluster boundary.;"
			"print n: -x (lpeek(a6+8)) new: -x (lpeek(a6-8)) "
			"old: -x (lpeek(a6-0c));_c"));
	    }
	    clcount = (new-old);
	}

	/*
	 * Inside the loop, you return ERROR when nextcl returns EOF
	 * or errors like bad cluster.
	 */

	while (clcount--) {
	    if (!(curcl = nextcl(curcl,dmd,0))) return ERROR;
	}

	/*
	 * Set rec to the record offset in this clust.  Set it to the
	 * cluster size in records if you're seeking to the end of file at
	 * a cluster boundary.  'rec' in that case is always zero (cluster
	 * bounardy, remember?) and you want the result to be the first
	 * record number PAST that cluster.
	 */
	if (eof_flag) rec = dmd->m_clsiz;
	else rec = (n & (dmd->m_clsizb-1)) >> dmd->m_rblog;

	ofd->o_curcl = curcl;
	ofd->o_currec = cl2rec(curcl,dmd) + rec;
    }

    ofd->o_bytnum = n;

    DBCMD(8,"print end of xlseek:;uft lpeek(.run);_c");
    return(n);
}

/*
 * Fdatime, Get/Set File Date and Time
 *
 * Megamax C relies on this function leaving the input buffer alone on a
 * read when the handle isatty, and on changing it (with the file's info)
 * when the handle !isatty.  We can preserve that and still return EIHNDL
 * with the handle refers to a tty.
 *
 * We change the DFD for the open file, not what's on disk. Fsfirst/next
 * has to look for a DFD or it will be out of date.
 *
 * NO DISK ACTIVITY, NO ERROR CONSIDERATIONS.
 */

long
xdatime(buf, h, wrt)
int *buf;			/* -> user buffer */
int h;				/* file handle */
int wrt;			/* 0:get, 1:set */
{
    OFD *ofd;
    DFD *dfd;
    int t[2];			/* buffer to hold user input for swapping */

    DBCMD(1,"print xdatime -x08 (lpeek (lpeek (`a6 + 8))) -x (wpeek (`a6 + c)) "
	    "-x (wpeek (`a6 + e));_c");

    ofd = syshnd(h);
    if (ofd == NULL || ofdisatty(ofd)) return EIHNDL;
  
    dfd = ofd->o_dfd;
    if (!buf) return EBADRQ;	/* a little self-protection! */

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

    DBCMD(8,"print end of xdatime;uft lpeek(.run);_c");
    return E_OK;
}

/****************************************************************************/
/* Misc routines which don't deserve a file of their own.		    */
/****************************************************************************/

/*
 * Return address of DTA.
 */
long
xgetdta()
{
	DBCMD(1,"print xgetdta;_c");
	return((long)run->p_xdta);
}


/*
 * Set DTA.
 */
long
xsetdta(addr)
DTA *addr;
{
	DBCMD(1,"print xsetdta -x (lpeek (`a6 + 8));_c");
	run->p_xdta = addr;
	return 0;		/* Return success! AKP 1/91 */
}


/*
 * Set default drive;
 * 0 = A, 1 = B, and so on.
 */
long
xsetdrv(drv)
uint drv;
{
	DBCMD(1,"print xsetdrv -x (wpeek (`a6 + 8));_c");
	if (drv > MAXDEVS) return EDRIVE;
	run->p_curdrv = drv;
	return( trapD(0x0A) );	/* return Drvmap() */
}


/*
 * Return default drive;
 * 0 = A, 1 = B, and so on.
 */
long
xgetdrv()
{
	DBCMD(1,"print xgetdrv;_c");
	return(run->p_curdrv);
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
 * Function Not Implemented;
 * return "Invalid Function Number."
 */
long
ni()
{
	return(EINVFN);
}

