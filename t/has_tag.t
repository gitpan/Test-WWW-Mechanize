#!perl -Tw

use strict;
use warnings;
use Test::More tests => 6;
use Test::Builder::Tester;
use URI::file;

BEGIN {
    use_ok( 'Test::WWW::Mechanize' );
}

my $mech=Test::WWW::Mechanize->new();
isa_ok($mech,'Test::WWW::Mechanize');

$mech->get( URI::file->cwd().'t/goodlinks.html' );

test_out( 'ok 1 - looking for "Test" link' );
$mech->has_tag( h1 => 'Test Page', 'looking for "Test" link' );
test_test( 'Handles finding tag by content' );

test_out( 'not ok 1 - looking for "Quiz" link' );
test_fail( +1 );
$mech->has_tag( h1 => 'Quiz', 'looking for "Quiz" link' );
test_test( 'Handles unfindable tag by content' );

test_out( 'ok 1 - Should have qr/Test 3/i link' );
$mech->has_tag_like( a => qr/Test 3/, 'Should have qr/Test 3/i link' );
test_test( 'Handles finding tag by content regexp' );

test_out( 'not ok 1 - Should be missing qr/goof/i link' );
test_fail( +1 );
$mech->has_tag_like( a => qr/goof/i, 'Should be missing qr/goof/i link' );
test_test( 'Handles unfindable tag by content regexp' );
