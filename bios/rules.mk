# rules.mk - rules include file for BIOS makefile
# =======================================================================
# 920702 kbad

# There's a rule for each possible combination of countries, machines,
# and ram/rom for startup.

# You can add "-s c:\alcyon\lib\oas68sym.dat" or whatever to the as68 line.
# You can also add "optimize $*.s" before oas68, except that it doesn't
# work with memory protection on.

.c.o:
	ocp68 $(CFLAGS) $*.c $*.i
	oc068 $*.i $*.1 $*.2 $*.3 -f
	oc168 $*.1 $*.2 $*.s
	oas68 -l -u -s c:\c\alcyon\lib\oas68sym.dat $*.s
	rm $*.i $*.1 $*.2 $*.s

# Machine-dependent C objects (rwabs.c)
.c.wo:
	ocp68 $(CFLAGS) -DUSE_DISK_CHANGE=1 $*.c $*.i
	oc068 $*.i $*.1 $*.2 $*.3 -f
	oc168 $*.1 $*.2 $*.s
	oas68 -l -u -s c:\c\alcyon\lib\oas68sym.dat $*.s
	rm $*.i $*.1 $*.2 $*.s

