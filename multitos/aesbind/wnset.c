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
wind_set(w_handle, w_field, w2, w3, w4, w5)
	WORD		w_handle;	
	WORD		w_field;
	WORD		w2, w3, w4, w5;
{
	WM_HANDLE = w_handle;
	WM_WFIELD = w_field;
	WM_IX = w2;
	WM_IY = w3;
	WM_IW = w4;
	WM_IH = w5;
	return( crys_if( WIND_SET ) );
}
