package Test::WWW::Mechanize;

use warnings;
use strict;

use WWW::Mechanize;
use Test::LongString;
use Test::Builder;

our @ISA = qw( WWW::Mechanize );

my $Test = Test::Builder->new();

=head1 NAME

Test::WWW::Mechanize - The great new Test::WWW::Mechanize!

=head1 Version

Version 0.99

=cut

our $VERSION = '0.99';

=head1 Synopsis

Test::WWW::Mechanize is a subclass of WWW::Mechanize that incorporates features that make sense
for doing web application testing.  For example:

    $mech->get( $page );
    $mech->title_is( "Invoice Status", 
      "Make sure we're on the invoice page" );

This is equivalent to:

    $mech->get( $page );
    is( $mech->title, "Invoice Status", 
      "Make sure we're on the invoice page" );

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

    local $Test::Builder::Level = 2;
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

    local $Test::Builder::Level = 2;
    return like_string( $self->title, $regex, $msg );
}

=head2 title_unlike( $regex [, $msg ] )

Tells if the title of the page matches the given regex.

    $mech->title_unlike( qr/Invoices for (.+)/

=cut

sub title_unlike {
    my $self = shift;
    my $regex = shift;
    my $msg = shift;

    local $Test::Builder::Level = 2;
    return unlike_string( $self->title, $regex, $msg );
}

=head2 content_is( $str [, $msg ] )

Tells if the content of the page matches the given string

=cut

sub content_is {
    my $self = shift;
    my $str = shift;
    my $msg = shift;

    local $Test::Builder::Level = 2;
    return is_string( $self->content, $str, $msg );
}

=head2 content_like( $regex [, $msg ] )

Tells if the content of the page matches the given regex

=cut

sub content_like {
    my $self = shift;
    my $regex = shift;
    my $msg = shift;

    local $Test::Builder::Level = 2;
    return like_string( $self->content, $regex, $msg );
}


=head2 content_unlike( $regex [, $msg ] )

Tells if the content of the page matches the given regex

=cut

sub content_unlike {
    my $self = shift;
    my $regex = shift;
    my $msg = shift;

    local $Test::Builder::Level = 2;
    return unlike_string( $self->content, $regex, $msg );
}


=head2 page_links_ok( [ $msg ] )

Follow all links on the current page and test for HTTP status 200

    $mech->page_links_ok('Check all links');

=cut

sub page_links_ok {
    my $self = shift;
    my $msg = shift;

    my @links = $self->links();
    my @urls = _format_links(\@links);

    my @failures = $self->_check_links_status( \@urls );
    my $ok = (@failures==0);

    $Test->ok( $ok, $msg );
    $Test->diag( @failures ) unless $ok;

    return $ok;
}

=head2 page_links_content_like( $regex,[ $msg ] )

Follow all links on the current page and test their contents for the 
specified regex.

    $mech->page_links_content_like(qr/html/,
      'Check all links contain html');

=cut

sub page_links_content_like {
    my $self = shift;
    my $regex = shift;
    my $msg = shift;

    my $usable_regex=$Test->maybe_regex( $regex );
    unless(defined( $usable_regex )) {
        my $ok = $Test->ok( 0, 'page_links_content_like' );
        $Test->diag("     '$regex' doesn't look much like a regex to me.");
        return $ok;
    }

    my @links = $self->links();
    my @urls = _format_links(\@links);

    my @failures = $self->_check_links_content( \@urls, $regex );
    my $ok = (@failures==0);

    $Test->ok( $ok, $msg );
    $Test->diag( @failures ) unless $ok;

    return $ok;
}

=head2 page_links_content_unlike( $regex,[ $msg ] )

Follow all links on the current page and test their contents do not
contain the specified regex.

    $mech->page_links_content_unlike(qr/Restricted/,
      'Check all links do not contain Restricted');

=cut

sub page_links_content_unlike {
    my $self = shift;
    my $regex = shift;
    my $msg = shift;

    my $usable_regex=$Test->maybe_regex( $regex );
    unless(defined( $usable_regex )) {
        my $ok = $Test->ok( 0, 'page_links_content_unlike' );
        $Test->diag("     '$regex' doesn't look much like a regex to me.");
        return $ok;
    }

    my @links = $self->links();
    my @urls = _format_links(\@links);

    my @failures = $self->_check_links_content( \@urls, $regex, 'unlike' );
    my $ok = (@failures==0);

    $Test->ok( $ok, $msg );
    $Test->diag( @failures ) unless $ok;

    return $ok;
}

=head2 links_ok( $links [, $msg ] )

Check the current page for specified links and test for HTTP status
200.  The links may be specified as a reference to an array containing
L<WWW::Mechanize::Link> objects, an array of URLs, or a scalar URL
name.

    my @links = $mech->find_all_links( url_regex => qr/cnn\.com$/ );
    $mech->links_ok( \@links, 'Check all links for cnn.com' );

    my @links = qw( index.html search.html about.html );
    $mech->links_ok( \@links, 'Check main links' );

    $mech->links_ok( 'index.html', 'Check link to index' );

=cut

sub links_ok {
    my $self = shift;
    my $links = shift;
    my $msg = shift;

    my @urls = _format_links( $links );
    my @failures = $self->_check_links_status( \@urls );
    my $ok = (@failures == 0);

    $Test->ok( $ok, $msg );
    $Test->diag( @failures ) unless $ok;

    return $ok;
}

=head2 link_status_is( $links, $status [, $msg ] )

Check the current page for specified links and test for HTTP status
passed.  The links may be specified as a reference to an array
containing L<WWW::Mechanize::Link> objects, an array of URLs, or a
scalar URL name.

    my @links = $mech->links();
    $mech->link_status_is( \@links, 403,
      'Check all links are restricted' );

=cut

sub link_status_is {
    my $self = shift;
    my $links = shift;
    my $status = shift;
    my $msg = shift;

    my @urls = _format_links( $links );
    my @failures = $self->_check_links_status( \@urls, $status );
    my $ok = (@failures == 0);

    $Test->ok( $ok, $msg );
    $Test->diag( @failures ) unless $ok;

    return $ok;
}

=head2 link_status_isnt( $links, $status [, $msg ] )

Check the current page for specified links and test for HTTP status
passed.  The links may be specified as a reference to an array
containing L<WWW::Mechanize::Link> objects, an array of URLs, or a
scalar URL name.

    my @links = $mech->links();
    $mech->link_status_isnt( \@links, 404,
      'Check all links are not 404' );

=cut

sub link_status_isnt {
    my $self = shift;
    my $links = shift;
    my $status = shift;
    my $msg = shift;

    my @urls = _format_links( $links );
    my @failures = $self->_check_links_status( \@urls, $status, 'isnt' );
    my $ok = (@failures == 0);

    $Test->ok( $ok, $msg );
    $Test->diag( @failures ) unless $ok;

    return $ok;
}


=head2 link_content_like( $links, $regex [, $msg ] )

Check the current page for specified links and test the content of each
for the regex passed.  The links may be specified as a reference to 
an array containing L<WWW::Mechanize::Link> objects, an array of URLs, 
or a scalar URL name.

    my @links = $mech->links();
    $mech->link_content_like( \@links, qr/Restricted/,
        'Check all links are restricted' );

=cut

sub link_content_like {
    my $self = shift;
    my $links = shift;
    my $regex = shift;
    my $msg = shift;

    my $usable_regex=$Test->maybe_regex( $regex );
    unless(defined( $usable_regex )) {
        my $ok = $Test->ok( 0, 'link_content_like' );
        $Test->diag("     '$regex' doesn't look much like a regex to me.");
        return $ok;
    }

    my @urls = _format_links( $links );
    my @failures = $self->_check_links_content( \@urls, $regex );
    my $ok = (@failures == 0);

    $Test->ok( $ok, $msg );
    $Test->diag( @failures ) unless $ok;

    return $ok;
}

=head2 link_content_unlike( $links, $regex [, $msg ] )

Check the current page for specified links and test the content of each
does not contain regex passed.  The links may be specified as a reference 
to an array containing L<WWW::Mechanize::Link> objects, an array of URLs, 
or a scalar URL name.

    my @links = $mech->links();
    $mech->link_content_like( \@links, qr/Restricted/,
      'Check all links are restricted' );

=cut

sub link_content_unlike {
    my $self = shift;
    my $links = shift;
    my $regex = shift;
    my $msg = shift;

    my $usable_regex=$Test->maybe_regex( $regex );
    unless(defined( $usable_regex )) {
        my $ok = $Test->ok( 0, 'link_content_unlike' );
        $Test->diag("     '$regex' doesn't look much like a regex to me.");
        return $ok;
    }

    my @urls = _format_links( $links );
    my @failures = $self->_check_links_content( \@urls, $regex, 'unlike' );
    my $ok = (@failures == 0);

    $Test->ok( $ok, $msg );
    $Test->diag( @failures ) unless $ok;

    return $ok;
}

# This actually performs the status check of each url. 
sub _check_links_status {
    my $self = shift;
    my $urls = shift;
    my $status = shift || 200;
    my $test = shift || 'is';

    # Create a clone of the $mech used during the test as to not disrupt
    # the original.
    my $mech = $self->clone();

    my @failures;

    for my $url ( @$urls ) {
        if ( $mech->follow_link( url => $url ) ) {
            if($test eq 'is') {
              push( @failures, $url ) unless $mech->status() == $status;
            } else {
              push( @failures, $url ) unless $mech->status() != $status;
            }
            $mech->back();
        } else {
            push( @failures, $url );
        }
    } # for

    return @failures;
}

# This actually performs the content check of each url. 
sub _check_links_content {
    my $self = shift;
    my $urls = shift;
    my $regex = shift || qr/<html>/;
    my $test = shift || 'like';

    # Create a clone of the $mech used during the test as to not disrupt
    # the original.
    my $mech = $self->clone();

    my @failures;
    for my $url ( @$urls ) {
        if ( $mech->follow_link( url => $url ) ) {
            my $content=$mech->content();
            if($test eq 'like') {
              push( @failures, $url ) unless $content=~/$regex/;
            } else {
              push( @failures, $url ) unless $content!~/$regex/;
            }
            $mech->back();
        } else {
            push( @failures, $url );
        }
    } # for

    return @failures;
}

# Create an array of urls to match for mech to follow.
sub _format_links {
    my $links = shift;

    my @urls;
    if(ref($links) eq 'ARRAY') {
        if(defined($$links[0])) {
            if(ref($$links[0]) eq 'WWW::Mechanize::Link') {
                @urls=map { $_->url() } @$links;
            } else {
                @urls=@$links;
            }
        }
    } else {
        push(@urls,$links);
    }
    return @urls;
}

=head1 To-do

=over 4

=item * Test suite

=item * Add HTML::Lint and HTML::Tidy capabilities.

=back

=head1 BUGS

Please report any bugs or feature requests to
C<bug-test-www-mechanize@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org>.  I will be notified, and then you'll automatically
be notified of progress on your bug as I make changes.

=head1 COPYRIGHT & LICENSE

Copyright 2004 Andy Lester, All Rights Reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=head1 AUTHOR

Andy Lester, C<< <andy@petdance.com> >>

=head1 ACKNOWLEDGEMENTS

Thanks to Shawn Sorichetti for big help and chunks of code.

=cut

1; # End of Test::WWW::Mechanize
