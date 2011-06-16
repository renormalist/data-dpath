#! /usr/bin/env perl

use strict;
use warnings;

use Test::More;
use Test::Deep;
use Data::DPath 'dpath';
use Data::Dumper;

# local $Data::DPath::DEBUG = 1;

BEGIN {
        if ($] < 5.010) {
                plan skip_all => "Perl 5.010 required for the smartmatch overloaded tests. This is ".$];
        }
}

use feature 'say';

my $data = {
    aList => [qw/aa bb cc dd ee ff gg hh ii jj/],
    aHash => {
        apple  => 'pie',
        banana => 'split',
        potato => [qw(baked chips fries fish&chips mashed)],
    },
};

diag 'hash address: ' . $data->{aHash};
# local $Data::DPath::USE_SAFE;
# my $res = $data ~~ dpath '//*[ no warnings; if (value =~ /i/) { print "("; print value;  print ")\n" } value =~ /i/ ]';
my $res = $data ~~ dpath '//*[ value =~ /i/ ]';
my $expected = [ qw/split pie ii chips fries fish&chips/ ];
unlike ($data->{aHash}, qr/i/, "aHash does not match the regex");
cmp_deeply($res, $expected, "elements with letter 'i' but not aHash");
diag "res      = ".Dumper($res);
diag "expected = ".Dumper($expected);

done_testing;
