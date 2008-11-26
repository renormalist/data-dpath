package Data::DPath::Point;

use strict;
use warnings;

use 5.010;

use Moose;
use MooseX::Method::Signatures;

# explicite undefs make Data::Dumper'ed structures more consistently readable

has parent => ( is  => "rw", default => sub { undef } );
has ref    => ( is  => "rw", default => sub { undef } );

1;

__END__

=head1 NAME

Data::DPath::Point - Abstraction for a single reference (a "point") in
the datastructure

Intermediate steps during execution are lists of currently covered
references in the data structure, i.e., lists of such B<Point>s. The
remaining B<Point>s at the end just need to be dereferenced and form
the result.

=cut
