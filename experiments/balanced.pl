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
my $text = '//A1/A2/A3/AAA/"BB BB"/BB2 BB2/"CC CC"["foo bar"]/"DD / DD"/"DD2\DD2"//EEE[ isa() eq "Foo::Bar" ]/"\"EE E2\""[ "\"affe\"" eq "Foo2::Bar2" ]/"\"EE E3\"[1]"/"\"EE E4\""[1]/"\"EE\E5\\\\\\""[1]/"\"FFF\""/"GGG[foo == bar]"/*/*[2]/XXX/YYY/ZZZ';
# my $text = '//A1/A2/A3/AAA/"BB BB"/BB2 BB2/"CC CC"["foo bar"]/"DD / DD"/EEE[ isa() eq "Foo::Bar" ]/"\"EE E2\""[ "\"affe\"" eq "Foo2::Bar2" ]/"\"EE E3\"[1]"/"\"EE E4\""[1]/"\"EE\E5';
# $text .= '\\';
# $text .= '\"';
# $text .= '"[1]/"\"FFF\""/"GGG[foo == bar]"/*/*[2]/XXX/YYY/ZZZ';
#say $text;

my ($extracted, $remainder);
my @parts;
my @cleaned_parts;

# say $text;
# say Dumper($text);

#say "-"x 60, "extract_delimited";

sub unescaped {
        my ($str) = @_;

        return unless defined $str;
        $str =~ s/(?<!\\)\\"/"/g;
        $str =~ s/\\{2}/\\/g;
        return $str;
}
sub unquoted {
        my ($str) = @_;
        $str =~ s/^"(.*)"$/$1/g;
        return $str;
}

sub quoted { shift =~ m,^/",; }

sub path_to_steps {
        my ($remaining_path) = @_;

        my @steps;
        my $extracted;

        while ($remaining_path)
        {
                my ($plain_part, $filter);
                given ($remaining_path)
                {
                        when ( \&quoted ) {
                                ($plain_part, $remaining_path) = extract_delimited($remaining_path,'"', "/");
                                ($filter,     $remaining_path) = extract_bracketed($remaining_path);
                                $plain_part                    = unescaped unquoted $plain_part;
                                push @steps, {
                                              part   => $plain_part,
                                              filter => $filter
                                             };
                        }
                        default {
                                ($extracted, $remaining_path) = extract_delimited($remaining_path,'/');

                                if (not $extracted) {
                                        ($extracted, $remaining_path) = ($remaining_path, undef); # END OF PATH
                                } else {
                                        $remaining_path = (chop $extracted) . $remaining_path;
                                }

                                ($plain_part, $filter) = $extracted =~ m,^/              # leading /
                                                                         (.*?)           # path part
                                                                         (\[.*\])?$      # optional filter
                                                                        ,xg;
                                $plain_part = unescaped $plain_part;
                                push @steps, {
                                              part   => $plain_part,
                                              filter => $filter
                                             };
                        }
                }
        }

        say foreach map { ($_->{part} || '<EMPTYSTEP>')."                        ".($_->{filter}||'') } @steps;
        return @steps;
}

say  $text;
path_to_steps($text);
