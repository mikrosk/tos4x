/*
***************************    FSHAND.C    ******************************
*
* $Revision: 2.3 $	$Source: /u2/MRS/osrevisions/gemdos/fshand.c,v $
* =======================================================================
* $Author: apratt $ 	$Date: 90/08/03 13:41:29 $    $Locker:  $
* =======================================================================
*
* $Log: fshand.c,v $
* Revision 2.3  90/08/03  13:41:29  apratt
* TTOS FINAL RELEASE
* 
* Revision 2.2  89/04/17  17:14:36  kbad
* YA header change
* 
* Revision 2.1  89/02/21  17:20:12  kbad
* *** TOS 1.4  FINAL RELEASE VERSION ***
* 
* Revision 1.5  88/10/11  13:23:12  apratt
* Added a guard against Fforce()-ing to an invalid handle.
* 
* Revision 1.4  88/10/05  13:03:40  apratt
* In xclose, there's a pointer being used as shorthand.
* I did it wrong when closing a "standard" handle (0-5).
* Now it's right.
* 
* Revision 1.3  88/08/08  17:40:00  apratt
* Added sftprobe() to remove duplicate code, and fixed a range check
* in getofd().
* 
* Revision 1.2  88/06/13  15:06:20  apratt
* Header style change
* 
* Revision 1.1  88/04/26  14:48:22  apratt
* Version used 4/22/88 to make test ROMs
* 
*************************************************************************
*/

/****************************************************************************\
* 									     *
* GEMDOS File System Handle Operations					     *
* (C)1986 Atari Corp.							     *
* 									     *
* ---- Edit history (reverse order, please): ------------------------------  *
* 									     *
* 18-Apr-1988 akp	Made getofd into a function again, added check.	     *
* 22-Mar-1988 akp	Fixed zero-length-write-never-returns bug (and read) *
* 03-Feb-1988 akp	Changed some register declarations, getofd -> macro. *
* 01-Feb-1988 akp	Added "p->o_flag |= O_DIRTY" to xwrite, for	     *
*			archive bit handling.				     *
* 12-Jan-1988 akp	Fixed Fclose: when closing a standard handle, it     *
*			reverts to the BIOS device, not 0.		     *
* 17-Jan-1986 lmd	Commented and prettified from Digital Research	     *
* 			source code.					     *
* 30-Jan-1986 lmd	Broken out from old FS.C			     *
* 									     *
\****************************************************************************/

#include "fs.h"
#include "gemerror.h"
#include "fsdecl.h"

/*
 * Return a valid handle;
 * if the handle refers to standard device,
 * return what the handle really refers to.
 */
syshnd(x_h)
int x_h;
{
	REG int h;

	h = x_h;
	if ((h >= NUMSTD) ||
	    ((h = run->p_uft[h]) > 0))
		h -= NUMSTD;

	return(h);
}


OFD
*getofd(h)
int h;
{
	if (h < 0 || h >= (OPNFILES + NUMSTD)) return 0; /* out of range */
	h = syshnd(h);
	if (h < 0) return 0;		/* char devs have no ofd */
	return(sft[h].f_ofd);
}

/*
 * Duplicate handle.
 */
long
dup(h)	/*+ h must be a standard handle (checked) */
int h;
{
	REG int i;
	REG FTAB *fptr;

	if ((h<0) || (h >= NUMSTD))
		return(EIHNDL);		/* only dup standard */

	if ((i = sftprobe()) < 0) return (ENHNDL);

	fptr = &sft[i];

	fptr->f_own = run;

	if ((h = run->p_uft[h]) > 0)
		fptr->f_ofd = sft[h-NUMSTD].f_ofd;
	else
		fptr->f_ofd = (long) h;

	fptr->f_use = 1;

	return(i+NUMSTD);
}


/*
 * Force handle.
 */
long
xforce(std,h)
int std,h;
{
	return(ixforce(std,h,run));
}


long
ixforce(x_std,x_h,x_p)	/* h   must NOT be a standard handle */
PD *x_p;		/* std must	be a standard handle */
int x_std;
int x_h;
{
	REG PD *p;
	REG int std;
	REG int h;
	REG long fh;

	p = x_p;
	std = x_std;
	h = x_h;

	if ((std < 0) || (std >= NUMSTD))
		return(EIHNDL);
	
	if (h < 0)
		p->p_uft[std] = h;
	else
	{
		if (h < NUMSTD)
			return(EIHNDL);

		if (!getofd(h)) return (EIHNDL);	/* AKP 10/88 */

		if ((fh = sft[h-NUMSTD].f_ofd) < 0L)
			p->p_uft[std] = fh;
		else
		{
			p->p_uft[std] = h;
			sft[h-NUMSTD].f_use++;
		}
	}
	return(E_OK);
}


/*	Function 0x3E	f_close

	Error returns
		EIHNDL
		ixclose()

	Last modified	SCC	10 Apr 85

SCC	I have added 'rc' to allow return of status from ixclose().
	I do not yet know whether it is appropriate to perform the
	operations inside the 'if' statement following the invocation
	of ixclose(), but I am leaving the flow of control intact.
*/

long
xclose(h)
int h;
{
REG	int h0;
REG	OFD *fd;
REG	long rc;
REG	FTAB *fptr;

	fptr = &sft[h-NUMSTD];	/* shorthand */

	if (h < 0)
		return(E_OK);	/* always a good close on a character device */

	if ((h0 = h) < NUMSTD)
	{
		h = run->p_uft[h];
		fptr = &sft[h-NUMSTD];	/* update the shorthand */
		/* AKP: when closing a std handle, it reverts to BIOS dev */
		run->p_uft[h0] = biosdev[h0];
		if (h < 0)
			return(E_OK);
	}
	else if (((long) fptr->f_ofd) < 0L)
	{
		if (!(--(fptr->f_use)))
		{
			fptr->f_ofd = 0;
			fptr->f_own = 0;
		}
		return(E_OK);
	}

	if (!(fd = getofd(h)))
		return(EIHNDL);

	rc = ixclose(fd,0);

	if (!(--(fptr->f_use)))
	{
		xmfreblk(fptr->f_ofd);
		fptr->f_ofd = 0;
		fptr->f_own = 0;
	}
	return(rc);
}


/*	Function 0x3F	f_read

	Error returns
		EIHNDL
		bios()

	Last modified	SCC	8 Apr 85
*/

long
xread(h,len,ubufr) /*+ read len (long) bytes from handle h */
int h;
long len;
char *ubufr;
{
REG	OFD	*p;

	if (p = getofd(h)) {
	    if (!len) return 0;
	    return(ixread(p,len,ubufr));
	}

	return(EIHNDL);
}


/*	Function 0x40	f_write

	Error returns
		EIHNDL
		bios()

	Last modified	SCC	10 Apr 85
*/

long
xwrite(h,len,ubufr) /*+ write len (long), handle h, buffer */
int h;
long len;
char *ubufr;
{
REG	OFD	*p;

	if (p = getofd(h))
           {
#ifdef RO_FASCISM
           /* Make sure file not opened as read only.*/
           if (p->o_mod == 0) return (EACCDN);
#endif
	   if (!len) return 0L;

	   /* set the dirty bit even though it might not be */
	   p->o_flag |= O_DIRTY;
           return(ixwrite(p,len,ubufr));
           }

	return(EIHNDL);
}


/*
	Error returns
		ENHNDL

	Last modified	SCC	8 Apr 85
*/

long
opnfil(f, dn, mod)
FCB *f;
DND *dn;
int mod;
{
	REG int i;
	REG int h;

	/* find free sft handle */
	if ((i = sftprobe()) < 0) return ENHNDL;

	sft[i].f_own = run;
	sft[i].f_use = 1;
	h = i+NUMSTD;

	return(makopn(f, dn, h, mod));
}

sftprobe()
{
    REG int i;
    REG FTAB *fptr;

    for (i = 0, fptr = &sft[0]; i < OPNFILES; i++, fptr++)
	if (!fptr->f_own)
	    return i;
    return -1;
}

