#include <portab.h>
#include <machine.h>
#include <taddr.h>
#include <obdefs.h>
#include <crysbind.h>

	VOID
rc_union(p1, p2)
	REG GRECT	*p1, *p2;
{
	REG WORD	tx, ty, tw, th;

	tw = max(p1->g_x + p1->g_w, p2->g_x + p2->g_w);
	th = max(p1->g_y + p1->g_h, p2->g_y + p2->g_h);
	tx = min(p1->g_x, p2->g_x);
	ty = min(p1->g_y, p2->g_y);
	p2->g_x = tx;
	p2->g_y = ty;
	p2->g_w = tw - tx;
	p2->g_h = th - ty;
}
