# Makefile for all BIOS - requires Lattice or GNU make
# =======================================================================
# 920702 kbad  New!  Improved!  Cleaner, whiter builds!


# The allbios extender is based on the switches set:
# ROM/RAM is the first letter: a for RAM, o for ROM.
# Machine is the second letter: t(TT) e(STe) p(STbook) f(Falcon/040)
# Country is the third letter: u=usa, g=germany, ... (see below)

# bios is affected by machine and country.
# flop, dmaread and clock are affected by the machine switch only.
# rwabs.c is affected by machine, too: for SPARROW it gets USE_DISK_CHANGE.
# startup is affected by machine, systype and MTOS.

# Look at the `default:' target, or type 'make' for usage information.


# Country codes
# -----------------------------------------------------------------------
# used: abcd fg i k  n    stu w
# free:     e  h j lm opqr   v xyz0123456789

# These numbers must match the values in switches.s
USA=0
UK=1
GERMANY=2
FRANCE=3
SPAIN=4
SWEDEN=5
ITALY=6
SWISSFRA=7
SWISSGER=8
TURKEY=9
FINLAND=10
NORWAY=11
DENMARK=12

ifndef C
C=u		    # default: usa
endif

ifeq '$C' 'a'
CNUM = $(SWISSFRA)
endif
ifeq '$C' 'b'
CNUM = $(SWISSGER)
endif
ifeq '$C' 'c'
CNUM = $(FINLAND)
endif
ifeq '$C' 'd'
CNUM = $(DENMARK)
endif
ifeq '$C' 'f'
CNUM = $(FRANCE)
endif
ifeq '$C' 'g'
CNUM = $(GERMANY)
endif
ifeq '$C' 'i'
CNUM = $(ITALY)
endif
ifeq '$C' 'k'
CNUM = $(UK)
endif
ifeq '$C' 'n'
CNUM = $(NORWAY)
endif
ifeq '$C' 's'
CNUM = $(SPAIN)
endif
ifeq '$C' 't'
CNUM = $(TURKEY)
endif
ifeq '$C' 'u'
CNUM = $(USA)
endif
ifeq '$C' 'w'
CNUM = $(SWEDEN)
endif


# Machine switches, set TT, SPARROW, STPAD, USE_DISK_CHANGE
# -----------------------------------------------------------------------

ifndef M
M=w		    # default: sparrow
endif

# Set values for ST/STe/MegaSTe
MTT = 0		    # TT machine flag
MSP = 0		    # SPARROW machine flag
MPD = 0		    # STPAD machine flag
DCHANGE = 0	    # USE_DISK_CHANGE value for rwabs.c

ifeq '$M' 'p'	    # STBOOK
MPD = 1
endif

ifeq '$M' 't'	    # TT
MTT = 1
endif

ifeq '$M' 'w'	    # Sparrow
MSP = 1
#DCHANGE = 1	    # testing
endif


# ROM/RAM flag, sets `systype' (switches.s: rom=0, ram=1)
# -----------------------------------------------------------------------

ifndef RAM
RAM=1		    # default: RAM build
endif

# set extender for startup & allbios
ifeq '$(RAM)' '0'
R=o
else
R=a
endif

# MultiTOS AES flag, sets `MTOS' (startup.s: version 5.00 instead of 4.05)
# -----------------------------------------------------------------------

ifndef MTOS
MTOS=0		    # default: single-TOS AES
endif

# Finally, set assembler and compiler flags from the above
# -----------------------------------------------------------------------
ASFLAGS = -S38 -D=country=$(CNUM) -D=systype=$(RAM) \
	-D=TT=$(MTT) -D=SPARROW=$(MSP) -D=STPAD=$(MPD) -D=MTOS=$(MTOS)

CDEF = -DUSE_DISK_CHANGE=$(DCHANGE)
CERR = -cw -j100i
COPT = -d2 -O -hd3 -ha3 -z2 -v
CMOD = -w -b0 -bn
CFLAGS = $(CDEF) #$(CERR) $(COPT) $(CMOD)


# Rules
# =======================================================================

.SUFFIXES:
.SUFFIXES: .o$M$C .a$M .o$M .o .s .c

.s.o .s.o$M .s.a$M .s.o$M$C:
	mas $(ASFLAGS) $*.s -O=$@
.c.o .c.o$M:
	ocp68 $(CFLAGS) $< $*.i
	oc068 $*.i $*.1 $*.2 $*.3 -f
	oc168 $*.1 $*.2 $*.s
	mas -U $*.s -O=$@
	rm $*.i $*.1 $*.2 $*.s
#	oas68 -l -u -s c:\c\alcyon\lib\oas68sym.dat $<

#	lcc -c $(CFLAGS) -o$@ $<


# Targets
# =======================================================================

default:
	@echo	'use: make [C=[abcdfgiknstuw]] [M=[efptw]] [RAM=[01]] [MTOS=[01]] allbios'
	@echo	'C sets "country" (default $C):'
	@echo	'	a swf	f fra	k uk	t tur'
	@echo	'	b swg	g ger	n nor	u usa'
	@echo	'	c fin	i ita	s spa	w swe'
	@echo	'	d den'
	@echo	'M sets machine flags (default $M):'
	@echo	'	e ST/STe/Mega STe'
	@echo	'	f Falcon/040'
	@echo	'	p STpad (STBOOK)'
	@echo	'	t TT'
	@echo	'	w Sparrow (Falcon/030)'
	@echo	'RAM sets "systype": 0 rom, 1 ram (default $(RAM))'
	@echo	'MTOS 1 for the MultiTOS AES (default $(MTOS))'

# Objects not affected by country or machine switches
OBJ = dsp\dsp.o spsound\spsound.o prtblk.o xinout.o memtest.o vtg.o version.o

allbios: allbios.$R$M$C
allbios.$R$M$C:	startup.$R$M dmaread.o$M clock.o$M \
		bios.o$M$C flop.o$M rwabs.o$M $(OBJ)
	aln -u -u -p -w -l -o $@ $<
	@echo $@ linked.
# The build makefile now gets allbios from here
#	cp $@ ..\build

# Compiler dependent objects
vtg.o: vtg.c
	lcc -c -D_BIOS=1 -DSPARROW=$(MSP) -r0 -m3 $(COPT) $(CMOD) -o $@ $<
vdivtg.o: vtg.c
	lcc -c -DSPARROW=$(MSP) -r0 -m3 $(COPT) $(CMOD) -o $@ $<

#
# Independent objects
#
version.s: version	# always make version
version:
	biosvers version.s
prtblk.o: prtblk.c prtblkc.h
xinout.o: xinout.s
memtest.o: memtest.s

#
# Machine-dependent objects
#
startup.$R$M: startup.s
dmaread.o$M: dmaread.s
clock.o$M: clock.s
flop.o$M: flop.s

rwabs.o$M: rwabs.c

#
# Machine- and country-dependent objects
#
bios.o$M$C: bios.s
