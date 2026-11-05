# TOS 4.92 RAM TOS image: loader, BIOS, VDI, GEMDOS and AES linked at $F8E0, data after the text,
# bss at $400. No Atari build file for the RAM TOS survives; part order, addresses and the glue
# are read from tos492.img. The job then writes text and data to tos.img (ramimg).

PARTS = glue0.o allbios.awu smvdi.o gemdos.030 glue1.o aes40usa.o glue2.o

tos.abs: $(PARTS)
	aln -a f8e0 xt 400 -o tos.abs $(PARTS)

glue0.o: glue0.s
	mac glue0.s

glue1.o: glue1.s
	mac glue1.s

glue2.o: glue2.s
	mac glue2.s
