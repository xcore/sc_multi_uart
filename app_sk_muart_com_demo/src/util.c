#include <string.h>
#include "common.h"

char console_messages[NUM_CONSOLE_MSGS][CONSOLE_MSGS_MAX_MEN] = {
		"Choose one of the following options \r\n e - echo data \r\n r - UART reconfiguration \r\n b - pipe file on all uart channels\r\n h - usage help\r\n",			//IDX_USAGE_HELP
		"Welcome to MUART Slice Card demo\r\n Choose one of the following options \r\n e - echo data \r\n r - UART reconfiguration \r\n b - pipe file on all uart channels\r\n h - usage help\r\n",  //IDX_WELCOME_USAGE
		"UART now echoes back the data entered\r\n", 				//IDX_ECHO_MODE_MSG
		"Enter new baud rate and Restart serial console with new baud rate setting \r\n", 						//IDX_RECONF_MODE_MSG
		"Restart serial console with new baud rate setting \r\n", //IDX_RECONF_SUCCESS_MSG
		"Specify a valid baud rate \r\n", 						//IDX_RECONF_FAIL_MSG
		"CRC mismatch for uploaded file. Choose one of the menu options \r\n",	//IDX_CRC_MISMATCH_FOR_GET_FILE_MSG
		"CRC value not found! Run crc_appeder host application on file before uploading \r\n",	//IDX_CRC_NA_FOR_GET_FILE_MSG
		"Press any key to fetch file from UART \r\n", 			//IDX_PUT_FILE_MSG
		"Buffered file data is lost \r\n", 						//IDX_FILE_DATA_LOST_MSG
		"Invalid request\r\n Use 'get' option before using 'put' option \r\n",	//IDX_INVALID_PUT_REQUEST
		"\r\nTotal Data Transfer Time per byte(in millisec): \r\n",		//IDX_FILE_STATS
		"UART is in Command mode. Press 'h' for help\r\n",		//IDX_CMD_MODE_MSG
		"UART is in Data mode\r\n",								//IDX_DATA_MODE_MSG
		"Invalid choice. Press 'h' for help\r\n",					//IDX_INVALID_USAGE
		"Muart Pipe Broken, Check Hardware\r\n",					//IDX_PIPE_BROKEN
};


static void reverse_array(char buf[], unsigned size)
{
  int begin = 0;
  int end = size - 1;
  int tmp;
  for (;begin < end;begin++,end--) {
    tmp = buf[begin];
    buf[begin] = buf[end];
    buf[end] = tmp;
  }
}


int itoa(int n, char buf[], int base, int fill)
{ static const char digits[] = "0123456789ABCDEF";
  int i = 0;
  while (n > 0) {
    int next = n / base;
    int cur  = n % base;
    buf[i] = digits[cur];
    i += 1;
    fill--;
    n = next;
  }
  for (;fill > 0;fill--) {
    buf[i] = '0';
    i++;
  }
  reverse_array(buf, i);
  return i;
}

void insert_separator(int time_base, char time_in_char[], int time_in_char_len[], char separator)
{
	//base: 5 for millisec; 2 for sec etc
	int i, limit;

	if (time_in_char_len[0] >= time_base)
		limit = time_in_char_len[0]-time_base;
	else
		limit = 0;

	for (i=time_in_char_len[0];i>limit;i--) {
		time_in_char[i+1] = time_in_char[i];
	}

	time_in_char[i] = separator;
	time_in_char_len[0] += 1;
}

int copy_console_message(char *msg, int index)
{
	int len = strlen(&console_messages[index][0]);
	strcpy(msg, &console_messages[index][0]);

	return len;
}

void string_copy(char *dest, char *src, int len)
{
	strncpy(dest, src, len);
}
