#
# $Header: /u2/MRS/osrevisions/aes/foo,v 1.4 89/01/23 12:18:41 kbad Exp $
#
# Author Slavik Lozben
# This makefile builds the bios object files
#
# 890123 kbad	changed `alnnew' refs to `aln' (new aln is now "OK")
# 880922 kbad	changed makefile for new build method (now uses alnnew)
# 880824 kbad	added actions to makefile
# 880701 kbad	Modified to rely on Mark Williams make control files:
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
		aln -c allbios.aln
		cp $@ ..\build
		@echo $@ linked.

prtblk.o:	prtblkc.h

rwabs.o:	portab.h

