	.text

	bsr	_announce
	clr	(sp)
	trap #1

.include announce

