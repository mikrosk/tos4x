****************************************************************************
*
* This source fragment is included into bios.s.
*
* It translates a key whose scan code is in d0 into the value that
* should go into the keyboard buffer.  When we fall off the bottom
* of this file, d0.w should have the scan code in the high byte and
* the ASCII code in the low byte.
*
* Here's what we have to deal with:
*	Unshifted normal keys
*	Shifted normal keys
*	Caps-locked keys
*	Alt-ed keys
*	Alt-shifted keys
*	Alted keys when caps-lock is down
*
* In addition, some keys (function keys, arrow keys) change
* their scan codes when they're shifted: the function keys
* are scan codes 3b-44 when unshifted, 54-5d when shifted.
* Also, the top row changes its scan code when alt-ed.
*
* There is more wierdness: ALT plus letter keys a-z A-Z results
* in an ASCII code of zero, but ALT with other keys give the normal
* ASCII code.  Control-2, control-6, and control-dash are special;
* dash is harder because it means we have to check after translating
* the key into its ASCII form.

*
* Handle all keys which need special handling: 
*
*	Alt -02 -> 78/00 (alt + top row adds 76 to scan code)
*
*	Ctrl-1c -> 1c/LF (same scan code)
*	Ctrl-4b -> 73/00
*	Ctrl-4d -> 74/00
*	Ctrl-47 -> 77/00
*	Shft-3b -> 54 (through 44 -> 5d)
*
* Anything NOT special means it can be dealt with by looking up the ASCII
* code in the right table (based on shift, capslock, and alt). A key must
* be special if its scan code has to change based on modifiers, or if its
* control form isn't its non-ctl form AND $1f.  Trouble here: ^2 and ^6 are
* ^@ and ^^ respectively, so they should be "special" in this sense, but
* they're not because you can't be special in two ways at once, and
* table-driving the alt-top-row-adds-$76 makes more sense.
*
* Some keys that are neither "special" in this sense nor "normal"
* are the alt-ed arrow keys and alt-help.
*
* The "special" table has bit patterns: if the corresponding entry AND the
* current kbshift is nonzero, then it's speical. No keys are special one
* way when ctrl-ed and another when shifted. Thus a second table of "what
* to return when it's special" is all we need. So it looks like this:
*
*	if (special[scan] & kbshift) {
*		return sptab[scan];
*	}
*
* This will be wierd when shift and alt are both down and you hit a special
* key.  I'm not that concerned.  sptab is an associative array, so
* sptab[scan] isn't just indexing into a table.  The first byte of each
* triple is the scan code, the next two are the scan and ASCII codes to
* return in that case.
*

	and.l	#$ff,d0			; make d0 an unsigned long
	move.b	special(PC,d0.w),d1	; see if it is special
	and.b	kbshift,d1
	beq	notspecial		; nope

	lea	sptab(PC),a0		; yup - do associative lookup
spctl:	tst.b	(a0)
	beq	notspecial		; end of table: not really special??
	cmp.b	(a0)+,d0
	beq	spcmatch
	addq	#2,a0
	bra	spctl

spcmatch:
	move.b	(a0)+,d0		; get the new scan code
	asl.w	#8,d0			; shift into position
	move.b	(a0)+,d0		; get the new ASCII code
	bra	alldone			; all done!

*
* See above for the layout of these tables.
*

*	  0   1   2   3   4   5   6   7   8   9   a   b   c   d   e   f
special:
dc.b	$00,$08,$08,$08,$08,$08,$08,$08,$08,$08,$08,$08,$08,$08,$00,$00,
dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$04,$00,$00,$00,
dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$03,$03,$03,$03,$03,
dc.b	$03,$03,$03,$03,$03,$00,$00,$04,$00,$00,$00,$04,$00,$04,$00,$00,
dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00

sptab:
dc.b	$02,$78,$00, $03,$79,$00, $04,$7a,$00, $05,$7b,$00
dc.b	$06,$7c,$00, $07,$7d,$00, $08,$7e,$00, $09,$7f,$00
dc.b	$0a,$80,$00, $0b,$81,$00, $0c,$82,$00, $0d,$83,$00
dc.b	$1c,$1c,$0a, $4b,$73,$00, $4d,$74,$00, $47,$77,$00
dc.b	$3b,$54,$00, $3c,$55,$00, $3d,$56,$00, $3e,$57,$00
dc.b	$3f,$58,$00, $40,$59,$00
dc.b	$41,$5a,$00, $42,$5b,$00, $43,$5c,$00, $44,$5d,$00
dc.b	0
.even

****************************************************************************
*
* OK, the key isn't special in the above sense.  We still have to deal
* with ^2 and ^6 and alt-help before falling into the normal case.
*
*	Ctrl-03 -> 03/00 (^2 -> NULL / same scan code)
*	Ctrl-07 -> 07/1e (^6 -> ^^)
*
*	Alt-Help increments the print-screen-request flag.
*
* We also have to deal with alt-keypad keys used to type in any
* ASCII code.
*

notspecial:
	move.b	kbshift,d1
	btst	#KBCTL,d1
	beq	notctl
	cmp.b	#$03,d0		; ^2
	beq	notnull
	move.w	#$0200,d0
	bra	alldone
notnull:
	cmp.b	#$07		; ^6
	beq	noctl
	move.w	#$071e
	bra	alldone

notctl:	
	btst	#KBALT,d1
	beq	normal
	cmp.b	#62,d0		; alt-help?
	bne	nothelp
	addq.w	#1,_dumpflg.w	; indicate a print-screen request
	moveq.l	#0,d0		; signal a no-key situation
	bra	alldone

nothelp:
	cmp.b	#$67,d0		; in range of keypad keys?
	blo	normal
	cmp.b	#$70,d0
	bhi	normal

* Alt plus a keypad key.  Get the ASCII equivalent, subtract $30,
* and accumulate into the variable altkp.

	move.w	altkp,d1		; get accumulated value
	bpl	altkp1
	moveq.l	#0,d1			; use zero if it was negative
altkp1:
	mulu.w	#10,d1			; multiply by 10
	move.l	skeytran,a0		; get value of this digit
	move.b	(a0,d0.w),d0
	sub.b	#$30,d0			; d0 is now this digit
	add.b	d0,d1
	move.b	d1,altkp
	moveq.l	#0,d0			; flag the no-key case
	bra	alldone

*
*	After getting the ASCII code, Ctrl-dash needs to become "^_".
*

normal:
	btst	#KBALT,d1
	beq	notalt

* Alt-key handling: use the alt, alt-shift, or alt-caps-lock assoc. table

	lea	akeytran,a0
	move.b	d1,d2
	and.b	#3,d2
	beq	anotshift
	addq.l	#4,a0
	bra	agottab
anotshift:
	btst	#KBCL,d1
	beq	agottab
	addq.l	#8,a0
agottab:
	move.l	(a0),a0		; a0 now points to assoc table to use
aloop:	tst.b	(a0)
	beq	notalt		; if not there handle "normally"
	cmp.b	(a0)+,d0
	beq	amatch
	addq.w	#1,d0
	bra	aloop

amatch:	asl.w	#8,d0
	move.b	(a0),d0		; get the ASCII code and return
	bra	alldone

********************
*
* We get here if the ALT key isn't down or even if it is, if this key
* doesn't get treated specially when alt-ed.  That means later on
* we check the alt key again and mash the ASCII code of alt-'A' through
* alt-'Z' to zero.
*

notalt:
	lea	skeytran,a0
	move.b	d1,d2
	and.b	#3,d2		; MAGIC NUMBER: 3 is both shift key bits
	beq	notshift
	addq.l	#4,a0		; advance to the shift-key entry
	bra	gottab
notshift:
	btst	#KBCL,d1
	beq	gottab
	addq.l	#8,a0		; advance to the "caps lock" entry

gottab:
	move.l	(a0),a0

*
* A0 now points to the table to be used.
*

	moveq	#0,d2
	move.b	d0,d2
	move.b	(a0,d2),d2	; get the key

*
* We have the ASCII code in d2 now.  Scan code still in d0.
*
* If the ALT key is down, mash ASCII codes [a-zA-Z] to zero.
*

	btst.b	#KBALT,kbshift.w
	beq	doctl
	cmp.b	#'A',d2
	blo	doctl
	cmp.b	#'Z',d2
	bls	altmash
	cmp.b	#'a',d2
	blo	doctl
	cmp.b	#'z',d2
	bhi	doctl
altmash:
	moveq.l	#0,d2		; mash ALT-letter keys to zero.

*
* Act on the control key.  We *should* only control-ize those keys
* that result in ASCII codes from 64-128 but old TOS didn't do that,
* any why buck the trend?
*

doctl:
	btst	#KBCTL,d1
	beq	noctl
	cmp.b	#'-',d2		; ctl-ize ^- specially into ^_
	bne	notctldash
	move.b	#$1f,d2
	bra	noctl

notctldash:
	and.b	#$1f,d2		; ctl-ize any key at all -- sigh
noctl:
	asl.w	#8,d0		; shift the scan code into d0.w's hi byte
	move.b	d2,d0		; move the ASCII code into place

alldone:

*
* we're done!
*
* Here we are, at the bottom of this include file.  At this point d0.w
* should have the scan code in the high byte and the ASCII code in the
* low byte.
*
**********************************************************************
