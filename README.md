[![Build status](https://travis-ci.org/patch/lingua-stem-any-pm5.png)](https://travis-ci.org/patch/lingua-stem-any-pm5)
[![Coverage status](https://coveralls.io/repos/patch/lingua-stem-any-pm5/badge.png)](https://coveralls.io/r/patch/lingua-stem-any-pm5)
[![CPAN version](https://badge.fury.io/pl/Lingua-Stem-Any.png)](http://badge.fury.io/pl/Lingua-Stem-Any)

# NAME

Lingua::Stem::Any - Unified interface to any stemmer on CPAN

# VERSION

This document describes Lingua::Stem::Any v0.03\_1.

# SYNOPSIS

```perl
use Lingua::Stem::Any;

# create German stemmer using the default source module
$stemmer = Lingua::Stem::Any->new(language => 'de');

# create German stemmer explicitly using Lingua::Stem::Snowball
$stemmer = Lingua::Stem::Any->new(
    language => 'de',
    source   => 'Lingua::Stem::Snowball',
);

# get stem for word
$stem = $stemmer->stem($word);

# get list of stems for list of words
@stems = $stemmer->stem(@words);
```

# DESCRIPTION

This module aims to provide a simple unified interface to any stemmer on CPAN.
It will provide a default available source module when a language is requested
but no source is requested.

## Attributes

- language

    The following language codes are currently supported.

        ┌────────────┬────┐
        │ Bulgarian  │ bg │
        │ Czech      │ cs │
        │ Danish     │ da │
        │ Dutch      │ nl │
        │ English    │ en │
        │ Esperanto  │ eo │
        │ Finnish    │ fi │
        │ French     │ fr │
        │ Galician   │ gl │
        │ German     │ de │
        │ Hungarian  │ hu │
        │ Ido        │ io │
        │ Italian    │ it │
        │ Latin      │ la │
        │ Norwegian  │ no │
        │ Persian    │ fa │
        │ Portuguese │ pt │
        │ Romanian   │ ro │
        │ Russian    │ ru │
        │ Spanish    │ es │
        │ Swedish    │ sv │
        │ Turkish    │ tr │
        └────────────┴────┘

    They are in the two-letter ISO 639-1 format and are case-insensitive but are
    always returned in lowercase when requested.

    ```perl
    # instantiate a stemmer object
    $stemmer = Lingua::Stem::Any->new(language => $language);

    # get current language
    $language = $stemmer->language;

    # change language
    $stemmer->language($language);
    ```

    The default language is `en` (English). The values `nb` (Norwegian Bokmål)
    and `nn` (Norwegian Nynorsk) are aliases for `no` (Norwegian). Country codes
    such as `CZ` for the Czech Republic are not supported, as opposed to `cs` for
    the Czech language, nor are full IETF language tags or Unicode locale
    identifiers such as `pt-PT` or `pt_BR`.

- source

    The following source modules are currently supported.

        ┌────────────────────────┬──────────────────────────────────────────────┐
        │ Module                 │ Languages                                    │
        ├────────────────────────┼──────────────────────────────────────────────┤
        │ Lingua::Stem::Snowball │ da de en es fi fr hu it nl no pt ro ru sv tr │
        │ Lingua::Stem::UniNE    │ bg cs de fa                                  │
        │ Lingua::Stem           │ da de en fr gl it no pt ru sv                │
        │ Lingua::Stem::Patch    │ eo io                                        │
        └────────────────────────┴──────────────────────────────────────────────┘

    A module name is used to specify the source. If no source is specified, the
    first available source in the above list with support for the current language
    is used.

    ```perl
    # get current source
    $source = $stemmer->source;

    # change source
    $stemmer->source('Lingua::Stem::UniNE');
    ```

- cache

    Boolean value specifying whether to cache the stem for each word. This will
    increase performance when stemming the same word multiple times at the expense
    of increased memory consumption. When enabled, the stems are cached for the life
    of the object or until the ["clear\_cache"](#clear_cache) method is called. The same cache is
    not shared among different languages, sources, or different instances of the
    stemmer object.

- exceptions

    Exceptions may be desired to bypass stemming for specific words and use
    predefined stems. For example, the plural English word `mice` will not stem to
    the singular word `mouse` unless it is specified in the exception dictionary.
    Another example is that by default the word `pants` will stem to `pant` even
    though stemming is normally not desired in this example. The exception
    dictionary can be provided as a hashref where the keys are language codes and
    the values are hashrefs of exceptions.

    ```perl
    # instantiate stemmer object with exceptions
    $stemmer = Lingua::Stem::Any->new(
        language   => 'en',
        exceptions => {
            en => {
                mice  => 'mouse',
                pants => 'pants',
            }
        }
    );

    # add/change exceptions
    $stemmer->exceptions(
        en => {
            mice  => 'mouse',
            pants => 'pants',
        }
    );

    # alternately...
    $stemmer->exceptions->{en} = {
        mice  => 'mouse',
        pants => 'pants',
    };
    ```

- casefold

    Boolean value specifying whether to apply Unicode casefolding to words before
    stemming them. This is enabled by default and is performed before normalization
    when also enabled.

- normalize

    Boolean value specifying whether to apply Unicode NFC normalization to words
    before stemming them. This is enabled by default and is performed after
    casefolding when also enabled.

## Methods

- stem

    Accepts a list of strings, stems each string, and returns a list of stems. The
    list returned will always have the same number of elements in the same order as
    the list provided. When no stemming rules apply to a word, the original word is
    returned.

    ```perl
    @stems = $stemmer->stem(@words);

    # get the stem for a single word
    $stem = $stemmer->stem($word);
    ```

    The words should be provided as character strings and the stems are returned as
    character strings. Byte strings in arbitrary character encodings are not
    supported.

- stem\_in\_place

    Accepts an array reference, stems each element, and replaces them with the
    resulting stems.

    ```perl
    $stemmer->stem_in_place(\@words);
    ```

    This method is provided for potential optimization when a large array of words
    is to be stemmed. The return value is not defined.

- languages

    Returns a list of supported two-letter language codes using lowercase letters.

    ```perl
    # all languages
    @languages = $stemmer->languages;

    # languages supported by Lingua::Stem::Snowball
    @languages = $stemmer->languages('Lingua::Stem::Snowball');
    ```

- sources

    Returns a list of supported source module names.

    ```perl
    # all sources
    @sources = $stemmer->sources;

    # sources that support English
    @sources = $stemmer->sources('en');
    ```

- clear\_cache

    Clears the stem cache for all languages and sources of this object instance when
    the ["cache"](#cache) attribute is enabled. Does not affect whether caching is enabled.

# SEE ALSO

[Lingua::Stem::Snowball](https://metacpan.org/pod/Lingua::Stem::Snowball), [Lingua::Stem::UniNE](https://metacpan.org/pod/Lingua::Stem::UniNE), [Lingua::Stem](https://metacpan.org/pod/Lingua::Stem), [Lingua::Stem::Patch](https://metacpan.org/pod/Lingua::Stem::Patch)

# AUTHOR

Nick Patch <patch@cpan.org>

This project is brought to you by [Shutterstock](http://www.shutterstock.com/).
Additional open source projects from Shutterstock can be found at
[code.shutterstock.com](http://code.shutterstock.com/).

# COPYRIGHT AND LICENSE

© 2013–2014 Shutterstock, Inc.

This library is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.
