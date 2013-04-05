package Lingua::Stem::Any;

use v5.6;
use utf8;
use Moo;
use List::Util qw( first );

our $VERSION = '0.00_1';

my %sources = (
    'Lingua::Stem::Snowball' => {
        languages => {map { $_ => 1 } qw(
            da de en es fi fr hu it nl no pt ro ru sv tr
        )},
        instantiator => sub {},
    },
    'Lingua::Stem::UniNE' => {
        languages => {map { $_ => 1 } qw(
            bg cs fa
        )},
        stemmer => sub {
            my ($language) = @_;
            require Lingua::Stem::UniNE;
            my $stemmer = Lingua::Stem::UniNE->new(language => $language);
            return sub { $stemmer->stem($_[0]) };
        },
    },
);
my @source_order = qw( Lingua::Stem::Snowball Lingua::Stem::UniNE );
my %is_language  = map { %{$_->{languages}} } values %sources;
my @languages    = sort keys %is_language;

has language => (
    is       => 'rw',
    isa      => sub { die "Invalid language '$_[0]'" if !$is_language{$_[0]} },
    coerce   => sub { defined $_[0] ? lc $_[0] : '' },
    trigger  => 1,
    required => 1,
);

has source => (
    is  => 'rw',
    isa => sub { die "Invalid source '$_[0]'" if !$sources{$_[0]} },
);

has _stemmer => (
    is => 'rw',
);

sub _trigger_language {
    my $self = shift;

    if (!$self->source || !$sources{$self->source}{languages}{$self->language}) {
        $self->source(
            first { $sources{$_}{languages}{$self->language} } @source_order
        );
    }

    $self->_stemmer(
        $sources{$self->source}{stemmer}->($self->language)
    );
}

sub languages {
    return @languages;
}

sub sources {
    return @source_order;
}

sub stem {
    my $self = shift;

    if (@_ == 1 && ref $_[0] eq 'ARRAY') {
        for my $word ( @{$_[0]} ) {
            $word = $self->_stemmer->($word);
        }
        return;
    }
    else {
        my @stems = map { $self->_stemmer->($_) } @_;
        return wantarray ? @stems : pop @stems;
    }
}

1;

__END__

=encoding UTF-8

=head1 NAME

Lingua::Stem::Any - Consistent interface to any stemmer on CPAN

=head1 VERSION

This document describes Lingua::Stem::Any v0.00_1.

=head1 SYNOPSIS

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

    # replace words in array reference with stems
    $stemmer->stem(\@words);

=head1 DESCRIPTION

This module aims to provide a simple unified interface to any stemmer on CPAN.
It will provide a default available source module when a language is requested
but no source is requested.

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

    ┌────────────────────────┬──────────────────────────────────────────────┐
    │ Module                 │ Languages                                    │
    ├────────────────────────┼──────────────────────────────────────────────┤
    │ Lingua::Stem::Snowball │ da nl en fi fr de hu it no pt ro ru es sv tr │
    │ Lingua::Stem::UniNE    │ bg cs fa                                     │
    └────────────────────────┴──────────────────────────────────────────────┘

A module name is used to specify the source.  If no source is specified, the
first available source in the above list with support for the current language
is used.  The source names are case sensitive.

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
