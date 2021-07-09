#include <iostream>
#include <cstdio>
#include <cstdlib>
#include <iomanip>
#include "veronica.h"

using namespace std;

// will start the stream with START_SIZE all the way upto MEM_SIZE
#define LOOP_ITERATION      200
#define LOOP_UNROLL         16
#define START_SIZE          4096
#define MEM_SIZE            (uint64)(256 * 1024 * 1024)
#define CACHE_BLOCK_SIZE    (veronica::CACHE_BLOCK_SIZE)

void init(byte* start_addr, uint64 num_block)
{
    for (int i = 0; i < num_block; i+= 1)
    {
        start_addr[i * CACHE_BLOCK_SIZE] = 0xff;
    }
}

void use_result(byte* result_ptr)
{
    if(*result_ptr != 0) cout << endl;
}

inline void stream_load(void* start_addr)
{
#ifdef X86_64
    
    #ifdef SSE2
        asm volatile("movdqa 0(%0), %%xmm0\n\t"
                    "movdqa 64(%0), %%xmm1\n\t"
                    "movdqa 128(%0), %%xmm2\n\t"
                    "movdqa 192(%0), %%xmm3\n\t"
                    "movdqa 256(%0), %%xmm4\n\t"
                    "movdqa 320(%0), %%xmm5\n\t"
                    "movdqa 384(%0), %%xmm6\n\t"
                    "movdqa 448(%0), %%xmm7\n\t"
                    "movdqa 512(%0), %%xmm0\n\t"
                    "movdqa 576(%0), %%xmm1\n\t"
                    "movdqa 640(%0), %%xmm2\n\t"
                    "movdqa 704(%0), %%xmm3\n\t"
                    "movdqa 768(%0), %%xmm4\n\t"
                    "movdqa 832(%0), %%xmm5\n\t"
                    "movdqa 896(%0), %%xmm6\n\t"
                    "movdqa 960(%0), %%xmm7\n\t"
                    :
                    : "r"(start_addr)
                    );
    #endif

    #ifdef AVX2
        asm volatile("vmovapd 0(%0), %%xmm0\n\t"
                    "vmovapd 64(%0), %%xmm1\n\t"
                    "vmovapd 128(%0), %%xmm2\n\t"
                    "vmovapd 192(%0), %%xmm3\n\t"
                    "vmovapd 256(%0), %%xmm4\n\t"
                    "vmovapd 320(%0), %%xmm5\n\t"
                    "vmovapd 384(%0), %%xmm6\n\t"
                    "vmovapd 448(%0), %%xmm7\n\t"
                    "vmovapd 512(%0), %%xmm0\n\t"
                    "vmovapd 576(%0), %%xmm1\n\t"
                    "vmovapd 640(%0), %%xmm2\n\t"
                    "vmovapd 704(%0), %%xmm3\n\t"
                    "vmovapd 768(%0), %%xmm4\n\t"
                    "vmovapd 832(%0), %%xmm5\n\t"
                    "vmovapd 896(%0), %%xmm6\n\t"
                    "vmovapd 960(%0), %%xmm7\n\t"
                    :
                    : "r"(start_addr));
    #endif

    #ifdef AVX512
        asm volatile("vmovdqa64 0(%0), %%xmm0\n\t"
                    "vmovdqa64 64(%0), %%xmm1\n\t"
                    "vmovdqa64 128(%0), %%xmm2\n\t"
                    "vmovdqa64 192(%0), %%xmm3\n\t"
                    "vmovdqa64 256(%0), %%xmm4\n\t"
                    "vmovdqa64 320(%0), %%xmm5\n\t"
                    "vmovdqa64 384(%0), %%xmm6\n\t"
                    "vmovdqa64 448(%0), %%xmm7\n\t"
                    "vmovdqa64 512(%0), %%xmm0\n\t"
                    "vmovdqa64 576(%0), %%xmm1\n\t"
                    "vmovdqa64 640(%0), %%xmm2\n\t"
                    "vmovdqa64 704(%0), %%xmm3\n\t"
                    "vmovdqa64 768(%0), %%xmm4\n\t"
                    "vmovdqa64 832(%0), %%xmm5\n\t"
                    "vmovdqa64 896(%0), %%xmm6\n\t"
                    "vmovdqa64 960(%0), %%xmm7\n\t"
                    :
                    : "r"(start_addr)
                    );
    #endif
#endif

#ifdef RISCV64
        asm volatile("ld t1, 0(%0)\n\t"
                    "ld t1, 64(%0)\n\t"
                    "ld t1, 128(%0)\n\t"
                    "ld t1, 192(%0)\n\t"
                    "ld t1, 256(%0)\n\t"
                    "ld t1, 320(%0)\n\t"
                    "ld t1, 384(%0)\n\t"
                    "ld t1, 448(%0)\n\t"
                    "ld t1, 512(%0)\n\t"
                    "ld t1, 576(%0)\n\t"
                    "ld t1, 640(%0)\n\t"
                    "ld t1, 704(%0)\n\t"
                    "ld t1, 768(%0)\n\t"
                    "ld t1, 832(%0)\n\t"
                    "ld t1, 896(%0)\n\t"
                    "ld t1, 960(%0)\n\t"
                    :
                    : "r"(start_addr)
                    );
#endif

}

void print_stream_info()
{
    #ifdef SSE2
        cout <<"[Info] Using SSE2 stream load instructions" << endl;
    #endif
    
    #ifdef AVX2
        cout <<"[Info] Using AVX2 stream load instructions" << endl;
    #endif
}

int main()
{
    srand(time(NULL));
    uint64 num_block = MEM_SIZE / CACHE_BLOCK_SIZE;
    // make sure mem addr is aligned
    byte* start_addr = (byte*)veronica::aligned_calloc(MEM_SIZE, CACHE_BLOCK_SIZE);
    if(start_addr != NULL)
    {
        //init(start_addr, num_block);
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

    print_stream_info();
    
    uint64 current_size = START_SIZE;
    while(current_size <= MEM_SIZE)
    {
        uint64 loops_remained = LOOP_ITERATION * MEM_SIZE / current_size;
               num_block      = current_size / CACHE_BLOCK_SIZE;
        
        cout << "[Result] Bandwidth for size " << current_size / 1024 << " KB is ... ";
        
        veronica::set_timer_start(0);
        // stream read
        while (loops_remained--)
        {
            for (uint64 i = 0; i + LOOP_UNROLL * CACHE_BLOCK_SIZE <= current_size; i+= LOOP_UNROLL * CACHE_BLOCK_SIZE)
            {               
                stream_load(start_addr + i);
            }
        }
        veronica::set_timer_end(0);
        double time = veronica::get_elapsed_time_in_us(0);
        double amount_of_data = LOOP_ITERATION * MEM_SIZE / 1024 / 1024 / 1024;
        double bandwidth = amount_of_data / time * 1000000; // GigaByte/s
        cout <<  bandwidth << " GB/s" << endl;
        //cout << "[Debug] amount_of_data is " << amount_of_data << "GB, with time is ";
        //cout << fixed << setprecision(2) << time << " us" << endl;

        current_size *= 2;
    }

    free(start_addr);
    return 0;
}