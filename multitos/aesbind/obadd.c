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
objc_add(tree, parent, child)
	LONG		tree;
	WORD		parent, child;
{
	OB_TREE = tree;
	OB_PARENT = parent;
	OB_CHILD = child;
	return( crys_if( OBJC_ADD ) );
}
