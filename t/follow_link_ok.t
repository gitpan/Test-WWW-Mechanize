#!perl -T

use strict;
use warnings;
use Test::More tests => 7;
use Test::Builder::Tester;
use URI::file;

BEGIN {
    use_ok( 'Test::WWW::Mechanize' );
}

FOLLOW_GOOD_LINK: {
    my $mech = Test::WWW::Mechanize->new();
    isa_ok( $mech,'Test::WWW::Mechanize' );

    $mech->get_ok( URI::file->cwd().'t/goodlinks.html' );
    $mech->follow_link_ok( {n=>1}, "Go after first link" );
}

#FOLLOW_BAD_LINK: {
TODO: {
    my $mech = Test::WWW::Mechanize->new();
    isa_ok( $mech,'Test::WWW::Mechanize' );

    $mech->get_ok( URI::file->cwd().'t/badlinks.html' );
    test_out('not ok 1 - Go after bad link');
    test_fail(+1);
    $mech->follow_link_ok( {n=>2}, "Go after bad link" );
    local $TODO = "I don't know how to get Test::Builder::Tester to handle regexes for the timestamp.";
    test_test('Handles bad links');
}

__DATA__
my $links=$mech->links();
test_out('not ok 1 - Checking all links some bad');
test_fail(+4);
test_diag('bad1.html');
test_diag('bad2.html');
test_diag('bad3.html');
$mech->links_ok($links,'Checking all links some bad');
test_test('Handles bad links');

test_out('not ok 1 - Checking specified link not found');
test_fail(+2);
test_diag('test2.html');
$mech->links_ok('test2.html','Checking specified link not found');
test_test('Handles link not found');



