package Data::DPath::Context;

use strict;
use warnings;

use Data::Dumper;
use aliased 'Data::DPath::Point';
use List::MoreUtils 'uniq';
use Scalar::Util 'reftype';
use Data::DPath::Filters;
use Iterator::Util;

# print "use $]\n" if $] >= 5.010; # allow new-school Perl inside filter expressions
# eval "use $]" if $] >= 5.010; # allow new-school Perl inside filter expressions

use Class::XSAccessor::Array
    chained     => 1,
    constructor => 'new',
    accessors   => {
                    current_points  => 0,
                    give_references => 1,
                   };

use constant { HASH             => 'HASH',
               ARRAY            => 'ARRAY',
               SCALAR           => 'SCALAR',
               ROOT             => 'ROOT',
               ANYWHERE         => 'ANYWHERE',
               KEY              => 'KEY',
               ANYSTEP          => 'ANYSTEP',
               NOSTEP           => 'NOSTEP',
               PARENT           => 'PARENT',
               ANCESTOR         => 'ANCESTOR',
               ANCESTOR_OR_SELF => 'ANCESTOR_OR_SELF',
           };

# only finds "inner" values; if you need the outer start value
# then just wrap it into one more level of array brackets.
sub _any
{
        my ($out, $in, $lookahead_key) = @_;

        no warnings 'uninitialized';

        $in = defined $in ? $in : [];
        return @$out unless @$in;

        my @newin;
        my @newout;
        my $ref;
        my $reftype;

        foreach my $point (@$in) {
                my @values;
                my $ref = $point->ref;

                # speed optimization: first try faster ref, then reftype
                if (ref($$ref) eq HASH or reftype($$ref) eq HASH) {
                        @values =
                            grep {
                                    # speed optimization: only consider a key if lookahead looks promising
                                    not defined $lookahead_key
                                    or $_->{key} eq $lookahead_key
                                    or ($ref = ref($_->{val}))         eq HASH
                                    or $ref                            eq ARRAY
                                    or ($reftype = reftype($_->{val})) eq HASH
                                    # not yet sure whether I also need this:
                                    #or $reftype                        eq ARRAY
                            } map { { val => $$ref->{$_}, key => $_ } }
                                keys %{$$ref};
                }
                elsif (ref($$ref) eq ARRAY or reftype($$ref) eq ARRAY) {
                        @values = map { { val => $_ } } @{$$ref}
                }
                else {
                        next
                }

                foreach (@values)
                {
                        my $key = $_->{key};
                        my $val = $_->{val};
                        my $newpoint = Point->new->ref(\$val)->parent($point);
                        $newpoint->attrs({ key => $key }) if $key;
                        push @newout, $newpoint;
                        push @newin,  $newpoint;
                }
        }
        push @$out, @newout;
        return _any ($out, \@newin, $lookahead_key);
}

sub _all {
        my ($self) = @_;

        no strict 'refs';
        no warnings 'uninitialized';

        return
          map { $self->give_references ? $_ : $$_ }
          uniq
          map { defined $_ ? $_->ref : () }
          @{$self->current_points};
}

# filter current results by array index
sub _filter_points_index {
        my ($self, $index, $points) = @_;

        return $points ? [$points->[$index]] : [];
}

# filter current results by condition
sub _filter_points_eval
{
        my ($self, $filter, $points) = @_;

        return [] unless @$points;
        return $points unless defined $filter;

        my $new_points;
        my $res;
        {
                package Data::DPath::Filters;

                local our $idx = 0;
                $new_points = [
                               grep {
                                       local our $p = $_;
                                       local $_;
                                       my $pref = $p->ref;
                                       if ( defined $pref ) {
                                               $_ = $$pref;
                                               # 'uninitialized' values are the norm
                                               no warnings 'uninitialized';
                                               $res = eval $filter;
                                               print STDERR ($@, "\n") if $@;
                                       } else {
                                               $res = 0;
                                       }
                                       $idx++;
                                       $res;
                               } @$points
                              ];
        }
        return $new_points;
}

sub _filter_points {
        my ($self, $step, $points) = @_;

        no strict 'refs';
        no warnings 'uninitialized';

        return [] unless @$points;

        my $filter = $step->filter;
        return $points unless defined $filter;

        $filter =~ s/^\[\s*(.*?)\s*\]$/$1/; # strip brackets and whitespace

        if ($filter =~ /^-?\d+$/)
        {
                return $self->_filter_points_index($filter, $points); # simple array index
        }
        elsif ($filter =~ /\S/)
        {
                return $self->_filter_points_eval($filter, $points); # full condition
        }
        else
        {
                return $points;
        }
}

# the root node
# (only makes sense at first step, but currently not asserted)
sub _select_root {
        my ($self, $step, $current_points, $new_points) = @_;

        my $step_points = $self->_filter_points($step, $current_points);
        push @$new_points, @$step_points;
}


# //
# anywhere in the tree
sub _select_anywhere {
        my ($self, $step, $current_points, $lookahead, $new_points) = @_;

        # speed optimization: only useful points added
        my $lookahead_key;
        if (defined $lookahead and $lookahead->kind eq KEY) {
                $lookahead_key = $lookahead->part;
        }

        # '//'
        # all hash/array nodes of a data structure
        foreach my $point (@$current_points) {
                my $step_points = [_any([], [ $point ], $lookahead_key), $point];
                push @$new_points, @{$self->_filter_points($step, $step_points)};
        }
}

# /key
# the value of a key
sub _select_key {
        my ($self, $step, $current_points, $new_points) = @_;

        foreach my $point (@$current_points) {
                no warnings 'uninitialized';
                next unless defined $point;
                my $pref = $point->ref;
                next unless (defined $point && (
                                                # speed optimization:
                                                # first try faster ref, then reftype
                                                ref($$pref)     eq HASH or
                                                reftype($$pref) eq HASH
                                               ));
                                # take point as hash, skip undefs
                my $attrs = { key => $step->part };
                my $step_points = [ map { Point
                                            ->new
                                              ->ref(\$_)
                                                ->parent($point)
                                                  ->attrs($attrs)
                                          } ( $$pref->{$step->part} || () ) ];
                push @$new_points, @{$self->_filter_points($step, $step_points)};
        }
}

# '*'
# all leaves of a data tree
sub _select_anystep {
        my ($self, $step, $current_points, $new_points) = @_;

        no warnings 'uninitialized';
        foreach my $point (@$current_points) {
                # take point as array
                my $pref = $point->ref;
                my $ref = $$pref;
                my $step_points = [];
                # speed optimization: first try faster ref, then reftype
                if (ref($ref) eq HASH or reftype($ref) eq HASH) {
                        $step_points = [ map {
                                my $v     = $ref->{$_};
                                my $attrs = { key => $_ };
                                Point->new->ref(\$v)->parent($point)->attrs($attrs)
                        } keys %$ref ];
                } elsif (ref($ref) eq ARRAY or reftype($ref) eq ARRAY) {
                        $step_points = [ map {
                                Point->new->ref(\$_)->parent($point)
                        } @$ref ];
                } else {
                        if (ref($pref) eq SCALAR or reftype($pref) eq SCALAR) {
                                # TODO: without map, it's just one value
                                $step_points = [ map {
                                        Point->new->ref(\$_)->parent($point)
                                } $ref ];
                        }
                }
                push @$new_points, @{ $self->_filter_points($step, $step_points) };
        }
}

# '.'
# no step (neither up nor down), just allow filtering
sub _select_nostep {
        my ($self, $step, $current_points, $new_points) = @_;

        foreach my $point (@{$current_points}) {
                my $step_points = [$point];
                push @$new_points, @{ $self->_filter_points($step, $step_points) };
        }
}

# '..'
# the parent
sub _select_parent {
        my ($self, $step, $current_points, $new_points) = @_;

        foreach my $point (@{$current_points}) {
                my $step_points = [$point->parent];
                push @$new_points, @{ $self->_filter_points($step, $step_points) };
        }
}

# '::ancestor'
# all ancestors (parent, grandparent, etc.) of the current node
sub _select_ancestor {
        my ($self, $step, $current_points, $new_points) = @_;

        foreach my $point (@{$current_points}) {
                my $step_points = [];
                my $parent = $point;
                while ($parent = $parent->parent) {
                        push @$step_points, $parent; # order matters
                }
                push @$new_points, @{ $self->_filter_points($step, $step_points) };
        }
}

# '::ancestor-or-self'
# all ancestors (parent, grandparent, etc.) of the current node and the current node itself
sub _select_ancestor_or_self {
        my ($self, $step, $current_points, $new_points) = @_;

        foreach my $point (@{$current_points}) {
                my $step_points = [$point];
                my $parent = $point;
                while ($parent = $parent->parent) {
                        push @$step_points, $parent; # order matters
                }
                push @$new_points, @{ $self->_filter_points($step, $step_points) };
        }
}

sub ref {
        my ($self) = @_;
        $self->first_point->{ref};
}

sub deref {
        my ($self) = @_;
        ${$self->ref};
}

sub first_point {
        my ($self) = @_;
        $self->current_points->[0];
}

sub all_points {
        my ($self) = @_;
        iarray $self->current_points;
}

sub _iter {
        my ($self) = @_;

        my $iter = iarray $self->current_points;
        return imap { __PACKAGE__->new->current_points([ $_ ]) } $iter;
}

sub isearch
{
        my ($self, $path_str) = @_;
        $self->_search(Data::DPath::Path->new(path => $path_str))->_iter;
}

sub _search
{
        my ($self, $path) = @_;

        no strict 'refs';
        no warnings 'uninitialized';

        my $current_points = $self->current_points;
        my $steps = $path->_steps;
        for (my $i = 0; $i < @$steps; $i++) {
                my $step = $steps->[$i];
                my $lookahead = $steps->[$i+1];
                my $new_points = [];

                if ($step->kind eq ROOT)
                {
                        $self->_select_root($step, $current_points, $new_points);
                }
                elsif ($step->kind eq ANYWHERE)
                {
                        $self->_select_anywhere($step, $current_points, $lookahead, $new_points);
                }
                elsif ($step->kind eq KEY)
                {
                        $self->_select_key($step, $current_points, $new_points);
                }
                elsif ($step->kind eq ANYSTEP)
                {
                        $self->_select_anystep($step, $current_points, $new_points);
                }
                elsif ($step->kind eq NOSTEP)
                {
                        $self->_select_nostep($step, $current_points, $new_points);
                }
                elsif ($step->kind eq PARENT)
                {
                        $self->_select_parent($step, $current_points, $new_points);
                }
                elsif ($step->kind eq ANCESTOR)
                {
                        $self->_select_ancestor($step, $current_points, $new_points);
                }
                elsif ($step->kind eq ANCESTOR_OR_SELF)
                {
                        $self->_select_ancestor_or_self($step, $current_points, $new_points);
                }
                $current_points = $new_points;
        }
        $self->current_points( $current_points );
        return $self;
}

sub match {
        my ($self, $path) = @_;

        $self->_search($dpath)->_all;
}

1;

__END__

=head1 NAME

Data::DPath::Context - Abstraction for a current context that enables incremental searches.

=head1 API METHODS

=head2 new ( %args )

Constructor; creates instance.

Args:

=over 4

=item give_references

Default 0. If set to true value then results are references to the
matched points in the data structure.

=back

=head2 all

Returns all values covered by current context.

If C<give_references> is set to true value then results are references
to the matched points in the data structure.

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

=head2 current_points

Attribute / accessor.

=head2 give_references

Attribute / accessor.

=head1 aliased classes

That's just to make Pod::Coverage happy which does not handle aliased
modules.

=head2 Context

=head2 Point

=head2 Step

=head1 AUTHOR

Steffen Schwigon, C<< <schwigon at cpan.org> >>

=head1 COPYRIGHT & LICENSE

Copyright 2008,2009 Steffen Schwigon.

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
