########################### BIOS MAKEFILE  ##############################
#
#  $Revision: 2.4 $	$Source: /u2/MRS/osrevisions/bios/makefile,v $
# =======================================================================
#  $Author: apratt $	$Date: 89/09/22 16:54:54 $     $Locker:  $
# =======================================================================
#
#  $Log: makefile,v $
#  Revision 2.4  89/09/22  16:54:54  apratt
#  THIS VERSION REQUIRES TURBO C'S "MAS" ASSEMBLER
#  No functional changes from previous revision, which is the last to
#  require Alcyon's AS68 assembler.
#
# Revision 2.3  89/08/25  16:45:58  apratt
# Added dmaread.o and dmaread.s (needs mac, not as68).
# 
# Revision 2.2  89/06/19  15:46:12  kbad
# Fixed pushd/popd lines.
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
ASM = mas -3 -S -U $*.s

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

# SFILES are those not affected by country or machine switches

SFILES	=	xinout.o clear.o

# CFILES are those which come from .c sources, also not affected
# by country or machine switches.

CFILES	=	prtblk.o rwabs.o

allbios.tau:	startup.tau dmaread.tau flop.tau clock.tau bios.tau \
			$(CFILES) $(SFILES)
		aln -u -q -w -l -o $@ $<
		cp $@ ..\build
		@echo $@ linked.

allbios.tou:	startup.tou dmaread.tou flop.tou clock.tou bios.tou \
			$(CFILES) $(SFILES)
		aln -u -q -w -l -o $@ $<
		cp $@ ..\build
		@echo $@ linked.

allbios.eau:	startup.eau dmaread.eau flop.eau clock.eau bios.eau \
			$(CFILES) $(SFILES)
		aln -u -q -w -l -o $@ $<
		cp $@ ..\build
		@echo $@ linked.

allbios.eou:	startup.eou dmaread.eou flop.eou clock.eou bios.eou \
			$(CFILES) $(SFILES)
		aln -u -q -w -l -o $@ $<
		cp $@ ..\build
		@echo $@ linked.

allbios.sau:	startup.sau dmaread.sau flop.sau clock.sau bios.sau \
			$(CFILES) $(SFILES)
		aln -u -q -w -l -o $@ $<
		cp $@ ..\build
		@echo $@ linked.

allbios.sou:	startup.sou dmaread.sou flop.sou clock.sou bios.sou \
			$(CFILES) $(SFILES)
		aln -u -q -w -l -o $@ $<
		cp $@ ..\build
		@echo $@ linked.

prtblk.o:	prtblkc.h prtblk.c

rwabs.o:	portab.h rwabs.c

xinout.o:	xinout.s
		mas -S -U xinout.s

clear.o:	clear.s
		mas -S -U clear.s

########

startup.tau:	startup.s
		cp switches.tau switches.s
		mas -S -U startup.s -O=startup.tau

dmaread.tau:	dmaread.s
		cp switches.tau switches.s
		mas -S -U dmaread.s -O=dmaread.tau

flop.tau:	flop.s
		cp switches.tau switches.s
		mas -S -U flop.s -O=flop.tau

clock.tau:	clock.s
		cp switches.tau switches.s
		mas -S -U clock.s -O=clock.tau

bios.tau:	bios.s
		cp switches.tau switches.s
		mas -S -U bios.s -O=bios.tau

########

startup.tou:	startup.s
		cp switches.tou switches.s
		mas -S -U startup.s -O=startup.tou

dmaread.tou:	dmaread.s
		cp switches.tou switches.s
		mas -S -U dmaread.s -O=dmaread.tou

flop.tou:	flop.s
		cp switches.tou switches.s
		mas -S -U flop.s -O=flop.tou

clock.tou:	clock.s
		cp switches.tou switches.s
		mas -S -U clock.s -O=clock.tou

bios.tou:	bios.s
		cp switches.tou switches.s
		mas -S -U bios.s -O=bios.tou

########

startup.eau:	startup.s
		cp switches.eau switches.s
		mas -S -U startup.s -O=startup.eau

dmaread.eau:	dmaread.s
		cp switches.eau switches.s
		mas -S -U dmaread.s -O=dmaread.eau

flop.eau:	flop.s
		cp switches.eau switches.s
		mas -S -U flop.s -O=flop.eau

clock.eau:	clock.s
		cp switches.eau switches.s
		mas -S -U clock.s -O=clock.eau

bios.eau:	bios.s
		cp switches.eau switches.s
		mas -S -U bios.s -O=bios.eau

########

startup.eou:	startup.s
		cp switches.eou switches.s
		mas -S -U startup.s -O=startup.eou

dmaread.eou:	dmaread.s
		cp switches.eou switches.s
		mas -S -U dmaread.s -O=dmaread.eou

flop.eou:	flop.s
		cp switches.eou switches.s
		mas -S -U flop.s -O=flop.eou

clock.eou:	clock.s
		cp switches.eou switches.s
		mas -S -U clock.s -O=clock.eou

bios.eou:	bios.s
		cp switches.eou switches.s
		mas -S -U bios.s -O=bios.eou

########

startup.sau:	startup.s
		cp switches.sau switches.s
		mas -S -U startup.s -O=startup.sau

dmaread.sau:	dmaread.s
		cp switches.sau switches.s
		mas -S -U dmaread.s -O=dmaread.sau

flop.sau:	flop.s
		cp switches.sau switches.s
		mas -S -U flop.s -O=flop.sau

clock.sau:	clock.s
		cp switches.sau switches.s
		mas -S -U clock.s -O=clock.sau

bios.sau:	bios.s
		cp switches.sau switches.s
		mas -S -U bios.s -O=bios.sau

########

startup.sou:	startup.s
		cp switches.sou switches.s
		mas -S -U startup.s -O=startup.sou

dmaread.sou:	dmaread.s
		cp switches.sou switches.s
		mas -S -U dmaread.s -O=dmaread.sou

flop.sou:	flop.s
		cp switches.sou switches.s
		mas -S -U flop.s -O=flop.sou

clock.sou:	clock.s
		cp switches.sou switches.s
		mas -S -U clock.s -O=clock.sou

bios.sou:	bios.s
		cp switches.sou switches.s
		mas -S -U bios.s -O=bios.sou

########

