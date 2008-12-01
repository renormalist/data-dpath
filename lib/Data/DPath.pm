use MooseX::Declare;

use 5.010;

class Data::DPath {

        our $DEBUG = 0;

        use Data::DPath::Path;
        use Data::DPath::Context;
        use Sub::Exporter -setup => { exports =>           [ 'dpath' ],
                                      groups  => { all  => [ 'dpath' ] },
                                    };

        sub dpath($) {
                my ($path) = @_;
                new Data::DPath::Path(path => $path);
        }

        method get_context (Any $data, Str $path) {
                new Data::DPath::Context(path => $path);
        }

        method match (Any $data, Str $path) {
                Data::DPath::Path->new(path => $path)->match($data);
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
                 AAA  => { BBB => { CCC  => [ qw/ XXX YYY ZZZ / ] },
                           RRR => { CCC  => [ qw/ RR1 RR2 RR3 / ] },
                           DDD => { EEE  => [ qw/ uuu vvv www / ] },
                         },
                };
    @resultlist = dpath('/AAA/BBB/CCC')->match($data);
    # ( ['XXX', 'YYY', 'ZZZ'] )
    
    @resultlist = dpath('/AAA/*/CCC')->match($data);
    # ( ['XXX', 'YYY', 'ZZZ'], [ 'RR1', 'RR2', 'RR3' ] )
    
    @resultlist = dpath('/AAA/BBB/CCC/../../DDD')->match($data);
    # ( { EEE => [ qw/ uuu vvv www / ] } )

See currently working paths in C<t/data_dpath.t>.

=head1 INSTALLATION

 perl Makefile.PL
 make
 make test
 make install

=head1 FUNCTIONS

=head2 dpath( $path )

Meant as the front end function for everyday use of Data::DPath. It
takes a path string and returns a C<Data::DPath::Path> object on which
the match method can be called with data structures. See SYNOPSIS.

=head1 METHODS

=head2 match( $data, $path )

Returns an array of all values in C<$data> that match the C<$path>.

=head2 get_context( $path )

Returns a C<Data::DPath::Context> object that matches the path and can
be used to incrementally dig into it.

=head1 THE DPATH LANGUAGE

=head2 Synopsis

=head2 Special elements

=over 4

=item * C<//>

=item * C<*>

=back

=head2 Different ways for the filter: C</part[filter]> vs. C</path/[filter]>.

=head2 Special characters

There are 4 special characters: the slash C</>, paired brackets C<[]>,
the double-quote C<"> and the backslash C<\>. They are needed and
explained in a logical order.

Path parts are divided by the slash </>.

A path part can be extended by a filter with appending an expression
in brackets C<[]>.

To contain slashes in hash keys, they can be surrounded by double
quotes C<">.

To contain double-quotes in hash keys they can be escaped with
backslash C<\>.

Backslashes in path parts don't need to be escaped. (B<Bug warning>:
This is how it B<should> be. I think the normal handling of
backslashes is currently broken. And another challenge is how to
create backslashes in Perl due to their special handling in string
interpolation.)

Filters of parts are already sufficiently divided by the brackets
C<[]>. There is no need to handle special characters in them, not even
double-quotes. The filter expression just needs to be balanced on the
brackets.

So this is the order how to create paths:

=over 4

=item 1. backslash double-quotes that are part of the key

=item 2. put double-quotes around the resulting key

=item 3. append the filter expression after the key

=item 4. separate several path parts with slashes

=back

=head1 AUTHOR

Steffen Schwigon, C<< <schwigon at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-data-dpath at
rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Data-DPath>. I will
be notified, and then you'll automatically be notified of progress on
your bug as I make changes.

=head2 Backslash handling

I think it is somewhat difficult to create a backslash directly before
a quoted double-quote. That's maybe due to Perl's special backslash
handling. The following key does not get parsed correctly (where the
inner double-quotes are meant as part of the key and the seemingly
doble backslash is in fact only a single backslash followed by the
second inner escaped double-quote):

  /"\"EE\E5\\""/

So you need to backslash the backslashes again:

  /"\"EE\E5\\\\\""/

to mean what you want, i.e.:

 "EE\E5\"

as the plain key.

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

Copyright 2008 Steffen Schwigon.

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.


=cut

# End of Data::DPath
