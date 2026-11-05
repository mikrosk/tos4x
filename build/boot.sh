#!/bin/sh
# Boot test: boot.sh <image> [result file]
# Boots <image> as the TOS of an emulated Falcon from the floppy image boot/boottest.st,
# whose BOOTTEST.ACC (source: src/boottest.c) runs GEMDOS file and memory calls on A:,
# waits for the desktop and reports a CRC-32 of the screen.  The BOOTTEST lines go to
# stdout (and to the result file); the exit code is 0 when the report is complete and
# has no failure.  With mtools the screen comes back as <result file>.raw, and as
# <result file>.pbm for a 640x400 monochrome screen.  Hatari runs headless with its own HOME, so no user configuration or
# NVRAM file takes part; HATARI names the emulator binary (default: hatari).
[ -f "$1" ] || { echo "usage: boot.sh <image> [result file]" >&2; exit 2; }
img=$(cd "$(dirname "$1")" && pwd)/$(basename "$1")
out=
[ -n "$2" ] && out=$(cd "$(dirname "$2")" && pwd)/$(basename "$2")
cd "$(dirname "$0")" || exit 1
HATARI=${HATARI:-hatari}
w=$(mktemp -d "$PWD/boot/run.XXXXXX") || exit 2
cp boot/boottest.st "$w/a.st"
mkdir -p "$w/home"
HOME="$w/home" SDL_VIDEODRIVER=dummy SDL_AUDIODRIVER=dummy timeout 300 \
	"$HATARI" --configfile boot/boot.cfg --machine falcon --tos "$img" --disk-a "$w/a.st" \
	> "$w/hatari.out" 2>&1
grep '^BOOTTEST' "$w/hatari.out" > "$w/result"
cat "$w/result"
if [ -n "$out" ]; then
	cp "$w/result" "$out"
	if command -v mcopy >/dev/null && mcopy -n -i "$w/a.st" ::SCREEN.RAW "$out.raw" 2>/dev/null; then
		if grep -q '^BOOTTEST screen mode ..[0-9a-f]8 bytes 32000 ' "$w/result"; then
			{ printf 'P4\n640 400\n'; cat "$out.raw"; } > "$out.pbm"
		fi
	fi
fi
rc=1
grep -q '^BOOTTEST END fails 0$' "$w/result" && ! grep -q ' FAIL ' "$w/result" && rc=0
[ $rc = 0 ] && rm -rf "$w" || echo "boot test failed, see $w/hatari.out" >&2
exit $rc
