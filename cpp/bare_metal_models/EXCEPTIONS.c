// Exceptions routine
// Ioannis Karageorgos

#include "IO.h"

void _EXC (unsigned int id){
    if ( id == 16 ){
        output(OUTPORT7, 100);          // success!
    }
    else if ( id == 2 ){
        output(OUTPORT7, 101);          // illegal instruction
    }
    else{
        output(OUTPORT7, 102);          // other exception
    }
}

