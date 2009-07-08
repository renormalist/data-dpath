use MooseX::Declare;

use 5.010;

class Data::DPath::Fast::Path is dirty {

        use Data::Dumper;
        use Data::DPath::Fast::Step;
        use Data::DPath::Fast::Point;
        use Data::DPath::Fast::Context;
        use Text::Balanced qw (
                                      extract_delimited
                                      extract_bracketed
                             );

        sub unescape {
                my ($str) = @_;

                return unless defined $str;
                $str =~ s/(?<!\\)\\(["'])/$1/g;          # '"$
                $str =~ s/\\{2}/\\/g;
                return $str;
        }

        sub unquote {
                my ($str) = @_;
                $str =~ s/^"(.*)"$/$1/g;
                return $str;
        }

        sub quoted { shift =~ m,^/["'],; }                                             # "

        clean;

        has path            => ( isa => "Str",      is => "rw" );
        has _steps          => ( isa => "ArrayRef", is => "rw", auto_deref => 1, lazy_build => 1 );
        has give_references => ( isa => "Int",      is => "rw", default => 0 );

        use overload '~~' => \&op_match;

        method op_match($data, $rhs) {
                return [ $self->match( $data ) ];
        }

        # essentially the Path parser
        method _build__steps {
                my $remaining_path = $self->path;
                my $extracted;
                my @steps;

                push @steps, new Data::DPath::Fast::Step( part => '', kind => 'ROOT' );

                while ($remaining_path) {
                        my $plain_part;
                        my $filter;
                        my $kind;
                        given ($remaining_path)
                        {
                                when ( \&quoted ) {
                                        ($plain_part, $remaining_path) = extract_delimited($remaining_path, q/'"/, "/"); # '
                                        ($filter,     $remaining_path) = extract_bracketed($remaining_path);
                                        $plain_part                    = unescape unquote $plain_part;
                                        $kind                          = 'KEY'; # quoted is always a key
                                }
                                default {
                                        ($extracted, $remaining_path) = extract_delimited($remaining_path,'/');

                                        if (not $extracted) {
                                                ($extracted, $remaining_path) = ($remaining_path, undef); # END OF PATH
                                        } else {
                                                $remaining_path = (chop $extracted) . $remaining_path;
                                        }

                                        ($plain_part, $filter) = $extracted =~ m,^/              # leading /
                                                                                 (.*?)           # path part
                                                                                 (\[.*\])?$      # optional filter
                                                                                ,xg;
                                        $plain_part = unescape $plain_part;
                                }
                        }

                        given ($plain_part) {
                                when ('')   { $kind ||= 'ANYWHERE' }
                                when ('*')  { $kind ||= 'ANYSTEP'  }
                                when ('.')  { $kind ||= 'NOSTEP'   }
                                when ('..') { $kind ||= 'PARENT'   }
                                default     { $kind ||= 'KEY'      }
                        }
                        push @steps, new Data::DPath::Fast::Step( part   => $plain_part,
                                                            kind   => $kind,
                                                            filter => $filter );
                }
                pop @steps if $steps[-1]->kind eq 'ANYWHERE'; # ignore final '/'
                $self->_steps( \@steps );
        }

        method match($data) {
                my $context = new Data::DPath::Fast::Context ( current_points  => [ new Data::DPath::Fast::Point ( ref => \$data )],
                                                         give_references => $self->give_references,
                                                       );
                return $context->match($self);
        }
}

# help the CPAN indexer
package Data::DPath::Fast::Path;

1;

__END__

=head1 NAME

Data::DPath::Fast::Path - Abstraction for a DPath.

Take a string description, parse it, provide frontend methods.

=head1 PUBLIC METHODS

=head2 new ( %args )

Constructor; creates instance.

Args:

=over 4

=item give_references

Default 0. If set to true value then results are references to the
matched points in the data structure.

=back

=head2 match( $data )

Returns an array of all values in C<$data> that match the Path object.

=head1 INTERNAL METHODS

=head2 op_match( $self, $data )

This sub/method is bound as the overloading function for C<~~>.

=head2 quoted

Checks whether a path part starts with quotes.

=head2 unquote

Removes surrounding quotes.

=head2 unescape

Converts backslashed characters into their non-backslashed form.

=head2 _build__steps

This method is essentially the DPath parser as it tokenizes the path
into single steps whose later execution is the base functionality of
the whole DPath module.

=head1 AUTHOR

Steffen Schwigon, C<< <schwigon at cpan.org> >>

=head1 COPYRIGHT & LICENSE

Copyright 2008,2009 Steffen Schwigon.

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
