/*
***************************    SCAN.C     ********************************
*
* $Revision: 1.20 $	$Source: d:/tos/dos\RCS\scan.c,v $
* =======================================================================
* $Author: ersmith $ 	$Date: 1992/11/19 01:41:02 $    $Locker: ersmith $
* =======================================================================
*
* $Log: scan.c,v $
* Revision 1.20  1992/11/19  01:41:02  ersmith
* Fixed renaming bug (don't allow empty strings in rename).
*
* Revision 1.19  1992/08/11  00:37:02  kbad
* TOS 4.00 Falcon030 first production version
*
* Revision 1.18  1991/06/26  23:41:50  apratt
* Added a line to fail if a slash is at the end of a string and
* this isn't a DIR scan.
*
* Revision 1.17  1991/06/25  13:04:24  apratt
* This is slightly simplified from before... dots are always OK,
* double slashes always stop the scan, and EROOT is returned only
* if scan_type is SCAN_DIR (FN_NORM, FN_DOTSOK, etc are obsolete).
*
* Revision 1.16  1991/06/25  11:51:48  apratt
* Dsetpath(".") in root didn't work before, and neither did \\ as an arg.
* Now they do, but it's a crock, and I'm trying to improve it.
*
* Revision 1.15  1991/06/20  17:18:56  apratt
* Fixed a bug: ANDing recno with clrm is only valid when recno
* is relative to the start of a cluster (e.g. cluster 2).
*
* Revision 1.14  1991/06/18  17:52:02  apratt
* Updated to DB release 3 (new print)
*
* Revision 1.13  1991/05/30  16:06:06  apratt
* Added kludge code to handle multiple backslashes in a row.
*
* Revision 1.12  1991/05/09  17:37:28  apratt
* Split out dotsok and added trailok, fixed logic and trailing SLASH,
* changed dirnext's end-of-dir return from ENMFIL to EFILNF.
* Removed extended flag arg from nextcl call.
*
* Revision 1.11  1991/05/03  00:14:20  apratt
* Added acceptance of trailing backslash when dotsok; dotsok is
* assumed to be a flag saying "I came from Dsetpath" and we must
* accept a trailing SLASH in Dsetpath because old Gemdos does.
*
* Revision 1.10  1991/04/30  12:12:38  apratt
* Converted DBCMDs to new infix DB style
*
* Revision 1.9  1991/04/05  18:38:22  apratt
* Misc fixes making it work
*
* Revision 1.8  1991/03/28  17:39:36  apratt
* THIS VERSION BOOTS! DESKTOP OPERATIONS WORK!
*
* Revision 1.7  1991/03/13  17:51:44  apratt
* Added a debugging message on a new level at _dirnext.
*
* Revision 1.6  1991/03/12  18:25:26  apratt
* Making gtest.prg works and lets you test functions in this version
*
* Revision 1.5  1991/02/22  15:29:28  apratt
* generic checkin
*
* Revision 1.4  1991/02/21  03:07:32  apratt
* This version performs this testbed perfectly.
*
* Revision 1.3  1991/02/15  18:45:40  apratt
* CI at the end of the week...
*
* Revision 1.2  1991/02/12  18:20:10  apratt
* *** empty log message ***
*
* Revision 1.1  1991/02/11  19:56:48  apratt
* Checkin lest I lose work (again)
*
*************************************************************************
*/

#include "fs.h"

/*
 * low-level directory structure operations

The DIR structure information about a slot in a directory.  The info
includes the drive, the starting cluster number of the directory the slot
is in, the cluster number that the slot itself is in, the record number of
the slot, and the offset in that record of the slot.  In addition, a
"fresh" DIR structure has valid FCB and BCB pointers: FCB points to the
image of the slot in a disk cache sector, and BCB points to that sector's
BCB (so you can mark it dirty).

FUNCTIONS:

long
fn2dir(pname,dir,flag)
char **pname;
DIR *dir;
int flag;

Fills in (uninitialized) 'dir' with the info on the slot referenced by the
string at *pname, and advances that pointer to the last component of the
string (after the last SLASH).  Returns zero on success.  The file
attribute does not participate, except that FA_LABEL inhibits a match.

The input pathname is checked several ways, and errors return EBADRQ. The
idea behind EBADRQ is that retrying the request won't do any good: it's
intrinsically bad, not just "can't do that right now."

EBADRQ errors: any component includes a '*' or '?' character, any component
is empty (except last when dotsok), last component is "." or ".." (and not
dotsok), any component is an invalid file name.  Also a component like
"..abc" or other unparsable.

RETURNS: If the file doesn't exist, but you got all the way to the last
directory, then EFILNF is returned and that directory's dev and cluster are
valid.  (These are the only parts used as input to dirslot.)  If you didn't
even get to the last directory (i.e. a component not found, or a component
is a file not a directory) then EPTHNF is returned.  On a successful return
from fn2dir() (return code zero), dir is fresh.

Call with SCAN_NORM for normal scans.  These will match dot and dot-dot.
Call with SCAN_DIR to return EROOT when the path ultimately specifies the
root directory; otherwise you'll get EFILNF.  Call with SCAN_EARLY to
return before scanning for the last component.

A double backslash is taken as an empty component.  In the SCAN_DIR case,
the scanning stops but succeeds.  Otherwise the drive is touched and you
get EFILNF.  The drive is touched because of a bug in the Desktop, where
Fopen of c:\\x has to touch the drive.

QUIET CHANGE FROM ORIGINAL GEMDOS: Fopen("a:\*.*",0) used to open the first
file on A: but this code returns EBADRQ.

long
dir2dir(dir)
DIR *dir;

Freshens (valid, stale) dir.  A dir can't be freshened across media-change
on a drive, but this isn't checked.  All that happens is getrec() on the
record in question.  Uses only the dev, recno, and recoffs fields.

long
dirfirst(dir,dmd)
DIR *dir;
DMD *dmd;

Initializes (valid, stale) dir to the first slot in the dir specified
in the dev and clust fields.  On zero return dir is fresh.  Returns errors.

long
dirnext(dir,dmd)
DIR *dir;
DMD *dmd;

Partly a macro. Advances (fresh) dir to the next slot in the directory.
'dmd' is &drvtbl[dir->dir_drv] (saves multiplying inside loops). Returns
zero and leaves dir fresh for success.  EFILNF means everything succeeded
and you fell off the end of the dir.  ERROR means something went wrong (bad
FAT). In each case, dir_curcl is unchanged, meaning it's the last cluster
of the dir, but dir_recno is bad and the dir isn't fresh.  Can also return
any error from xgetrec, in which case all fields are correct but not fresh.

long
dirslot(dir)
DIR *dir;

Fills in dir (just dev/cl) with the first slot available in the directory
specified by dir's dev and clust fields.  Includes extending dir if
necessary. On successful return, dir is fresh.  Disk errors cause a return
with an error code, not a longjmp. [?]

void
dirdirty(dir)
DIR *dir;

Mark dir->dir_bcb as dirty and (maybe) flush it to disk.  It is not clear
when the flush should really happen; maybe not until the GEMDOS call is over.
Maybe not.

int
match(patfcb,filfcb)
FCB *patfcb, *filfcb;

Returns 1 if the two fcb's match.  A match is letter-for-letter matching of
names, plus attribute match as fn2dir: FA_LABEL in filfcb inhibits match. 
This is used internally (by fn2dir) only. Use wmatch for wildcard matching.

int
wmatch(patfcb,filfcb)
FCB *patfcb, *filfcb;

Returns 1 if the two fcb's match, including wildcards and attribute match
TBD.

long
name2fcb(name,end,fcb)
char *name, *end;
FCB *fcb;

Creates an FCB from the name. If 'end' is null, the name is
null-terminated. If 'end' is non-null, it's the first char which is NOT
part of the name. Name may be '.' (in which case the FCB is for '.'), or
'..' (ditto) or an 8.3 filename, with or without wildcards. For the moment,
I guess ".abc" should be a legal filename, expanding to "xxxxxxxabc" (where
x is space).

*/

/* isend means "is the end of a component" -- either end of string or SLASH */
#define isend(s) (!*(s) || *(s) == SLASH)

/* isdots means "this component is either dot or dot-dot followed by isend" */
#define isdots(s) (*(s) == '.' && \
			(isend((s)+1) || ((*((s)+1) == '.') && isend((s)+2))))

/*
 * The types of searches are:
 *
 *	early return: scan for everything leading up to the last component.
 *
 *	directory: if you stop at the root, return EROOT.
 *
 * 	normal: scan for the file
 *
 * In each case, return with a fresh dir and *pname pointing to the
 * beginning of the last component if you return E_OK or EFILNF (in which
 * case the fresh dir describes the dir where the file would be if it
 * existed).  Return EPTHNF if something in the middle isn't a directory,
 * or isn't found.
 *
 * Stop looking if you encounter multiple slashes (empty components), but:
 * in normal, hit the disk anyway, and in directory, if the result is the
 * root, return EROOT.
 */

long
fn2dir(pname, dir, scan_type)
char **pname;
DIR *dir;
int scan_type;
{
    char *name = *pname, *oname, *end;
    DMD *dmd;
    uint dev;
    uint cl;
    char c;
    int haswild = 0;
    uint attr;
    long err;
    FCB fcb, *pfcb;
    int earlyflag, trailok;

    DBCMD(0x20,"print fn2dir -s (lpeek (lpeek (`a6 + 8))) "
		"flags -x (wpeek (`a6 + 10)) dir: -x (lpeek (`a6 + c));_c");

    trailok = (scan_type == SCAN_DIR);
    earlyflag = (scan_type == SCAN_EARLY);

    if (!*name) return EBADRQ;
    if (*(name+1) == COLON) {
	dev = (uc(*name) - 'A');
	name += 2;
	if (!*name) return EBADRQ;
    }
    else dev = run->p_curdrv;

    if (dev >= MAXDEVS) return EDRIVE;
    if (ckdrv(dev)) return EPTHNF;
    dmd = &drvtbl[dev];

    /* got d: out of the way */

    if (*name == SLASH) {
	cl = 0;
	++name;
    }
    else cl = run->p_curdir[dev];

    do {
    	dir->dir_dev = dev;
    	dir->dir_clust = cl;

	/*
	 * Find the end of name (SLASH or null byte) and scan the directory
	 * dev/cl for that name. While you're at it, flag wildcards. We
	 * don't actually bail out here because it might be the last
	 * component and earlyflag might be set.
	 */
	for (end = name; !isend(end); ++end) {
	    if (*end == '?' || *end == '*')
		haswild = 1;
	}

	/*
	 * Empty component?  Return file not found (!) for compatibility.
	 * I'd rather return EBADRQ because it will never succeed.  We have
	 * to touch the disk before returning EFILNF because old GEMDOS
	 * did, and we have to return EROOT or E_OK if this is a SCAN_DIR.
	 */

	if (end == name) {
	    if (trailok) {
		if (cl == 0) return EROOT;
		else return E_OK;
	    }
	    else {
		dirfirst(dir,dmd);
		return EFILNF;
	    }
	}

	/*
	 * if (last component && earlyflag) bail out now.
	 */

	if (!*end && earlyflag) {
	    *pname = name;
	    DBCMD(0x20,"print early return: *pname= "
			"-s (lpeek (lpeek (`a6 + 8))) "
			"dir -x (lpeek (`a6 + c)) is:;"
			"dirx (lpeek (`a6 + c));_c");
	    return E_OK;
	}

	/*
	 * If we're in the root and the name is "." or ".." then we fake a
	 * match.  dir is unchanged because it's already root. attr is set
	 * to FA_SUBDIR so we don't think we've found a file in the middle
	 * of a pathname where only directories can go.  If this is the last
	 * component then we return EROOT for SCAN_DIR, EFILNF otherwise.
	 */

	if (cl == 0 && isdots(name)) {
	    DBCMD(0x20,"print dot or dot-dot in root dir;_c");
	    if (!*end) {
		if (scan_type == SCAN_DIR) return EROOT;
		else return EFILNF;
	    }
	    attr = FA_SUBDIR;   /* fake attrib of matched "file" */
	    goto dotmatch;
	}

	/* If you get here, no wildcards are allowed */
        if (haswild) return EBADRQ;

	/* build an FCB from the name */
	if (err = name2fcb(name,end,&fcb)) return err;
	fcb.f_attrib = FA_ALL;

	/* do the scan */

	if (err = dirfirst(dir,dmd)) return err;

	DBCMD(0x20,"print scan new dir level. dir -x (lpeek (`a6 + c)) is:;"
			"dirf (lpeek (`a6 + c));_c");

	while (1) {
	    pfcb = dir->dir_fcb;
	    c = pfcb->f_name[0];
	    if (!c) goto nomatch;
	    if (match(&fcb,pfcb)) goto didmatch;
	    err = dirnext(dir,dmd);
	    if (err == EFILNF) break;
	    else if (err) return err;
	}

nomatch:
	DBCMD(0x20,"print fn2dir returns no match;_c");

	/* no match; if not last component then EPTHNF */
	if (*end) return EPTHNF;
	else {
	    /* last component not found; fill in *pname; yield EFILNF */
	    *pname = name;
	    return EFILNF;
	}

didmatch:
	/* got a match */

	/* set up cl of start of next search, down one level */
        cl = pfcb->f_clust;
        swp68(cl);
	attr = pfcb->f_attrib;

dotmatch:
	oname = name;
	name = end;

	if (*name == SLASH) {
	    /* fail if found a file but not at end of path */
	    if (!(attr & FA_SUBDIR)) return EPTHNF;
	    ++name;
	    /* fail if the slash was the end of the string and not a DIR scan */
	    if (!trailok && !*name) return EFILNF;
        }
    } while (*name);

    DBCMD(0x20,"print fn2dir returns, dir:;dirf (lpeek (`a6 + c));_c");
    *pname = oname;
    return E_OK;
}

long
dir2dir(dir)
DIR *dir;
{
    char *fcb;
    DMD *dmd = &drvtbl[dir->dir_dev];

    fcb = getrec(dir->dir_recno,dmd,0,&dir->dir_bcb);
    dir->dir_fcb = (FCB *)(fcb + dir->dir_recoffs);

    DBCMD(0x20,"print dir2dir returns, dir -x (lpeek (`a6 + 8)) is:;"
		"dirf (lpeek (`a6 + 8));_c");

    return E_OK;
}

/*
 * dirfirst: given just dev and cl, initialize the rest of the dir
 * structure and freshen it so it refers to the first slot of the dir.
 *
 * This is a macro, as follows:
 * #define dirfirst(dir,dmd) \
 *     ((dir->dir_curcl = dir->dir_clust), \
 *      (dir->dir_recno = realcl2rec(dir->dir_clust,dmd), \
 *      (dir->dir_recoffs = 0), \
 *      dir2dir(dir))
 */

/*
 * dirnext: advance dir to point to the next slot.  This will advance to
 * the end of the last record of the last cluster in the dir, and won't
 * stop at null-byte entries.  Returns E_OK and fresh dir on success,
 * EFILNF on failure (in which case dir_curcl is the last cluster), and
 * other errors. In any error case, dir isn't fresh any more.
 *
 * This is partly a macro: the fcb and recoffs fields are bumped to the
 * next FCB in the record, and if that's still in the current record then
 * that's it.  Otherwise a procedure call is made to _dirnext.
 *
 * The macro part looks like this:
 * 
 * #define dirnext(dir,dm) \
 *     ((dir->dir_fcb++), \
 *      (dir->dir_recoffs += sizeof(FCB)), \
 *      ((dir->dir_recoffs < dm->m_recsiz) ? E_OK : _dirnext(dir,dm)))
 *
 * "Bump the fcb & recoffs; call dirnext if you fell off the end."
 * 
 */

long
_dirnext(dir,dmd)
DIR *dir;
DMD *dmd;
{
    uint xcl, curcl;

    /* you only call this if you fell off the end of this record */

    DBCMD(0x20,
	"print _dirnext, dir: -x lpeek(a6 + 8) dmd: -x lpeek(a6 + c);"
	"print -n (DIR) ; dirx lpeek(a6 + 8);"
	"print -n (DMD) ; dmd lpeek(a6 + c);_c");

    curcl = dir->dir_curcl;

    /* bump recno/recoffs to the top of the next record */

    dir->dir_recoffs = 0;
    dir->dir_recno += 1;

    /* did you fall off this cluster? (RD is one big cluster) */

    if (!dir->dir_clust) {
	/* root dir; fallen off the end yet? */
	if (dir->dir_recno >= dmd->m_recdata) return EFILNF;
    }
    else {
	/*
	 * Not root dir; fallen off this cluster yet?
	 *
	 * We subtract off recdata from recno because the AND with clrm
	 * is only valid for sector numbers which are zero-based w.r.t
	 * the start of the data part of the disk.
	 */

	if (((dir->dir_recno - dmd->m_recdata) & dmd->m_clrm) == 0) {
	    /* fell off the end of this cluster: update curcl, recno */
	    xcl = getcl(dir->dir_curcl,dmd);
	    if (xcl == 0xffff) return EFILNF;
	    if (!xcl || ((xcl & 0xfff0) == 0xfff0)) {
		/* FAT error */
		return ERROR;
	    }
	    dir->dir_curcl = xcl;
	    dir->dir_recno = realcl2rec(dir->dir_curcl,dmd);
	}
	/* (else recno is fine; it's the next rec of this clust) */
    }

    /* we've updated recno (and curcl if necessary) */
    dir->dir_fcb = getrec(dir->dir_recno,dmd,0,&(dir->dir_bcb));

    DBCMD(0x20,"print _dirnext returns. dir -t -x lpeek(a6+8) :;"
	       "dirf (lpeek (`a6 + 8));_c");

    return E_OK;
}

long
dirslot(dir)
DIR *dir;
{
    FCB *fcb;
    BCB *bcb;
    long err;
    DMD *dmd = &drvtbl[dir->dir_dev];
    uint cl, rec;
    int i;

    if (err = dirfirst(dir,dmd)) return err;

    DBCMD(0x20,"print dirslot: dir after dirfirst:;dirf (lpeek (`a6 + 8));_c");

    while (1) {
	fcb = dir->dir_fcb;
	if (fcb->f_name[0] == 0 || fcb->f_name[0] == ERASED) return E_OK;
	if (err = dirnext(dir,dmd)) {
	    if (err == EFILNF) break;
	    else return err;
	}
    }

    /* end of all clusters */
    DBCMD(0x20,"print dirslot fell off dir:;dirx (lpeek (`a6 + 8));_c");

    /* total error if RD because you can't extend it */
    if (dir->dir_clust == 0) return ERROR;

    /* Have to extend the directory. Allocate a new cluster. */
    /* Return ERROR on disk full. */
    if (!(cl = nextcl(dir->dir_curcl,dmd,TRUE))) {
	DBCMD(0x20,"print dirslot can not extend dir;_c");
	return ERROR;
    }

    rec = realcl2rec(cl,dmd);

    /* zero out that cluster */

    for (i=dmd->m_clsiz; --i >= 0; ) {
	/* on getrec error, should probably clfix(cl,0) */
	/* and clfix(dir->dir_curcl,-1), but we don't. */
	fcb = getrec(rec+i,dmd,2,&bcb);	    /* special flag */
	clear(fcb,((char *)fcb)+dmd->m_recsiz);
    }

    /* the last record we zeroed was the first record of the cluster */
    /* and that's the record, bcb, and fcb we return. */

    dir->dir_clust = dir->dir_curcl = cl;
    dir->dir_recoffs = 0;
    dir->dir_recno = rec;
    dir->dir_fcb = fcb;
    dir->dir_bcb = bcb;
    return 0;
}

/*
 * match: given two FCB's, see if their names & attrs match.
 *
 * FCB *pat is the pattern, FCB *fcb is the potential match.
 *
 * Attribute matching: since this is only called for non-wildcard matches,
 * the pattern attribute doesn't matter.  fcb's attribute is used only to
 * inhibit matching of FA_LABEL.
 *
 * There's a trick here: we assume the names are on word boundaries and
 * compare 5 int's and a byte.  (GCC actually uses "cmpm.l (a2)+,(a3)+"!)
 */

int
match(pat,fcb)
FCB *pat;
FCB *fcb;
{
    int *p, *f;

    /* no matches on erased files or labels */
    if (fcb->f_name[0] == ERASED ||
	(fcb->f_attrib & FA_LABEL)) return 0;

    p = (int *)(pat->f_name);
    f = (int *)(fcb->f_name);
    if (*p++ == *f++ &&
	*p++ == *f++ &&
	*p++ == *f++ &&
	*p++ == *f++ &&
	*p++ == *f++ &&
	*(char *)p == *(char *)f) return 1;
    return 0;
}

int
wmatch(pat,fcb)
FCB *pat;
FCB *fcb;
{
    char *p = pat->f_name;
    char *f = fcb->f_name;
    int i;

    /* no match on erased files */
    if (*f == ERASED) return 0;

    /*
     * Old attr matching logic: "match if file att is 0 and input not 8, or
     * there is at least a one-bit match."
     *
     * The caller is assumed to have ORed in FA_ARCHIVE and FA_RO. This
     * results in archive and r/o files being unhideable.
     *
     * A saner approach is to use the SUBDIR, HIDDEN, and SYSTEM bits only
     * in the zero-or-any-bit-match test, but this might just be too much
     * incompatibility.
     */

    if (!(((fcb->f_attrib == 0) && (pat->f_attrib != FA_LABEL)) ||
	(fcb->f_attrib & pat->f_attrib))) return 0;

    for (i=11; i; i--, p++, f++) {
	if (!(*p == '?' || *p == *f)) return 0;
    }

    return 1;
}

/*
 * name2fcb: see above.
 *
 * This returns EBADRQ on some illegal file names, not all. The only kind
 * it catches now is "..abc" but it would be nice to catch names with
 * spaces, too.  But it is imperative that the FCB not be changed if the
 * file name is illegal: that way there is less to undo.  (Sometimes this
 * is called to stuff a name directly in a disk buffer.  To lift the
 * restriction on errors, change those calls.)
 */

long
name2fcb(name,end,fcb)
char *name;
char *end;
FCB *fcb;
{
	int count = 8;
	char *f = &fcb->f_name[0];
	char fill = ' ';

	/* if end is NULL, set it to the null at the end */
	if (end == NULL) {
		for (end = name; *end; end++) /* empty */ ;
	}

	/* Check for special cases */
	if (*name == '.') {
		if (++name == end) {
			/* it's dot */
			*f++ = '.';
			count--;
			goto gotdot;
		}
		else if (*name == '.') {
			if (++name == end) {
				/* it's dot-dot */
				*f++ = '.';
				*f++ = '.';
				count -= 2;
				goto gotdot;
			}
			/* else it's ..abc which is illegal */
			else return EBADRQ;
		}
		else {
			/* it's .abc */
			goto gotdot;
		}
	}

	/* another special case: look out for an empty name, or
	 * a drive letter+':' combination (somewhere in the depths
	 * of the code for rename such monstrosities can be
	 * generated -- ERS
	 */
	if (!*name) return EBADRQ;
	if (name[1] == ':' && (name[2] == '\\' || !name[2]))
		return EBADRQ;

	/* fill *f with at most 8 chars, but stop at end or dot */
	while (name < end && *name != '.') {
		if (*name == '*') {
			fill = '?';
			goto skip;
		}
		*f++ = uc(*name++);
		if (!(--count)) {
skip:
			/* skip to end or dot, then goto gotdot */
			while (name < end && *name++ != '.') /* empty */ ;
			break;
		}
	}

gotdot:
	/* Either name == end or *name is dot or char after dot. */
	/* Fill out FCB to 8 spaces */
	while (count) *f++ = fill, --count;

	/* note: if (*name == '.') then we assume (name < end) */

	if (*name == '.') name++;
	count = 3;
	fill = ' ';
	while (name < end && count) {
		if (*name == '*') {
			fill = '?';
			break;
		}
		/* break on encountering a second dot */
		else if (*name == '.') break;
		*f++ = uc(*name++);
		--count;
	}
	while (count) *f++ = fill, --count;
	return 0;
}
