*
* pkgboot.s: place a package in RAM and reboot.
*
* The package is the boot sector for loading GEMDOS off floppies,
* with code changes for 16-bit FATs and using the boot device
* (established at run-time) rather than Drive A:.
*
* When this code reboots, the package gets jumped to during the
* boot process and GEMDOS (really DOS.SYS) gets loaded & installed.
*
* The boot sector loads the FAT and root directory into a buffer
* which ends at _memtop, and loads the image file starting at _membot+$100.
* This package, then, must live in between.  How do you define "in between?"
* Well, I've decided it must be at least 256K above _membot and at least
* 128K below _memtop.  That should leave room for even the largest FAT+root.
*
* Because it goes to IPL 7, there's no risk of clobbering anything else
* in the system.  Well, there is some risk if there's something on the
* resvector chain that gets clobbered, but hey, you asked for it.  If
* a place within my own TPA satisfies the above criteria, there's no risk.
*

*
* OS variables:
*
_membot		equ	$432		; pointer to bottom of memory
_memtop		equ	$436		; pointer to top of memory
bootdev		equ	$446		; default boot device
_cmdload	equ	$482		; load-command switch
_sysbase	equ	$4f2		; base of os header

	move.l	4(sp),a6		; get my basepage address
	clr.l	-(sp)			; Go to super mode
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp

*	or.w	#$0700,sr		; go to IPL 7 (forever)

	move.l	_membot,d0
	add.l	#(256*1024),d0
	move.l	_memtop,d1
	sub.l	#(128*1024),d1
	cmp.l	d1,d0			; if (membot+256K) < (memtop-128K)
	bpl	badnews			; then fail

	move.l	$18(a6),d2
	add.l	$1c(a6),d2		; d2 -> base of my heap
	cmp.l	d2,d0			; if that's too low...
	bpl	toolow			; deal with it
	cmp.l	d2,d1			; if that's too high...
	bmi	toohigh			; deal with that
	move.l	d2,a0			; else put it at base of heap
	bra	inplace

badnews:
	pea	badmsg(pc)
	move.w	#$9,-(sp)
	trap	#1
	addq.l	#6,sp
	rts

badmsg:	dc.b	"Too little memory for safe package positioning\r\n",0
	even

*
* toolow: currently, the package is too low; place it at membot+256K
*

toolow:
	move.l	d0,a0
	bra	inplace

*
* toohigh: the package is too high; place it at memtop-128K.
* However, if that is in my TPA now, move it to my code start
* minus 2K bytes.
*

toohigh:
	move.l	d1,a0
	add.l	#$800,d1		; too close?
	cmp.l	a6,d1
	bpl	inplace			; no - keep it
	lea.l	-$200(a0),a0		; yes - back off
*	bra	inplace			; (fall through)

*
* inplace: round a0 up to the next $200 bytes,
* move the package to (a0), set it up as a package.
*

inplace:
	move.l	a0,d0
	add.l	#$1ff,d0
	and.l	#$fffffe00,d0
	move.l	d0,a0

	lea.l	bootsect(PC),a1
	move.l	a0,a2

	move.w	#$80-1,d0		; number of longs to move
.mloop:	move.l	(a1)+,(a2)+
	dbra	d0,.mloop

; set the pointer to point to itself

	move.l	a0,4(a0)

; compute the current checksum of the 512 bytes

chksum:
	moveq.l	#$0,d1
	move.w	#$100-1,d0		; number of words to count
	move.l	a0,a2
.cloop:	add.w	(a2)+,d1
	dbra	d0,.cloop

; in order to get a checksum of $5678, place ($5678-current) in checksum word

	move.w	#$5678,d0
	sub.w	d1,d0
	move.w	d0,$a(a0)

; all done; cause a reset (by jmp'ing to the reset handler from the header)

	move.l	_sysbase,a0
	move.l	4(a0),a0
	jmp	(a0)

*------------------------------------------------------------------------
*									:
*	Boot sector							:
*	Loads DOS.SYS from the disk and executes it.			:
*									:
*	(C)1985 Atari Corp.						:
*									:
* 02-May-1989 akp	Integrated into pkgboot.s and modified for any	:
*			size sector and 16-bit FATs.			:
* 25-Feb-1985 lmd	Hey!  It fits in 512 bytes....			:
*  2-Apr-1985 lmd	Fixed bugs (it works now)			:
*									:
*------------------------------------------------------------------------
	text

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
* Beginning of package.  This code is taken straight out of bootsec.s
*
bootsect:
	dc.l	$12123456		; magic number
	dc.l	0			; fill in with bootsect
	bra.s	start			; branch to code
	dc.w	0			; put word here for checksum 

* no need for a BPB here.

* Boot parameters
*
* fat+dir is loaded to end at _memtop; the image is loaded at _membot+$100.
*
fatbuf:		dc.l	0		; place where fat/dir is loaded to
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

*
* allocate all of memory; we'll never give it back, but we'll know
* that we're installing above other things which have booted (like AHDI).
*

	lea.l	bootsect(PC),a0		; clobber our magic #
	clr.l	(a0)
	pea	$ffffffff		; Malloc(-1L)
	move.w	#$48,-(sp)
	trap	#1

	move.l	d0,d7
	move.l	d0,2(sp)		; Malloc(d0)
	move.w	#$48,(sp)
	trap	#1
	addq	#6,sp

* set membot and memtop to the memory we just got.
* this means the RAM-loaded GEMDOS will leave the installed AHDI (etc.) alone.

	move.l	d0,_membot
	add.l	d7,d0
	move.l	d0,_memtop

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
	muls.w	recsiz(a5),d0		; (records *= (bytes/rec))

	move.l	_memtop,d1
	sub.l	d0,d1
	move.l	d1,(a0)			; store as fatbuf

	move.w	fsiz(a5),d0		; a4 = fatbuf + (a5[fsiz] * rsize)
	muls.w	recsiz(a5),d0
	move.l	d0,a4
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
	muls.w	recsiz(a5),d0		; d0 *= record size
	lea	(a0,d0.l),a0		; a0 -> end of directory buffer
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
* (insist on 16-bit sectors, as the old code insisted on 12-bit)
*
l_1:	tst.w	bflags(a5)
	beq.s	.12bit
	cmp.w	#$fff0,d7		; end of chain?
	bra	.12done
.12bit:	cmp.w	#$0ff0,d7
.12done:
	bcc	l_done			; (yes)

	move.w	d7,d3			; d3 = d7 - 2
	subq	#2,d3
	mulu	clsiz(a5),d3		; d3 *= clsiz
	add.w	datrec(a5),d3		; d3 += datrec

*----- if "break" in chain of sectors, read some in:
	tst.w	d4			; any old sectors?
	beq	l_4			; (no)
	cmp.w	d5,d3			; can this one be appended?
	beq	l_3			; (yes)
l_5:	bsr	readmult		; read old sectors

	muls.w	recsiz(a5),d4		; a3 += count * recsiz
	add.l	d4,a3

*----- startup a new chunk of contiguous sectors:
l_4:	move.w	d3,d6			; start = current sector
	move.w	d3,d5			; end = current sector
	clr.l	d4			; count = 0
l_3:	add.w	clsiz(a5),d4		; append current sector to
	add.w	clsiz(a5),d5		; the contiguous chunk

*----- compute next cluster number:
* (that is, fetch cluster number (D7) from the FAT.  Easy with 16-bit FATs)

	tst.w	bflags(a5)
	beq.s	.12bit
	move.w	d7,d2			; d2 = (d7 * 2)
	add.w	d2,d2
	move.w	(a6,d2),d7		; get the word there
	rol.w	#8,d7			; byte-swap d7.w -- that was easy
	bra	.12done

.12bit:	move.w	d7,d2			; d2 = (d7 >> 1) + d7
	lsr.w	#1,d2
	add.w	d7,d2
	move.b	1(a6,d2.w),d1		; get high byte
	lsl.w	#8,d1			; shift it up
	move.b	(a6,d2.w),d1		; get low byte (d1 = raw cluster entry)
	btst	#0,d7			; if(d7 & 1) d1 >>= 4
	beq	.l_2
	lsr.w	#4,d1
.l_2:	and.w	#$0fff,d1		; d1 &= $0fff
	move.w	d1,d7			; d7 = d1
.12done:
	bra	l_1			; read next cluster

*----- read any leftover sectors:
l_done:	tst.w	d4			; any sectors left?
	beq	ld_ex			; (nothing more to read)
	bsr	readmult		; read remainder (usu. entire file)

*----- jump to the base of the loaded file
ld_ex:	move.l	_membot,-(sp)		; push basepage address
	move.l	_membot,a0		; jsr to stuff we just loaded
	jsr	$100(a0)
	addq.w	#4,sp
	rts				; and rts to ROM boot

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
bootend: nop
