/*
***************************    FSHAND.C    ******************************
*
* $Revision: 2.5 $	$Source: e:/tos/gd2\RCS\fshand.c,v $
* =======================================================================
* $Author: apratt $ 	$Date: 1991/02/11 19:56:48 $    $Locker:  $
* =======================================================================
*
* $Log: fshand.c,v $
* Revision 2.5  1991/02/11  19:56:48  apratt
* Checkin lest I lose work (again)
*
* Revision 2.4  91/01/23  14:30:08  apratt
* Trimmed logs & comments, changed to compile under GCC or (new) Alcyon.
* 
*************************************************************************
*/

#include "fs.h"

/*
 * hand_init: initialize the handle system.
 */

char biosdev[NUMSTD] = { -1, -1, -2, -3, -1, -1 };

voidfn
hand_init()
{
    int i;
    for (i=0; i<NUMSTD; i++) {
	sft[i].f_own = &rootpd;
	ofdmaketty(sft[i].f_ofd,biosdev[i]);
    }
}


/*
 * return the index of an available slot in the SFT.
 */

int
sftprobe()
{
    int i;
    FTAB *fptr;

    for (i = 0, fptr = &sft[0]; i < OPNFILES; i++, fptr++)
	if (!fptr->f_own)
	    return i;
    return -1;
}

/*
 * Given a user handle number, return the slot number in SFT.
 * This includes turning negative user handles into the corresponding
 * positive one, and indirecting handles 0-NUMSTD through the PD.
 *
 * Returns -NUMBIOS for invalid handles, -ve for -ve input, or sft slot number.
 */
int
syshnd(h)
int h;
{
	if (h <= -NUMBIOS || h > OPNFILES) 
	    return -NUMBIOS;				/* too small/big */
	if (h < 0) return -h;				/* BIOS dev */
	if (h < NUMSTD) return run->p_uft[h];		/* PD indirect */
	return h;					/* direct */
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
 */

/*
 * Duplicate handle.
 */
long
xdup(h)	/*+ h must be a standard handle (checked) */
int h;
{
	int i;
	FTAB *fptr;

	if ((h<0) || (h >= NUMSTD))
		return(EIHNDL);		/* only dup standard */

	if ((i = sftprobe()) < 0) return (ENHNDL);

	fptr = &sft[i];

	/* get real slot number, fail if -ve */
	if ((h = syshnd(h)) < 0) return EIHNDL;

	fptr->f_own = run;
	fptr->f_ofd = sft[h].f_ofd;
	fptr->f_ofd->o_use++;		/* OFD used again now */

	return(i);
}


/*
 * Force handle: force 'std' to be the same thing that 'h' is.
 * 'std' must be a standard handle [0-NUMSTD), h may not be.
 */
long
xforce(std,h)
int std,h;
{
	return(ixforce(std,h,run));
}

/*
 * ixforce: called by xforce and pexec, takes the additional arg
 * of the PD in which the force takes place.  'h' is still
 */
long
ixforce(std,h,p)	/* h   must NOT be a standard handle */
PD *p;			/* std must	be a standard handle */
int std;
int h;
{
	int stdh;
	long err;

	if ((std < 0) || (std >= NUMSTD))
		return(EIHNDL);
	
	if (h < NUMSTD || h > OPNFILES) {
	    /* too small/big, or a BIOS handle, or a STD handle */
	    return EIHNDL;
	}
	if (sft[h].f_own == NULL) 
	    return EIHNDL;		/* invalid handle */

	/* close whatever 'std' points to already. */
	/* Don't bother if being called by pexec, setting up a new PD. */
	/* The syshnd call can't fail, since std is known to be legal. */

	if (p == run) {
	    stdh = syshnd(std);
	    /* this assert will fail if sombody's monkeyed with your PD */
	    ASSERT(stdh >= NUMSTD);
	    if (sft[stdh].f_own != NULL && !ofdisatty(sft[stdh].f_ofd)) {
		/* std really points to a file. Close it. */
		/* If the close returns and error, God help you. */
		if (err = xclose(std)) return err;
	    }
	}

	if (h < 0) {
	    /* Force std to be BIOS device h+3. */
	    /* To do this we use a slot in SFT & point p_uft[std] at it. */
	    stdh = sftprobe();
	    sft[stdh].f_own = p;
	    ofdmaketty(sft[stdh].f_ofd,h+3);
	    p->p_uft[std] = stdh;
	}
	else {
	    /* Force std to be whatever h is */
	    stdh = sftprobe();
	    sft[stdh].f_own = p;
	    sft[stdh].f_ofd = sft[h].f_ofd;
	    p->p_uft[std] = stdh;
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
	int realh;
	OFD *fd;
	long rc;
	FTAB *fptr;

	if (h <= -NUMBIOS) return EIHNDL;
	if (h < 0) return(E_OK);	/* "close" a character device */

	realh = syshnd(h);
	if (realh == -NUMBIOS) return EIHNDL;
	if (sft[realh].f_own == NULL) return EIHNDL;	/* not open */

	/* note: anybody can close anybody else's handle; */
	/* check would go here to restrict that.	  */

	fptr = &sft[realh];
	if (ofdisatty(fptr->f_ofd)) {
	    /* close a char device; really do nothing */
	    /* but see below: we reopen h onto BIOS dev if it's std */
	}
	else {
	    /* close a file; return errors before doing side effects */
	    if ((fd=fptr->f_ofd)->o_use == 1) {
		/* the OFD use count would drop to zero */
		if (fd->o_dfd->dfd_use == 1) {
		    /* the DFD use count would drop to zero */
		    if (rc = dfd_close(fd->o_dfd))	/* close the DFD */
			return rc;
		}
		else --(fd->o_dfd->dfd_use);
		if (rc = ofd_close(fd))			/* close the OFD */
		    return rc;
	    }
	    else --(fd->o_use);
        }

	if (h >= NUMSTD) {
	    fptr->f_own = NULL;				/* free this slot */
        }
        else {
	    /* h was a std handle; we need to reopen it on a char dev. */
	    /* fptr points to a slot we can use. */
	    fptr->f_own = run;
	    fptr->f_ofd = sft[h].f_ofd;	    /* dup a low sft handle */

	    /* I don't know if this is ever going to be necessary */
	    if (!ofdisatty(fptr->f_ofd)) fptr->f_ofd->o_use++;
	}
	return E_OK;
}   

/*
 * long dfd_close(dfd)
 *
 * Called only when the dfd's use count would reach zero.
 * Writes the dirty information if dirty, and frees the dfd.
 */

long
dfd_close(dfd)
DFD *dfd;
{
	DIR dir;
	long err;

	if (dfd->dfd_dirty) {
		dir.dir_dev = dfd->dfd_dev;
		dir.dir_cl = dfd->dfd_dircl;
		dir.dir_rec = dfd->dfd_dirrec;
		dir.dir_recoffs = dfd->dfd_diroffs;
		if (err = dir2dir(&dir)) return err;
		dir.dir_fcb->f_attrib = dfd->dfd_attrib;
		dir.dir_fcb->f_time = dfd->dfd_time;
		dir.dir_fcb->f_date = dfd->dfd_date;
		dir.dir_fcb->f_clust = dfd->dfd_strtcl;
		dir.dir_fcb->f_fileln = dfd->dfd_fileln;
		swp68l(dir.dir_fcb->f_fileln);
		dirdirty(&dir);
	}
	freebig(dfd);
	return E_OK;
}

/*
 * long ofd_close(ofd)
 *
 * Called only when the ofd's use count would reach zero.
 * Frees the ofd.
 */

long
ofd_close(ofd)
OFD *ofd;
{
	freebig(ofd);
	return E_OK;
}

/*
 * long Fread(handle,count,buffer)
 *  read 'count' bytes from 'handle' to 'buffer'
 *
 * May be called with 'handle' -ve or referring through PD to a BIOS dev.
 * Calls char_read or xrw as appropriate.
 * Cuts the request down so it doesn't fall of EOF before calling xrw.
 */

long
xread(h,len,ubufr)
int h;
long len;
void *ubufr;
{
	OFD *p;
	long maxlen;

	if ((h = syshnd(h)) == -NUMBIOS) return EIHNDL;
	if (!len) return 0;
	if (h < 0) return char_read(h+3,len,ubufr);
	p = sft[h].f_ofd;
	if (ofdisatty(p)) 
	    return char_read(ofddevno(p),len,ubufr);

	if (len > (maxlen = (p->o_dfd->dfd_fileln - p->o_bytnum)))
	    len = maxlen;
	if (len) return xrw(0, p, len, ubufr, xfr2usr);
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
	OFD	*p;

	if ((h = syshnd(h)) == -NUMBIOS) return EIHNDL;
	if (!len) return 0;
	if (h < 0) return char_write(h+3,len,ubufr);
	p = sft[h].f_ofd;
	if (ofdisatty(p))
	    return char_write(ofddevno(p),len,ubufr);
#if RO_FACISM
	if (!(p->o_flag & O_WRITE)) return EACCDN;
#endif

	/* update date, time, and archive bit on all writes */
	p->o_dfd->dfd_date = date;
	p->o_dfd->dfd_time = time;
	swp68(p->o_dfd->dfd_date);
	swp68(p->o_dfd->dfd_time);
	p->o_dfd->dfd_attrib |= FA_ARCHIVE;
	p->o_dfd->dfd_dirty = 1;
	return xrw(1,p,len,ubufr,usr2xfr);
}

/*
 * Create File and open it for reading and writing.
 * Create `name' with the given name and attribute byte, and return a handle.
 * If the attribute includes read-only, then the (empty!) file is opened
 * for reading only (!).
 */
long
xcreat(name,attr)
char *name;
char attr;
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
int drv;
{
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

/*
 *  Copy string `s' of length `n' to `d'.
 *
 *  This function is identical to xfr2usr.
 */
voidfn
xmovs(n, s, d)
int n;
void *s, *d;
{
  while (n--)
    *(char *)d++ = *(char *)s++;
}
