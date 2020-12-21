#include <stdint.h>

#define INPUT0_ADDR 0x60000010
#define OUTPUT0_ADDR 0x60000030

#define NUM_INPUT_PORTS 8
#define NUM_OUTPUT_PORTS 8

#define INPORT0 0
#define INPORT1 1
#define INPORT2 2
#define INPORT3 3
#define INPORT4 4
#define INPORT5 5
#define INPORT6 6
#define INPORT7 7

#define OUTPORT0 0
#define OUTPORT1 1
#define OUTPORT2 2
#define OUTPORT3 3
#define OUTPORT4 4
#define OUTPORT5 5
#define OUTPORT6 6
#define OUTPORT7 7


int input(uint8_t port_num, uint32_t * read_value);
int output(uint8_t port_num, uint32_t write_value);

// see EXCEPTIONS.c
void _EXC (unsigned int id);
