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
form_alert(defbut, astring)
	WORD		defbut;
	LONG		astring;
{
	FM_DEFBUT = defbut;
	FM_ASTRING = astring;
	return( crys_if( FORM_ALERT ) );
}
