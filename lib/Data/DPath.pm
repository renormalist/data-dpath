use MooseX::Declare;

use 5.010;

class Data::DPath {

        our $DEBUG = 0;

        use Data::DPath::Path;
        use Data::DPath::Context;

        sub build_dpath {
                return sub ($) {
                        my ($path) = @_;
                        new Data::DPath::Path(path => $path);
                };
        }

        use namespace::clean -except => 'meta';

        use Sub::Exporter -setup => {
                exports => [ dpath => \&build_dpath ],
                groups  => { all  => [ 'dpath' ] },
        };

        method get_context (Any $data, Str $path) {
                new Data::DPath::Context(path => $path);
        }

        method match (Any $data, Str $path) {
                Data::DPath::Path->new(path => $path)->match($data);
        }

        # ------------------------------------------------------------

}

package Data::DPath;
our $VERSION = '0.04';

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
    @resultlist = dpath('/AAA/*/CCC')->match($data);   # ( ['XXX', 'YYY', 'ZZZ'], [ 'RR1', 'RR2', 'RR3' ] )
    $resultlist = $data ~~ dpath '/AAA/*/CCC';         # [ ['XXX', 'YYY', 'ZZZ'], [ 'RR1', 'RR2', 'RR3' ] ]

Various other example paths from C<t/data_dpath.t> (not neccessarily
fitting to above data structure):

    $data ~~ dpath '/AAA/*/CCC'
    $data ~~ dpath '/AAA/BBB/CCC/../..'    # parents  (..)
    $data ~~ dpath '//AAA'                 # anywhere (//)
    $data ~~ dpath '//AAA/*'               # anywhere + anystep
    $data ~~ dpath '//AAA/*[size == 3]'    # filter by arrays/hash size
    $data ~~ dpath '//AAA/*[size != 3]'    # filter by arrays/hash size
    $data ~~ dpath '/"EE/E"/CCC'           # quote strange keys
    $data ~~ dpath '/AAA/BBB/CCC/*[1]'     # filter by array index
    $data ~~ dpath '/AAA/BBB/CCC/*[ idx == 1 ]' # same, filter by array index
    $data ~~ dpath '//AAA/BBB/*[key eq "CCC"]'  # filter by exact keys
    $data ~~ dpath '//AAA/*[ key =~ m(CC) ]'    # filter by regex matching keys
    $data ~~ dpath '//AAA/"*"[ key =~ /CC/ ]'   # when path is quoted, filter can contain slashes
    $data ~~ dpath '//CCC/*[value eq "RR2"]'    # filter by values of hashes

See full details C<t/data_dpath.t>.

=head1 ALPHA WARNING

I still experiment in details of semantics, especially final names of
the available filter functions and some edge cases like path steps
with just filter, or similar.

I will name this module v1.00 when I consider it stable.

In the mean time the worst thing that might happen would be slightly
changes to your dpaths. No current features will get lost.

=head1 FUNCTIONS

=head2 dpath( $path )

Meant as the front end function for everyday use of Data::DPath. It
takes a path string and returns a C<Data::DPath::Path> object on which
the match method can be called with data structures and the operator
C<~~> is overloaded. See SYNOPSIS.

=head1 METHODS

=head2 match( $data, $path )

Returns an array of all values in C<$data> that match the C<$path>.

=head2 get_context( $path )

Returns a C<Data::DPath::Context> object that matches the path and can
be used to incrementally dig into it.

=head1 OPERATOR

=head2 ~~

Does a C<match> of a dpath against a data structure.

Due to the B<matching> nature of DPath the operator C<~~> should make
your code more readable. It works commutative (meaning C<data ~~
dpath> is the same as C<dpath ~~ data>).



=head1 THE DPATH LANGUAGE

=head2 Synopsis

... TODO ...

=head2 Special elements

=over 4

=item * C<//>

Anchors to any hash or array inside the data structure below the
current step (or the root).

Typically used at the start of a path to anchor the path anywhere
instead of only the root node:

  //FOO/BAR

but can also happen inside paths to skip middle parts:

 /AAA/BBB//FARAWAY

This allows any way between C<BBB> and C<FARAWAY>.

=item * C<*>

Matches one step of any value relative to the current step (or the
root). This step might be any hash key or all values of an array in
the step before.

=back

=head2 Difference between C</part[filter]> vs. C</part/[filter]>
vs. C</part/*[filter]>

... TODO ...

=head2 Filters

Filters are conditions in brackets. They apply to all elements that
are directly found by the path part to which the filter is appended.

Internally the filter condition is part of a C<grep> construct
(exception: single integers, they choose array elements). See below.

Examples:

=over 4

=item C</*[2]/>

A single integer as filter means choose an element from an array. So
the C<*> finds all subelements on current step and the C<[2]> reduces
them to only the third element (index starts at 0).

=item C</FOO[ref eq 'ARRAY']/>

The C<FOO> is a step that matches a hash key C<FOO> and the filter
only takes the element if it is an 'ARRAY'.

=back

See L<Filter functions|Filter functions> for more functions like
C<isa> and C<ref>.

=head2 Filter functions

(not yet implemented)

The filter condition is internally part of a C<grep> over the current
subset of values. So you can also use the variable C<$_> in it:

  /*[$_->isa eq 'Some::Class']/

Additional filter functions are available that are usually prototyped
to take $_ by default:

=over 4

=item C<index>

The index of an element. So these two filters are equivalent:

 /*[2]/
 /*[index == 2]/

=item C<ref>

Perl's C<ref>.

=item C<isa>

Perl's C<isa>.

=back

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

Backslashes in path parts don't need to be escaped, except before
escaped quotes (but see below on L<Backslash handling|Backslash
handling>).

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

=head2 Backslash handling

If you know backslash in Perl strings, skip this paragraph, it should
be the same.

It is somewhat difficult to create a backslash directly before a
quoted double-quote.

Inside the DPath language the typical backslash rules of apply that
you already know from Perl B<single quoted> strings. The challenge is
to specify such strings inside Perl programs where another layer of
this backslashing applies.

Without quotes it's all easy. Both a single backslash C<\> and a
double backslash C<\\> get evaluated to a single backslash C<\>.

Extreme edge case by example: To specify a plain hash key like this:

  "EE\E5\"

where the quotes are part of the key, you need to escape the quotes
and the backslash:

  \"EE\E5\\\"

Now put quotes around that to use it as DPath hash key:

  "\"EE\E5\\\""

and if you specify this in a Perl program you need to additionally
escape the backslashes (i.e., double their count):


  "\"EE\E5\\\\\\""

As you can see, strangely, this backslash escaping is only needed on
backslashes that are not standing alone. The first backslash before
the first escaped double-quote is ok to be a single backslash.

All strange, isn't it? At least it's (hopefully) consistent with
something you know (Perl, Shell, etc.).

=head1 AUTHOR

Steffen Schwigon, C<< <schwigon at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-data-dpath at
rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Data-DPath>. I will
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


=head1 COPYRIGHT & LICENSE

Copyright 2008 Steffen Schwigon.

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.


=cut

# End of Data::DPath
