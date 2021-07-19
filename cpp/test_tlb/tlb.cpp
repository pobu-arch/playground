#include <iostream>
#include <cstdio>
#include <cstdlib>
#include "veronica.h"

using namespace std;

#define MEM_SIZE (veronica::uint64)(1024 * 1024 * 1024)

int main()
{
    srand(time(NULL));
    
    // make sure mem addr is aligned
    veronica::byte* start_addr = (veronica::byte*)veronica::aligned_malloc(MEM_SIZE);
    if(start_addr != NULL)
    {
	memset(start_addr, 0, MEM_SIZE);
	printf("[info] allocation and memset done\n");
    }
    else
    {
	printf("[error] error during malloc\n");
    }

    // enable THP
    /*if (madvise(start_addr, size, MADV_HUGEPAGE) == -1)
    {
        perror("[error] madvise error for hugepage");
        return 1;
    }*/
    
    veronica::uint64 page_size = veronica::get_page_size();
    printf("[info] page size is %llu bytes \n", page_size);
    
    veronica::uint64 stride         = 1 * page_size;
    //veronica::uint64 num_entries    = MEM_SIZE / stride;
    veronica::uint64 num_entries    = 30;
    veronica::uint64 num_iterations = 20000000000;
    printf("[info] running loop with %llu iterations, and %llu entries per iteration, stride is %lld\n", num_iterations, num_entries, stride);
    printf("[info] end_addr is %p \n", start_addr + num_entries * stride);

    veronica::set_timer_start(0);

    veronica::uint64 temp = 0;

    while (num_iterations--)
    {
	    //printf("[info] this is iteration %lld\n", num_iterations);
        for (veronica::uint64 i = 0; i < num_entries; i += 1)
        {
	        //printf("[info] about to access %p\n", start_addr + i * stride) ;
    	    temp += *(start_addr + i * stride);

	        //veronica::flush_cache_line_x86((start_addr + i * stride));
        }
    }

    veronica::set_timer_end(0);
    veronica::print_timer(0, "tlb test");
    
    printf("useless result = %llu\n", temp);
    free(start_addr);

    return 0;
}
