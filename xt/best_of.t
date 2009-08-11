#! /usr/bin/env perl

use 5.010;
use strict;
use warnings;
use Test::More tests => 6;
use Test::Deep;
use Data::DPath 'dpath', 'dpathr';
use Data::Dumper;

# local $Data::DPath::DEBUG = 1;

BEGIN {
	use_ok( 'Data::DPath' );
}

my $resultlist;

my $data3  = {
              AAA  => bless( { BBB => { CCC  => [ qw/ XXX YYY ZZZ / ] } }, "Foo::Bar"), # blessed BBB
              some => { where => { else => {
                                            AAA => { BBB => { CCC => 'affe' } }, # plain BBB
                                           } } },
              neighbourhoods => [
                                 { 'DDD' => { EEE => { F1 => 'affe',
                                                       F2 => 'tiger',
                                                       F3 => 'fink',
                                                       F4 => 'star',
                                                     },
                                              FFF => 'interesting value' }
                                 },
                                 { 'DDD' => { EEE => { F1 => 'bla',
                                                       F2 => 'bli',
                                                       F3 => 'blu',
                                                       F4 => 'blo',
                                                     },
                                              FFF => 'boring value' }
                                 },
                                 { 'DDD' => { EEE => { F1 => 'xbla',
                                                       F2 => 'xbli',
                                                       F3 => 'xblu',
                                                       F4 => 'xblo',
                                                     },
                                              FFF => 'third value' }
                                 },
                                 { 'DDD' => { EEE => { F1 => 'ybla',
                                                       F2 => 'ybli',
                                                       F3 => 'yblu',
                                                       F4 => 'yblo',
                                                     },
                                              FFF => 'fourth value' }
                                 },
                                ],
             };

# ------------------------------

$resultlist = $data3 ~~ dpath '/neighbourhoods/*[0]/DDD/FFF';
# ( 'interesting value' )
cmp_bag($resultlist, [ 'interesting value' ], "ROOT + KEYs + FILTER int 0 + KEYs" );

$resultlist = $data3 ~~ dpath '/*[key =~ m(neighbourhoods)]/*[0]/DDD/FFF';
# ( 'interesting value' )
cmp_bag($resultlist, [ 'interesting value' ], "ROOT + KEYs + FILTER eval key matches m() + FILTER int 0 + KEYs" );

$resultlist = $data3 ~~ dpath '/*[key eq "neighbourhoods"]/*[0]/DDD/FFF';
# ( 'interesting value' )
cmp_bag($resultlist, [ 'interesting value' ], "ROOT + ANYSTEP + FILTER eval + FILTER int" );
# filters on ANY
$resultlist = $data3 ~~ dpath '/*[key =~ m(neigh.*hoods)]/*[0]/DDD/FFF';
# ( 'interesting value' )
cmp_bag($resultlist, [ 'interesting value' ], "ROOT + ANYSTEP + FILTER eval + FILTER int" );

$resultlist = $data3 ~~ dpath '/*[key =~ /neigh.*hoods/]/*[0]/DDD/FFF';
# ( 'interesting value' )
cmp_bag($resultlist, [ 'interesting value' ], "ROOT + ANYSTEP + FILTER eval with slash + FILTER int" );

