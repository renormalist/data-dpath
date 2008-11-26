use MooseX::Declare;

use 5.010;
use strict;
use warnings;

class Data::DPath::Context {

        use Data::DPath::Point;
        use Data::Dumper;
        use List::MoreUtils 'uniq';

        # Points are the collected pointers into the datastructure
        has current_points => ( is  => "rw", isa => "ArrayRef", auto_deref => 1 );

        method all {
                return
                    map { $$_ }
                        uniq
                            map { $_->ref } $self->current_points;
        }

        method search($path) {
                $Data::DPath::DEBUG && say "Context.match:";
                $Data::DPath::DEBUG && say "    path == ", Dumper($path->path);
                my @current_points = $self->current_points;
                foreach my $step ($path->_steps) {
                        $Data::DPath::DEBUG && say "    ", $step->kind, " ==> ", $step->part;
                        $Data::DPath::DEBUG && say "    current_points: ", Dumper(\@current_points);
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
                                                $Data::DPath::DEBUG && say "    ,-----------------------------------";
                                                $Data::DPath::DEBUG && print "    point: ", Dumper($point);
                                                $Data::DPath::DEBUG && print "    step: ", Dumper($step);
                                                # take point as hash, skip undefs
                                                push @new_points, map {
                                                                       new Data::DPath::Point( ref => \$_, parent => $point )
                                                                      } ( ${$point->ref}->{$step->part} || () );
                                                $Data::DPath::DEBUG && say "    `-----------------------------------";
                                        }
                                }
                                when ('ANY')
                                {
                                        # all leaves of a data tree
                                        foreach my $point (@current_points) {
                                                $Data::DPath::DEBUG && say "    ,-----------------------------------";
                                                # take point as array
                                                $Data::DPath::DEBUG && say "    *** ", ref(${$point->ref});
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
                                                $Data::DPath::DEBUG && say "    `-----------------------------------";
                                        }
                                }
                                when ('PARENT')
                                {
                                        # the parent
                                        foreach my $point (@current_points) {
                                                $Data::DPath::DEBUG && say "    ,-----------------------------------";
                                                push @new_points, $point->parent;
                                                $Data::DPath::DEBUG && say "    `-----------------------------------";
                                        }
                                }
                        }
                $Data::DPath::DEBUG && print "    newpoints: ", Dumper(\@new_points);
                @current_points = @new_points;
                $Data::DPath::DEBUG && say "    ______________________________________________________________________";
        }
                $self->current_points( \@current_points );
        return $self;
        }

        method match($path) {
                $self->search($path)->all;
        }
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
