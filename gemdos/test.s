	.text

|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
| in mem @ ffit:LI45:
LI45:
	movew pc@(L45-LI45-2:b,a0:l:2),d2
	.long 0x343B8A0E
	jmp pc@(2,d2:w)
	.long 0x4EFB2002
L45:


|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
| in fshand @ _ixopen:L120:
	movel a3,a0@(a1:l:4)
	.long 0x218B9C00

|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
| in fshand @ _ixclose:L58:, _ttyopen:L126
| in sup @ _osi:L80:
	movel d0,a1@(a0:l:4)
	.long 0x23808c00

|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
| in mem @ ffit:LI47:
LI47:
	movew pc@(L47-LI47-2:b,a0:l:2),d1
	.long 0x323b8a06
	jmp pc@(2,d1:w)
	.long 0x4efb1002

L47:

|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
| in sup @ _domediach:L26:
	clrw a1@(64,a2:l:2)
	.long 0x4271aa40

| in sup @ _osif:LI67:
LI67:
	movew pc@(L67-LI67-2:b,a0:l:2),d4
	.long 0x383b8a06
	jmp pc@(2,d4:w)
	.long 0x4efb4002
L67:

| in sup @ _osif:L58:,L59:,L60:,L61:,L62,:L64:,L65:
	movel a1@(a0:l:4),a0
	.long 0x20718c00


|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
| in con @ _conout:L32:, _qrem:L110
	movew a1@(a0:l:2),d0
	.long 0x30318A00

| in con @ _conout:L32:
	movew d0,a1@(a0:l:2)
	.long 0x33808A00

| in con @ _xrawio:
	movew a2@(a0:l:2),d2
	.long 0x34328A00
	cmpw a1@(a0:l:2),d2
	.long 0xB4718A00

| in con @ _conin:,_constat
	movew a2@(a0:l:2),d1
	.long 0x32328A00
	cmpw a1@(a0:l:2),d1
	.long 0xB2718A00

| in con @ _conbrk:L85:
	movew a1@(a3:l:2),d1
	.long 0x3231BA00
	cmpw a0@(a3:l:2),d1
	.long 0xB270BA00

| in con @ _buflush:
	clrw a2@(a0:l:2)
	.long 0x42728A00
	clrw a1@(a0:l:2)
	.long 0x42718A00

| in con @ _qrem:
	movew a2@(a0:l:2),d3
	.long 0x36328A00
	cmpw a1@(a0:l:2),d3
	.long 0xB6718A00

| in con @ _qrem:L111:
	movew d1,a1@(a0:l:2)
	.long 0x33818A00

| in con @ _qrem:L111:
	movel a1@(a0:l:4),d0
	.long 0x20318C00

|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
| in fsproc @ _ixterm:L18:, _xexec:L100:
	cmpl a1@(a0:l:4),a3
	.long 0xB7F18C00
	clrl a1@(a0:l:4)
	.long 0x42B18C00

| in fsproc @ _xexec:L100:
	tstl a1@(a0:l:4)
	.long 0x4AB18C00
	movel a4,a1@(a0:l:4)
	.long 0x238C8C00
