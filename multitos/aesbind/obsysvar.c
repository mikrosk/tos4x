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
objc_sysvar(mode, which, ival1, ival2, oval1, oval2)
	WORD		mode, which, ival1, ival2;
	WORD		*oval1, *oval2;
{
	int_in[0] = mode;
	int_in[1] = which;
	if ( mode )
	{
	  int_in[2] = ival1;
	  int_in[3] = ival2;
	}
	crys_if(48);
	if ( !mode )
	{
	  *oval1 = int_out[1];
	  *oval2 = int_out[2];
	}
	return( RET_CODE );
}
