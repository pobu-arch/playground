#!/usr/bin/env perl

use v5.10;
use strict;
use warnings;
use File::Find;
use File::Copy;
use Cwd 'abs_path';

use lib $ENV{'VERONICA_PERL'};
use Veronica::Common;
use Veronica::Threads;

use threads;

our $C_COMPILER         = 'gcc';
our $CPP_COMPILER       = 'g++';
our $FORTRAN_COMPILER   = 'gfortran';
our $OPTIMIZATION_FLAGS = '-O3';
our $BUILD_CPU_NUM      = 1;
our $RUN_CPU_NUM        = 1;

our %SPEC_INFO;
our %SUPPORTED_BENCHMARKS;
our %UNSUPPORTED_BENCHMARKS;

our $THIS_DIR = Veronica::Common::get_script_path();
our $WORKING_TEMP_DIR   = "$THIS_DIR/_results";
require ("$THIS_DIR/info.pl");

our %THREAD_POOL        = ();
our @task_quque;

say "\n";
say " ******** SPECCPU working script by Pobu v2.0 ********";
say "\n";

####################################################################################################

# Main Logic

####################################################################################################

my ($bench_name, $input_size, $need_clean, $build_only, $pre_cmd) = &argument_parse;
&clean() if($need_clean);
&spec_init($bench_name);

foreach my $bench_name (@task_quque)
{
    my $current_time        = time();
    #my $working_temp       = "$WORKING_TEMP_DIR/"."${bench_name}_"."$current_time";
    my $working_temp        = "$WORKING_TEMP_DIR/$bench_name";
    my $precmd_log_file     = "$working_temp/pre_cmd.log";
    my $compile_log_file    = "$working_temp/compile.log";
    my $run_cmd_file        = "$working_temp/run_cmd";
    my $run_log_file        = "$working_temp/run_output.log";

    &spec_compile($working_temp, $bench_name, $need_clean, $compile_log_file);
    &spec_run_setup($working_temp, $bench_name, $input_size, $pre_cmd, $run_cmd_file, $run_log_file);
    if(!$build_only)
    {
        my $pre_cmd_log = &spec_run($working_temp, $bench_name, $input_size,
                                    $pre_cmd, $run_cmd_file, $run_log_file);

        &post_run_check($pre_cmd_log, $bench_name, $run_log_file, $precmd_log_file);
    }
}

####################################################################################################

# Subroutine

####################################################################################################

sub argument_parse
{
    my $bench_name = '';
    my $need_clean = 0;
    my $build_only = 0;
    my $input_size = '';
    my $pre_cmd = '';

    say '[info] parsing arguments ...';

    if(@ARGV < 1)
    {
        die '[error] no enough parameters for this script';
    }

    foreach my $current_arg (@ARGV)
    {
        # unsupported benchmarks?
        foreach my $bench_unsupported (keys %UNSUPPORTED_BENCHMARKS)
        {
            if($bench_unsupported =~ $current_arg)
            {
                say "[error] $bench_unsupported is unsupported";
                die "[error] the reason is ".$UNSUPPORTED_BENCHMARKS{$bench_unsupported}{'reason'};
            }
        }

        # supported benchmarks?
        foreach my $bench_supported (sort keys %SUPPORTED_BENCHMARKS)
        {
            if($bench_supported =~ $current_arg)
            {
                $bench_name = $bench_supported;
                last;
            }
        }

        if($current_arg =~ /(?<version>2006|2017)_(?<type>all|int|fp)/)
        {
            $bench_name = $+{version}.'_'.$+{type};
        }

        if($bench_name eq '')
        {
            if($current_arg =~ /-clean/)
            {
                $need_clean = 1;
            }
            elsif($current_arg =~ /-input=(?<size>test|train|ref)/)
            {
                $input_size = $+{size};
            }
            elsif($current_arg =~ /-build_core=(?<build_num>\d+)/)
            {
                $BUILD_CPU_NUM = $+{build_num};
            }
            elsif($current_arg =~ /-run_core=(?<run_num>\d+)/)
            {
                $RUN_CPU_NUM = $+{run_num};
            }
            elsif($current_arg =~ /-build_only/)
            {
                $build_only = 1;
            }
            else
            {
                die "[error] unknown parameters $current_arg";
            }
        }
    }

    die "[error] please specify the benchmark(s)" if $bench_name eq '';
    say "[info] the selected benchmark is $bench_name" if $bench_name ne '';
    say '[warning] the build_only option is ON' if $build_only;
    say '[critical warning] the type of specrun (ref/test) is unknown, set it to test' if $input_size eq '';
    $input_size = 'test' if $input_size eq '';

    #read pre cmd input from stdin, auto timeout
    my $timeout = 1;

    eval
    {
        local $SIG{ALRM} = sub{die 'alarm'};
        alarm $timeout;

        $pre_cmd=<STDIN>;
        chomp $pre_cmd if $pre_cmd ne '';
        say "[info] the preceding command is \"$pre_cmd\"";

        alarm 0;
    };
    say '[warning] stdin timeout' if $@ eq 'alarm';

    if($pre_cmd ne '')
    {
        say "[warning] sudo is recommended when preceding cmd is specified";
    }

    return ($bench_name, $input_size, $need_clean, $build_only, $pre_cmd);
}

sub clean
{
    say "[info] cleaning SPECCPU dir and $WORKING_TEMP_DIR ...";
    `rm -irf $WORKING_TEMP_DIR/*`;

    if(exists $ENV{'SPECCPU_2006_ROOT'})
    {
        system "rm -irf ".$ENV{'SPECCPU_2006_ROOT'}."/benchspec/C*/*/run";
        system "rm -irf ".$ENV{'SPECCPU_2006_ROOT'}."/benchspec/C*/*/exe";
        system "rm -irf ".$ENV{'SPECCPU_2006_ROOT'}."/benchspec/C*/*/build";
        system "rm -irf ".$ENV{'SPECCPU_2006_ROOT'}."/result/*";
    }

    if(exists $ENV{'SPECCPU_2017_ROOT'})
    {
        system "rm -irf ".$ENV{'SPECCPU_2017_ROOT'}."/benchspec/C*/*/run";
        system "rm -irf ".$ENV{'SPECCPU_2017_ROOT'}."/benchspec/C*/*/exe";
        system "rm -irf ".$ENV{'SPECCPU_2017_ROOT'}."/benchspec/C*/*/build";
        system "rm -irf ".$ENV{'SPECCPU_2017_ROOT'}."/result/*";

        system "find ".$ENV{'SPECCPU_2017_ROOT'}." -type f -name \"*.fppized.f90*\" | xargs rm";
    }

    if(!exists $ENV{'SPECCPU_2006_ROOT'} && !exists $ENV{'SPECCPU_2017_ROOT'})
    {
        die "[error] please specify the root dir in \$SPECCPU_2006_ROOT or \$SPECCPU_2017_ROOT";
    }
}

sub spec_compile
{
    my ($working_temp, $bench_name, $need_clean, $compile_log_file) = @_;
    system "rm $compile_log_file" if -e $compile_log_file;

    say "[info] starting compilation for $bench_name ...";

    Veronica::Common::mkdir_or_die("$working_temp");
    Veronica::Common::mkdir_or_die("$working_temp/obj");
    system "rm -irf $working_temp/obj/*";

    # setup spec root dir
    my $version = $SUPPORTED_BENCHMARKS{$bench_name}{'version'};

    die "[error] environment has not been set for \$SPECCPU_${version}_ROOT"
    if (!exists $ENV{"SPECCPU_${version}_ROOT"});

    my $specroot = $ENV{"SPECCPU_${version}_ROOT"};

    if($version eq '2006')
    {
        $SUPPORTED_BENCHMARKS{$bench_name}{'src_dir'} =
        "$specroot/benchspec/CPU2006/$bench_name";
    }
    elsif($version eq '2017')
    {
        if($bench_name =~ /6(?<invariant>\d\d\.[a-zA-Z0-9]+)_s/)
        {
            $SUPPORTED_BENCHMARKS{$bench_name}{'src_dir'} =
            "$specroot/benchspec/CPU/".'5'.$+{invariant}.'_r';
        }
        else
        {
            $SUPPORTED_BENCHMARKS{$bench_name}{'src_dir'} =
            "$specroot/benchspec/CPU/$bench_name";
        }
    }

    # setup filelist, if it applies
    my @filelist = ();
    if(exists $SPEC_INFO{$version}{$bench_name})
    {
        my $filelist_path = "$THIS_DIR/filelist/$SPEC_INFO{$version}{$bench_name}";
        my $filelist_handle = Veronica::Common::open_or_die("<$filelist_path");

        while(my $line = <$filelist_handle>)
        {
            push @filelist, $SUPPORTED_BENCHMARKS{$bench_name}{'src_dir'}."/src/$line";
        }
        close $filelist_handle;
    }

    if($bench_name eq '648.exchange2_s')
    {
        my $cmd  = "$specroot/bin/specperl";
           $cmd .= ' '."$specroot/bin/harness/specpp";
           $cmd .= ' '.$SPEC_INFO{$version}{'macro'};
           $cmd .= ' '.$SUPPORTED_BENCHMARKS{$bench_name}{'src_dir'}.'/src/exchange2.F90';
           $cmd .= ' -o '.$SUPPORTED_BENCHMARKS{$bench_name}{'src_dir'}.'/src/exchange2.fppized.f90';
        say "$cmd";
        `$cmd`;
    }

    # find source files
    my %source_files = ();
    my %source_files_include_dirs = ();

    find(
            sub {
                    my $name = $_;
                    if($name =~ /(\.c)$|(\.cc)$|(\.cpp)$|(\.F)$|(\.f90)$/
                       && !($name            =~ /win32/)
                       && !($File::Find::dir =~ /win32/))
                    {
                        my $check_pass = 0;
                        if(@filelist != 0)
                        {
                            foreach my $check_name (@filelist)
                            {
                                if($check_name =~ "$File::Find::dir.$name")
                                {
                                    $check_pass = 1;
                                    last;
                                }
                            }
                        }
                        else
                        {
                            $check_pass = 1;
                        }
                        
                        if($check_pass)
                        {
                            $source_files{$File::Find::dir.'--path--'.$name} = $File::Find::dir;
                        }
                    }
                    elsif($File::Find::name =~ /(\.h)$|(\.hh)$|(\.hpp)$/)
                    {
                        if(!exists $source_files_include_dirs{$File::Find::dir} and
                        !($File::Find::dir =~ /win32/) && !($name =~ /win32/) and
                        !($File::Find::dir =~ 'api/lzma' && $bench_name eq '657.xz_s') and
                        !(($File::Find::dir =~ 'third_party' || $File::Find::dir =~ 'cuew') && $bench_name eq '526.blender_r'))
                        {
                            $source_files_include_dirs{$File::Find::dir} = '';
                        }
                    }
                },
            $SUPPORTED_BENCHMARKS{$bench_name}{'src_dir'}."/src"
        );

    die "[error] source_files undetected for $bench_name" if scalar keys %source_files == 0;

    # setup flags
    my $flags  = '';
       $flags .= " $OPTIMIZATION_FLAGS";
       $flags .= ' '.$SPEC_INFO{$version}{'macro'};
       $flags .= ' '.$SUPPORTED_BENCHMARKS{$bench_name}{'macro'};
    if(`uname -a` =~ 'Darwin')
    {
        $flags .= ' -DSPEC_MACOSX -DSPEC_MACOSX_X64 -DSPEC_MACOSX_GCC -DSPEC_CPU_MACOSX';
    }
    elsif(`uname -a` =~ 'Linux')
    {
        $flags .= ' -DSPEC_LINUX_X64 -DSPEC_CPU_LINUX_X64';
        $flags .= ' -DSPEC_MACOSX_GCC' if $bench_name eq '623.xalancbmk_s';
        $flags .= ' -static';
    }
    else
    {
        die '[error] unsupported system';
    }

    my $compile_cmd = '';
    my $compiler    = '';
    my $error       = 0;

    my $obj_count = 1;
    foreach my $fullpath (sort keys %source_files)
    {
        (my $filename = $fullpath) =~ s/.+--path--//;
        if($filename =~ /(\.cpp)$/)
        {
            $compiler = $CPP_COMPILER;
        }
        elsif($filename =~ /(\.c)$|(\.cc)$/)
        {
            $compiler = $C_COMPILER;
        }
        elsif($filename =~ /(\.f)$|(\.F)$|(\.f90)$/)
        {
            $compiler = $FORTRAN_COMPILER;
        }
        else
        {
            die '[error] unsupported language';
        }

        $compile_cmd = $compiler;

        (my $object_name = $filename) =~ s/(\.c)$|(\.cc)$|(\.cpp)$|(\.F)$|(\.f90)$/\.o/;
        $compile_cmd .= " -c ".($source_files{$fullpath}.'/'.$filename);
        $compile_cmd .= " -o ".($working_temp."/obj/${obj_count}_".$object_name);

        foreach my $current_dir (keys %source_files_include_dirs)
        {
            $compile_cmd .= " -I$current_dir";
        }

        $compile_cmd .= $flags;

        say "\n";
        say "$compile_cmd";

        if($BUILD_CPU_NUM > 1)
        {
            $error = Veronica::Threads::thread_start($compile_cmd, ">>$compile_log_file");
            goto BUILD_ERROR if $error;
        }
        else
        {
            $error = system "$compile_cmd 2>> $compile_log_file";
        }

        $obj_count++;
        goto BUILD_ERROR if $error;
    }

    # empty the thread pool
    $error = Veronica::Threads::join_n_thread_with_log(scalar threads->list()) if($BUILD_CPU_NUM > 1);
    goto BUILD_ERROR if($error);

    # linking
    say "\n";
    say "[info] starting linking for $bench_name ...";
    my @obj_files = glob "$working_temp/obj/*.o";
    my $link_cmd  = "$compiler @obj_files $flags -o $working_temp/${bench_name}";
       $link_cmd .= " -lm -lstdc++ -dead_strip";
    
    foreach my $current_dir (keys %source_files_include_dirs)
    {
        $link_cmd .= " -I$current_dir";
    }

    say "$link_cmd\n\n";
    
    my $compile_log_handle = Veronica::Common::open_or_die(">>$compile_log_file");
    print $compile_log_handle $link_cmd;
    print $compile_log_handle "\n\n";
    close $compile_log_handle;
    # flush write buffer
    select((select($compile_log_handle), $| = 1)[0]);

    $error = system "$link_cmd 2>> $compile_log_file";

    BUILD_ERROR:
    if($error)
    {
        Veronica::Threads::join_n_thread_with_log(scalar threads->list()) if($BUILD_CPU_NUM > 1);

        say "\n";
        say "[error] build error detected for $bench_name";
        die "[error] plz check $compile_log_file";
    }
}

sub spec_run_setup
{
    my($working_temp, $bench_name, $input_size, $pre_cmd, $run_cmd_file, $run_log_file) = @_;
    die '[error] you must specify the size of benchmark (ref/test) ?' if $input_size eq '';

    my $run_cmd_handle = Veronica::Common::open_or_die(">$run_cmd_file");
    print $run_cmd_handle "#!/bin/bash\n";

    say "[info] clustering inputing arguments for $bench_name ...";
    foreach my $current_run_args (@{$SUPPORTED_BENCHMARKS{$bench_name}{$input_size}})
    {
        $bench_name ne '445.gobmk' ?
        print $run_cmd_handle "$working_temp/$bench_name $current_run_args >> $run_log_file\n" :
        print $run_cmd_handle "cat $current_run_args | $working_temp/$bench_name >> $run_log_file\n";
    }
    close $run_cmd_handle;

    chdir $working_temp;
    system "chmod 777 $run_cmd_file";

    # coping data input
    say "[info] coping data input for $bench_name ...";
    my $input_size_fix = '';
    my $version        = $SUPPORTED_BENCHMARKS{$bench_name}{'version'};
    
    if($version eq '2017')
    {
        if($input_size eq 'ref')
        {
            if($bench_name eq '620.omnetpp_s' or $bench_name eq '623.xalancbmk_s')
            {
                $input_size_fix = 'rate';
            }
            else
            {
                $input_size_fix = 'speed';
            }
        }
    }

    my $target_benchmark_dir = $SUPPORTED_BENCHMARKS{$bench_name}{'src_dir'};

    system ("cp -r $target_benchmark_dir/data/${input_size}"."${input_size_fix}"."/input/* $working_temp/.");
    system ("cp -r $target_benchmark_dir/data/all/input/* $working_temp/.") if -e "$target_benchmark_dir/data/all";
    system ("rm -irf $working_temp/control") if -e "$working_temp/control";
}

sub spec_run
{
    my($working_temp, $bench_name, $input_size, $pre_cmd, $run_cmd_file, $run_log_file) = @_;

    say "[info] executing command $pre_cmd $run_cmd_file ...";
    return `$pre_cmd $run_cmd_file 2>&1 $run_log_file`;
}

sub post_run_check
{
    my($pre_cmd_log, $bench_name, $run_log_file, $precmd_log_file) = @_;

    die "[error] Please use /usr/bin/perf rather than perf\n".
        '[error] perf is uncompatible with perl\'s system call for unknown reason.'
    if $pre_cmd_log =~ 'Please install an MTA on this system if you want to use sendmail';

    if($pre_cmd_log ne '')
    {
        my $perf_log_handle = Veronica::Common::open_or_die(">$precmd_log_file");

        print $perf_log_handle $pre_cmd_log;
        close $perf_log_handle;
    }

    say "[info] starting post-run check for $bench_name ...";

    die "[error] $run_log_file doesn't exist"
    if !-e $run_log_file;

    my $run_log_handle = Veronica::Common::open_or_die("<$run_log_file",
                                                       "it may indicates perf or run errors");

    my $line;
    my $run_log = '';

    while(defined($line=<$run_log_handle>))
    {
        $run_log .= $line;
    }
    close $run_log_handle;

    say "\n";
    say $run_log if $run_log ne '';
    say $pre_cmd_log;
}

####################################################################################################

# Misc.

####################################################################################################

sub spec_init
{
    (my $bench_name) = @_;
    
    Veronica::Common::mkdir_or_die("$WORKING_TEMP_DIR");

    if(!($bench_name =~ '(2006|2017)_(all|int|fp)'))
    {
        push @task_quque, $bench_name;
    }
    elsif($bench_name =~ /(?<version>2006|2017)_(?<type>all|int|fp)/)
    {
        if($+{type} eq 'all')
        {
            foreach my $bench_name (sort keys %SUPPORTED_BENCHMARKS)
            {
                push @task_quque, $bench_name if $SUPPORTED_BENCHMARKS{$bench_name}{'version'} eq $+{'version'};
            }
        }
        else
        {
            foreach my $bench_name (sort keys %SUPPORTED_BENCHMARKS)
            {
                push @task_quque, $bench_name if ($SUPPORTED_BENCHMARKS{$bench_name}{'version'} eq $+{'version'}) &&
                                                ($SUPPORTED_BENCHMARKS{$bench_name}{'type'}    eq $+{'type'});
            }
        }
    }

    say "[warning] task queue is empty, it may indicates unsupported benchmarks are selected" if @task_quque == 0;
}
