#include <string.h>
#include "common.h"

char trace_messages[NUM_TX_TRACE_MSGS][TRACE_MSGS_MAX_MEN] = {
		"Choose one of the following options \n e - echo data \n r - UART reconfiguration \n g - get file \n p - put file \n h - usage help\n",			//IDX_USAGE_HELP
		"Welcome to MUART slice demo\n Choose one of the following options \n e - echo data \n r - UART reconfiguration \n g - get file \n p - put file \n h - usage help\n",  //IDX_WELCOME_USAGE
		"UART now echoes back the data entered\n", //IDX_ECHO_MODE_MSG
		"Enter new baud rate for UART \n", //IDX_RECONF_MODE_MSG
		"Restart serial console with new baud rate setting \n", //IDX_RECONF_SUCCESS_MSG
		"Specify a valid baud rate \n", 	//IDX_RECONF_FAIL_MSG
		"UART is in Command mode. Press 'h' for help\n",		//IDX_CMD_MODE_MSG
		"UART is in Data mode\n",			//IDX_DATA_MODE_MSG
		"Invalid choice. Press 'h' for help\n",		//IDX_INVALID_USAGE
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

int string_copy(char *src, int index)
{
	int len = strlen(&trace_messages[index][0]);
	strcpy(src, &trace_messages[index][0]);

	return len;
}
