package Data::DPath;

use warnings;
use strict;

use Mouse;

our $VERSION = '0.01';

use parent 'Exporter';
our @EXPORT_OK = qw(dpath);
our %EXPORT_TAGS = (
                    all => [qw(dpath)]
                   );

use Data::DPath::Path;
use Data::DPath::Context;

has path => ( isa => "Str", is  => "rw" );

sub dpath($)
{
        my ($path) = @_;
        return Data::DPath::Path->new(path => $path);
}

sub get_context($)
{
        my ($path) = @_;
        return Data::DPath::Context->new(path => $path);
}

sub match
{
        my ($data, $path) = @_;
        my $p = new Data::DPath::Path(path => $path);
        return $p->match($data);
}


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

# Note, that hashes don't have an order, as they would have in XML documents.


=pod

=head1 NAME

Data::DPath - DPath is not XPath!

=head1 SYNOPSIS

 use Data::DPath 'dpath';
 my $dpath = dpath('//AAA/*/CCC');
 my $data  = { AAA => 

=cut


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


=head1 ACKNOWLEDGEMENTS


=head1 COPYRIGHT & LICENSE

Copyright 2008 Steffen Schwigon, all rights reserved.

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.


=cut

1; # End of Data::DPath
