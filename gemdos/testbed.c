/*
 * testbed for GEMDOS.
 */

#include "fs.h"

short buf[1024];

voidfn
main(argc,argv)
int argc;
char *argv[];
{
	int h;

	osi();

	for (h=0; h<1024; h++) buf[h] = h;

	xmkdir("n:\\subdir");
	h = xcreat("n:\\subdir\\test.file",0);
	xwrite(h,2048,buf);		/* middle only, start of file */
	xwrite(h,2048,buf);		/* middle only, extend file */
	xwrite(h,512,buf);		/* middle only, extend file */
	xclose(h);
	h = xopen("n:\\subdir\\test.file",1);
					/* sequence without extending file */
	xwrite(h,10L,"now is the");	/* tail start at start of sector */
	xwrite(h,2048L,buf);		/* head, mid, and tail */
	xwrite(h,10L," time for ");	/* head start & end in sector */
	xwrite(h,512-20,buf);		/* head ends at end of sector */
	xwrite(h,2048L,buf);		/* middle only */
	xclose(h);
	xdelete("n:\\subdir\\test.fil");
	xrmdir("n:\\subdir");

	DBMSG(-1,"testbed done");
}

