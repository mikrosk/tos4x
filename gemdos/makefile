#########################  GEMDOS MAKEFILE  #############################
#
# $Revision: 2.12 $	$Source: e:/tos/gd2\rcs\makefile.,v $
# =======================================================================
# $Author: apratt $ 	$Date: 1991/02/15 18:45:40 $     $Locker:  $
# =======================================================================
#
# $Log: makefile,v $
# Revision 2.12  1991/02/15  18:45:40  apratt
# CI at the end of the week...
#
# Revision 2.11  1991/02/12  18:20:10  apratt
# *** empty log message ***
#
# Revision 2.10  91/01/23  14:30:40  apratt
# Trimmed logs & comments, changed to compile under GCC or (new) Alcyon.
# 
#########################################################################

TMPDIR	=	m:
.SUFFIXES: .o .c .s

# un-comment this whole section to compile with GCC
CC=c:\gnu\bin\gcc.ttp
CFLAGS=-O -Wall -mshort -fstrength-reduce
#.c.o:
#	$(CC) $(CFLAGS) -S $*.c
#	emacs @gas2mac.rc $*.s 
#	mac -u $*.s
#	rm $*.s

#CC=cc
#CFLAGS=

	

################

FRAG =		fscl.o fscomm.o fsdir.o fsfs.o fshand.o scan.o \
		setup.o time.o panic.o mem.o pool.o

frag.prg: testbed.o $(FRAG) traps.o
		$(CC) $(CFLAGS) -o $@ $<

traps.o: traps.s
	gcc-as -o traps.o traps.s

NOTYET =	fsproc.o sup.o con.o

DS=dossys
LDOBJS	=	$(DS)\self.o $(DS)\ld_dos.o $(DS)\clear.o $(DS)\clock.o \
			$(DS)\announce.o $(DS)\fsstub.o

dos.sys:	gemdos.t
		mkvers $(DS)\announce.o
		aln -l -o dos.sys $(LDOBJS) gemdos.t

gemdos.t:	rwa.t $(OBJS) 
		aln -u -p -l -o $@ $<

gemdos.sx:	rwa.sx $(OBJS) 
		aln -u -p -l -o $@ $<

$(OBJS):	fs.h

fs.h:		fsdecl.h gemerror.h
