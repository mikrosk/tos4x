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
menu_popup( Menu, xpos, ypos, MData )
	MENU	      *Menu;
	WORD	      xpos;
	WORD	      ypos;
	MENU	      *MData;
{
	M_MENU	      = Menu;
	M_XPOS	      = xpos;
        M_YPOS	      = ypos;
	M_MDATA	      = MData;

	crys_if( MN_POPUP );

	return( RET_CODE );
}
