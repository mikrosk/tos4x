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
menu_ienable(tree, itemnum, enableit)
	LONG		tree;
	WORD		itemnum, enableit;
{
	MM_ITREE = tree;
	ITEM_NUM = itemnum;
	ENABLE_IT = enableit;
	return( crys_if(MENU_IENABLE) );
}
