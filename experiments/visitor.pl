#! /usr/bin/env perl

# You probably want to use Data::Visitor::Callback for trivial things

package FooCounter;

use 5.010;

use strict;
use warnings;

use Mouse;
use Data::Dumper;

extends qw(Data::Visitor);

has number_of_foos   => ( isa => "Int", is  => "rw", default => 0, );
has number_of_values => ( isa => "Int", is  => "rw", default => 0, );
has number_of_hashes => ( isa => "Int", is  => "rw", default => 0, );
has number_of_arrays => ( isa => "Int", is  => "rw", default => 0, );
has number_of_scalar => ( isa => "Int", is  => "rw", default => 0, );
has number_of_any    => ( isa => "Int", is  => "rw", default => 0, );

# sub visit_value {
#         my ( $self, $data ) = @_;

#         if ( defined $data and $data =~ /foo/ ) {
#                 print "value: ", Dumper($data);
#                 $self->number_of_foos( $self->number_of_foos + 1 );
#         }

#         return $data;
# }

sub visit_value {
        my ( $self, $data ) = @_;

        if ( defined $data ) {
                say "value: ", Dumper($data);
                $self->number_of_values( $self->number_of_values + 1 );
        }

        return $data;
}

sub visit_hash_key {
        my ( $self, $key, $value, $hash ) = @_;

        if ( defined $hash ) {
                say "hash ", (\$hash), " :", Dumper($hash);
                $self->number_of_hashes( $self->number_of_hashes + 1 );
        }

        return $hash;
}

sub visit_array {
        my ( $self, $data ) = @_;

        if ( defined $data ) {
                say "array: ", Dumper($data);
                $self->number_of_arrays( $self->number_of_arrays + 1 );
        }

        return $data;
}

sub visit_scalar {
        my ( $self, $data ) = @_;

        if ( defined $data ) {
                say "scalar: ", Dumper($data);
                $self->number_of_scalar( $self->number_of_scalar + 1 );
        }

        return $data;
}

# sub visit_no_rec_check {
#         my ( $self, $data ) = @_;

#         if ( defined $data ) {
#                 say "any: ", Dumper($data);
#                 $self->number_of_any( $self->number_of_any + 1 );
#         }

#         return $data;
# }

my $counter = FooCounter->new;

$counter->visit( {
                  this      => "that",
                  some_foos => [ qw/foo foo bar foo/ ],
                  the_other => "foo",
                 });

say "------------------";
say "foos: ",    $counter->number_of_foos; # 5
say "values: ",  $counter->number_of_foos; # 5
say "hashes: ",  $counter->number_of_hashes; # 1
say "arrays: ",  $counter->number_of_arrays; # 1
say "scalars: ", $counter->number_of_scalar; # 9
say "any: ",     $counter->number_of_any; # 9
