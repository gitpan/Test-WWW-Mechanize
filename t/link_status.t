#!perl -T

use strict;
use warnings;
use Test::More tests => 6;
use Test::Builder::Tester;
use Test::WWW::Mechanize;
use URI::file;


my $mech=Test::WWW::Mechanize->new();

isa_ok($mech,'Test::WWW::Mechanize');

$mech->get(URI::file->cwd().'t/goodlinks.html');

# Good links.
my $links=$mech->links();
test_out('ok 1 - Checking all links status are 200');
$mech->link_status_is($links,200,'Checking all links status are 200');
test_test('Handles All Links successful');

$mech->link_status_isnt($links,404,'Checking all links isnt');

# Bad links
$mech->get(URI::file->cwd().'t/badlinks.html');

$links=$mech->links();
test_out('not ok 1 - Checking all links some bad');
test_err("#     Failed test ($0 at line ".line_num(+2).")");
test_diag('goodlinks.html');
$mech->link_status_is($links,404,'Checking all links some bad');
test_test('Handles bad links');


test_out('not ok 1 - Checking specified link not found');
test_err("#     Failed test ($0 at line ".line_num(+2).")");
test_diag('test2.html');
$mech->links_ok('test2.html','Checking specified link not found');
test_test('Handles link not found');

test_out('not ok 1 - Checking all links not 200');
test_err("#     Failed test ($0 at line ".line_num(+2).")");
test_diag('goodlinks.html');
$mech->link_status_isnt($links,200,'Checking all links not 200');
test_test('Handles all links mismatch');
