#include <iostream>
#include <cstdio>
#include <cstdlib>
#include <iomanip>
#include "veronica.h"

using namespace std;

struct element
{
    element* next_ptr;
    uint64 padding0[7];
};

// will start the stream with START_SIZE all the way upto MEM_SIZE
#define LOOP_ITERATION      200
#define LOOP_UNROLL         32  // TODO: need to change pointer chasing kernel if this number is changed
#define START_SIZE          4096
#define MEM_SIZE            (uint64)(256 * 1024 * 1024)

void init(element* start_addr, uint64 num_element)
{
    printf("[Info] initializing array ...\n");
    for (uint64 i = 0; i + LOOP_UNROLL <= num_element; i+= LOOP_UNROLL)
    {
        // TODO: this data layout may still be defeated by an advanced temporal prefetcher
        start_addr[i + 15].next_ptr = &(start_addr[i + 21]);
        start_addr[i + 21].next_ptr = &(start_addr[i + 12]);
        start_addr[i + 12].next_ptr = &(start_addr[i + 18]);
        start_addr[i + 18].next_ptr = &(start_addr[i + 10]);
        start_addr[i + 10].next_ptr = &(start_addr[i + 23]);
        start_addr[i + 23].next_ptr = &(start_addr[i + 16]);
        start_addr[i + 16].next_ptr = &(start_addr[i + 17]);
        start_addr[i + 17].next_ptr = &(start_addr[i + 11]);
        start_addr[i + 11].next_ptr = &(start_addr[i + 3]);
        start_addr[i + 3].next_ptr = &(start_addr[i + 5]);
        start_addr[i + 5].next_ptr = &(start_addr[i + 0]);
        start_addr[i + 0].next_ptr = &(start_addr[i + 26]);
        start_addr[i + 26].next_ptr = &(start_addr[i + 29]);
        start_addr[i + 29].next_ptr = &(start_addr[i + 7]);
        start_addr[i + 7].next_ptr = &(start_addr[i + 14]);
        start_addr[i + 14].next_ptr = &(start_addr[i + 27]);
        start_addr[i + 27].next_ptr = &(start_addr[i + 19]);
        start_addr[i + 19].next_ptr = &(start_addr[i + 30]);
        start_addr[i + 30].next_ptr = &(start_addr[i + 28]);
        start_addr[i + 28].next_ptr = &(start_addr[i + 9]);
        start_addr[i + 9].next_ptr = &(start_addr[i + 8]);
        start_addr[i + 8].next_ptr = &(start_addr[i + 13]);
        start_addr[i + 13].next_ptr = &(start_addr[i + 2]);
        start_addr[i + 2].next_ptr = &(start_addr[i + 22]);
        start_addr[i + 22].next_ptr = &(start_addr[i + 1]);
        start_addr[i + 1].next_ptr = &(start_addr[i + 31]);
        start_addr[i + 31].next_ptr = &(start_addr[i + 25]);
        start_addr[i + 25].next_ptr = &(start_addr[i + 6]);
        start_addr[i + 6].next_ptr = &(start_addr[i + 20]);
        start_addr[i + 20].next_ptr = &(start_addr[i + 4]);
        start_addr[i + 4].next_ptr = &(start_addr[i + 24]);
        start_addr[i + 24].next_ptr = &(start_addr[i + 15]);
    }
}

inline void pointer_chasing(element* start_addr)
{
    element* p = start_addr;
    int i = LOOP_UNROLL;
    //printf("[Info] inner base is %p\n", p);
    while(i--)
    {
        p = p->next_ptr;
        //printf("now p is %p\n", p);
    }

    if(p == NULL) printf("\n");
}

int main()
{
    srand(time(NULL));
    uint64 cache_line_size   = veronica::get_cache_line_size();
    uint64 total_num_element = MEM_SIZE / sizeof(element);

    printf("[Info] there are %llu elements, with %lu bytes per element\n", total_num_element, sizeof(element));
    
    // make sure mem addr is aligned
    element* start_addr = (element*)veronica::aligned_calloc(MEM_SIZE, cache_line_size);
    if(start_addr != NULL)
    {
        init(start_addr, MEM_SIZE / sizeof(element));
    }
    else
    {
        printf("[Error] unable to allocate memory\n");
        exit(-1);
    }
    
    uint64 current_size = START_SIZE;
    while(current_size <= MEM_SIZE)
    {
        uint64 loops_remained             = LOOP_ITERATION * MEM_SIZE / current_size;
        const uint64 stride_per_iteration = LOOP_UNROLL * sizeof(element);
        const uint64 current_num_element  = current_size / sizeof(element);

        printf("[Debug] loops = %lld, num_elements = %lld\n", loops_remained, current_num_element);
        printf("[Result] testing latency for size %llu KB... ", current_size / 1024);

        veronica::set_timer_start(0);
        // stream read
        while (loops_remained--)
        {
            for (uint64 i = 0; i + LOOP_UNROLL < current_num_element; i+= LOOP_UNROLL)
            {
                //printf("[Info] outer base is %p\n", start_addr + i);
                pointer_chasing(start_addr + i);
            }
        }
        veronica::set_timer_end(0);

        double amount_of_loads = (LOOP_ITERATION * MEM_SIZE / current_size) * (current_num_element - 1);

        double load_time = veronica::get_elapsed_time_in_us(0);
        double load_latency =  (load_time * 1000) / amount_of_loads; // nano secs

        printf("total time is %.2lf us, num of loads is %.0lf, average load latency is %.2lf ns\n", load_time, amount_of_loads, load_latency);
        fflush(stdout);

        current_size *= 2;
    }

    free(start_addr);
    return 0;
}