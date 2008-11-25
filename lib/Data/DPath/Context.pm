package Data::DPath::Context;

# Method::Signatures: open brace needs to be on same line as "method" keyword

use strict;
use warnings;

use 5.010;

use Moose;
use MooseX::Method::Signatures;

use Data::Dumper;

# maybe not just the refs, but a hash, where the ref is in, plus a context like which parent it had, so later ".." is easy
has 'current_points' => ( is  => "rw", isa => "ArrayRef" );

method all {
        return ( $self->current_points );
}

method search($path) {
        say "::Context.match:";
        say "    path == ", Dumper($path->path);
        my $current_points = $self->current_points;
        foreach my $step ($path->_steps)
        {
                next unless $step->part;
                given ($step->kind)
                {
                        when ('HASH')
                        {
                                # follow the hash key
                                foreach my $point (@$current_points) {
                                        print "    point: ", Dumper($point);
                                        print "    step: ", Dumper($step);
                                        # take point as array as hash, skip undefs
                                        push @$current_points, ( ($$point)->{$step->part} || () );
                                        say "    ...";
                                }
                                say "    ---";
                        }
                        when ('ARRAY')
                        {
                                foreach my $point (@$current_points) {
                                        if ($step->part eq '*')
                                        {
                                                # take point as array
                                                push @$current_points, @$point;
                                        }
                                        elsif ( 1 == 2 ) # handle parent steps '..'
                                        {
                                                # TODO
                                        }
                                }
                        }
                }
        }
        $self->current_points( $current_points );
        return $self;
}

method match($path)
{
        $self->search($path)->all;
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
