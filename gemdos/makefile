#########################  GEMDOS MAKEFILE  #############################
#
# $Revision: 2.9 $	$Source: /u2/MRS/osrevisions/gemdos/makefile,v $
# =======================================================================
# $Author: apratt $ 	$Date: 90/11/26 13:51:27 $     $Locker:  $
# =======================================================================
#
# $Log: makefile,v $
# Revision 2.9  90/11/26  13:51:27  apratt
# Makefile now copies switches.t or switches.sx to switches.s
# to build rwa.s with or without JUST_LONG, respectively.
# 
# Revision 2.8  90/09/14  14:03:28  apratt
# Added a rule for rwa.o: needs mas, not as68.
# 
# Revision 2.7  90/08/03  13:42:09  apratt
# TTOS FINAL RELEASE
# 
# Revision 2.6  90/04/24  12:58:25  apratt
# Removed gemdos.aln from gemdos.o's dependency list
# 
# Revision 2.5  90/04/24  11:34:31  apratt
# Removed all CPPFLAGS, as the GEMDOS of this date doesn't need them.
# Also removed gemdos.aln usage: aln now uses ARGV and can take long
# argument lists.
# 
# Revision 2.4  89/12/27  14:43:51  apratt
# Added -DFASTRAM to CPPFLAGS line.  Remove it if the OS being built
# won't run on a machine with fast RAM (that is, not a TT).  This
# switch is used in mem.c, fsproc.c, and pool.c.
# 
# Revision 2.3  89/06/19  15:50:59  kbad
# Fixed pushd/popd lines
# 
# Revision 2.2  89/04/17  17:15:05  kbad
# YA header change
# 
# Revision 2.1  89/02/22  20:41:07  kbad
# *** TOS 1.4  FINAL RELEASE VERSION ***
# 
#
#########################################################################
# Makefile for gemdos, for TOS builds
# 880620 Ken Badertscher
#
################
# 890123 kbad	changed `alnnew' references to `aln' (new aln is now OK)
# 881010 kbad	use alnnew
# 880824 kbad	cleaned up for new make.ttp
# 880719 kbad	per akp, removed CKMEDIA flag, it was causing problems
# 880713 kbad	added CPPFLAGS
# 880701 kbad	Modified to rely on Mark Williams make control files:
#################
TMPDIR	=	m:
.SUFFIXES: .o .c .s

.c.o:
	cp $*.c $(TMPDIR)
	pushd $(TMPDIR)
	ocp68 $(CPPFLAGS) $*.c $*.i
	oc068 $*.i $*.1 $*.2 $*.3 -f
	oc168 $*.1 $*.2 $*.s
	optimize $*.s
	oas68 -l -u -s c:\alcyon\lib\oas68sym.dat $*.s
	popd
	mv $(TMPDIR)\$*.o .
	rm $(TMPDIR)\$*.[c|i|1|2|3|s]

################

CPPFLAGS =

OBJS	=	con.o    freednd.o fscl.o   fscomm.o fsdir.o  fsfs.o \
		fshand.o fsinter.o fsmisc.o fsnam.o  fsproc.o mem.o  \
		panic.o  pool.o    setup.o  sup.o    time.o

gemdos.t:	rwa.t $(OBJS) 
		aln -u -p -l -o $@ $<
		cp $@ ..\build
		@echo $@ linked.

gemdos.sx:	rwa.sx $(OBJS) 
		aln -u -p -l -o $@ $<
		cp $@ ..\build
		@echo $@ linked.

$(OBJS):	fs.h

rwa.t:		rwa.s
		cp switches.t switches.s
		mas -3 -S -o=$@ $<

rwa.sx:		rwa.s
		cp switches.sx switches.s
		mas -3 -S -o=$@ $<

con.o:		fsdecl.h

freednd.o:	gemerror.h fsdecl.h

fscl.o:		gemerror.h fsdecl.h

fscomm.o:

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
