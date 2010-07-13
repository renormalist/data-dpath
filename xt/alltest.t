#! /usr/bin/env perl

eval "use Test::Aggregate::Nested";

if ($@) {
        use Test::More;
        plan skip_all => "Test::Aggregate required for testing aggregated";
}

use Data::DPath;
#DB::enable_profile();

my $tests = Test::Aggregate::Nested->new
    ({
      dirs => 't/',
     });

$tests->run;
