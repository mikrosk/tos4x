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
shel_envrn(ppath, psrch)
	LONG		ppath;
	LONG		psrch;
{
	SH_PATH = ppath;
	SH_SRCH = psrch;
	return( crys_if( SHEL_ENVRN ) );
}
