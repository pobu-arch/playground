#include <stdio.h>
#include <stdlib.h>

double N = 1000000000;
double sum = 0;

double func(double x)
{
	return (double)1.0 / (1.0 + x * x);
}

int main(void)
{
	for(unsigned int index = 1; index < N; index++)
	{
		sum += (1 / N) * func(((double)1.0 / (2 * N)) + index * (1 / N));
	}

	printf("result = %f\n", sum * 4);
	return 0;
}
