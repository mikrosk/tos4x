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
fsel_exinput(pipath, pisel, pbutton, label)
	LONG		pipath, pisel;
	WORD		*pbutton;
	LONG		label;
{
	addr_in[0] = pipath;
	addr_in[1] = pisel;
	addr_in[2] = label;
	crys_if(91);
	*pbutton = int_out[1];
	return( RET_CODE );
}
