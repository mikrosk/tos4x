
/* panic.c */
volatile void panic _P((void));

/* mem.c */
void xminit _P((void));
long mbiggest _P((MPB *mp, int type));
MD *ffit _P((long amount, MPB *mp, int type));
long xsetblk _P((int n, void *blk, long len));
void freeit _P((MD *m, MPB *mp));
long xfmalloc _P((long amount, int mode));
long xmalloc _P((long amount));
long xmfree _P((void *addr));
void xmunhook _P((PD *pid));
void xmfreeall _P((PD *pid));
void xmchown _P((void *blk, PD *pid));
long xaddalt _P((void *blk, long siz));

/* fscl.c */
uint log2 _P((uint n));
voidfn dirdirty _P((DIR *dir));
voidfn fatdirty _P((uint dev));
voidfn flush _P((BCB *b));
voidfn flushall _P((void));
voidfn usrio _P((uint rwflg, uint num, uint strt, void *ubuf, DMD *dmd));
void *getrec _P((uint recn, DMD *dmd, int wrtflg, BCB **pbcb));
char *getfat _P((unsigned int s, DMD *dmd, int wflag));
voidfn clfix _P((uint cl, uint link, DMD *dmd));
uint getcl _P((uint cl, DMD *dmd));
uint nextcl _P((uint cl, DMD *dmd, int extflag, int *extended));
uint fastcl _P((DMD *dmd, int freeflag));
long xrw _P((int wrtflg, OFD *ofd, long len, void *ubufr, void (*bufxfr )_P ((uint, void *, void *))));
long ckdrv _P((uint d));
voidfn log _P((BPB *b, int drv));
long xgetfree _P((long *buf, uint drv));

/* pool.c */
voidfn poolinit _P((void));
int addheap _P((void *ptr, long size));
void *getbig _P((void));
struct block *newpool _P((void));
MD *getsmall _P((void));
struct block *compact _P((void));
void mdmove _P((MD *target, MD *dest));
MD *advance _P((struct block **pdptr, int *pdindex, struct block *sptr));
long freebig _P((void *ptmp));
void freesmall _P((MD *ptr));

/* scan.c */
long fn2dir _P((char **pname, DIR *dir, int flags));
long dir2dir _P((DIR *dir));
long _dirnext _P((DIR *dir, DMD *dmd));
long dirslot _P((DIR *dir));
int match _P((FCB *pat, FCB *fcb));
int wmatch _P((FCB *pat, FCB *fcb));
long name2fcb _P((char *name, char *end, FCB *fcb));

/* fsdir.c */
long xchdir _P((char *p));
long xgetdir _P((char *buf, int drv));
long xgetndir _P((char *buf, ulong len, uint drv));
long _getndir _P((char **pbuf, ulong len, DIR *dir, DMD *dmd));
long xmkdir _P((char *s));
long xrmdir _P((char *p));
long xsfirst _P((char *name, int att));
long ixsfirst _P((char *name, int att, DTA *dta));
long xsnext _P((void));
voidfn filldta _P((DTA *dta, DIR *dir));

/* testbed.c */
voidfn main _P((int argc, char *argv[]));
int uc _P((int c));
voidfn s68 _P((void *w));
voidfn s68l _P((void *w));
long xterm _P((int code));
voidfn clear _P((void *start, void *end));
void xfr2usr _P((uint n, void *s, void *d));
void usr2xfr _P((uint n, void *d, void *s));
voidfn upd_tod _P((void));
long cgets _P((int h, long len, char *buf));
long char_write _P((int h, long len, char *buf));
void coninit _P((void));

/* fscomm.c */

/* fsfs.c */
DFD *getdfd _P((DIR *dir));
long ixcreat _P((char *name, int attr, DIR *dir));
long xchmod _P((char *p, int wrt, int attr));
long xdelete _P((char *name));
long ixdel _P((DIR *dir));
long xrename _P((int n, char *p1, char *p2));

/* time.c */
long xgetdate _P((void));
long xsetdate _P((int d));
long xgettime _P((void));
long xsettime _P((uint t));

/* setup.c */
voidfn osi _P((void));

/* fshand.c */
int uftprobe _P((void));
OFD *syshnd _P((int h));
long xdup _P((int h));
long xforce _P((int std, int h));
long ixforce _P((int dest, int src, PD *pd));
long xclose _P((int h));
long xsync _P((void));
long xread _P((int h, long len, void *ubufr));
long xwrite _P((int h, long len, void *ubufr));
long xcreat _P((char *name, int attr));
long xopen _P((char *name, int mod));
long ixopen _P((DIR *dir, uint mod));
long xlseek _P((long n, int h, int flg));
long xdatime _P((int *buf, int h, int wrt));
long xgetdta _P((void));
long xsetdta _P((DTA *addr));
long xsetdrv _P((uint drv));
long xgetdrv _P((void));
