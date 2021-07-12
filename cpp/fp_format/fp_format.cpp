#include <cstdio>
#include <cstdlib>
#include <cmath>
#include <cstring>
#include <bitset>
#include "veronica.h"

// TODO: need to work on big endian

using namespace std;

typedef float FP;

template <class T> bitset<T> any_num_to_bitset(const veronica::byte* byte_ptr, const veronica::uint64 size)
{
	bitset<size * 8> bits;

	for(veronica::uint64 byte_ctr = 0; byte_ctr != size; byte_ctr++)
	{
		veronica::byte mask = 0x01;
		for(veronica::uint64 index = 0; index < 8; index++)
		{
			bits[byte_ctr * 8 + index] = (*byte_ptr) & mask;
			mask <<= 1;
		}
	}
	return bits;
}

int main()
{
	printf("[Info] FP size = %lu Bytes\n", sizeof(FP));
	int input = 15;
	cout << any_num_to_bitset(input, sizeof(input)) << endl;
	return 0;
}
