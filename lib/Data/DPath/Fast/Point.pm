package Data::DPath::Fast::Point;

use 5.010;
use strict;
use warnings;

        # has parent => ( is  => "rw", default => sub { undef } );
        # has ref    => ( is  => "rw", default => sub { undef } );

sub new {
        my ($class, %args) = @_;
        my $self = { %args };
        return bless $self, $class;
}

sub parent {
        my ($self, $value) = @_;
        $self->{parent} = $value if defined $value;
        return $self->{parent};
}

sub ref {
        my ($self, $value) = @_;
        $self->{ref} = $value if defined $value;
        return $self->{ref};
}

1;

__END__

=head1 NAME

Data::DPath::Fast::Point - Abstraction for a single reference (a "point") in
the datastructure

Intermediate steps during execution are lists of currently covered
references in the data structure, i.e., lists of such B<Point>s. The
remaining B<Point>s at the end just need to be dereferenced and form
the result.

=cut
