*------------------------------------------------------------------------
*									:
*	Boot sector							:
*	Loads OS.IMG from the disk and executes it.			:
*									:
*	(C)1985 Atari Corp.						:
*									:
* 25-Feb-1985 lmd	Hey!  It fits in 512 bytes....			:
*  2-Apr-1985 lmd	Fixed bugs (it works now)			:
*									:
*------------------------------------------------------------------------
	text

maxread		equ	64

*
* BPB fields:
*
recsiz	equ	0			; size of a sector in bytes
clsiz	equ	2			; number of sectors/cluster
clsizb	equ	4			; size of a cluster in bytes
rdlen	equ	6			; root directory length
fsiz	equ	8			; size of a FAT (in sectors)
fatrec	equ	10			; start of 2nd FAT
datrec	equ	12			; sector# of first data sector
numcl	equ	14			; number of clusters on media
bflags	equ	16			; flags


*
* OS variables:
*
_v_bas_ad	equ	$44e		; pointer to screen memory
_membot		equ	$432		; pointer to bottom of memory
_memtop		equ	$436		; pointer to top of memory
_cmdload	equ	$482		; load-command switch
bootdev		equ	$446		; default boot device


*
* Executable code,
* random garbage,
* and a serial number:
*
	bra.s	start			; branch to code
	dc.b	'Loader'		; name of the loader
	dc.b	$00,$00,$00		; 24-bit serial number

*
* 80 track, single-sided BPB
* (Identical to "DG-1" BPB)
*
	dc.b	$00,$02			; #bytes/sector
	dc.b	$02			; #sectors/cluster
	dc.b	$01,$00			; #reserved sectors
	dc.b	$02			; #of FATs
	dc.b	$70,$00			; #of root directory entries
	dc.b	$d0,$02			; #of sectors on media
	dc.b	$f8			; media descriptor byte
	dc.b	$05,$00			; #sectors/FAT
	dc.b	$09,$00			; #sectors/track
	dc.b	$01,$00			; #sides on media
	dc.b	$00,$00			; #hidden sectors

	even
*
* Boot parameters
*
execflg:	dc.w	0		; copied to _cmdload
ldmode:		dc.w	0		; 0:load file, 1:load sectors
ssect:		dc.w	0		; starting sector# to load
nsects:		dc.w	0		; #sectors to load
dummy:		dc.l	0		; space holder
ldaddr		equ	_membot		; load address basepage
fatbuf:		dc.l	$8000		; good place for FAT/directory buffer
fname:		dc.b	"DOS     SYS"	; filename to load (11 chars)
	even


*+
* Neuter Booter
*
* Register usage:
*	A6 -> FAT buffer
*	A5 -> BPB
*	A4 -> directory/load buffer
*	A3 -> current read address
*	A0..A2 used by traps
*
*	D7 = current cluster number
*	D6 = starting sector/sector number
*	D5 = ending sector
*	D4 = sector count
*	D3 = current sector
*	D0..D2 used by traps
*-
start:
	move.w	execflg(pc),_cmdload	; set command-load flag

	pea	msg(PC)
	move.w	#$9,-(sp)
	trap	#1
	addq	#6,sp

*----- Get BPB for boot device:
	move.w	bootdev,-(sp)		; d0 = getbpb(bootdev)
	move.w	#7,-(sp)
	trap	#13
	addq	#4,sp
	tst.l	d0			; if(d0 == NULL) return;
	beq	_fail			; (I give up)
	move.l	d0,a5			; a5 -> BPB

	nop;;
	lea	fatbuf(pc),a0		; use top of memory for FAT buffer
	clr.l	d0
	move.w	fsiz(a5),d0		; get number of bytes: fsiz+rdlen
	add.w	rdlen(a5),d0
	moveq	#9,d1
	asl.l	d1,d0			; records -> bytes
	move.l	_memtop,d1
	sub.w	d0,d1
	move.l	d1,(a0)			; store as fatbuf

;	move.l	_v_bas_ad,(a0)

	move.w	fsiz(a5),d0		; a4 = fatbuf + (a5[fsiz] << 9)
	lsl.w	#8,d0
	add.l	d0,d0
	move.w	d0,a4
	add.l	fatbuf(pc),a4		; a4 -> directory buffer

*----- Read FAT and directory sectors into memory:
	move.w	fatrec(a5),d6		; start = 2nd FAT
	move.w	fsiz(a5),d4		; count = a5[fsiz] + a5[rdlen]
	add.w	rdlen(a5),d4
	move.l	fatbuf(pc),a3		; address = the FAT buffer
	bsr	readmult		; read sectors

*----- Setup to search for the image file:
	move.l	a4,a0			; a0 -> directory buffer
	move.w	rdlen(a5),d0
	lsl.w	#8,d0
	lsl.w	#1,d0			; a0 += rdlen * 512
	lea	(a0,d0.w),a0		; a0 -> end of directory buffer
	lea	fname(pc),a1		; a1 -> file to open

*----- Search directory (backwards):
b_3:	sub.w	#$20,a0			; backup one directory entry
b_1:	cmp.l	a4,a0			; if(a0 < a4) then fail
	blt	_fail			; (file not found, so punt)
	moveq	#10,d0			; d0 = dbra length of file name
b_2:	move.b	(a0,d0.w),d1		; compare filename
	cmp.b	(a1,d0.w),d1
	bne	b_3			; try next entry on match failure
	dbra	d0,b_2			; (try all chars)

*----- Get (byte-reversed) cluster number:
	moveq	#0,d7			; get starting cluster number
	move.b	27(a0),d7		; from byte-reversed entry in
	lsl.w	#8,d7			; the directory entry
	move.b	26(a0),d7

*----- Setup for reading the file:
	move.l	fatbuf(pc),a6		; a6 -> FAT
	move.l	_membot,a3		; a3 -> read address basepage
	add.w	#$100,a3		; a3 now -> real read address
	clr.l	d4			; no sector count

*+
* Read the file.
* Read as many sectors as possible at once (try to suck it
* in with one rwabs call...)
*
*-

*----- compute sector number from cluster number:
l_1:	cmp.w	#$0ff0,d7		; end of chain?
	bge	l_done			; (yes)

	move.w	d7,d3			; d3 = d7 - 2
	subq	#2,d3
	mulu	clsiz(a5),d3		; d3 *= clsiz
	add.w	datrec(a5),d3		; d3 += datrec

*----- if "break" in chain of sectors, read some in:
	cmp.w	#maxread,d4		; if(d4 >= maxread) read_sectors....
	bge	l_5
	tst.w	d4			; any old sectors?
	beq	l_4			; (no)
	cmp.w	d5,d3			; can this one be appended?
	beq	l_3			; (yes)
l_5:	bsr	readmult		; read old sectors

	lsl.l	#8,d4			; a3 += count * 512
	lsl.l	#1,d4
	add.l	d4,a3

*----- startup a new chunk of contiguous sectors:
l_4:	move.w	d3,d6			; start = current sector
	move.w	d3,d5			; end = current sector
	clr.l	d4			; count = 0
l_3:	add.w	clsiz(a5),d4		; append current sector to
	add.w	clsiz(a5),d5		; the contiguous chunk

*----- compute next cluster number:
	move.w	d7,d2			; d2 = (d7 >> 1) + d7
	lsr.w	#1,d2
	add.w	d7,d2
	move.b	1(a6,d2.w),d1		; get high byte
	lsl.w	#8,d1			; shift it up
	move.b	(a6,d2.w),d1		; get low byte (d1 = raw cluster entry)
	btst	#0,d7			; if(d7 & 1) d1 >>= 4
	beq	l_2
	lsr.w	#4,d1
l_2:	and.w	#$0fff,d1		; d1 &= $0fff
	move.w	d1,d7			; d7 = d1
	bra	l_1			; read next cluster

*----- read any leftover sectors:
l_done:	tst.w	d4			; any sectors left?
	beq	ld_ex			; (nothing more to read)
	bsr	readmult		; read remainder (usu. entire file)

*----- jump to the base of the loaded file
ld_ex:	move.l	_membot,-(sp)		; push basepage address
	move.l	_membot,a0		; jsr to stuff we just loaded
	add.w	#$100,a0
	jsr	(a0)
	addq.w	#4,sp
	rts

*----- could not boot: complain
_fails:	tst.l	(sp)+			; return to boot ROM
_fail:	clr.l	d0			; error = 0
	rts


*+
* Read sectors from boot device
* Passed:	d6 = logical sector number
*		d4 = count
*		a3 -> address
*
* Returns:	NE: failure
*		EQ: success
*-
readmult:
	move.w	bootdev,-(sp)		; device = bootdev
	move.w	d6,-(sp)		; record = d6
	move.w	d4,-(sp)		; count = d4
	move.l	a3,-(sp)		; addr = a3
	clr.w	-(sp)			; operation = READ
	move.w	#4,-(sp)		; function = rwabs
	trap	#13			; bios trap
	add.w	#14,sp			; cleanup stack
	tst.w	d0			; test return code
	bne	_fails			; return to boot ROM with error	
read1:	rts				; byebye

msg:	dc.b	"Loading DOS.SYS",0
