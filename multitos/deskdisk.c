/*	DESKDISK.C From 1.4 	12/7/87 - 12/15/87	Derek.Mui	*/
/*	For newdesktop		3/18/89	- 6/15/89	Derek Mui	*/
/*	Update and crunch	8/30/89			D.Mui		*/
/*	Change at fc_format	1/29/90			D.Mui		*/
/*	Add high density formatting	2/21/90		D.Mui		*/
/*	Change the up_allwin to up_1allwin	11/14/90	D.Mui	*/
/*	Fix the high density button		11/20/90	D.Mui	*/
/*	Change the high density media cookie value	4/26/91	D.Mui	*/
/*	Change the setting of FCDOUBLE button		4/30/91	D.Mui	*/

/*	Discussion of skew factors
*	
*	The optimal skew factor for single/double sided formats is:
*	7 8 9 1 2 3 4 5 6
*	5 6 7 8 9 1 2 3 4
*	( that is, a skew factor of 2 )
*
*	This is because the floppy drive always does a seek-with-verify,
*	so the controller needs to read sector 9, seek to the next head/side
*	( where it's too late to catch the ID of sector 8 ), read the sector
*	ID of sector 9 ( to verify the seek; now the seek is done ). and
*	then begin reading with sector 1.
*
*	However, some Atari single-sided drives are actually 6ms drives.
*	They have extra circuitry to convert the 3ms step pulses into 
*	6ms pulses, but this slows them down enough that the above
*	skew factor is not enough. Hence, single-sided disks are formatted
*	with a skew factor of 3 ( or 6, depending ).
*/
/*	Fc_draw will use check and set mode for wm_update 7/14/92	*/
/*	However, in some case, it must use the absolute wait mode 	*/ 


/************************************************************************/
/*	New Desktop for Atari ST/TT Computer				*/
/*	Atari Corp							*/
/*	Copyright 1989,1990 	All Rights Reserved			*/
/************************************************************************/

#include <portab.h>
#include <deskobde.h>
#include <deskdefi.h>
#include <deskwin.h>
#include <gemdefs.h>
#include <deskusa.h>
#include <osbind.h>
#include <extern.h>

EXTERN	BYTE	*malloc();
EXTERN	LONG	trap14();
EXTERN	LONG	trap13();
EXTERN	OBJECT	*get_tree();
EXTERN	BYTE	*get_string();

#define MAXTRACK	80	/* maximum number of track		*/
#define FC_NUMOBJS	26
#define MAXSPT		18	/* Maximum sector / track		*/
#define	SECSIZE		512
#define	TRKSIZE		0x1200	/* (bytesPerSector) * (sectorsPerTrack) */
#define RWABS		4	/* BIOS read/write sectors		*/
#define RSECTS		2	/* |= 0x02 so mediach state is not checked */
#define WSECTS		3
#define	GETBPB		7	/* BIOS Get Bios Parameter Block	*/
#define READTRK		8	/* XBIOS read track  (floprd)		*/
#define	WRITRK		9	/* XBIOS write track (flopwr)		*/
#define FORMAT		10	/* XBIOS format (flopfmt)		*/
#define	PROTOBT		18	/* XBIOS prototype a boot sector	*/

#define FSIZE		0x4000L	/* format buffer size (16k)		*/
#define	VIRGIN		0xe5e5	/* FORMAT value to write to new sectors	*/
#define	MAGIC		0x87654321L
#define INTERLV		-1	/* neg, so use skew table for format	*/
#define SINGLESKEW	3	/* amount of SKEW for a single sided and 
				   high density disk */
#define	DOUBLESKEW	2	/* amount of skew between sides		*/

#define	BADSECT		-16
#define MAXBAD		16	/* max number of bad sector allowed	*/

#define BPB	struct bpb	/* BIOS Parameter Block	*/
BPB {
	WORD	recsiz;		/* sector size (bytes)		*/
	WORD	clsiz;		/* cluster size (sectors)	*/
	WORD	clsizb;		/* cluster size (bytes)		*/
	WORD	rdlen;		/* root directory size (sectors)*/
	WORD	fsiz;		/* FAT size (sectors)		*/
	WORD	fatrec;		/* Sector # of second FAT	*/
	WORD	datrec;		/* Sector # of data		*/
	WORD	numcl;		/* Number of data clusters	*/
	WORD	b_flags;	/* flags (1 => 16 bit FAT)	*/
};

/* The DSB location is returned by getbpb (Xbios 7) and is defined in
*	gemdos/rwabs.c.  We use it to determine the # of sides for
*	fc_copy, since it's easier to call getbpb and use the
*	system data structures than to read the boot sector
*	ourselves. getbpb actually returns a pointer to
*	this global system structure.
*	(kbad 880830)
*/

#define DSB	struct dsb	/* Device Status Block		*/
DSB {
	BPB	b;		/* BIOS Parameter Block		*/
	WORD	dntracks,	/* #tracks (cylinders) on dev	*/
		dnsides,	/* #sides per cylinder		*/
		dspc,		/* #sectors/cylinder		*/
		dspt,		/* #sectors/track		*/
		dhidden;	/* #hidden tracks		*/
	char	dserial[3];	/* 24-bit volume serial number	*/
};

MLOCAL	BYTE	FMDTAIL[] = "-f A:";
MLOCAL	BYTE	COPYTAIL[] = "-c A: B:";
MLOCAL	BYTE	DESKFMT[] = "DESKFMT=";	
MLOCAL	WORD	w_inc;
MLOCAL	WORD	bar_max;	/* in case user copies disk > 80 tracks */
MLOCAL	WORD	ttable[ ] = { FCCNCL, FCCOPY, FCFORMAT, SRCDRA, SRCDRB, ADRIVE,
			      BDRIVE };

MLOCAL 	WORD	skew1[MAXSPT*2] = { 1,2,3,4,5,6,7,8,9,10,11,
				    12,13,14,15,16,17,18,
				    1,2,3,4,5,6,7,8,9,10,11,
				    12,13,14,15,16,17,18 };

MLOCAL 	WORD	skew2[MAXSPT] = { 1,2,3,4,5,6,7,8,9,1,2,3,4,5,6,7,8,9 };

MLOCAL	WORD	d_handle;


/*	format and copy start	*/

	VOID
fc_start( source, op )
	BYTE	*source;
	WORD	op;
{
	REG WORD	ret,width;
	WORD		i,field,operation;
	REG BYTE	*destdr;
	REG OBJECT	*obj;
	LONG		value,save;	
	BYTE		*bptr;
	BYTE		tail[20];

	/* Launch process if DESKFMT= is in the environment */

	shel_envrn( &bptr, DESKFMT );
	if ( bptr )
	{
	  if ( op == CMD_COPY )		/* copy operation command tail */
	  {
	    strcpy( COPYTAIL, &tail[1] );
	    tail[4] = *source;		/* source drive */
	    tail[7] = ( tail[4] == 'A' ) ? 'B' : 'A';
	  }
	  else
	  {
	    strcpy( FMDTAIL, &tail[1] );/* format operation command tail */
	    tail[4] = *source;	
	  }

	  tail[0] = (BYTE)strlen( &tail[1] );

	  ret = shel_write( 0, 0, 1, bptr, tail );
	  if ( !ret )
	    fill_string( bptr, FTOLAUNCH );
	  else
	    return;
	}

	obj = get_tree( ADFORMAT );

	/* check for switch in cookie jar	*/

	obj[FCHIGH].ob_flags = HIDETREE;

	if ( getcookie( 0x5F464443L, &value ) )	/* FDC cookie	*/
	{
	  if ( value & 0xFF000000L )		/* high density	*/
	    obj[FCHIGH].ob_flags = SELECTABLE|RBUTTON|IS3DOBJ;
	  else
	    goto fc_2; 
	}
	else
	{
fc_2:	  if ( obj[FCHIGH].ob_state & SELECTED )
	  {
	    obj[FCHIGH].ob_state = NORMAL;
	    obj[FCDOUBLE].ob_state = SELECTED;
	  }
	}


	destdr = &obj[DESTDR].ob_spec;		/* to set boxchar in DESTDR */
	
	width = obj[FCBARA].ob_width;
	w_inc = width / MAXTRACK;
	bar_max = width = w_inc * MAXTRACK;
	obj[FCBARB].ob_width = obj[BARA].ob_width = obj[BARB].ob_width = obj[FCBARA].ob_width = width;
	
	obj[BARA].ob_x = obj[FCBARA].ob_x;
	obj[BARA].ob_y = obj[FCBARA].ob_y;
	obj[BARB].ob_x = obj[FCBARB].ob_x;
	obj[BARB].ob_y = obj[FCBARB].ob_y;
	

	for ( i = 0 ; i < 7; i++ )
	  obj[ttable[i]].ob_state = NORMAL;

	inf_sset( obj, FCLABEL, Nostr );

	obj[FCBOXF].ob_flags |= HIDETREE;
	obj[FCBOXC].ob_flags |= HIDETREE;

	ret = ( *source == 'A' );
	
	if ( op == CMD_COPY )
	{				/* format box	*/
	  obj[ ret ? BDRIVE : ADRIVE ].ob_state = SELECTED;
					/* copy box	*/
	  obj[ ret ? SRCDRA : SRCDRB ].ob_state = SELECTED;
	  *destdr = ret ? 'B' : 'A';
	  obj[FCCOPY].ob_state = SELECTED;
	  ret = FCCOPY;
	} 
	else 
	{ 				/* op == CMD_FORMAT 	*/
					/* copy box 		*/
	  obj[ ret ? SRCDRB : SRCDRA ].ob_state = SELECTED;
	  *destdr = ret ? 'A' : 'B';
						/* format box */
	  obj[ ret ? ADRIVE : BDRIVE ].ob_state = SELECTED;
	  obj[FCFORMAT].ob_state = SELECTED;
	  ret = FCFORMAT;
	}

#if 0
	d_handle = dr_dial_w( ADFORMAT, TRUE, MOVE|NAME );
#else
	d_handle = dr_dial_w( ADFORMAT, FALSE, 0 );
#endif
	operation = FALSE;

	while ( TRUE )			/* while loop 	*/
	{
fc_1:	  switch( ret )
	  {
	    case FCFORMAT:
	      w_draw_fld( d_handle, obj, FCBOXC );	/* erase copy function */
	      obj[FCBOXC].ob_flags |= HIDETREE;
	      obj[FCBOXF].ob_flags &= ~HIDETREE;
	      fc_draw( obj, FCBOXF, 1 );	/* draw the format	*/
	      field = 0; 
	      break;

	    case FCCOPY:
	      w_draw_fld( d_handle, obj, FCBOXF );	/* erase the format 	*/
	      obj[FCBOXF].ob_flags |= HIDETREE;
	      obj[FCBOXC].ob_flags &= ~HIDETREE;
	      fc_draw( obj, FCBOXC, 1 );
	      field = -1;
	      break;

	    case SRCDRA:		/* set the copy drive	*/
	    case SRCDRB:
	      *destdr = ( ret == SRCDRA ) ? 'B' : 'A';
	      w_draw_fld( d_handle, obj, DESTDR );
	      break;

	    case FCCNCL:		/* cancel		*/
	      if ( d_handle < 0 )	/* ++ERS 12/21/92 */
	        do_finish( ADFORMAT );	/* ++ERS 12/21/92 */
	      if ( operation )
	      {
	        up_1allwin( "A", FALSE, TRUE );
	        up_1allwin( "B", FALSE, TRUE );
	      }
	      if (d_handle >= 0 )	/* ++ERS 12/21/92 */
	      {
	        wind_close( d_handle );
		wind_delete( d_handle );
	      }
	      return;
	
	    case FCOK:
/*	      desk_mice( HOURGLASS );	*/
/*	      obj[BARA].ob_width = 0;	*/
/*	      obj[BARB].ob_width = 0;	*/

	      operation = TRUE;
	      save = obj[BARA].ob_spec;
	
	      if ( obj[FCFORMAT].ob_state & SELECTED )
	        ret = fc_format( obj );
	      else
	      {
                fc_copy( obj );
		ret = TRUE;
	      }

	      obj[BARB].ob_spec = obj[BARA].ob_spec = save;	
	      obj[BARA].ob_width = width;
	      obj[BARB].ob_width = width;
	      obj[FCOK].ob_state = NORMAL;
	      w_draw_fld( d_handle, obj, FCBARA );
 	      w_draw_fld( d_handle, obj, FCBARB );
	      w_draw_fld( d_handle, obj, FCOK );
/*	      desk_mice( ARROW );	*/
	      if ( !ret )
	      {
		ret = FCCNCL;
		goto fc_1;
	      }		
	  }

	  ret = form_do( obj, field ) & 0x7FFF;
	}		
}


/*	format disk	*/

	WORD
fc_format( obj )
	OBJECT	*obj;
{
REG	BYTE	*bufaddr;
REG	WORD	badindex, ret, i, trackno;
	LONG	dsb, valuel, value2;
	WORD	devno, j, k, disktype;
	WORD	sideno, curtrk,	skew, skewi;
	WORD	track, numside, cl;
REG	WORD	*badtable;
REG	WORD	*fat;
REG	BPB	*bpbaddr;
	BYTE	label1[14];
	BYTE	label2[14];
	LONG	lbuf[4];
	WORD	spt;
	WORD	*sktable;
	
						/* format needs 8k buffer   */
	if( !(bufaddr = malloc( FSIZE )) ) 	/* no memory		    */
	{
memerr:	  do1_alert( FCNOMEM );
	  return( TRUE );
	}

	fat = bufaddr;		/* the bad sector table		*/

						/* my bad sector table	    */
	if ( !(badtable= malloc( FSIZE )) )	/* no memory		    */
	{
	  Mfree( bufaddr );
	  goto memerr;
	}

	track = MAXTRACK;		/* always 80 tracks	*/
	spt = 9;
	numside = 2;			/* assume double sided	*/
	disktype = 3;
	sktable = skew2;

	if ( obj[FCSINGLE].ob_state & SELECTED )
	{
	  numside = 1;			/* it is single sided	*/
	  disktype = 2;		
	}
	else
	{
	  if ( obj[FCHIGH].ob_state & SELECTED )
	  {
	    spt = 18;
	    disktype = 4;
	    sktable = skew1;	
	  }
	}

	devno = ( obj[ADRIVE].ob_state & SELECTED ) ? 0 : 1;

	ret = 0;			/* assume it is ok	*/
	badindex = 0;			/* bad sector table	*/

				/* amount of skew from track to track	*/
	skew = ( ( numside == 1 ) || ( disktype == 4 ) ) ? SINGLESKEW : DOUBLESKEW;

	skewi = 0;

	for( trackno = 0; (trackno < track) && (!ret); trackno++ )
	{
	  for( sideno = 0; (sideno < numside) && (!ret); sideno++ )
	  {
	     skewi -= skew;
	     if ( skewi < 0 )
	       skewi += spt;

fagain:	     ret = (WORD)( trap14( FORMAT, bufaddr, &sktable[skewi], devno,
			spt, trackno, sideno, INTERLV, MAGIC, VIRGIN ) );

	     if ( ret == -16 )		/* Bad sectors !	*/
	     {
	       if ( ( trackno < 2 ) || ( (badindex + spt) >= MAXBAD ) )
	       {
		 if ( do1_alert( FCFAIL ) == 1 )	/* too many bad sectors	*/
		   goto fagain;
		 else
		   ret = 1;

		 break;		
	       }
	       else	
	         for ( i = 0; fat[i]; i++, badindex++ )
		 {
		   badtable[badindex] = ( trackno * numside * spt ) +
		   ( (fat[i] - 1) + ( sideno * spt ) );

		   ret = 0;	
		 }
	      }	/* if errror == 16 */
	
	      if ( ret )		/* some other error	*/
	      {				/* retry		*/
		if ( do1_alert( FCFAIL ) == 1 )
		  goto fagain;
	      }

	   }/* sideno	*/

	  fc_bar( obj, devno );		/* increment destination bar	*/

	}/* for trackno	*/

	if ( ! ret )			/* set up the Boot Sector info	*/
	{
	  trap14( PROTOBT, bufaddr, 0x01000000L, disktype, 0 ); 
	  *bufaddr = 0xe9;

	  if( ret = fc_rwsec(WSECTS, bufaddr, 0x10000L, devno) )
	    goto eout1;
					/* now set up the fat0 and fat1	*/
	  bpbaddr = trap13( GETBPB, devno );

	  /* 27-Mar-1985 lmd
	   * write boot sector again
	   * (this makes the media dirty, with drivemode = "changed")
	  */

	  if( ret = fc_rwsec(WSECTS, bufaddr, 0x10000L, devno) )
	    goto eout1;

	  k = max( bpbaddr->fsiz, bpbaddr->rdlen );
	  j = ( k * SECSIZE) / 2;

				/* clean up root directory	*/
	  for ( i = 0; i < j; i++ )
	    fat[i] = 0;	
				/* get the label	*/
	  strcpy( (TEDINFO*)(obj[FCLABEL].ob_spec)->te_ptext, label1 );

	  if ( label1[0] )
	  {
	    bfill( 11, ' ', label2 );
	    i = 0;
	    while( label1[i] )
	    {
	      label2[i] = label1[i];
	      i++;
	    }

	    LBCOPY( bufaddr, label2, 11 );
	    fat[5] |= 0x0008;	/* file attribute	*/
	  }
				
	  i = 1 + ( bpbaddr->fsiz * 2 );

	  if( ret = fc_rwsec( WSECTS, bufaddr, bpbaddr->rdlen, i, devno ) )
	    goto eout1;

				/* clean up FAT table	*/
	  for ( i = 0; i < j; i++ )
	    fat[i] = 0;

	       			/* the first 3 bytes have to be 0xF7FFFF*/	

	  fat[0] = 0xF9FF;	/* MS-DOS format		*/
	  fat[1] = 0xFF00;
				/* now make up the sector map	*/
	  for ( i = 0; i < badindex; i++ )
	  {
	    cl = ( badtable[i] - bpbaddr->datrec) / bpbaddr->clsiz + 2;
	    clfix ( cl, fat );
	  }
						/* write out fat 0	*/
	  if( ret = fc_rwsec( WSECTS, fat, bpbaddr->fsiz, 1, devno ) )
	    goto eout1; 
						/* write out fat 1	*/
	  ret = fc_rwsec( WSECTS, fat,
	  		  bpbaddr->fsiz, 1 + bpbaddr->fsiz, devno );

	}
eout1:	  
	/* now compute the size in bytes and tell the user 	*/

/*      desk_mice( ARROW );	*/
	
	if ( !ret )
	{
	  Dfree( lbuf, devno + 1 );
	  lbuf[0] = lbuf[0] * lbuf[2] * lbuf[3]; 
	  merge_str( g_buffer, get_string( FCSIZE ), lbuf );
	  if ( form_alert( 1, g_buffer ) == 1 )
	    ret = TRUE;		/* To Continue	*/
	}

	Mfree( bufaddr );
	Mfree( badtable );
	return( ret );
}


/*	disk copy	*/

	VOID
fc_copy( obj )
	OBJECT	*obj;
{
REG	LONG	bootbuf, buf;
	LONG	bufptr, bufsize;
	WORD	devnos, devnod;
REG	DSB	*dsbs, *dsbd;
	WORD	spc, bps, bpc, disksect, sectbufs, leftover;
	WORD	checkit, last, ret;
	WORD	dev, sectno, ssect, dsect, trkops;
REG	WORD	j, op, loop;

	bootbuf = malloc(0x158L );
	if( !bootbuf )
	{
errmem:	  do1_alert( FCNOMEM );
	  return;
	}

	devnos = ( obj[SRCDRA].ob_state & SELECTED ) ? 0 : 1;
	devnod = ( devnos ) ? 0 : 1;

chksrc:	if( !(dsbs = trap13(GETBPB,devnos)) )
	{
	  if( do1_alert( FCFAIL ) == 1 ) /* retry */
	    goto chksrc;
	  Mfree( bootbuf );
	  return;
	}

/* should spc exist? */
	spc = dsbs->dspc;			/* sectors per cylinder	   */
	bps = dsbs->b.recsiz;			/* bytes per sector	   */
	bpc = spc * bps;			/* bytes per cylinder	   */

						/* buffer at least a track */
	bufsize = malloc( 0xFFFFFFFFL );
	if( bufsize < (LONG)bpc )
	{
	  Mfree( bootbuf );
	  goto errmem;
	}

	disksect = spc * (dsbs->dntracks);	/* total sectors on disk    */
#if 1	/* ++ERS 12/21/92 */
	if (bufsize > ((LONG)disksect) * bps) {	/* don't take more memory than we need */
		bufsize = ((LONG)disksect) * bps;
	}
#endif
	buf = malloc( bufsize );		/* get the buffer	    */
#if 1	/* ++ ERS 12/21/92 */
	if ( !buf )				/* we have to check, when multitasking */
	{
	  Mfree( bootbuf );
	  goto errmem;
	}
#endif
	sectbufs = (bufsize / bps);		/* how many sector buffers  */
	leftover = disksect % sectbufs;		/* sectors left for last loop */

	checkit = TRUE;
	last = FALSE;
	ssect = dsect = sectno = 0;

	loop = disksect / sectbufs;		/* how many times to loop   */
	if( !loop )
	{
	  sectbufs = leftover;
	  last = TRUE;
	  loop = 1;
	}

						/* read boot sector	    */
	if( fc_rwsec(RSECTS, bootbuf, 0x00010000L, devnos) )
	  goto bailout;

	while( loop-- )
	{
	  dev = devnos;
	  for( op = RSECTS; op <= WSECTS; op++ ) /* read, write loop	    */
	  {
	    bufptr = buf;
						/* draw bar once per track  */
	    trkops = sectbufs / spc;		/* how many track operations */
	    for( j = 0; j < trkops; j++ )
	    {
	      if( fc_rwsec( op, bufptr, spc, sectno, dev) )
	        goto bailout;
	      sectno += spc;
	      bufptr += bpc;
	      fc_bar( obj, dev );
	    }
	    j = sectbufs % spc;
	    if( j )
	    {
	      if( fc_rwsec(op, bufptr, j, sectno, dev) )
		goto bailout;
	      sectno += j;
	      fc_bar( obj, dev );
	    }
	    if( op == RSECTS )
	    {
	      ssect = sectno;
	      sectno = dsect;
	      if( checkit )
	      {
		checkit = FALSE;
fc_c1:
		dsbd = trap13(GETBPB,devnod);
		if( !dsbd )
		{
		  if( do1_alert( FCFAIL ) == 1 ) /* retry */
		    goto fc_c1;
		  goto bailout;
		}
		if ( (dsbs->dnsides != dsbd->dnsides) ||
		     (spc != dsbd->dspc) ||
		     (dsbs->dntracks != dsbd->dntracks) ||
		     (bps != dsbd->b.recsiz)
		   )
		{
	  	   if ( do1_alert( FCNOTYPE ) != 1 )
	  	     goto bailout;
		
		   goto fc_c1;		/* try again	*/
	        }
	      } /* if( checkit ) */
	    }
	    else
	    {
	      dsect = sectno;
	      sectno = ssect;
	    }
	    dev = devnod;
	  } /* read, write loop */

	  if( !loop && !last )
	  {
	    loop = 1;
	    sectbufs = leftover;
	    last = TRUE;
	  }
	} /* while( loop-- ) */

						/* change the serialno */
	trap14( PROTOBT, bootbuf, 0x01000000L, -1, -1 );
	fc_rwsec(WSECTS, bootbuf, 0x00010000L, devnod);

bailout:
	Mfree( buf );
	Mfree( bootbuf );
	return;
}

	WORD
fc_rwsec( op, buf, nsect, sect, dev )
	WORD	op;
	LONG	buf;
	WORD	nsect, sect, dev;
{
REG	WORD	ret;

rerw:	if( ret = trap13(RWABS, op, buf, nsect, sect, dev) )
	  if( (ret = do1_alert(FCFAIL)) == 1 ) /* retry */
	    goto rerw;
	return( ret ); /* 0=>OK, 2=>error */
}


/*     put in the next cluster number 	*/

	VOID
clfix( cl, fat )
unsigned	WORD	cl;
unsigned	WORD	fat[];
{
REG	unsigned	WORD  ncl, cluster;
	unsigned	WORD  temp,num;

	num = 0x0FF7;

	ncl = cl + (cl >> 1);		/* multiply by 1.5	*/
					/* get the fat value 12 bit	*/

	cluster = fat[ncl] & 0x00FF;
	cluster |= fat[ncl+1] << 8;

	if (cl & 0x1)		/* is it odd ?		*/
	{
	  cluster &= 0x000F;	/* leave the last byte alone	*/
	  num = num << 4;
	}
	else
	  cluster &= 0xF000;	/* leave the high byte alone	*/	 

	num = cluster | num;		

	fat[ncl] = num;
	fat[ncl+1] = num >> 8;
}	 


/*	Inc and redraw slider bar	*/

	VOID
fc_bar( obj, which )
	REG OBJECT	*obj;
	REG WORD	which;
{
	REG WORD	wid;

	which = which ? BARB : BARA;

	wid = obj[which].ob_width;

	if ( wid == bar_max )
	  wid = 0;

	wid += w_inc; 
	
	wid = ( wid < bar_max ) ? wid : bar_max; /* don't overflow box */

	obj[which].ob_width = wid;
	obj[which].ob_spec = 0xFF1121L;
	fc_draw( obj, which, 0 );
}


/*	Draw the bar	*/

	VOID
fc_draw( obj, which, wait )
	OBJECT	*obj;
	WORD	which,wait;
{
	GRECT	size;
	WORD	mode;

	rc_copy( &obj[which].ob_x, &size );
	objc_offset( obj, which, &size.x, &size.y );
	if ( wait )
	  mode = BEG_UPDATE;
	else
	  mode = BEG_UPDATE|0x0100;

	if ( wind_update( mode ) )
	{
	  draw_loop( d_handle, obj, which, MAX_DEPTH, size.x, size.y, size.w+2, size.h );
 	  wind_update(0);
	}
	wait_msg( d_handle, obj );
}
