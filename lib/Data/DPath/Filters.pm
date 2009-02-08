package Data::DPath::Filters;

use 5.010;
use strict;
use warnings;

our $idx;

sub affe {
        return $_ eq 'affe' ? 1 : 0;
}

sub idx { $idx }

1;

__END__

=head1 NAME

Data::DPath::Filters - Magic DWIM functions available inside filter conditions

=head1 API METHODS

=head2 affe

Mysterious test function. Will vanish. Soon.

=head2 index

Returns the current index inside array elements.

=head1 AUTHOR

Steffen Schwigon, C<< <schwigon at cpan.org> >>

=head1 COPYRIGHT & LICENSE

Copyright 2008,2009 Steffen Schwigon.

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
