package Lingua::Stem::Any;

use v5.6;
use utf8;
use strict;
use warnings;

our $VERSION = '0.00_1';

1;

__END__

=encoding UTF-8

=head1 NAME

Lingua::Stem::Any - consistent interface to any stemmer on CPAN

=head1 VERSION

This document describes Lingua::Stem::Any v0.00_1.

=head1 SYNOPSIS

    use Lingua::Stem::Any;

    # create German stemmer using the default source module
    $stemmer = Lingua::Stem::Any->new(language => 'de');

    # create German stemmer explicitly using Lingua::Stem::Snowball
    $stemmer = Lingua::Stem::Any->new(language => 'de', source => 'snowball');

    # get stem for word
    $stem = $stemmer->stem($word);

    # get list of stems for list of words
    @stems = $stemmer->stem(@words);

    # replace words in array reference with stems
    $stemmer->stem(\@words);

=head1 DESCRIPTION

This module aims to provide a simple unified interface to any stemmer on CPAN.
It will provide a default available source module when a language is requested
and no specific source is requested.

=head2 Attributes

=over

=item language

The following language codes are currently supported.

    ┌────────────┬────┐
    │ Bulgarian  │ bg │
    │ Czech      │ cs │
    │ Danish     │ da │
    │ Dutch      │ nl │
    │ English    │ en │
    │ Finnish    │ fi │
    │ French     │ fr │
    │ German     │ de │
    │ Hungarian  │ hu │
    │ Italian    │ it │
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

    # instantiate a stemmer object
    $stemmer = Lingua::Stem::Any->new(language => $language);

    # get current language
    $language = $stemmer->language;

    # change language
    $stemmer->language($language);

Country codes such as C<cz> for the Czech Republic are not supported, nor are
IETF language tags such as C<pt-PT> or C<pt-BR>.

=item source

The following source modules are currently supported.

    ┌────────────────────────┬──────────┬──────────────────────────────────────────────┐
    │ Module                 │ Alias    │ Languages                                    │
    ├────────────────────────┼──────────┼──────────────────────────────────────────────┤
    │ Lingua::Stem::Snowball │ snowball │ da nl en fi fr de hu it no pt ro ru es sv tr │
    │ Lingua::Stem::UniNE    │ unine    │ bg cs fa                                     │
    └────────────────────────┴──────────┴──────────────────────────────────────────────┘

The full module name or the listed alias can be used to specify the source.  If
no source is specified, the first available source in the list that supports the
specified language is used.  The full module names are case sensitive and the
aliases are case insensitive.

    # get supported sources for the current language
    @sources = $stemmer->sources;

    # get current source
    $source = $stemmer->source;

    # change source to Lingua::Stem::UniNE
    $stemmer->source('unine');

=back

=head2 Methods

=over

=item stem

When a list of strings is provided, each string is stemmed and a list of stems
is returned.  The list returned will always have the same number of elements in
the same order as the list provided.

    @stems = $stemmer->stem(@words);

    # get the stem for a single word
    $stem = $stemmer->stem($word);

When an array reference is provided, each element is stemmed and replaced with
the resulting stem.

    $stemmer->stem(\@words);

The words should be provided as character strings and the stems are returned as
character strings.  Byte strings in arbitrary character encodings are not
supported.

=item languages

Returns a list of supported two-letter language codes using lowercase letters.

    # object method
    @languages = $stemmer->languages;

    # class method
    @languages = Lingua::Stem::UniNE->languages;

In scalar context it returns the number of supported languages.

=back

=head1 ACKNOWLEDGEMENTS

This module is brought to you by L<Shutterstock|http://www.shutterstock.com/>
(L<@ShutterTech|https://twitter.com/ShutterTech>).  Additional open source
projects from Shutterstock can be found at
L<code.shutterstock.com|http://code.shutterstock.com/>.

=head1 AUTHOR

Nick Patch <patch@cpan.org>

=head1 COPYRIGHT AND LICENSE

© 2013 Nick Patch

This library is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.
