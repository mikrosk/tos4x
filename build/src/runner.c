/*
 * Build runner: executes the commands in C:\BUILD.JOB one by one, logs "B <n> <line>" and
 * "E <n> <rc>" to C:\BUILD.LOG (opened and closed per record, so the host sees progress
 * at once), to the screen and to NatFeats stderr, and ends the emulation with NF_EXIT.
 * It waits for a key first unless C:\HEADLESS exists (written by build.sh), or when the
 * emulator has no NatFeats.
 *
 * Commands:
 *   cd X:\path                 change drive and directory
 *   x [>file] prog args        Pexec prog (PATH is searched, .ttp/.prg/.tos tried)
 *   setenv NAME=VALUE          environment for later Pexec calls (empty VALUE removes)
 *   del file...                Fdelete; wildcards allowed, a missing file is not an error
 *   copy src dst               copy one file
 *   rmtree dir                 delete a directory tree (for X:\ only its contents);
 *                              names starting with '.' are left alone
 *   cptree src dst             copy a directory tree; every copied file gets the same
 *                              date and time, so make sees sources and objects as equal
 *   touch file                 create an empty file if it does not exist
 *   romimg abs img size [banks] write the text and data of an aln -a output (header $601B)
 *                              to img, fill with $FF to size-2*banks bytes and append the CRC-16
 *                              (poly $1021, start 0) that startup.s checks; banks (default 1) is
 *                              the number of ROM chips: one CRC per chip over its bytes (byte n
 *                              is in chip n mod banks), stored high bytes first, then low bytes
 *   ramimg abs img             write the text and data of an aln -a output (header $601B)
 *                              to img and nothing else (a RAM TOS image: no fill, no CRC)
 *   check listfile             compare files with "crc size path" lines (POSIX cksum)
 *   subst file from to         replace every occurrence of the text from by to in file;
 *                              in from and to, \t is a tab, \s a space, \r a CR, \n a LF,
 *                              \\ a backslash;
 *                              the result code is the number of replacements
 *   key                        put a Return key press into the keyboard buffer, for a
 *                              program the makefiles call that waits for one at its end
 *   type text                  put the keys of text into the keyboard buffer (escapes as for
 *                              subst, \r is Return), for a program that reads its input from
 *                              the keyboard; the result code is the number of keys
 *   mkdir dir                  create a directory (Dcreate; the result code is its result)
 *   poke file offset hex       write the bytes hex (pairs of hex digits) at offset (decimal, or hex
 *                              with 0x) of an existing file; the result code is the number of bytes
 *   echo text
 */
#include <mint/osbind.h>
#include <string.h>

long nf_id_fn(const char *name);
long nf_call2(long id, long arg);
long nf_probe(void);
__asm__(
	"_nf_id_fn:\n\t.dc.w 0x7300\n\trts\n"
	"_nf_call2:\n\t.dc.w 0x7301\n\trts\n"
	/* supervisor mode: catch the illegal-instruction trap the NatFeats opcode gives
	   on an emulator without NatFeats */
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

static long nf_stderr_id, nf_exit_id;
static long have_nf;

static void nf_init(void)
{
	have_nf = Supexec(nf_probe) != 0;
	if (have_nf) {
		nf_stderr_id = nf_id_fn("NF_STDERR");
		nf_exit_id = nf_id_fn("NF_EXIT");
	}
}

static void out(const char *s)
{
	Cconws(s);
	if (have_nf && nf_stderr_id)
		nf_call2(nf_stderr_id, (long)s);
}

static void logrec(const char *s)
{
	long fh = Fopen("C:\\BUILD.LOG", 1);
	if (fh < 0)
		fh = Fcreate("C:\\BUILD.LOG", 0);
	if (fh >= 0) {
		Fseek(0, (short)fh, 2);
		Fwrite((short)fh, strlen(s), s);
		Fclose((short)fh);
	}
	out(s);
}

static char *utoa10(unsigned long v, char *p)
{
	char tmp[16];
	int n = 0;
	do { tmp[n++] = '0' + (v % 10); v /= 10; } while (v);
	while (n) *p++ = tmp[--n];
	*p = 0;
	return p;
}

static char *itoa10(long v, char *p)
{
	if (v < 0) { *p++ = '-'; v = -v; }
	return utoa10((unsigned long)v, p);
}

static long exit_code;

static long do_exit(void)
{
	nf_call2(nf_exit_id, exit_code);
	return 0;
}

static void finish(long code)
{
	long h = Fopen("C:\\HEADLESS", 0);
	exit_code = code;
	logrec("DONE\r\n");
	if (h >= 0)
		Fclose((short)h);
	if (h < 0 || !have_nf || !nf_exit_id) {
		Cconws("Press a key\r\n");
		Cnecin();
	}
	if (have_nf && nf_exit_id)
		Supexec(do_exit);
	Pterm(0);
}

static char *skipsp(char *p) { while (*p == ' ' || *p == '\t') p++; return p; }
static char *word(char **pp)
{
	char *p = skipsp(*pp), *w = p;
	while (*p && *p != ' ' && *p != '\t') p++;
	if (*p) *p++ = 0;
	*pp = p;
	return w;
}

static char buf[32768];

static long copyfile(const char *src, const char *dst, int settime)
{
	long in = Fopen(src, 0), o, n;
	_DOSTIME dt;
	if (in < 0) return in;
	o = Fcreate(dst, 0);
	if (o < 0) { Fclose((short)in); return o; }
	while ((n = Fread((short)in, sizeof(buf), buf)) > 0)
		if (Fwrite((short)o, n, buf) != n) { n = -1; break; }
	if (settime) {
		dt.time = 0;
		dt.date = ((1993 - 1980) << 9) | (1 << 5) | 1;
		Fdatime(&dt, (short)o, 1);
	}
	Fclose((short)in);
	Fclose((short)o);
	return n < 0 ? n : 0;
}

static long nfiles;

static long delfiles(char *line)
{
	_DTA dta, *old = Fgetdta();
	char *f, path[200], *e;
	long rc = 0, r;
	Fsetdta(&dta);
	while (*(f = word(&line))) {
		if (!strpbrk(f, "*?")) {
			r = Fdelete(f);
			if (r < 0 && r != -33 && r != -34) rc = r;
			continue;
		}
		for (r = Fsfirst(f, 0); r == 0; r = Fsnext()) {
			strcpy(path, f);
			e = strrchr(path, '\\');
			if (!e) e = strrchr(path, ':');
			if (e) e[1] = 0; else path[0] = 0;
			strcat(path, dta.dta_name);
			Fdelete(path);
		}
	}
	Fsetdta(old);
	return rc;
}

static void mkdirs(const char *dst)
{
	char d[200], *p;
	strcpy(d, dst);
	for (p = d + 3; *p; p++)
		if (*p == '\\') {
			*p = 0;
			Dcreate(d);
			*p = '\\';
		}
	Dcreate(d);
}

static long cptree(const char *src, const char *dst)
{
	_DTA dta, *old = Fgetdta();
	char pat[200], s[200], d[200];
	long rc;
	mkdirs(dst);
	strcpy(pat, src);
	strcat(pat, "\\*.*");
	Fsetdta(&dta);
	for (rc = Fsfirst(pat, 0x10); rc == 0; rc = Fsnext()) {
		if (dta.dta_name[0] == '.')
			continue;
		strcpy(s, src); strcat(s, "\\"); strcat(s, dta.dta_name);
		strcpy(d, dst); strcat(d, "\\"); strcat(d, dta.dta_name);
		if (dta.dta_attribute & 0x10) {
			if ((rc = cptree(s, d)) < 0) break;
			Fsetdta(&dta);
		} else {
			if ((rc = copyfile(s, d, 1)) < 0) break;
			nfiles++;
		}
	}
	Fsetdta(old);
	return rc == -49 || rc == -33 ? 0 : rc;
}

static long rmtree(const char *dir)
{
	_DTA dta, *old = Fgetdta();
	char pat[200], p[200];
	long rc;
	int root = strlen(dir) <= 3;
	strcpy(pat, dir);
	if (pat[strlen(pat) - 1] != '\\') strcat(pat, "\\");
	strcat(pat, "*.*");
	Fsetdta(&dta);
	for (rc = Fsfirst(pat, 0x10); rc == 0; rc = Fsnext()) {
		if (dta.dta_name[0] == '.')
			continue;
		strcpy(p, dir);
		if (p[strlen(p) - 1] != '\\') strcat(p, "\\");
		strcat(p, dta.dta_name);
		if (dta.dta_attribute & 0x10) {
			rmtree(p);
			Fsetdta(&dta);
		} else
			Fdelete(p);
	}
	Fsetdta(old);
	if (!root)
		Ddelete(dir);
	return 0;
}

static unsigned short crc16(const unsigned char *p, long n, unsigned short c)
{
	int i;
	while (n--) {
		c ^= (unsigned short)(*p++) << 8;
		for (i = 0; i < 8; i++)
			c = (c & 0x8000) ? (c << 1) ^ 0x1021 : c << 1;
	}
	return c;
}

static void crc16b(const unsigned char *p, long n, long pos, int banks, unsigned short *c)
{
	while (n--) {
		unsigned short *b = &c[pos++ % banks];
		*b = crc16(p++, 1, *b);
	}
}

static long romimg(const char *abs, const char *img, long size, int banks)
{
	long in = Fopen(abs, 0), o, n, left, len = 0, end = size - 2L * banks;
	unsigned char h[36], w[16];
	unsigned short c[8];
	int i;
	if (banks < 1 || banks > 8) return -4;
	for (i = 0; i < banks; i++) c[i] = 0;
	if (in < 0) return in;
	if (Fread((short)in, 36, h) != 36 || h[0] != 0x60 || h[1] != 0x1b) { Fclose((short)in); return -1; }
	left = ((long)h[2] << 24 | (long)h[3] << 16 | h[4] << 8 | h[5]) +
	       ((long)h[6] << 24 | (long)h[7] << 16 | h[8] << 8 | h[9]);
	if (left > end) { Fclose((short)in); return -2; }
	o = Fcreate(img, 0);
	if (o < 0) { Fclose((short)in); return o; }
	while (left > 0 && (n = Fread((short)in, left < (long)sizeof(buf) ? left : (long)sizeof(buf), buf)) > 0) {
		Fwrite((short)o, n, buf);
		crc16b((unsigned char *)buf, n, len, banks, c);
		left -= n;
		len += n;
	}
	Fclose((short)in);
	memset(buf, 0xff, sizeof(buf));
	while (len < end) {
		n = end - len;
		if (n > (long)sizeof(buf)) n = sizeof(buf);
		Fwrite((short)o, n, buf);
		crc16b((unsigned char *)buf, n, len, banks, c);
		len += n;
	}
	for (i = 0; i < banks; i++) {
		w[i] = c[i] >> 8;
		w[banks + i] = c[i];
	}
	Fwrite((short)o, 2L * banks, w);
	Fclose((short)o);
	return left ? -3 : 0;
}

static long ramimg(const char *abs, const char *img)
{
	long in = Fopen(abs, 0), o, n, left;
	unsigned char h[36];
	if (in < 0) return in;
	if (Fread((short)in, 36, h) != 36 || h[0] != 0x60 || h[1] != 0x1b) { Fclose((short)in); return -1; }
	left = ((long)h[2] << 24 | (long)h[3] << 16 | h[4] << 8 | h[5]) +
	       ((long)h[6] << 24 | (long)h[7] << 16 | h[8] << 8 | h[9]);
	o = Fcreate(img, 0);
	if (o < 0) { Fclose((short)in); return o; }
	while (left > 0 && (n = Fread((short)in, left < (long)sizeof(buf) ? left : (long)sizeof(buf), buf)) > 0) {
		Fwrite((short)o, n, buf);
		left -= n;
	}
	Fclose((short)in);
	Fclose((short)o);
	return left ? -3 : 0;
}

/* POSIX cksum: CRC-32 (poly 04C11DB7, MSB first) over the data and the length bytes */
static unsigned long crctab[256];

static void crc32_init(void)
{
	unsigned long c;
	int i, j;
	for (i = 0; i < 256; i++) {
		c = (unsigned long)i << 24;
		for (j = 0; j < 8; j++)
			c = (c & 0x80000000UL) ? (c << 1) ^ 0x04C11DB7UL : c << 1;
		crctab[i] = c;
	}
}

static long cksum(const char *file, unsigned long *crc, unsigned long *size)
{
	long fh = Fopen(file, 0), n, i;
	unsigned long c = 0, len = 0, l;
	if (fh < 0) return fh;
	while ((n = Fread((short)fh, sizeof(buf), buf)) > 0) {
		for (i = 0; i < n; i++)
			c = (c << 8) ^ crctab[((c >> 24) ^ (unsigned char)buf[i]) & 0xff];
		len += n;
	}
	Fclose((short)fh);
	for (l = len; l; l >>= 8)
		c = (c << 8) ^ crctab[((c >> 24) ^ (l & 0xff)) & 0xff];
	*crc = ~c & 0xffffffffUL;
	*size = len;
	return 0;
}

static long check(const char *list)
{
	static char lb[16384];
	char *p, *line, *q, rec[300];
	long fh = Fopen(list, 0), n, ok = 0, bad = 0, miss = 0;
	unsigned long ec, es, c, s;
	if (fh < 0) return fh;
	n = Fread((short)fh, sizeof(lb) - 1, lb);
	Fclose((short)fh);
	lb[n < 0 ? 0 : n] = 0;
	crc32_init();
	for (p = lb; *p; ) {
		line = p;
		while (*p && *p != '\n' && *p != '\r') p++;
		while (*p == '\n' || *p == '\r') *p++ = 0;
		line = skipsp(line);
		if (!*line || *line == '#') continue;
		ec = es = 0;
		for (q = word(&line); *q; q++) ec = ec * 10 + (*q - '0');
		for (q = word(&line); *q; q++) es = es * 10 + (*q - '0');
		q = word(&line);
		if (cksum(q, &c, &s) < 0) {
			strcpy(rec, "MISSING   "); miss++;
		} else if (c == ec && s == es) {
			strcpy(rec, "IDENTICAL "); ok++;
		} else {
			strcpy(rec, "DIFFERS   "); bad++;
		}
		strcat(rec, q);
		strcat(rec, "\r\n");
		logrec(rec);
	}
	q = rec;
	strcpy(q, "CHECK "); strncat(q, list, 100); strcat(q, " identical "); q += strlen(q); q = itoa10(ok, q);
	strcpy(q, " differs "); q += strlen(q); q = itoa10(bad, q);
	strcpy(q, " missing "); q += strlen(q); q = itoa10(miss, q);
	strcpy(q, "\r\n");
	logrec(rec);
	return bad + miss;
}

static void unescape(char *s)
{
	char *d = s;
	while (*s) {
		if (*s == '\\' && s[1]) {
			s++;
			*d++ = *s == 't' ? '\t' : *s == 's' ? ' ' : *s == 'r' ? '\r' : *s == 'n' ? '\n' : *s;
			s++;
		} else
			*d++ = *s++;
	}
	*d = 0;
}

static int hexval(char c)
{
	if (c >= '0' && c <= '9') return c - '0';
	c |= 0x20;
	if (c >= 'a' && c <= 'f') return c - 'a' + 10;
	return -1;
}

static long poke(const char *file, const char *off, const char *hex)
{
	long fh, o = 0, n = 0, rc;
	char buf[128];
	if (off[0] == '0' && (off[1] | 0x20) == 'x') {
		for (off += 2; hexval(*off) >= 0; off++) o = o * 16 + hexval(*off);
	} else {
		for (; *off >= '0' && *off <= '9'; off++) o = o * 10 + (*off - '0');
	}
	for (; hexval(hex[0]) >= 0 && hexval(hex[1]) >= 0 && n < (long)sizeof(buf); hex += 2)
		buf[n++] = (char)(hexval(hex[0]) * 16 + hexval(hex[1]));
	if (*hex || !n) return -1;
	if ((fh = Fopen(file, 2)) < 0) return fh;
	if ((rc = Fseek(o, (short)fh, 0)) != o) { Fclose((short)fh); return rc < 0 ? rc : -64; }
	rc = Fwrite((short)fh, n, buf);
	Fclose((short)fh);
	return rc;
}

static long subst(const char *file, char *from, char *to)
{
	long fh, size, n = 0, fl, tl, o;
	char *in, *out, *p, *q;
	unescape(from);
	unescape(to);
	fl = strlen(from);
	tl = strlen(to);
	if (!fl) return -1;
	if ((fh = Fopen(file, 0)) < 0) return fh;
	size = Fseek(0, (short)fh, 2);
	Fseek(0, (short)fh, 0);
	in = (char *)Malloc(size + 1);
	if (!in) { Fclose((short)fh); return -39; }
	Fread((short)fh, size, in);
	Fclose((short)fh);
	in[size] = 0;
	for (p = in; p + fl <= in + size; p++)
		if (!memcmp(p, from, fl)) { n++; p += fl - 1; }
	if (n) {
		out = (char *)Malloc(size + n * (tl > fl ? tl - fl : 0) + 1);
		if (!out) { Mfree(in); return -39; }
		for (p = in, q = out; p < in + size; ) {
			if (p + fl <= in + size && !memcmp(p, from, fl)) {
				memcpy(q, to, tl); q += tl; p += fl;
			} else
				*q++ = *p++;
		}
		o = Fcreate(file, 0);
		if (o < 0) { Mfree(out); Mfree(in); return o; }
		Fwrite((short)o, q - out, out);
		Fclose((short)o);
		Mfree(out);
	}
	Mfree(in);
	return n;
}

static long put_return(void)
{
	_IOREC *k = Iorec(1);
	short t = k->ibuftl + 4;
	if (t >= k->ibufsiz) t = 0;
	*(long *)((char *)k->ibuf + t) = 0x001c000dL;
	k->ibuftl = t;
	return 0;
}

/* ST scancodes of the keys type puts into the buffer: a-z, 0-9 */
static const unsigned char scan_az[26] = {
	0x1e, 0x30, 0x2e, 0x20, 0x12, 0x21, 0x22, 0x23, 0x17, 0x24, 0x25, 0x26, 0x32,
	0x31, 0x18, 0x19, 0x10, 0x13, 0x1f, 0x14, 0x16, 0x2f, 0x11, 0x2d, 0x15, 0x2c
};
static const unsigned char scan_09[10] = { 0x0b, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0a };
static char *typetext;

static long put_keys(void)
{
	_IOREC *k = Iorec(1);
	char *s;
	long n = 0;
	for (s = typetext; *s; s++) {
		unsigned char c = (unsigned char)*s, sc = 0;
		short t = k->ibuftl + 4;
		if (t >= k->ibufsiz) t = 0;
		if (t == k->ibufhd) return -1;	/* buffer full */
		if (c >= 'a' && c <= 'z') sc = scan_az[c - 'a'];
		else if (c >= 'A' && c <= 'Z') sc = scan_az[c - 'A'];
		else if (c >= '0' && c <= '9') sc = scan_09[c - '0'];
		else if (c == '\r') sc = 0x1c;
		else if (c == ' ') sc = 0x39;
		*(long *)((char *)k->ibuf + t) = ((long)sc << 16) | c;
		k->ibuftl = t;
		n++;
	}
	return n;
}

static char envbuf[2048];
static long envlen;

static void setenv_cmd(char *def)
{
	char *eq = strchr(def, '='), *p = envbuf;
	size_t nl;
	if (!eq) return;
	nl = eq - def + 1;
	while (p < envbuf + envlen) {
		size_t l = strlen(p) + 1;
		if (!strncmp(p, def, nl)) {
			memmove(p, p + l, envbuf + envlen - (p + l));
			envlen -= l;
		} else
			p += l;
	}
	if (eq[1] && envlen + strlen(def) + 2 < sizeof(envbuf)) {
		strcpy(envbuf + envlen, def);
		envlen += strlen(def) + 1;
	}
	envbuf[envlen] = 0;
	envbuf[envlen + 1] = 0;
}

static const char *getpath(void)
{
	char *p = envbuf;
	while (p < envbuf + envlen) {
		if (!strncmp(p, "PATH=", 5)) return p + 5;
		p += strlen(p) + 1;
	}
	return "";
}

/* find prog: as given, then in each PATH entry (';' or ',' separated), with extensions */
static int findprog(const char *prog, char *res)
{
	static const char *ext[] = { "", ".ttp", ".prg", ".tos", 0 };
	const char *path = getpath(), *e;
	char dir[128];
	int i, n, found = 0, first = 1;
	_DTA dta, *old = Fgetdta();
	Fsetdta(&dta);
	for (;;) {
		if (first) {
			dir[0] = 0;
			first = 0;
		} else {
			if (!*path || strchr(prog, '\\') || strchr(prog, ':')) break;
			for (e = path; *e && *e != ';' && *e != ','; e++) ;
			n = e - path;
			memcpy(dir, path, n);
			dir[n] = 0;
			if (n && dir[n - 1] != '\\') strcat(dir, "\\");
			path = *e ? e + 1 : e;
		}
		for (i = 0; ext[i] && !found; i++) {
			strcpy(res, dir);
			strcat(res, prog);
			strcat(res, ext[i]);
			if (Fsfirst(res, 0) == 0) found = 1;
		}
		if (found) break;
	}
	Fsetdta(old);
	return found;
}

static long run(char *rest)
{
	char *redir = 0, *prog, *args;
	char cmd[130], full[200];
	long rc, saved = -1, fh = -1;
	size_t len;

	rest = skipsp(rest);
	if (*rest == '>') {
		rest++;
		redir = word(&rest);
	}
	prog = word(&rest);
	args = skipsp(rest);
	len = strlen(args);
	if (len > 125) return -1000;
	cmd[0] = (char)len;
	memcpy(cmd + 1, args, len + 1);
	if (!findprog(prog, full))
		return -33;
	if (redir) {
		fh = Fcreate(redir, 0);
		if (fh < 0) return -1001;
		saved = Fdup(1);
		Fforce(1, (short)fh);
	}
	rc = Pexec(0, full, cmd, envlen ? envbuf : 0);
	if (redir) {
		Fforce(1, (short)saved);
		Fclose((short)saved);
		Fclose((short)fh);
	}
	return rc;
}

int main(void)
{
	long fh, size, n = 0;
	char *jobs, *p, *line, *cmd, rec[300], *q;
	long rc;

	nf_init();
	fh = Fopen("C:\\BUILD.JOB", 0);
	if (fh < 0) { logrec("no C:\\BUILD.JOB\r\n"); finish(2); }
	size = Fseek(0, (short)fh, 2);
	Fseek(0, (short)fh, 0);
	jobs = (char *)Malloc(size + 2);
	if (!jobs) { logrec("no memory\r\n"); finish(3); }
	Fread((short)fh, size, jobs);
	Fclose((short)fh);
	jobs[size] = 0;
	Fdelete("C:\\BUILD.LOG");
	logrec("START\r\n");

	for (p = jobs; *p; ) {
		line = p;
		while (*p && *p != '\n' && *p != '\r') p++;
		while (*p == '\n' || *p == '\r') *p++ = 0;
		line = skipsp(line);
		if (!*line || *line == '#') continue;
		n++;
		q = rec; *q++ = 'B'; *q++ = ' ';
		q = utoa10(n, q); *q++ = ' ';
		strncpy(q, line, 250); q[250] = 0; q += strlen(q);
		*q++ = '\r'; *q++ = '\n'; *q = 0;
		logrec(rec);
		cmd = word(&line);
		rc = 0;
		if (!strcmp(cmd, "cd")) {
			char *d = skipsp(line);
			if (d[0] && d[1] == ':') {
				Dsetdrv((d[0] | 0x20) - 'a');
				d += 2;
			}
			if (*d) rc = Dsetpath(d);
		} else if (!strcmp(cmd, "x")) {
			rc = run(line);
		} else if (!strcmp(cmd, "del")) {
			rc = delfiles(line);
		} else if (!strcmp(cmd, "copy")) {
			char *a = word(&line), *b = word(&line);
			rc = copyfile(a, b, 0);
		} else if (!strcmp(cmd, "cptree")) {
			char *a = word(&line), *b = word(&line);
			nfiles = 0;
			rc = cptree(a, b);
			if (rc == 0) rc = nfiles;
		} else if (!strcmp(cmd, "rmtree")) {
			rc = rmtree(skipsp(line));
		} else if (!strcmp(cmd, "touch")) {
			char *a = skipsp(line);
			long h = Fopen(a, 0);
			if (h >= 0) Fclose((short)h);
			else if ((h = Fcreate(a, 0)) >= 0) Fclose((short)h);
			else rc = h;
		} else if (!strcmp(cmd, "romimg")) {
			char *a = word(&line), *b = word(&line), *z = word(&line), *k = word(&line);
			long sz = 0;
			int banks = 0;
			while (*z >= '0' && *z <= '9') sz = sz * 10 + (*z++ - '0');
			while (*k >= '0' && *k <= '9') banks = banks * 10 + (*k++ - '0');
			rc = romimg(a, b, sz, banks ? banks : 1);
		} else if (!strcmp(cmd, "ramimg")) {
			char *a = word(&line), *b = word(&line);
			rc = ramimg(a, b);
		} else if (!strcmp(cmd, "key")) {
			rc = Supexec(put_return);
		} else if (!strcmp(cmd, "poke")) {
			char *a = word(&line), *b = word(&line), *c = word(&line);
			rc = poke(a, b, c);
		} else if (!strcmp(cmd, "mkdir")) {
			rc = Dcreate(skipsp(line));
		} else if (!strcmp(cmd, "type")) {
			typetext = skipsp(line);
			unescape(typetext);
			rc = Supexec(put_keys);
		} else if (!strcmp(cmd, "check")) {
			rc = check(skipsp(line));
		} else if (!strcmp(cmd, "subst")) {
			char *a = word(&line), *b = word(&line), *c = word(&line);
			rc = subst(a, b, c);
		} else if (!strcmp(cmd, "setenv")) {
			setenv_cmd(skipsp(line));
		} else if (!strcmp(cmd, "echo")) {
			rc = 0;
		} else {
			rc = -999;
		}
		q = rec; *q++ = 'E'; *q++ = ' ';
		q = utoa10(n, q); *q++ = ' ';
		q = itoa10(rc, q);
		*q++ = '\r'; *q++ = '\n'; *q = 0;
		logrec(rec);
	}
	finish(0);
	return 0;
}
