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
#define REPEAT              500
#define LOOP_UNROLL         32
#define START_SIZE          8192 * 16
#define MEM_SIZE            (uint64)(256 * 1024 * 1024)

void init(node** nodes, node* memory, uint64 num_node)
{
    printf("[Info] initializing the nodes array ...\n");
    for (uint64 i = 0; i < num_node; i++)
    {
        nodes[i] = &memory[i];
    }

    printf("[Info] shuffling the nodes array ...\n");
    int repeat = REPEAT / 10;
    while(repeat--)
    {
        for (uint64 i = 0; i < num_node - 1; i++)
        {
            uint64 swap = i + rand() % (num_node - i);
            node* tmp = nodes[swap];
            nodes[swap] = nodes[i];
            nodes[i] = tmp;
        }
    }

    printf("[Info] connecting the nodes array ...\n");
	for (uint64 i = 0; i < num_node - 1; i++)
    {
		nodes[i]->next_ptr = nodes[i+1];
	}
	nodes[num_node - 1]->next_ptr = NULL;
}

inline void pointer_chasing(node* p)
{
    int i = LOOP_UNROLL;
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

    // make sure mem addr is aligned
    node** nodes = (node**)veronica::aligned_calloc(total_num_node * sizeof(node*), page_size);
    node* memory = (node*)veronica::aligned_calloc(total_num_node * sizeof(node), page_size);
	if(memory != NULL and nodes != NULL)
    {
        init(nodes, memory, total_num_node);
    }
    else
    {
        printf("[Error] unable to allocate memory\n");
        exit(-1);
    }

    printf("[Info] there are %llu nodes, with %lu bytes per node\n", total_num_node, sizeof(node));

    uint64 current_size = START_SIZE;
    while(current_size <= MEM_SIZE)
    {
        uint64 loops_remained             = REPEAT * MEM_SIZE / current_size;
        const uint64 stride_per_iteration = LOOP_UNROLL * sizeof(node);
        const uint64 current_num_node  = current_size / sizeof(node);

        printf("[Debug] loops = %lld, num_nodes = %lld\n", loops_remained, current_num_node);
        printf("[Result] testing latency for size %llu KB... ", current_size / 1024);

        veronica::set_timer_start(0);
        // stream read
        while (loops_remained--)
        {
            node* node = nodes[0];
            for (uint64 i = 0; i + LOOP_UNROLL < current_num_node; i+= LOOP_UNROLL)
            {
                pointer_chasing(node);
            }
        }
        veronica::set_timer_end(0);

        double amount_of_loads = (REPEAT * MEM_SIZE / current_size) * (current_num_node - 1);

        double load_time = veronica::get_elapsed_time_in_us(0);
        double load_latency =  (load_time * 1000) / amount_of_loads; // nano secs

        printf("total time is %.2lf us, num of loads is %.0lf, average load latency is %.2lf ns\n", load_time, amount_of_loads, load_latency);
        fflush(stdout);

        current_size *= 2;
    }

    free(nodes);
    free(memory);
    return 0;
}