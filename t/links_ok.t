#!perl -T

use strict;
use warnings;
use Test::More tests => 7;
use Test::Builder::Tester;
use URI::file;

BEGIN {
    use_ok( 'Test::WWW::Mechanize' );
}

my $mech=Test::WWW::Mechanize->new();
isa_ok($mech,'Test::WWW::Mechanize');

$mech->get(URI::file->cwd().'t/goodlinks.html');

# Good links.
my $links=$mech->links();
test_out('ok 1 - Checking all links successful');
$mech->links_ok($links,'Checking all links successful');
test_test('Handles All Links successful');

$mech->links_ok('goodlinks.html','Specified link');

$mech->links_ok([qw(goodlinks.html badlinks.html)],'Specified link list');

# Bad links
$mech->get(URI::file->cwd().'t/badlinks.html');

$links=$mech->links();
test_out('not ok 1 - Checking all links some bad');
test_err("#     Failed test ($0 at line ".line_num(+4).")");
test_diag('bad1.html');
test_diag('bad2.html');
test_diag('bad3.html');
$mech->links_ok($links,'Checking all links some bad');
test_test('Handles bad links');

test_out('not ok 1 - Checking specified link not found');
test_err("#     Failed test ($0 at line ".line_num(+2).")");
test_diag('test2.html');
$mech->links_ok('test2.html','Checking specified link not found');
test_test('Handles link not found');



