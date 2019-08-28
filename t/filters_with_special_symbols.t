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
    q!/simpleFild[value eq 'aaa[bbb/ccc]ddd"eee\'fff']!,
    q!/simpleFild[value eq "aaa[bbb/ccc]ddd\"eee'fff"]!,
    q!/fieldWithBackSlash\\[value eq 'aaa[bbb/ccc]ddd"eee\'fff']!,
    q!/fieldWithBackSlash\\[value eq "aaa[bbb/ccc]ddd\"eee'fff"]!,
    q!/'fieldWithQoute'[value eq 'aaa[bbb/ccc]ddd"eee\'fff']!,
    q!/'fieldWithQoute'[value eq "aaa[bbb/ccc]ddd\"eee'fff"]!,
    #
    # If the key contains square brackets, slash or double quotes, it must be enclosed in double quotes.
    #
    q!/"]fieldWithSquareBrackets["[value eq 'aaa[bbb/ccc]ddd"eee\'fff']!,
    q!/"]fieldWithSquareBrackets["[value eq "aaa[bbb/ccc]ddd\"eee'fff"]!,
    q!/"[fieldWithSquareBrackets]"[value eq 'aaa[bbb/ccc]ddd"eee\'fff']!,
    q!/"[fieldWithSquareBrackets]"[value eq "aaa[bbb/ccc]ddd\"eee'fff"]!,
    q!/"\"fieldWithDoubleQoute\""[value eq 'aaa[bbb/ccc]ddd"eee\'fff']!,
    q!/"\"fieldWithDoubleQoute\""[value eq "aaa[bbb/ccc]ddd\"eee'fff"]!,
    q!/"fieldWithSlash/"[value eq 'aaa[bbb/ccc]ddd"eee\'fff']!,
    q!/"fieldWithSlash/"[value eq "aaa[bbb/ccc]ddd\"eee'fff"]!,
];

foreach my $path (@$FIXTURES) {
    my @result = dpath($path)->match($data);

    ok(@result == 1);
    is($result[0], $value, $path);
}
