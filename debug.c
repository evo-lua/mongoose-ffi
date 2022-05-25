#include <stdio.h>

typedef char* String;

#define DEBUG_MODE 1
void DEBUG(String message) {
#ifdef DEBUG_MODE
	printf("[DEBUG] %s\n", message);
#endif

};