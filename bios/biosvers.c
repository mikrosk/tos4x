/*
 * biosvers: create an assembly source file with the date in it.  The
 * output file is named as the first argument; it will look like this:
 *
 *	.globl date
 *	.globl dosdate
 * 	date	equ	$mmddyyyy
 * 	dosdate	equ	$xxxx
 */

#include <stdio.h>
#include <osbind.h>

main(int argc,char *argv[])
{
    FILE *fp;
    int today = Tgetdate();
    int day = today & 0x1f;
    int month = (today & 0x1ff) >> 5;
    int year = ((today & ~0x1ff) >> 9) + 1980;

    if (argc != 2) {
	puts("Usage: biosvers <file>");
	puts("Writes global equates for date and dosdate to file");
	exit(1);
    }

    if ((fp = fopen(argv[1],"w")) == NULL) {
	printf("Can't create %s\n",argv[1]);
	exit(1);
    }

    fprintf(fp,".globl date\n.globl dosdate\n");
    fprintf(fp,"date\tequ\t$%02d%02d%04d\n",month,day,year);
    fprintf(fp,"dosdate\tequ\t$%04x\n",today);
    fclose(fp);
    exit(0);
}

