/*	MESSAGE.H		9/21/92			Derek Mui		*/

#define AP_MSG 		0
#define WM_USER	    	0
#define MN_SELECTED 	10

#define WM_REDRAW 	20
#define WM_TOPPED 	21
#define WM_CLOSE 	22
#define WM_FULLED 	23
#define WM_ARROWED 	24
#define WM_HSLID 	25
#define WM_VSLID 	26
#define WM_SIZED 	27
#define WM_MOVED 	28
#define WM_UNTOPPED	30
#define WM_ONTOP	31

#define AC_OPEN 	40
#define AC_CLOSE 	41

#define AP_TERM		50	/* Request app to terminate	*/
#define AP_TFAIL	51	/* Fail to terminate or close	*/	
#define AP_TSUCCESS	52	/* Termination success		*/ 

#define CT_KEY		53	/* CPX */
#define CT_MULTI	55	/* CPX */

#define AP_RESCHG	57	/* resolution change		*/
#define AP_ACTIVE	58	/* application becomes active/not	*/

#define SHUT_COMPLETED	60	/* shutdown completed		*/
#define RESCH_COMPLETED 61	/* resolution changed completed */

#define	AP_DRAGNDROP	63	/* application drag and drop	*/

#define DK_INFLOAD	70	/* Load in INF again		*/
#define DK_ICNLOAD	71	/* Load in ICN file again	*/	
#define SH_WDRAW	72	/* redraw windows		*/

/*	The above values are published and can't be changed */

#if 0

#define	TO_SLEEP	65	/* Request to sleep, change to icon */
#define TO_WAKEUP	66	/* Request to wake up	*/
#define TO_SFAIL	67	/* Sleep fail		*/
#define TO_WFAIL	68	/* wake up fail		*/

#define SH_REQUE	70	/* Request mode		*/
#define SH_ACKNO	71	/* Acknowledge	mode	*/

#define	SH_XCOPY	72	/* file copy	*/
#define	SH_XDELE	73	/* file delete	*/
#define SH_XMOVE	74	/* file move	*/

#define SH_FORMA	75	/* format disk	*/
#define SH_PRINT	76	/* print file	*/
#define SH_SHOW		77	/* show a file	*/
#define SH_EXIT		78	/* Default shell exits 	*/
#define SH_START	79	/* Default shell starts */
#define SH_WDRAW	80	/* redraw certain window	*/
#define SH_WCLOSE	81	/* close certain window		*/

#define	TO_SLEEP	65	/* Request to sleep, change to icon */
#define TO_WAKEUP	66	/* Request to wake up	*/
#define TO_SFAIL	67	/* Sleep fail		*/
#define TO_WFAIL	68	/* wake up fail		*/

#define SH_REQUE	70	/* Request mode		*/
#define SH_ACKNO	71	/* Acknowledge	mode	*/

#define	SH_XCOPY	72	/* file copy	*/
#define	SH_XDELE	73	/* file delete	*/
#define SH_XMOVE	74	/* file move	*/

#define SH_FORMA	75	/* format disk	*/
#define SH_PRINT	76	/* print file	*/
#define SH_SHOW		77	/* show a file	*/
#define SH_EXIT		78	/* Default shell exits 	*/
#define SH_START	79	/* Default shell starts */
#define SH_WDRAW	80	/* redraw certain window	*/
#define SH_WCLOSE	81	/* close certain window		*/

#endif

#define	CH_EXIT		90	/* child process exit		*/

