#include <iostream>
#include <stdio.h>
#include <stdlib.h>
#include "veronica.h"

using namespace std;

#define MEM_SIZE (uint64_t)(1024 * 1024 * 1024)

int main()
{
    srand(time(NULL));
    
    // make sure mem addr is aligned
    uint64_t* start_addr = (uint64_t*)veronica::page_aligned_malloc(MEM_SIZE);
    if(start_addr != NULL) memset(start_addr, 0, MEM_SIZE);

    // enable THP
    /*if (madvise(start_addr, size, MADV_HUGEPAGE) == -1)
    {
        perror("[error] madvise error for hugepage");
        return 1;
    }*/

    uint64_t num_entries = MEM_SIZE / veronica::CACHE_BLOCK_SIZE;
    uint64_t num_iterations = 30000;
    printf("[into] entering into the main loop with %lld iterations\n", num_iterations);
    
    // streaming
    /*for (int i = 0; i < num_entries; i+= CACHE_BLOCK_SIZE * 1)
    {
    	*((volatile uint64*)start_addr + i) = 0xff;
    }*/

    while (num_iterations--)
    {
        for (uint64_t i = 0; i < num_entries; i+= veronica::CACHE_BLOCK_SIZE)
        {
    	    //volatile uint64_t temp = *((volatile uint64_t*)start_addr + i);
            *((volatile uint64_t*)start_addr + i) = 0;
        }
    }

    free(start_addr);

    return 0;
}

