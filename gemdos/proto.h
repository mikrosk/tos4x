/* con.c */
long constat _P(( int h ));
long xconstat _P(( void ));
long xconostat _P(( void ));
long xprtostat _P(( void ));
long xauxistat _P(( void ));
long xauxostat _P(( void ));
void conbrk _P(( int x_h , int x_block ));
void buflush _P(( int h ));
void qins _P(( REG int x_h , long ch ));
long conout _P(( int x_h , int x_ch ));
long xtabout _P(( int ch ));
long tabout _P(( int x_h , int x_ch ));
long cookdout _P(( int x_h , int x_ch ));
long xauxout _P(( int ch ));
long xprtout _P(( int ch ));
long getch _P(( int x_h ));
long x7in _P(( void ));
long conin _P(( int x_h ));
long xconin _P(( void ));
long x8in _P(( void ));
long xauxin _P(( void ));
long rawconio _P(( int parm ));
long xprt_line _P(( char *p ));
long prt_line _P(( int x_h , char *x_p ));
void newline _P(( REG int h , REG int startcol ));
int backsp _P(( int h , char *cbuf , int retlen , int col ));
long readline _P(( char *x_p ));
long cgets _P(( int x_h , int maxlen , char *buf ));

/* freednd.c */
DND *freleaf _P(( void ));

/* fscl.c */
DMD *getdmd _P(( int drv ));
long log _P(( BPB *b , int drv ));
void flush _P(( BCB *x_b ));
void flushall _P(( void ));
void usrio _P(( int rwflg , int num , int x_strt , char *ubuf , DMD *dm ));
char *getrec _P(( int x_recn , DMD *x_dm , int wrtflg ));
char *getfat _P(( unsigned int s , DMD *dm , int wflag ));
void clfix _P(( int x_cl , int link , DMD *x_dm ));
int getcl _P(( int x_cl , DMD *x_dm ));
int nextcl _P(( OFD *x_p , int wrtflg ));
int fastcl _P(( DMD *dm , int x_lastcl , int freeflag ));
void addit _P(( OFD *x_p , long siz , int flg ));
long xrw _P(( int wrtflg , OFD *x_p , long len , void *ubufr , void (*bufxfr )()));
long ckdrv _P(( int x_d ));
long xgetfree _P(( long *p_buf , int p_drv ));

/* fscomm.c */

/* fsdir.c */
void ixdirdup _P(( int h , int dn , PD *p ));
DND *makdnd _P(( DND *x_p , FCB *x_b ));
FCB *scan _P(( DND *x_p , char *n , int att , long *posp ));
DND *dcrack _P(( char **np ));
DND *findit _P(( char *name , char **sp , int dflag ));
long xchdir _P(( char *p ));
long xgetdir _P(( char *buf , int drv ));
void makbuf _P(( FCB *x_f , DTA *x_ubufr ));
FCB *dirinit _P(( DND *x_dn ));
long xmkdir _P(( char *s ));
long xrmdir _P(( char *p ));
long ixsfirst _P(( char *name , int att , DTA *addr ));
long xsnext _P(( void ));

/* fsfs.c */
long ixclose _P(( OFD *x_fd , int part ));
OFD *makofd _P(( DND *x_p ));
long ixread _P(( OFD *x_p , long x_len , void *ubufr ));
long ixwrite _P(( OFD *p , long len , void *ubufr ));
long makopn _P(( FCB *x_f , DND *dn , int h , int mod ));
long ixcreat _P(( char *name , int attr ));
long ixopen _P(( char *name , int mod ));
long xchmod _P(( char *p , int wrt , int attr ));
long xdatime _P(( int *buf , int h , int wrt ));
long xunlink _P(( char *name ));
long ixdel _P(( DND *dn , FCB *f , long pos ));
long xrename _P(( int n , char *p1 , char *p2 ));
long drename _P(( DND *dp , char *p1 , char *s2 ));
long xlseek _P(( long n , int h , int flg ));
long ixlseek _P(( OFD *x_p , long x_n ));

/* fshand.c */
int syshnd _P(( int x_h ));
OFD *getofd _P(( int h ));
long dup _P(( int h ));
long xforce _P(( int std , int h ));
long ixforce _P(( int x_std , int x_h , PD *x_p ));
long xclose _P(( int h ));
long xread _P(( int h , long len , void *ubufr ));
long xwrite _P(( int h , long len , void *ubufr ));
long opnfil _P(( FCB *f , DND *dn , int mod ));
int sftprobe _P(( void ));

/* fsinter.c */
long xgetdta _P(( void ));
long xsetdta _P(( DTA *addr ));
long xsetdrv _P(( int drv ));
long xgetdrv _P(( void ));
long xsfirst _P(( char *name , int att ));
long xcreat _P(( char *name , int attr ));
long xopen _P(( char *name , int mod ));

/* fsmisc.c */
char uc _P(( int x_c ));
int log2 _P(( int n ));
void xmovs _P(( int x_n , void *x_s , void *x_d ));
int xcmps _P(( char *x_s , char *x_d ));

/* fsnam.c */
int match _P(( char *x_s1 , char *x_s2 ));
void builds _P(( char *x_s1 , char *x_s2 ));
int getpath _P(( char *x_p , char *d , int flg ));
char *packit _P(( char *s , char *d ));
char *dopath _P(( DND *p , char *buf ));
int eordot _P(( char *x_s , int termch ));

/* fsproc.c */
int ncmps _P(( int x_n , char *x_s , char *x_d ));
volatile void xtermres _P(( long blkln , int rc ));
volatile void xterm _P(( unsigned int rc ));
volatile void x0term _P(( void ));
void ixterm _P(( PD *r ));
long xexec _P(( int flg , char *s , char *t , char *v ));
long xpgmld _P(( PRG *prg , int h , PD *x_lp ));

/* mem.c */
void xminit _P(( void ));
long mbiggest _P(( MPB *mp , int type ));
MD *ffit _P(( long amount , MPB *mp , int type ));
long xsetblk _P(( int n , void *blk , long x_len ));
void freeit _P(( MD *x_m , MPB *mp ));
long xfmalloc _P(( long amount , int mode ));
long xmalloc _P(( long amount ));
long xmfree _P(( void *addr ));
void xmunhook _P(( PD *pid ));
void xmfreeall _P(( PD *pid ));
void xmchown _P(( void *x_blk , PD *pid ));
long xaddalt _P(( void *blk , long siz ));

/* panic.c */
volatile void panic _P(( void ));
void panic1 _P(( char *s ));

/* pool.c */
void poolinit _P(( void ));
void addheap _P(( void *x_ptr , long x_size ));
DND *getbig _P(( void ));
struct block *newpool _P(( void ));
MD *getsmall _P(( void ));
struct block *compact _P(( void ));
void mdmove _P(( MD *x_target , MD *x_dest ));
MD *advance _P(( struct block **pdptr , int *pdindex , struct block *sptr ));
long freebig _P(( void *ptmp ));
void freesmall _P(( MD *x_ptr ));

/* setup.c */
void osi _P(( void ));

/* sup.c */
long ni _P(( void ));
long xgetver _P(( void ));
void cinit _P(( void ));
void freetree _P(( DND *d ));
void offree _P(( DMD *d ));
long osif _P(( int *pw ));
void tikfrk _P(( int n ));
long xmediach _P(( int drv ));

/* time.c */
long xgetdate _P(( void ));
long xsetdate _P(( int d ));
long xgettime _P(( void ));
long xsettime _P(( int t ));
