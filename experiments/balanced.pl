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

# not that backslashes are already handled special in Perl when it creates that string
# is it ok or tactically wise to allow "BB2 BB2" without quoting?
my $text = '//A1/A2/A3/AAA/"BB BB"/BB2 BB2/"CC CC"["foo bar"]/"DD / DD"/"DD2\DD2"/EEE[ isa() eq "Foo::Bar" ]/"\"EE E2\""[ "\"affe\"" eq "Foo2::Bar2" ]/"\"EE E3\"[1]"/"\"EE E4\""[1]/"\"EE\E5\\\\\\""[1]/"\"FFF\""/"GGG[foo == bar]"/*/*[2]/XXX/YYY/ZZZ';
# my $text = '//A1/A2/A3/AAA/"BB BB"/BB2 BB2/"CC CC"["foo bar"]/"DD / DD"/EEE[ isa() eq "Foo::Bar" ]/"\"EE E2\""[ "\"affe\"" eq "Foo2::Bar2" ]/"\"EE E3\"[1]"/"\"EE E4\""[1]/"\"EE\E5';
# $text .= '\\';
# $text .= '\"';
# $text .= '"[1]/"\"FFF\""/"GGG[foo == bar]"/*/*[2]/XXX/YYY/ZZZ';
say $text;

my ($extracted, $remainder);
my @parts;
my @cleaned_parts;

say $text;
say Dumper($text);

say "-"x 60, "extract_delimited";

sub part_and_filter {
        my $part = shift;

        my $plain_part;
        my $filter;

        # ignore leading slash
	($plain_part) = $part =~ /^.(.*)$/g;

        # divide part from filter
        ($plain_part, $filter) = $plain_part =~ m/^(.*?)(\[.*\])$/g if $plain_part =~ m/\[/;

        # unescape quotes
        $plain_part =~ s/(?<!\\)\\"/"/g    if $plain_part;
        #$plain_part =~ s/\\"/"/g    if $plain_part;

        # unescape escapes
        $plain_part =~ s/\\{2}/\\/g if $plain_part;

        return ($plain_part, $filter);
}

my @steps = ();

($extracted, $remainder) = ('unused', $text);
while ($extracted and $remainder) {

        my ($plain_part, $filter);

        if ($remainder =~ m,^/",)                             # " fix highlighting
        {
                # --- handle quoted paths ---

                # single step, first the quoted part, then the filter

                my $extracted2;

                $extracted = '/';
                $remainder =~ s/^.//g;
                ($extracted2, $remainder) = extract_delimited($remainder,'"');
                $extracted .= $extracted2;

                # plain part
                ($plain_part) = $extracted =~ /."?(.*?)"?$/g;
                #($plain_part)  = $extracted =~ /.(.*)/g;    # plain part
                #$plain_part    = $1 if $plain_part =~ m/^"(.*)"$/;  # completely quoted, take whole inner

                # extract filter
                if ($remainder =~ /^\[/) {
                        ($extracted2, $remainder) = extract_bracketed($remainder);
                        $filter = $extracted2;
                }

                # unescape quotes
                $plain_part =~ s/(?<!\\)\\"/"/g    if $plain_part;
                #$plain_part =~ s/\\"/"/g    if $plain_part;
                # unescape escapes
                $plain_part =~ s/\\{2}/\\/g        if $plain_part;

                my $step = { part => $plain_part, filter => $filter};
                push @steps, $step;
                say "* ".Dumper($step, $remainder);
                next;
        }
        else {

                # --- handle unquoted paths ---

                ($extracted, $remainder) = extract_delimited($remainder,'/');

                if (not defined $extracted and defined $remainder)
                {
                        # the last path part
                        $extracted = $remainder;
                        $remainder = undef;
                }
                else
                {
                        # put back the closing '/' on extracted in front of the remainder
                        $remainder = (chop $extracted) . $remainder ;
                }

                ($plain_part, $filter) = part_and_filter($extracted);

                my $step = { part => $plain_part, filter => $filter};
                push @steps, $step;
                say "+ ".Dumper($step, $remainder);
                #sleep 2;
        }
}

say  $text;
say foreach map { ($_->{part} || '')."                        ".($_->{filter}||'') } @steps;
