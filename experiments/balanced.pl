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

# not allowed:
#   * quoting the filter:
#     - wrong:   /"EEE3""[isa() eq \"Zomtec\"]"/
#     - correct: /"EEE3"[isa() eq "Zomtec"]/

my $text = '//A1/A2/A3/AAA/"BB BB"/"CC CC"["foo bar"]/"DD / DD"/EEE[ isa() eq "Foo::Bar" ]/"\"EE E2\""[ "\"affe\"" eq "Foo2::Bar2" ]/"\"FFF\""/"GGG[foo == bar]"/*/*[2]/XXX/YYY/ZZZ';

my ($extracted, $remainder);
my @parts;
my @cleaned_parts;

say $text;
say Dumper($text);

say "-"x 60, "extract_delimited";

($extracted, $remainder) = ('unused', $text);
while ($extracted and $remainder) {
        ($extracted, $remainder) = extract_delimited($remainder,'/');
        if (not defined $extracted and defined $remainder) {
                $extracted = $remainder;
                $remainder = undef;
        } else {
                $remainder = (chop $extracted) . $remainder if defined $extracted;
        }
        my $plain_part;
        my $filter;
	($plain_part) = $extracted =~ /.(.*)/g;

        # completely quoted, take whole inner
        if ($plain_part =~ m/^"(.*)"$/) {
                $plain_part = $1;
        }

        # still starts qith quotes: devide in pathpart and filter
        if ($plain_part =~ m,^", ) { # " )}
                ($plain_part, $filter) = extract_delimited($plain_part,'"[]');
                # if now unbalanced this is a parse or path bug
                # e.g. "DD/DD" still does not work
                $plain_part =~ s/^"(.*)"$/$1/;
        }
        $plain_part =~ s/\\"/"/g if $plain_part;
        print Dumper($extracted, $plain_part);
        print Dumper($filter) if $filter;
        print Dumper($remainder);
        say "";
        #sleep 2;
}

#exit 0;

say "-"x 60, "extract_delimited2 ";

($extracted, $remainder) = ('unused', $text);
while ($extracted and $remainder) {
        ($extracted, $remainder) = extract_delimited($remainder,'"' );  # }'"/]}} ;
        #$remainder = (chop $extracted) . $remainder if defined $extracted;

        say Dumper($extracted, $remainder);
        #sleep 1;
}

say "-"x 60, "gen_delimited_pat";

my $patstring = gen_delimited_pat(q{'"`/}); # '});
say Dumper($patstring);

@parts = $text =~ m/$patstring/g;
say Dumper(\@parts);
say foreach @parts;

# @parts = split /$patstring/g, $text;
# say Dumper(\@parts);
# say foreach @parts;

# say "."x 60, "cleaned_parts";

# @cleaned_parts = map {
#                       $_
#                      } @parts;
# say Dumper(\@cleaned_parts);
# say foreach @cleaned_parts;


# say "-"x 60, "extract_quotelike";

# @parts = extract_quotelike($text);
# say Dumper(\@parts);

