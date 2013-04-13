use utf8;
use strict;
use warnings;
use open qw( :encoding(UTF-8) :std );
use Test::More tests => 91;
use Lingua::Stem::Any;

my ($stemmer, @words, @words_copy);

$stemmer = new_ok 'Lingua::Stem::Any', [language => 'cs'];

can_ok $stemmer, qw( stem language languages source );

is $stemmer->language, 'cs', 'language read-accessor';

my @langs = sort qw(
    ar bg cs da de en es fa fi fr hu it la nl no pt ro ru sv tr
);
my $langs = @langs;
is_deeply [$stemmer->languages],          \@langs, 'object method list';
is_deeply [Lingua::Stem::Any->languages], \@langs, 'class method list';
is_deeply [Lingua::Stem::Any::languages], \@langs, 'function list';
is scalar $stemmer->languages,             $langs, 'object method scalar';
is scalar Lingua::Stem::Any->languages,    $langs, 'class method scalar';
is scalar Lingua::Stem::Any::languages,    $langs, 'function scalar';

my @sources = qw(
    Lingua::Stem::Snowball
    Lingua::Stem::UniNE
    Lingua::AR::Word
    Lingua::LA::Stemmer
);
my $sources = @sources;
is_deeply [$stemmer->sources],          \@sources, 'object method list';
is_deeply [Lingua::Stem::Any->sources], \@sources, 'class method list';
is_deeply [Lingua::Stem::Any::sources], \@sources, 'function list';
is scalar $stemmer->sources,             $sources, 'object method scalar';
is scalar Lingua::Stem::Any->sources,    $sources, 'class method scalar';
is scalar Lingua::Stem::Any::sources,    $sources, 'function scalar';

@words = @words_copy = qw( že dobře ještě );
is_deeply [$stemmer->stem(@words)], [qw( že dobř jesk )], 'list of words';
is_deeply \@words, \@words_copy, 'not destructive on arrays';

$stemmer->stem(\@words);
is_deeply \@words, [qw( že dobř jesk )], 'arrayref modified in place';

is_deeply scalar $stemmer->stem(@words), 'jesk', 'list of words in scalar';

is_deeply [$stemmer->stem('prosím')], ['pro'], 'word in list context';
is_deeply [$stemmer->stem()],         [],      'empty list in list context';
is scalar $stemmer->stem('prosím'),   'pro',   'word in scalar context';
is scalar $stemmer->stem(),           undef,   'empty list in scalar context';

is $stemmer->stem('работа'), 'работа', 'only stem for current language';

$stemmer->language('bg');
is $stemmer->language,       'bg',  'language changed via write-accessor';
is $stemmer->stem('работа'), 'раб', 'language change confirmed by stemming';

$stemmer->language('CS');
is $stemmer->language,       'cs',  'language coerced via write-accessor';
is $stemmer->stem('prosím'), 'pro', 'language coersion confirmed by stemming';

eval { $stemmer->language('xx') };
like $@, qr/Invalid language 'xx'/, 'invalid language via write-accessor';

eval { $stemmer->language('') };
like $@, qr/Invalid language ''/, 'empty string as language via write-accessor';

eval { $stemmer->language(undef) };
like $@, qr/Invalid language ''/, 'undef as language via write-accessor';

eval { Lingua::Stem::Any->new(language => 'xx') };
like $@, qr/Invalid language 'xx'/, 'invalid language via instantiator';

eval { Lingua::Stem::Any->new() };
like $@, qr/Missing required arguments: language/, 'instantiator w/o language';

$stemmer = new_ok 'Lingua::Stem::Any', [
    language => 'de',
    source   => 'Lingua::Stem::Snowball',
], 'new stemmer using Snowball';

@words = @words_copy = qw( sähet singen );
is_deeply [$stemmer->stem(@words)], [qw( sahet sing )], 'list of words';
is_deeply \@words, \@words_copy, 'not destructive on arrays';

$stemmer->stem(\@words);
is_deeply \@words, [qw( sahet sing )], 'arrayref modified in place';

is_deeply scalar $stemmer->stem(@words), 'sing', 'list of words in scalar';

is_deeply [$stemmer->stem('bekämen')], ['bekam'], 'word in list context';
is_deeply [$stemmer->stem()],          [],        'empty list in list context';
is scalar $stemmer->stem('bekämen'),   'bekam',   'word in scalar context';
is scalar $stemmer->stem(),            undef,     'empty list in scalar context';

$stemmer->language('bg');
is $stemmer->language, 'bg',                  'lang changed via write-accessor';
is $stemmer->source,   'Lingua::Stem::UniNE', 'source changed to match language';
is $stemmer->stem('работа'), 'раб', 'language change confirmed by stemming';

$stemmer->source('Lingua::Stem::UniNE');
is $stemmer->source, 'Lingua::Stem::UniNE', 'updating source to itself is noop';

$stemmer->source('Lingua::Stem::Snowball');
eval { $stemmer->stem('работа') };
like $@, qr/Invalid source 'Lingua::Stem::Snowball' for language 'bg'/,
    'invalid source for current language';

eval { $stemmer->source('Acme::Buffy') };
like $@, qr/Invalid source 'Acme::Buffy'/, 'invalid source via write-accessor';

$stemmer->language('tr');
is $stemmer->language, 'tr',                     'lang changed via write-accessor';
is $stemmer->source,   'Lingua::Stem::Snowball', 'source changed to match language';
is $stemmer->stem('değilken'), 'değil', 'language change confirmed by stemming';

my @tests = (
    [qw( ar القامع    قمع      )],
    [qw( bg камили    камил    )],
    [qw( cs velbloudi velbloud )],
    [qw( da kameler   kamel    )],
    [qw( de Kamele    kamel    )],
    [qw( en camels    camel    )],
    [qw( es camellos  camell   )],
    [qw( fa شتر       شتر      )],
    [qw( fi kamelit   kamel    )],
    [qw( fr chameaux  chameau  )],
    [qw( hu tevék     teve     )],
    [qw( it cammelli  cammell  )],
    [qw( la cameli    camel    )],
    [qw( nl kamelen   kamel    )],
    [qw( no kameler   kamel    )],
    [qw( pt camelos   camel    )],
    [qw( ro cămile    căm      )],
    [qw( ru верблюды  верблюд  )],
    [qw( sv kameler   kamel    )],
    [qw( tr develer   deve     )],
);

for my $test (@tests) {
    my ($language, $word, $stem) = @$test;
    $stemmer->language($language);
    is $stemmer->language, $language, "switch language to $language";
    is $stemmer->stem($word), $stem, "$language: $word stems to $stem";
}
