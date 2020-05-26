# This Makefile assumes the following module files are loaded:
#
# GCC
# CUDA
#
# This Makefile will only work if executed on a GPU node.
#

NVCC = nvcc

NVCCFLAGS = -O3

LFLAGS = -lm

# Compiler-specific flags (by default, we always use sm_37)
GENCODE_SM37 = -gencode=arch=compute_37,code=\"sm_37,compute_37\"
GENCODE = $(GENCODE_SM37)

.SUFFIXES : .cu .ptx

BINARIES = matmul

matmul: matmul.o
	$(NVCC) $(GENCODE) $(LFLAGS) -o $@ $<

.cu.o:
	$(NVCC) $(GENCODE) $(NVCCFLAGS) -o $@ -c $<

clean:	
	rm -f *.o $(BINARIES)
