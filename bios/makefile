#
# $Header: /home/mikro/atari/tos/work/bios/rcs/rcs-repaired/makefile,v 1.1 88/09/19 14:00:58 kbad Exp $
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

SFILES	=	flop.o xinout.o startup.o clear.o clock.o bios.o 

CFILES	=	prtblk.o rwabs.o

allbios.o:	$(SFILES) $(CFILES) allbios.aln
		aln -c allbios.aln
		mv $@ ..\build
		@echo $@ linked.

rallbios.o:	$(SFILES) $(CFILES) rallbios.aln
		aln -c rallbios.aln
		mv $@ ..\build
		@echo $@ linked.

prtblk.o:	prtblkc.h

rwabs.o:	portab.h
