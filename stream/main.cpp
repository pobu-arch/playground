#include <iostream>
#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <sys/mman.h>

typedef unsigned long long int uint64;

#define MEM_SIZE ((uint64)1024 * 1024 * 1024)
#define CACHE_BLOCK_SIZE 64

using namespace std;

int main()
{
    srand(time(NULL));
    
    // make sure mem addr is aligned
    void *start_addr;
    uint64 alignment = 1 * 1024 * 1024 * 1024;
    uint64 size = 1 * 1024 * 1024 * 1024;
    int err = posix_memalign(&start_addr, alignment, size);
    if (err != 0)
    {
        if (err == EINVAL)
        {
            printf("[error] posix_memalign EINVAL\n");
        }
        else if (err == ENOMEM)
        {
            printf("[error] posix_memalign ENOMEM\n");
        }
        return 1;
    }

    printf("[info] posix_memalign ok, start_addr = %p\n", start_addr);

    // enable THP
    if (madvise(start_addr, size, MADV_HUGEPAGE) == -1)
    {
        perror("[error] madvise error for hugepage");
        return 1;
    }

    uint64 num_entries = MEM_SIZE / CACHE_BLOCK_SIZE;
    uint64 num_iterations = 10000;
    printf("[into] entering into the main loop with %lld iterations\n", num_iterations);
    
    // streaming
    while (num_iterations--)
    {
        volatile double *ptr;
        
        for (int i = 0; i < num_entries; i+=CACHE_BLOCK_SIZE)
        {
    	    volatile uint64 *ptr = ((volatile uint64*)start_addr + i);
    	    *ptr;
        }

        // rand
        // volatile double *ptr = (volatile double *)((double *)addr + rand() % num_entries);
        // *ptr;
    }

    free(start_addr);

    return 0;
}

