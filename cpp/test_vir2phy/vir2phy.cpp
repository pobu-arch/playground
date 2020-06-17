#include <cstdio>
#include "veronica.h"

int main()
{
	int* pointer = (int*)malloc(sizeof(int));
	
	printf("%p %x\n", pointer, veronica::mem_addr_vir2phy((unsigned long)pointer));
	
	free(pointer);
	
	return 0;
}
