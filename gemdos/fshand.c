/*
***************************    FSHAND.C    ******************************
*
* $Revision: 2.7 $	$Source: e:/tos/gd2\rcs\fshand.c,v $
* =======================================================================
* $Author: apratt $ 	$Date: 1991/02/15 18:45:40 $    $Locker:  $
* =======================================================================
*
* $Log: fshand.c,v $
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
	    if (*fptr == NULL) return i;
    }
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
	if (h <= -NUMBIOS || h >= run->p_uftsize)
	    return NULL;			/* too small/big */
	if (h < 0) return (OFD *)(~(h+3));	/* old-style BIOS dev */
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
	PD *_run;
	OFD *ofd;

	if ((dest < 0) || (dest >= pd->p_uftsize))
		return(EIHNDL);

	if (src < -NUMBIOS || src >= _run->p_uftsize) {
	    /* too small/big */
	    return EIHNDL;
	}

	if (src >= 0) {
	    ofd = _run->p_uft[src];
	    if (ofd == NULL) return EIHNDL;


	    if (pd == _run) {
		/* close whatever 'dest' points to already, */
		/* but only if not spawning a new process.  */

		if (err = xclose(dest)) return err;
	    }
	    /* now copy it over, and increase use count */
	    pd->p_uft[dest] = ofd;
	    ofd->o_use++;
	}
	else {
	    /* is there an equivalent to o_use++ for TTY's? */
	    pd->p_uft[dest] = ofdtty(src+3);
	}
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
 */

long
xclose(h)
int h;
{
	OFD *ofd;
	PD *_run;

    /* A while ago, I "guaranteed" that any close would flush all */
    /* dirty sectors on all drives ... do that first. See xsync() */

    xsync();

    if (h < -NUMBIOS || h >= _run->p_uftsize) return EIHNDL;
    if (h < 0) return E_OK;	    /* "close" an old-style TTY */

    if ((ofd = _run->p_uft[h]) == NULL) return EIHNDL;	/* not open */

    /* mark as closed, but see below: h<NUMSTD gets reopened */
    _run->p_uft[h] = NULL;

    if (ofdisatty(ofd)) {
	/* close a new-style char device; really do nothing for now,  */
	/* but see below: we reopen h onto BIOS dev if it's a std hdl */
    }
    else {
	/* close a file; really close it in spite of errors */
	if ((--ofd->o_use) == 0) {
	    if (--(ofd->o_dfd->dfd_use) == 0) {
		freebig(ofd->o_dfd);
	    }
	    freebig(ofd);
	}
    }

    /* now re-open the handle on its default BIOS device if < NUMSTD */
    if (h < NUMSTD) {
	/* h was a std handle; we need to reopen it on a char dev. */
	_run->p_uft[h] = ofdtty(biosdev[h]);
    }

    return E_OK;
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
long len;
void *ubufr;
{
	OFD *ofd;
	long maxlen;

	if ((ofd = syshnd(h)) == NULL) return EIHNDL;
	if (!len) return 0;
	if (ofdisatty(ofd)) {
	    if (len > 32767) len = 32767;
	    return cgets(ofddevno(ofd),len,ubufr);
	}

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
	OFD	*ofd;
	long err;

	if ((ofd = syshnd(h)) == NULL) return EIHNDL;
	if (!len) return 0;
	if (ofdisatty(ofd))
	    return char_write(ofddevno(ofd),len,ubufr);
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

	/* deny creates of subdirs; also of labels with any other bit set */
	if ((attr & FA_SUBDIR) || ((attr & FA_LABEL) && (attr != FA_LABEL)))
		return EBADRQ;
	if (err = ixcreat(name, attr, &dir)) return err;
	return ixopen(&dir,((attr & FA_RO) ? 0 : 2));
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
	return((long)run->p_xdta);
}


/*
 * Set DTA.
 */
long
xsetdta(addr)
DTA *addr;
{
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
	if (drv > MAXDEVS) return EDRIVE;
	run->p_curdrv = drv;
	return( trap13(0x0A) );	/* return Drvmap() */
}


/*
 * Return default drive;
 * 0 = A, 1 = B, and so on.
 */
long
xgetdrv()
{
	return(run->p_curdrv);
}

