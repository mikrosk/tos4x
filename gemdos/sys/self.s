	.include atari

;+
;  Executable file structure
;
;-
	.ABS
MAGIC:		ds.w    1		; 0x601a
TSIZE:		ds.l    1		; size of text
DSIZE:		ds.l    1		;	data
BSIZE:		ds.l    1		;	BSS
SSIZE:		ds.l    1		;	symbol table
		ds.w	5		;
TSTART	   	 =	*		; start of text
		.assert * = $1c
	.TEXT

;+
;  Get control from relocator.
;
;-
Start	equ	*-TSTART
	lea	Start(pc),a2		; a2 -> base of .PRG file we are
	cmp.w	#$601a,(a2)		; magic number match?
	bne	.fallthrough		; (no -- already relocated)
;
;  Loaded from boot floppy
;
	move.l	a2,a1			; A1 -> base of text
	lea.l	-$100(a2),a3		; A3 -> basepage we will build
	move.l	a3,(a3)			; Build basepage: self pointer
	move.l	_memtop,4(a3)
	move.l	a1,8(a3)		; text base
	move.l	TSIZE(a2),$c(a3)	; text size
	add.l	#TSTART,$c(a3)		; (plus header size)
	add.l	#TSTART,a1		; add header size to a1
	move.l	a1,d1			; save this as text base.
	move.l	a1,a0			; start applying fixups from here.
	add.l	TSIZE(a2),a1		; bump a1 by text size
	move.l	a1,$10(a3)		; data base
	move.l	DSIZE(a2),$14(a3)	; data size
	add.l	DSIZE(a2),a1		; add data size
	move.l	a1,$18(a3)		; bss base
	move.l	BSIZE(a2),$1c(a3)	; bss size
	add.l	SSIZE(a2),a1		; add symbol table size to offset ptr

	tst.l	(a1)			; if (*A1 == NULL)
	beq.s	.1			;	then no_fixups_to_do;

	moveq	#0,d0			; wipe-out upper bits of d0
	add.l	(a1)+,a0		; A0 -> first fixup

.2:	add.l	d1,(a0)			; add text base to longword at a0
.4:	move.b	(a1)+,d0		; get next fixup byte
	beq.s	.1			; if (d0 == 0) we're finished;
	cmp.b	#1,d0			; if (d0 == 1) a0 += 0xfe;
	bne.s	.3
	add.w	#$00fe,a0		; (bump a0)
	bra.s	.4			; (get next reloc byte -- don't fixup)
.3:	add.w	d0,a0			; a0 += d0
	bra.s	.2			; (fixup and get next reloc byte)
.1:
	; CLEAR MY BSS

	move.l	$18(a3),a0		; get BSS base
	move.l	$1c(a3),d0		; get bss size
	asr.l	#1,d0			; get size in words
	bra.s	.clrend			; bra to end of loop

.clrloop:
	clr.w	(a0)+
.clrend:
	dbra	d0,.clrloop

;+
;  Fall through to the next object file.  It had better be
;  something prepared to handle it.
;-

.fallthrough:
