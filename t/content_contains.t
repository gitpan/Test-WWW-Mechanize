#!perl -Tw

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

# test regex
test_out( 'ok 1 - Does it say test page?' );
$mech->content_contains( 'Test Page', "Does it say test page?" );
test_test( "Finds the contains" );


test_out( 'not ok 1 - Where is Mungo?' );
test_err("#     Failed test ($0 at line ".line_num(+3).")");
test_diag(q(    searched: "<html>\x{0a}  <head>\x{0a}    <title>Test Page</title>\x{0a}  </h"...) );
test_diag(q(  can't find: "Mungo") );
$mech->content_contains( 'Mungo', "Where is Mungo?" );
test_test( "Handles not finding it" );
