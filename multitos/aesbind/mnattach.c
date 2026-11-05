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
menu_attach( flag, tree, item, Menu )
	WORD	      flag;
	OBJECT	      *tree;
	WORD	      item;
	MENU	      *Menu;
{
	M_FLAG	      = flag;
	M_TREE	      = tree;
	M_ITEM	      = item;
	M_MDATA	      = Menu;

	crys_if( MN_ATTACH );

	return( RET_CODE );
}
