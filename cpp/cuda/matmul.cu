
#include "cuda_runtime.h"
#include "device_launch_parameters.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <time.h>
#include <cuda.h>

#ifdef GPU_PART
    //#define GPU_Task1
    #define GPU_Task2
    //#define GPU_Task34
    
#endif

#define NO_CMD_INPUT
#ifdef NO_CMD_INPUT
    #define M        8192
    #define N        2048
    #define P        2048    
    #define BlockDim 32
    #define GridDim  (N / BlockDim)
    #define TILE_WIDTH 16
#endif

//#define CPU_PART
#define GPU_PART
#define CHECK_PART
//#define PRINT_PART

#define rand_max 32768
#define FP float

void print_matrix(FP* a, int m, int n)
{
    for (int i = 0; i < m; i++)
    {
        for (int j = 0; j < n; j++)
        {
            printf("%f ", a[i * n + j]);
        }
        printf("\n");
    }
    printf("\n");
}

void init_matrix(FP* a, int m, int n)
{
    for (int i = 0; i < m; i++)
    {
        for (int j = 0; j < n; j++)
        {
            a[i * n + j] = (FP)rand() / (FP)rand_max;
            //      a[i * p + j] = (FP) i+j; // may be helpful for debugging
        }
    }
}

__global__ void gpu_kernel_task1(FP* a, FP* b, FP* c, int m, int n, int p)
{
    float sum = 0.0f;

    int row = blockIdx.y * blockDim.y + threadIdx.y;
    int col = blockIdx.x * blockDim.x + threadIdx.x;

    if (row < m && col < p)
    {
        for (int i = 0; i < n; ++i)
        {
            sum += a[row * n + i] * b[i * p + col];
        }
        c[row * p + col] = sum;
    }
}

__global__ void gpu_kernel_task2(FP* a, FP* b, FP* c, int m, int n, int p)
{
    __shared__ float sharedA[TILE_WIDTH][TILE_WIDTH];
    __shared__ float sharedB[TILE_WIDTH][TILE_WIDTH];
    int bx = blockIdx.x;
    int by = blockIdx.y;
    int tx = threadIdx.x;
    int ty = threadIdx.y;
    int row = by * TILE_WIDTH + ty;
    int col = bx * TILE_WIDTH + tx;
    float v = 0.0;

    for (int i = 0; i < (int)(ceil((float)n / TILE_WIDTH)); i++)
    {
        if (i * TILE_WIDTH + tx < n && row < m)
            sharedA[ty][tx] = a[row * n + i * TILE_WIDTH + tx];
        else
            sharedA[ty][tx] = 0.0;

        if (i * TILE_WIDTH + ty < n && col < p)
            sharedB[ty][tx] = b[(i * TILE_WIDTH + ty) * p + col];
        else
            sharedB[ty][tx] = 0.0;
        __syncthreads();

        for (int j = 0; j < TILE_WIDTH; j++)
            v += sharedA[ty][j] * sharedB[j][tx];
        __syncthreads();
    }

    if (row < m && col < p)
        c[row * p + col] = v;
}

void kij_matrixmult(FP* a, FP* b, FP* kij, int m, int n, int p)
{
    for (int k = 0; k < n; k++)
    {
        for (int i = 0; i < m; i++)
        {
            FP r = a[i * n + k];
            for (int j = 0; j < p; j++)
            {
                kij[i * p + j] += r * b[k * p + j];
            }
        }
    }
}

void check_matrix(FP* a, FP* b, FP* gpu, int m, int n, int p)
{
    FP* kij = (FP*)malloc(m * p * sizeof(FP)); // results from CPU
    memset(kij, 0, m * p * sizeof(FP));

    kij_matrixmult(a, b, kij, m, n, p);

    // diff on result matrix
    for (int i = 0; i < m; i++)
    {
        for (int j = 0; j < p; j++)
        {
            gpu[i * p + j] -= kij[i * p + j];
        }
    }

    double error, suma, sumb, sumc;
    suma = 0.; sumb = 0; sumc = 0;
    
    // suma, m * n
    for (int i = 0; i < m; i++)
    {
        for (int j = 0; j < n; j++)
        {
            suma += a[i * n + j] * a[i * n + j];
        }
    }

    // sumb, n * p
    for (int i = 0; i < n; i++)
    {
        for (int j = 0; j < p; j++)
        {
            sumb += b[i * p + j] * b[i * p + j];
        }
    }
    
    // sumc, m * p
    for (int i = 0; i < m; i++)
    {
        for (int j = 0; j < p; j++)
        {
            sumc += gpu[i * p + j] * gpu[i * p + j];
        }
    }

    suma = sqrt(suma);
    sumb = sqrt(sumb);
    sumc = sqrt(sumc);
    error = sumc / (sqrt(m*p) * suma * sumb);
    printf("Scaled error between GPU and CPU: %f\n", error);
}

int main(int argc, char* argv[])
{
    int Grid_Dim = 1; //Grid dimension, x and y, square
    int Block_Dim = 1; //Block dimension, x and y, square
    int m, n, p; // matrix dimension
    FP* a, *b, *gpu;

    cudaEvent_t start, stop; // using cuda events to measure time
    float elapsed_time_ms; // which is applicable for asynchronous code also
    cudaError_t errorcode;

#ifdef NO_CMD_INPUT    
    m = M;
    n = N;
    p = P;
    Block_Dim = BlockDim;
    Grid_Dim = GridDim;
#else
    if (argc != 4)
    {
        printf("Usage: matmul <matrix dim> <block dim> <grid dim>\n");
        exit(-1);
    }
    n = atoi(argv[1]);
    Block_Dim = atoi(argv[2]); // Square block
    Grid_Dim = atoi(argv[3]); // Square grid
#endif

    a = (FP*)malloc(m * n * sizeof(FP)); // dynamically allocated memory for arrays on host
    b = (FP*)malloc(n * p * sizeof(FP));
    gpu = (FP*)malloc(m * p * sizeof(FP)); // results from GPU

    FP* kij = (FP*)malloc(m * p * sizeof(FP)); // results from CPU
    memset(kij, 0, m * p * sizeof(FP));

    srand(12345);
    init_matrix(a, m, n);
    init_matrix(b, n, p);

    cudaEventCreate(&start); // instrument code to measure start time
    cudaEventCreate(&stop);

#ifdef GPU_PART
    int gpucount = 0; // Count of available GPUs
    int gpunum = 0; // Device number to use
    FP* dev_a, * dev_b, * dev_c;

    // --------------------SET PARAMETERS AND DATA -----------------------

    errorcode = cudaGetDeviceCount(&gpucount);
    if (errorcode == cudaErrorNoDevice)
    {
        printf("No GPUs are visible\n");
        exit(-1);
    }
    else
    {
        printf("Device count = %d\n", gpucount);
    }

    if (Block_Dim * Block_Dim > 1024)
    {
        printf("Error, too many threads in block\n");
        exit(-1);
    }
    
    if (Grid_Dim * Block_Dim < n)
    {
        printf("Error, number of threads in x/y dimensions less than number of array elements\n");
        exit(-1);
    }

    cudaSetDevice(gpunum);
    printf("Using device %d\n", gpunum);

    cudaMalloc((void**)&dev_a, m * n * sizeof(FP)); // allocate memory on device
    cudaMalloc((void**)&dev_b, n * p * sizeof(FP));
    cudaMalloc((void**)&dev_c, m * p * sizeof(FP));

    cudaMemcpy(dev_a, a, m * n * sizeof(FP), cudaMemcpyHostToDevice);
    cudaMemcpy(dev_b, b, n * p * sizeof(FP), cudaMemcpyHostToDevice);

    cudaEventRecord(start, 0);
    // cudaEventSynchronize(start); // not needed

#ifdef GPU_Task1
    dim3 DimGrid((p - 1) / BlockDim + 1, (m - 1) / BlockDim + 1, 1);
    dim3 DimBlock(BlockDim, BlockDim, 1);
    gpu_kernel_task1 <<<DimGrid, DimBlock >>> (dev_a, dev_b, dev_c, m, n, p);
#endif    

#ifdef GPU_Task2
    dim3 DimGrid(ceil(p / BlockDim), ceil(m / BlockDim), 1);
    dim3 DimBlock(TILE_WIDTH, TILE_WIDTH, 1);
    gpu_kernel_task2 << < dimGrid, dimBlock >> > (dev_a, dev_b, dev_c, m, n, p, TILE_WIDTH);
#endif

    cudaEventRecord(stop, 0); // instrument code to measure end time
    cudaEventSynchronize(stop);
    cudaEventElapsedTime(&elapsed_time_ms, start, stop);

    cudaMemcpy(gpu, dev_c, m * p * sizeof(FP), cudaMemcpyDeviceToHost);

    printf("Matrix Dimension = %d\n", n);
    printf("Block_Dim = %d, Grid_Dim = %d\n", Block_Dim, Grid_Dim);

    printf("Time to calculate results on GPU: %f ms.\n", elapsed_time_ms); // exec. time
#endif

#ifdef CPU_PART
    // ------------- COMPUTATION DONE ON HOST CPU ----------------------------
    // DEBUGGING USE ONLY (AND FOR LIMITED NUMBERS OF TIMING RUNS)

    cudaEventRecord(start, 0); // use same timing
    // cudaEventSynchronize(start); // not needed

    kij_matrixmult(a, b, kij, m, n, p); // do calculation on host (NOTE: This computes the diff with GPU result.)

    cudaEventRecord(stop, 0); // instrument code to measue end time
    cudaEventSynchronize(stop);
    cudaEventElapsedTime(&elapsed_time_ms, start, stop);

    printf("Time to calculate kij results on CPU: %f ms.\n", elapsed_time_ms); // exec. time
#endif

#ifdef CHECK_PART
    check_matrix(a, b, gpu, m, n, p);
#endif

#ifdef PRINT_PART
    print_matrix(a, m, n);
    print_matrix(b, n, p);
    print_matrix(kij, m, p);
#endif

    // -------------- clean up ---------------------------------------

    free(a);
    free(b);
    free(gpu);

#ifdef GPU_PART
    cudaFree(dev_a);
    cudaFree(dev_b);
    cudaFree(dev_c);
#endif

    cudaEventDestroy(start);
    cudaEventDestroy(stop);

    return 0;
}

