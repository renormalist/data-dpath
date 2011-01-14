#! /usr/bin/env perl

use strict;
use warnings;
use Test::More;
use Data::DPath 'dpath';
use Data::Dumper;
use Benchmark ':all', ':hireswallclock';
use Devel::Size 'total_size';
use TAP::DOM;

BEGIN {
        print "TAP Version 13\n";
        plan tests => 3;
	use_ok( 'Data::DPath' );
}

my $tap;
{
        local $/;
        open (TAP, "< xt/regexp-common.tap") or die "Cannot read xt/regexp-common.tap";
        $tap = <TAP>;
        close TAP;
}

local $Data::DPath::USE_SAFE;

my $path          = '//is_has[ value & $TAP::DOM::HAS_TODO & $TAP::DOM::IS_ACTUAL_OK ]/..';
#my $path          = '//is_has[ print(((value & $TAP::DOM::IS_ACTUAL_OK) ? "1" : "0")."\n") ; value & $TAP::DOM::HAS_TODO & $TAP::DOM::IS_ACTUAL_OK ]/..';
#my $path          = qq|//is_has[ print(((value & $IS_ACTUAL_OK) ? "1" : "0")."\n") ; value & $HAS_TODO & $IS_ACTUAL_OK ]/..|;
#my $path          = '//is_has[ print value."\n" ]/..';
#my $expected      = "2";

foreach my $usebitsets (0..1) {
        my $huge_data = TAP::DOM->new( tap => $tap, usebitsets => $usebitsets );

        my $resultlist;

        diag "Running benchmark. Can take some time ...";
        my $count = 1;
        my $t = timeit ($count, sub { $resultlist = [ dpath($path)->match($huge_data) ] });
        my $n = $t->[5];
        my $throughput = $n / $t->[0];
        diag Dumper($resultlist);
        ok(1, "benchmark -- usebitsets = $usebitsets");
        print "  ---\n";
        print "  benchmark:\n";
        print "    timestr:    ".timestr($t), "\n";
        print "    wallclock:  $t->[0]\n";
        print "    usr:        $t->[1]\n";
        print "    sys:        $t->[2]\n";
        print "    throughput: $throughput\n";
        print "  ...\n";
}

done_testing;
