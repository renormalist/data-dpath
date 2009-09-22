package Data::DPath;

use strict;
use warnings;

our $VERSION = '0.30';

our $DEBUG = 0;

use Data::DPath::Path;
use Data::DPath::Context;

sub build_dpath {
        return sub ($) {
                my ($path) = @_;
                Data::DPath::Path->new(path => $path);
        };
}

sub build_dpathr {
        return sub ($) {
                my ($path) = @_;
                Data::DPath::Path->new(path => $path, give_references => 1);
        };
}

use Sub::Exporter -setup => {
                             exports => [ dpath => \&build_dpath, dpathr => \&build_dpathr ],
                             groups  => { all   => [ 'dpath', 'dpathr' ] },
                            };

sub get_context {
        my ($class, $data, $path) = @_;
        Data::DPath::Context->new(path => $path);
}

sub match {
        my ($class, $data, $path) = @_;
        Data::DPath::Path->new(path => $path)->match($data);
}

# ------------------------------------------------------------

1;

__END__

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
    $data ~~ dpath '//AAA/*[ key =~ /CC/ ]'     # filter by regex matching keys
    $data ~~ dpath '//CCC/*[ value eq "RR2" ]'  # filter by values of hashes

You can get references into the C<$data> data structure by using C<dpathr>:

    $data ~~ dpathr '/AAA/*/CCC'
    $data ~~ dpathr '/AAA/BBB/CCC/../..'
    $data ~~ dpathr '//AAA'
    # etc.

See full details C<t/data_dpath.t>.

=head1 ABOUT

With this module you can address points in a datastructure by
describing a "path" to it using hash keys, array indexes or some
wildcard-like steps. It is inspired by XPath but differs from it.

=head2 Why not XPath?

XPath is for XML. DPath is for data structures, with a stronger Perl
focus.

Although XML documents are data structures, they are special.

Elements in XML always have an order which is in contrast to hash keys
in Perl.

XML elements names on same level can be repeated, not so in hashes.

XML element names are more limited than arbitrary strange hash keys.

XML elements can have attributes and those can be addressed by XPath;
Perl data structures do not need this. On the other side, data
structures in Perl can contain blessed elements, DPath can address
this.

XML has namespaces, data structures have not.

Arrays starting with index 1 as in XPath would be confusing to read
for data structures.

DPath allows filter expressions that are in fact just Perl expressions
not an own sub language as in XPath.

=head2 Comparison with Data::Path

There is a similar approach on CPAN, L<Data::Path|Data::Path>. Here is
a comparison matrix between L<Data::Path|Data::Path> and
L<Data::DPath|Data::DPath>.

(Warning: B<alpha> grade comparison ahead, not yet fully verified,
only evaluated by reading the source. Speed comparison not really
benchmarked.)

 ---------------------------------------------------------------------
 Criteria             Data::Path           Data::DPath
 ---------------------------------------------------------------------
 
 real XPath syntax    no                   no
 
 ---------------------------------------------------------------------
 
 allow strange,       YES                  YES
 non-xml but
 perl-like            although
 hash keys            limited,
                      see next
 ---------------------------------------------------------------------
 
 allows special       no                   YES
 chars of own
 path syntax in                            you can quoting everything
 hash keys
 ("/[]|*.")
 
 ---------------------------------------------------------------------
 
 call subs in         YES                  no
 data structure,
 like:
 /method()
 ---------------------------------------------------------------------
 
 callbacks on         YES                  no
 not found keys
 
 ---------------------------------------------------------------------
 
 element "//"         no                   YES
 for "ANYWHERE"
 (//foo/bar)
 
 ---------------------------------------------------------------------
 
 element "."          no                   YES
 for "NOSTEP" or
 "actual position"
 (/.[filter expr])
 
 ---------------------------------------------------------------------
 
 element ".."         no                   YES
 for "PARENT"
 (//foo/..)
 
 ---------------------------------------------------------------------
 
 element "*"          no                   YES
 for "ANYSTEP" or
 "all subelements"
 (/foo/*)
 
 ---------------------------------------------------------------------
 
 array access         YES                  YES
 like /foo[4]
                      although             including negative indexes
                      limited              and whitespace awareness
 ---------------------------------------------------------------------
 
 complex              no                   YES
 filter expressions
 like                                      full Perl expressions
 /foo[size == 3] or                        plus sugar functions,
 /.[isa("Foo::Bar")]                       some minor limitations
                                           (no "/" allowed in expr)
 
 ---------------------------------------------------------------------
 
 works with           YES                  YES
 blessed subelements
 
 ---------------------------------------------------------------------
 
 arrays start         YES                  YES
 with index 0
 (in contrast
 to 1 as in XPath)
 
 ---------------------------------------------------------------------
 
 handling of          croak               RETURN EMPTY
 not matching
 paths                but can be
                      overwritten
                      as callback
 
 ---------------------------------------------------------------------
 
 usage sugar          none                overloaded '~~' operator
 
 ---------------------------------------------------------------------
 
 Speed                FAST                slow
 
                      - raw Perl          - based on Moose
                      - considered fast   - slow startup time
                                          - probably comparable
                                            speed with expression
                                            that Data::Path handles
                                          - slow on fuzzy paths,
                                            eg. with many "//" in it
 
 ---------------------------------------------------------------------
 
 Perl Versions        5.6 - 5.11          5.10 .. 5.11
 
 ---------------------------------------------------------------------
 
 Install chance       100%                40%
 (http://deps                             (for Perl 5.10+)
  .cpantesters
  .org)
 
 ---------------------------------------------------------------------


=head3 Summary

Generally L<Data::Path|Data::Path> is for simpler use cases but does
not suffer from surrounding meta problems: it has few dependencies, is
fast and works on practically every Perl version.

Whereas L<Data::DPath|Data::DPath> provides more XPath like features
but regarding speed and Perl compatibility suffers a bit from it's
new-school dependency stack: Perl 5.10+, Moose and MooseX::Declare.

=head1 Security warning

B<Watch out!> This module C<eval>s parts of provided dpaths (filter
expressions). Don't use it if you don't trust your paths.

Maybe I will provide a switch-off-complex-filtering option in a later
version. Tell me what you think or when you need it.

=head1 FUNCTIONS

=head2 dpath( $path )

Meant as the front end function for everyday use of Data::DPath. It
takes a path string and returns a C<Data::DPath::Path> object on which
the match method can be called with data structures and the operator
C<~~> is overloaded.

The function is prototyped to take exactly one argument so that you
can omit the parens in many cases.

See SYNOPSIS.

=head2 dpathr( $dpath )

Same as C<dpath> but toggles that results are references to the
matched points in the data structure.

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
your code more readable.


=head1 THE DPATH LANGUAGE

=head2 Synopsis

 /AAA/BBB/CCC
 /AAA/*/CCC
 //CCC/*
 //CCC/*[2]
 //CCC/*[size == 3]
 //CCC/*[size != 3]
 /"EE/E"/CCC
 /AAA/BBB/CCC/*[1]
 /AAA/BBB/CCC/*[ idx == 1 ]
 //AAA/BBB/*[key eq "CCC"]
 //AAA/*[ key =~ /CC/ ]
 //CCC/*[value eq "RR2"]
 //.[ size == 4 ]
 /.[ isa("Funky::Stuff") ]/.[ size == 5 ]/.[ reftype eq "ARRAY" ]

=head2 Modeled on XPath

The basic idea is that of XPath: define a way through a datastructure
and allow some funky ways to describe fuzzy ways. The syntax is
roughly looking like XPath but in fact have not much more in common.

=head3 Some wording

I call the whole path a, well, B<path>.

It consists of single (B<path>) B<steps> that are divided by the path
separator C</>.

Each step can have a B<filter> appended in brackets C<[]> that narrows
down the matching set of results.

Additional functions provided inside the filters are called, well,
B<filter functions>.

Each step has a set of C<point>s relative to the set of points before
this step, all starting at the root of the data structure.

=head2 Special elements

=over 4

=item * C<//>

Anchors to any hash or array inside the data structure below the
currently found points (or the root).

Typically used at the start of a path to anchor the path anywhere
instead of only the root node:

  //FOO/BAR

but can also happen inside paths to skip middle parts:

 /AAA/BBB//FARAWAY

This allows any way between C<BBB> and C<FARAWAY>.

=item * C<*>

Matches one step of any value relative to the current points (or the
root). This step might be any hash key or all values of an array in
the step before.

=item * C<..>

Matches the parent element relative to the current points.

=item * C<.>

A "no step". This keeps passively at the current points, but allows
incrementally attaching filters to points or to otherwise hard to
reach steps, like the top root element C</>. So you can do:

 /.[ FILTER ]

or chain filters:

 /AAA/BBB/.[ filter1 ]/.[ filter2 ]/.[ filter3 ]

This way you do not need to stuff many filters together into one huge
killer expression and can more easily maintain them.

See L<Filters|Filters> for more details on filters.

=item * If you need those special elements to be not special but as
key names, just quote them:

 /"*"/
 /"*"[ filter ]/
 /".."/
 /".."[ filter ]/
 /"."/
 /"."[ filter ]/
 /"//"/
 /"//"[ filter ]/

=back

=head2 Difference between C</step[filter]> vs. C</step/.[filter]>
vs. C</step/*[filter]>

The filter applies to the matched points of the step to which it is
applied, therefore C</part[filter]> is the normal form. The "no step"
stays on the current step, therefore C</part/.[filter]> should be the
same as C</part[filter]>.

It's different for C</part/*[filter]>. That means, take all the sub
elements ("*") after "step" and apply the filter to those. The most
common use is to take "all" elements of an array and chose one element
via index: C</step/*[4]/>. This takes the fifth element of the array
inside "step".

=head2 Filters

Filters are conditions in brackets. They apply to all elements that
are directly found by the path part to which the filter is appended.

Internally the filter condition is part of a C<grep> construct
(exception: single integers, they choose array elements). See below.

Examples:

=over 4

=item C</FOO/*[2]/>

A single integer as filter means choose an element from an array. So
the C<*> finds all subelements that follow current step C<FOO> and the
C<[2]> reduces them to only the third element (index starts at 0).

=item C</FOO/*[ idx == 2 ]/>

The C<*> is a step that matches all elements after C<FOO>, but with
the filter only those elements are chosen that are of index 2. This is
actually the same as just C</FOO/*[2]>.

=item C</FOO/*[key eq "CCC"]>

In all elements after C<FOO> it matches only those elements whose key
is "CCC".

=item C</FOO/*[key =~ /CCC/ ]>

In all elements after step C<FOO> it matches only those elements whose
key matches the regex C</CCC/>. It is actually just Perl code inside
the filter which works in a grep{}-like context.

=item C<//FOO/*[value eq "RR2"]>

Find elements below C<FOO> that have the value C<RR2>.

Combine this with the parent step C<..>:

=item C<//FOO/*[value eq "RR2"]/..>

Find such an element below C<FOO> where an element with value C<RR2>
is contained.

=item C<//FOO[size E<gt>= 3]>

Find C<FOO> elements that are arrays or hashes of size 3 or bigger.

=back

=head2 Filter functions

The filter condition is internally part of a C<grep> over the current
subset of values. So you can write any condition like in a grep and
also use the variable C<$_>.

Additional filter functions are available that are usually written to
use $_ by default. See L<Data::DPath::Filters|Data::DPath::Filters>
for complete list of available filter functions.

Here are some of them:

=over 4

=item idx

Returns the current index inside array elements.

Please note that the current matching elements might not be in a
defined order if resulting from anything else than arrays.

=item size

Returns the size of the current element. If it is a arrayref it
returns number of elements, if it's a hashref it returns number of
keys, if it's a scalar it returns 1, everything else returns -1.

=item key

Returns the key of the current element if it is a hashref. Else it
returns undef.

=item value

Returns the value of the current element. If it is a hashref return
the value. If a scalar return the scalar. Else return undef.

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

=head1 INTERNAL METHODS

To make pod coverage happy.

=head2 build_dpath

Prepares internal attributes for I<dpath>.

=head2 build_dpathr

Prepares internal attributes for I<dpathr>.


=head1 AUTHOR

Steffen Schwigon, C<< <schwigon at cpan.org> >>

=head1 CONTRIBUTIONS

Florian Ragwitz (cleaner exports, $_ scoping, general perl consultant)

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

Copyright 2008,2009 Steffen Schwigon.

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

There are other modules on CPAN which are related to finding elements
in data structures.

=over 4

=item Data::Path

http://search.cpan.org/dist/Data-Path

=item XML::XPathEngine

http://search.cpan.org/dist/XML-XPathEngine

=item Tree::XPathEngine

http://search.cpan.org/dist/Tree-XPathEngine

=item Class::XPath

http://search.cpan.org/dist/Class-XPath

=item Hash::Path

http://search.cpan.org/dist/Hash-Path

=back

=cut

# End of Data::DPath
