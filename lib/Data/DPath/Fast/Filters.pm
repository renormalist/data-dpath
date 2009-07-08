package Data::DPath::Fast::Filters;

use 5.010;
use strict;
use warnings;

use Data::Dumper;
use Scalar::Util;

our $idx;

sub affe {
        return $_ eq 'affe' ? 1 : 0;
}

sub idx { $idx }

sub size
{
        no warnings 'uninitialized';
        return scalar @$_      if Scalar::Util::reftype $_  eq 'ARRAY';
        return scalar keys %$_ if Scalar::Util::reftype $_  eq 'HASH';
        return  1              if Scalar::Util::reftype \$_ eq 'SCALAR';
        return -1;
}

sub key
{
        no warnings 'uninitialized';
        return (keys %$_)[0] if Scalar::Util::reftype $_  eq 'HASH';
        return undef;
}

# same as key() + debug info
sub _key
{
        no warnings 'uninitialized';
        say "*** key ", Scalar::Util::reftype($_), " -- ", Dumper($_ ? $_ : "UNDEF");
        say "        ", join (", ", keys %$_) if Scalar::Util::reftype $_  eq 'HASH';
        return (keys %$_)[0] if Scalar::Util::reftype $_  eq 'HASH';
        return undef;
}

sub value
{
        #print STDERR "*** value ", (keys %$_)[0], " ", Dumper($_ ? $_ : "UNDEF");
        no warnings 'uninitialized';
        return (values %$_)[0] if (defined $_ and Scalar::Util::reftype  $_  eq 'HASH');
        return $_              if (defined $_ and Scalar::Util::reftype \$_  eq 'SCALAR');
        return undef;
}

sub isa {
        my ($classname) = @_;

        #print STDERR "*** value ", Dumper($_ ? $_ : "UNDEF");
        return $_->isa($classname) if (defined $_ and Scalar::Util::blessed $_);
        return undef;
}

sub reftype {
        my ($refname) = @_;

        #print STDERR "*** value ", Dumper($_ ? $_ : "UNDEF");
        return Scalar::Util::reftype($_) if not $refname;
        return (Scalar::Util::reftype($_) eq $refname);
}

# sub parent, Eltern-Knoten liefern
# nextchild, von parent und mir selbst
# previous child
# "." als aktueller Knoten, kind of "no-op", daran aber Filter verknüpfbar, löst //.[filter] und /.[filter]

# IDEA: functions that return always true, but track stack of values, eg. last taken index
#
#    //AAA/*[ _push_idx ]/CCC[ condition ]/../../*[ idx == pop_idx + 1]/
#
# This would take a way down to a filtered CCC, then back again and take the next neighbor.

# help the CPAN indexer
package Data::DPath::Fast::Filters;

1;

__END__

=pod

=head1 NAME

Data::DPath::Fast::Filters - Magic functions available inside filter conditions

=head1 API METHODS

=head2 affe

Mysterious test function. Will vanish. Soon. Or will it really? No,
probably not. I like it. :-)

Returns true if the value eq "affe".

=head2 idx

Returns the current index inside array elements.

Please note that the current matching elements might not be in a
defined order if resulting from anything else than arrays.

=head2 size

Returns the size of the current element. If it is a hash ref it
returns number of elements, if hashref it returns number of keys, if
scalar it returns 1, everything else returns -1.

=head2 key

Returns the key of the current element if it is a hashref. Else it
returns undef.

=head2 value

Returns the value of the current element. If it is a hashref return
the value. If a scalar return the scalar. Else return undef.

=head2 isa

Frontend to UNIVERSAL::isa. True if the current elemt is_a given
class.

=head2 reftype

Frontend to Scalar::Util::reftype.

If argument given it checks whether reftype($_) equals the argument
and returns true/false.

If no argument is given it returns reftype of current element $_ and
you can do comparison by yourself with C<eq>, C<=~>, C<~~> or
whatever.

=head1 AUTHOR

Steffen Schwigon, C<< <schwigon at cpan.org> >>

=head1 COPYRIGHT & LICENSE

Copyright 2008,2009 Steffen Schwigon.

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
