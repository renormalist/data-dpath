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

sub part_and_filter {
        my $extracted = shift;

        my $plain_part;
        my $filter;
	($plain_part) = $extracted =~ /.(.*)/g;

        # completely quoted, take whole inner
        if ($plain_part =~ m/^"(.*)"$/) {
                $plain_part = $1;
        }

        # still starts with quotes: devide in pathpart and filter
        if ($plain_part =~ m,^", ) { # " )}
                ($plain_part, $filter) = extract_delimited($plain_part,'"[]');
                # if now unbalanced this is a parse or path bug
                # e.g. "DD/DD" still does not work
                $plain_part =~ s/^"(.*)"$/$1/;
        }
        $plain_part =~ s/\\"/"/g if $plain_part;

        return ($plain_part, $filter);
}

my @steps = ();

($extracted, $remainder) = ('unused', $text);
while ($extracted and $remainder) {

        # --- handle quoted paths ---
        if ($remainder =~ m,^/",) {                                    # "
                #say "____QUOTED: ".Dumper($remainder);
                $extracted = '/';
                $remainder =~ s/^.//g;
                #say "a___".Dumper($extracted, $remainder);
                my $extracted2;
                ($extracted2, $remainder) = extract_delimited($remainder,'"');
                $extracted .= $extracted2; # == part
                #say "--- ".Dumper($remainder);
                my ($plain_part, $filter);

                # plain part
                ($plain_part) = $extracted =~ /.(.*)/g;
                # completely quoted, take whole inner
                if ($plain_part =~ m/^"(.*)"$/) {
                        $plain_part = $1;
                }


                if ($remainder =~ m,^\[,) {                                    # "
                        #say "--- extract bracketed: $remainder";
                        ($extracted2, $remainder) = extract_bracketed($remainder);
                        $filter = $extracted2;
                        #say "--- filter: $filter";
                }
                #say "b___".Dumper($extracted, $extracted2, $remainder);
                #say "next";

                #my ($plain_part, $filter) = part_and_filter($extracted);

                my $step = { part => $plain_part, filter => $filter};
                push @steps, $step;
                say "* ".Dumper($step, $remainder);
                next;
        }

        # handle normal paths

        ($extracted, $remainder) = extract_delimited($remainder,'/');
        #say " remainder: $remainder";
        if (not defined $extracted and defined $remainder) {
                $extracted = $remainder;
                $remainder = undef;
        } else {
                #if ($remainder =~ m,^/,) {
                $remainder = (chop $extracted) . $remainder ;
                #}
        }

        my ($plain_part, $filter) = part_and_filter($extracted);
        #         print Dumper($extracted, $plain_part);
        #         print Dumper($filter) if $filter;
        #         print Dumper($remainder);
        my $step = { part => $plain_part, filter => $filter};
        push @steps, $step;
        say "+ ".Dumper($step, $remainder);
        #sleep 2;
}

print <<EOL;

______________________________________________________________________
TODO: missing filter split on non-quoted keys
-----
+ \$step = {
          'filter' => undef,
          'part' => 'EEE[ isa() eq "Foo::Bar" ]'
        };

EOL

exit 0;

# say "-"x 60, "extract_delimited2 ";

# ($extracted, $remainder) = ('unused', $text);
# while ($extracted and $remainder) {
#         ($extracted, $remainder) = extract_delimited($remainder,'"' );  # }'"/]}} ;
#         #$remainder = (chop $extracted) . $remainder if defined $extracted;

#         say Dumper($extracted, $remainder);
#         #sleep 1;
# }

say "-"x 60, "tokenizer";

($extracted, $remainder) = ('unused', $text);
while ($extracted and $remainder) {

        ($extracted, $remainder) = extract_delimited($remainder,'/');
        say Dumper($remainder);

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

exit 0;

say "-"x 60, "gen_delimited_pat";

my $patstring = gen_delimited_pat(q{'"`/}); # '});
say Dumper($patstring);

$remainder = $text;
$remainder .= '/' unless $remainder =~ m,/$,;
say Dumper($remainder);
my $part;

# ----------

say "-"x 60, "tokenizer";

($extracted, $remainder) = ('unused',
                            '/BBB/"CC CC"["foo bar"]/"DD / DD"/EEE[ isa() eq "Foo::Bar" ]/ZZZ');
say Dumper($remainder);
while ($extracted and $remainder) {

        #say "____: ".Dumper($remainder);
        if ($remainder =~ m,^/",) {                                    # "
                say "____QUOTED TOKEN AHEAD: ".Dumper($remainder);
                $extracted = '/';
                $remainder =~ s/^.//g;
                #say "a___".Dumper($extracted, $remainder);
                my $extracted2;
                ($extracted2, $remainder) = extract_delimited($remainder,'"');
                $extracted .= $extracted2; # == part
                if ($remainder =~ m,^\[",) {                                    # "
                        ($extracted2, $remainder) = extract_bracketed($remainder);
                }
                #say "b___".Dumper($extracted, $extracted2, $remainder);
                #say "next";
                next;
        }


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
#         $extracted = $1 if ($remainder =~ s/($patstring)(?<rest>.*)/$+{rest}/);

#         if (not defined $extracted and defined $remainder) {
#                 $extracted = $remainder;
#                 $remainder = undef;
#         } else {
#                 $remainder = (chop $extracted) . $remainder if defined $extracted;
#         }
#         say Dumper($extracted, $remainder);
#         say "";
#         say "";
#         say "";
}
