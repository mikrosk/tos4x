#include <portab.h>
#include <machine.h>
#include <taddr.h>
#include <obdefs.h>
#include <crysbind.h>

	WORD
max(a, b)
	WORD		a, b;
{
	return( (a > b) ? a : b );
}
