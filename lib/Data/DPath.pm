package Data::DPath;

use warnings;
use strict;

our $VERSION = '0.01';

# ----- SYNOPSIS ----------------------------------------

use Data::DPath 'dpath';

my $dpath = dpath('//AAA/*/CCC');
my $data  = {
             AAA  => { BBB   => { CCC  => [ qw/ XXX YYY ZZZ / ] } },
             some => { where => { else => {
                                           AAA => { BBB => { CCC => 'affe' } },
                                          } } },
             strange_keys => { 'DD DD' => { 'EE/E' => { CCC => 'zomtec' } } },
            };

# classic calls
@resultlist = $dpath->match($data);
@resultlist = Data::DPath->find($data, '//AAA/*/CCC');
# ( ['XXX', 'YYY', 'ZZZ'], 'affe' )

# via Perl 5.10 smart matching

@resultlist = $data ~~ $dpath;
@resultlist = $data ~~ dpath('//AAA/*/CCC');
@resultlist = $data ~~ dpath '//AAA/*/CCC';
# ( ['XXX', 'YYY', 'ZZZ'], 'affe' )

# filter
@resultlist = $data ~~ dpath '//AAA/*/CCC[$#_ == 2]'; # array with 3 elements (last index is 2)
@resultlist = $data ~~ dpath '//AAA/*/CCC[@_  == 3]'; # array with 3 elements
# same as
@resultlist = $data ~~ dpath '//AAA/*/CCC/[$#_ == 2]';
@resultlist = $data ~~ dpath '//AAA/*/CCC/[@_  == 3]';
# ( ['XXX', 'YYY', 'ZZZ'] )


@resultlist = $data ~~ dpath '//AAA/*/CCC/*';
# ( 'XXX', 'YYY', 'ZZZ', 'affe' )

@resultlist = $data ~~ dpath '/AAA/*/CCC/*';
# ( 'XXX', 'YYY', 'ZZZ' )

@resultlist = $data ~~ dpath '/AAA/*/CCC/* | /some/where/else/AAA/BBB/CCC';
# ( 'XXX', 'YYY', 'ZZZ', 'affe' )

@resultlist = $data ~~ dpath '/AAA/*/CCC/*[2]';
# ( 'ZZZ' )

@resultlist = $data ~~ dpath '//AAA/*/CCC/*[2]';
# ( 'ZZZ' )

@resultlist = $data ~~ dpath '/strange_keys/DD DD/EE\/E/CCC';
@resultlist = $data ~~ dpath '/strange_keys/"DD DD"/"EE/E"/CCC';
#@resultlist = $data ~~ dpathx '.', '.strange_keys.DD DD.EE/E.CCC'; # allow different step separator, rivals parent step ".."
# ( 'zomtec' )

# context objects for incremental searches
$context = Data::DPath->get_context($data, '//AAA/*/CCC');
$context->find_all();
# ( ['XXX', 'YYY', 'ZZZ'], 'affe' )

# dpath inside context, same as: Data::DPath->find($data, '//AAA/*/CCC/*[2]')
$context->find('/*[2]');
$context ~~ dpath '/*[2]';
#$context ~~ dpathx '.', '.*[2]';
# ( 'ZZZ' )

# ----------------------------------------

my $data2 = [
             'UUU',
             'VVV',
             'WWW',
             { AAA  => { BBB   => { CCC  => [ qw/ XXX YYY ZZZ / ] } } },
            ];

@resultlist = $data2 ~~ dpath '/*';
# ( 'UUU', 'VVV', 'WWW', { AAA  => { BBB   => { CCC  => [ qw/ XXX YYY ZZZ / ] } } } )

@resultlist = $data2 ~~ dpath '/*[2]';
# ( 'WWW' )

@resultlist = $data2 ~~ dpath '//*[2]';
# ( 'WWW', 'ZZZ' )

@resultlist = $data2 ~~ dpath '/*[3]';
# ( { AAA  => { BBB   => { CCC  => [ qw/ XXX YYY ZZZ / ] } } } )

# ----------------------------------------

my $data3  = {
              AAA  => bless( { BBB => { CCC  => [ qw/ XXX YYY ZZZ / ] } }, "Foo::Bar"), # blessed BBB
              some => { where => { else => {
                                            AAA => { BBB => { CCC => 'affe' } }, # plain BBB
                                           } } },
              neighbourhoods => [
                                 { 'DDD' => { EEE => { F1 => 'affe',
                                                       F2 => 'tiger',
                                                       F3 => 'fink',
                                                       F4 => 'star',
                                                     },
                                              FFF => 'interesting value' }
                                 },
                                 { 'DDD' => { EEE => { F1 => 'bla',
                                                       F2 => 'bli',
                                                       F3 => 'blu',
                                                       F4 => 'blo',
                                                     },
                                              FFF => 'boring value' }
                                 },
                                ],
             };

@resultlist = $data3 ~~ dpath '//AAA/BBB[ref($_) eq "Foo::Bar"]/CCC';
# ( ['XXX', 'YYY', 'ZZZ'] )

# parent step
@resultlist = $data3 ~~ dpath '//DDD/EEE/F1[$_ eq "affe"]/../FFF'; # the DDD/FFF where the neighbor DDD/EEE/F1 == "affe"
# ( 'interesting value' )

# filter expressions can directly or indirectly follow a step (without or with slash), so this is the same
@resultlist = $data3 ~~ dpath '//DDD/EEE/F1/[$_ eq "affe"]/../FFF';
# ( 'interesting value' )

# same via direct access
@resultlist = $data3 ~~ dpath '/neighbourhoods/*[0]/DDD/FFF';
# ( 'interesting value' )



# ----- END SYNOPSIS ----------------------------------------

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
