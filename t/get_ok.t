#!perl -T

use strict;
use warnings;
use Test::More tests => 9;
use Test::Builder::Tester;
use URI::file;

BEGIN {
    use_ok( 'Test::WWW::Mechanize' );
}

#########################################
# Basic tests: can_ok, isa_ok

can_ok('Test::WWW::Mechanize', 'get_ok');

my $mech=Test::WWW::Mechanize->new();
isa_ok($mech,'Test::WWW::Mechanize');

#########################################
# Functionality tests: success/failure of get_ok for existent/nonexistent documents

my $goodlinks = URI::file->cwd().'t/goodlinks.html';
$mech->get($goodlinks);
ok($mech->success, 'sanity check: we can load goodlinks.html');

test_out('ok 1 - Try to get goodlinks.html');
my $result = $mech->get_ok($goodlinks, 'Try to get goodlinks.html');
test_test('Gets existing URI and reports success');
isa_ok($result, 'HTTP::Response', "get_ok()'s return value");

my $notafile = URI::file->cwd().'t/NONEXISTENT.html';
$mech->get($notafile);
ok(!$mech->success, "sanity check: we can't load NONEXISTENT.html");

test_out('not ok 1 - Try to get NONEXISTENT.html');
test_fail(+1);
$result = $mech->get_ok($notafile, 'Try to get NONEXISTENT.html');
test_test('Fails to get nonexistent URI and reports failure');

isa_ok($result, 'HTTP::Response', "get_ok()'s return value even after failure to get()");
