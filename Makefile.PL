use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'Test::WWW::Mechanize',
    AUTHOR              => 'Andy Lester <andy@petdance.com>',
    VERSION_FROM        => 'Mechanize.pm',
    ABSTRACT_FROM       => 'Mechanize.pm',
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More'        => 0,
        'Test::LongString'  => '0.07',
        'URI::file'         => 0,
        'WWW::Mechanize'    => '1.00',
        'Carp::Assert::More' => 0,
        'HTTP::Server::Simple' => '0.07',
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Test-WWW-Mechanize-*' },
);
