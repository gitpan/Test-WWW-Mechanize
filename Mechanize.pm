package Test::WWW::Mechanize;

use warnings;
use strict;

use WWW::Mechanize;
use Test::LongString;

our @ISA = qw( WWW::Mechanize );

=head1 NAME

Test::WWW::Mechanize - The great new Test::WWW::Mechanize!

=head1 Version

Version 0.01

=cut

our $VERSION = '0.01';

=head1 Synopsis

Test::WWW::Mechanize is a subclass of WWW::Mechanize that incorporates features that make sense
for doing web application testing.  For example:

    $mech->get( $page );
    $mech->title_is( "Invoice Status", "Make sure we're on the invoice page" );

This is equivalent to:

    $mech->get( $page );
    is( $mech->title, "Invoice Status", "Make sure we're on the invoice page" );

but has nicer error handling.

=head1 Constructor

=head2 new

Behaves like, and calls, L<WWW::Mechanize>'s C<new> method.  Any parms
passed in get passed to WWW::Mechanize's constructor.

=cut

sub new {
    my $class = shift;
    my %mech_args = @_;

    my $self = $class->SUPER::new( %mech_args );

    return $self;
}

=head1 Methods

=head2 title_is( $str [, $msg ] )

Tells if the title of the page is the given string.

    $mech->title_is( "Invoice Summary" );

=cut

sub title_is {
    my $self = shift;
    my $str = shift;
    my $msg = shift;

    return is_string( $self->title, $str, $msg );
}

=head2 title_like( $regex [, $msg ] )

Tells if the title of the page matches the given regex.

    $mech->title_like( qr/Invoices for (.+)/

=cut

sub title_like {
    my $self = shift;
    my $regex = shift;
    my $msg = shift;

    return like_string( $self->title, $regex, $msg );
}

=head2 content_is( $str [, $msg ] )

Tells if the content of the page matches the given string

=cut

sub content_is {
    my $self = shift;
    my $str = shift;
    my $msg = shift;

    return is_string( $self->content, $str, $msg );
}

=head2 content_like( $regex [, $msg ] )

Tells if the content of the page matches the given regex

=cut

sub content_like {
    my $self = shift;
    my $regex = shift;
    my $msg = shift;

    return like_string( $self->content, $regex, $msg );
}

=head1 To-do

=over 4

=item * Test suite

=item * Add HTML::Lint and HTML::Tidy capabilities.

=back

=head1 Author

Andy Lester, C<< <andy@petdance.com> >>

=head1 Bugs

Please report any bugs or feature requests to
C<bug-test-www-mechanize@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org>.  I will be notified, and then you'll automatically
be notified of progress on your bug as I make changes.

=head1 Copyright & License

Copyright 2004 Andy Lester, All Rights Reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1; # End of Test::WWW::Mechanize
