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

	VOID
graf_watchbox(tree, obj, instate, outstate)
	LONG		tree;
	WORD		obj;
	UWORD		instate, outstate;
{
	GR_TREE = tree;
	GR_OBJ = obj;
	GR_INSTATE = instate;
	GR_OUTSTATE = outstate;
	return( crys_if( GRAF_WATCHBOX ) );
}
