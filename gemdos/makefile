#########################  GEMDOS MAKEFILE  #############################
#
# $Revision: 2.10 $	$Source: makefile.,v $
# =======================================================================
# $Author: apratt $ 	$Date: 91/01/23 14:30:40 $     $Locker:  $
# =======================================================================
#
# $Log: makefile,v $
# Revision 2.10  91/01/23  14:30:40  apratt
# Trimmed logs & comments, changed to compile under GCC or (new) Alcyon.
#
#########################################################################

TMPDIR	=	m:
.SUFFIXES: .o .c .s

#CC=gcc
#CFLAGS=-O -Wall -mshort -fstrength-reduce
CC=cc
CFLAGS=

################

OBJS	=	con.o    freednd.o fscl.o   fscomm.o fsdir.o  fsfs.o \
		fshand.o fsinter.o fsmisc.o fsnam.o  fsproc.o mem.o  \
		panic.o  pool.o    setup.o  sup.o    time.o

DS=dossys
LDOBJS	=	$(DS)\self.o $(DS)\ld_dos.o $(DS)\clear.o $(DS)\clock.o \
			$(DS)\announce.o $(DS)\fsstub.o

dos.sys:	gemdos.t
		mkvers $(DS)\announce.o
		aln -l -o dos.sys $(LDOBJS) gemdos.t

gemdos.t:	rwa.t $(OBJS) 
		aln -u -p -l -o $@@ $<

gemdos.sx:	rwa.sx $(OBJS) 
		aln -u -p -l -o $@@ $<

$(OBJS):	fs.h

fs.h:		fsdecl.h gemerror.h
