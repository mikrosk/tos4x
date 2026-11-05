# Host build of the runner and the file commands with m68k-atari-mint-gcc.
# The binaries are committed in build/drives/c/auto and build/drives/c/util.
CC = m68k-atari-mint-gcc
CFLAGS = -O2 -s -Wall
TOOLFLAGS = $(CFLAGS) -nostdlib -nostartfiles -fno-builtin

all: runner.prg rm.ttp cp.ttp mv.ttp echo.ttp egrep.ttp boottest.acc

runner.prg: runner.c
	$(CC) $(CFLAGS) -o $@ runner.c

rm.ttp: crt.S tools.c
	$(CC) $(TOOLFLAGS) -DTOOL_RM -o $@ crt.S tools.c -lgcc
cp.ttp: crt.S tools.c
	$(CC) $(TOOLFLAGS) -DTOOL_CP -o $@ crt.S tools.c -lgcc
mv.ttp: crt.S tools.c
	$(CC) $(TOOLFLAGS) -DTOOL_MV -o $@ crt.S tools.c -lgcc
echo.ttp: crt.S tools.c
	$(CC) $(TOOLFLAGS) -DTOOL_ECHO -o $@ crt.S tools.c -lgcc
egrep.ttp: crt.S tools.c
	$(CC) $(TOOLFLAGS) -DTOOL_EGREP -o $@ crt.S tools.c -lgcc

boottest.acc: acc.S boottest.c
	$(CC) $(TOOLFLAGS) -m68020 -o $@ acc.S boottest.c -lgcc
