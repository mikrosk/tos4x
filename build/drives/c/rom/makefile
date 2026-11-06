# TOS ROM image: BIOS, VDI, GEMDOS and AES linked at $E00000, data after the text,
# bss at $400, as the TOS 4.04 ROM. AES names the AES object: make AES=ttaesusa.o (aes/,
# TOS 4.05) or make AES=aes40usa.o (multitos/, TOS 5.00). The job then writes text and
# data to tos.img, fills it with $FF to 512 KB and appends the CRC-16 (romimg).

PARTS = allbios.owu smvdi.o gemdos.030 glue1.o $(AES) glue2.o

tos.abs: $(PARTS)
	aln -a e00000 xt 400 -o tos.abs $(PARTS)

glue1.o: glue1.s
	mac glue1.s

glue2.o: glue2.s
	mac glue2.s
