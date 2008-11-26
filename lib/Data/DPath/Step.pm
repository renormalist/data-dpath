package Data::DPath::Step;

use strict;
use warnings;

use 5.010;

use Moose;
use MooseX::Method::Signatures;

# explicite undefs make Data::Dumper'ed structures more consistently readable

has kind   => ( isa => "Str", is  => "rw", default => sub { undef } );
has part   => ( isa => "Str", is  => "rw", default => sub { undef } );
has filter => ( isa => "Any", is  => "rw", default => sub { undef } );

1;

__END__

=head1 NAME

Data::DPath::Step - Abstraction for a single Step through a Path.

The result Collects all information about a single step, resulting
from parsing a path.

When a DPath is evaluated it executes these B<Step>s of a B<Path>.

=cut
