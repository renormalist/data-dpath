#! /usr/bin/env perl

use 5.010;

use strict;
use warnings;

use Data::Traverse qw(traverse);

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

traverse {
          print "ARRAY: ".(\$a)."\n" if /ARRAY/;
          print "HASH:  ".(\$a)." => ".(\$b)."\n" if /HASH/;
         } $struct;

traverse {
          print "ARRAY: ".(\$a)."\n" if /ARRAY/;
          print "HASH:  $a (".(\$a).") => $b (".(\$b).")\n" if /HASH/;
         } $struct;

# Do I get the references into the structure? No.
# Change the code to it.
