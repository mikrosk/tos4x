#include <portab.h>
#include <machine.h>
#include <taddr.h>
#include <obdefs.h>
#include <crysbind.h>

EXTERN UWORD		control[C_SIZE];
EXTERN UWORD		global[G_SIZE];
EXTERN UWORD		int_in[I_SIZE];
EXTERN UWORD		int_out[O_SIZE];
EXTERN LONG		addr_in[AI_SIZE];
EXTERN LONG		addr_out[AO_SIZE];

	WORD
evnt_mouse(flags, x, y, width, height, pmx, pmy, pmb, pks)
	WORD		flags, x, y, width, height;
	WORD		*pmx, *pmy, *pmb, *pks;
{
	MO_FLAGS = flags;
	MO_X = x;
	MO_Y = y;
	MO_WIDTH = width;
	MO_HEIGHT = height;
	crys_if(EVNT_MOUSE);
	*pmx = EV_MX;
	*pmy = EV_MY;
	*pmb = EV_MB;
	*pks = EV_KS;
	return(RET_CODE);
}
