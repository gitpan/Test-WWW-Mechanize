#!perl -T

use Test::More tests => 1;

BEGIN {
use_ok( 'Test::WWW::Mechanize' );
}

diag( "Testing Test::WWW::Mechanize $Test::WWW::Mechanize::VERSION" );