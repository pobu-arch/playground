#!/usr/bin/env perl
use v5.10;
use strict;
use warnings;
use File::Find;
use File::Copy;
use lib "$ENV{'VERONICA'}/perl";
use Veronica::Common;

our $COMPILER = 'g++';
our $FLAGS    = '-O3 -g';

our $THIS_DIR         = Veronica::Common::get_script_path();
our $RESULTS_DIR      = "$THIS_DIR/../_results";
our $VERONICA_CPP_DIR = "$ENV{'VERONICA'}/cpp";
our %BENCH_INFO;
our %TASK_QUEUE;

&bench_init();
my ($build_only, $pre_cmd) = &argument_parsing;

foreach my $bench_name (keys %TASK_QUEUE)
{
    my $build_error = &bench_compile($bench_name);
    &bench_run($pre_cmd, $bench_name, $TASK_QUEUE{$bench_name}) if(!$build_error & !$build_only);
}

####################################################################################################

# Misc.

####################################################################################################

sub bench_init()
{
    mkdir $RESULTS_DIR if !-e $RESULTS_DIR;
    die "[error-script] unable to create working temp dir at $RESULTS_DIR" if !-e $RESULTS_DIR;

    Veronica::Common::set_msg_level(5);

    my @bench_names = glob "*/Makefile";
    foreach my $name (@bench_names)
    {
        $BENCH_INFO{$+{dir}} = '' if ($name =~ /(?<dir>.+)\/Makefile/);
        Veronica::Common::say_level("detected $+{dir}", 5);
    }

    die "[error] Veronica is not imported !" if $VERONICA_CPP_DIR eq '/cpp';
    Veronica::Common::say_level("veronica CPP Library dir is at $VERONICA_CPP_DIR", 5);
    Veronica::Common::say_level("playground dir is at $RESULTS_DIR", 5);
    Veronica::Common::say_level("working temp dir is at $RESULTS_DIR", 5);
    Veronica::Common::say_level("init done\n\n", 5);
}

sub argument_parsing()
{
    my $bench_name = '';
    my $need_clean = 0;

    Veronica::Common::say_level("parsing arguments ...", 5);

    if(@ARGV < 1)
    {
        die '[error-script] no enough parameters for this script';
    }

    foreach my $current_arg (@ARGV)
    {
        # supported benchmarks?
        foreach my $bench_supported (sort keys %BENCH_INFO)
        {
            if($bench_supported =~ $current_arg)
            {
                $bench_name = $bench_supported;
                $TASK_QUEUE{$bench_name} = '';
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
            elsif($current_arg =~ /-runargs='(?<runargs>.*)'/)
            {
                Veronica::Common::say_level("the run args for $bench_name is ".$+{runargs}, 5);
                $TASK_QUEUE{$bench_name} = $+{runargs};
            }
            else
            {
                die "[error-script] unknown parameters $current_arg";
            }
        }
    }

    die "[error-script] please specify the benchmark(s)" if $bench_name eq '';

    Veronica::Common::say_level("the selected benchmark is $bench_name", 5) if $bench_name ne '';
    Veronica::Common::say_level("the build_only option is ON", 3) if $build_only;

    #read pre cmd input from stdin, auto timeout
    my $timeout = 1;

    eval
    {
        local $SIG{ALRM} = sub{die 'alarm'};
        alarm $timeout;

        $pre_cmd=<STDIN>;
        chomp $pre_cmd if $pre_cmd ne '';
        Veronica::Common::say_level("the preceding command is \"$pre_cmd\"", 5);

        alarm 0;
    };
    Veronica::Common::say_level("stdin timeout", 3) if $@ eq 'alarm';

    Veronica::Common::say_level("cleaning results dir $RESULTS_DIR ...", 5);
    `rm -irf $RESULTS_DIR/*`;

    return ($build_only, $pre_cmd);
}

sub bench_compile()
{
    my ($bench_name)    = @_;
    my $source_dir      = "$THIS_DIR/$bench_name";
    my $target_dir      = "$RESULTS_DIR/$bench_name";
    my $compile_logfile = "$target_dir/compile.log";

    mkdir $target_dir if !-e $target_dir;
    die "[error-script] unable to create $target_dir" if !-e $target_dir;

    chdir "$source_dir";
    my $parameters = "source_dir=$source_dir target_dir=$target_dir inc_dir=$VERONICA_CPP_DIR";
       $parameters.= " compiler=\"$COMPILER\" \"flags=$FLAGS\"";

    say "\n";

    my $compile_log = `make bin $parameters`;
    say "$compile_log";
    if($compile_log =~ 'errors generated.')
    {
        die "[error] fail to open $compile_logfile" if !open COMPILE_LOGFILE, ">$compile_logfile";
        print COMPILE_LOGFILE $compile_log;
        close COMPILE_LOGFILE;
        return 1;
    }

    return 0;
}

sub bench_run()
{
    my ($pre_cmd, $bench_name, $runargs) = @_;
    my $source_dir = "$THIS_DIR/$bench_name";
    my $target_dir = "$RESULTS_DIR/$bench_name";

    chdir "$source_dir";
    say "\n";
    system "$pre_cmd make run source_dir=$source_dir target_dir=$target_dir runargs=$runargs";
}