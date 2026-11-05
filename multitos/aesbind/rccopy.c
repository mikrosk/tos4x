#include <portab.h>
#include <machine.h>
#include <taddr.h>
#include <obdefs.h>
#include <crysbind.h>

	VOID
rc_copy(psxywh, pdxywh)
	REG WORD	*psxywh;
	REG WORD	*pdxywh;
{
	*pdxywh++ = *psxywh++;
	*pdxywh++ = *psxywh++;
	*pdxywh++ = *psxywh++;
	*pdxywh++ = *psxywh++;
}
