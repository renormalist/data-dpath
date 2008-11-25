#! /usr/bin/env perl

use strict;
use warnings;
use Test::More tests => 8;

use 5.010;

use Data::Dumper;

BEGIN {
	use_ok( 'Data::DPath::Path' );
}

my $path;
my @kinds;
my @parts;
my @filters;
my @refs;

$path    = new Data::DPath::Path( path => '/AAA/*[0]/CCC' );
@kinds   = map { $_->{kind}   } $path->_steps;
@parts   = map { $_->{part}   } $path->_steps;
@filters = map { $_->{filter} } $path->_steps;
@refs    = map { ref $_       } $path->_steps;
print Dumper($path->_steps);
print Dumper(\@kinds);
is_deeply(\@kinds, [qw/HASH HASH ARRAY HASH/],       "kinds");
is_deeply(\@parts, ['', qw/AAA * CCC/],              "parts");
is_deeply(\@filters, [ undef, undef, '[0]', undef ], "filters");
is($_, 'Data::DPath::Step', "kinds") foreach @refs;

