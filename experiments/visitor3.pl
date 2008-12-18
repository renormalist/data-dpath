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

say "Works fine to find all the plain values ...";
$v = Data::Visitor::Callback->new(value     => sub { say " VALUE: $_" });
$v->visit( $data );

say "The following does not work, I expected finding all hash/array refs ...";
$v = Data::Visitor::Callback->new(ref_value => sub { say " REF_VALUE: ".Dumper($_) });
$v->visit( $data );

