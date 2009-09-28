use strict;
use warnings;
use inc::Module::Install;

name 'Data-DPath';
all_from 'lib/Data/DPath.pm';

requires 'perl'                       => 5.008;
requires 'parent'                     => 0;
requires 'aliased'                    => 0;
requires 'Class::XSAccessor'          => 0;
requires 'Class::XSAccessor::Array'   => 0;
requires 'Scalar::Util'               => 0;
requires 'List::MoreUtils'            => 0;
requires 'Sub::Exporter'              => 0;
requires 'Text::Balanced'             => '2.02';

test_requires 'Test::More';
test_requires 'Test::Deep';
test_requires 'Clone';

tests_recursive;

#makemaker_args dist => { PREOP => 'pod2text lib/Data/DPath.pm > README' } ;

WriteAll;
