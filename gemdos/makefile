# Makefile for GEMDOS - requires Lattice or GNU make
# =======================================================================
# $Id: makefile.,v 2.24 1992/08/11 00:37:02 kbad Exp $
# History is in the above file in the RCS directory (use rlog to see it).

ifdef NODB
DBFLAG=-DNODB
else
DBFLAG=
endif

ifdef T
R=-D=REALTIME=1
else
R=-D=REALTIME=0
endif

# Rules
# =======================================================================

.SUFFIXES:
.SUFFIXES: .o .ot .ol .og .c .s .mac .gas

# Assembler rules
# -----------------------------------------------------------------------
AS=pasm
ASFLAGS=-ub2 $R #-b for pasm
.mac.o:
	$(AS) $(ASFLAGS) -o=$@ $<
.gas.og:
	gcc-as -o $@ $<
.s.o:
	$(AS) $(ASFLAGS) -o=$@ $<


# Lattice rules
# -----------------------------------------------------------------------
CDEF=$(DBFLAG)
CERR=-j135i
#135: Assignment to shorter data type (precision may be lost)
# -w: short ints
# -b0 -bn: no base reg, a4 is reg. var
CMOD=-w -b0 -bn
# -d2: debug, include local symbols
# -O: optimize
# -mf: frames (link/unlk)
# -z2: DRI output
# -hd3 -ha3: temps end at d3/a3
COPT=-d2 -O -mf -z2 -hd3 -ha3
.c.ol:
	$(CC) -c $(CFLAGS) -o$@ $<

ifdef GCC
# GCC-specific rules
# -----------------------------------------------------------------------
CC=gcc

CFLAGS=$(DBFLAG) -O -Wall -mshort \
	-fcall-used-d2 -fcall-used-a2 -fcall-saved-d3 -fcall-saved-a3 \
	-fstrength-reduce -fcombine-regs -fforce-mem


# comment out the .c.o .c.ot rules to use gas as gcc's back end
.c.o:
	$(CC) $(CFLAGS) -S -o $*.1 $<
	sed -f ss $*.1 > $*.2
	$(AS) $(ASFLAGS) $*.2 -O=$*.o
	mv $*.1 $*.2 seds
#	emacs @gas2mac.rc $*.2

.c.ot:
	$(CC) -m68020 $(CFLAGS) -S -o $*.1 $<
	sed -f ss $*.1 > $*.2
	$(AS) $(ASFLAGS) $*.2 -O=$*.ot
	mv $*.1 $*.2 tseds
#	emacs @gas2mac.rc $*.s
else
# Lattice-specific rules used by default
# -----------------------------------------------------------------------
CC=lcc
CFLAGS=$(CDEF) $(CERR) $(CMOD) $(COPT)
.c.ot:
	$(CC) -m3 -c $(CFLAGS) -o$@ $<
.c.o:
	$(CC) -c $(CFLAGS) -o$@ $<

endif


# Macros
# =======================================================================

CFILES = fscl.c fsdir.c fsfs.c fshand.c scan.c \
	time.c panic.c mem.c pool.c sup.c con.c \
	fsproc.c

# rwa.o is in the middle so everything can call it pc-relative
OFILES = fscl.o fsdir.o fsfs.o fshand.o scan.o \
	time.o panic.o rwa.o mem.o pool.o sup.o con.o \
	fsproc.o

OTFILES = fscl.ot fsdir.ot fsfs.ot fshand.ot scan.ot \
	time.ot panic.ot rwa.o mem.ot pool.ot sup.ot con.ot \
	fsproc.ot

# OTDFILES for linking debug stub with TOS
OTDFILES = fscl.ot fsdir.ot fsfs.ot fshand.ot scan.ot \
	time.ot panic.ot rwa.o mem.ot pool.ot sup.otd con.ot \
	fsproc.ot $S\fsstpar.o

# S= directory where loader files live
# $S\clock.o - not used no more?  -----v
S=sys
LOADER=$S\self.o $S\ld_dos.o $S\clear.o  $S\announce.o $S\fsstpar.o version.o


# Targets
# =======================================================================

default:
	@echo 'use: make [NODB=] [GCC=] [all] [dos.68k] [dos.030] [gemdos.68k] [gemdos.030] [gtest.prg]'

all: dos.sys gemdos.030 gemdos.68k gtest.prg


dos.68k: $(LOADER) gemdos.68k
	aln -l -o $@ $<

dos.030: $(LOADER) gemdos.030
	aln -l -o $@ $<

gemdos.030: $(OTFILES)
	aln -u -p -l -o $@ $<

gemdos.03d: $(OTDFILES)
	aln -u -p -l -o $@ $<

gemdos.68k: $(OFILES)
	aln -u -p -l -o $@ $<

ftest.prg: ftest.ol fcmds.ol
	lcc $(CDEF) $(CMOD) $(COPT) -o$@ $<

# Dependencies
# =======================================================================

fs.h: fsdecl.h gemerror.h

proto.h: $(CFILES)
	mkptypes -z $< >proto.h

version.o: # always make this by hand
	lcc -c $(CMOD) $(COPT) version.c

sup.otd: sup.c
	$(CC) -DSTUB -m3 -c $(CFLAGS) -o$@ $<


# Assembler objects
docall.o: docall.mac
traps.o: traps.mac
rwa.o: rwa.mac
docall.og: docall.gas
traps.og: traps.gas
rwa.og: rwa.gas
