# What's this

This is a working script for running SPECCPU 2006 / 2017.

Currenly only 9 benchmarks from SPECint06 and 5 benchmarks from SPECint17 are supported.

# Usage

1. git clone this repo.

2. chmod +x simple_spec.pl

3. set the following env variables

export SPECCPU_2006_ROOT = YOUR_SPECCPU_2006_DIRECTORY

export SPECCPU_2017_ROOT = YOUR_SPECCPU_2017_DIRECTORY

Example：
`./simple_spec -input=test -clean 429`

`-input=test` indicates using test input, this option can also be `-input=ref` to indicate using ref input

`-build_core=8` indicates using 8 cores during compilation

~~`-run_core=4` indicates using 4 cores for running the benchmarks~~

`-clean` indicates cleaning working log from last run

`429` indicates the benchmark name. The script has pattern matching, so both `429` and `429.mcf` work for 429.mcf

Or you can launch a batch of benchmarks in this way:
`./simple_spec -input=test version_type`

The option for `version` is `2016` or `2017`

The option for `type` is `int` or `fp` or `all`

# Build_Only Mode

If you just want to compile the bencharms without actually running them, use `-build_only`

# Using perf or taskset with a benchmark process

Example:
`echo "taskset -c 1 /usr/bin/perf stat" | ./simple_spec -test -clean 429`

The taskset and perf command will only be applied to the benchmarks, this script and the compilation of benchmarks are not affected.
