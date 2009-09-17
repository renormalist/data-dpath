#! /usr/bin/env perl

eval "use Test::Aggregate";

if ($@) {
        use Test::More;
        plan skip_all => "Test::Aggregate required for testing aggregated";
}

use Data::DPath;
#DB::enable_profile();

my $tests = Test::Aggregate->new
    ({
      dirs => 't/',
     });

$tests->run;
