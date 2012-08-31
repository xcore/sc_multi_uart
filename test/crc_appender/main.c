#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>

//#define DEBUG                   1
#define NUM_FILE_CHARS_TO_READ	1000
#define CRC_INDICATOR       	'#'
#define CRC_POLYNOMIAL          0xf

void welcome_text(void)
{
	printf("CRC Appender Utility\n");
	printf("---------------------\n");
	printf("This application computes CRC value of input file and appends it to the end of output file\n");
	printf("Use output file as upload file to test MUART Slice Card File upload feature\n\n");
	printf("Limitations:\n");
	printf(">> Input file should be of size < 1KB; for larger size files, only first 1KB data is used to compute checksum\n\n");
}

int calc_checksum(unsigned *checksum, unsigned data, unsigned poly)
{
	int i;
	int xorBit;
	
	for (i = 0; i < 32; i++) {
		xorBit = (*checksum & 1);

		*checksum  = (*checksum >> 1) | ((data & 1) << 31);
		data = data >> 1;

		if (xorBit)
				*checksum = *checksum ^ poly;
	}
}

void usage(void)
{
	printf("Usage:\n");
	printf(" -i<input file name>\n");
	printf(" -o<output file name>\n\n");
	printf("Sample usage: crc32 -iinput_file_name -ooutput_file_name\n\n");
	exit (2);
}

int main(int argc, char *argv[]) 
{
    unsigned poly = CRC_POLYNOMIAL;
    FILE *f_input_file;
    FILE *f_output_file;
    unsigned checksum = 0;
    unsigned data1 = 55;
    unsigned num_char= 0;
    char crc_array[20];
    char c;
    int i;
    char in_file_name[50] = "";//"infile";
    char out_file_name[50] = "outfile";
    
    welcome_text();

	while ((argc > 1) && (argv[1][0] == '-'))
	{
		switch (argv[1][1])
		{
			case 'i':
				strcpy(in_file_name, &argv[1][2]);
				break;

			case 'o':
				//printf("%s\n",&argv[1][2]);
				strcpy(out_file_name, &argv[1][2]);
				break;

			default:
				printf("Invalid usage: %s\n", argv[1]);
				usage();
		}

		++argv;
		--argc;
	}
	
    f_input_file = fopen(in_file_name, "rb");
    
    if (NULL == f_input_file)
    {
        printf("Invalid input file. \t <File %s is not present on host directory!>\n", in_file_name);
    }
    else
    {
	    f_output_file = fopen(out_file_name, "wb");
		printf("Calculating file Checksum...\n\n");

	    while ((!feof(f_input_file)) && (num_char<NUM_FILE_CHARS_TO_READ))
	    {
			num_char++;
	        c = fgetc(f_input_file);

	        data1 = toascii(c);
#ifdef DEBUG
	        printf("ANSI value: %d\n", data1);
#endif //DEBUG

			if (data1 != 127) {
				calc_checksum(&checksum, data1, poly);

				/* Write char to output file */
				fputc(c, f_output_file);
			}
	    } // while(!feof(f_input_file))

	    /* Append CRC to end of output file */
	    {
			c = CRC_INDICATOR;
	        /* Write CRC flag to output file */
			fputc(c, f_output_file);
			itoa(checksum, crc_array, 10);
#ifdef DEBUG
			printf("String checksum Value: %s\n", crc_array);
#endif //DEBUG

			for (i=0;i<strlen(crc_array);i++) {
	            fputc(crc_array[i], f_output_file);
			}
	    }

	    fclose(f_input_file);
	    fclose(f_output_file);

		printf("Computed checksum Value '%u' is appended at the end of output file %s\n\n", checksum, out_file_name);
    }

	system("pause");
	return 0;
}
