use strict;
use warnings;
use inc::Module::Install;

name 'Data-DPath';
all_from 'lib/Data/DPath.pm';

requires 'perl'                       => 5.010;
requires 'parent'                     => 0;
requires 'Scalar::Util'               => 0;
requires 'List::MoreUtils'            => 0;
requires 'Sub::Exporter'              => 0;
requires 'Class::MOP'                 => "0.84";
requires 'Moose'                      => "0.79";
requires 'namespace::autoclean'       => "0.05";
requires 'MooseX::Declare'            => "0.22";
requires 'MooseX::Types::Structured'  => "0.14";
requires 'MooseX::Method::Signatures' => "0.16";
requires 'B::Hooks::EndOfScope'       => "0.05";
requires 'Parse::Method::Signatures'  => "1.003005";

test_requires 'Test::More';
test_requires 'Test::Deep';
tests_recursive;

#makemaker_args dist => { PREOP => 'pod2text lib/Data/DPath.pm > README' } ;

WriteAll;
