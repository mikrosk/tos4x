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
evnt_button(clicks, mask, state, pmx, pmy, pmb, pks)
	WORD		clicks;
	UWORD		mask;
	UWORD		state;
	WORD		*pmx, *pmy, *pmb, *pks;
{
	B_CLICKS = clicks;
	B_MASK = mask;
	B_STATE = state;
	crys_if(EVNT_BUTTON);
	*pmx = EV_MX;
	*pmy = EV_MY;
	*pmb = EV_MB;
	*pks = EV_KS;
	return(RET_CODE);
}
