#!perl -T

use strict;
use warnings;
use Test::More tests => 8;
use Test::Builder::Tester;
use URI::file;

BEGIN {
    use_ok( 'Test::WWW::Mechanize' );
}

my $mech=Test::WWW::Mechanize->new();
isa_ok($mech,'Test::WWW::Mechanize');

$mech->get(URI::file->cwd().'t/goodlinks.html');

# test regex
test_out('not ok 1 - page_links_content_like'); 
test_err("#     Failed test ($0 at line ".line_num(+2).")");
test_diag("     'blah' doesn't look much like a regex to me.");
$mech->page_links_content_like('blah','Testing the regex');
test_test('Handles bad regexs');

# like
test_out('ok 1 - Checking all page links contain: Test');
$mech->page_links_content_like(qr/Test/,'Checking all page links contain: Test');
test_test('Handles All page links contents successful');

test_out('not ok 1 - Checking all page link content failures');
test_err("#     Failed test ($0 at line ".line_num(+4).")");
test_diag('goodlinks.html');
test_diag('badlinks.html');
test_diag('goodlinks.html');
$mech->page_links_content_like(qr/BadTest/,'Checking all page link content failures');
test_test('Handles link content not found');

# unlike
# test regex
test_out('not ok 1 - page_links_content_unlike'); 
test_err("#     Failed test ($0 at line ".line_num(+2).")");
test_diag("     'blah' doesn't look much like a regex to me.");
$mech->page_links_content_unlike('blah','Testing the regex');
test_test('Handles bad regexs');

test_out('ok 1 - Checking all page links do not contain: BadTest');
$mech->page_links_content_unlike(qr/BadTest/,'Checking all page links do not contain: BadTest');
test_test('Handles All page links unlike contents successful');

test_out('not ok 1 - Checking all page link unlike content failures');
test_err("#     Failed test ($0 at line ".line_num(+4).")");
test_diag('goodlinks.html');
test_diag('badlinks.html');
test_diag('goodlinks.html');
$mech->page_links_content_unlike(qr/Test/,'Checking all page link unlike content failures');
test_test('Handles link unlike content found');
