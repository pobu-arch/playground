#!/usr/bin/env perl
use v5.26;
use strict;
use warnings;
use File::Find;
use File::Copy;
use Cwd 'abs_path';
use threads;

(our $THIS_DIR = $+{path}) =~ s/\/$// if(abs_path($0) =~ /(?<path>\/.+\/)/);
our $WORKING_TEMP_DIR = "$THIS_DIR/results";
our %bench_info;

&bench_init();
my ($test_name, $need_clean, $build_only, $pre_cmd) = &argument_parser;

if($need_clean)
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
    }

    if(!exists $ENV{'SPECCPU_2006_ROOT'} && !exists $ENV{'SPECCPU_2017_ROOT'})
    {
        die "[error] please specify the root dir in \$SPECCPU_2006_ROOT or \$SPECCPU_2017_ROOT";
    }
}

if (!-e $WORKING_TEMP_DIR)
{
    mkdir $WORKING_TEMP_DIR if scalar @task_quque != 0;
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
        $bench_info{$+{dir}} = '' if ($name =~ /(?<dir>.+)\/Makefile/);
    }
}

sub get_script_path
{
    (my $final_path = $+{path}) =~ s/\/$// if(abs_path($0) =~ /(?<path>\/.+\/)/);
    return $final_path;
}