use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
                                 module_name         => 'Data::DPath',
                                 license             => 'perl',
                                 dist_author         => 'Steffen Schwigon <schwigon@cpan.org>',
                                 dist_version_from   => 'lib/Data/DPath.pm',
                                 build_requires      => {
                                                         'Test::More' => 0,
                                                        },
                                 requires            => {
                                                         'Test::More'      => 0,
                                                         'parent'          => 0,
                                                         'Moose'           => 0,
                                                         'MooseX::Declare' => 0,
                                                        },
                                 add_to_cleanup      => [ 'Data-DPath-*' ],
                                );

$builder->create_build_script();
