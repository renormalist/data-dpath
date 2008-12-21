#! /usr/bin/env perl

use 5.010;
use strict;
use warnings;
use Test::More tests => 71;

use Data::DPath 'dpath';

#local $Data::DPath::DEBUG = 1;

BEGIN {
	use_ok( 'Data::DPath' );
}

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
my $resultlist;
my $context;

# trivial matching

@resultlist = dpath('/AAA/BBB/CCC')->match($data);
is_deeply(\@resultlist, [ ['XXX', 'YYY', 'ZZZ'] ], "KEYs" );

@resultlist = dpath('/AAA/BBB/CCC/..')->match($data);
is_deeply(\@resultlist, [ { CCC => ['XXX', 'YYY', 'ZZZ'] } ], "KEYs + PARENT" );

@resultlist = dpath('/AAA/BBB/CCC/../..')->match($data);
is_deeply(\@resultlist, [
                         {
                          BBB => { CCC => ['XXX', 'YYY', 'ZZZ'] },
                          RRR => { CCC  => [ qw/ RR1 RR2 RR3 / ] },
                          DDD => { EEE => [ qw/ uuu vvv www / ] },
                         }
                        ], "KEYs + PARENT + PARENT" );

@resultlist = dpath('/AAA/BBB/CCC/../../DDD')->match($data);
is_deeply(\@resultlist, [ { EEE => [ qw/ uuu vvv www / ] } ], "KEYs + PARENT + KEY" );

@resultlist = dpath('/AAA/*/CCC/../../DDD')->match($data);
is_deeply(\@resultlist, [ { EEE => [ qw/ uuu vvv www / ] } ], "KEYs + ANYSTEP + PARENT + KEY no double results" );

@resultlist = dpath('/')->match($data);
use Data::Dumper;
is_deeply(\@resultlist, [ $data ], "ROOT" );

@resultlist = dpath('/AAA/*/CCC')->match($data);
is_deeply(\@resultlist, [ ['XXX', 'YYY', 'ZZZ'], [ 'RR1', 'RR2', 'RR3' ] ], "KEYs + ANYSTEP" );

# --- same with operator ---

is_deeply(dpath('/AAA/BBB/CCC') ~~ $data,    [ ['XXX', 'YYY', 'ZZZ'] ], "KEYs" );
is_deeply(dpath('/AAA/BBB/CCC/..') ~~ $data, [ { CCC => ['XXX', 'YYY', 'ZZZ'] } ], "KEYs + PARENT" );
is_deeply(dpath('/AAA/BBB/CCC/../..') ~~ $data, [
                                                 {
                                                  BBB => { CCC => ['XXX', 'YYY', 'ZZZ'] },
                                                  RRR => { CCC  => [ qw/ RR1 RR2 RR3 / ] },
                                                  DDD => { EEE => [ qw/ uuu vvv www / ] },
                                                 }
                                                ], "KEYs + PARENT + PARENT" );
is_deeply(dpath('/AAA/BBB/CCC/../../DDD') ~~ $data, [ { EEE => [ qw/ uuu vvv www / ] } ], "KEYs + PARENT + KEY" );
is_deeply(dpath('/AAA/*/CCC/../../DDD') ~~ $data, [ { EEE => [ qw/ uuu vvv www / ] } ], "KEYs + ANYSTEP + PARENT + KEY no double results" );
is_deeply(dpath('/') ~~ $data, [ $data ], "ROOT" );
is_deeply(dpath('/AAA/*/CCC') ~~ $data, [ ['XXX', 'YYY', 'ZZZ'], [ 'RR1', 'RR2', 'RR3' ] ], "KEYs + ANYSTEP" );

# --- ---

# WATCH OUT: the order of results is not defined! tests may be false negatives ...
@resultlist = dpath('//AAA/*/CCC')->match($data);
is_deeply(\@resultlist, [ ['XXX', 'YYY', 'ZZZ'], ['RR1', 'RR2', 'RR3'], 'affe' ], "ANYWHERE + KEYs + ANYSTEP" );
@resultlist = dpath('///AAA/*/CCC')->match($data);
is_deeply(\@resultlist, [ ['XXX', 'YYY', 'ZZZ'], ['RR1', 'RR2', 'RR3'], 'affe' ], "2xANYWHERE + KEYs + ANYSTEP" );


@resultlist = Data::DPath->match($data, '//AAA/*/CCC');
is_deeply(\@resultlist, [ ['XXX', 'YYY', 'ZZZ'], [ 'RR1', 'RR2', 'RR3' ], 'affe' ], "ANYWHERE + KEYs + ANYSTEP as function" );
@resultlist = Data::DPath->match($data, '///AAA/*/CCC');
is_deeply(\@resultlist, [ ['XXX', 'YYY', 'ZZZ'], [ 'RR1', 'RR2', 'RR3' ], 'affe' ], "2xANYWHERE + KEYs + ANYSTEP as function" );

# from now on more via Perl 5.10 smart matching

# --------------------

$resultlist = $data ~~ dpath '/some//CCC';
is_deeply($resultlist, [ 'affe' ], "ROOT + KEY + ANYWHERE + KEY" );

$resultlist = $data ~~ dpath '//some//CCC';
is_deeply($resultlist, [ 'affe' ], "ANYWHERE + KEY + ANYWHERE + KEY" );

$resultlist = $data ~~ dpath '/some//else//CCC';
is_deeply($resultlist, [ 'affe' ], "ROOT + KEY + ANYWHEREs + KEY" );

$resultlist = $data ~~ dpath '//some//else//CCC';
is_deeply($resultlist, [ 'affe' ], "ANYWHERE + KEYs + ANYWHEREs" );

# --------------------

my $dpath = dpath('//AAA/*/CCC');
$resultlist = $data ~~ $dpath;
is_deeply($resultlist, [ ['XXX', 'YYY', 'ZZZ'], [ 'RR1', 'RR2', 'RR3' ], 'affe' ], "ANYWHERE + KEYs + ANYSTEP with smartmatch and variable" );
$resultlist = $data ~~ $dpath;
is_deeply($resultlist, [ ['XXX', 'YYY', 'ZZZ'], [ 'RR1', 'RR2', 'RR3' ], 'affe' ], "2xANYWHERE + KEYs + ANYSTEP with smartmatch and variable" );

$resultlist = $data ~~ dpath('//AAA/*/CCC');
is_deeply($resultlist, [ ['XXX', 'YYY', 'ZZZ'], [ 'RR1', 'RR2', 'RR3' ], 'affe' ], "ANYWHERE + KEYs + ANYSTEP with smartmatch and dpath()" );
$resultlist = $data ~~ dpath('///AAA/*/CCC');
is_deeply($resultlist, [ ['XXX', 'YYY', 'ZZZ'], [ 'RR1', 'RR2', 'RR3' ], 'affe' ], "2xANYWHERE + KEYs + ANYSTEP with smartmatch and dpath()" );

$resultlist = $data ~~ dpath '//AAA/*/CCC';
is_deeply($resultlist, [ ['XXX', 'YYY', 'ZZZ'], [ 'RR1', 'RR2', 'RR3' ], 'affe' ], "ANYWHERE + KEYs + ANYSTEP with smartmatch and dpath without parens" );
$resultlist = $data ~~ dpath '///AAA/*/CCC';
is_deeply($resultlist, [ ['XXX', 'YYY', 'ZZZ'], [ 'RR1', 'RR2', 'RR3' ], 'affe' ], "2xANYWHERE + KEYs + ANYSTEP with smartmatch and dpath without parens" );

$resultlist = dpath '//AAA/*/CCC' ~~ $data;
is_deeply($resultlist, [ ['XXX', 'YYY', 'ZZZ'], [ 'RR1', 'RR2', 'RR3' ], 'affe' ], "ANYWHERE + KEYs + ANYSTEP with smartmatch and dpath without parens commutative" );
$resultlist = dpath '///AAA/*/CCC' ~~ $data;
is_deeply($resultlist, [ ['XXX', 'YYY', 'ZZZ'], [ 'RR1', 'RR2', 'RR3' ], 'affe' ], "2xANYWHERE + KEYs + ANYSTEP with smartmatch and dpath without parens commutative" );

$resultlist = $data ~~ dpath '/AAA/*/CCC/*';
is_deeply($resultlist, [ 'XXX', 'YYY', 'ZZZ', 'RR1', 'RR2', 'RR3' ], "trailing .../* unpacks" );

$resultlist = $data ~~ dpath '/strange_keys/DD DD/"EE/E"/CCC';
$resultlist = $data ~~ dpath '/strange_keys/"DD DD"/"EE/E"/CCC';
is_deeply($resultlist, [ 'zomtec' ], "quoted KEY containg slash" );

TODO: {

        local $TODO = 'spec only';

        # filters

        $resultlist = $data ~~ dpath '//AAA/*/CCC[$#_ == 2]';  # array with 3 elements (last index is 2) # DEPRECATED
        is_deeply($resultlist, [ ['XXX', 'YYY', 'ZZZ'] ] );
        $resultlist = $data ~~ dpath '//AAA/*/CCC[@_  == 3]';  # array with 3 elements                   # DEPRECATED
        is_deeply($resultlist, [ ['XXX', 'YYY', 'ZZZ'] ] );
        $resultlist = $data ~~ dpath '//AAA/*/CCC[size == 3]'; # array with 3 elements                   # OK
        is_deeply($resultlist, [ ['XXX', 'YYY', 'ZZZ'] ] );

        # same?
        $resultlist = $data ~~ dpath '//AAA/*/CCC/[$#_ == 2]';
        is_deeply($resultlist, [ ['XXX', 'YYY', 'ZZZ'] ] );

        $resultlist = $data ~~ dpath '//AAA/*/CCC/[@_  == 3]';
        is_deeply($resultlist, [ ['XXX', 'YYY', 'ZZZ'] ] );

}

$resultlist = $data ~~ dpath '//AAA/*/CCC/*';
is_deeply($resultlist, [ 'XXX', 'YYY', 'ZZZ', 'RR1', 'RR2', 'RR3', 'affe'] );

TODO: {

        local $TODO = 'spec only';

        $resultlist = $data ~~ dpath '/AAA/*/CCC/* | /some/where/else/AAA/BBB/CCC';
        # ( 'XXX', 'YYY', 'ZZZ', 'affe' )
        is_deeply($resultlist, [ 'XXX', 'YYY', 'ZZZ', 'RR1', 'RR2', 'RR3', 'affe' ] );

        $resultlist = $data ~~ dpath '/AAA/*/CCC/*[2]';
        is_deeply($resultlist, [ 'ZZZ', 'RR3' ], "ANYSTEP + FILTER int" );

        $resultlist = $data ~~ dpath '//AAA/*/CCC/*[2]';
        is_deeply($resultlist, [ 'ZZZ', 'RR3' ], "ANYWHERE + ANYSTEP + FILTER int" );

        # ---------- is CCC/*[2] the same as CCC[2] or is it not? DECIDE NOW! ----------
        $resultlist = $data ~~ dpath '/AAA/*/CCC[2]';
        is_deeply($resultlist, [ 'ZZZ', 'RR3' ], "KEY + FILTER int" );

        $resultlist = $data ~~ dpath '//AAA/*/CCC[2]';
        is_deeply($resultlist, [ 'ZZZ', 'RR3' ], "ANYWHERE + KEY + FILTER int" );

}

TODO: {

        local $TODO = 'rethink spec';

        # only allowing to access the first value makes
        # CCC[0] the same as CCC, which seems redundant and useless

        # AHA: current semantic is: the array index refers to all currently collected results.
        #      Is this what we want as useful complement to *[2]?
        #      It would also mean to only be useful at end of path, right?

        $resultlist = $data ~~ dpath '/AAA/*/CCC[0]';
        diag Dumper($resultlist);
        is_deeply($resultlist, [ [ 'XXX', 'YYY', 'ZZZ' ] ], "KEY + FILTER int 0" );

        $resultlist = $data ~~ dpath '/AAA/*/CCC[1]';
        is_deeply($resultlist, [ [ 'RR1', 'RR2', 'RR3' ] ], "KEY + FILTER int 1" );

        $resultlist = $data ~~ dpath '//AAA/*/CCC[0]';
        diag Dumper($resultlist);
        is_deeply($resultlist, [ [ 'XXX', 'YYY', 'ZZZ' ] ], "ANYWHERE + KEY + FILTER int 0" );

        $resultlist = $data ~~ dpath '//AAA/*/CCC[1]';
        diag Dumper($resultlist);
        is_deeply($resultlist, [ [ 'RR1', 'RR2', 'RR3' ] ], "ANYWHERE + KEY + FILTER int 1" );

}

TODO: {

        local $TODO = 'spec only';

        # --------------------

        # context objects for incremental searches
        $context = Data::DPath->get_context($data, '//AAA/*/CCC');
        $resultlist = $context->all();
        # ( ['XXX', 'YYY', 'ZZZ'], 'affe' )
        is_deeply($resultlist, [ ['XXX', 'YYY', 'ZZZ'], ['RR1', 'RR2', 'RR3'], 'affe' ], "context for incremental searches" );

        # is '*/..[0]' the same as ''?
        $context = Data::DPath->get_context($data, '//AAA/*/..[0]/CCC'); # !!??
        $resultlist = $context->all();
        # ( ['XXX', 'YYY', 'ZZZ'], 'affe' )
        is_deeply($resultlist, [ ['XXX', 'YYY', 'ZZZ'], ['RR1', 'RR2', 'RR3'], 'affe' ] );

        # dpath inside context, same as: Data::DPath->match($data, '//AAA/*/CCC/*[2]')
        $resultlist = $context->search(dpath '/*[2]');
        is_deeply($resultlist, [ 'ZZZ' ], "incremental + FILTER int" );

}

# ----------------------------------------



my $data2 = [
             'UUU',
             'VVV',
             'WWW',
             {
              AAA  => { BBB   => { CCC  => [ qw/ XXX YYY ZZZ / ] } } },
            ];

$resultlist = $data2 ~~ dpath '/*'; # /*
is_deeply($resultlist, [ 'UUU', 'VVV', 'WWW', { AAA  => { BBB   => { CCC  => [ qw/ XXX YYY ZZZ / ] } } } ], "ROOT + ANYSTEP" );

$resultlist = $data2 ~~ dpath '/';
is_deeply($resultlist, [ $data2 ], "ROOT" );

$resultlist = $data2 ~~ dpath '//';
is_deeply($resultlist, [ $data2,
                         { AAA  => { BBB   => { CCC  => [ qw/ XXX YYY ZZZ / ] } } },
                         { BBB   => { CCC  => [ qw/ XXX YYY ZZZ / ] } },
                         { CCC  => [ qw/ XXX YYY ZZZ / ] },
                         [ qw/ XXX YYY ZZZ / ]
                       ], "ANYWHERE" );

$resultlist = $data2 ~~ dpath '/*[2]';
is_deeply($resultlist, [ 'WWW' ], "ROOT + ANYSTEP + FILTER int: plain value" );

$resultlist = $data2 ~~ dpath '/*[3]';
# ( { AAA  => { BBB   => { CCC  => [ qw/ XXX YYY ZZZ / ] } } } )
is_deeply($resultlist, [ { AAA  => { BBB   => { CCC  => [ qw/ XXX YYY ZZZ / ] } } } ], "ROOT + ANYSTEP + FILTER int: ref value" );

TODO: {

        local $TODO = 'spec only';

        $resultlist = $data2 ~~ dpath '//*[2]';
        is_deeply($resultlist, [ 'WWW', 'ZZZ' ], "ANYWHERE + ANYSTEP + FILTER int" );

}

# basic eval filters
$resultlist = $data2 ~~ dpath '/*/AAA/BBB/CCC';
is_deeply($resultlist, [ ['XXX', 'YYY', 'ZZZ'] ], "FILTER eval prepare" );
$resultlist = $data2 ~~ dpath '/*/AAA/BBB/CCC[17 == 17]';
is_deeply($resultlist, [ ['XXX', 'YYY', 'ZZZ'] ], "FILTER eval simple true" );
$resultlist = $data2 ~~ dpath '/*/AAA/BBB/CCC[0 == 0]';
is_deeply($resultlist, [ ['XXX', 'YYY', 'ZZZ'] ], "FILTER eval simple true with false values" );
$resultlist = $data2 ~~ dpath '/*/AAA/BBB/CCC["foo" eq "foo"]';
is_deeply($resultlist, [ ['XXX', 'YYY', 'ZZZ'] ], "FILTER eval simple true with strings" );
$resultlist = $data2 ~~ dpath '/*/AAA/BBB/CCC[1 == 2]';
is_deeply($resultlist, [ ], "FILTER eval simple false" );
$resultlist = $data2 ~~ dpath '/*/AAA/BBB/CCC["foo" eq "bar"]';
is_deeply($resultlist, [ ], "FILTER eval simple false with strings" );

# ----------------------------------------

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
                                ],
             };

TODO: {
        local $TODO = 'spec only';

        $resultlist = $data3 ~~ dpath '//AAA/BBB[ref($_) eq "Foo::Bar"]/CCC';
        # ( ['XXX', 'YYY', 'ZZZ'] )
        is_deeply($resultlist, [ ['XXX', 'YYY', 'ZZZ'] ] );

        # parent step
        $resultlist = $data3 ~~ dpath '//DDD/EEE/F1[$_ eq "affe"]/../FFF'; # the DDD/FFF where the neighbor DDD/EEE/F1 == "affe"
        # ( 'interesting value' )
        is_deeply($resultlist, [ 'interesting value' ] );

        # filter expressions can directly or indirectly follow a step (without or with slash), so this is the same
        $resultlist = $data3 ~~ dpath '//DDD/EEE/F1/[$_ eq "affe"]/../FFF';
        # ( 'interesting value' )
        is_deeply($resultlist, [ 'interesting value' ] );

}

$resultlist = $data3 ~~ dpath '/neighbourhoods/*[0]/DDD/FFF';
# ( 'interesting value' )
is_deeply($resultlist, [ 'interesting value' ], "ROOT + KEYs + FILTER int + KEYs" );

$resultlist = $data3 ~~ dpath '//neighbourhoods/*[0]/DDD/FFF';
# ( 'interesting value' )
is_deeply($resultlist, [ 'interesting value' ], "ANYWHERE + KEYs + FILTER int + KEYs" );

TODO: {
        local $TODO = 'spec only';

        # filters on ANY
        $resultlist = $data3 ~~ dpath '/*[key =~ qw(neigh.*hoods)]/*[0]/DDD/FFF';
        # ( 'interesting value' )
        is_deeply($resultlist, [ 'interesting value' ], "ROOT + ANYSTEP + FILTER eval + FILTER int" );

        # filters on ANYWHERE (or is /[...]/ better the same as /*[...]/ ?)
        $resultlist = $data3 ~~ dpath '/[key =~ qw(neigh.*hoods)]/*[0]/DDD/FFF';
        # ( 'interesting value' )
        is_deeply($resultlist, [ 'interesting value' ] );

}

# ----------------------------------------

my $data4  = {
              AAA  => { BBB => { CCC  => [ qw/
                                                     XXX
                                                     YYY
                                                     ZZZ
                                                     XXXX
                                                     YYYY
                                                     ZZZZ
                                             / ] } },
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
                                ],
             };

TODO: {
        local $TODO = 'too dirty, first cleanup _filter_eval';

        $resultlist = $data4 ~~ dpath '//AAA/BBB/CCC/*[ ${$_->{ref}} =~ m(....) ]';
        is_deeply($resultlist, [ 'XXXX', 'YYYY', 'ZZZZ', 'affe' ], "FILTER eval regex" );

}

