use MooseX::Declare;

use 5.010;
use strict;
use warnings;

class Data::DPath::Step {
        has kind   => ( isa => "Str", is  => "rw", default => sub { undef } );
        has part   => ( isa => "Str", is  => "rw", default => sub { undef } );
        has filter => ( isa => "Any", is  => "rw", default => sub { undef } );
}

1;

__END__

=head1 NAME

Data::DPath::Step - Abstraction for a single Step through a Path.

When a DPath is evaluated it executes these B<Step>s of a B<Path>.

=cut
