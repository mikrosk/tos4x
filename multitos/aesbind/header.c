#include <portab.h>
#include <machine.h>
#include <taddr.h>
#include <obdefs.h>
#include <crysbind.h>

typedef struct cblk
{
	LONG		cb_pcontrol;
	LONG		cb_pglobal;
	LONG		cb_pintin;
	LONG		cb_pintout;
	LONG		cb_padrin;
	LONG		cb_padrout;
} CBLK;

EXTERN WORD		crystal();

GLOBAL UWORD		control[C_SIZE];
GLOBAL UWORD		global[G_SIZE];
GLOBAL UWORD		int_in[I_SIZE];
GLOBAL UWORD		int_out[8];
GLOBAL LONG		addr_in[4];
GLOBAL LONG		addr_out[4];
GLOBAL WORD		gl_apid;
GLOBAL LONG		ad_c;
GLOBAL CBLK		c;

MLOCAL BYTE		ctrl_cnts[] =
{
	0, 1, 0, 0,			/* func 010		*/
	2, 1, 1, 0,			/* func 011		*/
	2, 1, 1, 0,			/* func 012		*/
	0, 1, 1, 0,			/* func 013		*/
	2, 1, 1, 0,			/* func 014		*/
	1, 1, 1, 0,			/* func 015		*/
	0, 0, 0, 0,			/* func 016		*/
	1, 1, 0, 0,			/* func 017		*/
	1, 3, 1, 0,			/* func 018		*/
	0, 1, 0, 0,			/* func 019		*/
	0, 1, 0, 0,			/* func 020		*/
	3, 5, 0, 0,			/* func 021		*/
	5, 5, 0, 0,			/* func 022		*/
	0, 1, 1, 0,			/* func 023		*/
	2, 1, 0, 0,			/* func 024		*/
	16, 7, 1, 0,			/* func 025		*/
	2, 1, 0, 0,			/* func 026		*/
	0, 0, 0, 0,			/* func 027		*/
	0, 0, 0, 0,			/* func 028		*/
	0, 0, 0, 0,			/* func 029		*/
	1, 1, 1, 0,			/* func 030		*/
	2, 1, 1, 0,			/* func 031		*/
	2, 1, 1, 0,			/* func 032		*/
	2, 1, 1, 0,			/* func 033		*/
	1, 1, 2, 0,			/* func 034		*/
	1, 1, 1, 0,			/* func 035		*/
	2, 1, 2, 0,			/* func 036		*/
	2, 1, 2, 0,			/* func 037		*/
	3, 1, 1, 0,			/* func 038		*/
	1, 1, 1, 0,			/* func 039		*/
	2, 1, 1, 0,			/* func 040		*/
	1, 1, 1, 0,			/* func 041		*/
	6, 1, 1, 0,			/* func 042		*/
	4, 1, 1, 0,			/* func 043		*/
	1, 3, 1, 0,			/* func 044		*/
	2, 1, 1, 0,			/* func 045		*/
	4, 2, 1, 0,			/* func 046		*/
	8, 1, 1, 0,			/* func 047		*/
	4, 3, 0, 0,			/* func 048		*/
	0, 0, 0, 0,			/* func 049		*/
	1, 1, 1, 0,			/* func 050		*/
	9, 1, 1, 0,			/* func 051		*/
	1, 1, 1, 0,			/* func 052		*/
	1, 1, 0, 0,			/* func 053		*/
	0, 5, 1, 0,			/* func 054		*/
	3, 3, 1, 0,			/* func 055		*/
	2, 2, 1, 0,			/* func 056		*/
	0, 0, 0, 0,			/* func 057		*/
	0, 0, 0, 0,			/* func 058		*/
	0, 0, 0, 0,			/* func 059		*/
	0, 0, 0, 0,			/* func 060		*/
	0, 0, 0, 0,			/* func 061		*/
	0, 0, 0, 0,			/* func 062		*/
	0, 0, 0, 0,			/* func 063		*/
	0, 0, 0, 0,			/* func 064		*/
	0, 0, 0, 0,			/* func 065		*/
	0, 0, 0, 0,			/* func 066		*/
	0, 0, 0, 0,			/* func 067		*/
	0, 0, 0, 0,			/* func 068		*/
	0, 0, 0, 0,			/* func 069		*/
	4, 3, 0, 0,			/* func 070		*/
	8, 3, 0, 0,			/* func 071		*/
	6, 1, 0, 0,			/* func 072		*/
	8, 1, 0, 0,			/* func 073		*/
	8, 1, 0, 0,			/* func 074		*/
	4, 1, 1, 0,			/* func 075		*/
	3, 1, 1, 0,			/* func 076		*/
	0, 5, 0, 0,			/* func 077		*/
	1, 1, 1, 0,			/* func 078		*/
	0, 5, 0, 0,			/* func 079		*/
	0, 1, 1, 0,			/* func 080		*/
	0, 1, 1, 0,			/* func 081		*/
	0, 0, 0, 0,			/* func 082		*/
	0, 0, 0, 0,			/* func 083		*/
	0, 0, 0, 0,			/* func 084		*/
	0, 0, 0, 0,			/* func 085		*/
	0, 0, 0, 0,			/* func 086		*/
	0, 0, 0, 0,			/* func 087		*/
	0, 0, 0, 0,			/* func 088		*/
	0, 0, 0, 0,			/* func 089		*/
	0, 2, 2, 0,			/* func 090		*/
	0, 2, 3, 0,			/* func 091		*/
	0, 0, 0, 0,			/* func 092		*/
	0, 0, 0, 0,			/* func 093		*/
	0, 0, 0, 0,			/* func 094		*/
	0, 0, 0, 0,			/* func 095		*/
	0, 0, 0, 0,			/* func 096		*/
	0, 0, 0, 0,			/* func 097		*/
	0, 0, 0, 0,			/* func 098		*/
	0, 0, 0, 0,			/* func 099		*/
	5, 1, 0, 0,			/* func 100		*/
	5, 1, 0, 0,			/* func 101		*/
	1, 1, 0, 0,			/* func 102		*/
	1, 1, 0, 0,			/* func 103		*/
	2, 5, 0, 0,			/* func 104		*/
	6, 1, 0, 0,			/* func 105		*/
	2, 1, 0, 0,			/* func 106		*/
	1, 1, 0, 0,			/* func 107		*/
	6, 5, 0, 0,			/* func 108		*/
	0, 1, 0, 0,			/* func 109		*/
	0, 1, 1, 0,			/* func 110		*/
	0, 1, 0, 0,			/* func 111		*/
	2, 1, 0, 1,			/* func 112		*/
	2, 1, 1, 0,			/* func 113		*/
	1, 1, 1, 0,			/* func 114		*/
	0, 1, 1, 0,			/* func 115		*/
	0, 0, 0, 0,			/* func 116		*/
	0, 0, 0, 0,			/* func 117		*/
	0, 0, 0, 0,			/* func 118		*/
	0, 0, 0, 0,			/* func 119		*/
	0, 1, 2, 0,			/* func 120		*/
	3, 1, 2, 0,			/* func 121		*/
	1, 1, 1, 0,			/* func 122		*/
	1, 1, 1, 0,			/* func 123		*/
	0, 1, 1, 0,			/* func 124		*/
	0, 1, 2, 0,			/* func 125		*/
	1, 1, 1, 0,			/* func 126		*/
	0, 1, 1, 0,			/* func 127		*/
	1, 1, 1, 0,			/* func 128		*/
	0, 1, 1, 0,			/* func 129		*/
	1, 1, 0, 0,			/* func 130		*/
	0, 0, 0, 0,			/* func 131		*/
	0, 0, 0, 0,			/* func 132		*/
	0, 0, 0, 0,			/* func 133		*/
	0, 0, 0, 0,			/* func 134		*/
	0, 0, 0, 0,			/* func 135		*/
	0, 0, 0, 0,			/* func 136		*/
	0, 0, 0, 0,			/* func 137		*/
	0, 0, 0, 0,			/* func 138		*/
	0, 0, 0, 0,			/* func 139		*/
};

	WORD
crys_if(opcode)
	WORD		opcode;
{
	WORD		i;
	BYTE		*pctrl;

	control[0] = opcode;

	pctrl = &ctrl_cnts[(opcode - 10) * 4];
	for(i=1; i<C_SIZE; i++)
	  control[i] = *pctrl++;

	crystal(ad_c);
	return( RET_CODE );
}


	WORD
appl_init()
{
	WORD		i;

	c.cb_pcontrol = ADDR(&control[0]);
	c.cb_pglobal = ADDR(&global[0]);
	c.cb_pintin = ADDR(&int_in[0]);
	c.cb_pintout = ADDR(&int_out[0]);
	c.cb_padrin = ADDR(&addr_in[0]);
	c.cb_padrout = ADDR(&addr_out[0]);

	ad_c = ADDR(&c);
	crys_if(APPL_INIT);
	gl_apid = RET_CODE;
	return( gl_apid );
}
