#ifndef UTIL_H_
#define UTIL_H_

int itoa(int n, char buf[], int base, int fill);

int copy_console_message(REFERENCE_PARAM(char, msg), int index);
void string_copy(REFERENCE_PARAM(char, dest), REFERENCE_PARAM(char, src), int len);

#endif /* UTIL_H_ */
