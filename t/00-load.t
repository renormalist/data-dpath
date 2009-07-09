#!/usr/bin/env perl

use Test::More tests => 1;

BEGIN {
        use_ok( 'Data::DPath::Fast' )
}

diag( "Testing Data::DPath::Fast $Data::DPath::Fast::VERSION, Perl $], $^X" );
