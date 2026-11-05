/*
 * Boot test accessory (BOOTTEST.ACC on the floppy image build/boot/boottest.st).
 * The AES loads it from the boot floppy A:, so the ROM's GEMDOS and floppy code load it.
 * It runs GEMDOS file and memory calls on A:, waits until the main application (the
 * desktop) is in its event loop, and reports a CRC-32 of the screen memory. Every result
 * goes to NatFeats stderr as a line starting with "BOOTTEST"; "BOOTTEST END" closes the
 * report and the emulation ends with NF_EXIT; "BOOTTEST info" lines carry values that may
 * differ between ROMs with the same behaviour (memory sizes). The screen memory is also
 * written to A:\SCREEN.RAW. build/boot.sh runs it.
 */
#include <mint/osbind.h>
#include <mint/falcon.h>

long nf_id_fn(const char *name);
long nf_call2(long id, long arg);
long nf_probe(void);
__asm__(
	"_nf_id_fn:\n\t.dc.w 0x7300\n\trts\n"
	"_nf_call2:\n\t.dc.w 0x7301\n\trts\n"
	"_nf_probe:\n"
	"\tmove.l a2,-(sp)\n"
	"\tmove.l 0x10,a1\n"
	"\tlea nf_ill,a0\n"
	"\tmove.l a0,0x10\n"
	"\tmove.l sp,a2\n"
	"\tpea nf_name\n"
	"\tclr.l -(sp)\n"
	"\t.dc.w 0x7300\n"
	"nf_back:\n"
	"\tmove.l a2,sp\n"
	"\tmove.l a1,0x10\n"
	"\tmove.l (sp)+,a2\n"
	"\trts\n"
	"nf_ill:\n"
	"\tmoveq #0,d0\n"
	"\tbra.s nf_back\n"
	"nf_name:\n\t.ascii \"NF_VERSION\\0\"\n\t.even\n");

long linea_screen_bytes(void);
__asm__(
	"_linea_screen_bytes:\n"
	"\tmovem.l d2/a2,-(sp)\n"
	"\t.dc.w 0xa000\n"
	"\tmoveq #0,d0\n"
	"\tmove.w -2(a0),d0\n"
	"\tmulu.w -4(a0),d0\n"
	"\tmovem.l (sp)+,d2/a2\n"
	"\trts\n");

static long nf_stderr_id, nf_exit_id, have_nf, exit_code;

static long nf_init(void)
{
	have_nf = nf_probe() != 0;
	if (have_nf) {
		nf_stderr_id = nf_id_fn("NF_STDERR");
		nf_exit_id = nf_id_fn("NF_EXIT");
	}
	return 0;
}

static long nf_exit(void)
{
	nf_call2(nf_exit_id, exit_code);
	return 0;
}

static int slen(const char *s) { int n = 0; while (s[n]) n++; return n; }

static char line[160];
static int pos;

static void put(const char *s) { while (*s && pos < (int)sizeof(line) - 3) line[pos++] = *s++; }

static void puthex(unsigned long v, int digits)
{
	char t[9];
	int i;
	for (i = digits - 1; i >= 0; i--, v >>= 4) t[i] = "0123456789abcdef"[v & 15];
	t[digits] = 0;
	put(t);
}

static void putdec(long v)
{
	char t[12];
	int n = 0;
	unsigned long u = v < 0 ? -v : v;
	if (v < 0) put("-");
	do { t[n++] = '0' + u % 10; u /= 10; } while (u);
	while (n) { char c[2] = { t[--n], 0 }; put(c); }
}

static void flush(void)
{
	line[pos++] = '\n';
	line[pos] = 0;
	if (have_nf && nf_stderr_id)
		nf_call2(nf_stderr_id, (long)line);
	pos = 0;
}

static int fails;

static void info(const char *name, long value)
{
	put("BOOTTEST info ");
	put(name);
	put(" ");
	putdec(value);
	flush();
}

static void result(const char *name, int ok, long value)
{
	put("BOOTTEST gemdos ");
	put(name);
	put(ok ? " ok " : " FAIL ");
	putdec(value);
	flush();
	if (!ok) fails++;
}

/* AES */
static short control[5], global[15], int_in[16], int_out[7];
static void *addr_in[3], *addr_out[1];
static void *aespb[6] = { control, global, int_in, int_out, addr_in, addr_out };

static short aes(short op, short nin, short nout, short nain)
{
	control[0] = op; control[1] = nin; control[2] = nout; control[3] = nain; control[4] = 0;
	__asm__ volatile("move.l %0,d1\n\tmove.w #200,d0\n\ttrap #2"
			 : : "g"(aespb) : "d0", "d1", "d2", "a0", "a1", "a2", "memory");
	return int_out[0];
}

static void evnt_timer(long ms)
{
	int_in[0] = ms & 0xffff;
	int_in[1] = ms >> 16;
	aes(24, 2, 1, 0);
}

static unsigned long crctab[256];

static unsigned long crc32(const unsigned char *p, unsigned long n)
{
	unsigned long c = 0xffffffffUL;
	int i, j;
	if (!crctab[1])
		for (i = 0; i < 256; i++) {
			unsigned long k = i;
			for (j = 0; j < 8; j++) k = (k & 1) ? (k >> 1) ^ 0xedb88320UL : k >> 1;
			crctab[i] = k;
		}
	while (n--) c = crctab[(c ^ *p++) & 0xff] ^ (c >> 8);
	return ~c;
}

static unsigned char data[30000], back[30000];

static void gemdos_tests(void)
{
	_DISKINFO d1, d2;
	_DTA dta, *old = Fgetdta();
	long r, h, i, m0, m1, p;
	const char *f1 = "A:\\BTDIR\\TEST1.DAT", *f2 = "A:\\BTDIR\\TEST2.DAT";

	for (i = 0; i < (long)sizeof(data); i++) data[i] = (unsigned char)(i * 7 + 3);
	r = Dfree(&d1, 1);
	result("dfree", r == 0 && d1.b_total > 0, d1.b_free);
	r = Dcreate("A:\\BTDIR");
	result("dcreate", r == 0, r);
	h = Fcreate(f1, 0);
	result("fcreate", h >= 0, h);
	r = Fwrite((short)h, sizeof(data), data);
	result("fwrite", r == sizeof(data), r);
	result("fclose", Fclose((short)h) == 0, 0);
	h = Fopen(f1, 0);
	result("fopen", h >= 0, h);
	r = Fseek(12345, (short)h, 0);
	result("fseek", r == 12345, r);
	r = Fread((short)h, 10000, back);
	for (i = 0; i < 10000 && back[i] == data[12345 + i]; i++) ;
	result("fread", r == 10000 && i == 10000, r);
	r = Fseek(0, (short)h, 2);
	result("fseek-end", r == sizeof(data), r);
	Fclose((short)h);
	Fsetdta(&dta);
	r = Fsfirst("A:\\BTDIR\\*.*", 0);
	result("fsfirst", r == 0 && dta.dta_size == sizeof(data) && slen(dta.dta_name) == 9, dta.dta_size);
	r = Fsnext();
	result("fsnext-end", r < 0, r);
	Fsetdta(old);
	r = Frename(0, f1, f2);
	result("frename", r == 0, r);
	r = Fopen(f1, 0);
	result("fopen-renamed", r < 0, r);
	r = Fattrib(f2, 0, 0);
	result("fattrib", r >= 0 && (r & ~0x20) == 0, r);
	r = Fdelete(f2);
	result("fdelete", r == 0, r);
	r = Ddelete("A:\\BTDIR");
	result("ddelete", r == 0, r);
	r = Dfree(&d2, 1);
	result("dfree-again", r == 0 && d2.b_free == d1.b_free, d2.b_free);

	m0 = (long)Malloc(-1);
	info("malloc-free", m0);
	result("malloc-free", m0 > 100000, m0 > 100000);
	p = (long)Malloc(100000);
	result("malloc", p > 0, p != 0);
	if (p > 0) {
		for (i = 0; i < 100000; i += 4) *(long *)(p + i) = i;
		r = Mshrink((void *)p, 50000);
		result("mshrink", r == 0, r);
		r = Mfree((void *)p);
		result("mfree", r == 0, r);
	}
	m1 = (long)Malloc(-1);
	result("malloc-same", m1 == m0, m1 == m0);
	r = (long)Mxalloc(-1, 0);
	info("mxalloc-st", r);
	result("mxalloc-st", r > 0, r > 0);
}

int acc_main(void)
{
	long mode, size, i, h;
	unsigned long crc;
	unsigned short tosver;
	short ap;

	Supexec(nf_init);
	put("BOOTTEST START tos ");
	{
		long sys = 0;
		long get_sysbase(void);
		sys = Supexec(get_sysbase);
		tosver = *(unsigned short *)(sys + 2);
		puthex(tosver, 4);
		put(" date ");
		puthex(*(unsigned long *)(sys + 24), 8);
	}
	put(" gemdos ");
	puthex((unsigned short)Sversion(), 4);
	flush();
	ap = aes(10, 0, 1, 0);
	put("BOOTTEST aes ");
	puthex((unsigned short)global[0], 4);
	put(" apid ");
	putdec(ap);
	flush();
	gemdos_tests();
	/* each return means the main application waits for events, so it has drawn its screen */
	for (i = 0; i < 4; i++)
		evnt_timer(1000);
	if (tosver >= 0x0400) {
		mode = VsetMode(-1);
		size = VgetSize(mode);
	} else {
		/* XBIOS without the Falcon video calls (2.07 ends at 64 Blitmode): ST resolution, Line-A size */
		mode = Getrez();
		size = linea_screen_bytes();
	}
	crc = crc32((const unsigned char *)Logbase(), size);
	put("BOOTTEST screen mode ");
	puthex(mode, 4);
	put(" bytes ");
	putdec(size);
	put(" crc ");
	puthex(crc, 8);
	flush();
	h = Fcreate("A:\\SCREEN.RAW", 0);
	if (h >= 0) {
		Fwrite((short)h, size, Logbase());
		Fclose((short)h);
	}
	put("BOOTTEST END fails ");
	putdec(fails);
	flush();
	exit_code = fails ? 1 : 0;
	if (have_nf && nf_exit_id)
		Supexec(nf_exit);
	for (;;)
		evnt_timer(60000);
	return 0;
}
