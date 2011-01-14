package Data::DPath::Step;

use strict;
use warnings;

use Class::XSAccessor::Array
    chained     => 1,
    constructor => 'new',
    accessors   => {
                    kind   => 0,
                    part   => 1,
                    filter => 2,
                    filter_type => 3,
                   };

1;

__END__

=head1 NAME

Data::DPath::Step - Abstraction for a single Step through a Path.

When a DPath is evaluated it executes these B<Step>s of a B<Path>.

=head1 INTERNAL METHODS

=head2 new

Constructor.

=head2 kind

Attribute / accessor.

=head2 part

Attribute / accessor.

=head2 filter

Attribute / accessor.

=cut
