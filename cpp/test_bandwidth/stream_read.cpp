#include <iostream>
#include <cstdio>
#include <cstdlib>
#include "veronica.h"
using namespace std;
// will start the stream with START_SIZE all the way upto MEM_SIZE
#define LOOP_ITERATION  200
#define LOOP_UNROLL     16
#define START_SIZE      4096
#define MEM_SIZE (uint64)(256 * 1024 * 1024)
#define STRIDE   (veronica::CACHE_BLOCK_SIZE)
void init(byte* start_addr, uint64 num_block)
{
    for (int i = 0; i < num_block; i+= STRIDE * 1)
    {
        *((volatile byte*)start_addr + i) = 0xff;
    }
}
void use_result(byte* result_ptr)
{
    if(*result_ptr != 0) cout << endl;
}
int main()
{
    srand(time(NULL));
    uint64 num_block = MEM_SIZE / STRIDE;
    // make sure mem addr is aligned
    byte* start_addr = (byte*)veronica::aligned_malloc(MEM_SIZE);
    if(start_addr != NULL)
    {
        memset(start_addr, 0, MEM_SIZE);
        init(start_addr, num_block);
    }
    else
    {
        cout << "[Error] unable to allocate memory" << endl;
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
        byte parallel_result_1 = 0;
        byte parallel_result_2 = 0;
        byte parallel_result_3 = 0;
        byte parallel_result_4 = 0;
        uint64 loops_remained = LOOP_ITERATION * MEM_SIZE / current_size;
               num_block      = current_size / STRIDE;
        //cout << "[DEBUG] will loop " << loops_remained << " times, with " << num_block << " blocks per iteration" <<endl;
        cout << "[Result] Bandwidth for size " << current_size / 1024 << " KB is ... ";
        
        veronica::set_timer_start(0);
        // stream read
        while (loops_remained--)
        {
            for (uint64 i = 0; i + LOOP_UNROLL * STRIDE <= current_size; i+= LOOP_UNROLL * STRIDE)
            {               
                parallel_result_1 ^= start_addr[i + 0 * STRIDE];
                parallel_result_2 ^= start_addr[i + 1 * STRIDE];
                parallel_result_3 ^= start_addr[i + 2 * STRIDE];
                parallel_result_4 ^= start_addr[i + 3 * STRIDE];
                
                parallel_result_1 ^= start_addr[i + 4 * STRIDE];
                parallel_result_2 ^= start_addr[i + 5 * STRIDE];
                parallel_result_3 ^= start_addr[i + 6 * STRIDE];
                parallel_result_4 ^= start_addr[i + 7 * STRIDE];
                
                parallel_result_1 ^= start_addr[i + 8 * STRIDE];
                parallel_result_2 ^= start_addr[i + 9 * STRIDE];
                parallel_result_3 ^= start_addr[i + 10 * STRIDE];
                parallel_result_4 ^= start_addr[i + 11 * STRIDE];
                
                parallel_result_1 ^= start_addr[i + 12 * STRIDE];
                parallel_result_2 ^= start_addr[i + 13 * STRIDE];
                parallel_result_3 ^= start_addr[i + 14 * STRIDE];
                parallel_result_4 ^= start_addr[i + 15 * STRIDE];
            }
        }
        veronica::set_timer_end(0);
        double time = veronica::get_elapsed_time_in_us(0);
        double amount_of_data = LOOP_ITERATION * MEM_SIZE;
        double bandwidth = amount_of_data / time / 1024 / 1024 / 1024 * 1000000; // GigaByte/s
        cout <<  bandwidth << " GB/s" << endl;
        //cout << "[DEBUG]" << "amount_of_data is " << amount_of_data / 1024 / 1024 << endl;
        //cout << "[DEBUG]" << " time is " << time / 1000000 << " secs" << endl;
        use_result(&parallel_result_1);
        use_result(&parallel_result_2);
        use_result(&parallel_result_3);
        use_result(&parallel_result_4);
        current_size *= 2;
    }
    
    
    free(start_addr);
    return 0;
}