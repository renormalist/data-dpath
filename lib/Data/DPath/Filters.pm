package Data::DPath::Filters;

use strict;
use warnings;

our $index;

sub affe {
        return $_ eq 'affe' ? 1 : 0;
}

sub index { $index }

1;

