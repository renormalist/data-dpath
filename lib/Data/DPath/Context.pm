package Data::DPath::Context;

use strict;
use warnings;

use 5.010;

use Moose;

sub all
{
        my ($self) = @_;
        return ('affe', 'zomtec');
}

sub search
{
        my ($self, $path) = @_;
        return new Data::DPath::Context;
}

sub match
{
        my ($self, $path) = @_;
        $self->search($path)->all();
}


1;

__END__

=head1 NAME

Data::DPath::Context

Abstraction for a current context that enables incremental searches.

=head2 all

Returns all values covered by current context.

=head2 search

Return new context with path relative to current context.

=head2 match

Same as search()->all();

=cut
