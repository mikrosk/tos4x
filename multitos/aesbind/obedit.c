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
objc_edit(tree, obj, inchar, idx, kind)
	LONG		tree;
	WORD		obj;
	WORD		inchar, *idx, kind;
{
	OB_TREE = tree;
	OB_OBJ = obj;
	OB_CHAR = inchar;
	OB_IDX = *idx;
	OB_KIND = kind;
	crys_if( OBJC_EDIT );
	*idx = OB_ODX;
	return( RET_CODE );
}
