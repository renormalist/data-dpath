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

say "Find all the plain values ...";
$v = Data::Visitor::Callback->new(value     => sub { say " VALUE: $_" });
$v->visit( $data );

say "Find all hash/array refs ...";
$v = Data::Visitor::Callback->new(
                                  ignore_return_values => 1,
                                  ref => sub { say " REF_VALUE: ".Dumper($_) }
                                 );
$v->visit( $data );

my @results;
$v = Data::Visitor::Callback->new(
                                  ignore_return_values => 1,
                                  ref => sub {
                                              my ( $visitor, $data ) = @_;
                                              push @results, $data
                                             }
                                 );
$v->visit( $data );
print "results: ".Dumper(\@results);
