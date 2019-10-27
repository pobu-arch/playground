#!/usr/bin/env perl -w

package Veronica::common;

use v5.10;
use strict;
use warnings;
use Cwd 'abs_path';
use threads;
use Exporter qw(get_script_path mkdir_die open_die info_print)

####################################################################################################

# Misc.

####################################################################################################


sub get_script_path()
{
    (my $final_path = $+{path}) =~ s/\/$// if(abs_path($0) =~ /(?<path>\/.+\/)/);
    return $final_path;
}

sub mkdir_die()
{
    (my $dirpath) = @_;

    mkdir $dirpath if !-e $dirpath;
    die "[error] unable to create dir at $dirpath" if !-e $dirpath;
}

sub open_die()
{
    (my $dirpath) = @_;

    mkdir $dirpath if !-e $dirpath;
    die "[error] unable to create dir at $dirpath" if !-e $dirpath;
}

sub info_print()
{
    my ($level, $string) = @_;
    if($INFO_LEVEL >= $level)
    {
        my $prefix = '';
        if($level == 5)
        {
            $prefix = '[INFO] ';
        }
        elsif($level == 4)
        {
            $prefix = '[INFO] ';
        }
        elsif($level == 3)
        {
            $prefix = '[WARNING] ';
        }
        elsif($level == 2)
        {
            $prefix = '[CRITICAL] ';
        }
        elsif($level == 1)
        {
            $prefix = '[BUG] ';
        }
        elsif($level == 0)
        {
            $prefix = '';
        }

        say "${prefix}${string}";
    }
}