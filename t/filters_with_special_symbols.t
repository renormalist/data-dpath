#! /usr/bin/env perl

use strict;
use warnings;

use Test::More 0.88 tests => 28;
use Data::DPath 'dpath';

my @fields = (
    'simpleFild',                'fieldWithBackSlash\\',
    '\'fieldWithQoute\'',        ']fieldWithSquareBrackets[',
    '[fieldWithSquareBrackets]', '"fieldWithDoubleQoute"',
    'fieldWithSlash/',
);

my $value = 'aaa[bbb/ccc]ddd"eee\'fff';

my $data = {map {$_ => $value} @fields};

my $FIXTURES = [
    {
        path   => q!/simpleFild[value eq 'aaa[bbb/ccc]ddd"eee\'fff']!,
        result => $value,
    },
    {
        path   => q!/simpleFild[value eq "aaa[bbb/ccc]ddd\"eee'fff"]!,
        result => $value,
    },
    {
        path   => q!/fieldWithBackSlash\\[value eq 'aaa[bbb/ccc]ddd"eee\'fff']!,
        result => $value,
    },
    {
        path   => q!/fieldWithBackSlash\\[value eq "aaa[bbb/ccc]ddd\"eee'fff"]!,
        result => $value,
    },
    {
        path   => q!/'fieldWithQoute'[value eq 'aaa[bbb/ccc]ddd"eee\'fff']!,
        result => $value,
    },
    {
        path   => q!/'fieldWithQoute'[value eq "aaa[bbb/ccc]ddd\"eee'fff"]!,
        result => $value,
    },
    #
    # If the key contains square brackets, slash or double quotes, it must be enclosed in double quotes.
    #
    {
        path   => q!/"]fieldWithSquareBrackets["[value eq 'aaa[bbb/ccc]ddd"eee\'fff']!,
        result => $value,
    },
    {
        path   => q!/"]fieldWithSquareBrackets["[value eq "aaa[bbb/ccc]ddd\"eee'fff"]!,
        result => $value,
    },
    {
        path   => q!/"[fieldWithSquareBrackets]"[value eq 'aaa[bbb/ccc]ddd"eee\'fff']!,
        result => $value,
    },
    {
        path   => q!/"[fieldWithSquareBrackets]"[value eq "aaa[bbb/ccc]ddd\"eee'fff"]!,
        result => $value,
    },
    {
        path   => q!/"\"fieldWithDoubleQoute\""[value eq 'aaa[bbb/ccc]ddd"eee\'fff']!,
        result => $value,
    },
    {
        path   => q!/"\"fieldWithDoubleQoute\""[value eq "aaa[bbb/ccc]ddd\"eee'fff"]!,
        result => $value,
    },
    {
        path   => q!/"fieldWithSlash/"[value eq 'aaa[bbb/ccc]ddd"eee\'fff']!,
        result => $value,
    },
    {
        path   => q!/"fieldWithSlash/"[value eq "aaa[bbb/ccc]ddd\"eee'fff"]!,
        result => $value,
    },
];

foreach my $test (@$FIXTURES) {
    my @result = dpath($test->{'path'})->match($data);

    ok(@result == 1);
    is($result[0], $test->{'result'}, $test->{'path'});
}
