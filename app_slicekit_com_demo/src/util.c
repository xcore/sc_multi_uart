#include <string.h>
#include "common.h"

char console_messages[NUM_CONSOLE_MSGS][CONSOLE_MSGS_MAX_MEN] = {
		"Choose one of the following options \n e - echo data \n r - UART reconfiguration \n g - get file \n p - put file \n h - usage help\n",			//IDX_USAGE_HELP
		"Welcome to MUART Slice Card demo\n Choose one of the following options \n e - echo data \n r - UART reconfiguration \n g - get file \n p - put file \n h - usage help\n",  //IDX_WELCOME_USAGE
		"UART now echoes back the data entered\n", 				//IDX_ECHO_MODE_MSG
		"Enter new baud rate for UART \n", 						//IDX_RECONF_MODE_MSG
		"Restart serial console with new baud rate setting \n", //IDX_RECONF_SUCCESS_MSG
		"Specify a valid baud rate \n", 						//IDX_RECONF_FAIL_MSG
		"Press any key to fetch file from UART \n", 			//IDX_PUT_FILE_MSG
		"Buffered file data is lost \n", 						//IDX_FILE_DATA_LOST_MSG
		"Invalid request\n Use 'get' option before using 'put' option \n",	//IDX_INVALID_PUT_REQUEST
		"\nFile Received Vs File Transferred Timing (in millisec): \n",		//IDX_FILE_STATS
		"UART is in Command mode. Press 'h' for help\n",		//IDX_CMD_MODE_MSG
		"UART is in Data mode\n",								//IDX_DATA_MODE_MSG
		"Invalid choice. Press 'h' for help\n",					//IDX_INVALID_USAGE
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
