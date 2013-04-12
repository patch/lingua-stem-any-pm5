use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name   => 'Lingua::Stem::Any',
    license       => 'perl',
    create_readme => 1,
    configure_requires => {
        'Module::Build' => '0.36',
    },
    build_requires => {
        'Pod::Man'   => '2.04',
        'Test::More' => '0.82',
    },
    requires => {
        'perl'                   => '5.6.0',
        'strict'                 => 0,
        'utf8'                   => 0,
        'warnings'               => 0,
        'Carp'                   => 0,
        'Lingua::LA::Stemmer'    => 0,
        'Lingua::Stem::Snowball' => 0,
        'Lingua::Stem::UniNE'    => 0,
        'List::Util'             => 0,
        'Moo'                    => '1.000000',
    },
    meta_merge => {
        resources => {
            repository => 'git://github.com/patch/lingua-stem-any-pm5.git',
            homepage   => 'https://github.com/patch/lingua-stem-any-pm5',
            bugtracker => 'https://github.com/patch/lingua-stem-any-pm5/issues',
        },
    },
);

$builder->create_build_script;
