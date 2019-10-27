#include <cstdio>
#include <cstdlib>
#include "veronica.h"
using namespace std;

#define NUM_ELEMENTS (uint64_t) 2147483647
typedef uint32_t element;

element* ptr[NUM_ELEMENTS];

int main()
{
    // make sure mem addr is aligned
    element** mem = (element**)veronica::page_aligned_malloc(NUM_ELEMENTS * sizeof(element*));
    if(mem != NULL) memset(mem, 0, NUM_ELEMENTS);

    uint64_t num_iterations = 10;

    printf("[into] linked list element size is %lu bytes\n", sizeof(element));
    printf("[info] initializing linked list with %lld elements\n", NUM_ELEMENTS);

    uint64_t remains  = NUM_ELEMENTS;
    uint64_t pre_index = 1;
    while(remains--)
    {
        uint64_t next_index = veronica::int_hash(pre_index);
        ptr[pre_index] = ptr[next_index];
        pre_index = next_index;
    }

    printf("[info] iterating linked list with %lld elements\n", NUM_ELEMENTS);
    uint64_t current_index = 1;
    element* temp_ptr = ptr[current_index];
    veronica::set_timer_start(0);
    while (num_iterations--)
    {
        remains  = NUM_ELEMENTS;
        while(remains--)
        {
            printf("%p %p\n", temp_ptr, (element*)*temp_ptr);
            temp_ptr = (element*) *temp_ptr;
        }
    }
    veronica::set_timer_end(0);
    veronica::print_timer(0, "test");

    free(mem);

    return 0;
}

