/*
******************* Revision Control System *****************************
*
* $Author: kbad $
* =======================================================================
*
* $Date: 1992/08/11 00:34:42 $
* =======================================================================
*
* $Locker:  $
* =======================================================================
*
* $Log: prtblk.c,v $
* Revision 2.5  1992/08/11  00:34:42  kbad
* TOS 4.00 Falcon030 first production version
*
* Revision 2.4  1992/07/27  20:12:04  kbad
* Nearly last Sparrow test BIOS
*
* Revision 2.3  1991/01/02  19:07:12  unknown
* Checkin to shut up rcsdiff: no changes.
*
* Revision 2.2  90/08/03  13:23:25  apratt
* TTOS FINAL RELEASE
* 
* Revision 2.1  89/02/21  17:22:18  kbad
* *** TOS 1.4  FINAL RELEASE VERSION ***
* 
* Revision 1.1  87/11/20  14:24:13  lozben
* Initial revision
* 
* =======================================================================
*
* $Revision: 2.5 $
* =======================================================================
*
* $Source: d:/tos/bios\rcs\prtblk.c,v $
* =======================================================================
*
*************************************************************************
*/
# include      "prtblkc.h"

extern int plstout (), pauxout ();
extern short prtcnt;

int prtblk (args)
PRTARG *args;

/* ______
** prtblk -- print a block of BitMap or text memory onto a printer
** atari corp  (26 March 1985)     asm
** revision 1  (27 May 1985)       lmd
** revision 2  (24 July 1985)      asm
**
** *blkptr     block pointer
** offset      bit offset
** width       x dimension
** height      y dimension
** left        left leading x
** right       right trailing x
** srcres      source resolution
** dstres      destination resolution
** *colpal     color palette pointer
** type        printer type
** port        printer port
** *masks      halftone masks pointer
**
** see PRTBLK(2) manual pages
**
** Please note that most of this code is intentionally written
** in line to minimize function call overhead.  Sorry.
*/
{
   register int i, j;
   register char *srcarg, *dstarg;

/* copy prtblk arguments */
   srcarg = (char *)args;
   dstarg = (char *)&a;
   for (i = sizeof(a); i > 0; i--)
      *dstarg++ = *srcarg++;

/* determine output port */
   if (a.port > MAXPOR)
      RETERR
   PR = (a.port == PRNTR);

/* check for text string */
   if (a.height == 0)
   {
      while (a.width--)                           /* print text string */
      {

      /* check global print count for abort */
         if (prtcnt != NOABRT)
            break;

         if (prtchr (*a.blkptr++))
            RETERR
      }
      prtcnt = -1;
      return (0);
   }

/* check print parameters (some for debug) */
   if (a.type > MAXTYP)
      RETERR
   if (a.dstres > MAXDST)
      RETERR
   if (a.srcres > MAXSRC)
      RETERR
   if (a.offset > MAXOFF)
      RETERR
   LO = (a.srcres == LOW);
   ME = (a.srcres == MEDIUM);
   HI = (a.srcres == HIGH);
   DR = (a.dstres == DRAFT);
   CD = (a.type == ATCDM);
   DW = (a.type == ATMDW);
   ED = (a.type == EPMDM);
   if (DW)                                        /* BitMap on daisy wheel */
      RETERR
   DR = (ED && !DR) ? TRUE : DR;                  /* force draft on Epson */
   if (LO && (a.width > LOWID))                   /* clip width to low */
   {
      a.right += (a.width - LOWID);
      a.width = LOWID;
   }
   else if (a.width > HIWID)                      /* clip width to high */
   {
      a.right += (a.width - HIWID);
      a.width = HIWID;
   }

/* determine halftone masks and trailing white truncation */
   if (a.masks == 0)
   {
      a.masks = dmasks;
      TW = TRUE;
   }
   else
      TW = FALSE;

/* build luminance or hue/saturation/intensity palettes */
   if (HI)
      invid = *a.colpal & 0x0001;                 /* inverse video bit */
   else
      for (i = 0; i < 16; i++)
      {
         duppal = (*a.colpal++) & 0x0777;         /* copy palette entry */
         if (duppal != 0x0777)                    /* check for pure white */
         {
            blue = duppal & 0x0007;
            green = (duppal >> 4) & 0x0007;
            red = (duppal >> 8) & 0x0007;
            if (CD)                               /* color hue/satur/inten */
            {
               *(intpal + i) = red;                         /* intensity */
               *(intpal + i) = (*(intpal + i) < green) ? green : *(intpal + i);
               *(intpal + i) = (*(intpal + i) < blue) ? blue : *(intpal + i);
               *(intpal + i) += 1;
               *(lumsat + i) = red;                         /* saturation */
               *(lumsat + i) = (*(lumsat + i) > green) ? green : *(lumsat + i);
               *(lumsat + i) = (*(lumsat + i) > blue) ? blue : *(lumsat + i);
               red = ((red - (*(lumsat + i) + 1)) > 0);     /* hue */
               green = ((green - (*(lumsat + i) + 1)) > 0);
               blue = ((blue - (*(lumsat + i) + 1)) > 0);
               *(huepal + i) = (red * 4) + (green * 2) + blue;
            }
            else                                  /* monochrome luminance */
            {
               *(lumsat + i) = ((red * 30)        /* NTSC RGB summation */
                  + (green * 59) + (blue * 11)) / 100;
               *(huepal + i) = 7;
               *(intpal + i) = 8;
            }
         }
         else                                     /* pure white */
         {
            *(lumsat + i) = 8;
            *(huepal + i) = 7;
            *(intpal + i) = 8;
         }
      }

/* determine pixel mapping parameters */
   if (LO)
      planes = pixhgt = pixwid = 4;
   else if (ME)
   {
      planes = pixwid = 2;
      pixhgt = 4;
   }
   else
   {
      planes = 1;
      pixhgt = 8;
      pixwid = 2;
   }
   pixwid /= (ED) ? 2 : 1;
   pixincr = ((a.left + a.width + a.right) * planes) / 16;
   rasincr = pixincr * pixhgt;

/* normalize BitMap block pointer */
/* NB -- all bits are addressed left to right */
   rasword = (short *)((long)(a.blkptr) & 0xfffffffe);
   rasbit = (rasword == (short *)a.blkptr) ? a.offset : a.offset + 8;

/* map pixels and print */
   LS = TRUE;
   for (height = 0; height < a.height; height += pixhgt)
   {

   /* check global print count for abort */
      if (prtcnt != NOABRT)
         break;

   /* truncate trailing white space if necessary */
      if (TW)
      {
         WS = TRUE;
         plzword = rasword + (((a.width * planes) / 16) - planes);
         plzbit = 15 - (a.width % 16);
         for (ajwidth = a.width; ajwidth > 0; ajwidth--)
         {
            pixlen = ((a.height - height) / pixhgt) ? pixhgt
               : a.height - height;
            pixword = plzword;
            for (i = 0; i < pixlen; i++)
            {
               index = 0;
               inbit = 1;
               plnword = pixword;
               for (j = 0; j < planes; j++)
               {
                  index += WRDBIT(*(plnword++),plzbit) * inbit;
                  inbit *= 2;
               }
               if (HI)
               {
                  if (!(index ^ invid))
                  {
                     WS = FALSE;
                     break;
                  }
               }
               else
                  if (*(lumsat + index) != 8)
                  {
                     WS = FALSE;
                     break;
                  }
               pixword += pixincr;
            }
            if (!WS)
               break;
            plzbit--;
            if (plzbit < 0)
            {
               plzword -= planes;
               plzbit = 15;
            }
         }
      }
      else
         ajwidth = a.width;

      i = ajwidth * pixwid;
      i += ((ED) ? i / 2 : 0);
      prtn1 = i % 256;
      prtn2 = i / 256;
      for (quality = 0; quality < ((DR) ? 1 : 2); quality++)
      {
         for (color = 0; color < ((CD && !HI) ? 3 : 1); color++)
         {
            if (CD && !HI)                        /* select ymc color */
               if (color == 0)
               {
                  if (prtstr (YELLO))
                     RETERR
               }
               else if (color == 1)
               {
                  if (prtstr (MAGTA))
                     RETERR
               }
               else
                  if (prtstr (CYAN))
                     RETERR
            if (prtstr ((ED) ? EBMMO : ABMMO))    /* select BitMap mode */
               RETERR
            if (prtchr (prtn1))
               RETERR
            if (prtchr (prtn2))
               RETERR
            EP = TRUE;
            plzword = rasword;
            plzbit = rasbit;
            for (width = 0; width < ajwidth; width++)
            {
               for (i = 0; i < 8; i++)
                  *(pixblk + i) = 0;
               for (i = 0; i < 4; i++)
               {
                  *(hues + i) = 7;
                  *(intens + i) = 8;
               }

            /* build pixel block */
               pixlen = ((a.height - height) / pixhgt) ? pixhgt
                  : a.height - height;
               if ((a.height - height) / pixhgt)
                  pixlen = pixhgt;
               else
               {
                  pixlen = a.height - height;
                  LS = FALSE;
               }
               pixword = plzword;
               for (i = 0; i < pixlen; i++)
               {
                  index = 0;
                  inbit = 1;
                  plnword = pixword;
                  for (j = 0; j < planes; j++)
                  {
                     index += WRDBIT(*(plnword++),plzbit) * inbit;
                     inbit *= 2;
                  }
                  if (HI)
                     *(pixblk + i) = (!(index ^ invid)) ? *a.masks : 0;
                  else
                  {
                     *(pixblk + (i*2)) = *(a.masks + (*(lumsat+index)*2));
                     *(pixblk + ((i*2)+1)) = *(a.masks
                        + ((*(lumsat+index)*2)+1));
                     *(hues + i) = *(huepal + index);
                     *(intens + i) = *(intpal + index);
                  }
                  pixword += pixincr;
               }

            /* adjust pixel block for ymc color and intensity and brown */
               if (CD && !HI)
                  for (i = 0; i < pixlen; i++)
                  {
                     CP = FALSE;
                     if (color == 0)
                     {
                        if (*(hues + i) % 2)
                           CP = TRUE;
                     }
                     else if (color == 1)
                     {
                        if ((*(hues + i) == 6) && (*(intens + i) < 8))
                        {
                           *(pixblk + (i * 2)) &= 0x01;
                           *(pixblk + ((i * 2) + 1)) &= 0x04;
                        }
                        else
                           if ((*(hues + i) == 2) || (*(hues + i) == 3)
                              || (*(hues + i) == 6) || (*(hues + i) == 7))
                              CP = TRUE;
                     }
                     else
                        if ((*(hues + i) == 6) && (*(intens + i) < 8))
                        {
                           *(pixblk + (i * 2)) &= 0x04;
                           *(pixblk + ((i * 2) + 1)) &= 0x01;
                        }
                        else
                           if (*(hues + i) > 3)
                              CP = TRUE;
                     if (CP)
                     {
                        *(pixblk + (i * 2)) = 0;
                        *(pixblk + ((i * 2) + 1)) = 0;
                     }
                     *(pixblk + (i*2)) |= *(a.masks + (*(intens+i)*2));
                     *(pixblk + ((i*2)+1)) |= *(a.masks + ((*(intens+i)*2)+1));
                  }

            /* print pixel block */
               for (i = 4; i < (pixwid + 4); i++)
               {
                  prtbyt = 0;
                  prtbit = 128;
                  for (j = 0; j < 8; j++)
                  {
                     prtbyt += BYTBIT(*(pixblk + j),i) * prtbit;
                     prtbit /= 2;
                  }
                  if (prtchr (prtbyt))            /* print byte */
                     RETERR
                  EP = !EP;
               }
               if (ED && EP)                      /* pad byte for Epson */
                  if (prtchr (prtbyt))
                     RETERR

               plzbit++;
               if (plzbit > 15)
               {
                  plzword += planes;
                  plzbit = 0;
               }
            }
            if (prtchr (CR))
               RETERR
         }
         if (prtstr (PIXLS))                      /* part LF not guaranteed */
            RETERR
         if (prtchr (LF))
            RETERR
      }
      if (DR)
         for (i = 0; i < ((ED) ? 2 : 1); i++)
         {
            if (prtstr (PIXLS))
               RETERR
            if (prtchr (LF))
               RETERR
         }
      if (LS)
      {
         if (prtstr (RASLS))
            RETERR
         if (prtchr (LF))
            RETERR
      }
      else
         for (i = 0; i < ((ED) ? ((pixlen * 6) - 3) : ((pixlen * 4) - 2)); i++)
         {
            if (prtstr (PIXLS))
               RETERR
            if (prtchr (LF))
               RETERR
         }
         rasword += rasincr;
   }

/* reset line spacing and color then return */
   prtstr (RSTLS);
   if (CD && !HI)
      prtstr (RSTCO);
   prtcnt = -1;
   return (0);
}

int prtchr (c)
char c;

/* print character c to port, return PBERR if printer port not ready */
{
   if (PR)                                        /* printer or modem port */
   {
      if (!plstout (c, c))
         return (PBERR);
   }
   else
      pauxout (c, c);
   return (0);
}

int prtstr (s)
char *s;

/* print character string s terminated by '\377' */
{
   while (*s != '\377')
      if (prtchr (*s++))
         return (PBERR);
   return (0);
}
