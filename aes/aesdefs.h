#ifndef AESDEFS_H
#define AESDEFS_H

#undef AESVERSION
#define AESVERSION 0x120

#undef AESVERSION
#define AESVERSION 0x140

#undef AESVERSION
#define AESVERSION 0x310

#undef AESVERSION
#define AESVERSION 0x320

#ifndef MULTITOS
#define MULTITOS 0
#endif

#define NUM_ACCS 1			/* for atari in rom		*/
#define NUM_PDS (NUM_ACCS + 2)		/* acc's + ctrlpd + dos appl.	*/
#define NUM_EVBS (NUM_PDS * 5)		/* 5 * the number of PDs	*/
#define MAX_ACCS 6			/* for atari, from disk		*/
#define EVB_PROC 5			/* for atari, number of EVB per process */

#define KBD_SIZE 8

#define CARTRIDGE	1	/* if rom cartridge exists */

#define UNLINKED	0	/* if desktop not linked with gem */

#define DOWARNING	0	/* Do we need initial warning box ?  */


#define	MAXOBJ	    19		/* maximum number of objects in a window */

#define	NUM_WIN	8		/* # window structures per block of memory */

#define STACK_SIZE  448
#define STACK2_SIZE 300
#define STACK3_SIZE 350
#define NFORKS      32
#define QUEUE_SIZE 128

#define CMDLEN 128


#endif /* AESDEFS_H */
