#!perl -Tw

use strict;
use warnings;
use Test::More tests => 10;
use Test::Builder::Tester;
use URI::file;

BEGIN {
    use_ok( 'Test::WWW::Mechanize' );
}


my $mech=Test::WWW::Mechanize->new();
isa_ok($mech,'Test::WWW::Mechanize');

GOOD_GET: {
    my $goodlinks = URI::file->cwd().'t/goodlinks.html';
    $mech->get($goodlinks);
    ok($mech->success, 'sanity check: we can load goodlinks.html');

    test_out('ok 1 - Try to get goodlinks.html');
    my $ok = $mech->get_ok($goodlinks, 'Try to get goodlinks.html');
    test_test('Gets existing URI and reports success');
    is( ref($ok), '', "get_ok() should only return a scalar" );
    ok( $ok, "And the result should be true" );
}

BAD_GET: {
    my $badurl = "http://wango.nonexistent.xx-only-testing/";
    $mech->get($badurl);
    ok(!$mech->success, "sanity check: we can't load NONEXISTENT.html");

    test_out( 'not ok 1 - Try to get bad URL' );
    test_fail( +3 );
    test_diag( "500" );
    test_diag( "Can't connect to wango.nonexistent.xx-only-testing:80 (Bad hostname 'wango.nonexistent.xx-only-testing')" );
    my $ok = $mech->get_ok( $badurl, 'Try to get bad URL' );
    test_test( 'Fails to get nonexistent URI and reports failure' );

    is( ref($ok), '', "get_ok() should only return a scalar" );
    ok( !$ok, "And the result should be false" );
}
