#! /usr/bin/env perl

use Test::Aggregate;

use Data::DPath;
#DB::enable_profile();

my $tests = Test::Aggregate->new
    ({
      dirs => 't/',
     });

$tests->run;
