package Data::DPath::Step;

use 5.010;
use strict;
use warnings;

use Object::Tiny::rw 'kind', 'part', 'filter';

1;

__END__

=head1 NAME

Data::DPath::Step - Abstraction for a single Step through a Path.

When a DPath is evaluated it executes these B<Step>s of a B<Path>.

=cut
