use MooseX::Declare;

use 5.010;

class Data::DPath::Context {

        use Data::Dumper;
        use Data::DPath::Point;
        use List::MoreUtils 'uniq';

        # Points are the collected pointers into the datastructure
        has current_points => ( is  => "rw", isa => "ArrayRef", auto_deref => 1 );

        method all {
                return
                    map { $$_ }
                        uniq
                            map {
                                 defined $_ ? $_->ref : ()
                                } $self->current_points;
        }

        # filter current results by array index
        sub _filter_points_index {
                my ($self, $index, @points) = @_;
                return @points ? ($points[$index]) : ();
        }

        # filter current results by condition
        sub _filter_points_eval {
                my ($self, $filter, @points) = @_;
                return () unless @points;
                return @points unless defined $filter;

                #print STDERR "_filter_points_eval: $filter | ".Dumper([ map { $_->ref } @points ]);
                my @new_points;
                {
                        require Data::DPath::Filters;
                        package Data::DPath::Filters;
                        local our $idx = 0;
                        @new_points =
                            grep {
                                    my $res;
                                    my $p = $_;
                                    local $_;
                                    if ( defined $p->ref ) {
                                            $_ = ${ $p->ref };
                                            # say STDERR "* $_";
                                            no warnings 'uninitialized'; # having non-fitting values is the norm
                                            $res = eval $filter;
                                            say STDERR $@ if $@;
                                    } else {
                                            $res = 0;
                                    }
                                    $idx++;
                                    $res;
                            } @points;
                }
                return @new_points;
        }

        sub _filter_points {
                my ($self, $step, @points) = @_;

                return () unless @points;

                my $filter = $step->filter;
                return @points unless defined $filter;

                $filter =~ s/^\[\s*(.*?)\s*\]$/$1/; # strip brackets and whitespace

                given ($filter) {
                        when (/^-?\d+$/) {
                                # say "INT Filter: $filter <-- ".Dumper(\(map { $_ ? $_->ref : () } @points));
                                return $self->_filter_points_index($filter, @points); # simple array index
                        }
                        when (/\S/) {
                                #say "EVAL Filter: $filter, ".Dumper(\(map {$_->ref} @points));
                                return $self->_filter_points_eval($filter, @points); # full condition
                        }
                        default {
                                return @points;
                        }
                }
        }

        # only finds "inner" values; if you need the outer start value
        # then just wrap it into one more level of array brackets.
        sub _any {
                my ($out, $in) = @_;

                #print "    in: ", Dumper($in);
                #sleep 3;

                $in //= [];
                return @$out unless @$in;

                my @newin;
                my @newout;

                foreach my $point (@$in) {
                        my @values;
                        my $ref = $point->ref;
                        given (ref $$ref) {
                                when ('HASH')  { @values = values %{$$ref} }
                                when ('ARRAY') { @values = @{$$ref}        }
                                default        { next }
                        }
                        foreach (@values) {
                                push @newout, new Data::DPath::Point( ref => \$_, parent => $point );
                                push @newin,  new Data::DPath::Point( ref => \$_, parent => $point );
                        }
                }
                push @$out,  @newout;
                return _any ($out, \@newin);
        }

        method search($path) {
                $Data::DPath::DEBUG && say "Context.search:";
                $Data::DPath::DEBUG && say "    \$path == ",      Dumper($path);
                $Data::DPath::DEBUG && say "    \$path.path == ", Dumper($path->path);
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
                                        my @step_points = $self->_filter_points($step, @current_points);
                                        push @new_points, @step_points;
                                }
                                when ('ANYWHERE')
                                {
                                        # '//'
                                        # all hash/array nodes of a data structure
                                        $Data::DPath::DEBUG && print "current_points: ".Dumper(\@current_points);
                                        foreach my $point (@current_points) {
                                                $Data::DPath::DEBUG && say "    ,-----------------------------------";
                                                $Data::DPath::DEBUG && print "    point: ", Dumper($point);
                                                $Data::DPath::DEBUG && print "    step: ", Dumper($step);
                                                my @step_points = (_any([], [ $point ]), $point);
                                                push @new_points, $self->_filter_points($step, @step_points);
                                                $Data::DPath::DEBUG && print "    new_points: ", Dumper(\@new_points);
                                                $Data::DPath::DEBUG && say "    `-----------------------------------";
                                        }
                                }
                                when ('KEY')
                                {
                                        # the value of a key
                                        #print "    current_points: ", Dumper(\@current_points);
                                        foreach my $point (@current_points) {
                                                next unless defined $point;
                                                next unless ref ${$point->ref} eq 'HASH';
                                                $Data::DPath::DEBUG && say "    ,-----------------------------------";
                                                $Data::DPath::DEBUG && print "    point: ", Dumper($point);
                                                $Data::DPath::DEBUG && print "    step: ", Dumper($step);
                                                # take point as hash, skip undefs
                                                my @step_points = map {
                                                                       new Data::DPath::Point( ref => \$_, parent => $point )
                                                                      } ( ${$point->ref}->{$step->part} || () );
                                                push @new_points, $self->_filter_points($step, @step_points);
                                                $Data::DPath::DEBUG && say "    `-----------------------------------";
                                        }
                                }
                                when ('ANYSTEP')
                                {
                                        # '*'
                                        # all leaves of a data tree
                                        foreach my $point (@current_points) {
                                                $Data::DPath::DEBUG && say "    ,-----------------------------------";
                                                # take point as array
                                                my $ref = ${$point->ref};
                                                $Data::DPath::DEBUG && say "    *** ", ref($ref);
                                                my @step_points = ();
                                                given (ref $ref) {
                                                        when ('HASH')
                                                        {
                                                                @step_points = map {
                                                                                    new Data::DPath::Point( ref => \$_, parent => $point )
                                                                                   } values %$ref;
                                                        }
                                                        when ('ARRAY')
                                                        {
                                                                @step_points = map {
                                                                                    new Data::DPath::Point( ref => \$_, parent => $point )
                                                                                   } @$ref;
                                                        }
                                                        default
                                                        {
                                                                if (ref $point->ref eq 'SCALAR') {
                                                                        @step_points = map {
                                                                                            new Data::DPath::Point( ref => \$_, parent => $point )
                                                                                           } $ref;
                                                                }
                                                        }
                                                }
                                                push @new_points, $self->_filter_points($step, @step_points);
                                                $Data::DPath::DEBUG && say "    `-----------------------------------";
                                        }
                                }
                                when ('PARENT')
                                {
                                        # '..'
                                        # the parent
                                        foreach my $point (@current_points) {
                                                $Data::DPath::DEBUG && say "    ,-----------------------------------";
                                                my @step_points = ($point->parent);
                                                push @new_points, $self->_filter_points($step, @step_points);
                                                $Data::DPath::DEBUG && say "    `-----------------------------------";
                                        }
                                }
                        }
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

# help the CPAN indexer
package Data::DPath::Context;

1;

__END__

=head1 NAME

Data::DPath::Context - Abstraction for a current context that enables incremental searches.

=head1 API METHODS

=head2 all

Returns all values covered by current context.

=head2 search( $path )

Return new context with path relative to current context.

=head2 match( $path )

Same as C<< search($path)->all() >>;

=head1 UTILITY SUBS/METHODS

=head2 _filter_points

Evaluates the filter condition in brackets. It differenciates between
simple integers, which are taken as array index, and all other
conditions, which are taken as evaled perl expression in a grep like
expression onto the set of points found by current step.

=head1 AUTHOR

Steffen Schwigon, C<< <schwigon at cpan.org> >>

=head1 COPYRIGHT & LICENSE

Copyright 2008,2009 Steffen Schwigon.

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
__END__

/foo[ isa("Foo")  ]/

    @filtered = grep { eval $condition } @points;

/foo[ reallyhotstuff("Foo")  ]/

/foo[ index == 7  ]/

package Data::DPath::Filters;
        our $index;

        sub reallyhotstuff {
                (@args) = @_;
                # $_->ref sowieso da
                return 1 or 0;
        }

        sub index { $index };
}

package Data::DPath::Context;
sub _filter {

        @points = map { new Point( ref => $_ } @refs;

                        @filtered = grep { eval 'reallyhotstuff("Foo")' } @points;
                        grep { $_ = ${ $_->ref }; foo() } @list;
                        {
                                package Data::DPath::Filters;
                                local $index = -1;
                                grep { $index++; $_ = ${ $_->ref }; eval $condition; } @points;
                        }
}
# moose type constraints, haben check methode
# haben Syntax, diese stehlen
# subtypes definieren

