#include <iostream>
#include <errno.h>
#include <sys/mman.h>

namespace veronica
{
    const uint64_t CACHE_BLOCK_SIZE = 64;
    const uint64_t PAGE_SIZE        = 4096;

    void* page_aligned_malloc(uint64_t size)
    {
        // make sure mem addr is aligned
        void* start_addr = NULL;
        uint64_t alignment = PAGE_SIZE;
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
            exit(1);
        }

        printf("[info] posix_memalign ok, start_addr = %p\n", start_addr);
        return start_addr;
    }
}