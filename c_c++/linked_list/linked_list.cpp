#include <iostream>
#include <cstdio>
#include <cstdlib>
#include "pobu.h"
using namespace std;

#define NUM_ELEMENTS (uint64_t) 2147483647

uint32_t* ptr[NUM_ELEMENTS];

int main()
{
    // make sure mem addr is aligned
    uint32_t** mem = (uint32_t**)page_aligned_malloc(NUM_ELEMENTS * sizeof(unsigned int*));
    if(mem != NULL) memset(mem, 0, NUM_ELEMENTS);

    uint64_t num_iterations = 300;

    //printf("[into] linked list element size is %lu bytes\n", sizeof(element));
    printf("[into] entering into the main loop with %lld iterations\n", num_iterations);

    set_timer_start(0);
    while (num_iterations--)
    {
        uint64_t remains  = NUM_ELEMENTS;
        uint64_t pre_index = 1; 
        while(remains--)
        {
            uint64_t next_index = (pre_index * 16807) % 2147483647;
    	    ptr[pre_index] = &(ptr[next_index]);
            pre_index = next_index;
        }
    }
    set_timer_end(0);
    print_timer(0, "test");

    free(mem);

    return 0;
}

