#include "IO.h"

#ifdef __riscv
static uint32_t * const input0_ptr = (uint32_t *)(INPUT0_ADDR);
static uint32_t * const output0_ptr = (uint32_t *)(OUTPUT0_ADDR);

int input(uint8_t port_num, uint32_t * read_value){
    if (port_num < NUM_INPUT_PORTS){
        *read_value = input0_ptr[port_num];
        return 0;
    }
    else {
        return 1;
    }    
}

int output(uint8_t port_num, uint32_t write_value){
    if (port_num < NUM_OUTPUT_PORTS){
        output0_ptr[port_num] = write_value;
        return 0;
    }
    else {
        return 1;
    }    
}
#else
#include <stdio.h>
int output(uint8_t port_num, uint32_t write_value){
	printf("GPOUT%d: %02x\n", port_num, write_value);
	return 0;
}
#endif
