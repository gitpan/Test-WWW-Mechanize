#!perl -T

use strict;
use warnings;
use Test::More tests => 4;
use Test::Builder::Tester;
use URI::file;

BEGIN {
    use_ok( 'Test::WWW::Mechanize' );
}

my $mech=Test::WWW::Mechanize->new();

isa_ok($mech,'Test::WWW::Mechanize');

$mech->get(URI::file->cwd().'t/goodlinks.html');

# Good links.
test_out('ok 1 - Checking all page links successful');
$mech->page_links_ok('Checking all page links successful');
test_test('Handles All page links successful');

# Bad links
$mech->get(URI::file->cwd().'t/badlinks.html');

test_out('not ok 1 - Checking some page link failures');
test_err("#     Failed test ($0 at line ".line_num(+4).")");
test_diag('bad1.html');
test_diag('bad2.html');
test_diag('bad3.html');
$mech->page_links_ok('Checking some page link failures');
test_test('Handles link not found');

