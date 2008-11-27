#! /usr/bin/env perl

use 5.010;
use strict;
use warnings;

use Data::Dumper::Simple;
use Text::Balanced qw (
                              extract_delimited
                              extract_bracketed
                              extract_quotelike
                              extract_codeblock
                              extract_variable
                              extract_tagged
                              extract_multiple
                              gen_delimited_pat
                              gen_extract_tagged
                     );

my $text = '/AAA/"BB BB"/"CC CC"["foo bar"]/"DD/DD"/EEE[ ref eq "Foo::Bar"]/FFF';
my ($extracted, $remainder);

say $text;
say Dumper($text);

say "-"x 60, "extract_delimited";

($extracted, $remainder) = ('unused', $text);
while ($extracted and $remainder) {
        ($extracted, $remainder) = extract_delimited($remainder,'/');
        $remainder = (chop $extracted) . $remainder if defined $extracted;

        say Dumper($extracted, $remainder);
        #sleep 1;
}

say "-"x 60, "extract_quotelike";

($extracted, $remainder) = ('unused', $text);
while ($extracted and $remainder) {
        ($extracted, $remainder) = extract_quotelike($remainder,'/');
        $remainder = (chop $extracted) . $remainder if defined $extracted;

        say Dumper($extracted, $remainder);
        #sleep 1;
}

say "-"x 60, "gen_delimited_pat";

my $patstring = gen_delimited_pat(q{'"`/}); # '});
say Dumper($patstring);

my @parts;
@parts = $text =~ m/$patstring/g;
say Dumper(\@parts);
say foreach @parts;
