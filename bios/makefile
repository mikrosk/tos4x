########################### BIOS MAKEFILE  ##############################
#
#  $Revision: 2.7 $	$Source: /u2/MRS/osrevisions/bios/makefile,v $
# =======================================================================
#  $Author: apratt $	$Date: 90/11/26 13:16:28 $     $Locker:  $
# =======================================================================
#
#  $Log: makefile,v $
#  Revision 2.7  90/11/26  13:16:28  apratt
#  Flop now has .sx, .e, and .t extensions, though .e and .t
#  are really the same thing.  (Both TT and MSTE have high-density
#  floppy capability.)
#
# Revision 2.6  90/08/03  13:23:19  apratt
# TTOS FINAL RELEASE
# 
# Revision 2.5  90/08/03  11:28:25  apratt
# This version has variables set for machine and country, to tell it
# what switches and object files to use.
# 
# Revision 2.4  89/09/22  16:54:54  apratt
# THIS VERSION REQUIRES TURBO C'S "MAS" ASSEMBLER
# No functional changes from previous revision, which is the last to
# require Alcyon's AS68 assembler.
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

#
# startup is affected by country, systype, and machine switches:
# first letter t for TT, e for STe, s for ST.  Systype is the
# middle letter: a for RAM, o for ROM.  Country is the third
# letter: u=usa, g=germany, ...
#
# dmaread and clock are affected only by machine switches,
# and then only by TSXMACHINE: t for TT and sx for others.
#
# flop is affected by MACHINE, though t and e are actually the same.
#
# bios is affected by machine and country.
#
# Set these switches with no spaces.  MACHINE is s, e, or t;
# TSXMACHINE is sx or t (for dmaread, and clock).
# These are the one-letter country codes used in file names for building TOS:
# 
# 	u	usa
# 	g	germany
# 	f	france
# 	k	uk
# 	s	spain (must also set PAL to 0 or 1)
# 	i	italy
# 	w	sweden
# 	a	swissfra
# 	b	swissger
# 	t	turkey
# 	c	finland
# 	n	norway
# 	d	denmark
# 
# letters used: abcd fg i k  n    stu w
# letters free:     e  h j lm opqr   v xyz

CCODE=u
MACHINE=t
TSXMACHINE=t

# that's all you need to set for different machines or countries.
############

TMPDIR	=	m:

ASM = mas -3 -8 -S $*.s -O=$@

# You can add "-s c:\alcyon\lib\oas68sym.dat" or whatever to the as68 line.

.c.o:
	cp $*.c $(TMPDIR)
	pushd $(TMPDIR)
	ocp68 $*.c $*.i
	oc068 $*.i $*.1 $*.2 $*.3 -f
	oc168 $*.1 $*.2 $*.s
	optimize $*.s
	oas68 -l -u -s c:\alcyon\lib\oas68sym.dat $*.s
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

allbios.$(MACHINE)o$(CCODE):	startup.$(MACHINE)o \
			dmaread.$(TSXMACHINE) clock.$(TSXMACHINE) \
			bios.$(MACHINE)$(CCODE) flop.$(MACHINE) \
			$(CFILES) $(SFILES)
		aln -u -u -p -w -l -o $@ $<
		cp $@ ..\build
		@echo $@ linked.

# add fsstub.o to this list if you define USEDB as 1 in startup.s

allbios.$(MACHINE)a$(CCODE):	startup.$(MACHINE)a \
			dmaread.$(TSXMACHINE) clock.$(TSXMACHINE) \
			bios.$(MACHINE)$(CCODE) flop.$(MACHINE) \
			$(CFILES) $(SFILES)
		aln -u -u -p -w -l -o $@ $<
		cp $@ ..\build
		@echo $@ linked.

prtblk.o:	prtblkc.h prtblk.c

rwabs.o:	portab.h rwabs.c

xinout.o:	xinout.s
		$(ASM)

clear.o:	clear.s
		$(ASM)

############

# any switches.t* will do for these three

dmaread.t:	dmaread.s
		cp switches.tau switches.s
		$(ASM)

flop.t:		flop.s
		cp switches.tau switches.s
		$(ASM)

flop.e:		flop.s
		cp switches.eau switches.s
		$(ASM)

flop.sx:	flop.s
		cp switches.sau switches.s
		$(ASM)

dmaread.sx:	dmaread.s
		cp switches.sau switches.s
		$(ASM)

clock.sx:	clock.s
		cp switches.sau switches.s
		$(ASM)

clock.t:	clock.s
		cp switches.tau switches.s
		$(ASM)


############

startup.$(MACHINE)a:	startup.s
		cp switches.$(MACHINE)au switches.s
		$(ASM)

startup.$(MACHINE)o:	startup.s
		cp switches.$(MACHINE)ou switches.s
		$(ASM)

############

# any switches.x?y will do for BIOS (x is machine, y is country)

bios.$(MACHINE)$(CCODE):	bios.s
		cp switches.$(MACHINE)a$(CCODE) switches.s
		$(ASM)
