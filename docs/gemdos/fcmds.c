/* opcode table for ftest */

#include "ftest.h"

#define G0(r,n,f) \
	{ n,1,r,f },
#define G1(r,n,f,n1,t1) \
	{ n,1,r,f,n1,0,0,0,0,0,0,0,0,t1 },
#define G2(r,n,f,n1,t1,n2,t2) \
	{ n,1,r,f,n1,n2,0,0,0,0,0,0,0,t1,t2 },
#define G3(r,n,f,n1,t1,n2,t2,n3,t3) \
	{ n,1,r,f,n1,n2,n3,0,0,0,0,0,0,t1,t2,t3 },
#define G4(r,n,f,n1,t1,n2,t2,n3,t3,n4,t4) \
	{ n,1,r,f,n1,n2,n3,n4,0,0,0,0,0,t1,t2,t3,t4 },

#define B0(r,n,f) \
	{ n,13,r,f },
#define B1(r,n,f,n1,t1) \
	{ n,13,r,f,n1,0,0,0,0,0,0,0,0,t1, },
#define B2(r,n,f,n1,t1,n2,t2) \
	{ n,13,r,f,n1,n2,0,0,0,0,0,0,0,t1,t2 },
#define B5(r,n,f,n1,t1,n2,t2,n3,t3,n4,t4,n5,t5) \
	{ n,13,r,f,n1,n2,n3,n4,n5,0,0,0,0,t1,t2,t3,t4,t5 },

#define XB0(r,n,f) \
	{ n,14,r,f },
#define XB1(r,n,f,n1,t1) \
	{ n,14,r,f,n1,0,0,0,0,0,0,0,0,t1 },
#define XB2(r,n,f,n1,t1,n2,t2) \
	{ n,14,r,f,n1,n2,0,0,0,0,0,0,0,t1,t2 },
#define XB3(r,n,f,n1,t1,n2,t2,n3,t3) \
	{ n,14,r,f,n1,n2,n3,0,0,0,0,0,0,t1,t2,t3 },
#define XB4(r,n,f,n1,t1,n2,t2,n3,t3,n4,t4) \
	{ n,14,r,f,n1,n2,n3,n4,0,0,0,0,0,t1,t2,t3,t4 },
#define XB6(r,n,f,n1,t1,n2,t2,n3,t3,n4,t4,n5,t5,n6,t6) \
	{ n,14,r,f,n1,n2,n3,n4,n5,n6,0,0,0,t1,t2,t3,t4,t5,t6 },
#define XB7(r,n,f,n1,t1,n2,t2,n3,t3,n4,t4,n5,t5,n6,t6,n7,t7) \
	{ n,14,r,f,n1,n2,n3,n4,n5,n6,n7,0,0,t1,t2,t3,t4,t5,t6,t7 },
#define XB9(r,n,f,n1,t1,n2,t2,n3,t3,n4,t4,n5,t5,n6,t6,n7,t7,n8,t8,n9,t9) \
	{ n,14,r,f,n1,n2,n3,n4,n5,n6,n7,n8,n9,t1,t2,t3,t4,t5,t6,t7,t8,t9 },

#define INTERN0(r,n,f) \
	{ n,-1,r,f },
#define INTERN1(r,n,f,n1,t1) \
	{ n,-1,r,f,n1,0,0,0,0,0,0,0,0,t1 },
#define INTERN2(r,n,f,n1,t1,n2,t2) \
	{ n,-1,r,f,n1,n2,0,0,0,0,0,0,0,t1,t2 },

OP optab[] = {
    G0(LONG, "pterm0", 0)
    G0(LONG, "cconin", 1)
    G1(LONG, "cconout", 2, "char", CHAR)
    G0(LONG, "cauxin", 3)
    G1(LONG, "cauxout", 4, "char", CHAR)
    G1(LONG, "cprnout", 5, "char", CHAR)
    G1(LONG, "crawio", 6, "char", CHAR)
    G0(LONG, "crawcin", 7)
    G0(LONG, "cnecin", 8)
    G1(LONG, "cconws", 9, "string", STRING)
    G1(RSBUF, "cconrs", 0xa, "rsbuf", RSBUF)
    G0(LONG, "cconis", 0xb)
    G1(LONG, "dsetdrv", 0x0e, "drive#", INT)
    G0(LONG, "cconos", 0x10)
    G0(LONG, "cprnos", 0x11)
    G0(LONG, "cauxis", 0x12)
    G0(LONG, "cauxos", 0x13)
    G2(LONG, "maddmem", 0x14, "start", LONG, "size", LONG)
    G1(LONG, "pminalt", 0x15, "amount", LONG)
    G0(LONG, "dgetdrv", 0x19)
    G1(XDTA, "fsetdta", 0x1a, "new dta (x2c)", BUF)
    G1(LONG, "super", 0x20, "ssp (-1 or x400)", BUF)
    G0(LONG, "tgetdate", 0x2a)
    G1(LONG, "tsetdate", 0x2b, "new date", INT)
    G0(LONG, "tgettime", 0x2c)
    G1(LONG, "tsettime", 0x2d, "new time", INT)
    G0(XDTA, "fgetdta", 0x2f)
    G0(LONG, "sversion", 0x30)
    G2(LONG, "ptermres", 0x31, "keep size", LONG, "ret code", INT)
    G2(DFREE, "dfree", 0x36, "buf (x10)", BUF, "drive#", INT)
    G1(LONG, "dcreate", 0x39, "name", STRING)
    G1(LONG, "ddelete", 0x3a, "name", STRING)
    G1(LONG, "dsetpath", 0x3b, "path", STRING)
    G2(LONG, "fcreate", 0x3c, "name", STRING, "mode", INT)
    G2(LONG, "fopen", 0x3d, "name", STRING, "mode", INT)
    G1(LONG, "fclose", 0x3e, "handle", INT)
    G3(FREAD, "fread", 0x3f, "handle", INT, "count", LONG, "buffer", BUF)
    G3(LONG, "fwrite", 0x40, "handle", INT, "count", LONG, "buffer", BUF)
    G1(LONG, "fdelete", 0x41, "name", STRING)
    G3(LONG, "fseek", 0x42, "offset", LONG, "handle", INT, "mode", INT)
    G3(LONG, "fattrib", 0x43, "name", STRING, "wflag", INT, "attr", INT)
    G2(LONG, "fmalloc", 0x44, "amt", LONG, "mode", INT)
    G1(LONG, "fdup", 0x45, "std", INT)
    G2(LONG, "fforce", 0x46, "std", INT, "new", INT)
    G2(BUF0, "dgetpath", 0x47, "buf", BUF, "drive#", INT)
    G1(LONG, "malloc", 0x48, "amt", LONG)
    G1(LONG, "mfree", 0x49, "addr", LONG)
    G3(LONG, "mshrink", 0x4a, "dummy", WZERO, "addr", LONG, "new size", LONG)
    G4(LONG, "pexec", 0x4b, "mode", INT, "name", STRING,
	"tail", STRING, "env", BUF)
    G1(LONG, "pterm", 0x4c, "code", INT)
    G2(XDTA, "fsfirst", 0x4e, "name", STRING, "attr", INT)
    G0(XDTA, "fsnext", 0x4f)
    G3(LONG, "frename", 0x56, "dummy", WZERO, "old", STRING, "new", STRING)
    G3(FDATIME, "fdatime", 0x57, "timeptr", TIMEBUF, "handle", INT,
	"wflag", INT)

    B1(XMPB, "getmpb", 0x0, "mpbptr", XMPB)
    B1(LONG, "bconstat", 0x01, "device", INT)
    B1(LONG, "bconin", 0x02, "device", INT)
    B2(LONG, "bconout", 0x03, "device", INT, "char", CHAR)
    B5(LONG, "rwabs", 0x04, "rwflag", INT, "buf", BUF, "count", INT,
	"recno", INT, "device", INT)
    B2(LONG, "setexc", 0x05, "vecnum", INT, "new value", LONG)
    B0(LONG, "tickcal", 0x06)
    B1(XBPB, "getbpb", 0x07, "device", INT)
    B1(LONG, "bcostat", 0x08, "device", INT)
    B1(LONG, "mediach", 0x09, "device", INT)
    B0(LONG, "drvmap", 0x0a)
    B1(LONG, "kbshift", 0x0b, "mode (-1=dont change)", INT)

    XB3(LONG, "initmous",0x00,"type",INT,"param",LONG,"vec",LONG)
    XB0(LONG, "physbase",0x02)
    XB0(LONG, "logbase",0x03)
    XB0(LONG, "getrez",0x04)
    XB3(LONG, "setscreen",0x05,"logbase",BUF,"physbase",BUF,"rez",INT)
    XB1(LONG, "setpalette",0x06,"ptr",LONG)
    XB2(LONG, "setcolor",0x07,"colnum",INT,"rgb",INT)
    XB7(LONG, "floprd",0x08,"buf",BUF,"filler",LZERO,"devno",INT,
	"sectno",INT,"trackno",INT,"sideno",INT,"count",INT)
    XB7(LONG, "flopwr",0x09,"buf",BUF,"filler",LZERO,"devno",INT,
	"sectno",INT,"trackno",INT,"sideno",INT,"count",INT)
    XB9(FMTBUF, "flopfmt",0x0a,"buf",BUF,"skewtbl or -1",BUF,
	"devno",INT,"spt",INT,"trackno",INT,"sideno",INT,
	"interlv or -1 for skewtbl",INT,"magic",FMAGIC,"virgin",INT)
    XB3(LONG, "dbstub",0x0b,"code",INT,"intarg",INT,"longarg",LONG)
    XB2(LONG, "midiws",0x0c,"cnt",INT,"buf",BUF)
    XB2(LONG, "mfpint",0x0d,"int number",INT,"new vector",LONG)
    XB1(IOREC, "iorec",0x0e,"devno",INT)
    XB6(LONG, "rsconf",0x0f,"speed",INT,"flow",INT,"ucr",INT,
	"rsr",INT,"tsr",INT,"scr",INT)
    XB3(LONG, "keytbl",0x10,"unshift",BUF,"shift",BUF,"capslock",BUF)
    XB0(LONG, "random",0x11)
    XB4(BOOT, "protobt",0x12,"buf",BUF,"serial # or 01000000",LONG,
	"type",INT,"execflag",INT)
    XB7(FMTBUF, "flopver",0x13,"buf",BUF,"filler",LZERO,
	"devno",INT,"sectno",INT,"trackno",INT,"sideno",INT,"count",INT)
    XB0(LONG, "scrdmp",0x14)
    XB2(LONG, "cursconf",0x15,"function",INT,"operand",INT)
    XB1(LONG, "settime",0x16,"datetime",LONG)
    XB0(LONG, "gettime",0x17)
    XB0(LONG, "bioskeys",0x18)
    XB2(LONG, "ikbdws",0x19,"count",INT,"ptr",BUF)
    XB1(LONG, "jdisint",0x1a,"intno",INT)
    XB1(LONG, "jenabint",0x1b,"intno",INT)
    XB2(LONG, "giaccess",0x1c,"data",INT,"register",INT)
    XB1(LONG, "offgibit",0x1d,"bitmask",INT)
    XB1(LONG, "ongibit",0x1e,"bitmask",INT)
    XB4(LONG, "xbtimer",0x1f,"timer",INT,"control",INT,"data",INT,"vec",LONG)
    XB1(LONG, "dosound",0x20,"buf",BUF)
    XB1(LONG, "setprt",0x21,"config",INT)
    XB0(LONG, "kbdvbase",0x22)
    XB2(LONG, "kbrate",0x23,"initial",INT,"repeat",INT)
    XB0(LONG, "prtblk",0x24)
    XB0(LONG, "vsync",0x25)
    XB1(LONG, "supexec",0x26,"codeptr",BUF)
    XB0(LONG, "puntaes",0x27)

    XB1(INT, "floprate",41,"rate",INT)

    XB4(LONG, "dmaread",42,"sector",LONG,"count",INT,"buf",BUF,"devno",INT)
    XB4(LONG, "dmawrite",43,"sector",LONG,"count",INT,"buf",BUF,"devno",INT)

    XB1(INT,"bconmap",44,"devno",INT)
    XB2(LONG,"bconctl",45,"opcode",INT,"opnd",INT)
    XB4(LONG,"nvmaccess",46,"opcode (0=rd,wr,init=2)",INT,
	"start",INT,"count",INT,"buf",BUF)

    XB1(INT,"blitmode",64,"mode",INT)

    XB1(INT,"esetshift",80,"mode",INT)
    XB0(INT,"egetshift",81)
    XB1(INT,"esetbank",82,"bank",INT)
    XB2(INT,"esetcolor",83,"number",INT,"rgb",INT)
    XB3(INT,"esetpalette",84,"start",INT,"count",INT,"colarray",BUF)
    XB3(PALETTE,"egetpalette",85,"start",INT,"count",INT,"colarray",BUF)
    XB1(INT,"esetgray",86,"mode",INT)
    XB1(INT,"esetsmear",87,"mode",INT)

    INTERN0(NOTUSED, "list", 1)
    INTERN0(NOTUSED, "quit", 2)
    INTERN0(NOTUSED, "help", 3)
    INTERN1(NOTUSED, "load", 4, "file", STRING)
    INTERN1(NOTUSED, "transcript", 5, "file (or \"off\")", STRING)
    INTERN0(NOTUSED, "dbstop", 6)
    INTERN1(NOTUSED, "db", 7, "cmd", STRING)
    INTERN0(NOTUSED, "time", 8)
    INTERN2(LONG, "set", 9, "var", LONG, "value", LONG)
    INTERN1(NOTUSED, "zabort", 10, "value", LONG)
    INTERN1(NOTUSED, "miabort", 11, "value", LONG)
    INTERN1(NOTUSED, "nzabort", 12, "value", LONG)
};

int NCMDS = ((sizeof(optab) / sizeof(OP)) - 1);
