;
;	nosbind.s	trap calls for GEMDOS, BIOS & XBIOS
;
	.text
	.globl	_xbios
	.globl	_bios
	.globl	_gemdos

_xbios:
	movem.l	4(sp),d0-d2/a0-a2
	movem.l	d0-d2/a0-a2,-(sp)
	trap	#14
	add.l	#24,sp
	rts

_bios:
	movem.l	4(sp),d0-d2/a0-a2
	movem.l	d0-d2/a0-a2,-(sp)
	trap	#13
	add.l	#24,sp
	rts

_gemdos:
	movem.l	4(sp),d0-d2/a0-a2
	movem.l	d0-d2/a0-a2,-(sp)
	trap	#1
	add.l	#24,sp
	rts

	.end
