compiler 	= empty
flags  		= empty

source_dir  = empty
target_dir 	= empty

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
	$(compiler) $(source_file) -o $(target_dir)/bin $(flags) 2>&1 | tee -a $(build_log)

clean:
	rm -f $(target_dir)/bin