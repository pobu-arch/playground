// Interrupt service routine
// Ioannis Karageorgos

void _ISR (unsigned int irq){
    if (irq == 0){
        __asm("nop");
    }
    else {
        __asm("nop");
        __asm("nop");
    }
}

