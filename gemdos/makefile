# Makefile for GEMDOS - requires Lattice or GNU make
# =======================================================================
# $Id: makefile.,v 2.22 1992/07/05 01:01:10 kbad Exp $
# History is in the above file in the RCS directory (use rlog to see it).

# Rules
# =======================================================================

.SUFFIXES:
.SUFFIXES: .o .ot .ol .og .c .s .mac .gas

# Assembler rules
# -----------------------------------------------------------------------
AS=pasm
ASFLAGS=-U -3 -B #-B for pasm
.mac.o:
	$(AS) $(ASFLAGS) $*.mac
.gas.og:
	gcc-as -o $*.o $*.gas

# Lattice rules
# -----------------------------------------------------------------------
CDEF=
CERR=-j135i
#135: Assignment to shorter data type (precision may be lost)
CMOD=-w
COPT=-d -O
.c.ol:
	$(CC) -m3 -c $(CFLAGS) -o$@ $<

ifdef USELC
# Lattice-specific rules
# -----------------------------------------------------------------------
CC=lcc
CFLAGS=$(CDEF) $(CERR) $(CMOD) $(COPT)
.c.ot:
	$(CC) -m3 -z2 -c $(CFLAGS) -o$@ $<
.c.o:
	$(CC) -z2 -c $(CFLAGS) -o$@ $<

else
# GCC rules
# -----------------------------------------------------------------------
CC=gcc
CFLAGS=-fcall-used-d2 -fcall-used-a2 -fcall-saved-d3 -fcall-saved-a3 \
	-O -Wall -mshort -fstrength-reduce -fcombine-regs -fforce-mem

.s.o:
	$(CC) -c $<
.s.ot:
	$(CC) -m68020 -c $<

# comment out the .c.o .c.ot rules to use gas as gcc's back end
.c.o:
	$(CC) $(CFLAGS) -S -o $*.1 $<
	sed -f gass $*.1 > $*.2
	$(AS) $(ASFLAGS) $*.2 -O=$*.o
	rm $*.1 $*.2

#	emacs @gas2mac.rc temp.s

.c.ot:
	$(CC) -m68020 $(CFLAGS) -S -o $*.1 $<
	sed -f gass $*.1 > $*.2
	$(AS) $(ASFLAGS) $*.2 -O=$*.ot
	rm $*.1 $*.2

#	emacs @gas2mac.rc temp.s
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

# S= directory where loader files live
S=sys
LOADER=$S\self.o $S\ld_dos.o $S\clear.o $S\clock.o $S\announce.o $S\fsstpar.o


# Targets
# =======================================================================

default:
	@echo 'use: make [USELC=] [all] [dos.sys] [gemdos.030] [gemdos.68k] [gtest.prg]'

all: dos.sys gemdos.68k gtest.prg


dos.sys: $(LOADER) gemdos.030
	mkvers $S\announce.o
	aln -l -o dos.sys $<

gemdos.030: $(OTFILES) 
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

# Assembler objects
docall.o: docall.mac
traps.o: traps.mac
rwa.o: rwa.mac
docall.og: docall.gas
traps.og: traps.gas
rwa.og: rwa.gas
