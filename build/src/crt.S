| Minimal startup for the file commands: no C library, so the inherited
| standard handles are never closed (TOS children share them with the parent).
	.text
	.globl	__start
__start:
	move.l	4(sp),a0
	move.l	a0,_bp
	lea	stacktop,sp
	move.l	0xc(a0),d0
	add.l	0x14(a0),d0
	add.l	0x1c(a0),d0
	add.l	#0x100,d0
	move.l	d0,-(sp)
	move.l	a0,-(sp)
	clr.w	-(sp)
	move.w	#0x4a,-(sp)
	trap	#1
	lea	12(sp),sp
	jsr	_tool_main
	move.w	d0,-(sp)
	move.w	#0x4c,-(sp)
	trap	#1
	.bss
	.globl	_bp
_bp:	.ds.l	1
	.ds.b	4096
stacktop:
