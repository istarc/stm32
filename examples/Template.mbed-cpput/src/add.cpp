#include "add.h"

int add(int x, int y)
{
	if(x<0)
		x=-x;
	if(y<0)
		y=-y;
	return x+y;
}
