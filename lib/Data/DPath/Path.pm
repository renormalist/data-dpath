use MooseX::Declare;

use strict;
use warnings;

use 5.010;

class Data::DPath::Path {

        has 'path'   => ( isa => "Str",      is  => "rw" );
        has '_steps' => ( isa => "ArrayRef", is  => "rw", auto_deref => 1, lazy_build => 1 );

        method get_steps { $self->_steps }
        method _build__steps {
                $self->_steps( [ split(qr[/], $self->path) ] );
                say "_build__steps: ".join(", ", $self->_steps);
        }

        method _clear__steps {
                say "_clear__steps: ".join(", ", $self->_steps);
        }

        sub match
        {
                #return ('affe', 'zomtec');
                return ( ['XXX', 'YYY', 'ZZZ'] );
        }
}

1;

__END__

=head1 NAME

Data::DPath::Path

Abstraction for a DPath.

Take a string description, parse it, bundle class with overloading,
etc.

=head2 all

Returns all values covered by current context.

=head2 search

Return new context with path relative to current context.

=head2 match

Same as search()->all();

=cut
