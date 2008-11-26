#! /usr/bin/env perl

use strict;
use warnings;
use Test::More tests => 5;

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
my @steps = $path->_steps;
@kinds   = map { $_->{kind}   } @steps;
@parts   = map { $_->{part}   } @steps;
@filters = map { $_->{filter} } @steps;
@refs    = map { ref $_       } @steps;
print Dumper(@steps);
print Dumper(\@kinds);
is_deeply(\@kinds, [qw/ROOT KEY ANY KEY/],       "kinds");
is_deeply(\@parts, [qw{ / AAA * CCC } ],             "parts");
is_deeply(\@filters, [ undef, undef, '[0]', undef ], "filters");
is((scalar grep { $_ eq 'Data::DPath::Step' } @refs), (scalar @steps), "refs");
