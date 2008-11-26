package Data::DPath::Context;

# MooseX::Method::Signatures: open brace needs to be on same line as "method" keyword

use 5.010;

use strict;
use warnings;

use Moose;
use MooseX::Method::Signatures;
use Data::DPath::Point;
use Data::Dumper;

# Points are the collected pointers into the datastructure
# maybe not just the refs, but a hash, where the ref is in, plus a context like which parent it had, so later ".." is easy
has current_points => ( is  => "rw", isa => "ArrayRef", auto_deref => 1 );

method all {
        return map { ${$_->ref} } $self->current_points;
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
                                # the root node
                                # (only makes sense at first step, but currently not asserted)
                                push @new_points, @current_points;
                        }
                        when ('ANYWHERE')
                        {
                                # all parent nodes of a data tree
                                my @all_points = ();
                                push @new_points, @all_points;
                        }
                        when ('KEY')
                        {
                                # the value of a key
                                foreach my $point (@current_points) {
                                        say "    ,-----------------------------------";
                                        print "    point: ", Dumper($point);
                                        print "    step: ", Dumper($step);
                                        # take point as array as hash, skip undefs
                                        push @new_points, map {
                                                               new Data::DPath::Point( ref => \$_, parent => $point )
                                                              } ( ${$point->ref}->{$step->part} || () );
                                        say "    `-----------------------------------";
                                }
                        }
                        when ('ANY')
                        {
                                # all leaves of a data tree
                                foreach my $point (@current_points) {
                                        say "    ,-----------------------------------";
                                        # take point as array
                                        say "    *** ", ref(${$point->ref});
                                        given (ref ${$point->ref}) {
                                                when ('HASH')
                                                {
                                                        push @new_points, map {
                                                                               new Data::DPath::Point( ref => \$_, parent => $point )
                                                                              } values %${$point->ref};
                                                }
                                                when ('ARRAY')
                                                {
                                                        push @new_points, map {
                                                                               new Data::DPath::Point( ref => \$_, parent => $point )
                                                                              } @{$point->ref}
                                                }
                                        }
                                        say "    `-----------------------------------";
                                }
                        }
                        when ('PARENT')
                        {
                                # the parent
                                foreach my $point (@current_points) {
                                        say "    ,-----------------------------------";
                                        push @new_points, $point->parent;
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
