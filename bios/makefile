########################### BIOS MAKEFILE  ##############################
#
#  $Revision: 2.2 $	$Source: /u2/MRS/osrevisions/bios/makefile,v $
# =======================================================================
#  $Author: kbad $	$Date: 89/06/19 15:46:12 $     $Locker:  $
# =======================================================================
#
#  $Log: makefile,v $
#  Revision 2.2  89/06/19  15:46:12  kbad
#  Fixed pushd/popd lines.
#
# Revision 2.1  89/02/22  20:45:37  kbad
# *** TOS 1.4  FINAL RELEASE VERSION ***
# 
#
#########################################################################
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
	cp $*.s $(TMPDIR)\$*.s
	pushd $(TMPDIR)
	as68 -l -u $*.s
	popd
	mv $(TMPDIR)\$*.o .
	rm $(TMPDIR)\$*.s

.c.o:
	cp $*.c $(TMPDIR)
	pushd $(TMPDIR)
	cp68 $*.c $*.i
	c068 $*.i $*.1 $*.2 $*.3 -f
	c168 $*.1 $*.2 $*.s
	optimize $*.s
	as68 -l -u $*.s
	popd
	mv $(TMPDIR)\$*.o .
	rm $(TMPDIR)\$*.[c|i|1|2|3|s]
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

