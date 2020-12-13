#!/usr/bin/env perl

use v5.10;
use strict;
use warnings;
use lib $ENV{'VERONICA_PERL'};
use Veronica::Common;
use Veronica::Threads;
use File::Copy qw(move);

Veronica::Common::set_log_level(5);

chdir("/Users/bowen/Library/Mobile\ Documents/JFJWWP64QD~com~goodiware~GoodReader/Documents/@\ Papers");

my @pdfs = `find . -type f`;

foreach my $original_path (@pdfs)
{
    if(($original_path =~ /\.pdf$/))
    {
    }
}