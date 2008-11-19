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
                   { bar => 43 }
                 ]
               ],
               7,
               8
             ];
traverse {
          print "ARRAY: $a\n" if /ARRAY/;
          print "HASH:  $a => $b\n" if /HASH/
         } $struct;

my $struct2 = "single value";
traverse {
          print "ARRAY: $a\n" if /ARRAY/;
          print "HASH:  $a => $b\n" if /HASH/
         } $struct2;
