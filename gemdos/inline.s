	text
s68:	move.w	(a0),d0
	ror.w	#8,d0
	move.w	d0,(a0)
s68l:	move.l	(a0),d0
	ror.w	#8,d0
	swap	d0
	ror.w	#8,d0
	move.l	d0,(a0)
dojmp:	jmp	(a0)
	end
