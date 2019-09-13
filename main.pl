#!/usr/bin/env perl
use v5.10;
use strict;
use warnings;
use File::Find;
use File::Copy;
use Cwd 'abs_path';
use threads;

our $COMPILER = 'g++';
our $FLAGS    = '-O0';

(our $THIS_DIR = $+{path}) =~ s/\/$// if(abs_path($0) =~ /(?<path>\/.+\/)/);
our $WORKING_TEMP_DIR = "$THIS_DIR/results";
our %BENCH_INFO;
our @TASK_QUEUE;

&bench_init();
my ($build_only, $pre_cmd) = &argument_parsing;

foreach my $bench_name (@TASK_QUEUE)
{
    bench_compile($bench_name);
    bench_run($bench_name, $pre_cmd) if(!$build_only);
}

####################################################################################################

# Misc.

####################################################################################################

sub bench_init
{
    mkdir $WORKING_TEMP_DIR if !-e $WORKING_TEMP_DIR;
    die "[error] unable to create working temp dir at $WORKING_TEMP_DIR" if !-e $WORKING_TEMP_DIR;

    my @bench_names = glob "*/Makefile";
    foreach my $name (@bench_names)
    {
        $BENCH_INFO{$+{dir}} = '' if ($name =~ /(?<dir>.+)\/Makefile/);
    }
}

sub get_script_path
{
    (my $final_path = $+{path}) =~ s/\/$// if(abs_path($0) =~ /(?<path>\/.+\/)/);
    return $final_path;
}

sub argument_parsing
{
    my $bench_name = '';
    my $need_clean = 0;

    say '[info] parsing arguments ...';

    if(@ARGV < 1)
    {
        die '[error] no enough parameters for this script';
    }

    foreach my $current_arg (@ARGV)
    {
        # supported benchmarks?
        foreach my $bench_supported (sort keys %BENCH_INFO)
        {
            if($bench_supported =~ $current_arg)
            {
                $bench_name = $bench_supported;
                push @TASK_QUEUE, $bench_name;
                last;
            }
        }

        if($bench_name eq '')
        {
            if($current_arg =~ /-clean/)
            {
                $need_clean = 1;
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

    say "[info] cleaning results dir $WORKING_TEMP_DIR ...";
    `rm -irf $WORKING_TEMP_DIR/*`;

    return ($build_only, $pre_cmd);
}

sub bench_compile
{
    my ($bench_name) = @_;
    my $source_dir = "$THIS_DIR/$bench_name";
    my $target_dir = "$WORKING_TEMP_DIR/$bench_name";

    mkdir $target_dir if !-e $target_dir;
    die "[error] unable to create $target_dir" if !-e $target_dir;
    
    chdir "$source_dir";
    system "make bin source_dir=$source_dir target_dir=$target_dir compiler=$COMPILER flags=$FLAGS";
}

sub bench_run
{
    my ($bench_name, $pre_cmd) = @_;
    my $source_dir = "$THIS_DIR/$bench_name";
    my $target_dir = "$WORKING_TEMP_DIR/$bench_name";
    
    chdir "$source_dir";
    system "$pre_cmd make run source_dir=$source_dir target_dir=$target_dir";
}