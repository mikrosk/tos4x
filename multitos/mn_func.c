/* MN_POPUP.C
 * ================================================================
 * DESCRIPTION: These are the popup menu specific routines
 *
 * 11/30/91  cjg   - created from portions of menu.c
 * 01/07/92  cjg   - modified to accomodate calls from the menubar
 * 01/13/92  cjg   - modified to remove user-called MenuIDs
 * 01/27/92  cjg   - added comments
 * 01/29/92  cjg   - Started conversion to Alcyon ( AES Version )
 * 02/19/92  cjg   - merged into AES
 * 03/23/92  cjg   - moved both BEG_MCTRL and END_CTRL - mn_popup()
 *		   - exit WaitForUpButton() only for popups
 * 03/24/92  cjg   - removed WaitForUpButton()
 *		   - use evnt_button instead.
 * 04/01/92  cjg   - redo menu_popup() to use MENU structure
 * 05/07/92  cjg   - Don't wait for an up button upon entry if
 *		     if mn_popup is called by a menubar.
 */


/* INCLUDE FILES
 * ================================================================
 */
#include <portab.h>
#include <machine.h>
#include <pdstruct.h>
#include <dispvars.h>
#include <obdefs.h>
#include <objaddr.h>
#include <gemlib.h>
#include <osbind.h>

#include "mn_tools.h"


/* EXTERNS
 * ================================================================
 */

/* MN_MENU.C */
EXTERN WORD     Menu_Insert();
EXTERN VOID     Menu_Delete();
EXTERN MENU_PTR GetMenuPtr();
EXTERN VOID	CheckMenuHeight();
EXTERN WORD	CountMenuItems();
EXTERN VOID	RestoreMenu();
EXTERN VOID	AdjustMenuPosition();


/* MN_EVENT.C */
EXTERN LONG     EvntSubMenu();
EXTERN BOOLEAN	Pop_Blit();

EXTERN OBJECT   *CurTree;
EXTERN WORD     CurMenu;
EXTERN WORD     CurObject;
EXTERN WORD	CurScroll;

/* MN_MBAR.C */
EXTERN BOOLEAN  MenuBar_Mode;
EXTERN MENU_PTR gl_menuptr;


/* in MN_TOOLS.C */
EXTERN VOID	ObjcDraw();

/* in DESKIF.S */
EXTERN WORD	wm_update();

/* in GEMEVLIB.C */
EXTERN UWORD    ev_button();


/* in OPTIMIZE.S */
EXTERN BOOLEAN  min();

/* GEMOBLIB.C */

/* APGSXIF.S */
EXTERN VOID   gsx_sclip();
EXTERN GRECT  gl_rfull;

/* GLOBALS
 * ================================================================
 */

/* FUNCTIONS
 * ================================================================
 */


/* mn_popup()
 * ================================================================
 * Displays a First Level Popup Menu.
 * 
 * GLOBALS: There are several MENUBAR globals used so that this
 *          is compatible with the menubar routines. There shouldn't
 *          be any interference with them.
 * 
 * IN:  MENU   *Menu     Contains the tree, menu, start item and scroll flag
 *      WORD   xpos      The xpos we want the menu to start on
 *      WORD   ypos      The ypos we want the menu to start on
 *	MENU   *MData    Returns the tree, menu, item and scroll flag
 *			 of the submenu that was selected.
 *
 * OUT: TRUE - The return MENU structure is valid
 *
 *      FALSE - the return Menu Structure is invalid
 *	      - FALSE means that the user clicked either on a disabled
 *		menu item, or clicked outside of any menu.
 */
BOOLEAN
mn_popup( Menu, xpos, ypos, MData )
MENU    *Menu;			/* the Input Menu Structure	   */
WORD	xpos;			/* the xpos that we want to start  */
WORD	ypos;			/* the ypos that we want to start  */
MENU	*MData;			/* the output menu structure	   */
{
    REG OBJECT   *tree;
    REG MENU_PTR MenuPtr;	/* Ptr to the Menu Node  	 */
    WORD         MenuID;	/* The menu id for the menu node */
    LONG         obj;		/* return value from evnt_submenu*/
    GRECT        rect;		/* GRECT for dummy variable      */
    BOOLEAN      flag = FALSE;	/* VALID/INVALID variable        */
    WORD         rets[4];	/* used for ev_button 	         */
    MRETS	 mk;

    flag = FALSE;		/* Set to Invalid return data    */

    ActiveTree( Menu->mn_tree );

    obj = -1L;			/* Set it to no object selected  */
    if( !MenuBar_Mode )		/* PopUp Menu Routines!          */
    {

      /* Wait for the up button */
      do
      {
        graf_mkstate( &mk.x, &mk.y, &mk.buttons, &mk.kstate );
      }while( mk.buttons );      
			        /* moved 03/23/92 cjg 		 */
      wm_update( BEG_MCTRL );	/* Lock the menus and mouse      */

      /* Get the new Menu ID! */
      if( ( MenuID = Menu_Insert( tree, Menu->mn_menu )) > 0 )
      {
        MenuPtr = GetMenuPtr( MenuID );			/* Get the ptr   */
        MWIDTH( MenuPtr )  = ObW( MPARENT( MenuPtr ));  /* Set the width */
        MHEIGHT( MenuPtr ) = ObH( MPARENT( MenuPtr ));  /* and height    */

	/* Initialize the menu data. Set the starting item */
        AssignMenuData( MenuPtr, Menu->mn_item );		

	/* Adjust for scrolling, if its wanted. Do this by checking
         * the height of the menu.
         */
	MSCROLL( MenuPtr ) = Menu->mn_scroll;
        if( Menu->mn_scroll )
            CheckMenuHeight( MenuPtr );

	/* Adjust the x and y position of the popup */
        AdjustMenuPosition( MenuPtr, xpos, ypos, &rect, FALSE, TRUE );

	/* Save the area underneath the menu */
        if( Pop_Blit( MenuPtr, FALSE ) )
        {
	  ObjcDraw( tree, MPARENT( MenuPtr ), &gl_rfull );

          obj = EvntSubMenu( MenuPtr );		 	         /* Do EVNT!*/
          Pop_Blit( MenuPtr, TRUE );				 /* Restore */
        }
        else
          obj = -2L;   /* Memory Allocation Error */
        RestoreMenu( MenuPtr );				   /* Rebuild menu  */
        Menu_Delete( MenuID );				   /* Delete Node   */
      }
    }
    else
    { /* MENU BAR ROUTINES  */

      obj = EvntSubMenu( gl_menuptr );		      /* Go Do IT!          */
      MData->mn_tree   = NULL;			      /* set the variables  */
      MData->mn_menu   = NIL;
      MData->mn_item   = NIL;
      MData->mn_scroll = FALSE;      

      if( obj == -1L )				      /* set flag if AOK      */
        flag = TRUE;				      /* For the Menu bar only*/
    }

    /* MenuID and MenuPtr are reused here...*/
    if( ( obj != -1L ) && ( obj != -2L ) )	      /* For PopUPs!       */
    {						      /* Set your variables*/
	MData->mn_tree   = CurTree;		      /* The tree!         */
	MData->mn_menu   = CurMenu;		      /* The menu          */
	MData->mn_item   = CurObject;		      /* The menu item     */
	MData->mn_scroll = CurScroll;		      /* Scroll field      */
	flag    = TRUE;
    }

    /* 03/23/92 cjg - this is so that the popups disappear immediately
     *                but the menubar itself has its own WaitForUpButton()
     */
    if( !MenuBar_Mode )
    {
      do
      {
        graf_mkstate( &mk.x, &mk.y, &mk.buttons, &mk.kstate );
      }while( mk.buttons );      
      wm_update( END_MCTRL );
    }
    return( flag );
}
