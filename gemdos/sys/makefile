# makefile for GEMDOS, derived from the TOS 1.4 release version.
# this has some salt added plus dos.sys building.

DS=dossys
TMPDIR	=	m:
ASFLAGS	=	-l -u -s e:\oas68sym.dat
.SUFFIXES: .o .c .s
.s.o:
	mac $*.s
	cp $*.s $(TMPDIR)\$*.s
	pushd $(TMPDIR)
	oas68 $(ASFLAGS) $*.s
	popd
	mv $(TMPDIR)\$*.o .
	rm $(TMPDIR)\$*.s

.c.o:
	cp $*.c $(TMPDIR)
	pushd $(TMPDIR)
	ocp68 $(CPPFLAGS) $*.c $*.i
	oc068 $*.i $*.1 $*.2 $*.3 -f
	oc168 $*.1 $*.2 $*.s
#	optimize $*.s
#	oas68 $(ASFLAGS) $*.s
	mac -6 $*.s
	popd
	mv $(TMPDIR)\$*.o .
	rm $(TMPDIR)\$*.[c|i|1|2|3|s]

################

LDOBJS	=	$(DS)\self.o $(DS)\ld_dos.o $(DS)\clear.o $(DS)\clock.o \
			$(DS)\announce.o $(DS)\fsstub.o

dos.sys:	gemdos.o $(LDOBJS)
		mkvers $(DS)\announce.o
		aln -l -o dos.sys $(LDOBJS) gemdos.o

xdos.sys:	gemdos.o self.o ld_dos.o clear.o clock.o announce.o
		aln -u -o xdos.sys self.o ld_dos.o clear.o clock.o \
			announce.o gemdos.o

CPPFLAGS =	-DBIGCL -DBIGPARTS -DFLUSHALL -DFASTCL # -DCKMEDIA

OBJS	=	con.o    freednd.o fscl.o   fscomm.o fsdir.o  fsfs.o \
		fshand.o fsinter.o fsmisc.o fsnam.o  fsproc.o mem.o  \
		panic.o  pool.o    rwa.o    setup.o  sup.o    time.o

gemdos.o:	$(OBJS) gemdos.aln
		aln -c gemdos.aln

$(OBJS):	fs.h

con.o:		fsdecl.h

freednd.o:	gemerror.h fsdecl.h

fscl.o:		gemerror.h fsdecl.h

fsdir.o:	gemerror.h fsdecl.h

fsfs.o:		gemerror.h fsdecl.h

fshand.o:	gemerror.h fsdecl.h

fsinter.o:	gemerror.h fsdecl.h

fsmisc.o:	gemerror.h fsdecl.h

fsnam.o:	gemerror.h fsdecl.h

fsproc.o:	gemerror.h fsdecl.h

mem.o:		gemerror.h fsdecl.h

panic.o:	gemerror.h fsdecl.h

pool.o:		gemerror.h fsdecl.h

setup.o:	fsdecl.h

sup.o:		gemerror.h

time.o:		gemerror.h

self.o:
	mac self.s
ld_dos.o:
	mac ld_dos.s
clear.o:
	mac clear.s
clock.o:
	mac clock.s
announce.o:
	mac announce.s
