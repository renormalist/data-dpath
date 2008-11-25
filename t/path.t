#! /usr/bin/env perl

use strict;
use warnings;
use Test::More tests => 2;

use 5.010;

use Data::Dumper;

BEGIN {
	use_ok( 'Data::DPath::Path' );
}

my $data  = {
             AAA  => { BBB   => { CCC  => [ qw/ XXX YYY ZZZ / ] } },
             some => { where => { else => {
                                           AAA => { BBB => { CCC => 'affe' } },
                                          } } },
             strange_keys => { 'DD DD' => { 'EE/E' => { CCC => 'zomtec' } } },
            };
my $path = new Data::DPath::Path(path => '/AAA/BBB/CCC');
say "path: ";
say Dumper( [ $path->path ] );
say "_steps: ";
say Dumper( [ $path->_steps ] );

ok(1, "dummy");
