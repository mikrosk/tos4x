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
objc_gclip(tree, obj, poffx, poffy, x, y, w, h)
	LONG		tree;
	WORD		obj;
	WORD		*poffx, *poffy, *x, *y, *w, *h;
{
	addr_in[0] = tree;
	int_in[0] = obj;
	control[0] = 44;
	control[1] = 1;
	control[2] = 7;
	control[3] = 1;
	control[4] = 0;
	crystal(ad_c);
	*poffx = int_out[1];
	*poffy = int_out[2];
	*x = int_out[3];
	*y = int_out[4];
	*w = int_out[5];
	*h = int_out[6];
	return( RET_CODE );
}
