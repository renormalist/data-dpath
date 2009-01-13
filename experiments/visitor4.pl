#! /usr/bin/env perl

use 5.010;
use strict;
use warnings;

use Data::Dumper;
use Data::Visitor::Callback;

my $v;
my $data  = {
             AAA  => { BBB   => { CCC  => [ qw/ XXX YYY ZZZ / ] } },
             some => { where => { else => {
                                           AAA => { BBB => { CCC => 'affe' } },
                                          } } },
             strange_keys => { 'DD DD' => { 'EE/E' => { CCC => 'zomtec' } } },
             foo => { 'bar' => { 'baz' => { brueller => [ qw/affe tiger fink star/] } } },
            };

say "Find all hash/array refs ...";

# only finds "inner" values; if you need the outer start value
# then just wrap it into array brackets.
sub any {
        my ($out, $in) = @_;

        $in //= [];
        return @$out unless @$in;

        my @newin;
        my @newout;

        foreach my $v (@$in) {
                my @values;
                given (ref $v) {
                        when ('HASH')  { @values = values %$v }
                        when ('ARRAY') { @values = @$v        }
                        default { next }
                }
                push @newout,
                    # $v is the parent of @newout
                    map {
                         # new Data::DPath::Point( ref => \$_, parent => $v )
                         $_
                        }
                        grep {
                                ref =~ /^HASH|ARRAY$/
                        } @values;

                foreach (@values) {
                        $v = new Data::Visitor::Callback(
                                                         ref => sub {
                                                                     my ( $visitor, $data ) = @_;
                                                                     push @newin, $data
                                                                    }
                                                        );
                        $v->visit( $_ );
                }
        }
        push @$out,  @newout;
        return any ($out, \@newin);
}

# ----------

my @results2;
@results2 = any([], [ [ $data ] ]);
print "results2: ".Dumper(\@results2);
say "count: ".scalar(@results2);

# ----------

# my $data2  = [
#               "AAA",
#               { BBB   => { CCC  => [ qw/ XXX YYY ZZZ / ] } },
#              ];
# @results2 = any([], [ $data2 ]);
# print "results2: ".Dumper(\@results2);
# say "count: ".scalar(@results2);

