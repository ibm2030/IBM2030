#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#define ccrosLineSize 100
#define versions "   |004|005|006|007|010|014|025|A20"
/*
#AAA  CN CH   CL   CM  CU CA   CB CK   CD   CF  CG CV CC  CS   AAASAKPK
 102  F3 0001 0001 110 01 ???? ?? 0010 0110 000 00 00 000 0000 ? 0 0 1 # QA001:C2
*/
struct ccrosLayout {
	char space1;
	char ADDR[3];
	char space2[2];
	char CN[2];
	char space3;
	char CH[4];
	char space4;
	char CL[4];
	char space5;
	char CM[3];
	char space6;
	char CU[2];
	char space7;
	char CA[4];
	char space8;
	char CB[2];
	char space9;
	char CK[4];
	char space10;
	char CD[4];
	char space11;
	char CF[3];
	char space12;
	char CG[2];
	char space13;
	char CV[2];
	char space14;
	char CC[3];
	char space15;
	char CS[4];
	char space16;
	char AA;
	char space17;
	char AS;
	char space18;
	char AK;
	char space19;
	char PK;
	char space20;
	char comment[11]; /* # QANNN:RN- */
	char version[3];
	} ccrosLine;

typedef struct  {
	int address;
	char ccros[56];	/* Final char is NUL */
	} ccrosEntry;

ccrosEntry ccros[4096];
int ccrosEntryCount;
char *flag;
char *ptr;
int	i;
char thisVersion[4];

int htoi(char *hex, int length) {
	int value = 0;
	char ch;

	for (;length>0;length--) {
		ch = *(hex++);
		if (ch >= '0' && ch <= '9')
			value = (value << 4) + (ch - '0');
		else if (ch >= 'A' && ch <= 'F')
			value = (value << 4) + (ch - 'A' + 10);
		else if (ch >= 'a' && ch <= 'f')
			value = (value << 4) + (ch - 'a' + 10);
		else
			return value;
	}
}

char * itob(int value, char *buffer, int length) {
	char *ptr;
	ptr = buffer + length;
	for (;length>0;length--) {
		*--ptr = '0' + (value & 1);
		value = value >> 1;
	}
	return buffer;
}

char parity(char *buffer, int length, char start) {
	char result = start;
	for (;length>0;length--) {
		result^=(*buffer++ & 1);
	}
	return result;
}

main (int argc, char *argv[]) {
	if ((argc==2) && (strcmp(argv[1],"-v")==0)) {		
		printf("CCROS file converter 2012-04-07\n");
		exit(0);
	}
	ccrosEntryCount = 0;
	while (1) {
		ccrosLine.version[0]=' ';
		ccrosLine.version[1]=' ';
		ccrosLine.version[2]=' ';
		flag = gets((char*)&ccrosLine);
		if (flag != NULL) {
			thisVersion[0]=ccrosLine.version[0];
			thisVersion[1]=ccrosLine.version[1];
			thisVersion[2]=ccrosLine.version[2];
			thisVersion[3]='\0';
			if (ccrosLine.space1=='#') {
				/* Ignore comment line */
			} 
			else if (  (ccrosLine.space1 !=' ') | (ccrosLine.space2[0] !=' ') | (ccrosLine.space2[1] !=' ') | (ccrosLine.space3 !=' ') | (ccrosLine.space4 !=' ') | (ccrosLine.space5 !=' ')
					 | (ccrosLine.space6 !=' ') | (ccrosLine.space7 !=' ') | (ccrosLine.space8 !=' ') | (ccrosLine.space9 !=' ') | (ccrosLine.space10!=' ')
					 | (ccrosLine.space11!=' ') | (ccrosLine.space12!=' ') | (ccrosLine.space13!=' ') | (ccrosLine.space14!=' ') | (ccrosLine.space15!=' ')
					 | (ccrosLine.space16!=' ') | (ccrosLine.space17!=' ') | (ccrosLine.space18!=' ') | (ccrosLine.space19!=' ') | (ccrosLine.space20!=' ')) {
				/* Skip invalid line */
				printf("Line format error\r\n");
				puts((char*)&ccrosLine);
				printf("\r\n");
				exit(1);
				}
			else if (strstr(versions,(char*)&thisVersion[0])==NULL) {
				/* Skip it */
			}
			else {
				char cnBinary[9];
				cnBinary[8]='\0';
				char addrBinary[13];
				addrBinary[12]='\0';
				/* Handle CCROS line - convert to a 56-bit binary string in the same order */
				ccros[ccrosEntryCount].address = htoi(ccrosLine.ADDR,3);
				itob(ccros[ccrosEntryCount].address,addrBinary,12);

				ccros[ccrosEntryCount].ccros[55] = '\0';
				/* Generate binary from top 6 bits of CN */
				itob(htoi(ccrosLine.CN,2),cnBinary,8);

				/* 0 (PN) is calculated later */
				ccros[ccrosEntryCount].ccros[0] = '0';

				ccros[ccrosEntryCount].ccros[1] = cnBinary[0];
				ccros[ccrosEntryCount].ccros[2] = cnBinary[1];
				ccros[ccrosEntryCount].ccros[3] = cnBinary[2];
				ccros[ccrosEntryCount].ccros[4] = cnBinary[3];
				ccros[ccrosEntryCount].ccros[5] = cnBinary[4];
				ccros[ccrosEntryCount].ccros[6] = cnBinary[5];

				/* 7 (PS) and 8 (PA) are calculated later */
				ccros[ccrosEntryCount].ccros[7] = '0';
				ccros[ccrosEntryCount].ccros[8] = '0';

				ccros[ccrosEntryCount].ccros[9] = ccrosLine.CH[0];
				ccros[ccrosEntryCount].ccros[10] = ccrosLine.CH[1];
				ccros[ccrosEntryCount].ccros[11] = ccrosLine.CH[2];
				ccros[ccrosEntryCount].ccros[12] = ccrosLine.CH[3];

				ccros[ccrosEntryCount].ccros[13] = ccrosLine.CL[0];
				ccros[ccrosEntryCount].ccros[14] = ccrosLine.CL[1];
				ccros[ccrosEntryCount].ccros[15] = ccrosLine.CL[2];
				ccros[ccrosEntryCount].ccros[16] = ccrosLine.CL[3];

				ccros[ccrosEntryCount].ccros[17] = ccrosLine.CM[0];
				ccros[ccrosEntryCount].ccros[18] = ccrosLine.CM[1];
				ccros[ccrosEntryCount].ccros[19] = ccrosLine.CM[2];

				ccros[ccrosEntryCount].ccros[20] = ccrosLine.CU[0];
				ccros[ccrosEntryCount].ccros[21] = ccrosLine.CU[1];

				ccros[ccrosEntryCount].ccros[22] = ccrosLine.CA[0];
				ccros[ccrosEntryCount].ccros[23] = ccrosLine.CA[1];
				ccros[ccrosEntryCount].ccros[24] = ccrosLine.CA[2];
				ccros[ccrosEntryCount].ccros[25] = ccrosLine.CA[3];

				ccros[ccrosEntryCount].ccros[26] = ccrosLine.CB[0];
				ccros[ccrosEntryCount].ccros[27] = ccrosLine.CB[1];

				ccros[ccrosEntryCount].ccros[28] = ccrosLine.CK[0];
				ccros[ccrosEntryCount].ccros[29] = ccrosLine.CK[1];
				ccros[ccrosEntryCount].ccros[30] = ccrosLine.CK[2];
				ccros[ccrosEntryCount].ccros[31] = ccrosLine.CK[3];

				ccros[ccrosEntryCount].ccros[32] = ccrosLine.PK;

				/* 32 (PC) is calculated later */
				ccros[ccrosEntryCount].ccros[33] = '0';

				ccros[ccrosEntryCount].ccros[34] = ccrosLine.CD[0];
				ccros[ccrosEntryCount].ccros[35] = ccrosLine.CD[1];
				ccros[ccrosEntryCount].ccros[36] = ccrosLine.CD[2];
				ccros[ccrosEntryCount].ccros[37] = ccrosLine.CD[3];

				ccros[ccrosEntryCount].ccros[38] = ccrosLine.CF[0];
				ccros[ccrosEntryCount].ccros[39] = ccrosLine.CF[1];
				ccros[ccrosEntryCount].ccros[40] = ccrosLine.CF[2];

				ccros[ccrosEntryCount].ccros[41] = ccrosLine.CG[0];
				ccros[ccrosEntryCount].ccros[42] = ccrosLine.CG[1];

				ccros[ccrosEntryCount].ccros[43] = ccrosLine.CV[0];
				ccros[ccrosEntryCount].ccros[44] = ccrosLine.CV[1];

				ccros[ccrosEntryCount].ccros[45] = ccrosLine.CC[0];
				ccros[ccrosEntryCount].ccros[46] = ccrosLine.CC[1];
				ccros[ccrosEntryCount].ccros[47] = ccrosLine.CC[2];

				ccros[ccrosEntryCount].ccros[48] = ccrosLine.CS[0];
				ccros[ccrosEntryCount].ccros[49] = ccrosLine.CS[1];
				ccros[ccrosEntryCount].ccros[50] = ccrosLine.CS[2];
				ccros[ccrosEntryCount].ccros[51] = ccrosLine.CS[3];

				ccros[ccrosEntryCount].ccros[52] = ccrosLine.AA;
				ccros[ccrosEntryCount].ccros[53] = ccrosLine.AS;
				ccros[ccrosEntryCount].ccros[54] = ccrosLine.AK;

				/* Now change any ? to 0 */
				for (ptr=&ccros[ccrosEntryCount].ccros[0];ptr<=&ccros[ccrosEntryCount].ccros[54];ptr++)
					if (*ptr=='?') *ptr='0';

				/* PA */
				ccros[ccrosEntryCount].ccros[8] = parity(addrBinary,12,'1');

				/* PN = CN */
				ccros[ccrosEntryCount].ccros[0] = parity((char*)&ccros[ccrosEntryCount].ccros[1],6,'1');

				/* PS = PA CH CL CM CU CA CB CK PK AA AK */
				ccros[ccrosEntryCount].ccros[7] = parity((char*)&ccros[ccrosEntryCount].ccros[8],25,
						parity((char*)&ccros[ccrosEntryCount].ccros[52],1,
							parity((char*)&ccros[ccrosEntryCount].ccros[54],1,'1'
							)
						)
				);

				/* PC = CD CF CG CV CC CS AS */
				ccros[ccrosEntryCount].ccros[33] = parity((char*)&ccros[ccrosEntryCount].ccros[34],18,
					parity((char*)&ccros[ccrosEntryCount].ccros[53],1,'1'
					)
				);

				/* BA0 flip PA & PC */
				if (ccros[ccrosEntryCount].address==0xBA0) {
					ccros[ccrosEntryCount].ccros[8] = ccros[ccrosEntryCount].ccros[8] ^ 1;
					ccros[ccrosEntryCount].ccros[33] = ccros[ccrosEntryCount].ccros[33] ^ 1;
				}
				/* B60 flip PN, PS, PA & PC */
				if (ccros[ccrosEntryCount].address==0xB60) {
					ccros[ccrosEntryCount].ccros[0] = ccros[ccrosEntryCount].ccros[0] ^ 1;
					ccros[ccrosEntryCount].ccros[7] = ccros[ccrosEntryCount].ccros[7] ^ 1;
					ccros[ccrosEntryCount].ccros[8] = ccros[ccrosEntryCount].ccros[8] ^ 1;
					ccros[ccrosEntryCount].ccros[33] = ccros[ccrosEntryCount].ccros[33] ^ 1;
				}
				ccrosEntryCount++;
			}
		}
		else
			break;
	}
	/* Now output */
	for (i=0;i<ccrosEntryCount;i++) {
		printf("16#%03x# => \"%s\",\r\n",ccros[i].address,(char*)&ccros[i].ccros[0]);
	}
}
