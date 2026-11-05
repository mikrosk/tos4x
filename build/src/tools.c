/*
 * File commands the makefiles call, one binary per name (-DTOOL_RM etc.):
 *   rm, del  file...        delete; a missing file is not an error
 *   cp, copy src dst        copy one file
 *   mv src dst              move one file, replacing dst
 *   echo text...            print the arguments
 *   egrep string file...    print "file: line" for lines containing string;
 *                           exit 0 if any line matched (literal strings, files up to 64 KB)
 */
#include <mint/osbind.h>

extern char *bp;
static int argc;
static char *argv[64];
static char tail[130];
#if defined(TOOL_CP) || defined(TOOL_MV)
static char buf[16384];
#endif

#ifdef TOOL_EGREP
static int slen(const char *s) { int n = 0; while (s[n]) n++; return n; }
#endif

static void args(void)
{
	int n = (unsigned char)bp[0x80], i;
	char *p;
	if (n > 126) n = 126;
	for (i = 0; i < n; i++) tail[i] = bp[0x81 + i];
	tail[n] = 0;
	argv[argc++] = "";
	for (p = tail; *p; ) {
		while (*p == ' ' || *p == '\t' || *p == '\r' || *p == '\n') *p++ = 0;
		if (!*p) break;
		if (argc < 63) argv[argc++] = p;
		while (*p && *p != ' ' && *p != '\t' && *p != '\r' && *p != '\n') p++;
	}
}

#if !defined(TOOL_RM)
static void out(const char *s) { Cconws(s); }
#endif

#if defined(TOOL_CP) || defined(TOOL_MV)
static long copyfile(const char *src, const char *dst)
{
	long in = Fopen(src, 0), o, n;
	if (in < 0) return in;
	o = Fcreate(dst, 0);
	if (o < 0) { Fclose((short)in); return o; }
	while ((n = Fread((short)in, sizeof(buf), buf)) > 0)
		if (Fwrite((short)o, n, buf) != n) { n = -1; break; }
	Fclose((short)in);
	Fclose((short)o);
	return n < 0 ? n : 0;
}
#endif

#ifdef TOOL_EGREP
static char big[65536];

static int egrep(const char *pat, const char *file)
{
	long fh = Fopen(file, 0), n;
	char *line, *e, *p;
	int found = 0, pl = slen(pat), i;
	if (fh < 0) return 0;
	n = Fread((short)fh, sizeof(big) - 1, big);
	Fclose((short)fh);
	if (n < 0) return 0;
	big[n] = 0;
	for (line = big; *line; line = e) {
		for (e = line; *e && *e != '\n'; e++) ;
		if (*e) *e++ = 0;
		for (p = line; *p; p++) {
			for (i = 0; i < pl && p[i] == pat[i]; i++) ;
			if (i == pl) {
				out(file); out(": "); out(line); out("\n");
				found = 1;
				break;
			}
		}
	}
	return found;
}
#endif

int tool_main(void)
{
	int i;
	args();
#if defined(TOOL_RM)
	for (i = 1; i < argc; i++)
		if (argv[i][0] != '-')
			Fdelete(argv[i]);
	return 0;
#elif defined(TOOL_CP)
	(void)i;
	if (argc != 3) { out("usage: cp src dst\r\n"); return 1; }
	if (copyfile(argv[1], argv[2]) < 0) { out("cp: cannot copy "); out(argv[1]); out("\r\n"); return 1; }
	return 0;
#elif defined(TOOL_MV)
	(void)i;
	if (argc != 3) { out("usage: mv src dst\r\n"); return 1; }
	Fdelete(argv[2]);
	if (Frename(0, argv[1], argv[2]) < 0) {
		if (copyfile(argv[1], argv[2]) < 0) { out("mv: cannot move "); out(argv[1]); out("\r\n"); return 1; }
		Fdelete(argv[1]);
	}
	return 0;
#elif defined(TOOL_ECHO)
	for (i = 1; i < argc; i++) {
		out(argv[i]);
		out(i + 1 < argc ? " " : "\r\n");
	}
	return 0;
#elif defined(TOOL_EGREP)
	{
		int found = 0;
		if (argc < 3) { out("usage: egrep string file...\r\n"); return 2; }
		for (i = 2; i < argc; i++)
			found |= egrep(argv[1], argv[i]);
		return found ? 0 : 1;
	}
#else
#error define TOOL_RM, TOOL_CP, TOOL_MV, TOOL_ECHO or TOOL_EGREP
#endif
}
