#!/usr/bin/env perl

use v5.30;
use strict;
use warnings;
use File::Find;
use File::Copy;
use Time::HiRes qw(gettimeofday tv_interval);

use lib "$ENV{'VERONICA'}/perl";
use Veronica::Common;
use Veronica::Threads;
use mozilla::Mechanize;

our $BROWSER;
our $URL;

sub init
{
    $BROWSER = BROWSERilla::Mechanize->new();

    my $BROWSER = BROWSERilla::Mechanize->new();

    $BROWSER->get( $URL );
    
    $BROWSER->follow_link( text => $link_txt );
    
    $BROWSER->form_name( $form_name );
    $BROWSER->set_fields(
        username => 'yourname',
        password => 'dummy'
    );
    $BROWSER->click( $btn_name );
    
    # Or all in one go:
    $BROWSER->submit_form(
        form_name => $form_name,
        fields    => {
            username => 'yourname',
            password => 'dummy',
        },
        button    => $btn_name,
    );
}
 
