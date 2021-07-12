#include <iostream>
#include <cstdio>
#include <cstdlib>
#include <iomanip>
#include "veronica.h"
#include "stream_kernel.h"

using namespace std;

// will start the stream with START_SIZE all the way upto MEM_SIZE
#define REPEAT              200
#define LOOP_UNROLL         32 // TODO: need to change the stream kernel if this number is changed
#define START_SIZE          2048
#define MEM_SIZE            (uint64)(512 * 1024 * 1024)

int main()
{
    uint64 cache_line_size = veronica::get_cache_line_size();
    uint64 num_line = MEM_SIZE / cache_line_size;
    
    // make sure mem addr is aligned
    byte* start_addr = (byte*)veronica::aligned_calloc(MEM_SIZE, veronica::get_page_size());
    if(start_addr == NULL)
    {
        printf("[Error] unable to allocate memory\n");
        exit(-1);
    }

    // enable THP
    /*if (madvise(start_addr, size, MADV_HUGEPAGE) == -1)
    {
        perror("[error] madvise error for hugepage");
        return 1;
    }*/

    uint64 current_size = START_SIZE;
    while(current_size <= MEM_SIZE)
    {
        uint64 loops_remained             = REPEAT * MEM_SIZE / current_size;
        const uint64 stride_per_iteration = LOOP_UNROLL * cache_line_size;
        const uint64 num_line             = current_size / cache_line_size;

        printf("[Result] testing bandwidth for size %llu KB ... ", current_size / 1024);

        veronica::set_timer_start(0);
        while (loops_remained--)
        {
            for (uint64 i = 0; i + stride_per_iteration <= current_size; i+= stride_per_iteration)
            {
                stream_load(start_addr + i);
            }
        }
        veronica::set_timer_end(0);

        loops_remained = REPEAT * MEM_SIZE / current_size;
        veronica::set_timer_start(1);
        while (loops_remained--)
        {
            for (uint64 i = 0; i + stride_per_iteration <= current_size; i+= stride_per_iteration)
            {
                stream_store(start_addr + i);
            }
        }
        veronica::set_timer_end(1);
        
        double amount_of_data = REPEAT * MEM_SIZE / 1024 / 1024 / 1024;
        
        double load_time = veronica::get_elapsed_time_in_us(0);
        double load_bandwidth = amount_of_data / load_time * 1000000; // GigaByte/s

        double store_time = veronica::get_elapsed_time_in_us(1);
        double store_bandwidth = amount_of_data / store_time * 1000000; // GigaByte/s

        printf("load bandwidth is %.2f GB/s, store bandwidth is %.2f GB/s\n", load_bandwidth, store_bandwidth);
        fflush(stdout);

        current_size *= 2;
    }

    free(start_addr);
    return 0;
}