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
graf_mbox(w, h, srcx, srcy, dstx, dsty)
	WORD		w, h;
	WORD		srcx, srcy, dstx, dsty;
{
	GR_I1 = w;
	GR_I2 = h;
	GR_I3 = srcx;
	GR_I4 = srcy;
	GR_I5 = dstx;
	GR_I6 = dsty;
	return( crys_if( GRAF_MBOX ) );
}
