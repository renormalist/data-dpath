package Data::DPath::Context;

# Method::Signatures: open brace needs to be on same line as "method" keyword

use strict;
use warnings;

use 5.010;

use Moose;
use MooseX::Method::Signatures;

use Data::Dumper;

# Points are the collected pointers into the datastructure
# maybe not just the refs, but a hash, where the ref is in, plus a context like which parent it had, so later ".." is easy
has current_points => ( is  => "rw", isa => "ArrayRef", auto_deref => 1 );

method all {
        return map { $$_ } $self->current_points;
}

method search($path) {
        say "Context.match:";
        say "    path == ", Dumper($path->path);
        my @current_points = $self->current_points;
        foreach my $step ($path->_steps)
        {
                say "    ", $step->kind, " ==> ", $step->part;
                say "    current_points: ", Dumper(\@current_points);
                my @new_points = ();
                given ($step->kind)
                {
                        when ('ROOT')
                        {
                                push @new_points, @current_points; # only makes sense at first step
                        }
                        when ('ANYWHERE')
                        {
                                # collect *all* points
                                my @all_points = ();
                                push @new_points, @all_points;
                        }
                        when ('KEY')
                        {
                                # follow the hash key
                                foreach my $point (@current_points) {
                                        say "    ,-----------------------------------";
                                        print "    point: ", Dumper($point);
                                        print "    step: ", Dumper($step);
                                        # take point as array as hash, skip undefs
                                        push @new_points, map {
                                                               #new Data::DPath::Point( ref => \$_, parent => $point )
                                                               \$_
                                                              } ( $$point->{$step->part} || () );
                                        say "    `-----------------------------------";
                                }
                        }
                        when ('ANY')
                        {
                                foreach my $point (@current_points) {
                                        say "    ,-----------------------------------";
                                        # take point as array
                                        say "    *** ", ref($$point);
                                        given (ref $$point) {
                                                when ('HASH')  { push @new_points, map { \$_ } values %$$point }
                                                when ('ARRAY') { push @new_points, map { \$_ } @$point        }
                                        }
                                        say "    `-----------------------------------";
                                }
                        }
                        when ('PARENT')
                        {
                                foreach my $point (@current_points) {
                                        say "    ,-----------------------------------";
                                        # take point as array
                                        push @new_points, map { \$_ } @$point;
                                        say "    `-----------------------------------";
                                }
                        }
                }
                print "    newpoints: ", Dumper(\@new_points);
                @current_points = @new_points;
                say "    ______________________________________________________________________";
        }
        $self->current_points( \@current_points );
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
