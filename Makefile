compiler 	= gcc
flags  		= -O3 -lstdc++

source_dir  = empty
target_dir 	= empty

ifeq ($(source_dir),empty)
	$(error "error")
endif

ifeq ($(target_dir),empty)
	$(error "error")
endif

source_file = $(wildcard $(source_dir)/*.cpp) $(wildcard $(source_dir)/*.c)
build_log  	= $(target_dir)/build.log
run_log    	= $(target_dir)/run.log

#.PHONY: all clean

bin: $(source_file)
	$(compiler) $(source_file) -o $(target_dir)/bin $(flags) 2>&1 | tee -a $(build_log)

clean:
	rm -f $(target_dir)/bin