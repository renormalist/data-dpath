#! /usr/bin/env perl

use 5.010;
use strict;
use warnings;
use Data::Dumper;
use Data::DPath 'dpath';

use Test::More tests => 2;

#local $Data::DPath::DEBUG = 1;

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

my @resultlist;
my $context;

# trivial matching

@resultlist = $data ~~ dpath '/AAA/BBB/CCC';
say "resultlist == ", Dumper(\@resultlist);
is_deeply(\@resultlist, [ ['XXX', 'YYY', 'ZZZ'] ], "KEYs" );

# commutative?
@resultlist = dpath '/AAA/BBB/CCC' ~~ $data;
say "resultlist == ", Dumper(\@resultlist);
is_deeply(\@resultlist, [ ['XXX', 'YYY', 'ZZZ'] ], "KEYs" );

