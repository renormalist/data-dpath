#! /usr/bin/env perl

use 5.010;

use strict;
use warnings;

my $struct = [ 1,
               2,
               { affe => 41,
                 zomtec => 42,
               },
               [ 3,
                 4,
                 [ 5,
                   6,
                   { bar => 43 },
                   { baz => {
                             AAA => { BBB => { CCC => [ qw/UUU VVV WWW XXX YYY ZZZ/ ] } },
                             one => { more => { level => { AAA => { BBB => { CCC => [ qw/111 222 333 444/ ] } } } } },
                            },
                   }
                 ]
               ],
               7,
               8
             ];

use Data::Eacherator 'eacherator';
my $iter = eacherator($struct);

while (my ($k, $v) = $iter->()) {
        say STDERR "k,v: $k, $v";
}

# --------------------------------------------------

use Data::Iter qw(:all);

my @days = qw/Mon Tue Wnd Thr Fr Su So/;
my @i = iter \@days;
foreach ( @i )
{
        printf "Day: %s [%s]\n", VALUE, counter;
}

foreach my $i ( iter \@days )
{
        printf "Day: %s [%s]\n", $i->VALUE, $i->counter;
}
