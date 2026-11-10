/*
 * ls_dump - display the IBM System/360 Model 30 local storage
 *
 * Lawrence Wilkinson lawrence@ljw.me.uk http://www.ljw.me.uk/ibm360
 *
 * Reads the 2K local storage block through the AXI BRAM window (/dev/axi2,
 * provided by the axibram kernel module) or from a saved 2048-byte image,
 * and formats it.
 *
 * Local storage layout (2K bytes, LS address = storage address bits 1-3 & 8-15):
 *
 *   000-6FF  Multiplexor channel UCW storage, areas 0-6 (selected by the
 *            XXH, XH, XL bump address latches), 256 bytes = 32 UCWs each
 *   700-7FF  CPU local storage (CU=LS forces address bits 1-3 to 111)
 *
 * The layouts below are from the IBM S/360 Model 30 FE Handbook (229-2116-2):
 *   p13 "Local Storage - CPU"
 *   p31 "Unit Control Word"
 *
 * CPU local storage (offsets within the 256-byte CPU area):
 *
 *   col:  0 1 2 3 | 4 ... 7 | 8 9 A B C D E F
 *   0X-FX  GPR n    1050      0X Float Pt Reg 0
 *          (row n)  sense     2X Float Pt Reg 2
 *                   byte      4X Float Pt Reg 4
 *                   (04)      5X I J G U V L D S (CPU store)
 *                             6X Float Pt Reg 6
 *                             7X Float Pt Multiply/Divide
 *                             8X-BX K-addressable bytes 0-31
 *   CX-FX cols 6-F, and 9A-9F: CPU working storage
 *
 * Each UCW is 8 bytes. UCW n (0-15) is at row n, columns 0-7 of its area;
 * UCW n (16-31) is at row n-16, columns 8-F.
 *   byte 0  Status
 *   byte 1  Flags
 *   byte 2-3 Count
 *   byte 4-5 Data address
 *   byte 6-7 Next CCW address
 *
 * Byte order: AXI byte offset n is LS address n.
 *
 * Patching: -p ADDR BYTE... writes the hex bytes to LS address ADDR
 * (000-7FF) and following, then reads them back to check. For example
 *     ls_dump -p 7B8 FF 05      system mask FF, key 0 / AMWP 5
 * The device or image file is then given with -d.
 *
 * Build:  gcc -O2 -Wall -o ls_dump ls_dump.c
 *         (or with the PetaLinux/Yocto cross compiler for the Zybo)
 */

#include <errno.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#define LS_SIZE     2048
#define AREA_SIZE   256
#define MPX_AREAS   7
#define CPU_BASE    0x700
#define UCWS_PER_AREA 32

static unsigned char ls[LS_SIZE];

/* CPU local storage byte at CPU-area offset off */
static unsigned cpu(unsigned off) { return ls[CPU_BASE + (off & 0xFF)]; }

/* K-addressable bytes: K 0-31 map to 88-8F, 98-9F, A8-AF, B8-BF */
static unsigned k_addr(unsigned k) { return 0x88 + ((k >> 3) << 4) + (k & 7); }

static const char *k_use[32] = {
	"MPX Intrp Buffer Unit Address",
	"MPX T Reg Store",
	"MPX R Reg Store",
	"MPX Intrp Buffer Unit Status",
	"PSW bit pos 1, Instruction Length pos 4-7",
	"Sel Chan 1 Unit Address",
	"Sel Chan 1 Next CCW Addr Hi",
	"Sel Chan 1 Next CCW Addr Lo",
	"MPX Unit Address Temp Storage",
	"1050 Unit Status",
	"CPU Working Storage",
	"CPU Working Storage",
	"CPU Working Storage",
	"CPU Working Storage",
	"CPU Working Storage",
	"CPU Working Storage",
	"Instruction Counter Unavailable",
	"Instruction Counter Hi",
	"Instruction Counter Lo",
	"Unassigned",
	"Sel Chan Chaining R Reg Storage",
	"Sel Chan 2 Unit Address",
	"Sel Chan 2 Next CCW Addr Hi",
	"Sel Chan 2 Next CCW Addr Lo",
	"System Mask",
	"Prot Key 0-3 and A M W P 4-7",
	"Unassigned",
	"Condition Reg 0-3, PGM Mask 4-7",
	"Op Code Mask",
	"Sel Chan S Reg Store",
	"Sel Chan U Reg Store",
	"Sel Chan V Reg Store",
};

static void usage(const char *prog)
{
	fprintf(stderr,
		"Usage: %s [options] [device-or-file]\n"
		"       %s [-d device-or-file] -p ADDR BYTE [BYTE...]\n"
		"Display or patch IBM 2030 local storage (default device /dev/axi2)\n"
		"  -p A patch: write the hex BYTEs to LS address A (000-7FF) onwards\n"
		"  -d D device or image file (default /dev/axi2)\n"
		"  -c   CPU local storage only\n"
		"  -m   Multiplexor UCWs only\n"
		"  -a   show all UCWs, including all-zero ones\n"
		"  -x   raw hex dump of the whole 2K as well\n"
		"  -o F save the 2K image to file F\n"
		"  -h   this help\n", prog, prog);
}

static int load(const char *path)
{
	int fd = open(path, O_RDONLY);
	size_t got = 0;

	if (fd < 0) {
		fprintf(stderr, "%s: %s\n", path, strerror(errno));
		return -1;
	}
	while (got < LS_SIZE) {
		ssize_t n = read(fd, ls + got, LS_SIZE - got);
		if (n < 0) {
			if (errno == EINTR)
				continue;
			fprintf(stderr, "%s: read: %s\n", path, strerror(errno));
			close(fd);
			return -1;
		}
		if (n == 0)
			break;
		got += n;
	}
	close(fd);
	if (got != LS_SIZE) {
		fprintf(stderr, "%s: only %zu of %d bytes read\n", path, got, LS_SIZE);
		return -1;
	}
	return 0;
}

/* Hex dump of len bytes from LS address base */
static void hexdump(unsigned base, unsigned len)
{
	for (unsigned a = base; a < base + len; a += 16) {
		printf("  %03X:", a);
		for (unsigned i = 0; i < 16; i++)
			printf("%s%02X", (i % 4) ? "" : " ", ls[a + i]);
		printf("\n");
	}
}

static void show_cpu(void)
{
	unsigned b88 = cpu(0x88), b89 = cpu(0x89), b8a = cpu(0x8A), b8b = cpu(0x8B);
	static const char *cpu_regs = "IJGUVLDS";
	int cc;

	printf("CPU LOCAL STORAGE (LS 700-7FF)\n\n");

	printf("General registers\n");
	for (int r = 0; r < 16; r++) {
		unsigned o = r << 4;
		printf("  R%-2d %02X%02X%02X%02X%s", r,
		       cpu(o), cpu(o + 1), cpu(o + 2), cpu(o + 3),
		       (r % 4 == 3) ? "\n" : "  ");
	}

	printf("\nFloating point registers\n");
	for (int r = 0; r <= 6; r += 2) {
		unsigned o = (r << 4) | 8;
		printf("  F%d  %02X%02X%02X%02X %02X%02X%02X%02X\n", r,
		       cpu(o), cpu(o + 1), cpu(o + 2), cpu(o + 3),
		       cpu(o + 4), cpu(o + 5), cpu(o + 6), cpu(o + 7));
	}
	printf("  FP multiply/divide work  ");
	for (int i = 0; i < 8; i++)
		printf("%02X", cpu(0x78 + i));
	printf("\n");

	printf("\nCPU register store (5X)\n ");
	for (int i = 0; i < 8; i++)
		printf(" %c=%02X", cpu_regs[i], cpu(0x58 + i));
	printf("\n");

	/* PSW fields held in local storage */
	cc = -1;
	switch (cpu(0xBB) >> 4) {
	case 0x8: cc = 0; break;
	case 0x4: cc = 1; break;
	case 0x2: cc = 2; break;
	case 0x1: cc = 3; break;
	}
	printf("\nPSW fields\n");
	printf("  System mask        %02X\n", cpu(0xB8));
	printf("  Protection key     %X\n", cpu(0xB9) >> 4);
	printf("  AMWP               %X  (%s, %s, %s, %s)\n", cpu(0xB9) & 0xF,
	       (cpu(0xB9) & 8) ? "ASCII" : "EBCDIC",
	       (cpu(0xB9) & 4) ? "MC enabled" : "MC masked",
	       (cpu(0xB9) & 2) ? "Wait" : "Running",
	       (cpu(0xB9) & 1) ? "Problem" : "Supervisor");
	if (cc >= 0)
		printf("  Condition code     %d", cc);
	else
		printf("  Condition code     ? (CR=%X)", cpu(0xBB) >> 4);
	printf("    Program mask %X\n", cpu(0xBB) & 0xF);
	printf("  PSW bit 1 / ILC    %02X\n", cpu(0x8C));
	printf("  Instruction ctr    %02X%02X  (saved; unavailable byte %02X)\n",
	       cpu(0xA9), cpu(0xAA), cpu(0xA8));
	printf("  Op code mask       %02X\n", cpu(0xBC));

	printf("\nSelector channels\n");
	printf("  Sel 1  unit %02X  next CCW %02X%02X\n",
	       cpu(0x8D), cpu(0x8E), cpu(0x8F));
	printf("  Sel 2  unit %02X  next CCW %02X%02X\n",
	       cpu(0xAD), cpu(0xAE), cpu(0xAF));
	printf("  Chaining R %02X   S %02X  U %02X  V %02X\n",
	       cpu(0xAC), cpu(0xBD), cpu(0xBE), cpu(0xBF));

	printf("\nMultiplexor channel\n");
	printf("  Interrupt buffer  unit %02X  status %02X\n", b88, b8b);
	printf("  T reg store %02X  R reg store %02X  unit addr temp %02X\n",
	       b89, b8a, cpu(0x98));

	printf("\n1050 console\n");
	printf("  Sense byte %02X  unit status %02X\n", cpu(0x04), cpu(0x99));

	printf("\nK-addressable bytes\n");
	for (unsigned k = 0; k < 32; k++)
		printf("  K%-2u %02X  %02X  %s\n", k, k_addr(k), cpu(k_addr(k)), k_use[k]);

	printf("\nCPU working storage (CX-FX; columns 0-3 are R12-R15)\n");
	hexdump(CPU_BASE + 0xC0, 0x40);
	printf("\n");
}

static void flag_names(unsigned f, char *buf, size_t len)
{
	static const char *names[8] = {
		"CD", "CC", "SILI", "SKIP", "PCI", "ACTIVE", NULL, NULL
	};
	buf[0] = 0;
	for (int b = 0; b < 6; b++)
		if (f & (0x80 >> b)) {
			strncat(buf, names[b], len - strlen(buf) - 1);
			strncat(buf, " ", len - strlen(buf) - 1);
		}
	strncat(buf, (f & 0x02) ? "OUT " : "IN ", len - strlen(buf) - 1);
	strncat(buf, (f & 0x01) ? "DEC" : "INC", len - strlen(buf) - 1);
}

static void status_names(unsigned s, char *buf, size_t len)
{
	static const char *state[4] = {
		"expects-data", "data-done/status-expected",
		"status-queued(IB full)", "status-in-IB"
	};
	buf[0] = 0;
	if (s & 0x80) strncat(buf, "ZERO-CNT ", len - strlen(buf) - 1);
	if (s & 0x40) strncat(buf, "CHAN-CTL-CHK ", len - strlen(buf) - 1);
	if (s & 0x20) strncat(buf, "INTF-CTL-CHK ", len - strlen(buf) - 1);
	strncat(buf, state[(s >> 3) & 3], len - strlen(buf) - 1);
	if (s & 0x04) strncat(buf, " WRONG-LEN", len - strlen(buf) - 1);
	if (s & 0x02) strncat(buf, " PROG-CHK", len - strlen(buf) - 1);
	if (s & 0x01) strncat(buf, " PROT-CHK", len - strlen(buf) - 1);
}

static void show_mpx(int all)
{
	int shown = 0;

	printf("MULTIPLEXOR UCWs (LS 000-6FF)\n");
	printf("  Area UCW  LS   Stat Flag Count DataA NxCCW  Flags / Status\n");
	for (int area = 0; area < MPX_AREAS; area++) {
		for (int n = 0; n < UCWS_PER_AREA; n++) {
			unsigned a = area * AREA_SIZE + ((n & 15) << 4) + ((n >> 4) << 3);
			const unsigned char *u = &ls[a];
			char fl[64], st[96];
			int zero = 1;

			for (int i = 0; i < 8; i++)
				if (u[i])
					zero = 0;
			if (zero && !all)
				continue;
			flag_names(u[1], fl, sizeof fl);
			status_names(u[0], st, sizeof st);
			printf("  %d    %2d   %03X  %02X   %02X   %02X%02X  %02X%02X  %02X%02X   %s",
			       area, n, a, u[0], u[1], u[2], u[3], u[4], u[5], u[6], u[7], fl);
			if (u[1] & 0x04)	/* status only meaningful when Active */
				printf(" / %s", st);
			printf("\n");
			shown++;
		}
	}
	if (!shown)
		printf("  (all UCWs are zero; use -a to list them)\n");
	printf("\n");
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

/* Write n bytes at LS address addr, then read them back to verify */
static int patch(const char *path, long addr, const unsigned char *val, int n)
{
	unsigned char old[LS_SIZE], chk[LS_SIZE];
	int fd = open(path, O_RDWR);
	int ok = 1;

	if (fd < 0) {
		fprintf(stderr, "%s: %s\n", path, strerror(errno));
		return 1;
	}
	if (pread(fd, old, n, addr) != n) {
		fprintf(stderr, "%s: read at %03lX failed: %s\n", path, addr, strerror(errno));
		close(fd);
		return 1;
	}
	if (pwrite(fd, val, n, addr) != n) {
		fprintf(stderr, "%s: write at %03lX failed: %s\n", path, addr, strerror(errno));
		close(fd);
		return 1;
	}
	if (pread(fd, chk, n, addr) != n) {
		fprintf(stderr, "%s: read-back at %03lX failed: %s\n", path, addr, strerror(errno));
		close(fd);
		return 1;
	}
	close(fd);

	for (int i = 0; i < n; i++) {
		printf("  LS %03lX: %02X -> %02X", addr + i, old[i], chk[i]);
		if (chk[i] != val[i]) {
			printf("  MISMATCH: wrote %02X", val[i]);
			ok = 0;
		}
		printf("\n");
	}
	return ok ? 0 : 1;
}

int main(int argc, char *argv[])
{
	const char *path = "/dev/axi2", *save = NULL;
	int cpu_only = 0, mpx_only = 0, all = 0, raw = 0, opt;
	long paddr = -1;

	while ((opt = getopt(argc, argv, "cmaxo:p:d:h")) != -1) {
		switch (opt) {
		case 'c': cpu_only = 1; break;
		case 'm': mpx_only = 1; break;
		case 'a': all = 1; break;
		case 'x': raw = 1; break;
		case 'o': save = optarg; break;
		case 'd': path = optarg; break;
		case 'p':
			paddr = parse_hex(optarg, LS_SIZE - 1);
			if (paddr < 0) {
				fprintf(stderr, "Invalid LS address '%s' (000-7FF)\n", optarg);
				return 1;
			}
			break;
		default: usage(argv[0]); return opt == 'h' ? 0 : 1;
		}
	}

	if (paddr >= 0) {
		unsigned char val[LS_SIZE];
		int n = argc - optind;

		if (n < 1) {
			fprintf(stderr, "-p needs at least one hex byte value\n");
			return 1;
		}
		if (paddr + n > LS_SIZE) {
			fprintf(stderr, "%d bytes at %03lX would run past 7FF\n", n, paddr);
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

	if (optind < argc)
		path = argv[optind];

	if (load(path))
		return 1;

	if (save) {
		FILE *f = fopen(save, "wb");
		if (!f || fwrite(ls, 1, LS_SIZE, f) != LS_SIZE) {
			fprintf(stderr, "%s: %s\n", save, strerror(errno));
			return 1;
		}
		fclose(f);
	}

	if (!mpx_only)
		show_cpu();
	if (!cpu_only)
		show_mpx(all);
	if (raw) {
		printf("RAW LOCAL STORAGE\n");
		hexdump(0, LS_SIZE);
	}
	return 0;
}
