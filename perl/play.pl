#!/usr/bin/env perl

use v5.10;
use strict;
use warnings;
use lib $ENV{'VERONICA_PERL'};
use Veronica::Common;
use Veronica::Threads;

Veronica::Common::set_msg_level(5);
Veronica::Common::say_level('4', 'lalala');