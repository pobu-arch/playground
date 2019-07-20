#include <iostream>
#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <sys/mman.h>

#define MEM_SIZE (1024 * 1024 * 1024LL)

using namespace std;

int main()
{
    srand(time(NULL));
    void *addr;
    size_t alignment = 1 * 1024 * 1024 * 1024L;
    size_t size = 1 * 1024 * 1024 * 1024L;
    int err = posix_memalign(&addr, alignment, size);
    if (err != 0)
    {
        if (err == EINVAL)
        {
            printf("posix_memalign EINVAL\n");
        }
        else if (err == ENOMEM)
        {
            printf("posix_memalign ENOMEM\n");
        }
        return 1;
    }

    printf("posix_memalign ok, addr = %p\n", addr);

    // if (madvise(addr, size, MADV_HUGEPAGE) == -1) {
    //   perror("madvise");
    //   return 1;
    // }

    printf("madvise ok\n");

    int num_entries = MEM_SIZE / sizeof(double);
    int num_iterations = 1000;
    while (num_iterations--)
    {
        // streaming
        for (int i = 0; i < num_entries; i+=8)
        {
    	    volatile double *ptr = (volatile double *)((double *)addr + i);
    	    *ptr;
        }

        // rand
        // volatile double *ptr = (volatile double *)((double *)addr + rand() % num_entries);
        // *ptr;
    }

    free(addr);

    return 0;
}

