#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>

#define NUM_FILE_CHARS_TO_READ	1024
#define CRC_INDICATOR       	'#'

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

int main(int argc, char *argv[]) 
{
    unsigned checksum = 0;
    unsigned data1 = 55;
    unsigned poly = 0xf;
    unsigned num_char= 0;
    FILE *f_input_file;
    FILE *f_output_file;
    char c;
    char crc_array[20];
    int i;
    
    f_input_file = fopen("crc.txt", "rb");
    f_output_file = fopen("crc-1.txt", "wb");
	printf("calculating Checksum...\n");

    while ((!feof(f_input_file)) && (num_char<NUM_FILE_CHARS_TO_READ))
    {
		num_char++;
        c = fgetc(f_input_file);
        
        data1 = toascii(c);
        printf("ANSI value: %d\n", data1);

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
		printf("String checksum Value: %s\n", crc_array);
		
		for (i=0;i<strlen(crc_array);i++) {
            fputc(crc_array[i], f_output_file);
		}
    }


    fclose(f_input_file);
    fclose(f_output_file);
    
	printf("Computed checksum Value: %u\n", checksum);

	system("pause");	
	return 0;
}
