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
EXTERN LONG		ad_c;

	WORD
form_button(form, obj, clks, pnxt_obj)
	LONG		form;
	WORD		obj;
	WORD		clks;
	WORD		*pnxt_obj;
{
	addr_in[0] = form;
	int_in[0] = obj;
	int_in[1] = clks;
	crys_if(56);
	*pnxt_obj = int_out[1];
	return( RET_CODE );
}
