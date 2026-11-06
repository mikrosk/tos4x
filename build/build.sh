#!/bin/sh
# Build TOS 4 with the single-TOS AES or with the MultiAES, or MultiTOS GEM.SYS, in Hatari with the
# original Atari tools.
#   build/build.sh tos|multitos|gemsys|desk    without a window: progress on stdout, Hatari exits when done
#   build/build.sh tos|multitos|gemsys|desk -w in a Hatari window (Hatari waits for a key at the end)
#   build/build.sh tos|multitos -b <image>     then boot the built ROM and <image> (boot.sh) and compare
# The job is TOS.JOB, MULTITOS.JOB, GEMSYS.JOB or DESK.JOB, its expected checksums TOS.LST,
# MULTITOS.LST, GEMSYS.LST or DESK.LST; they are copied to drives/c/BUILD.JOB and
# drives/c/EXPECT.LST, which the runner reads.  Starting Hatari by hand from build/ works too,
# after that copy:  hatari --configfile hatari.cfg
# HATARI names the emulator binary (default: hatari).  Outputs land in build/drives/d (the ROM
# in build/drives/d/rom/tos.img, GEM.SYS in build/drives/d/multitos/gem.sys), the log in
# build/drives/c/build.log.  check C:\EXPECT.LST must find every file identical, the ROM or
# GEM.SYS among them; every program the job runs (x) must end with 0 and no step with a negative code.
case "$1" in
tos) job=TOS ;;
gemsys) job=GEMSYS ;;
multitos) job=MULTITOS ;;
desk) job=DESK ;;
*) echo "usage: build.sh tos|multitos|gemsys|desk [-w] | build.sh tos|multitos -b <reference image>" >&2; exit 2 ;;
esac
shift
ref=
if [ "$1" = -b ]; then
	[ -f "$2" ] || { echo "usage: build.sh tos|multitos -b <reference image>" >&2; exit 2; }
	ref=$(cd "$(dirname "$2")" && pwd)/$(basename "$2")
fi
cd "$(dirname "$0")" || exit 1
HATARI=${HATARI:-hatari}
rm -f drives/c/build.log hatari.out drives/c/headless boot.src boot.ref
cp "$job.JOB" drives/c/BUILD.JOB && cp "$job.LST" drives/c/EXPECT.LST || exit 1
# Hatari runs with its own HOME, so no user configuration or NVRAM file takes part
rm -rf home && mkdir home || exit 1
if [ "$1" = -w ]; then
	exec env XAUTHORITY="${XAUTHORITY:-$HOME/.Xauthority}" HOME="$PWD/home" "$HATARI" --configfile hatari.cfg
fi
: > drives/c/headless
HOME="$PWD/home" SDL_VIDEODRIVER=dummy SDL_AUDIODRIVER=dummy "$HATARI" --configfile hatari.cfg --conout 2 \
	> hatari.out 2>&1 &
pid=$!
shown=0
idle=0
while kill -0 $pid 2>/dev/null; do
	sleep 2
	if [ -f drives/c/build.log ]; then
		n=$(wc -l < drives/c/build.log)
		if [ "$n" -gt "$shown" ]; then
			tail -n +"$((shown + 1))" drives/c/build.log | head -n "$((n - shown))" | tr -d '\r' |
				grep -E '^(B [0-9]+ (x|echo)|DIFFERS|MISSING|CHECK|DONE)' | sed 's/^B [0-9]* //'
			shown=$n
			idle=0
		else
			idle=$((idle + 2))
		fi
	fi
	if [ $idle -ge 1800 ]; then
		echo "no progress for 30 minutes, stopping Hatari" >&2
		kill $pid
		break
	fi
done
wait $pid 2>/dev/null
rm -f drives/c/headless
grep -q '^DONE' drives/c/build.log 2>/dev/null || { echo "build did not finish, see build/drives/c/build.log" >&2; exit 1; }
rc=0
tr -d '\r' < drives/c/build.log | grep -q '^CHECK C:\\EXPECT.LST identical [0-9]* differs 0 missing 0$' || rc=1
failed=$(tr -d '\r' < drives/c/build.log | awk '/^B [0-9]+ /{s = $0; sub(/^B [0-9]+ /, "", s); b[$2] = s}
	/^E [0-9]+ /{if (($3 != 0 && b[$2] ~ /^x /) || $3 < 0) print "  exit " $3 ": " b[$2]}')
if [ -n "$failed" ]; then
	echo "steps that ended with an error:" >&2
	echo "$failed" >&2
	rc=1
fi
if [ -z "$ref" ]; then
	[ $rc = 0 ] && echo "RESULT ok" || echo "RESULT failed"
	exit $rc
fi
echo "boot test: built ROM"
./boot.sh drives/d/rom/tos.img boot.src > /dev/null || rc=1
echo "boot test: $ref"
./boot.sh "$ref" boot.ref > /dev/null || rc=1
grep -v '^BOOTTEST info' boot.ref > boot.ref.cmp
grep -v '^BOOTTEST info' boot.src > boot.src.cmp
if [ -s boot.ref.cmp ] && cmp -s boot.ref.cmp boot.src.cmp; then
	echo "boot test: the built ROM boots like the reference"
else
	echo "boot test: the reports differ:" >&2
	diff boot.ref boot.src >&2
	rc=1
fi
rm -f boot.ref.cmp boot.src.cmp
[ $rc = 0 ] && echo "RESULT ok" || echo "RESULT failed"
exit $rc
