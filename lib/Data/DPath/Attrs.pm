package Data::DPath::Attrs;
# ABSTRACT: Abstraction for internal attributes attached to a point

use strict;
use warnings;

use Class::XSAccessor # ::Array
    chained     => 1,
    constructor => 'new',
    accessors   => [qw( key idx )];

1;

__END__

=head1 INTERNAL METHODS

=head2 new

Constructor.

=head2 key

Attribute / accessor.

The key actual hash key under which the point is located in case it's
the value of a hash entry.

=head2 idx

Attribute / accessor.

The key actual array index under which the point is located in case it's
the value of a array entry.

=cut
