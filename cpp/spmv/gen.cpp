#include <iostream>
#include <cstdlib>
#include <ctime>

typedef unsigned long long uint64;

int main(int argc, char* argv[])
{
    uint64 num_rows = 0;
    uint64 num_cols = 0;
    uint64 nnz      = 0;
    uint64 sparsity = 100;
    FILE * output;

    if(argc < 4)
    {
        printf("[error] please specify num_rows, num_cols and the level of sparsity(1.0-100.0)\n");
        exit(-1);
    }

    num_rows = atoi(argv[1]);
    num_cols = atoi(argv[2]);
    sparsity = atoi(argv[3]);

    if(num_rows == 0 || num_cols == 0 || sparsity < 0 || sparsity > 100)
    {
        printf("[error] wrong num of num_rows or num_cols or sparsity\n");
        exit(-1);
    }

    nnz = ((double)num_rows / 100 ) * num_cols * sparsity;
    srand (time(NULL));
    output = fopen("matrix.mtx","w");

    printf("[info] nnz = %lld\n", nnz);
    fprintf(output, "%lld %lld %lld\n", num_rows, num_cols, nnz);

    for(uint64 row_index = 0; row_index < num_rows; row_index++)
    {
        for(uint64 col_index = 0; col_index < num_cols; col_index++)
        {
            if(rand() % 100 > sparsity)
            {
                fprintf(output, "%lld %lld %d\n", row_index, col_index, rand() % 10);
            }
        }
    }

    return 0;
}