/*
 * osbind.h - interface to TOS for Lattice C 5
 *
 * This file contains the general interface to C5 via #pragmas
 *
 * Started 10/1/90 Alex G. Kiernan
 *
 * Copyright (c) 1990 HiSoft
 */

#ifndef _OSBIND_H
#define _OSBIND_H

long int gemdos(int, ...);
long int bios(int, ...);
long int xbios(int, ...);

/* GEMDOS bindings */

long *__ngv(int);
long __lgc(int,const char *);
long __lgcc(int,const char *,const char *);
long __lgcs(int,const char *,int);
long __lgcss(int,const char *,int,int);
long __lgds(int,char *,int);
long __lgl(int,long);
long __lglss(int,long,int,int);
long __lgns(int,long *,int);
long __lgp(int,void *);
long __lgpl(int,void *,long);
long __lgrss(int,short *,int,int);
long __lgs(int,int);
long __lgscc(int,int,const char *,const char *);
long __lgsccc(int,int,const char *,const char *,const char *);
long __lgscp(int,int,const char *,void *);
long __lgsqp(int,int,const void *,void *);
long __lgsdc(int,int,char *,const char *);
long __lgsl(int,int,long);
long __lgsld(int,int,long,char *);
long __lgsll(int,int,long,long);
long __lgssll(int,int,int,long,long);
long __lgslp(int,int,long,void *);
long __lgslq(int,int,long,const void *);
long __lgsls(int,int,long,int);
long __lgsn(int,int,long *);
long __lgspl(int,int,void *,long);
long __lgss(int,int,int);
long __lgsss(int,int,int,int);
long __lgu(int,unsigned int);
long __lgv(int);
long __sgunnn(int,unsigned,long *,long *,long *);
long __vgn(int,long *);
short __sgr(int,short *);
short __sgs(int,int);
short __sgsl(int,int,long);
short __sgsls(int,int,long,int);
short __sgss(int,int,int);
short __sgv(int);
unsigned short __ugv(int);
void (*__stdargs __ggsg(int,int,void (*__stdargs)(long)))(long);
void *__pgl(int,long);
void *__pgls(int,long,int);
void *__pgp(int,void *);
void *__pgs(int,int);
void *__pgv(int);
void __vgc(int,const char *);
void __vgls(int,long,int);
void __vgp(int,void *);
void __vgs(int,int);
void __vgv(int);

#pragma inline __vgc((short),)	{register d2,a2; "4e41";}
#pragma inline __vgls((short),,(short))	{register d2,a2; "4e41";}
#pragma inline __vgn((short),)	{register d2,a2; "4e41";}
#pragma inline __vgp((short),)	{register d2,a2; "4e41";}
#pragma inline __vgs((short),(short))	{register d2,a2; "4e41";}
#pragma inline __vgv((short))	{register d2,a2; "4e41";}
#pragma inline d0=__ggsg((short),(short),)	{register d2,a2; "4e41";}
#pragma inline d0=__lgc((short),)	{register d2,a2; "4e41";}
#pragma inline d0=__lgcc((short),,)	{register d2,a2; "4e41";}
#pragma inline d0=__lgcs((short),,(short))	{register d2,a2; "4e41";}
#pragma inline d0=__lgcss((short),,(short),(short))	{register d2,a2; "4e41";}
#pragma inline d0=__lgds((short),,(short))	{register d2,a2; "4e41";}
#pragma inline d0=__lgl((short),)	{register d2,a2; "4e41";}
#pragma inline d0=__lglss((short),,(short),(short))	{register d2,a2; "4e41";}
#pragma inline d0=__lgns((short),,(short))	{register d2,a2; "4e41";}
#pragma inline d0=__lgp((short),)	{register d2,a2; "4e41";}
#pragma inline d0=__lgpl((short),,)	{register d2,a2; "4e41";}
#pragma inline d0=__lgrss((short),,(short),(short))	{register d2,a2; "4e41";}
#pragma inline d0=__lgs((short),(short))	{register d2,a2; "4e41";}
#pragma inline d0=__lgscc((short),(short),,)	{register d2,a2; "4e41";}
#pragma inline d0=__lgsccc((short),(short),,,)	{register d2,a2; "4e41";}
#pragma inline d0=__lgscp((short),(short),,)	{register d2,a2; "4e41";}
#pragma inline d0=__lgsqp((short),(short),,)	{register d2,a2; "4e41";}
#pragma inline d0=__lgsdc((short),(short),,)	{register d2,a2; "4e41";}
#pragma inline d0=__lgsl((short),(short),)	{register d2,a2; "4e41";}
#pragma inline d0=__lgsld((short),(short),,)	{register d2,a2; "4e41";}
#pragma inline d0=__lgsll((short),(short),,)	{register d2,a2; "4e41";}
#pragma inline d0=__lgssll((short),(short),(short),,)	{register d2,a2; "4e41";}
#pragma inline d0=__lgslp((short),(short),,)	{register d2,a2; "4e41";}
#pragma inline d0=__lgslq((short),(short),,)	{register d2,a2; "4e41";}
#pragma inline d0=__lgsls((short),(short),,(short))	{register d2,a2; "4e41";}
#pragma inline d0=__lgsn((short),(short),)	{register d2,a2; "4e41";}
#pragma inline d0=__lgspl((short),(short),,)	{register d2,a2; "4e41";}
#pragma inline d0=__lgss((short),(short),(short))	{register d2,a2; "4e41";}
#pragma inline d0=__lgsss((short),(short),(short),(short))	{register d2,a2; "4e41";}
#pragma inline d0=__lgu((short),(short))	{register d2,a2; "4e41";}
#pragma inline d0=__lgv((short))	{register d2,a2; "4e41";}
#pragma inline d0=__ngv((short))	{register d2,a2; "4e41";}
#pragma inline d0=__pgl((short),)	{register d2,a2; "4e41";}
#pragma inline d0=__pgls((short),,(short))	{register d2,a2; "4e41";}
#pragma inline d0=__pgp((short),)	{register d2,a2; "4e41";}
#pragma inline d0=__pgs((short),(short))	{register d2,a2; "4e41";}
#pragma inline d0=__pgv((short))	{register d2,a2; "4e41";}
#pragma inline d0=__sgr((short),)	{register d2,a2; "4e41";}
#pragma inline d0=__sgs((short),(short))	{register d2,a2; "4e41";}
#pragma inline d0=__sgsl((short),(short),)	{register d2,a2; "4e41";}
#pragma inline d0=__sgsls((short),(short),,(short))	{register d2,a2; "4e41";}
#pragma inline d0=__sgss((short),(short),(short))	{register d2,a2; "4e41";}
#pragma inline d0=__sgunnn((short),(short),,,)	{register d2,a2; "4e41";}
#pragma inline d0=__sgv((short))	{register d2,a2; "4e41";}
#pragma inline d0=__ugv((short))	{register d2,a2; "4e41";}

#define Pterm0()		__vgv(0x0)
#define Cconin()		__lgv(0x1)
#define Cconout(a)		__vgs(0x2,a)
#define Cauxin()		__sgv(0x3)
#define Cauxout(a)		__vgs(0x4,a)
#define Cprnout(a)		__lgs(0x5,a)
#define Crawio(a)		__lgs(0x6,a)
#define Crawcin()		__lgv(0x7)
#define Cnecin()		__lgv(0x8)
#define Cconws(a)		__vgc(0x9,a)
#define Cconrs(a)		__vgp(0x0a,a)
#define Cconis()		__sgv(0x0b)
#define Dsetdrv(a)		__lgs(0x0e,a)
#define Cconos()		__sgv(0x10)
#define Cprnos()		__sgv(0x11)
#define Cauxis()		__sgv(0x12)
#define Cauxos()		__sgv(0x13)
#define Maddalt(a,b)	__lgpl(0x14,a,b)
#define Dgetdrv()		__sgv(0x19)
#define Fsetdta(a)		__vgp(0x1a,a)
#define Super(a)		__pgp(0x20,a)
#define Tgetdate()		__ugv(0x2a)
#define Tsetdate(a)		__lgu(0x2b,a)
#define Tgettime()		__ugv(0x2c)
#define Tsettime(a)		__lgu(0x2d,a)
#define Fgetdta()		__pgv(0x2f)
#define Sversion()		__ugv(0x30)
#define Ptermres(a,b)	__vgls(0x31,a,b)
#define Dfree(a,b)		__lgns(0x36,a,b)
#define Dcreate(a)		__lgc(0x39,a)
#define Ddelete(a)		__lgc(0x3a,a)
#define Dsetpath(a)		__lgc(0x3b,a)
#define Fcreate(a,b)	__lgcs(0x3c,a,b)
#define Fopen(a,b)		__lgcs(0x3d,a,b)
#define Fclose(a)		__lgs(0x3e,a)
#define Fread(a,b,c)	__lgslp(0x3f,a,b,c)
#define Fwrite(a,b,c)	__lgslq(0x40,a,b,c)
#define Fdelete(a)		__lgc(0x41,a)
#define Fseek(a,b,c)	__lglss(0x42,a,b,c)
#define Fattrib(a,b,c)	__lgcss(0x43,a,b,c)
#define Mxalloc(a,b)	__pgls(0x44,a,b)
#define Fdup(a)			__lgs(0x45,a)
#define Fforce(a,b)		__lgss(0x46,a,b)
#define Dgetpath(a,b)	__lgds(0x47,a,b)
#define Malloc(a)		__pgl(0x48,a)
#define Mfree(a)		__lgp(0x49,a)
#define Mshrink(a,b)	__lgspl(0x4a,0,a,b)
#define Pexec(a,b,c,d)	__lgsccc(0x4b,a,b,c,d)
#define Pterm(a)		__vgs(0x4c,a)
#define Fsfirst(a,b)	__lgcs(0x4e,a,b)
#define Fsnext()		__lgv(0x4f)
#define Frename(a,b,c)	__lgscc(0x56,a,b,c)
#define Fdatime(a,b,c)	__lgrss(0x57,a,b,c)
#define Flock(a,b,c,d)	__lgssll(0x5c,a,b,c,d)

/* BIOS bindings */

void __vbp(int,void *);
long __lbs(int,int);
long __lbss(int,int,int);
long __lbspsss(int,int,void *,int,int,int);
long __lbspsssl(int,int,void *,int,int,int,long);
void (*__fbsf(int,int,void (*)()))();
long __lbv(int);
void *__pbs(int,int);
unsigned long __mbv(int);
long *__nbv(int);

#pragma inline d0=__nbv((short))	{register d2,a2; "4e4d";}
#pragma inline __vbp((short),)	{register d2,a2; "4e4d";}
#pragma inline d0=__lbs((short),(short))	{register d2,a2; "4e4d";}
#pragma inline d0=__lbss((short),(short),(short))	{register d2,a2; "4e4d";}
#pragma inline d0=__lbspsss((short),(short),,(short),(short),(short))	{register d2,a2; "4e4d";}
#pragma inline d0=__lbspsssl((short),(short),,(short),(short),(short),)	{register d2,a2; "4e4d";}
#pragma inline d0=__fbsf((short),(short),)	{register d2,a2; "4e4d";}
#pragma inline d0=__lbv((short))	{register d2,a2; "4e4d";}
#pragma inline d0=__pbs((short),(short))	{register d2,a2; "4e4d";}
#pragma inline d0=__mbv((short))	{register d2,a2; "4e4d";}

#define Getmpb(a)			__vbp(0,a)
#define Bconstat(a)			__lbs(1,a)
#define Bconin(a)			__lbs(2,a)
#define Bconout(a,b)		__lbss(3,a,b)
#define Rwabs(a,b,c,d,e)	__lbspsss(4,a,b,c,d,e)
#define Lrwabs(a,b,c,d,e)	__lbspsssl(4,a,b,c,-1,d,e)
#define Setexc(a,b)			__fbsf(5,a,b)
#define Tickcal()			__lbv(6)
#define Getbpb(a)			__pbs(7,a)
#define Bcostat(a)			__lbs(8,a)
#define Mediach(a)			__lbs(9,a)
#define Drvmap()			__mbv(10)
#define Kbshift(a)			__lbs(11,a)

/* XBIOS bindings */

unsigned char __dxss(int,int,int);
long __lxg(int,long (*)(void));
long __lxv(int);
unsigned long __mxssssss(int,int,int,int,int,int,int);
void *__pxs(int,int);
void *__pxv(int);
char **__rxccc(int,const char *,const char *,const char *);
void **__rxv(int);
short __sxppsssss(int,void *,void *,int,int,int,int,int);
short __sxprsssssls(int,void *,short *,int,int,int,int,int,long,int);
short __sxs(int,int);
short __sxss(int,int,int);
short __sxv(int);
void __vxc(int,const char *);
void __vxm(int,unsigned long);
unsigned long __mxv(int);
void __vxp(int,void *);
short __sxp(int,void *);
void __vxplss(int,void *,long,int,int);
void __vxpps(int,void *,void *,int);
void __vxs(int,int);
void __vxsf(int,int,void (*)(void));
void __vxsl(int,int,long);
void __vxsp(int,int,void *);
void __vxspf(int,int,void *,void (*)());
void __vxsssf(int,int,int,int,void (*)());
void __vxv(int);
long __lxlsps(int,long,int,void *,int);
short __sxsssd(int,int,int,int,char *);
long __lxs(int,int);
void __vxssr(int,int,int,short *);
long __lxsl(int,int,long);
long *__nxv(int);
short __sxsp(int,int,void *);
long __lxspls(int,int,void *,long,int);
long __lxsqls(int,int,void *,long,int);
long __lxsp(int,int,void *);
long __lxssc(int,int,int,const char *);
long __lxs(int,int);
long __lxssss(int,int,int,int,int);
long __lxssp(int,int,int,void *);

#pragma inline d0=__sxsp((short),(short),)	{register d2,a2; "4e4e";}
#pragma inline d0=__lxspls((short),(short),,,(short))	{register d2,a2; "4e4e";}
#pragma inline d0=__lxsqls((short),(short),,,(short))	{register d2,a2; "4e4e";}
#pragma inline d0=__lxsp((short),(short),)	{register d2,a2; "4e4e";}
#pragma inline d0=__lxssc((short),(short),(short),)	{register d2,a2; "4e4e";}
#pragma inline d0=__lxssss((short),(short),(short),(short),(short))	{register d2,a2; "4e4e";}
#pragma inline d0=__lxssp((short),(short),(short),)	{register d2,a2; "4e4e";}
#pragma inline d0=__lxsp((short),(short))	{register d2,a2; "4e4e";}
#pragma inline d0=__nxv((short))	{register d2,a2; "4e4e";}
#pragma inline d0=__lxsl((short),(short),)	{register d2,a2; "4e4e";}
#pragma inline __vxssr((short),(short),(short),)	{register d2,a2; "4e4e";}
#pragma inline d0=__lxs((short),(short))	{register d2,a2; "4e4e";}
#pragma inline d0=__sxsssd((short),(short),(short),(short),)	{register d2,a2; "4e4e";}
#pragma inline d0=__lxlsps((short),,(short),,(short))	{register d2,a2; "4e4e";}
#pragma inline d0=__dxss((short),(short),(short))	{register d2,a2; "4e4e";}
#pragma inline d0=__lxg((short),)	{register d2,a2; "4e4e";}
#pragma inline d0=__lxv((short))	{register d2,a2; "4e4e";}
#pragma inline d0=__mxssssss((short),(short),(short),(short),(short),(short),(short))	{register d2,a2; "4e4e";}
#pragma inline d0=__pxs((short),(short))	{register d2,a2; "4e4e";}
#pragma inline d0=__pxv((short))	{register d2,a2; "4e4e";}
#pragma inline d0=__rxccc((short),,,)	{register d2,a2; "4e4e";}
#pragma inline d0=__rxv((short))	{register d2,a2; "4e4e";}
#pragma inline d0=__sxppsssss((short),,,(short),(short),(short),(short),(short))	{register d2,a2; "4e4e";}
#pragma inline d0=__sxprsssssls((short),,,(short),(short),(short),(short),(short),,(short))	{register d2,a2; "4e4e";}
#pragma inline d0=__sxs((short),(short))	{register d2,a2; "4e4e";}
#pragma inline d0=__sxss((short),(short),(short))	{register d2,a2; "4e4e";}
#pragma inline d0=__sxv((short))	{register d2,a2; "4e4e";}
#pragma inline __vxc((short),)	{register d2,a2; "4e4e";}
#pragma inline __vxm((short),)	{register d2,a2; "4e4e";}
#pragma inline d0=__mxv((short))	{register d2,a2; "4e4e";}
#pragma inline __vxp((short),)	{register d2,a2; "4e4e";}
#pragma inline d0=__sxp((short),)	{register d2,a2; "4e4e";}
#pragma inline __vxplss((short),,,(short),(short))	{register d2,a2; "4e4e";}
#pragma inline __vxpps((short),,,(short))	{register d2,a2; "4e4e";}
#pragma inline __vxs((short),(short))	{register d2,a2; "4e4e";}
#pragma inline __vxsf((short),(short),)	{register d2,a2; "4e4e";}
#pragma inline __vxsl((short),(short),)	{register d2,a2; "4e4e";}
#pragma inline __vxsp((short),(short),)	{register d2,a2; "4e4e";}
#pragma inline __vxspf((short),(short),,)	{register d2,a2; "4e4e";}
#pragma inline __vxsssf((short),(short),(short),(short),)	{register d2,a2; "4e4e";}
#pragma inline __vxv((short))	{register d2,a2; "4e4e";}

#define Initmous(a,b,c)				__vxspf(0,a,b,c)
#define Ssbrk(a)					__lxs(1,a)
#define Physbase()					__pxv(2)
#define Logbase()					__pxv(3)
#define Getrez()					__sxv(4)
#define Setscreen(a,b,c)			__vxpps(5,a,b,c)
#define Setpallete(a)				__vxp(6,a)
#define Setpalette(a)				__vxp(6,a)
#define Setcolor(a,b)				__sxss(7,a,b)
#define Floprd(a,b,c,d,e,f,g)		__sxppsssss(8,a,b,c,d,e,f,g)
#define Flopwr(a,b,c,d,e,f,g)		__sxppsssss(9,a,b,c,d,e,f,g)
#define Flopfmt(a,b,c,d,e,f,g,h,i)	__sxprsssssls(10,a,b,c,d,e,f,g,h,i)
#define Midiws(a,b)					__vxsp(12,a,b)
#define Mfpint(a,b)					__vxsf(13,a,b)
#define Iorec(a)					__pxs(14,a)
#define Rsconf(a,b,c,d,e,f)			__mxssssss(15,a,b,c,d,e,f)
#define Keytbl(a,b,c)				__rxccc(16,a,b,c)
#define Random()					__lxv(17)
#define Protobt(a,b,c,d)			__vxplss(18,a,b,c,d)
#define Flopver(a,b,c,d,e,f,g)		__sxppsssss(19,a,b,c,d,e,f,g)
#define Scrdmp()					__vxv(20)
#define Cursconf(a,b)				__sxss(21,a,b)
#define Settime(a)					__vxm(22,a)
#define Gettime()					__mxv(23)
#define Bioskeys()					__vxv(24)
#define Ikbdws(a,b)					__vxsl(25,a,b)
#define Jdisint(a)					__vxs(26,a)
#define Jenabint(a)					__vxs(27,a)
#define Giaccess(a,b)				__dxss(28,a,b)
#define Offgibit(a)					__vxs(29,a)
#define Ongibit(a)					__vxs(30,a)
#define Xbtimer(a,b,c,d)			__vxsssf(31,a,b,c,d)
#define Dosound(a)					__vxc(32,a)
#define Setprt(a)					__sxs(33,a)
#define Kbdvbase()					__rxv(34)
#define Kbrate(a,b)					__sxss(35,a,b)
#define Prtblk(a)					__sxp(36,a)
#define Vsync()						__vxv(37)
#define Supexec(a)					__lxg(38,a)
#define Puntaes()					__vxv(39)
#define Floprate(a,b)				__sxss(41,a,b)
#define DMAread(a,b,c,d)			__lxlsps(42,a,b,c,d)
#define DMAwrite(a,b,c,d)			__lxlsps(43,a,b,c,d)
#define Bconmap(a)					__lxs(44,a)
#define NVMaccess(a,b,c,d)			__sxsssd(46,a,b,c,d)
#define Blitmode(a)					__sxs(64,a)
#define EsetShift(a)				__sxs(80,a)
#define EgetShift()					__sxv(81)
#define EsetBank(a)					__sxs(82,a)
#define EsetColor(a,b)				__sxss(83,a,b)
#define EsetPalette(a,b,c)			__vxssr(84,a,b,c)
#define EgetPalette(a,b,c)			__vxssr(85,a,b,c)
#define EsetGray(a)					__sxs(86,a)
#define EsetSmear(a)				__sxs(87,a)

int _mediach(int);		/* force GEMDOS media change */
#endif
