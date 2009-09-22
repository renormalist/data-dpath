package Data::DPath::Point;

use strict;
use warnings;

use Class::XSAccessor::Array
    chained     => 1,
    constructor => 'new',
    accessors   => {
                    parent => 0,
                    attrs  => 1,
                    ref    => 2,
                   };

1;

__END__

=head1 NAME

Data::DPath::Point - Abstraction for a single reference (a "point") in
the datastructure

Intermediate steps during execution are lists of currently covered
references in the data structure, i.e., lists of such B<Point>s. The
remaining B<Point>s at the end just need to be dereferenced and form
the result.

=head1 INTERNAL METHODS

=head2 new

Constructor.

=head2 parent

Attribute / accessor.

=head2 ref

Attribute / accessor.

=head2 attrs

Attribute / accessor.

=cut
