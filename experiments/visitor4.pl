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

# say "Find all the plain values ...";
# $v = Data::Visitor::Callback->new(value     => sub { say " VALUE: $_" });
# $v->visit( $data );

say "Find all hash/array refs ...";

# $v = Data::Visitor::Callback->new(
#                                   ignore_return_values => 1,
#                                   ref => sub { say " REF_VALUE: ".Dumper($_) }
#                                  );
# $v->visit( $data );

# my @results1;
# $v = Data::Visitor::Callback->new(
#                                   #ignore_return_values => 1,
#                                   ref => sub {
#                                               my ( $visitor, $data ) = @_;
#                                               push @results1, $data
#                                              }
#                                  );
# $v->visit( $data2 );
# print "results1: ".Dumper(\@results1);

sub any {
        my ($out, $in) = @_;

        $in //= [];
        return @$out unless @$in;

        my @results2;
        my @outrefs;

        foreach my $v (@$in) {
                my @values;
                given (ref $v) {
                        when ('HASH')  { @values = values %$v }
                        when ('ARRAY') { @values = @$v        }
                        default { next }
                }
                push @outrefs, grep { ref =~ /^HASH|ARRAY$/ } @values;
                foreach (@values) {
                        $v = Data::Visitor::Callback->new(
                                                          ref => sub {
                                                                      my ( $visitor, $data ) = @_;
                                                                      push @results2, $data
                                                                     }
                                                         );
                        $v->visit( $_ );
                }
        }
        push @$out,  @outrefs;
        return any ($out, \@results2);
}

# ----------

my @results2;
@results2 = any([], [ $data ]);
print "results2: ".Dumper(\@results2);
say "count: ".scalar(@results2);

# ----------

my $data2  = [
              "AAA",
              { BBB   => { CCC  => [ qw/ XXX YYY ZZZ / ] } },
             ];
@results2 = any([], [ $data2 ]);
print "results2: ".Dumper(\@results2);
say "count: ".scalar(@results2);

