#! /usr/bin/env perl

use strict;
use warnings;

use Test::More;
use Test::Deep;
use Data::DPath 'dpath';
use Data::Dumper;

# local $Data::DPath::DEBUG = 1;

if ($] < 5.010) {
        plan skip_all => "Perl 5.010 required for the smartmatch overloaded tests. This is ".$];
} else {
        plan tests => 3;
}

use_ok( 'Data::DPath' );

my $datacontent='';
{
        local $/;
        open F, "<", "t/bigdata.dump" or die;
        $datacontent = <F>;
        close F;
}
my $VAR1;
eval $datacontent;
my $data = $VAR1;

my $res;

$res = $data ~~ dpath('/report');
is($res->[0]{reportgroup_testrun_id}, 30862, "simple dpath" );

$res = $data ~~ dpath('//data//benchmark[ value eq "call_simple"]/../mean/..');
cmp_bag($res, [
               {
                'glibc'              => 'glibc, 2.4',
                'count'              => '150',
                'language_series'    => 'arch_barcelona',
                'standard_deviation' => '0.0164822946672',
                'language_binary'    => '/opt/artemis/slbench/python/arch_barcelona/2.7/bin/python',
                'release'            => '2.6.30.10-105.2.23.fc11.x86_64',
                'operating_system'   => 'Linux',
                'hostname'           => 'foo.dept.lhm.com',
                'mean'               => '0.592707689603',
                'median'             => '0.58355140686',
                'architecture'       => '64bit',
                'number_CPUs'        => '16',
                'benchmark'          => 'call_simple',
                'machine'            => 'x86_64'
               }
              ]
        , "very complicated dpath" );
