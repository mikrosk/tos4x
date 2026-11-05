# TOS 2.07 ROM image: BIOS, VDI, GEMDOS and the AES (with desktop and resource glue, linked first into
# one object that exports gemstart only, as the TOS 4 makeimg does) at $E00000, data after the text, bss
# at $400.  No Atari build file for this ROM survives; part order (= the tos3x 2.06 link order),
# addresses and the glue are read from tos207.rom.

BIOS = ..\bios\startup.wo \
	..\bios\dmaread.w \
	..\bios\clock.w \
	..\bios\bios.wu \
	..\bios\flop.w \
	..\bios\prtblk.o \
	..\bios\rwabs.o \
	..\bios\xinout.o \
	..\bios\memtest.o \
	..\bios\version.o

VDI = ..\vdi\escape.o \
	..\vdi\font6x6.o \
	..\vdi\font8x8.o \
	..\vdi\font8x16.o \
	..\vdi\entry.o \
	..\vdi\tables.o \
	..\vdi\line1010.o \
	..\vdi\gsxasm1.o \
	..\vdi\allgem.o \
	..\vdi\blitinit.o \
	..\vdi\routines.o \
	..\vdi\jmptbl.o \
	..\vdi\isin.o \
	..\vdi\monobj.o \
	..\vdi\opnwk.o \
	..\vdi\monout.o \
	..\vdi\text.o \
	..\vdi\textblt.o \
	..\vdi\hbtxtblt.o \
	..\vdi\mono.o \
	..\vdi\hbmono.o \
	..\vdi\gsxasm2.o \
	..\vdi\hbrect.o \
	..\vdi\mouse.o \
	..\vdi\copyrfm.o \
	..\vdi\blastman.o \
	..\vdi\hbbitblt.o \
	..\vdi\blaster.o \
	..\vdi\seedfill.o \
	..\vdi\xfrmform.o \
	..\vdi\stcolor.o \
	..\vdi\sbblit.o \
	..\vdi\sbfrag.o \
	..\vdi\sbescape.o \
	..\vdi\sbhline.o \
	..\vdi\sbvline.o \
	..\vdi\sbmono.o \
	..\vdi\sbtxtblt.o \
	..\vdi\cbssdefs.o

GEMDOS = ..\bdos\osinit.o \
	..\bdos\lmul.o \
	..\bdos\ldiv.o \
	..\bdos\xfer.o \
	..\bdos\console.o \
	..\bdos\fsfat.o \
	..\bdos\fsglob.o \
	..\bdos\fsdir.o \
	..\bdos\fsopnclo.o \
	..\bdos\fshand.o \
	..\bdos\fsmain.o \
	..\bdos\fssupp.o \
	..\bdos\proc.o \
	..\bdos\umem.o \
	..\bdos\osmem.o \
	..\bdos\bdosmain.o \
	..\bdos\sup.o \
	..\bdos\time.o

AES = ..\aes\gemjstrt.o \
	..\aes\gemaints.o \
	..\aes\gemaplib.o \
	..\aes\gemasync.o \
	..\aes\gembase.o \
	..\aes\gembind.o \
	..\aes\gemcli.o \
	..\aes\gemctrl.o \
	..\aes\gemdisp.o \
	..\aes\gemevlib.o \
	..\aes\gemflag.o \
	..\aes\gemfmalt.o \
	..\aes\gemfmlib.o \
	..\aes\gemfslib.o \
	..\aes\gemglobe.o \
	..\aes\geminit.o \
	..\aes\geminput.o \
	..\aes\gemmnlib.o \
	..\aes\gemobed.o \
	..\aes\gemobjop.o \
	..\aes\gempd.o \
	..\aes\gemqueue.o \
	..\aes\gemrom.o \
	..\aes\gemrslib.o \
	..\aes\gemsclib.o \
	..\aes\gemshlib.o \
	..\aes\gemwmlib.o \
	..\aes\gemwrect.o \
	..\aes\romcart.o \
	..\aes\gemoblib.o \
	..\aes\apgrlib.o \
	..\aes\apgsxif.o \
	..\aes\gemgrlib.o \
	..\aes\gemgsxif.o \
	..\aes\gsx2.o \
	..\aes\jbind.o \
	..\aes\jdispa.o \
	..\aes\jdos.o \
	..\aes\large.o \
	..\aes\optimize.o \
	..\aes\ratrbp.o \
	..\aes\trap14.o \
	..\desk\deskact.o \
	..\desk\deskapp.o \
	..\desk\deskbind.o \
	..\desk\deskbutt.o \
	..\desk\deskdir.o \
	..\desk\deskdisk.o \
	..\desk\deskfile.o \
	..\desk\deskinf.o \
	..\desk\deskins.o \
	..\desk\deskmem.o \
	..\desk\deskmenu.o \
	..\desk\deskmisc.o \
	..\desk\deskopen.o \
	..\desk\deskpref.o \
	..\desk\desksear.o \
	..\desk\desksele.o \
	..\desk\deskshel.o \
	..\desk\deskshow.o \
	..\desk\deskrsc.o \
	..\desk\deskstor.o \
	..\desk\desktop.o \
	..\desk\deskupda.o \
	..\desk\deskwin.o \
	..\desk\deskif.o \
	..\desk\osbind.o

tos.abs: $(BIOS) glue1.o $(VDI) $(GEMDOS) ttaesusa.o glue2.o
	aln -a e00000 xt 400 -o tos.abs $(BIOS) glue1.o $(VDI) $(GEMDOS) ttaesusa.o glue2.o

ttaesusa.o: glue3.o $(AES) glue.usa
	aln -w -k gemstart -q -o ttaesusa.o glue3.o $(AES) -i glue.usa _tosrsc

glue3.o: glue3.s
	mac glue3.s

glue1.o: glue1.s
	mac glue1.s

glue2.o: glue2.s
	mac glue2.s
