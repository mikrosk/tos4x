# switches.mk - include file for BIOS makefile
# =======================================================================
# 920701 kbad

#########################################################################
# The following macros set `systype', `country',  and machine flags
# in $(ASFLAGS) for BIOS assembly.  They also set $(CDEF) for rwabs.c.
#
# The following options can be set on the command line, or
# in the main makefile.  Look for 'default:' in this file to see
# the current default values.
# -----------------------------------------------------------------------
# C=[abcdfgiknstuw]	(sets 'country')
#	a swissfra	g germany	s spain
#	b swissger	i italy		t turkey
#	c finland	k uk		u usa
#	d denmark	n norway	w sweden
#	f france
# used: abcd fg i k  n    stu w
# free:     e  h j lm opqr   v xyz0123456789
# -----------------------------------------------------------------------
# M=[eptw]		(sets TT, SPARROW, STPAD, USE_DISK_CHANGE)
#	e ST/STe/Mega STe
#	f Falcon/040
#	p STpad (STBOOK)
#	t TT
#	w Sparrow (Falcon/030)
# -----------------------------------------------------------------------
# RAM=[01]		(sets 'systype')
#	0 rom
#	1 ram
#########################################################################

#
# Country codes
# These must match the values in switches.s
#
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

#
# Machine switches, set TT, SPARROW, STPAD, USE_DISK_CHANGE
#
ifndef M
M=e		    # default: ST/STe/MegaSTe
endif

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
DCHANGE = 1
endif

#
# ROM/RAM flag, sets `systype' (switches.s: rom=0, ram=1)
#
ifndef RAM
RAM=0		    # default: ROM build
endif

#
# Finally, set assembler and compiler flags from the above
#
ASFLAGS = -3 -8 -S -D=country=$(CNUM) -D=systype=$(RAM) \
	-D=TT=$(MTT) -D=SPARROW=$(MSP) -D=STPAD=$(MPD)

# For CFLAGS = $(CDEF) $(CERR) $(COPT) $(CMOD)
CDEF = -DUSE_DISK_CHANGE=$(DCHANGE)
