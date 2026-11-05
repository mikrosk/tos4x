#!/bin/sh
# Makes boot/boottest.st (720 KB, FAT12, BOOTTEST.ACC only) with mtools from src/boottest.acc
# (cd src && make boottest.acc).
cd "$(dirname "$0")" || exit 1
rm -f boottest.st
mformat -C -i boottest.st -f 720 -N 19930308 :: && mcopy -m -i boottest.st ../src/boottest.acc ::BOOTTEST.ACC
