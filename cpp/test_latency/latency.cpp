#include <iostream>
#include <cstdio>
#include <cstdlib>
#include <iomanip>
#include "veronica.h"

using namespace std;

// assume 64 bytes of line size
struct node
{
    node* next_ptr;
    uint64 padding0[7];
};

// will start the stream with START_SIZE all the way upto MEM_SIZE
#define REPEAT              200
#define START_SIZE          (uint64)(8 * 1024)
#define MEM_SIZE            (uint64)(512 * 1024 * 1024)

void init(node** nodes, node* memory, uint64 num_node, uint64 shuffle_factor)
{
    printf("[Info] initializing the nodes array ...\n");
    for (uint64 i = 0; i < num_node; i++)
    {
        nodes[i] = &memory[i];
    }

    printf("[Info] shuffling the nodes array with factor %lld ...\n", shuffle_factor);
    for (uint64 i = 0; i + shuffle_factor <= num_node; i += shuffle_factor)
    {
        int64 repeat = REPEAT / 10;
        do
        {
            for(uint64 j = i; j < i + shuffle_factor; j++)
            {
                uint64 swap = i + (rand() % shuffle_factor);
                //printf("[Debug]init shuffling iter %lld swaping nodes[%lld] with nodes[%lld], stride is %lld\n", repeat, j, swap, swap - j);
                node* tmp = nodes[swap];
                nodes[swap] = nodes[j];
                nodes[j] = tmp;
            }
        }while(--repeat > 0);
    }

    printf("[Info] connecting the nodes array ...\n");
	for (uint64 i = 0; i < num_node - 1; i++)
    {
		nodes[i]->next_ptr = nodes[i+1];
	}
	nodes[num_node - 1]->next_ptr = NULL;
}

inline void pointer_chasing(node* p, uint64 shuffle_factor)
{
    uint64 i = shuffle_factor;
    node* start_ptr = p;
    while(i--)
    {
        p = p->next_ptr;
    }

    // useless
    if(p == NULL) printf("\n");
}

int main()
{
    srand(time(NULL));
    uint64 total_num_node = MEM_SIZE / sizeof(node);
    uint64 page_size = veronica::get_page_size();

    printf("[Info] there are %llu nodes, with %lu bytes per node\n", total_num_node, sizeof(node));
    
    // make sure that one round of pointer chasing will not trigger more than 1 TLB miss
    uint64 shuffle_factor = page_size / sizeof(node);

    // make sure mem addr is aligned
    node** nodes = (node**)veronica::aligned_calloc(total_num_node * sizeof(node*), page_size);
    node* memory = (node*)veronica::aligned_calloc(total_num_node * sizeof(node), page_size);
	if(memory != NULL and nodes != NULL)
    {
        veronica::set_timer_start(1);
        init(nodes, memory, total_num_node, shuffle_factor);
        veronica::set_timer_end(1);

        double load_time = veronica::get_elapsed_time_in_us(1);
        printf("[Info] init took %.3lf secs\n", load_time / 1000 / 1000);
    }
    else
    {
        printf("[Error] unable to allocate memory\n");
        exit(-1);
    }

    uint64 current_size = START_SIZE;
    while(current_size <= MEM_SIZE)
    {
        uint64 loops_remained             = REPEAT * MEM_SIZE / current_size;
        const uint64 current_num_node     = current_size / sizeof(node);

        printf("[Debug] loops = %llu, num_nodes = %llu\n", loops_remained, current_num_node);
        printf("[Result] testing latency for size %llu KB... ", current_size / 1024);

        veronica::set_timer_start(0);
        // stream read
        while (loops_remained--)
        {
            
            for (uint64 i = 0; i + shuffle_factor <= current_num_node; i+= shuffle_factor)
            {
                //printf("[Debug] loops = %lld, i = %lld, current_num_nodes = %lld\n", loops_remained, i, current_num_node);
                pointer_chasing(nodes[i], shuffle_factor);
            }
        }
        veronica::set_timer_end(0);

        double amount_of_loads = (REPEAT * MEM_SIZE / current_size) * (current_num_node);
        double load_time = veronica::get_elapsed_time_in_us(0);
        double load_latency = (load_time * 1000) / amount_of_loads; // nano secs

        printf("pointer chasing total time is %.3lf secs, num of loads is %.3lf GInsts, average load latency is %.3lf ns\n", load_time / 1000 / 1000, amount_of_loads / 1000 / 1000 / 1000, load_latency);
        fflush(stdout);

        current_size *= 1.6;
        //exit(0);
    }

    free(nodes);
    free(memory);
    return 0;
}