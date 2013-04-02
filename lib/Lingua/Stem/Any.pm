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

    # get stem for a word
    $stem = $stemmer->stem($word);

    # get list of stems for a list of words
    @stems = $stemmer->stem(@stems);

    # replace words in array reference with stems
    $stemmer->stem(\@stems);

	# get supported languages
    @languages = $stemmer->languages;

	# get current language
    $language = $stemmer->language;

	# change language to Dutch
    $stemmer->language('nl');

	# get supported sources for the current language
    @sources = $stemmer->sources;

	# get current source
    $source = $stemmer->source;

	# change source to Lingua::Stem::UniNE
    $stemmer->source('unine');

=head1 DESCRIPTION

=over

=item * simple interface

=item * unifies all stemmers

=item * sane defaults

=item * input and output character strings

=back

=head2 Sources

The first source listed for a language is the default.

    Arabic      ar  Lingua::AR::Word
    Bulgarian   bg  Lingua::Stem::UniNE
    Czech       cs  Lingua::Stem::UniNE
    Danish      da  Lingua::Stem::Snowball, Lingua::Stem::Snowball::Da
    Dutch       nl  Lingua::Stem::Snowball
    English     en  Lingua::Stem::Snowball, Lingua::Stem::En, SWISH::Stemmer
    Finnish     fi  Lingua::Stem::Snowball
    French      fr  Lingua::Stem::Snowball, Lingua::Stem::Fr
    Galician    gl  Lingua::GL::Stemmer
    German      de  Lingua::Stem::Snowball, Text::German
    Hungarian   hu  Lingua::Stem::Snowball
    Italian     it  Lingua::Stem::Snowball, Lingua::Stem::It
    Latin       la  Lingua::LA::Stemmer
    Norwegian   no  Lingua::Stem::Snowball, Lingua::Stem::Snowball::No
    Persian     FA  Lingua::Stem::UniNE
    Portuguese  pt  Lingua::Stem::Snowball, Lingua::PT::Stemmer
    Romanian    ro  Lingua::Stem::Snowball
    Russian     ru  Lingua::Stem::Snowball, Lingua::Stem::Ru
    Spanish     es  Lingua::Stem::Snowball, Lingua::Stem::Es
    Swedish     sv  Lingua::Stem::Snowball, Lingua::Stem::Snowball::Se
    Turkish     tr  Lingua::Stem::Snowball

=head1 AUTHOR

Nick Patch <patch@cpan.org>

=head1 COPYRIGHT AND LICENSE

© 2013 Nick Patch

This library is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.
