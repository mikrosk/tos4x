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
shel_get(pbuffer, len)
	LONG		pbuffer;
	WORD		len;
{
	SH_PBUFFER = pbuffer;
	SH_LEN = len;
	return( crys_if( SHEL_GET ) );
}
