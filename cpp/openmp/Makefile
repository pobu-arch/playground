# This makes both a sequential and parallel program to display the Mandelbrot Set
# Use module load intel

CC = icc

CFLAGS_OMP = -g -O3 -xHost -fno-alias -std=c99 -qopenmp #-fp-model precise
CFLAGS_SERIAL = -g -O3 -xHost -fno-alias -std=c99 #-fp-model precise

EXECUTABLES = mandseq mandomp

TIMING = timing.o 

all: $(EXECUTABLES)

mandseq: mandseq.o drand.o $(TIMING)  
	$(CC) $(CFLAGS_SERIAL) -o $@ $^ -lm

mandomp: mandomp.o drand.o $(TIMING)
	$(CC) $(CFLAGS_OMP) -o $@ $^ -lm

mandomp-ts: mandomp.o drand-ts.o $(TIMING)
	$(CC) $(CFLAGS_OMP) -o $@ $^ -lm

mandomp-tasks: mandomp-tasks.o drand-ts.o $(TIMING)
	$(CC) $(CFLAGS_OMP) -o $@ $^ -lm

mandseq.o: mandseq.c drand.o timing.o
	$(CC) $(CFLAGS_SERIAL) -c -o $@ $^

.c.o:
	$(CC) $(CFLAGS_OMP) -c $<

clean:
	rm -f $(EXECUTABLES) *.o
