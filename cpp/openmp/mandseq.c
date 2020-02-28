#include <stdio.h>
#include <math.h>
#include "timing.h"

double drand(void);
void dsrand(unsigned s);

struct complex_number
{
    double real;
    double img;
};

int is_in_mandelbrot(int real_index, int img_index)
{
    int64_t iterate_count = 20000;
    struct complex_number c;
    struct complex_number z;
    c.real = ((double)real_index + drand()) / 1000;
    c.img  = ((double)img_index  + drand()) / 1000;
    z = c;
    
    while(iterate_count--)
    {
        struct complex_number new_z;

        new_z.real = z.real * z.real - z.img * z.img + c.real;
        new_z.img  = 2 * z.real * z.img + c.img;
        z = new_z;
        
        if(z.real * z.real + z.img * z.img > 4) return 0;
    }
    return 1;
}

int main()
{
    int64_t in_ctr   = 0;
    int64_t total_ctr = 0;
    double start_time, end_time, cputime;

    dsrand(12345);
    timing(&start_time, &cputime);
    for(int real_index = -2000; real_index < 500; real_index ++)
    {
        for(int img_index = 0; img_index < 1250; img_index ++)
        {
            in_ctr += is_in_mandelbrot(real_index, img_index);
            total_ctr++;
        }
    }
    timing(&end_time, &cputime);
    double area = 2.0 * 3.125 * in_ctr / total_ctr;

    printf("Area    is %f, inside ctr is %d, total cells are %d\n", area, in_ctr, total_ctr);
    printf("Runtime is %f\n", end_time - start_time);
    return 0;
}
