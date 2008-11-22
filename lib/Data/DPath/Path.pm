package Data::DPath::Path;

use strict;
use warnings;

use 5.010;

use Moose;
use MooseX::Method::Signatures;

use Data::DPath::Step;
use Data::Dumper;

has 'path'   => ( isa => "Str",      is  => "rw" );
has '_steps' => ( isa => "ArrayRef", is  => "rw", auto_deref => 1); # , lazy_build => 1 );

# essentially the Path parser
method _build__steps {
        $self->_steps([]);
        my @parts = split qr[/], $self->path;
        foreach (@parts) {
                my ($part, $filter) =
                    m/
                        ([^\[]*)         # part
                            (\[.*\])     # part filter
                                /x;
                my $kind;
                given ($part) {
                        when ('*') { $kind = 'ARRAY' }
                        default    { $kind = 'HASH' }
                }
                $self->_steps ( [ $self->_steps,
                                  new Data::DPath::Step( part   => $_,
                                                         kind   => $kind,
                                                         filter => $filter )
                                ]);
        }
}

sub match
{
        #return ('affe', 'zomtec');
        return ( ['XXX', 'YYY', 'ZZZ'] );
}

1;

__END__

=head1 NAME

Data::DPath::Path

Abstraction for a DPath.

Take a string description, parse it, bundle class with overloading,
etc.

=head2 all

Returns all values covered by current context.

=head2 search

Return new context with path relative to current context.

=head2 match

Same as search()->all();

=cut
