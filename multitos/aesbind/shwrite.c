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
shel_write(doex, isgr, iscr, pcmd, ptail)
	WORD		doex, isgr, iscr;
	LONG		pcmd, ptail;
{
	SH_DOEX = doex;
	SH_ISGR = isgr;
	SH_ISCR = iscr;
	SH_PCMD = pcmd;
	SH_PTAIL = ptail;
	return( crys_if( SHEL_WRITE ) );
}
