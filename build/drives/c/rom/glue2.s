; GEM magic block (os_magic points here): magic, end of the AES bss, AES start
	.globl	the_magic
	.globl	endaesbss
	.globl	gemstart
	.text
the_magic:
	dc.l	$87654321
	dc.l	endaesbss
	dc.l	gemstart
	.bss
endaesbss:
