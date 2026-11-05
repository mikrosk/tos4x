| Startup for the boot test accessory: the AES starts an accessory with its basepage
| in a0 and no stack of its own; the accessory never returns.
	.text
	.globl	__start
__start:
	lea	stacktop,sp
	jsr	_acc_main
hang:	bra.s	hang
	.globl	_get_sysbase
_get_sysbase:
	move.l	0x4f2,d0
	rts
	.bss
	.ds.b	8192
stacktop:
