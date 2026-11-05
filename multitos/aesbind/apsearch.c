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
appl_search(stype, name, type, id)
	WORD		stype;
	LONG		name;
	WORD		*type, *id;
{
	int_in[0] = stype;
	addr_in[0] = name;
	crys_if(18);
	*type = int_out[1];
	*id = int_out[2];
	return( RET_CODE );
}
