#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/*
 * Generate .coe file for Vivado memory initialisation
 *
 * Card definitions, taken from p30-31 of the
 * IBM Programming Handbook
 * DOS
 * CE Serviceability Programs
 * FES S29-0029
 * (Field Engineering Programming Handbook)
 * http://bitsavers.org/pdf/ibm/360/fe/FE_PgmHbk_1967.pdf
 */
	#define cardSize 80
	struct cardLayouts {
		unsigned char two;
		unsigned char type[3];
		union {
			struct {
				unsigned char ESD_fill1[6];
				unsigned char ESD_count[2];
				unsigned char ESD_fill2[2];
				unsigned char ESD_ESID[2];
				struct {
					unsigned char ESD_name[8];
					unsigned char ESD_type;
					unsigned char ESD_origin[3];
					unsigned char ESD_fill2a;
					unsigned char ESD_length[3];
				} ESD_records[3];
				unsigned char ESD_fill3[8];
			} ESD;
			struct {
				unsigned char TXT_fill1;
				unsigned char TXT_address[3];
				unsigned char TXT_fill2[2];
				unsigned char TXT_count[2];
				unsigned char TXT_fill3[2];
				unsigned char TXT_ESID[2];
				unsigned char TXT_data[56];
			} TXT;
			struct {
				unsigned char RLD_fill1[6];
				unsigned char RLD_count[2];
				unsigned char RLD_fill2[4];
				struct {
					unsigned char RLD_rel1[2];
					unsigned char RLD_rel2[2];
					unsigned char RLD_flags;
					unsigned char RLD_origin[3];
				} RLD_records[7];
			} RLD;
			struct {
				unsigned char END_fill1;
				unsigned char END_origin[3];
				unsigned char END_fill2[6];
				unsigned char END_ESID[2];
				unsigned char END_label[6];
				unsigned char END_fill3[7];
				unsigned char END_controlSectionLength[4];
			} END;
			struct {
				unsigned char REP_fill1[2];
				unsigned char REP_address[6];
				unsigned char REP_fill2;
				unsigned char REP_ESID[3];
				unsigned char REP_data[54];
				unsigned char REP_fill3[2];
			} REP;
		};
		unsigned char id[8];
	} cardImage;

	int byteCount;
    unsigned char mem[65536];

#if 0
/*
 * The Xilinx FPGA image generator will reverse the bits of each data
 * byte it adds to the image, so we need to reverse them here first.
 */
unsigned char bitReverse(unsigned char c)
{
	unsigned char c2;
	c2 = ((c & 0x55)<<1) | ((c & 0xaa)>>1);
	c2 = ((c2 & 0x33)<<2) | ((c2 & 0xcc)>>2);
	return ((c2 & 0x0F)<<4) | ((c2 & 0xF0)>>4);
}
#endif

int oddParity(unsigned char c)
{
    int p = (c >> 4) ^ (c & 0x0f);
    p = (p >> 2) ^ (p & 0x03);
    p = (p >> 1) ^ (p & 0x01);
    return 1-p;
}

/*
 * Ignore ESD records
 */
void handle_ESD() {
	/* Ignore ESD cards for now */
	fputs("ESD card found, ignored\n",stderr);
}

/*
 * The TXT records contain the actual data and are the only ones we actually
 * use.  The code is loaded in its original assembled location.
 */
void handle_TXT() {
	/*
     * Fill in the mem array
	*/
	int i;
	int c = cardImage.TXT.TXT_count[0]*256+cardImage.TXT.TXT_count[1]; /* MSB first */
	if (cardImage.TXT.TXT_address[0]>0) {
		fputs("Address > 64k\n",stderr);
		exit(1);
	}
    unsigned int addr = cardImage.TXT.TXT_address[1]<<8 | cardImage.TXT.TXT_address[2];
	for (i = 0; i<c; i++) {
        mem[addr + i] = cardImage.TXT.TXT_data[i];
	}
}

/*
 * Ignore RLD cards for now - no automatic relocation
 * We should check for external references and flag if we find any,
 * since we can't link them properly
 */
void handle_RLD() {
	/* Ignore RLD cards for now */
	fputs("RLD card found, ignored\n",stderr);
}

/*
 * The END card terminates the image
 * and writes the entire memory to the output file.
 */
void handle_END() {
    for (unsigned int a = 0; a < sizeof(mem); a++) {
        fprintf(stdout, "%08b%01b\n", mem[a], oddParity(mem[a]));
    }
}

/*
 * REP cards are for patching and don't really apply here, so they are
 * ignored.  We could flag if there are any and refuse to work.
 */
void handle_REP() {
	/* Ignore REP cards for now */
	fputs("REP card found, ignored\n",stderr);
}

void main(int argc, char *argv[]) {
	if ((argc==2) && (strcmp(argv[1],"-v")==0)) {		
		printf("PCH to MEM file converter 2025-11-20\n");
		exit(0);
	}
    fprintf(stdout,"memory_initialization_radix = 2;\nmemory_initialization_vector =\n");
	while (1) {
		byteCount = fread((char*)&cardImage,1,cardSize,stdin);
        if (byteCount == cardSize) {
			if (cardImage.two==64) /* Skip blank cards */
				fputs("Skipping blank card\n",stderr);
			else if (cardImage.two!=2) {
				/* Loader cards should always have 02 as the first byte (12-2-9) */
				fputs("Non-loader card found, not EBCDIC?\n",stderr);
			}
			else if ((cardImage.type[0]==0xc5) && (cardImage.type[1]==0xe2) && (cardImage.type[2]==0xc4))	/* ESD */
				handle_ESD();
			else if ((cardImage.type[0]==0xe3) && (cardImage.type[1]==0xe7) && (cardImage.type[2]==0xe3))	/* TXT */
				handle_TXT();
			else if ((cardImage.type[0]==0xd9) && (cardImage.type[1]==0xd3) && (cardImage.type[2]==0xc4))	/* RLD */
				handle_RLD();
			else if ((cardImage.type[0]==0xc5) && (cardImage.type[1]==0xd5) && (cardImage.type[2]==0xc4))	/* END */
				handle_END();
			else if ((cardImage.type[0]==0xd9) && (cardImage.type[1]==0xc5) && (cardImage.type[2]==0xd7))	/* REP */
				handle_REP();
			else fputs("Unrecognised card type found, not EBCDIC?\n",stderr);
		}
		else
			exit(0);
	}
    fprintf(stdout,";\n");
}

