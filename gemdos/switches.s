*
* This file contains the one and only switch required for GEMDOS:
* JUST_LONG, which is used in rwa.s.  When zero, the code is assembled to
* test the _longframe variable.  When one, the machine is assumed to be
* longframe-only, like a TT.
*

JUST_LONG	equ	0
