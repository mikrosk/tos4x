| docall.s -- help function for btest.c
|
| Usage:
|   docall(trap,fncode,p_args,p_types,max_args)
|   int trap;
|   int fncode;
|   long *p_args;
|   int *p_types;
|   int max_args;
|
|	p_types is an array of max_args ints; if the 0x80 bit is set,
|	the corresponding element of p_args should be pushed as a long.
|	When p_types is zero, the corresponding arg is not pushed at all.
|
|

.globl _osif			| imported from sup.c
.globl _docall			| exported to ftest.c
_docall:
	movew	sp@(4),d0	| trap number in d0
	movew	sp@(6),fncode	| function number in fncode
	movel	sp@(8),a0	| a0 -> args (all longs)
	movel	sp@(0xc),a1	| a1 -> types (all words)
	movew	sp@(0x10),d1	| d1 = max number of args
	moveml	d2/a2,sp@-	| save regs
	movel	sp,osp

	movew	d1,d2		| d2 = also max number of args
	subql	#1,d1		| d1 = count for dbra (max #args - 1)

	aslw	#1,d2		| d2 *= 2 (offset past last type word)
	lea	a1@(-2,d2:w),a1	| a1 -> last type word
	aslw	#1,d2		| d2 *= 2 again (offs past last arg long)
	lea	a0@(-4,d2:w),a0	| a0 -> last arg longword

loop:
	tstb	a1@(1)
	beq	next
	bmi	mlong
| int
	movew	a0@(2),sp@-	| move lo word of Nth arg to stack
	bra	next

mlong:	movel	a0@,sp@-	| move whole long of Nth arg to stack
next:	subql	#4,a0
	subql	#2,a1
	dbra	d1,loop

	movew	fncode,sp@-
	aslw	#2,d0		| trapno *= 4
xjmptab:
	jmp	pc@(jmptab-xjmptab-2:b,d0:w)	| what crappy syntax!

jmptab:
	trap	#0
	bra	done
	bra	dotrap1
	nop
	trap	#2
	bra	done
	trap	#3
	bra	done
	trap	#4
	bra	done
	trap	#5
	bra	done
	trap	#6
	bra	done
	trap	#7
	bra	done
	trap	#8
	bra	done
	trap	#9
	bra	done
	trap	#0xa
	bra	done
	trap	#0xb
	bra	done
	trap	#0xc
	bra	done
	trap	#0xd
	bra	done
	trap	#0xe
	bra	done
	trap	#0xf
	bra	done
	nop
done:
	movel	osp,sp
	moveml	sp@+,d2/a2
	rts

dotrap1:
	movel	sp,a0
	movel	a0,sp@-
	bsr	_osif
	bra	done

.comm osp,4
.comm fncode,2
