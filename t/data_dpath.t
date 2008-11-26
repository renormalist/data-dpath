#! /usr/bin/env perl

use 5.010;
use strict;
use warnings;
use Test::More tests => 8;


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

@resultlist = dpath('/')->match($data);
is_deeply(\@resultlist, [ $data ], "ROOT" );

@resultlist = dpath('/AAA/*/CCC')->match($data);
is_deeply(\@resultlist, [ ['XXX', 'YYY', 'ZZZ'], [ 'RR1', 'RR2', 'RR3' ] ], "KEYs + ANY" );

# repeated, via intermediate Context
@resultlist = dpath('/AAA/*/CCC')->match($data);
is_deeply(\@resultlist, [ ['XXX', 'YYY', 'ZZZ'], [ 'RR1', 'RR2', 'RR3' ] ], "KEYs + ANY" );

TODO: {
        local $TODO = 'work in progress';
        @resultlist = dpath('//AAA/*/CCC')->match($data);
        is_deeply(\@resultlist, [ ['XXX', 'YYY', 'ZZZ'], 'affe' ], "ANYWHERE + KEYs + ANY" );
}

exit 0;

TODO: {

        local $TODO = 'spec only';

        my $dpath = dpath('//AAA/*/CCC');

        # classic calls
        @resultlist = $dpath->match($data);
        @resultlist = Data::DPath->match($data, '//AAA/*/CCC');
        # ( ['XXX', 'YYY', 'ZZZ'], 'affe' )
        is_deeply(\@resultlist, [ ['XXX', 'YYY', 'ZZZ'], 'affe' ] );

        # via Perl 5.10 smart matching

        @resultlist = $data ~~ $dpath;
        @resultlist = $data ~~ dpath('//AAA/*/CCC');
        @resultlist = $data ~~ dpath '//AAA/*/CCC';
        # ( ['XXX', 'YYY', 'ZZZ'], 'affe' )
        is_deeply(\@resultlist, [ ['XXX', 'YYY', 'ZZZ'], 'affe' ]);

        # filter
        @resultlist = $data ~~ dpath '//AAA/*/CCC[$#_ == 2]'; # array with 3 elements (last index is 2)
        @resultlist = $data ~~ dpath '//AAA/*/CCC[@_  == 3]'; # array with 3 elements
        # same as
        @resultlist = $data ~~ dpath '//AAA/*/CCC/[$#_ == 2]';
        @resultlist = $data ~~ dpath '//AAA/*/CCC/[@_  == 3]';
        # ( ['XXX', 'YYY', 'ZZZ'] )
        is_deeply(\@resultlist, [ ['XXX', 'YYY', 'ZZZ'] ] );


        @resultlist = $data ~~ dpath '//AAA/*/CCC/*';
        # ( 'XXX', 'YYY', 'ZZZ', 'affe' )
        is_deeply(\@resultlist, [ 'XXX', 'YYY', 'ZZZ', 'affe'] );

        @resultlist = $data ~~ dpath '/AAA/*/CCC/*';
        # ( 'XXX', 'YYY', 'ZZZ' )
        is_deeply(\@resultlist, [ 'XXX', 'YYY', 'ZZZ' ] );

        @resultlist = $data ~~ dpath '/AAA/*/CCC/* | /some/where/else/AAA/BBB/CCC';
        # ( 'XXX', 'YYY', 'ZZZ', 'affe' )
        is_deeply(\@resultlist, [ 'XXX', 'YYY', 'ZZZ', 'affe' ] );

        @resultlist = $data ~~ dpath '/AAA/*/CCC/*[2]';
        # ( 'ZZZ' )
        is_deeply(\@resultlist, [ 'ZZZ' ] );

        @resultlist = $data ~~ dpath '//AAA/*/CCC/*[2]';
        # ( 'ZZZ' )
        is_deeply(\@resultlist, [ 'ZZZ' ] );

        @resultlist = $data ~~ dpath '/strange_keys/DD DD/"EE/E"/CCC';
        @resultlist = $data ~~ dpath '/strange_keys/"DD DD"/"EE/E"/CCC';
        # ( 'zomtec' )
        is_deeply(\@resultlist, [ 'zomtec' ] );

        # context objects for incremental searches
        $context = Data::DPath->get_context($data, '//AAA/*/CCC');
        $context->all();
        # ( ['XXX', 'YYY', 'ZZZ'], 'affe' )
        is_deeply(\@resultlist, [ ['XXX', 'YYY', 'ZZZ'], 'affe' ] );

        # is '*/..[0]' the same as ''?
        $context = Data::DPath->get_context($data, '//AAA/*/..[0]/CCC');
        $context->all();
        # ( ['XXX', 'YYY', 'ZZZ'], 'affe' )
        is_deeply(\@resultlist, [ ['XXX', 'YYY', 'ZZZ'], 'affe' ] );

        # dpath inside context, same as: Data::DPath->match($data, '//AAA/*/CCC/*[2]')
        $context->search('/*[2]');
        $context ~~ dpath '/*[2]';
        # ( 'ZZZ' )
        is_deeply(\@resultlist, [ 'ZZZ' ] );

        # ----------------------------------------

        my $data2 = [
                     'UUU',
                     'VVV',
                     'WWW',
                     {
                      AAA  => { BBB   => { CCC  => [ qw/ XXX YYY ZZZ / ] } } },
                    ];

        @resultlist = $data2 ~~ dpath '/*'; # /*
        # ( 'UUU', 'VVV', 'WWW', { AAA  => { BBB   => { CCC  => [ qw/ XXX YYY ZZZ / ] } } } )
        is_deeply(\@resultlist, [ 'UUU', 'VVV', 'WWW', { AAA  => { BBB   => { CCC  => [ qw/ XXX YYY ZZZ / ] } } } ] );

        @resultlist = $data2 ~~ dpath '/';
        is_deeply(\@resultlist, $data2, "root" );

        @resultlist = $data2 ~~ dpath '/*[2]';
        # ( 'WWW' )
        is_deeply(\@resultlist, [ 'WWW' ] );

        @resultlist = $data2 ~~ dpath '//*[2]';
        # ( 'WWW', 'ZZZ' )
        is_deeply(\@resultlist, [ 'WWW', 'ZZZ' ] );

        @resultlist = $data2 ~~ dpath '/*[3]';
        # ( { AAA  => { BBB   => { CCC  => [ qw/ XXX YYY ZZZ / ] } } } )
        is_deeply(\@resultlist, [ { AAA  => { BBB   => { CCC  => [ qw/ XXX YYY ZZZ / ] } } } ] );

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

        @resultlist = $data3 ~~ dpath '//AAA/BBB[ref($_) eq "Foo::Bar"]/CCC';
        # ( ['XXX', 'YYY', 'ZZZ'] )
        is_deeply(\@resultlist, [ ['XXX', 'YYY', 'ZZZ'] ] );

        # parent step
        @resultlist = $data3 ~~ dpath '//DDD/EEE/F1[$_ eq "affe"]/../FFF'; # the DDD/FFF where the neighbor DDD/EEE/F1 == "affe"
        # ( 'interesting value' )
        is_deeply(\@resultlist, [ 'interesting value' ] );

        # filter expressions can directly or indirectly follow a step (without or with slash), so this is the same
        @resultlist = $data3 ~~ dpath '//DDD/EEE/F1/[$_ eq "affe"]/../FFF';
        # ( 'interesting value' )
        is_deeply(\@resultlist, [ 'interesting value' ] );

        # same via direct access
        @resultlist = $data3 ~~ dpath '/neighbourhoods/*[0]/DDD/FFF';
        # ( 'interesting value' )
        is_deeply(\@resultlist, [ 'interesting value' ] );

}
