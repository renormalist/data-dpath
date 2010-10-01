use strict;
use warnings;
use inc::Module::Install;

name 'Data-DPath';
all_from 'lib/Data/DPath.pm';

requires 'perl'                       => 5.008;
requires 'parent'                     => 0;
requires 'aliased'                    => 0;
requires 'Class::XSAccessor'          => '1.05';
requires 'Class::XSAccessor::Array'   => 0;
requires 'Scalar::Util'               => 0;
requires 'List::MoreUtils'            => 0;
requires 'Sub::Exporter'              => 0;
requires 'Text::Balanced'             => '2.02';
requires 'Iterator::Util'             => 0;
requires 'Safe'                       => 0;

test_requires 'Test::More'            => 0.88;
test_requires 'Test::Aggregate::Nested';
test_requires 'Devel::Size';
test_requires 'Test::Deep';
test_requires 'Clone';

author_requires 'Module::Install::AuthorTests';
author_tests('xt');

repository 'git://github.com/renormalist/data-dpath.git';
bugtracker 'http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Data-DPath';

WriteAll;
