package Test::WWW::Mechanize;

=head1 NAME

Test::WWW::Mechanize - Testing-specific WWW::Mechanize subclass

=head1 VERSION

Version 1.05_02

=cut

our $VERSION = '1.05_02';

=head1 SYNOPSIS

Test::WWW::Mechanize is a subclass of L<WWW::Mechanize> that incorporates
features for web application testing.  For example:

    $mech->get_ok( $page );
    $mech->title_is( "Invoice Status", "Make sure we're on the invoice page" );
    $mech->content_contains( "Andy Lester", "My name somewhere" );
    $mech->content_like( qr/(cpan|perl)\.org/, "Link to perl.org or CPAN" );

This is equivalent to:

    $mech->get( $page );
    ok( $mech->success );
    is( $mech->title, "Invoice Status", "Make sure we're on the invoice page" );
    ok( index( $mech->content, "Andy Lester" ) >= 0, "My name somewhere" );
    like( $mech->content, qr/(cpan|perl)\.org/, "Link to perl.org or CPAN" );

but has nicer diagnostics if they fail.

=cut

use warnings;
use strict;

use WWW::Mechanize;
use Test::LongString 0.07;
use Test::Builder;

use base 'WWW::Mechanize';

my $Test = Test::Builder->new();


=head1 CONSTRUCTOR

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

=head1 METHODS

=head2 $mech->get_ok($url, [ \%LWP_options ,] $desc)

A wrapper around WWW::Mechanize's get(), with similar options, except
the second argument needs to be a hash reference, not a hash. Like
well-behaved C<*_ok()> functions, it returns true if the test passed,
or false if not.

=cut

sub get_ok {
    my $self = shift;
    my $url = shift;

    my $desc;
    my %opts;

    if ( @_ ) {
        my $flex = shift; # The flexible argument

        if ( !defined( $flex ) ) {
            $desc = shift;
        } elsif ( ref $flex eq 'HASH' ) {
            %opts = %$flex;
            $desc = shift;
        } elsif ( ref $flex eq 'ARRAY' ) {
            %opts = @$flex;
            $desc = shift;
        } else {
            $desc = $flex;
        }
    } # parms left

    $self->get( $url, %opts );
    my $ok = $self->success;

    $Test->ok( $ok, $desc );
    if ( !$ok ) {
        $Test->diag( $self->status );
        $Test->diag( $self->response->message ) if $self->response;
    }

    return $ok;
}

=head2 $mech->title_is( $str [, $desc ] )

Tells if the title of the page is the given string.

    $mech->title_is( "Invoice Summary" );

=cut

sub title_is {
    my $self = shift;
    my $str = shift;
    my $desc = shift;

    local $Test::Builder::Level = $Test::Builder::Level + 1;
    return is_string( $self->title, $str, $desc );
}

=head2 $mech->title_like( $regex [, $desc ] )

Tells if the title of the page matches the given regex.

    $mech->title_like( qr/Invoices for (.+)/

=cut

sub title_like {
    my $self = shift;
    my $regex = shift;
    my $desc = shift;

    local $Test::Builder::Level = $Test::Builder::Level + 1;
    return like_string( $self->title, $regex, $desc );
}

=head2 $mech->title_unlike( $regex [, $desc ] )

Tells if the title of the page matches the given regex.

    $mech->title_unlike( qr/Invoices for (.+)/

=cut

sub title_unlike {
    my $self = shift;
    my $regex = shift;
    my $desc = shift;

    local $Test::Builder::Level = $Test::Builder::Level + 1;
    return unlike_string( $self->title, $regex, $desc );
}

=head2 $mech->content_is( $str [, $desc ] )

Tells if the content of the page matches the given string

=cut

sub content_is {
    my $self = shift;
    my $str = shift;
    my $desc = shift;

    local $Test::Builder::Level = $Test::Builder::Level + 1;
    return is_string( $self->content, $str, $desc );
}

=head2 $mech->content_contains( $str [, $desc ] )

Tells if the content of the page contains I<$str>.

=cut

sub content_contains {
    my $self = shift;
    my $str = shift;
    my $desc = shift;

    local $Test::Builder::Level = $Test::Builder::Level + 1;
    return contains_string( $self->content, $str, $desc );
}

=head2 $mech->content_lacks( $str [, $desc ] )

Tells if the content of the page lacks I<$str>.

=cut

sub content_lacks {
    my $self = shift;
    my $str = shift;
    my $desc = shift;

    local $Test::Builder::Level = $Test::Builder::Level + 1;
    return lacks_string( $self->content, $str, $desc );
}

=head2 $mech->content_like( $regex [, $desc ] )

Tells if the content of the page matches I<$regex>.

=cut

sub content_like {
    my $self = shift;
    my $regex = shift;
    my $desc = shift;

    local $Test::Builder::Level = $Test::Builder::Level + 1;
    return like_string( $self->content, $regex, $desc );
}

=head2 $mech->content_unlike( $regex [, $desc ] )

Tells if the content of the page does NOT match I<$regex>.

=cut

sub content_unlike {
    my $self = shift;
    my $regex = shift;
    my $desc = shift;

    local $Test::Builder::Level = $Test::Builder::Level + 1;
    return unlike_string( $self->content, $regex, $desc );
}

=head2 $mech->has_tag( $tag, $text [, $desc ] )

Tells if the page has a C<$tag> tag with the given content in its text.

XXX Make the $text optional

=cut

sub has_tag {
    my $self = shift;
    my $tag  = shift;
    my $text = shift;
    my $desc = shift;

    my $found = $self->_tag_walk( $tag, sub { $text eq $_[0] } );

    return $Test->ok( $found, $desc );
}


=head2 $mech->has_tag_like( $tag, $regex [, $desc ] )

Tells if the page has a C<$tag> tag with the given content in its text.

=cut

sub has_tag_like {
    my $self = shift;
    my $tag  = shift;
    my $text = shift;
    my $desc = shift;

    my $found = $self->_tag_walk( $tag, sub { $text =~ $_[0] } );

    return $Test->ok( $found, $desc );
}


=head2 $mech->has_tag_like( $tag, $regex [, $desc ] )

Tells if the page has a C<$tag> tag with text matching the given regex.

=cut

sub _tag_walk {
    my $self = shift;
    my $tag  = shift;
    my $match = shift;

    my $p = HTML::TokeParser->new( \($self->content) );

    while ( my $token = $p->get_tag( $tag ) ) {
        my $tagtext = $p->get_trimmed_text( "/$tag" );
        return 1 if $match->( $tagtext );
    }
    return;
}

=head2 $mech->page_links_ok( [ $desc ] )

Follow all links on the current page and test for HTTP status 200

    $mech->page_links_ok('Check all links');

=cut

sub page_links_ok {
    my $self = shift;
    my $desc = shift;

    my @links = $self->links();
    my @urls = _format_links(\@links);

    my @failures = $self->_check_links_status( \@urls );
    my $ok = (@failures==0);

    $Test->ok( $ok, $desc );
    $Test->diag( $_ ) for @failures;

    return $ok;
}

=head2 $mech->page_links_content_like( $regex,[ $desc ] )

Follow all links on the current page and test their contents for I<$regex>.

    $mech->page_links_content_like( qr/foo/,
      'Check all links contain "foo"' );

=cut

sub page_links_content_like {
    my $self = shift;
    my $regex = shift;
    my $desc = shift;

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

    $Test->ok( $ok, $desc );
    $Test->diag( $_ ) for @failures;

    return $ok;
}

=head2 $mech->page_links_content_unlike( $regex,[ $desc ] )

Follow all links on the current page and test their contents do not
contain the specified regex.

    $mech->page_links_content_unlike(qr/Restricted/,
      'Check all links do not contain Restricted');

=cut

sub page_links_content_unlike {
    my $self = shift;
    my $regex = shift;
    my $desc = shift;

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

    $Test->ok( $ok, $desc );
    $Test->diag( $_ ) for @failures;

    return $ok;
}

=head2 $mech->links_ok( $links [, $desc ] )

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
    my $desc = shift;

    my @urls = _format_links( $links );
    my @failures = $self->_check_links_status( \@urls );
    my $ok = (@failures == 0);

    $Test->ok( $ok, $desc );
    $Test->diag( $_ ) for @failures;

    return $ok;
}

=head2 $mech->link_status_is( $links, $status [, $desc ] )

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
    my $desc = shift;

    my @urls = _format_links( $links );
    my @failures = $self->_check_links_status( \@urls, $status );
    my $ok = (@failures == 0);

    $Test->ok( $ok, $desc );
    $Test->diag( $_ ) for @failures;

    return $ok;
}

=head2 $mech->link_status_isnt( $links, $status [, $desc ] )

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
    my $desc = shift;

    my @urls = _format_links( $links );
    my @failures = $self->_check_links_status( \@urls, $status, 'isnt' );
    my $ok = (@failures == 0);

    $Test->ok( $ok, $desc );
    $Test->diag( $_ ) for @failures;

    return $ok;
}


=head2 $mech->link_content_like( $links, $regex [, $desc ] )

Check the current page for specified links and test the content of
each against I<$regex>.  The links may be specified as a reference to
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
    my $desc = shift;

    my $usable_regex=$Test->maybe_regex( $regex );
    unless(defined( $usable_regex )) {
        my $ok = $Test->ok( 0, 'link_content_like' );
        $Test->diag("     '$regex' doesn't look much like a regex to me.");
        return $ok;
    }

    my @urls = _format_links( $links );
    my @failures = $self->_check_links_content( \@urls, $regex );
    my $ok = (@failures == 0);

    $Test->ok( $ok, $desc );
    $Test->diag( $_ ) for @failures;

    return $ok;
}

=head2 $mech->link_content_unlike( $links, $regex [, $desc ] )

Check the current page for specified links and test the content of each
does not match I<$regex>.  The links may be specified as a reference to
an array containing L<WWW::Mechanize::Link> objects, an array of URLs,
or a scalar URL name.

    my @links = $mech->links();
    $mech->link_content_like( \@links, qr/Restricted/,
      'Check all links are restricted' );

=cut

sub link_content_unlike {
    my $self = shift;
    my $links = shift;
    my $regex = shift;
    my $desc = shift;

    my $usable_regex=$Test->maybe_regex( $regex );
    unless(defined( $usable_regex )) {
        my $ok = $Test->ok( 0, 'link_content_unlike' );
        $Test->diag("     '$regex' doesn't look much like a regex to me.");
        return $ok;
    }

    my @urls = _format_links( $links );
    my @failures = $self->_check_links_content( \@urls, $regex, 'unlike' );
    my $ok = (@failures == 0);

    $Test->ok( $ok, $desc );
    $Test->diag( $_ ) for @failures;

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
            if ( $test eq 'is' ) {
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
            if ( $test eq 'like' ) {
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

=head2 follow_link_ok( \%parms [, $comment] )

Makes a C<follow_link()> call and executes tests on the results.
The link must be found, and then followed successfully.  Otherwise,
this test fails.

I<%parms> is a hashref containing the parms to pass to C<follow_link()>.
Note that the parms to C<follow_link()> are a hash whereas the parms to
this function are a hashref.  You have to call this function like:

    $agent->follow_like_ok( {n=>3}, "looking for 3rd link" );

As with other test functions, C<$comment> is optional.  If it is supplied
then it will display when running the test harness in verbose mode.

Returns true value if the specified link was found and followed
successfully.  The HTTP::Response object returned by follow_link()
is not available.

=cut

sub follow_link_ok {
    my $self = shift;
    my $parms = shift || {};
    my $comment = shift;

    # return from follow_link() is an HTTP::Response or undef
    my $response = $self->follow_link( %$parms );

    my $ok;
    my $error;
    if ( !$response ) {
        $error = "No matching link found";
    } else {
        if ( !$response->is_success ) {
            $error = $response->as_string;
        } else {
            $ok = 1;
        }
    }

    $Test->ok( $ok, $comment );
    $Test->diag( $error ) if $error;

    return $ok;
}

=head1 TODO

Add HTML::Lint and HTML::Tidy capabilities.

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

Thanks to Mike O'Regan and Shawn Sorichetti for big help and chunks of code.

=cut

1; # End of Test::WWW::Mechanize
