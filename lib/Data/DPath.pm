use MooseX::Declare;

use 5.010;
use strict;
use warnings;

class Data::DPath extends Exporter {

        our $DEBUG = 0;

        use Data::DPath::Path;
        use Data::DPath::Context;
        use Sub::Exporter -setup => { exports =>           [ 'dpath' ],
                                      groups  => { all  => [ 'dpath' ] },
                                    };

        sub dpath {
                my ($path) = @_;
                return Data::DPath::Path->new(path => $path);
        }

        method get_context (Any $data, Str $path) {
                return Data::DPath::Context->new(path => $path);
        }

        method match (Any $data, Str $path) {
                my $dpath = new Data::DPath::Path(path => $path);
                return $dpath->match($data);
        }

}

# ------------------------------------------------------------

# old school way so Module::Build can extract VERSION
# must be after class {} declaration above, else namespaces double and universes collapse.
package Data::DPath;
our $VERSION = '0.01';

1;

__END__

# Idea collection
#
# ::Tree
#   ::Node   (references to current expressions)
#     :: NodeSet   (collection of ::Node's)
# ::Context
#      same as ::NodeSet (?)
# ::Step
#       ::Step::Hashkey
#       ::Step::Any
#       ::Step::Parent
#       ::Step::Filter::Grep
#       ::Step::Filter::ArrayIndex
# ::Expression (inside brackets)
#    single int: array index
#    else:       perl filter expression, as in grep, balanced quote
#                $_ available
# ::Grammar --> ::Step::(Hashkey, Any, Grep, ArrayIndex)
#      ::Joins (path1 | path2)
#      ::LocationPath vs. Path (first is a basic block, second the whole)
#      // is just an empty step, make that empty step special, not the path string

# Note, that hashes don't have an order, as they would have in XML documents.


=pod

=head1 NAME

Data::DPath - DPath is not XPath!

=head1 SYNOPSIS

    use Data::DPath 'dpath';
    my $data  = {
                 AAA  => { BBB   => { CCC  => [ qw/ XXX YYY ZZZ / ] },
                           DDD   => { EEE  => [ qw/ uuu vvv www / ] },
                         },
                };
    @resultlist = dpath('/AAA/BBB/CCC')->match($data);
    ( ['XXX', 'YYY', 'ZZZ'] )
    @resultlist = dpath('/AAA/*/CCC')->match($data);
    # ( ['XXX', 'YYY', 'ZZZ'] )

See currently working paths in B<t/data_dpath.t>.

=head1 FUNCTIONS

=head2 dpath

Meant as B<the> front end function for everyday use of Data::DPath. It
takes a path string and returns a Data::DPath::Path object for which
smart matching (C<~~>) is overloaded. See SYNOPSIS.

=head1 METHODS

=head2 match($data, $path)

Returns all values in B<data> that match the B<path> as an array.

=head2 get_context($path)

Returns a Data::DPath::Context object that matches the path and can be
used to incrementally dig into it.


=head1 AUTHOR

Steffen Schwigon, C<< <schwigon at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-data-dpath at
rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Data-DPath>.  I will
be notified, and then you'll automatically be notified of progress on
your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Data::DPath


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Data-DPath>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Data-DPath>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Data-DPath>

=item * Search CPAN

L<http://search.cpan.org/dist/Data-DPath>

=back


=head1 REPOSITORY

The public repository is hosted on github:

  git clone git://github.com/renormalist/data-dpath.git


=head1 ACKNOWLEDGEMENTS


=head1 COPYRIGHT & LICENSE

Copyright 2008 Steffen Schwigon, all rights reserved.

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.


=cut

# End of Data::DPath
