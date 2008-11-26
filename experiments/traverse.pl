#! /usr/bin/env perl

use 5.010;

use strict;
use warnings;

use Data::Traverse qw(traverse);
use Data::Dumper::Simple;

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

print Dumper($struct);

traverse {
          print "ARRAY: ".(Dumper(\$a))."\n" if /ARRAY/;
          print "HASH:  ".(Dumper(\$a))." => ".(\$b)."\n" if /HASH/;
         } $struct;

traverse {
          print "ARRAY: ".(Dumper(\$a))."\n" if /ARRAY/;
          print "HASH:  $a (".(Dumper(\$a)).") => $b (".(Dumper(\$b)).")\n" if /HASH/;
         } $struct;

# Do I get the references into the structure? No.
# Change the code to it.
