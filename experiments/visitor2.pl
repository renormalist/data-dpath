#! /usr/bin/env perl

# You probably want to use Data::Visitor::Callback for trivial things

package FooCounter;

use 5.010;

use strict;
use warnings;

use Mouse;
use Data::Dumper;

extends 'Data::Visitor';

# --------------------

# sub visit_array {
#         my ( $self, $data ) = @_;
#         print \$data, ": array: ", Dumper($data);
#         return $data;
# }

# sub visit_hash {
#         my ( $self, $data ) = @_;
#         print \$data, ": hash: ", Dumper($data);
#         return $data;
# }

# sub visit_value {
#         my ( $self, $data ) = @_;
#         print \$data, ": value: ", Dumper($data);
#         return $data;
# }

# --------------------

# sub visit_value {
#         my ( $self, $data ) = @_;
#         print \$data, ": value: ", Dumper($data);
#         return $data;
# }

# --------------------

sub visit_ref {
        my ( $self, $data ) = @_;
        print \$data, ": ref: ", Dumper($data);
        $self->SUPER ($data);
}

# --------------------

# sub visit_seen {
#         my ( $self, $data ) = @_;
#         print \$data, ": ref: ", Dumper($data);
#         return $data;
# }

# --------------------

# sub visit_no_rec_check {
#         my ( $self, $data ) = @_;
#         print \$data, ": no_rec_check: ", Dumper($data);
#         return $data;
# }

# --------------------

my $counter = FooCounter->new;
my $data  = {
             AAA  => { BBB   => { CCC  => [ qw/ XXX YYY ZZZ / ] } },
             some => { where => { else => {
                                           AAA => { BBB => { CCC => 'affe' } },
                                          } } },
             strange_keys => { 'DD DD' => { 'EE/E' => { CCC => 'zomtec' } } },
             foo => { 'bar' => { 'baz' => { brueller => [ qw/affe tiger fink star/] } } },
            };
say Dumper($data);
$counter->visit( $data );


