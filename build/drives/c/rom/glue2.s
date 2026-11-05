; GEM magic block (os_magic points here): magic, end of the memory the OS uses (for a RAM TOS the
; end of the image), AES start. TOS.IMG ends with the 4 bytes after endaesbss.
	.globl	the_magic
	.globl	endaesbss
	.globl	gemstart
	.text
the_magic:
	dc.l	$87654321
	dc.l	endaesbss
	dc.l	gemstart
	.data
endaesbss:
	dc.b	'kbad'
