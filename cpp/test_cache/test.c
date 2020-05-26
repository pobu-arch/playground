#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>
#include <unistd.h>
#include <math.h>
#include <string.h>

typedef unsigned char BYTE;
typedef unsigned long long int uint64;

//all the defined numbers are given in Bytes
#define CACHE_BLOCK_SIZE                                         64
#define TEST_CACHE_SIZE_LO                                (8 * 1024)
#define TEST_CACHE_SIZE_HI                                (128 * 1024)
#define TEST_BUFFER_SIZE                   ((uint64)4096 * 1024 * 1024)
#define LOOP_FACTOR                                          10000

uint64* access_location_pre_computing(const uint64 test_size)
{
        uint64 locaion_array_size = test_size/CACHE_BLOCK_SIZE;
        srand(time(NULL));

        //printf("[info] starting malloc location array, size = %llu KB ...", locaion_array_size * sizeof(uint64) / 1024);
        uint64* location_array = (uint64*)calloc(locaion_array_size, sizeof(uint64));
        if(location_array == NULL)
        {
                printf("[error] no enough memory for loction array\n");
                exit(-1);
        }
        
        uint64 offset = ceil((log(CACHE_BLOCK_SIZE)/log(2)));
        //printf("[info] offset = 0x%x\n",offset);

        for(uint64 location_counter = 0; location_counter < locaion_array_size; location_counter++)
        {
                location_array[location_counter] = (0x1<<offset) * location_counter;
        }

	//randomize
        for(uint64 index = 0; index < locaion_array_size; index ++)
        {  
		uint64 value = rand() % locaion_array_size;  
  
		uint64 median = location_array[index];
        	location_array[index] = location_array[value];
        	location_array[value] = median;
	}

        //printf("  location array pre-computing completed\n");
        return location_array;
}

void main_logic(BYTE* test_buffer)
{
        BYTE res;

        struct timeval start;
        struct timeval end;
        struct timezone tz;
            
        unsigned int current_test_size = TEST_CACHE_SIZE_LO;

        while(current_test_size <= TEST_CACHE_SIZE_HI)
        {
        	uint64* location_array = access_location_pre_computing(current_test_size);
                printf("[info] starting cache size test at %6d KB, ", current_test_size/1024);

                gettimeofday(&start, &tz);

                int test_loop = LOOP_FACTOR;
                while(test_loop--)
                {
                        for(int access_counter = 0; access_counter < current_test_size/CACHE_BLOCK_SIZE; access_counter += 1)
                        {
                        	//printf("[info] accessing %p\n",test_buffer+location_array[access_counter]);
                                volatile res = test_buffer[location_array[access_counter]];
                        }
                }

                gettimeofday(&end, &tz);
                double time = (end.tv_sec - start.tv_sec + ((double)end.tv_usec - start.tv_usec) / 1000000);
                printf("%d iteration of access loop consumes %10lf second\n",LOOP_FACTOR, time);
		
		free(location_array);
		memset(test_buffer,0,TEST_BUFFER_SIZE);
                current_test_size *=2;
        }

        free(test_buffer);
}

int main()
{
	printf("[info] starting malloc test buffer, size = %llu KB ...\n", TEST_BUFFER_SIZE/1024);
	BYTE* test_buffer = (BYTE*)calloc(TEST_BUFFER_SIZE, sizeof(BYTE));
	if(test_buffer == NULL)
	{
        	printf("[error] no enough memory for test buffer\n");
        	exit(-1);
	}

	main_logic(test_buffer);
	return 0;
}
