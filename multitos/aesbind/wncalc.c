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
wind_calc(wctype, kind, x, y, w, h, px, py, pw, ph)
	WORD		wctype;
	UWORD		kind;
	WORD		x, y, w, h;
	WORD		*px, *py, *pw, *ph;
{
	WM_WCTYPE = wctype;
	WM_WCKIND = kind;
	WM_WCIX = x;
	WM_WCIY = y;
	WM_WCIW = w;
	WM_WCIH = h;
	crys_if( WIND_CALC );
	*px = WM_WCOX;
	*py = WM_WCOY;
	*pw = WM_WCOW;
	*ph = WM_WCOH;
	return( RET_CODE );
}
