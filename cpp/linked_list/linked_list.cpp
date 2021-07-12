#include <cstdio>
#include <cstdlib>
#include "veronica.h"
using namespace std;

typedef veronica::uint64 element;
const   veronica::uint64 NUM_ELEMENTS = 2147483647;

int main()
{
    // make sure mem addr is aligned
    element* element_ptr  = (element*)veronica::aligned_malloc(NUM_ELEMENTS * sizeof(element*));
    if(element_ptr != NULL)
    {
        memset(element_ptr, 0, NUM_ELEMENTS * sizeof(element*));
    }
    else
    {
        printf("[Error] no enough memory\n");
        exit(-1);
    }

    veronica::uint64 num_iterations = 10;

    printf("[Info] linked list element size is %lu bytes\n", sizeof(element));
    printf("[Info] initializing linked list with %llu elements\n", NUM_ELEMENTS);

    veronica::uint64 remains  = NUM_ELEMENTS;
    veronica::uint64 pre_index = 1;
    while(remains--)
    {
        veronica::uint64 next_index = veronica::hash_within_int(pre_index);
        element_ptr[pre_index] = element_ptr[next_index];
        pre_index = next_index;
    }

    printf("[Info] iterating linked list with %llu elements\n", NUM_ELEMENTS);
    element* temp_element_ptr = &element_ptr[0];
    
    veronica::set_timer_start(0);
    while (num_iterations--)
    {
        remains  = NUM_ELEMENTS;
        while(remains--)
        {
            printf("%p %p\n", temp_element_ptr, (element*)*temp_element_ptr);
            temp_element_ptr = (element*) *temp_element_ptr;
        }
    }
    veronica::set_timer_end(0);
    veronica::print_timer(0, "test");

    free(element_ptr);

    return 0;
}

