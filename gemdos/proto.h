
/* con.c */
long constat _P((int h));
long xconstat _P((void));
long xconostat _P((void));
long xprtostat _P((void));
long xauxistat _P((void));
long xauxostat _P((void));
void conbrk _P((int h, int block));
void buflush _P((int h));
void qins _P((int h, long ch));
long conout _P((int h, int ch));
long xtabout _P((int ch));
long tabout _P((int h, int ch));
long cookdout _P((int h, int ch));
long xauxout _P((int ch));
long xprtout _P((int ch));
long getch _P((int h));
long x7in _P((void));
long conin _P((int h));
long xconin _P((void));
long x8in _P((void));
long xauxin _P((void));
long rawconio _P((int parm));
long xprt_line _P((char *p));
long prt_line _P((int h, char *p));
void newline _P((REG int h, REG int startcol));
int backsp _P((int h, char *cbuf, int retlen, int col));
long readline _P((char *p));
long cgets _P((int h, int maxlen, char *buf));

/* fscl.c */
int log2 _P((uint n));
voidfn log _P((BPB *b, int drv));
void flush _P((BCB *b));
void flushall _P((void));
voidfn usrio _P((uint rwflg, uint num, uint strt, void *ubuf, DMD *dm));
char *getrec _P((uint recn, DMD *dmd, int wrtflg));
char *getfat _P((unsigned int s, DMD *dmd, int wflag));
void clfix _P((uint cl, uint link, DMD *dmd));
int getcl _P((uint cl, DMD *dmd));
int nextcl _P((uint cl, DMD *dmd, int extflag, int *extended));
int fastcl _P((DMD *dmd, int lastcl, int freeflag));
long xrw _P((int wrtflg, OFD *p, long len, void *ubufr, void (*bufxfr )()));
long ckdrv _P((uint d));
long xgetfree _P((long *buf, uint drv));

/* fscomm.c */

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

/* fsfs.c */
DFD *getdfd _P((DIR *dir));
long ixcreat _P((char *name, int attr, DIR *dir));
long xopen _P((char *name, int mod));
long ixopen _P((DIR *dir, int mod));
long xchmod _P((char *p, int wrt, int attr));
long xdatime _P((int *buf, int h, int wrt));
long xdelete _P((char *name));
long ixdel _P((DIR *dir));
long xrename _P((int n, char *p1, char *p2));
long xlseek _P((long n, int h, int flg));

/* fshand.c */
voidfn hand_init _P((void));
int sftprobe _P((void));
int syshnd _P((int h));
long xdup _P((int h));
long xforce _P((int std, int h));
long ixforce _P((int std, int h, PD *p));
long xclose _P((int h));
long dfd_close _P((DFD *dfd));
long ofd_close _P((OFD *ofd));
long xread _P((int h, long len, void *ubufr));
long xwrite _P((int h, long len, void *ubufr));
long xcreat _P((char *name, int attr));
long xgetdta _P((void));
long xsetdta _P((DTA *addr));
long xsetdrv _P((int drv));
long xgetdrv _P((void));
voidfn xmovs _P((int n, void *s, void *d));

/* fsproc.c */
int ncmps _P((int n, char *s, char *d));
volatile void xtermres _P((long blkln, int rc));
volatile void xterm _P((unsigned int rc));
volatile void x0term _P((void));
void ixterm _P((PD *r));
long xexec _P((int mode, char *s, char *t, char *v));
long xpgmld _P((PRG *prg, int h, PD *lp));

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

/* panic.c */
volatile void panic _P((void));

/* pool.c */
void poolinit _P((void));
void addheap _P((void *ptr, long size));
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

/* setup.c */
void osi _P((void));

/* sup.c */
long ni _P((void));
long xgetver _P((void));
void cinit _P((void));
void freetree _P((char *d));
void offree _P((DMD *d));
long osif _P((int *pw));
void tikfrk _P((int n));
long xmediach _P((int drv));

/* time.c */
long xgetdate _P((void));
long xsetdate _P((int d));
long xgettime _P((void));
long xsettime _P((int t));
