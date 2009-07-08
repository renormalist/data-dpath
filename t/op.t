#! /usr/bin/env perl

use 5.010;
use strict;
use warnings;
use Data::Dumper;
use Data::DPath::Fast 'dpath';

use Test::More tests => 2;

#local $Data::DPath::Fast::DEBUG = 1;

my $data  = {
             AAA  => { BBB   => { CCC  => [ qw/ XXX YYY ZZZ / ] },
                       RRR   => { CCC  => [ qw/ RR1 RR2 RR3 / ] },
                       DDD   => { EEE  => [ qw/ uuu vvv www / ] },
                     },
             some => { where => { else => {
                                           AAA => { BBB => { CCC => 'affe' } },
                                          } } },
             strange_keys => { 'DD DD' => { 'EE/E' => { CCC => 'zomtec' } } },
            };

my $resultlist;
my $context;

# trivial matching

is_deeply($data ~~ dpath '/AAA/BBB/CCC', [ ['XXX', 'YYY', 'ZZZ'] ], "data ~~ dpath" );
is_deeply(dpath '/AAA/BBB/CCC' ~~ $data, [ ['XXX', 'YYY', 'ZZZ'] ], "dpath ~~ data (commutative)" );

