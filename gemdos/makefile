#########################  GEMDOS MAKEFILE  #############################
#
# $Revision: 2.17 $	$Source: e:/tos/gd2\RCS\makefile.,v $
# =======================================================================
# $Author: apratt $ 	$Date: 1991/04/05 18:38:22 $     $Locker:  $
# =======================================================================
#
# $Log: makefile,v $
# Revision 2.17  1991/04/05  18:38:22  apratt
# Misc fixes making it work
#
# Revision 2.16  1991/03/28  17:39:36  apratt
# THIS VERSION BOOTS! DESKTOP OPERATIONS WORK!
#
# Revision 2.15  1991/03/13  17:51:44  apratt
# Don't know.
#
# Revision 2.14  1991/03/12  18:25:26  apratt
# Making gtest.prg works and lets you test functions in this version
#
# Revision 2.13  1991/02/21  03:07:32  apratt
# This version performs this testbed perfectly.
#
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
.SUFFIXES: .o .oo .c .s .mac .gas

# un-comment this whole section to compile with GCC
CC=gcc
CFLAGS=-fcall-used-d2 -fcall-used-a2 -fcall-saved-d3 -fcall-saved-a3 \
	-O -Wall -mshort -fstrength-reduce -fcombine-regs -fforce-mem
.s.o:
	$(CC) -c $*.s

# un-comment these lines if you want to use MAC to assemble GCC's output
.c.o:
	$(CC) $(CFLAGS) -S $*.c
	emacs @gas2mac.rc $*.s 
	mas -u $*.s
	rm $*.s

.c.oo:
	$(CC) $(CFLAGS) -S -DUNREAL $*.c
	emacs @gas2mac.rc $*.s 
	mas -u $*.s
	mv $*.o $*.oo
	rm $*.s

.mac.o:
	mas -u $*.mac

.gas.o:
	gcc-as -o $*.o $*.gas

all: gtest.prg dos.sys

# set these to .mac or .gas as appropriate

docall.o: docall.mac
traps.o: traps.mac
rwa.o: rwa.mac

################

CFILES =	fscl.c fscomm.c fsdir.c fsfs.c fshand.c scan.c \
		setup.c time.c panic.c mem.c pool.c sup.c con.c \
		fsproc.c

OFILES =	fscl.o fscomm.o fsdir.o fsfs.o fshand.o scan.o \
		time.o panic.o pool.o sup.o con.o \
		fsproc.o

gtest.prg: ftest.o fcmds.o docall.o traps.o unreal.oo setup.oo mem.oo $(OFILES) 
		cc -o $@ $< -l syserr.o
		prgflags 7 7 $@

DS=dossys
LDOBJS	=	$(DS)\self.o $(DS)\ld_dos.o $(DS)\clear.o $(DS)\clock.o \
			$(DS)\announce.o $(DS)\fsstpar.o

dos.sys:	gemdos.o
		mkvers $(DS)\announce.o
		aln -l -o dos.sys $(LDOBJS) gemdos.o


gemdos.o:	rwa.o setup.o mem.o $(OFILES) 
		aln -u -p -l -o $@ $<

#$(OFILES):	fs.h

fs.h:		fsdecl.h gemerror.h

proto.h:	$(CFILES)
		mkptypes -z $< >proto.h

# Compile these things with your "native" compiler, rather than using GCC
# and then messing with the assembly language.  If your "native" compiler
# *is* GCC, you're golden.

ftest.o: ftest.c
		cc -c ftest.c
fcmds.o: fcmds.c
		cc -c fcmds.c


