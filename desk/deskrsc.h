/*
 * Must include the specific resource header file;
 * the layout is actually different.
 * We can use the same header files for 2.06, 2.08 & 3.06, though.
 */
#include "rsc/306/deskus.h"

/*
 * TOS versions before 0x400 have some language dependent strings
 * hardcoded instead of begin placed in the resource file
 */

#ifndef More
extern char const More[];
extern char const Endfile[];
extern char const Cart[]; /* unused; taken from desktop.inf instead */
extern char const Cpystr[];
extern char const Delstr[];
extern char const Fileinfo[];
extern char const Foldinfo[];
extern char const Movestr[];
extern char const Readerror[];
extern char const Cantopen[];
extern char const Nomem[];
extern char const Cachetxt[];
extern char const Blttxt[];
extern char const Nconflict[];
extern char const Rname[];
extern char const Crenstr[];
extern char const Mrenstr[];
extern char const Istr[];
extern char const Isels[];
extern char const Isel[];
extern char const Istrs[];
extern char const Device[];
extern char const Sinf[];
extern char const Litem[];
#endif

