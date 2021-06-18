#include <iostream>
#include <cstdio>
#include <cstdlib>
#include "veronica.h"

using namespace std;

#define MEM_SIZE (uint64_t)(1024 * 1024 * 1024)

int main()
{
    srand(time(NULL));
    
    // make sure mem addr is aligned
    uint64_t* start_addr = (uint64_t*)veronica::aligned_malloc(MEM_SIZE);
    if(start_addr != NULL) memset(start_addr, 0, MEM_SIZE);

    // enable THP
    /*if (madvise(start_addr, size, MADV_HUGEPAGE) == -1)
    {
        perror("[error] madvise error for hugepage");
        return 1;
    }*/
    
    uint64_t page_size = veronica::get_page_size();
    printf("[into] page size is %lld bytes \n", page_size);
    
    uint64_t num_entries = MEM_SIZE / page_size;
    uint64_t num_iterations = 20000000;
    printf("[into] entering into the main loop with %lld iterations, and %lld entries per iteration\n", num_iterations, num_entries);
    
    veronica::set_timer_start(0);
    // streaming
    /*for (int i = 0; i < num_entries; i+= CACHE_BLOCK_SIZE * 1)
    {
    	*((volatile uint64*)start_addr + i) = 0xff;
    }*/

    while (num_iterations--)
    {
        for (uint64_t i = 0; i < num_entries; i+= page_size)
        {
    	    //volatile uint64_t temp = *((volatile uint64_t*)start_addr + i);
            *((volatile uint64_t*)start_addr + i) = 0;
        }
    }
    veronica::set_timer_end(0);
    veronica::print_timer(0, "tlb test");
    
    free(start_addr);

    return 0;
}

