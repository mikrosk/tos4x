/* A set of useful defines for SPARROW */
/* Complied from everybody working on the machine */

#define		Config		((volatile char *) 0xFFFF8006L)
#define		Clock_Sel	((volatile char *) 0xFFFF8007L)
#define		VID_BH		((volatile int *) 0xFFFF8200L)
#define		VID_BM		((volatile int *) 0xFFFF8202L)
#define		VID_BL		((volatile int *) 0xFFFF820CL)
#define		SYNCMODE	((volatile char *) 0xFFFF820AL)
#define		HOFF		((volatile int *) 0xFFFF820EL)	
#define		VWRAP		((volatile int *) 0xFFFF8210L)
#define		ST_Palette	((volatile int *) 0xFFFF8240L)
#define		ST_Shift	((volatile char *) 0xFFFF8260L)
#define		SP_Shift	((volatile int *) 0xFFFF8266L)
#define		HHT		((volatile int *) 0xFFFF8282L)	/* Horiz Half Total */
#define		HBB		((volatile int *) 0xFFFF8284L)
#define		HBE		((volatile int *) 0xFFFF8286L)
#define		HDB		((volatile int *) 0xFFFF8288L)
#define		HDE		((volatile int *) 0xFFFF828AL)
#define		HSS		((volatile int *) 0xFFFF828CL)
#define		HFS		((volatile int *) 0xFFFF828EL)
#define		HEE		((volatile int *) 0xFFFF8290L)
#define		VFT		((volatile int *) 0xFFFF82A2L)
#define		VBB		((volatile int *) 0xFFFF82A4L)
#define		VBE		((volatile int *) 0xFFFF82A6L)
#define		VDB		((volatile int *) 0xFFFF82A8L)
#define		VDE		((volatile int *) 0xFFFF82AAL)
#define		VSS		((volatile int *) 0xFFFF82ACL)
#define		VMC		((volatile int *) 0xFFFF82C0L)
#define		VCO		((volatile int *) 0xFFFF82C2L)
#define		VTC		VCO
#define		SP_Palette	((volatile int *) 0xFFFF9800L)

/* Equates file for Testing of SPARROW sound DMA channels */

#define		s_dma_ctl2	((volatile char *) 0x00ff8900L)
#define		s_dma_ctl	((volatile char *) 0xFFFF8901L)
#define		 REC_SET	0x80
#define		 PLAY_SET	0x00
#define		 REC_REP	0x20
#define		 REC_SINGLE	0x00
#define		 REC_ENABLE	0x10
#define		 PLAY_REP	0x02
#define		 PLAY_SINGLE	0x00
#define		 PLAY_ENABLE	0x01

#define		f_b_um		((volatile char *) 0xFFFF8903L)
#define		f_b_lm		((volatile char *) 0xFFFF8905L)
#define		f_b_ll		((volatile char *) 0xFFFF8907L)

#define		f_a_um		((volatile char *) 0xFFFF8909L)
#define		f_a_lm		((volatile char *) 0xFFFF890BL)
#define		f_a_ll		((volatile char *) 0xFFFF890DL)

#define		f_e_um		((volatile char *) 0xFFFF890FL)
#define		f_e_lm		((volatile char *) 0xFFFF8911L)
#define		f_e_ll		((volatile char *) 0xFFFF8913L)

/* Note this block of registers exist
   only in the Falcon version of this chip */
#define		f_b_uu		((volatile char *) 0xFFFF8915L)
#define		f_a_uu		((volatile char *) 0xFFFF8917L)
#define		f_e_uu		((volatile char *) 0xFFFF8919L)

#define		s_mode_ctl	((volatile short *) 0xFFFF8920L)
#define		 M_CHAN_0	0x0000
#define		 M_CHAN_1	0x1000
#define		 M_CHAN_2	0x2000
#define		 M_CHAN_3	0x3000
#define		 M_CHAN_4	0x4000
#define		 M_CHAN_OFF	0x7000
#define		 M_CHAN_MASK	0x7000

#define		 A_CHAN_1	0x0000
#define		 A_CHAN_2	0x0100
#define		 A_CHAN_3	0x0200
#define		 A_CHAN_4	0x0300
#define		 A_CHAN_5	0x0400
#define		 A_CHAN_MASK	0x0700

#define		 MONO_MODE	0x0080
#define		 WORD_MODE	0x0040

#define		 S_RT_160	0x0003
#define		 S_RT_320	0x0002
#define		 S_RT_640	0x0001
#define		 S_RT_1280	0x0000
#define		 S_RT_MASK	0x0003

#define		uwire_data	((volatile short *) 0xFFFF8922L)
#define		uwire_mask	((volatile short *) 0xFFFF8924L)
#define		MAX_CHANNELS	5

#define		SND		0x8000
#define		INPUT_SELECT	0x0000
#define		 PSG_OFF	0x0000
#define		 PSG_EN		0x0020
#define		 PSG_DIS	0x0040
#define		BASS		0x0800
#define		 FLAT		0x00C0
#define		TREBLE		0x1000
#define		VOLUME		0x1800
#define		 V_FULL		0x0500
#define		RIGHT_FADE	0x2000
#define		 FADE_OFF	0x0280
#define		LEFT_FADE	0x2800
#define		SCALE		0x3000
#define		CONTROL		0x3800
#define		 MHZ8		0x0200
#define		 MHZ7		0x0300
#define		 MIX_ADC	0x0080
#define		 MIX_AUX	0x0000
#define		 MUX_AUX	0x0060
#define		 MUX_ADC	0x0040
#define		 MUX_IN		0x0020
#define		MASK		0xFFE0

#ifndef NULL
#define		NULL		0
#endif
