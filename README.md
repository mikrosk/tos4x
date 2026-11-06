This is the complete TOS 4 and MultiTOS source code history, as found in various archives available at
https://docs.dev-docs.org. Those archives contain not only the source files but, in the case of BIOS, GEMDOS and the
MultiTOS AES, also "RCS" folders with version control history going back as far as 1987 (although it broke in places,
as [docs/bios/0read.me](docs/bios/0read.me) describes; I was able to recover most of the lost content).

Part of the repository is a full build harness that recreates byte-exact builds (where Atari's binary survives):

| Tag               | Builds
|-------------------|-------------------------------------------------------------------------
| build/tos207      | TOS 2.07 (Sparrow)
| build/tos400      | TOS 4.00, SCREEN.PRG, SMSCREEN.PRG, USA.PRG
| build/tos401      | TOS 4.01, SCREEN.PRG, SMSCREEN.PRG, USA.PRG
| build/tos402      | TOS 4.02, SCREEN.PRG, SMSCREEN.PRG, USA.PRG
| build/gemsys100   | MultiTOS 1.00 GEM.SYS in six languages
| build/gemsys101   | MultiTOS 1.01 GEM.SYS in six languages
| build/tos404      | TOS 4.04, SCREEN.PRG, SMSCREEN.PRG, USA.PRG
| build/tos492      | TOS 4.92 (the RAM TOS of the beta boot floppy), DESK.PRG
| build/tos492rom   | TOS 4.92 as a ROM (never released), DESK.PRG
| build/gemsys108   | MultiTOS 1.08 GEM.SYS in five languages, DESK.PRG
| master            | TOS 4.05, SCREEN.PRG, SMSCREEN.PRG, USA.PRG, TOS 5.00, GEM.SYS 1.09 in five languages, DESK.PRG

`SCREEN.PRG`: the VDI as a program, with the blit routines working with and without Blitter

`SMSCREEN.PRG`: the ROM's VDI as a program (Blitter only)

`USA.PRG`: the single-TOS AES and desktop as a program, with all languages (despite its name)

`DESK.PRG`: the MultiTOS desktop as a program (it needs a 68030+ CPU)

All releases up to TOS 4.92 beta internally supported Swedish (although it hadn't been released in TOS ROMs due to
size constraints). Fixup commits after each release's tag give the Swedish resources the look of the other languages
and USA.PRG the Swedish resources; a commented `# Swedish:` block in each job builds them into the ROM.

# Building

Each tag above rebuilds its image(s) from the sources in its tree with Atari's original tools, which run inside the
Hatari emulator.

## Requirements

- Hatari, as `hatari` on the PATH, or name the binary in `HATARI` (`HATARI=/path/to/hatari build/build.sh ...`).
- A POSIX shell.
- mtools, only for the screen dump of the boot test (optional).

## Running a build

From the repository root:

```
build/build.sh tos         # TOS with the single-TOS AES
build/build.sh multitos    # TOS with the MultiTOS AES
build/build.sh gemsys      # MultiTOS GEM.SYS
build/build.sh desk        # the MultiTOS desktop as a program, DESK.PRG
```

Run without arguments, build.sh prints its usage; the table above says which products each tag has. The build runs
without a window and prints its progress. It takes a few minutes. Hatari takes every setting from `build/hatari.cfg`
and runs with `build/home` as its home folder, so your own Hatari configuration and NVRAM play no part.

- `-w` runs the build in a Hatari window instead.
- `-b <image>` (tos, multitos) then boots the built ROM and `<image>` and compares the two boots.

## Result

- `RESULT ok` means that every file in the job's checksum list (`build/TOS.LST`, `build/MULTITOS.LST`,
  `build/GEMSYS.LST` or `build/DESK.LST`) came out byte for byte as expected. On master the lists are empty; there
  it means that every step of the job ended without an error.
- The built image is `build/drives/d/rom/tos.img` (TOS), `build/drives/d/multitos/gem.sys` (GEM.SYS 1.08 and
  master; 1.00 and 1.01 make one per language, `gem_usa.sys` … `gem_swe.sys`) or `build/drives/d/multitos/desk.prg`
  (DESK.PRG).
- The full log is `build/drives/c/build.log`.

## Layout

- `build/` holds the host side: build.sh, boot.sh, hatari.cfg, the TOS 3.06 image the build machine boots,
  and the jobs (`*.JOB`) with their checksum lists (`*.LST`).
- `build/drives/c`, `d`, `m` and `s` are the build machine's drives C:, D:, M: and S:. S: is this repository.

## Tags

Each tag names a commit whose `build/build.sh` rebuilds the image(s) given, byte for byte where an original exists.
Example: `git checkout build/tos401 && build/build.sh tos`.

# History

Every release is a branch from master, merged by its `[RELEASE]` commit:

- "Import files for ...": Atari's files up to the release date.
- "Apply uncommitted changes": the edits a later RCS check-in holds, which the release was built with.
- "Import files for reconstruction": Atari's files dated after the release, which my edits start from.
- "Modify files for 1:1 byte match": my edits; the message names where each file I wrote comes from.
- "Build harness": the jobs and tools.
- Fixups, then the merge. The tag points to the last commit before the fixups, or to the merge where there are none.

"[DOCS] Various developer docs / resources" puts the documents, development logs and Sparrow sources no release builds
from under docs/, with their paths in the repository.

"[FILE] Intermediate AES files between TOS 4.01 and 4.02" and "[FILE] AES changes after TOS 4.04" put the single-TOS
AES files no release was built from at their paths.

The branches archive, lattice/multitos, lattice/pixvdi and rcs/* keep the archive copies and the RCS
side branches; the RCS symbolic names are tags. They are preserved for historical reasons only.

## Known limits of master

- TOS 5.00 leaves Spanish out (it does not fit; a commented block in the job puts it back) and has no Swedish.
- TOS 5.00 in 4 colours, as TOS 4.92: when NEWDESK.INF starts a program (#Z), neither the program nor the desktop
  icons appear, and drive windows don't open.

# Credits

TOS 2.07's non-BIOS parts come from Thorsten Otto's TOS 2.06 reconstruction, https://github.com/th-otto/tos3x.
