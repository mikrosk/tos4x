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
form_keybd(form, obj, nxt_obj, thechar, pnxt_obj, pchar)
	LONG		form;
	WORD		obj;
	WORD		nxt_obj;
	WORD		thechar;
	WORD		*pnxt_obj;
	WORD		*pchar;
{
	addr_in[0] = form;
	int_in[0] = obj;
	int_in[2] = nxt_obj;
	int_in[1] = thechar;
	crys_if(55);
	*pnxt_obj = int_out[1];
	*pchar = int_out[2];
	return( RET_CODE );
}
