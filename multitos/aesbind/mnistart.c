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
menu_istart( flag, tree, menu, item )
	WORD	    flag;
	OBJECT	    *tree;
	WORD	    menu;
	WORD	    item;
{
	M_FLAG      = flag;
	M_TREE      = tree;
	M_MENU2     = menu;	
	M_ITEM2     = item;

	crys_if( MN_ISTART );

	return( RET_CODE );
}
