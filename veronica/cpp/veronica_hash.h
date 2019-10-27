#include <stdint.h>

namespace veronica
{
    uint64_t int_hash(const uint64_t input)
    {
        return (input * 16807) % 2147483647;
    }
}