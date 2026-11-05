; Common blocks of allbios.awu as .bss, in the order aln allocates them, then endos (start of
; the AES bss). tos492.img has them between the GEMDOS and AES bss.
	.globl	_seed
	.globl	_PR
	.globl	_prtbyt
	.globl	_blue
	.globl	_WS
	.globl	_TW
	.globl	_hues
	.globl	_maxacct
	.globl	_diskmod
	.globl	_ajwidth
	.globl	_rasincr
	.globl	_prtn1
	.globl	_prtn2
	.globl	_curflop
	.globl	_pixincr
	.globl	_rasword
	.globl	_plnword
	.globl	_quality
	.globl	_pixword
	.globl	_green
	.globl	_plzword
	.globl	_inbit
	.globl	_index
	.globl	_invid
	.globl	_color
	.globl	_cksum
	.globl	_red
	.globl	_a
	.globl	_dsbtab
	.globl	_huepal
	.globl	_planes
	.globl	_rasbit
	.globl	_duppal
	.globl	_CD
	.globl	_intpal
	.globl	_ED
	.globl	_pixblk
	.globl	_flopok
	.globl	_pixlen
	.globl	_HI
	.globl	_intens
	.globl	_ME
	.globl	_CP
	.globl	_pixhgt
	.globl	_EP
	.globl	_pixwid
	.globl	_prtbit
	.globl	_plzbit
	.globl	_DR
	.globl	_lumsat
	.globl	_LO
	.globl	_DW
	.globl	_LS
	.globl	endos
	.bss
_seed:	ds.b	4
_PR:	ds.b	2
_prtbyt:	ds.b	2
_blue:	ds.b	2
_WS:	ds.b	2
_TW:	ds.b	2
_hues:	ds.b	8
_maxacct:	ds.b	4
_diskmod:	ds.b	2
_ajwidth:	ds.b	2
_rasincr:	ds.b	2
_prtn1:	ds.b	2
_prtn2:	ds.b	2
_curflop:	ds.b	2
_pixincr:	ds.b	2
_rasword:	ds.b	4
_plnword:	ds.b	4
_quality:	ds.b	2
_pixword:	ds.b	4
_green:	ds.b	2
_plzword:	ds.b	4
_inbit:	ds.b	2
_index:	ds.b	2
_invid:	ds.b	2
_color:	ds.b	2
_cksum:	ds.b	24
_red:	ds.b	2
_a:	ds.b	30
_dsbtab:	ds.b	72
_huepal:	ds.b	32
_planes:	ds.b	2
_rasbit:	ds.b	2
_duppal:	ds.b	2
_CD:	ds.b	2
_intpal:	ds.b	32
_ED:	ds.b	2
_pixblk:	ds.b	8
_flopok:	ds.b	4
_pixlen:	ds.b	2
_HI:	ds.b	2
_intens:	ds.b	8
_ME:	ds.b	2
_CP:	ds.b	2
_pixhgt:	ds.b	2
_EP:	ds.b	2
_pixwid:	ds.b	2
_prtbit:	ds.b	2
_plzbit:	ds.b	2
_DR:	ds.b	2
_lumsat:	ds.b	32
_LO:	ds.b	2
_DW:	ds.b	2
_LS:	ds.b	2
endos:
