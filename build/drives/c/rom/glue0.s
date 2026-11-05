; RAM TOS loader, the first 34 bytes of TOS.IMG: copies the image behind it (OS header on) to
; os_beg, the address the OS is linked for, up to endaesbss, and starts it there.
	.globl	endaesbss
	.text
	move.w	#$2700,sr
	lea	osimg(pc),a0
	move.l	8(a0),a1		; os_beg
	move.l	a1,a2
	move.l	#endaesbss,a3
copy:	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	cmp.l	a3,a1
	blt	copy
	jmp	(a2)
osimg:
