#include <stdlib.h>
#include "dadd.h"

#define ARGC 2

int dadd(int x, int y)
{
	int i = 0;
	int retVal = 0;
	int *ptr = (int*) malloc(ARGC * sizeof(int));

	ptr[0] = x;
	ptr[1] = y;

	retVal = 0;
	for(i=0; i < ARGC; i++) {
		if(ptr[i]<0)
			ptr[i]=-ptr[i];
		retVal += ptr[i];
	}

	return retVal;
}
