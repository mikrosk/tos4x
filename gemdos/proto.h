
/* fscl.c */
uint log2 _P((uint n));
voidfn dirdirty _P((DIR *dir));
voidfn fatdirty _P((uint dev));
voidfn invclean _P((int xdev));
voidfn flush _P((BCB *b));
voidfn flushall _P((void));
voidfn usrio _P((uint rwflg, uint num, uint strt, void *ubuf, DMD *dmd));
void *getrec _P((uint recn, DMD *dmd, int wrtflg, BCB **pbcb));
char *getfat _P((unsigned int s, DMD *dmd, int wflag));
voidfn clfix _P((uint cl, uint link, DMD *dmd));
uint getcl _P((uint cl, DMD *dmd));
uint nextcl _P((uint cl, DMD *dmd, int extflag));
uint fastcl _P((DMD *dmd, int freeflag));
long xrw _P((int wrtflg, OFD *ofd, ulong len, void *ubufr, void (*bufxfr )_P ((uint, void *, void *))));
long ckdrv _P((uint d));
voidfn log _P((BPB *b, int drv));
long xgetfree _P((long *buf, uint drv));

/* fscomm.c */

/* fsdir.c */
long xchdir _P((char *p));
long xgetdir _P((char *buf, int drv));
long xgetndir _P((char *buf, uint drv, ulong len));
long _getndir _P((char **pbuf, ulong len, DIR *dir, DMD *dmd));
long xmkdir _P((char *s));
long xrmdir _P((char *p));
long xsfirst _P((char *name, int att));
long ixsfirst _P((char *name, int att, DTA *dta));
long xsnext _P((void));
voidfn filldta _P((DTA *dta, DIR *dir));

/* fsfs.c */
DFD *getdfd _P((DIR *dir));
long ixcreat _P((char *name, int attr, DIR *dir));
long xchmod _P((char *p, int wrt, int attr));
long xunlink _P((char *name));
long ixdel _P((DIR *dir));
long xrename _P((int n, char *p1, char *p2));

/* fshand.c */
int uftprobe _P((void));
OFD *syshnd _P((int h));
long xdup _P((int h));
long xforce _P((int std, int h));
long ixforce _P((int dest, int src, PD *pd));
long xclose _P((int h));
long ixclose _P((int h, PD *pd));
void offree _P((uint dev));
long xsync _P((void));
long xread _P((int h, ulong len, void *ubufr));
long ixread _P((OFD *ofd, ulong len, void *ubufr));
long xwrite _P((int h, long len, void *ubufr));
long ixwrite _P((OFD *ofd, long len, void *ubufr));
long xcreat _P((char *name, int attr));
long xopen _P((char *name, int mod));
long ttyopen _P((char *name));
long ixopen _P((DIR *dir, uint mod));
long xlseek _P((long n, int h, int flg));
long ixlseek _P((long n, OFD *ofd, int flg));
long xdatime _P((int *buf, int h, int wrt));
long xgetdta _P((void));
long xsetdta _P((DTA *addr));
long xsetdrv _P((uint drv));
long xgetdrv _P((void));
long xgetver _P((void));
long ni _P((void));

/* scan.c */
long fn2dir _P((char **pname, DIR *dir, int flags));
long dir2dir _P((DIR *dir));
long _dirnext _P((DIR *dir, DMD *dmd));
long dirslot _P((DIR *dir));
int match _P((FCB *pat, FCB *fcb));
int wmatch _P((FCB *pat, FCB *fcb));
long name2fcb _P((char *name, char *end, FCB *fcb));

/* setup.c */
voidfn osi _P((void));

/* time.c */
void tikfrk _P((int n));
long xgetdate _P((void));
long xsetdate _P((int d));
long xgettime _P((void));
long xsettime _P((uint t));

/* panic.c */
volatile void panic _P((void));
volatile void panic1 _P((char *s));

/* mem.c */
void xminit _P((void));
unsigned long mbiggest _P((MPB *mp, int type));
MD *ffit _P((unsigned long amount, MPB *mp, int type));
long xmshrink _P((int n, void *blk, unsigned long len));
void freeit _P((MD *m, MPB *mp));
unsigned long xfmalloc _P((unsigned long amount, int mode));
unsigned long xmalloc _P((unsigned long amount));
long xmfree _P((void *addr));
void xmunhook _P((PD *pid));
void xmfreeall _P((PD *pid));
void xmchown _P((void *blk, PD *pid));
long xaddalt _P((void *blk, unsigned long siz));
void *xsrealloc _P((signed long ss));

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

/* sup.c */
long xmediach _P((int drv));
long osif _P((volatile int *pw));

/* con.c */
void coninit _P((void));
long xconout _P((int ch));
long xauxout _P((int ch));
long xprtout _P((int ch));
long xconws _P((char *p));
long _conout _P((int h, int ch, int flags));
long char_write _P((int tty, long len, char *buf));
long conout _P((int dev, int ch, int mode));
long xconin _P((void));
long xnecin _P((void));
long xauxin _P((void));
long xrawcin _P((void));
long xrawio _P((int ch));
long _conin _P((int h, int mode));
long conin _P((int dev, int mode));
long xconstat _P((void));
long xauxis _P((void));
long _istat _P((int h));
long constat _P((int dev));
long xconos _P((void));
long xauxos _P((void));
long xprnos _P((void));
long _ostat _P((int h));
void conbrk _P((int dev, int block, int mode));
void buflush _P((int dev));
void qins _P((int dev, long ch));
long qrem _P((int dev));
long cookdout _P((int dev, int ch));
long xconrs _P((unsigned char *p));
long cgets _P((int dev, long maxlen, char *buf));

/* fsproc.c */
void xtermres _P((long blkln, int rc));
void xterm _P((unsigned int rc));
void x0term _P((void));
void ixterm _P((PD *r));
long xexec _P((int mode, char *s, char *t, char *v));
long xpgmld _P((PRG *prg, int h, PD *lp));
