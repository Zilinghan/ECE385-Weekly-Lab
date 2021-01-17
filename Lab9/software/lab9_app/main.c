/************************************************************************
Lab 9 Nios Software

Dong Kai Wang, Fall 2017
Christine Chen, Fall 2013

For use with ECE 385 Experiment 9
University of Illinois ECE Department
************************************************************************/

#include <stdlib.h>
#include <stdio.h>
#include <time.h>
#include "aes.h"

// Pointer to base address of AES module, make sure it matches Qsys
volatile unsigned int * AES_PTR = (unsigned int *) 0x00000100;

// Execution mode: 0 for testing, 1 for benchmarking
int run_mode = 0;

/** charToHex
 *  Convert a single character to the 4-bit value it represents.
 *  
 *  Input: a character c (e.g. 'A')
 *  Output: converted 4-bit value (e.g. 0xA)
 */
char charToHex(char c)
{
	char hex = c;

	if (hex >= '0' && hex <= '9')
		hex -= '0';
	else if (hex >= 'A' && hex <= 'F')
	{
		hex -= 'A';
		hex += 10;
	}
	else if (hex >= 'a' && hex <= 'f')
	{
		hex -= 'a';
		hex += 10;
	}
	return hex;
}

/** charsToHex
 *  Convert two characters to byte value it represents.
 *  Inputs must be 0-9, A-F, or a-f.
 *  
 *  Input: two characters c1 and c2 (e.g. 'A' and '7')
 *  Output: converted byte value (e.g. 0xA7)
 */
char charsToHex(char c1, char c2)
{
	char hex1 = charToHex(c1);
	char hex2 = charToHex(c2);
	return (hex1 << 4) + hex2;
}

void AddRoundKey(unsigned char * State, unsigned char * RoundKey)
{
	for(int i=0;i<16;i++)
	{
		State[i]=State[i]^RoundKey[i];
	}
	return;
}

void SubBytes(unsigned char * State)
{
	for(int i=0;i<16;i++)
	{
		State[i]=aes_sbox[State[i]];
	}
	return;
}

void InvSubBytes(unsigned char *State)
{
	for (int i = 0; i < 16; i++)
	{
		State[i] = aes_invsbox[State[i]];
	}
	return;
}

void ShiftRows(unsigned char *State)
{
	unsigned char temp;
	// 1 shift
	temp=State[1];
	State[1]=State[5];
	State[5]=State[9];
	State[9]=State[13];
	State[13]=temp;
	// 2 shift
	temp=State[2];
	State[2]=State[10];
	State[10]=temp;
	temp=State[6];
	State[6]=State[14];
	State[14]=temp;
	// 3 shift
	temp=State[3];
	State[3]=State[15];
	State[15]=State[11];
	State[11]=State[7];
	State[7]=temp;
	return;
}

void InvShiftRows(unsigned char *State)
{
	unsigned char temp;
	// Inverse 1 shift
	temp = State[13];
	State[13] = State[9];
	State[9] = State[5];
	State[5] = State[1];
	State[1] = temp;
	// Inverse 2 shift
	temp = State[2];
	State[2] = State[10];
	State[10] = temp;
	temp = State[6];
	State[6] = State[14];
	State[14] = temp;
	// Inverse 3 shift
	temp = State[7];
	State[7] =  State[11];
	State[11] = State[15];
	State[15] = State[3];
	State[3] = temp;
	return;
}

unsigned char xtime(unsigned char a)
{
	if (0x80 & a)
	{
		return (a<<1) ^ 0x1b;
	}
	else
	{
		return a<<1;
	}
}

void MixColumns(unsigned char *State)
{
	unsigned char b[4];
	for(int i=0;i<4;i++)
	{
		b[0]=xtime(State[4*i]) ^ xtime(State[4*i+1]) ^ State[4*i+1] ^ State[4*i+2] ^ State[4*i+3];
		b[1]=State[4*i] ^ xtime(State[4*i+1]) ^ xtime(State[4*i+2]) ^ State[4*i+2] ^ State[4*i+3];
		b[2]=State[4*i] ^ State[4*i+1] ^ xtime(State[4*i+2]) ^ xtime(State[4*i+3]) ^ State[4*i+3];
		b[3]=xtime(State[4*i]) ^ State[4*i] ^ State[4*i+1] ^ State[4*i+2] ^ xtime(State[4*i+3]);
		for(int j=0;j<4;j++)
		{
			State[4*i+j]=b[j];
		}
	}
	return;
}

void InvMixColumns(unsigned char *State)
{
	unsigned char b[4];
	for(int i=0;i<4;i++)
	{
		//{0x02, 0x03, 0x09, 0x0b, 0x0d, 0x0e}
		b[0]=gf_mul[State[4*i]][5] ^ gf_mul[State[4*i+1]][3] ^ gf_mul[State[4*i+2]][4] ^ gf_mul[State[4*i+3]][2];
		b[1]=gf_mul[State[4*i]][2] ^ gf_mul[State[4*i+1]][5] ^ gf_mul[State[4*i+2]][3] ^ gf_mul[State[4*i+3]][4];
		b[2]=gf_mul[State[4*i]][4] ^ gf_mul[State[4*i+1]][2] ^ gf_mul[State[4*i+2]][5] ^ gf_mul[State[4*i+3]][3];
		b[3]=gf_mul[State[4*i]][3] ^ gf_mul[State[4*i+1]][4] ^ gf_mul[State[4*i+2]][2] ^ gf_mul[State[4*i+3]][5];
		for(int j=0;j<4;j++)
		{
			State[4*i+j]=b[j];
		}
	}
	return;
}

void RotWord(unsigned char * word)
{
	unsigned char temp;
	temp=word[0];
	word[0]=word[1];
	word[1]=word[2];
	word[2]=word[3];
	word[3]=temp;
	return;
}

void SubWord(unsigned char * word)
{
	for(int i=0;i<4;i++)
	{
		word[i]=aes_sbox[word[i]];
	}
	return;	
}

void KeyExpansion(unsigned char * key, unsigned char * w, int Nr)
{
	// Nb, Nk Number of words(columns) in a state(key) (always 4)
	// Nr number of looping rounds
	unsigned char temp[4];
	int i;
	for(i=0;i<4;i++)
	{
		for(int j=0;j<4;j++)
		{
			w[4*i+j]=key[4*i+j];
		}
	}
	for(i=4;i<4*(Nr+1);i++)
	{
		for(int j=0;j<4;j++)
		{
			temp[j]=w[4*(i-1)+j];
		}
		if(0==(i % 4))
		{
			RotWord(temp);
			SubWord(temp);
			for(int j=0;j<4;j++)
			{
				temp[j]=temp[j] ^ ((Rcon[i/4] >> (24-8*j)) & 0xFF);
			}
		}
		for(int j=0;j<4;j++)
		{
			w[4*i+j]=w[4*(i-4)+j] ^ temp[j];
		}
	}
	return;
}

/** encrypt
 *  Perform AES encryption in software.
 *
 *  Input: msg_ascii - Pointer to 32x 8-bit char array that contains the input message in ASCII format
 *         key_ascii - Pointer to 32x 8-bit char array that contains the input key in ASCII format
 *  Output:  msg_enc - Pointer to 4x 32-bit int array that contains the encrypted message
 *               key - Pointer to 4x 32-bit int array that contains the input key
 */
void encrypt(unsigned char * msg_ascii, unsigned char * key_ascii, unsigned int * msg_enc, unsigned int * key)
{
	int Nr=10;
	unsigned char msg_char[16];
	unsigned char key_char[16];
	for(int i=0;i<16;i++){
		key_char[i]=charsToHex(key_ascii[2*i],key_ascii[2*i+1]);
		msg_char[i]=charsToHex(msg_ascii[2*i],msg_ascii[2*i+1]);
	}
	for(int i=0;i<4;i++)
	{
		key[i]=0;
		for(int j=0;j<4;j++)
		{
			key[i]=key[i]<<8;
			key[i]+=key_char[4*i+j];
		}
	}
	unsigned char state[16];
	unsigned char w[16*(Nr+1)];
	KeyExpansion(key_char, w, Nr);
	/*
	for(int i=0;i<Nr+1;i++)
	{
		printf("\nThe %d key is:\n",i+1);
		for(int j=0;j<16;j++)
		{
			printf("%02x",w[16*i+j]);
		}
	}
	printf("\n");
	*/
	for(int i=0;i<16;i++)
	{
		state[i]=msg_char[i];
	}
	AddRoundKey(state,w);
	/*
	printf("\nThe state after the %d AddRoundKey is:\n", 1);
	for (int j = 0; j < 16; j++)
	{
		printf("%02x", state[j]);
	}
	printf("\n");
	*/
	for(int round=1;round<Nr;round++)
	{
		SubBytes(state);
		ShiftRows(state);
		MixColumns(state);
		AddRoundKey(state,w+16*round);
		/*
		printf("\nThe state after the %d AddRoundKey is:\n", round+1);
		for (int j = 0; j < 16; j++)
		{
			printf("%02x", state[j]);
		}
		printf("\n");
		*/
	}
	SubBytes(state);
	ShiftRows(state);
	AddRoundKey(state,w+16*Nr);
	/*
	printf("\nThe state after the %d AddRoundKey is:\n", Nr+1);
	for (int j = 0; j < 16; j++)
	{
		printf("%02x", state[j]);
	}
	printf("\n");
	*/
	for(int i=0;i<4;i++)
	{
		msg_enc[i]=0;
		for (int j = 0; j < 4; j++)
		{
			msg_enc[i] = msg_enc[i] << 8;
			msg_enc[i] += state[4 * i + j];
		}
	}
	return;
}

/** decrypt
 *  Perform AES decryption in hardware.
 *
 *  Input:  msg_enc - Pointer to 4x 32-bit int array that contains the encrypted message
 *              key - Pointer to 4x 32-bit int array that contains the input key
 *  Output: msg_dec - Pointer to 4x 32-bit int array that contains the decrypted message
 */
void decrypt(unsigned int * msg_enc, unsigned int * msg_dec, unsigned int * key)
{
	// Implement this function
	for (int i = 0; i < 4; i++)
	{
		AES_PTR[i] = key[i];
		AES_PTR[i+4] = msg_enc[i];
	}
	AES_PTR[14] = 1;
	while(0==AES_PTR[15])
	{
		continue;
	}
	AES_PTR[14] = 0;
	for (int i = 0; i < 4; i++)
	{
		msg_dec[i] = AES_PTR[i + 8];
	}
	return;	
	/*
	int Nr=10;
	unsigned char msg_char[16];
	unsigned char key_char[16];
	for(int i=0;i<16;i++)
	{
		key_char[i]=(key[i/4] >> 8*(3-(i%4))) & 0xFF;
		msg_char[i]=(msg_enc[i/4] >> 8*(3-(i%4))) & 0xFF;
	}
	unsigned char state[16];
	unsigned char w[16*(Nr+1)];	
	KeyExpansion(key_char, w, Nr);
	for(int i=0;i<16;i++)
	{
		state[i]=msg_char[i];
	}
	AddRoundKey(state,w+16*Nr);
	for(int round=Nr-1;round>0;round--)
	{
		InvShiftRows(state);
		InvSubBytes(state);
		AddRoundKey(state,w+16*round);
		InvMixColumns(state);
	}
	InvShiftRows(state);
	InvSubBytes(state);
	AddRoundKey(state,w);
	for(int i=0;i<4;i++)
	{
		msg_dec[i]=0;
		for (int j = 0; j < 4; j++)
		{
			msg_dec[i] = msg_dec[i] << 8;
			msg_dec[i] += state[4 * i + j];
		}
	}
	return;
	*/
}

/** main
 *  Allows the user to enter the message, key, and select execution mode
 *
 */
int main()
{
	// Input Message and Key as 32x 8-bit ASCII Characters ([33] is for NULL terminator)
	unsigned char msg_ascii[33];
	unsigned char key_ascii[33];
	// Key, Encrypted Message, and Decrypted Message in 4x 32-bit Format to facilitate Read/Write to Hardware
	unsigned int key[4];
	unsigned int msg_enc[4];
	unsigned int msg_dec[4];

	printf("Select execution mode: 0 for testing, 1 for benchmarking: ");
	scanf("%d", &run_mode);

	if (run_mode == 0) {
		// Continuously Perform Encryption and Decryption
		while (1) {
			int i = 0;
			printf("\nEnter Message:\n");
			scanf("%s", msg_ascii);
			printf("\n");
			printf("\nEnter Key:\n");
			scanf("%s", key_ascii);
			printf("\n");
			encrypt(msg_ascii, key_ascii, msg_enc, key);
			printf("\nEncrpted message is: \n");
			for(i = 0; i < 4; i++){
				printf("%08x", msg_enc[i]);
			}
			printf("\n");
			for(int i=0;i<4;i++)
			{
				AES_PTR[i]=key[i];
			}
			decrypt(msg_enc, msg_dec, key);
			printf("\nDecrypted message is: \n");
			for(i = 0; i < 4; i++){
				printf("%08x", msg_dec[i]);
			}
			printf("\n");
		}
	}
	else {
		// Run the Benchmark
		int i = 0;
		int size_KB = 2;
		// Choose a random Plaintext and Key
		for (i = 0; i < 32; i++) {
			msg_ascii[i] = 'a';
			key_ascii[i] = 'b';
		}
		// Run Encryption
		clock_t begin = clock();
		for (i = 0; i < size_KB * 64; i++)
			encrypt(msg_ascii, key_ascii, msg_enc, key);
		clock_t end = clock();
		double time_spent = (double)(end - begin) / CLOCKS_PER_SEC;
		double speed = size_KB / time_spent;
		printf("Software Encryption Speed: %f KB/s \n", speed);
		// Run Decryption
		begin = clock();
		for (i = 0; i < size_KB * 64; i++)
			decrypt(msg_enc, msg_dec, key);
		end = clock();
		time_spent = (double)(end - begin) / CLOCKS_PER_SEC;
		speed = size_KB / time_spent;
		printf("Hardware Encryption Speed: %f KB/s \n", speed);
	}
	return 0;
}
