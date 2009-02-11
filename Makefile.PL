use strict;
use warnings;
use inc::Module::Install;

name 'Data-DPath';
all_from 'lib/Data/DPath.pm';

requires 'perl'                 => 5.010;
requires 'parent'               => 0;
requires 'Scalar::Util'         => 0;
requires 'List::MoreUtils'      => 0;
requires 'Sub::Exporter'        => 0;
requires 'Moose'                => 0;
requires 'MooseX::Declare'      => "0.02";
requires 'B::Hooks::EndOfScope' => '0.05';

test_requires 'Test::More';
test_requires 'Test::Deep';
tests_recursive;

#makemaker_args dist => { PREOP => 'pod2text lib/Data/DPath.pm > README' } ;

WriteAll;
