#! /usr/bin/env perl

eval "use Test::Aggregate::Nested";

if ($@) {
        use Test::More;
        plan skip_all => "Test::Aggregate required for testing aggregated";
}

unless ($ENV{AUTOMATED_TESTING} or $ENV{RELEASE_TESTING}) {
        plan skip_all => "Author tests not required for installation";
}

use Data::DPath;
#DB::enable_profile();

my $tests = Test::Aggregate::Nested->new
    ({
      dirs => 't/',
     });

$tests->run;
