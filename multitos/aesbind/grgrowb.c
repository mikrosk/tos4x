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
graf_growbox(orgx, orgy, orgw, orgh, x, y, w, h)
	WORD		orgx, orgy, orgw, orgh;
	WORD		x, y, w, h;
{
	GR_I1 = orgx;
	GR_I2 = orgy;
	GR_I3 = orgw;
	GR_I4 = orgh;
	GR_I5 = x;
	GR_I6 = y;
	GR_I7 = w;
	GR_I8 = h;
	return( crys_if( GRAF_GROWBOX ) );
}
