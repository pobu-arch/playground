#include <ctime>
#include <cmath>
#include <string>
#include <stdint.h>

namespace veronica
{
    const uint64_t MAX_NUM_TIMER = 10;

    struct timepoint
    {
        struct timespec start;
        struct timespec end;
    }timepoints[MAX_NUM_TIMER];

    void check_timer_index(const uint64_t index)
    {
        if(index >= MAX_NUM_TIMER)
        {
            printf("[error] timer index is larger than MAX_NUM_TIMER %lld\n", MAX_NUM_TIMER);
            exit(-1);
        }
    }

    double time_spec_to_ns(const timespec* tv)
    {
        return tv->tv_sec * pow(10,9) + tv->tv_nsec;
    }

    void set_timer_start(const uint64_t index)
    {
        check_timer_index(index);
        clock_gettime(CLOCK_MONOTONIC, &(timepoints[index].start));
    }

    void set_timer_end(const uint64_t index)
    {
        check_timer_index(index);
        clock_gettime(CLOCK_MONOTONIC, &(timepoints[index].end));
    }

    void print_timer(const uint64_t index, const char* name)
    {
        double elapsed_time = time_spec_to_ns(&(timepoints[index].end)) - time_spec_to_ns((&timepoints[index].start));

        if(elapsed_time >= pow(10,9))
        {
            uint64_t sec  = floor(elapsed_time / pow(10,9));
            uint64_t msec = floor((elapsed_time - sec * pow(10,9)) / pow(10,6));
            printf("[time] timer %s = %llds %lldms\n", name, sec, msec);
        }
        else if(elapsed_time >= pow(10,6))
        {
            uint64_t msec  = floor(elapsed_time / pow(10,6));
            uint64_t usec = floor((elapsed_time - msec * pow(10,6)) / pow(10,3));
            printf("[time] timer %s = %lldms %lldus\n", name, msec, usec);
        }
        else if(elapsed_time >= pow(10,3))
        {
            uint64_t usec  = floor(elapsed_time / pow(10,3));
            uint64_t nsec = floor((elapsed_time - usec * pow(10,3)));
            printf("[time] timer %s = %lldus %lldns\n", name, usec, nsec);
        }
        else
        {
            printf("[time] timer %s = %lldns\n", name, (uint64_t)time_spec_to_ns(&(timepoints[index].start)));
            printf("[time] timer %s = %lldns\n", name, (uint64_t)time_spec_to_ns(&(timepoints[index].end)));
        }
    }
}
