#include <portab.h>
#include <machine.h>
#include <taddr.h>
#include <obdefs.h>
#include <crysbind.h>

	WORD
rc_equal(p1, p2)
	REG WORD	*p1, *p2;
{
	REG WORD	i;

	for(i=0; i<4; i++)
	{
	  if (*p1++ != *p2++)
	    return(FALSE);
	}
	return(TRUE);
}
