#! /usr/bin/env perl

use strict;
use warnings;

use Test::More;

eval "use Artemis::Test";
plan skip_all => "no suite meta" if $@;

artemis_suite_meta();

