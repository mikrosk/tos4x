    .text
fuji_blit:
	lea	ib_ints,a0
	move.l	#$00010001,(a0)+	; MD_REPLACE, BLACK
	clr.w	(a0)			; WHITE
	lea	icon_pts,a0
	lea	ib_pts,a1
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0),(a1)
	pea	icon_fdb
	bsr	icon_blit
	addq	#4,sp

	moveq	#5,d1
	bsr	do_shroom

	move.w	#7,(sp)
	trap	#1
	clr.w	(sp)
	trap	#1

    .data
icon_start:
	.dc.l	$00000000,$79FF3C00,$00000000
	.dc.l	$00000000,$79FF3C00,$00000000
	.dc.l	$00000000,$79FF3C00,$00000000
	.dc.l	$00000000,$79FF3C00,$00000000
	.dc.l	$00000000,$79FF3C00,$00000000
	.dc.l	$00000000,$79FF3C00,$00000000
	.dc.l	$00000000,$79FF3C00,$00000000
	.dc.l	$00000000,$79FF3C00,$00000000
	.dc.l	$00000000,$79FF3C00,$00000000
	.dc.l	$00000000,$79FF3C00,$00000000
	.dc.l	$00000000,$79FF3C00,$00000000
	.dc.l	$00000000,$79FF3C00,$00000000
	.dc.l	$00000000,$79FF3C00,$00000000
	.dc.l	$00000000,$79FF3C00,$00000000
	.dc.l	$00000000,$79FF3C00,$00000000
	.dc.l	$00000000,$79FF3C00,$00000000
	.dc.l	$00000000,$F9FF3E00,$00000000
	.dc.l	$00000000,$F9FF3E00,$00000000
	.dc.l	$00000000,$F9FF3E00,$00000000
	.dc.l	$00000000,$F9FF3E00,$00000000
	.dc.l	$00000000,$F9FF3E00,$00000000
	.dc.l	$00000000,$F9FF3E00,$00000000
	.dc.l	$00000001,$F9FF3F00,$00000000
	.dc.l	$00000001,$F9FF3F00,$00000000
	.dc.l	$00000001,$F9FF3F00,$00000000
	.dc.l	$00000001,$F9FF3F00,$00000000
	.dc.l	$00000003,$F9FF3F80,$00000000
	.dc.l	$00000003,$F9FF3F80,$00000000
	.dc.l	$00000003,$F9FF3F80,$00000000
	.dc.l	$00000007,$F1FF1FC0,$00000000
	.dc.l	$00000007,$F1FF1FC0,$00000000
	.dc.l	$0000000F,$F1FF1FE0,$00000000
	.dc.l	$0000000F,$F1FF1FE0,$00000000
	.dc.l	$0000001F,$E1FF0FF0,$00000000
	.dc.l	$0000003F,$E1FF0FF8,$00000000
	.dc.l	$0000003F,$E1FF0FF8,$00000000
	.dc.l	$0000007F,$C1FF07FC,$00000000
	.dc.l	$000000FF,$C1FF07FE,$00000000
	.dc.l	$000001FF,$81FF03FF,$00000000
	.dc.l	$000003FF,$81FF03FF,$80000000
	.dc.l	$000007FF,$01FF01FF,$C0000000
	.dc.l	$00000FFE,$01FF00FF,$E0000000
	.dc.l	$00001FFE,$01FF00FF,$F0000000
	.dc.l	$00007FFC,$01FF007F,$FC000000
	.dc.l	$0000FFF8,$01FF003F,$FE000000
	.dc.l	$0003FFF0,$01FF001F,$FF800000
	.dc.l	$001FFFE0,$01FF000F,$FFF00000
	.dc.l	$00FFFFC0,$01FF0007,$FFFE0000
	.dc.l	$00FFFF80,$01FF0003,$FFFE0000
	.dc.l	$00FFFF00,$01FF0001,$FFFE0000
	.dc.l	$00FFFC00,$01FF0000,$7FFE0000
	.dc.l	$00FFF800,$01FF0000,$3FFE0000
	.dc.l	$00FFE000,$01FF0000,$0FFE0000
	.dc.l	$00FF8000,$01FF0000,$03FE0000
	.dc.l	$00FC0000,$01FF0000,$007E0000
	.dc.l	$00E00000,$01FF0000,$000E0000
	.dc.l	$00000000,$00000000,$00000000
	.dc.l	$00000000,$00000000,$00000000
	.dc.l	$00000000,$00000000,$00000000
	.dc.l	$00000000,$00000000,$00000000
	.dc.l	$00000000,$00000000,$00000000
	.dc.l	$0000C07F,$FE030007,$C01E0700
	.dc.l	$0001E07F,$FE07801F,$F81E18C0
	.dc.l	$0003E07F,$FE0F803F,$FC1E1740
	.dc.l	$0003F07F,$FE0FC03F,$FE1E2520
	.dc.l	$0003F07F,$FE0FC03F,$FE1E2620
	.dc.l	$0007F803,$C01FE03C,$1F1E2520
	.dc.l	$0007F803,$C01FE03C,$0F1E1540
	.dc.l	$0007F803,$C01FE03C,$0F1E18C0
	.dc.l	$000F7C03,$C03DF03C,$0F1E0700
	.dc.l	$000F3C03,$C03CF03C,$0F1E0000
	.dc.l	$000F3C03,$C03CF03C,$1E1E0000
	.dc.l	$001E3E03,$C078F83C,$7E1E0000
	.dc.l	$001E1E03,$C078783D,$FC1E0000
	.dc.l	$001E1E03,$C078783D,$F81E0000
	.dc.l	$003E1F03,$C0F87C3D,$E01E0000
	.dc.l	$003FFF03,$C0FFFC3D,$E01E0000
	.dc.l	$003FFF03,$C0FFFC3D,$E01E0000
	.dc.l	$007FFF83,$C1FFFE3C,$F01E0000
	.dc.l	$007FFF83,$C1FFFE3C,$F81E0000
	.dc.l	$00780783,$C1E01E3C,$781E0000
	.dc.l	$00F807C3,$C3E01F3C,$3C1E0000
	.dc.l	$00F007C3,$C3C01F3C,$3E1E0000
	.dc.l	$00F003C3,$C3C00F3C,$1E1E0000
	.dc.l	$01F003E3,$C7C00FBC,$1F1E0000
	.dc.l	$01E001E3,$C78007B8,$0F1E0000

icon_fdb:				; FDB for fuji icon
	dc.l	icon_start		; fd_addr
	dc.w	96,86,6,0,1		; fd_w,fd_h,fd_wd,fd_stand,fd_planes

icon_pts:
	dc.w	0,0,95,85,0,4,95,89

*+
* icon_blit: use line A copy raster form to blit an icon to the screen
* 4(sp) -> source memory form
*-
    .bss
ib_contrl:	ds.w	7
ib_psfdb:	ds.l	1
ib_pdfdb:	ds.l	1
ib_sfdb:	ds.l	5
ib_dfdb:	ds.l	5
ib_ints:	ds.w	3
ib_pts:		ds.w	8

    .text
icon_blit:
	lea	ib_dfdb,a0		; destination is screen
	clr.l	(a0)
	move.l	a0,ib_pdfdb
	lea	ib_sfdb,a1
	move.l	a1,ib_psfdb
	move.l	4(sp),a0
	move.l	(a0)+,(a1)+		; fd_addr
	move.l	(a0)+,(a1)+		; fd_w,fd_h
	move.l	(a0)+,(a1)+		; fd_wdwidth,fd_stand
	move.w	(a0),(a1)		; fd_planes

	dc.w	$a000			; a0 -> line A vars
	clr.w	$36(a0)			; CLIP = 0
	move.w	#1,$74(a0)		; COPYTRAN = 1
	addq	#4,a0			; skip PLANES & WIDTH
	lea	ib_contrl,a1
	move.l	a1,(a0)+
	lea	ib_ints,a1
	move.l	a1,(a0)+
	lea	ib_pts,a1
	move.l	a1,(a0)
	dc.w	$a00e			; copy raster form
	rts

*+
* do_shroom - draw little mushroom clouds on the screen
*  Passed:	d1.w = #shrooms to draw (DBRA count)
*  Returns:	some shrooms on display
*  Uses:	d0-d7/a0-a2
*
*  Discussion:	The graphics ain't all that great.  And this is silly.
*
*-
do_shroom:
	lea	ib_ints,a0
	move.l	#$00010001,(a0)+	; MD_REPLACE, BLACK
	clr.w	(a0)			; WHITE

	lea	ib_pts,a0
	moveq	#15,d6			; x & y span
	clr.l	(a0)+			; sx1 = sy1 = 0
	move.w	d6,(a0)+		; sx2
	move.w	d6,(a0)+		; sy2

	clr.w	(a0)+			; dx1 = 0

	move.l	a0,-(sp)
	dc.w	$a000			; a0 -> line A info
	move.w	-4(a0),d7		; vertical rez
	move.l	(sp)+,a0

	lsr	#1,d7			; / 2
	subq	#8,d7			; - 8
	move.w	d7,(a0)+		; = dy1
	move.w	d6,(a0)+		; dx2 = 15
	add.w	d6,d7			; dy1 + 15
	move.w	d7,(a0)			; = dy2

	addq	#1,d6			; d6 = step
	move.w	d1,d7			; d7 = # of shrooms

	pea	mush_fdb		; pass src fdb

dmlp:	bsr	icon_blit		; blit 'dem shrooms
	add.w	d6,ib_pts+$8
	add.w	d6,ib_pts+$c
	dbra	d7,dmlp

	addq	#4,sp			; get back stack

	rts

*+
*  Form to display on system catastrophe
*
*-
mushroom:				; (sic)
	dc.w	%0000011000000000
	dc.w	%0010100100000000
	dc.w	%0000000010000000
	dc.w	%0100100001000000
	dc.w	%0001000111110000
	dc.w	%0000000111110000
	dc.w	%0000011111111100
	dc.w	%0000111111111110
	dc.w	%0000110111111110
	dc.w	%0001111111111111
	dc.w	%0001111111101111
	dc.w	%0000111111101110
	dc.w	%0000111111011110
	dc.w	%0000011111111100
	dc.w	%0000001111111000
	dc.w	%0000000011100000

mush_fdb:
	dc.l	mushroom		; fd_addr
	dc.w	16,16,1,0,1		; fd_w,fd_h,fd_wd,fd_stand,fd_planes

