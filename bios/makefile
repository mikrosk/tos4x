#
# $Header: /home/mikro/atari/tos/work/bios/rcs/rcs-repaired/makefile,v 1.3 88/10/12 14:44:51 kbad Exp $
#
# Author Slavik Lozben
# This makefile builds the bios object files
#
# 880701 kbad
# Modified to rely on Mark Williams make control files:
#
# 880824 kbad
# added actions to makefile
#
# 880922 kbad
# changed makefile for new build method (now uses alnnew)
#
TMPDIR	=	m:
.SUFFIXES: .o .c .s
.s.o:
	as68 -s $(TMPDIR)\ -f $(TMPDIR)\ -l -u $*.s
.c.o:
	cp68 $*.c $(TMPDIR)\$*.i
	c068 $(TMPDIR)\$*.i $(TMPDIR)\$*.1 $(TMPDIR)\$*.2 $(TMPDIR)$*.3 -f
	c168 $(TMPDIR)\$*.1 $(TMPDIR)\$*.2 $*.s
	rm $(TMPDIR)\$*.*
	optimize $*.s
	as68 -s $(TMPDIR)\ -f $(TMPDIR)\ -l -u $*.s
	rm $*.s
#
################################################################

STARTUP	=	startup.o

SFILES	=	flop.o xinout.o clear.o clock.o bios.o 

CFILES	=	prtblk.o rwabs.o

allbios.o:	$(STARTUP) $(SFILES) $(CFILES) allbios.aln
		alnnew -c allbios.aln
		cp $@ ..\build
		@echo $@ linked.

prtblk.o:	prtblkc.h

rwabs.o:	portab.h

