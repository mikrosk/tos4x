#include <portab.h>
#include <machine.h>
#include <taddr.h>
#include <obdefs.h>
#include <crysbind.h>
#include "struct.h"

EXTERN UWORD		control[C_SIZE];
EXTERN UWORD		global[G_SIZE];
EXTERN UWORD		int_in[I_SIZE];
EXTERN UWORD		int_out[O_SIZE];
EXTERN LONG		addr_in[AI_SIZE];
EXTERN LONG		addr_out[AO_SIZE];

	WORD
menu_settings( flag, Values )
	WORD	      flag;
	MN_SET	      *Values;
{
	M_FLAG	      = flag;
	M_MENU	      = Values;

	crys_if( MN_SETTING );

	return( RET_CODE );
}
