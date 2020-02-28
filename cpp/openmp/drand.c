#include <stdlib.h>
#include <stdint.h>
#include <stdio.h>
#include <omp.h>

static uint64_t parallel_seed[20];

static uint64_t seed;
#pragma omp threadprivate(seed)
void dsrand(unsigned s)
{
    seed = s-1;
    printf("Seed = %lu. RAND_MAX = %d.\n",seed,RAND_MAX);
}

double drand(void)
{
	seed = 6364136223846793005ULL*seed + 1;
    return((double)(seed>>33)/(double)RAND_MAX);
}


void parallel_dsrand()
{
    dsrand(12345);
    for(int i = 0; i < 20; i++)
    {
        parallel_seed[i] = drand() * 1000000;
        printf("parallel_seed[%d] is %d\n", i, parallel_seed[i]);
    }
}

double parallel_drand()
{
    parallel_seed[omp_get_thread_num() % 20] = parallel_seed[omp_get_thread_num() % 20] * 16807 % 2147483647;
    //printf("thread %d is getting %d\n", omp_get_thread_num(), parallel_seed[omp_get_thread_num() % 20]);
    return parallel_seed[omp_get_thread_num() % 20] % 1000 / 1000;
}