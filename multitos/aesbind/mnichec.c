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
menu_icheck(tree, itemnum, checkit)
	LONG		tree;
	WORD		itemnum, checkit;
{
	MM_ITREE = tree;
	ITEM_NUM = itemnum;
	CHECK_IT = checkit;
	return( crys_if(MENU_ICHECK) );
}
