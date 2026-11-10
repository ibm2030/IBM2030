/*
 * ms_dump - display or patch the IBM System/360 Model 30 main storage
 *
 * Lawrence Wilkinson lawrence@ljw.me.uk http://www.ljw.me.uk/ibm360
 *
 * Reads the 64K main storage through the AXI BRAM window (/dev/axi1,
 * provided by the axibram kernel module), or a saved image file, and shows
 * it in hex and EBCDIC, 16 bytes per line. Runs of identical lines are
 * shown once followed by "*", as hexdump does (use -v to show every line).
 *
 * AXI byte offset n is main storage address n. Parity is generated and
 * stripped by the hardware, so only the 8 data bits are seen here.
 *
 * Examples:
 *     ms_dump                     whole of storage (000000-00FFFF)
 *     ms_dump -s 100 -e 23F       addresses 0100-023F
 *     ms_dump -s 1C0 -n 40        64 bytes from 01C0
 *     ms_dump -s 16K -n 1K        1024 bytes from 4000 (K = decimal kilobytes)
 *     ms_dump -p 300 80 00 01     write 80 00 01 to 0300-0302
 *     ms_dump -l pch00d.txt       load the TXT cards of an object deck
 *     ms_dump -s 1C0 -n 40 -o x   save 01C0-01FF to file x ...
 *     ms_dump -s 1C0 -i x         ... and write it back to 01C0 later
 *     ms_dump -d saved.bin        display an image file
 *
 * Object decks (-l): 80-byte EBCDIC card images as punched by the assembler,
 * the same format pch_to_mem reads. Each card has X'02' in column 1 and its
 * type in columns 2-4. TXT cards are loaded at their assembled address
 * (no relocation); ESD, RLD and REP cards are ignored; END stops loading.
 * Storage not covered by TXT cards is left unchanged.
 *   TXT: cols 6-8 address, 11-12 byte count (max 56), 17-72 data
 *   END: cols 6-8 entry address (blank if none)
 *
 * Build:  gcc -O2 -Wall -o ms_dump ms_dump.c
 *         (or with the PetaLinux/Yocto cross compiler for the Zybo)
 */

#include <errno.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#define MS_SIZE 65536
#define LINE    16

static unsigned char ms[MS_SIZE];

static void usage(const char *prog)
{
	fprintf(stderr,
		"Usage: %s [-d device-or-file] [-s START] [-e END | -n LEN] [-v] [-o FILE]\n"
		"       %s [-d device-or-file] -p ADDR BYTE [BYTE...]\n"
		"       %s [-d device-or-file] -l DECK\n"
		"       %s [-d device-or-file] [-s START] -i FILE\n"
		"Display or patch IBM 2030 main storage (default device /dev/axi1)\n"
		"Addresses, lengths and bytes are hex; an address or length ending\n"
		"in K is decimal kilobytes (e.g. 16K = 4000, 64K = 10000).\n"
		"  -s A  start address (default 0)\n"
		"  -e A  end address, inclusive (default FFFF)\n"
		"  -n L  length in bytes (instead of -e)\n"
		"  -v    show every line (do not collapse repeated lines)\n"
		"  -o F  save the selected range, as binary, to file F\n"
		"  -p A  patch: write the hex BYTEs to address A onwards\n"
		"  -l F  load the TXT cards of punched object deck F into storage\n"
		"  -i F  write binary file F (e.g. from -o) into storage at START (-s, default 0)\n"
		"  -d D  device or image file (default /dev/axi1)\n"
		"  -h    this help\n", prog, prog, prog, prog);
}

/* Parse a hex number in [0, max]; returns -1 if invalid */
static long parse_hex(const char *s, long max)
{
	char *end;
	long v;

	if (!*s)
		return -1;
	errno = 0;
	v = strtol(s, &end, 16);
	if (errno || *end || v < 0 || v > max)
		return -1;
	return v;
}

/*
 * Parse an address or length in [0, max]: hex, or decimal kilobytes if it
 * ends in K or k (16K = 0x4000). Returns -1 if invalid.
 */
static long parse_addr(const char *s, long max)
{
	size_t len = strlen(s);
	char num[32], *end;
	long v;

	if (len < 2 || (s[len - 1] != 'K' && s[len - 1] != 'k'))
		return parse_hex(s, max);
	if (len - 1 >= sizeof num)
		return -1;
	memcpy(num, s, len - 1);
	num[len - 1] = 0;
	for (char *c = num; *c; c++)
		if (*c < '0' || *c > '9')
			return -1;
	errno = 0;
	v = strtol(num, &end, 10);
	if (errno || v > max / 1024 + 1)
		return -1;
	v *= 1024;
	return v > max ? -1 : v;
}

/* EBCDIC to printable ASCII ('.' for anything without a printable form) */
static char ebcdic(unsigned char c)
{
	static const struct { unsigned char lo, hi; char first; } run[] = {
		{ 0x81, 0x89, 'a' }, { 0x91, 0x99, 'j' }, { 0xA2, 0xA9, 's' },
		{ 0xC1, 0xC9, 'A' }, { 0xD1, 0xD9, 'J' }, { 0xE2, 0xE9, 'S' },
		{ 0xF0, 0xF9, '0' },
	};
	static const struct { unsigned char code; char ch; } punct[] = {
		{ 0x40, ' ' }, { 0x4A, '[' }, { 0x4B, '.' }, { 0x4C, '<' },
		{ 0x4D, '(' }, { 0x4E, '+' }, { 0x4F, '|' }, { 0x50, '&' },
		{ 0x5A, '!' }, { 0x5B, '$' }, { 0x5C, '*' }, { 0x5D, ')' },
		{ 0x5E, ';' }, { 0x5F, '^' }, { 0x60, '-' }, { 0x61, '/' },
		{ 0x6A, '|' }, { 0x6B, ',' }, { 0x6C, '%' }, { 0x6D, '_' },
		{ 0x6E, '>' }, { 0x6F, '?' }, { 0x79, '`' }, { 0x7A, ':' },
		{ 0x7B, '#' }, { 0x7C, '@' }, { 0x7D, '\'' }, { 0x7E, '=' },
		{ 0x7F, '"' }, { 0xA1, '~' }, { 0xC0, '{' }, { 0xD0, '}' },
		{ 0xE0, '\\' },
	};

	for (size_t i = 0; i < sizeof run / sizeof run[0]; i++)
		if (c >= run[i].lo && c <= run[i].hi)
			return run[i].first + (c - run[i].lo);
	for (size_t i = 0; i < sizeof punct / sizeof punct[0]; i++)
		if (c == punct[i].code)
			return punct[i].ch;
	return '.';
}

/* Read [start, start+len) from path into ms[]; returns bytes read or -1 */
static long load(const char *path, long start, long len)
{
	int fd = open(path, O_RDONLY);
	long got = 0;

	if (fd < 0) {
		fprintf(stderr, "%s: %s\n", path, strerror(errno));
		return -1;
	}
	while (got < len) {
		ssize_t n = pread(fd, ms + start + got, len - got, start + got);
		if (n < 0) {
			if (errno == EINTR)
				continue;
			fprintf(stderr, "%s: read at %04lX: %s\n", path, start + got, strerror(errno));
			close(fd);
			return -1;
		}
		if (n == 0)
			break;
		got += n;
	}
	close(fd);
	return got;
}

/* One line: address, hex in groups of 4, EBCDIC. Partial lines are padded. */
static void line(long a, long n)
{
	printf("%04lX:", a);
	for (long i = 0; i < LINE; i++) {
		if (i % 4 == 0)
			putchar(' ');
		if (i < n)
			printf("%02X", ms[a + i]);
		else
			printf("  ");
	}
	printf("  |");
	for (long i = 0; i < n; i++)
		putchar(ebcdic(ms[a + i]));
	printf("|\n");
}

static void dump(long start, long len, int verbose)
{
	long end = start + len;
	int starred = 0;

	for (long a = start; a < end; a += LINE) {
		long n = (end - a < LINE) ? end - a : LINE;

		if (!verbose && a > start && n == LINE &&
		    memcmp(ms + a, ms + a - LINE, LINE) == 0) {
			if (!starred) {
				printf("*\n");
				starred = 1;
			}
			continue;
		}
		starred = 0;
		line(a, n);
	}
	/* Show where a collapsed run ends, as hexdump does */
	if (starred)
		printf("%04lX\n", end);
}

/* Write n bytes at address addr, then read them back to verify */
static int patch(const char *path, long addr, const unsigned char *val, int n)
{
	unsigned char old[MS_SIZE], chk[MS_SIZE];
	int fd = open(path, O_RDWR);
	int ok = 1;

	if (fd < 0) {
		fprintf(stderr, "%s: %s\n", path, strerror(errno));
		return 1;
	}
	if (pread(fd, old, n, addr) != n) {
		fprintf(stderr, "%s: read at %04lX failed: %s\n", path, addr, strerror(errno));
		close(fd);
		return 1;
	}
	if (pwrite(fd, val, n, addr) != n) {
		fprintf(stderr, "%s: write at %04lX failed: %s\n", path, addr, strerror(errno));
		close(fd);
		return 1;
	}
	if (pread(fd, chk, n, addr) != n) {
		fprintf(stderr, "%s: read-back at %04lX failed: %s\n", path, addr, strerror(errno));
		close(fd);
		return 1;
	}
	close(fd);

	for (int i = 0; i < n; i++) {
		printf("  %04lX: %02X -> %02X", addr + i, old[i], chk[i]);
		if (chk[i] != val[i]) {
			printf("  MISMATCH: wrote %02X", val[i]);
			ok = 0;
		}
		printf("\n");
	}
	return ok ? 0 : 1;
}

#define CARD 80

/* Load the TXT cards of an object deck into storage, verifying each card */
static int load_deck(const char *path, const char *deck)
{
	static const unsigned char ESD[3] = { 0xC5, 0xE2, 0xC4 };
	static const unsigned char TXT[3] = { 0xE3, 0xE7, 0xE3 };
	static const unsigned char RLD[3] = { 0xD9, 0xD3, 0xC4 };
	static const unsigned char END[3] = { 0xC5, 0xD5, 0xC4 };
	static const unsigned char REP[3] = { 0xD9, 0xC5, 0xD7 };
	unsigned char card[CARD], chk[56];
	long lo = MS_SIZE, hi = -1, bytes = 0;
	int cards = 0, txt = 0, bad = 0, ended = 0, fd;
	FILE *f = fopen(deck, "rb");
	size_t got;

	if (!f) {
		fprintf(stderr, "%s: %s\n", deck, strerror(errno));
		return 1;
	}
	fd = open(path, O_RDWR);
	if (fd < 0) {
		fprintf(stderr, "%s: %s\n", path, strerror(errno));
		fclose(f);
		return 1;
	}

	while (!ended && (got = fread(card, 1, CARD, f)) > 0) {
		cards++;
		if (got != CARD) {
			fprintf(stderr, "Card %d: short card (%zu bytes), ignored\n", cards, got);
			break;
		}
		if (card[0] == 0x40)		/* blank card */
			continue;
		if (card[0] != 0x02) {
			fprintf(stderr, "Card %d: not a loader card (column 1 is %02X), ignored\n",
				cards, card[0]);
			continue;
		}
		if (!memcmp(card + 1, TXT, 3)) {
			long addr = (card[5] << 16) | (card[6] << 8) | card[7];
			int n = (card[10] << 8) | card[11];

			if (n > 56) {
				fprintf(stderr, "Card %d: TXT byte count %d > 56\n", cards, n);
				bad = 1;
				break;
			}
			if (addr + n > MS_SIZE) {
				fprintf(stderr, "Card %d: TXT at %06lX+%X is beyond 64K\n", cards, addr, n);
				bad = 1;
				break;
			}
			if (n == 0)
				continue;
			if (pwrite(fd, card + 16, n, addr) != n ||
			    pread(fd, chk, n, addr) != n) {
				fprintf(stderr, "Card %d: %s at %04lX failed: %s\n", cards, path,
					addr, strerror(errno));
				bad = 1;
				break;
			}
			for (int i = 0; i < n; i++)
				if (chk[i] != card[16 + i]) {
					printf("  %04lX: MISMATCH wrote %02X read %02X\n",
					       addr + i, card[16 + i], chk[i]);
					bad = 1;
				}
			txt++;
			bytes += n;
			if (addr < lo)
				lo = addr;
			if (addr + n - 1 > hi)
				hi = addr + n - 1;
		} else if (!memcmp(card + 1, END, 3)) {
			long entry = (card[5] << 16) | (card[6] << 8) | card[7];

			ended = 1;
			if (card[5] == 0x40 && card[6] == 0x40 && card[7] == 0x40)
				printf("END card, no entry address\n");
			else
				printf("END card, entry address %06lX\n", entry);
		} else if (!memcmp(card + 1, ESD, 3) || !memcmp(card + 1, RLD, 3) ||
			   !memcmp(card + 1, REP, 3)) {
			fprintf(stderr, "Card %d: %s card ignored\n", cards,
				!memcmp(card + 1, ESD, 3) ? "ESD" :
				!memcmp(card + 1, RLD, 3) ? "RLD" : "REP");
		} else {
			fprintf(stderr, "Card %d: unknown card type %02X%02X%02X, ignored\n",
				cards, card[1], card[2], card[3]);
		}
	}
	close(fd);
	fclose(f);

	if (!ended && !bad)
		fprintf(stderr, "Warning: no END card found\n");
	if (txt)
		printf("Loaded %d TXT cards, X'%lX' (%ld) bytes, into %04lX-%04lX%s\n",
		       txt, bytes, bytes, lo, hi, bad ? " (WITH ERRORS)" : "");
	else
		printf("No TXT cards loaded\n");
	return bad ? 1 : 0;
}

/* Write binary file 'in' into storage at addr, verifying it by read-back */
static int load_bin(const char *path, const char *in, long addr)
{
	static unsigned char buf[MS_SIZE + 1], chk[MS_SIZE];
	long n = 0, bad = 0;
	FILE *f = fopen(in, "rb");
	int fd;

	if (!f) {
		fprintf(stderr, "%s: %s\n", in, strerror(errno));
		return 1;
	}
	/* Read one byte more than fits, to detect an oversized file */
	n = fread(buf, 1, MS_SIZE - addr + 1, f);
	if (ferror(f)) {
		fprintf(stderr, "%s: %s\n", in, strerror(errno));
		fclose(f);
		return 1;
	}
	fclose(f);
	if (n == 0) {
		fprintf(stderr, "%s: file is empty\n", in);
		return 1;
	}
	if (n > MS_SIZE - addr) {
		fprintf(stderr, "%s: file does not fit at %04lX (only %lX bytes to FFFF)\n",
			in, addr, MS_SIZE - addr);
		return 1;
	}

	fd = open(path, O_RDWR);
	if (fd < 0) {
		fprintf(stderr, "%s: %s\n", path, strerror(errno));
		return 1;
	}
	if (pwrite(fd, buf, n, addr) != n || pread(fd, chk, n, addr) != n) {
		fprintf(stderr, "%s: write/read-back at %04lX failed: %s\n", path, addr,
			strerror(errno));
		close(fd);
		return 1;
	}
	close(fd);

	for (long i = 0; i < n; i++)
		if (chk[i] != buf[i] && bad++ < 16)
			printf("  %04lX: MISMATCH wrote %02X read %02X\n", addr + i, buf[i], chk[i]);
	if (bad > 16)
		printf("  ... %ld more mismatches\n", bad - 16);
	printf("Wrote X'%lX' (%ld) bytes to %04lX-%04lX%s\n", n, n, addr, addr + n - 1,
	       bad ? " (WITH ERRORS)" : "");
	return bad ? 1 : 0;
}

int main(int argc, char *argv[])
{
	const char *path = "/dev/axi1", *save = NULL, *deck = NULL, *in = NULL;
	long start = 0, endaddr = -1, len = -1, paddr = -1, got;
	int verbose = 0, opt;

	while ((opt = getopt(argc, argv, "s:e:n:vo:p:d:l:i:h")) != -1) {
		switch (opt) {
		case 's':
			if ((start = parse_addr(optarg, MS_SIZE - 1)) < 0) {
				fprintf(stderr, "Invalid start address '%s' (0-FFFF or 0K-63K)\n", optarg);
				return 1;
			}
			break;
		case 'e':
			if ((endaddr = parse_addr(optarg, MS_SIZE - 1)) < 0) {
				fprintf(stderr, "Invalid end address '%s' (0-FFFF or 0K-63K)\n", optarg);
				return 1;
			}
			break;
		case 'n':
			if ((len = parse_addr(optarg, MS_SIZE)) <= 0) {
				fprintf(stderr, "Invalid length '%s' (1-10000 or 1K-64K)\n", optarg);
				return 1;
			}
			break;
		case 'v': verbose = 1; break;
		case 'o': save = optarg; break;
		case 'd': path = optarg; break;
		case 'l': deck = optarg; break;
		case 'i': in = optarg; break;
		case 'p':
			if ((paddr = parse_addr(optarg, MS_SIZE - 1)) < 0) {
				fprintf(stderr, "Invalid address '%s' (0-FFFF or 0K-63K)\n", optarg);
				return 1;
			}
			break;
		default: usage(argv[0]); return opt == 'h' ? 0 : 1;
		}
	}

	if (in) {
		if (deck || paddr >= 0 || save || endaddr >= 0 || len >= 0 || optind < argc) {
			fprintf(stderr, "-i takes only -s (address) and -d\n");
			return 1;
		}
		return load_bin(path, in, start);
	}

	if (deck) {
		if (paddr >= 0 || optind < argc) {
			fprintf(stderr, "-l cannot be combined with -p or other arguments\n");
			return 1;
		}
		return load_deck(path, deck);
	}

	if (paddr >= 0) {
		static unsigned char val[MS_SIZE];
		int n = argc - optind;

		if (n < 1) {
			fprintf(stderr, "-p needs at least one hex byte value\n");
			return 1;
		}
		if (paddr + n > MS_SIZE) {
			fprintf(stderr, "%d bytes at %04lX would run past FFFF\n", n, paddr);
			return 1;
		}
		for (int i = 0; i < n; i++) {
			long v = parse_hex(argv[optind + i], 0xFF);
			if (v < 0) {
				fprintf(stderr, "Invalid byte value '%s' (00-FF)\n", argv[optind + i]);
				return 1;
			}
			val[i] = (unsigned char)v;
		}
		return patch(path, paddr, val, n);
	}

	if (optind < argc) {
		fprintf(stderr, "Unexpected argument '%s' (use -d for the device or file)\n",
			argv[optind]);
		return 1;
	}
	if (endaddr >= 0 && len >= 0) {
		fprintf(stderr, "Use either -e or -n, not both\n");
		return 1;
	}
	if (endaddr >= 0) {
		if (endaddr < start) {
			fprintf(stderr, "End address %04lX is before start %04lX\n", endaddr, start);
			return 1;
		}
		len = endaddr - start + 1;
	} else if (len < 0) {
		len = MS_SIZE - start;
	}
	if (start + len > MS_SIZE) {
		fprintf(stderr, "Range %04lX + %lX runs past FFFF\n", start, len);
		return 1;
	}

	got = load(path, start, len);
	if (got < 0)
		return 1;
	if (got < len)
		fprintf(stderr, "%s: only %lX of %lX bytes available\n", path, got, len);
	if (got == 0)
		return 1;

	if (save) {
		FILE *f = fopen(save, "wb");
		if (!f || fwrite(ms + start, 1, got, f) != (size_t)got) {
			fprintf(stderr, "%s: %s\n", save, strerror(errno));
			return 1;
		}
		fclose(f);
	}

	dump(start, got, verbose);
	return 0;
}
