package Data::DPath::Path;

use strict;
use warnings;

use 5.010;

use Moose;

sub match
{
        #return ('affe', 'zomtec');
        return ( ['XXX', 'YYY', 'ZZZ'] );
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
