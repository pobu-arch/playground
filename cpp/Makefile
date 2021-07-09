compiler 	= empty
flags  		= empty

source_dir  = empty
target_dir 	= empty
inc_dir     = empty

runargs     = empty

ifeq ($(cc),empty)
	$(error "compiler error")
endif

ifeq ($(source_dir),empty)
	$(error "source_dir error")
endif

ifeq ($(target_dir),empty)
	$(error "target_dir error")
endif

source_file = $(wildcard $(source_dir)/*.cpp) $(wildcard $(source_dir)/*.c)
build_log  	= $(target_dir)/build.log
run_log    	= $(target_dir)/run.log

#.PHONY: all clean

bin: $(source_file)
	$(compiler) $(source_file) -o $(target_dir)/bin $(flags) $(addprefix -I,$(inc_dir)) 2>&1 | tee -a $(build_log)

run: $(bin)
	#time $(target_dir)/bin | tee -a $(run_log)
	$(target_dir)/bin $(runargs)

clean:
	rm -f $(target_dir)/bin