#! /usr/bin/env perl

use Test::More tests => 1;

BEGIN {
        use_ok( 'Data::DPath' )
}

diag( "Testing Data::DPath $Data::DPath::VERSION, Perl $], $^X" );
