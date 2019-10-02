#include <iostream>
#include <cstdio>
#include <cstdlib>
#include "pobu.h"
using namespace std;

#define MEM_SIZE (uint64_t)1024 * 1024 * 1024 * 4

struct element
{
    uint64_t* next;
    uint64_t* pre;
    double data[6];
};

int main()
{
    // make sure mem addr is aligned
    element* mem = (element*)page_aligned_malloc(MEM_SIZE);
    //if(mem != NULL) memset(mem, 0, MEM_SIZE);

    uint64_t num_entries = MEM_SIZE / CACHE_BLOCK_SIZE;
    uint64_t num_iterations = 300;
    
    
    printf("[into] linked list element size is %lu bytes\n", sizeof(element));
    printf("[into] entering into the main loop with %lld iterations\n", num_iterations);

    set_timer_start(0);
    while (num_iterations--)
    {
        for (int i = 0; i < num_entries; i+= CACHE_BLOCK_SIZE)
        {
    	    mem[i].data[0] = i;
        }
    }
    set_timer_end(0);
    print_timer(0, "test");

    free(mem);

    return 0;
}

