#!/bin/bash

#SBATCH --partition=cpsc424
#SBATCH --cpus-per-task=20
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --time=4:00:00
#SBATCH --mem-per-cpu=6100
#SBATCH --job-name=Mandelbrot1-2
#SBATCH --output=%x-%j.out

# This script loads module files, builds programs, and then runs the programs for Assignment 2.
#    (Note it is only set up for the first several tasks, but you can modify it or enlarge it 
#     to encompass the other tasks, as well.)

# The script uses the Makefile in /home/cpsc424_ahs3/assignments/assignment2/Makefile. 

# To run the script, submit it to Slurm using: sbatch slurmrun.sh. Note that it requests a full node (20 cores).
# During program development, you may want a simplified version of the script (such as commenting out 
# or removing unnecessary lines. (You could also use an interactive (srun) session during development.

# The script will produce an output file named something like "Mandelbrot1-2-49530642.out"
#    where 49530642 is the Slurm job number.

# Load Required Modules

module load intel


# Task 1

make clean
make mandseq

echo ""
echo ""
echo "Serial version"

time ./mandseq
time ./mandseq
time ./mandseq

# Task 2 - Part 1

echo ""
echo ""
echo "OpenMP version with original drand.c"
echo ""

make clean
make mandomp

export OMP_NUM_THREADS=2
export OMP_SCHEDULE="dynamic,250"
echo "Number of threads = " $OMP_NUM_THREADS
echo "OMP_SCHEDULE = " $OMP_SCHEDULE
time ./mandomp
time ./mandomp
time ./mandomp

# Task 2 - Part 2

make clean
make mandomp-ts

echo ""
echo ""
echo "OpenMP version with threadsafe drand-ts.c"
echo ""
export OMP_NUM_THREADS=2
export OMP_SCHEDULE="dynamic,250"
echo "Number of threads = " $OMP_NUM_THREADS
echo "OMP_SCHEDULE = " $OMP_SCHEDULE
time ./mandomp-ts
time ./mandomp-ts
time ./mandomp-ts

echo ""
echo ""
echo "Performance runs for thread-safe OpenMP with loops"
echo ""
export OMP_NUM_THREADS=1
export OMP_SCHEDULE="dynamic,250"
echo "Number of threads = " $OMP_NUM_THREADS
echo "OMP_SCHEDULE = " $OMP_SCHEDULE
time ./mandomp-ts
time ./mandomp-ts
time ./mandomp-ts
echo ""

export OMP_NUM_THREADS=2
export OMP_SCHEDULE="dynamic,250"
echo "Number of threads = " $OMP_NUM_THREADS
echo "OMP_SCHEDULE = " $OMP_SCHEDULE
time ./mandomp-ts
time ./mandomp-ts
time ./mandomp-ts
echo ""

export OMP_NUM_THREADS=4
export OMP_SCHEDULE="dynamic,250"
echo "Number of threads = " $OMP_NUM_THREADS
echo "OMP_SCHEDULE = " $OMP_SCHEDULE
time ./mandomp-ts
time ./mandomp-ts
time ./mandomp-ts
echo ""

export OMP_NUM_THREADS=10
export OMP_SCHEDULE="dynamic,250"
echo "Number of threads = " $OMP_NUM_THREADS
echo "OMP_SCHEDULE = " $OMP_SCHEDULE
time ./mandomp-ts
time ./mandomp-ts
time ./mandomp-ts

export OMP_NUM_THREADS=20
export OMP_SCHEDULE="dynamic,250"
echo "Number of threads = " $OMP_NUM_THREADS
echo "OMP_SCHEDULE = " $OMP_SCHEDULE
time ./mandomp-ts
time ./mandomp-ts
time ./mandomp-ts

