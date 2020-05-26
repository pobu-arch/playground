#include <stdio.h>
#include <stdint.h>

uint64_t rdtsc(){
    unsigned int lo,hi;
    __asm__ __volatile__ ("rdtsc" : "=a" (lo), "=d" (hi));
    return ((uint64_t)hi << 32) | lo;
}

extern "C" int foo(int a);

int foo(int a)
{
	return a;
}


int main(void)
{
	int count = 10000000;

	uint64_t start = rdtsc();
	for (int i = 0; i < count; ++i) {
		asm ("mov $4096, %%rax\n\t"
		     "int $0x80":::"rax");
	}
	uint64_t end = rdtsc();
	uint64_t cycles = end - start;

	printf("Executed %d irqs in %llu cycles (%lf cycles/request)\n",
	       count, cycles, (double)cycles / (double)count);

	start = rdtsc();
	for (int i = 0; i < count; ++i) {
		asm ("mov $4096, %%rax\n\t"
		     "syscall":::"rax");
	}
	end = rdtsc();
	cycles = end - start;

	printf("Executed %d syscalls in %llu cycles (%lf cycles/request)\n",
	       count, cycles, (double)cycles / (double)count);

	start = rdtsc();
	for (int i = 0; i < count; ++i) {
		asm ("mov $4096, %%rax\n\t"
		     "call foo":::"rax");
	}
	end = rdtsc();
	cycles = end - start;

	printf("Executed %d calls in %llu cycles (%lf cycles/request)\n",
	       count, cycles, (double)cycles / (double)count);
	return 0;
}
