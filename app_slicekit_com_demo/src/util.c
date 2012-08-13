#include <string.h>
#include "common.h"

char trace_messages[NUM_TX_TRACE_MSGS][RX_CHANNEL_FIFO_LEN] = {
		"Choose one of the following options \n e - echo data \n r - UART reconfiguration \n g - get file \n p - put file \n h - usage help"
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

int str_cpy(char *src, int index)
{
	int len = strlen(&trace_messages[index][0]);
	strcpy(src, &trace_messages[index][0]);

	return len;
}
