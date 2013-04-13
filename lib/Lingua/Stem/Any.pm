package Lingua::Stem::Any;

use v5.6;
use utf8;
use Moo;
use Carp;
use List::Util qw( first );

our $VERSION = '0.01';

my %sources = (
    'Lingua::Stem::Snowball' => {
        languages => {map { $_ => 1 } qw(
            da de en es fi fr hu it la nl no pt ro ru sv tr
        )},
        builder => sub {
            my $language = shift;
            require Lingua::Stem::Snowball;
            my $stemmer = Lingua::Stem::Snowball->new(
                lang     => $language,
                encoding => 'UTF-8',
            );
            return {
                stem     => sub { $stemmer->stem(\@_) },
                in_place => sub { $stemmer->stem_in_place(shift) },
                language => sub { $stemmer->lang(shift) },
            };
        },
    },
    'Lingua::Stem::UniNE' => {
        languages => {map { $_ => 1 } qw(
            bg cs fa
        )},
        builder => sub {
            my $language = shift;
            require Lingua::Stem::UniNE;
            my $stemmer = Lingua::Stem::UniNE->new(language => $language);
            return {
                stem     => sub { $stemmer->stem(@_) },
                in_place => sub { $stemmer->stem(shift) },
                language => sub { $stemmer->language(shift) },
            };
        },
    },
    'Lingua::AR::Word' => {
        languages => { ar => 1 },
        builder => sub {
            my $language = shift;
            require Lingua::AR::Word::Stem;
            return {
                stem     => sub { map { Lingua::AR::Word::stem($_) } @_ },
                in_place => sub {
                    for my $word (@{$_[0]}) {
                        $word = Lingua::AR::Word::stem($word);
                    }
                },
                language => sub {},
            };
        },
    },
    'Lingua::LA::Stemmer' => {
        languages => { la => 1 },
        builder => sub {
            my $language = shift;
            require Lingua::LA::Stemmer;
            return {
                stem     => sub { Lingua::LA::Stemmer::stem(@_) },
                in_place => sub {
                    for my $word (@{$_[0]}) {
                        $word = Lingua::LA::Stemmer::stem($word);
                    }
                },
                language => sub {},
            };
        },
    },
);

my @source_order = qw(
    Lingua::Stem::Snowball
    Lingua::Stem::UniNE
    Lingua::AR::Word
    Lingua::LA::Stemmer
);
my %is_language = map { %{$_->{languages}} } values %sources;
my @languages   = sort keys %is_language;

has language => (
    is       => 'rw',
    isa      => sub { croak "Invalid language '$_[0]'"
                      unless $is_language{$_[0]} },
    coerce   => sub { defined $_[0] ? lc $_[0] : '' },
    trigger  => 1,
    required => 1,
);

has source => (
    is      => 'rw',
    isa     => sub { croak "Invalid source '$_[0]'"
                     unless $sources{$_[0]} },
    trigger => 1,
);

has _stemmer => (
    is      => 'ro',
    builder => '_build_stemmer',
    clearer => '_clear_stemmer',
    lazy    => 1,
);

# the stemmer is cleared whenever a language or source is updated
sub _trigger_language {
    my $self = shift;

    $self->_clear_stemmer;

    # keep current source if it supports this language
    return if $self->source
           && $sources{$self->source}{languages}{$self->language};

    # use the first supported source for this language
    $self->source(
        first { $sources{$_}{languages}{$self->language} } @source_order
    );
}

sub _trigger_source {
    my $self = shift;

    $self->_clear_stemmer;
}

# the stemmer is built lazily on first use
sub _build_stemmer {
    my $self = shift;

    croak sprintf "Invalid source '%s' for language '%s'" => (
        $self->source, $self->language
    ) unless $sources{$self->source}{languages}{$self->language};

    $sources{$self->source}{stemmer}
        ||= $sources{$self->source}{builder}->($self->language);

    $sources{$self->source}{stemmer}{language}->($self->language);

    return $sources{$self->source}{stemmer};
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
        $self->_stemmer->{in_place}->($_[0]);
        return;
    }
    else {
        my @stems = $self->_stemmer->{stem}->(@_);
        return wantarray ? @stems : pop @stems;
    }
}

1;

__END__

=encoding UTF-8

=head1 NAME

Lingua::Stem::Any - Consistent interface to any stemmer on CPAN

=head1 VERSION

This document describes Lingua::Stem::Any v0.01.

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
    │ Arabic     │ ar │
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
    │ Lingua::AR::Word       │ ar                                           │
    │ Lingua::LA::Stemmer    │ la                                           │
    └────────────────────────┴──────────────────────────────────────────────┘

A module name is used to specify the source.  If no source is specified, the
first available source in the above list with support for the current language
is used.

    # get current source
    $source = $stemmer->source;

    # change source
    $stemmer->source('Lingua::Stem::UniNE');

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

=item sources

Returns a list of supported source module names.

    # object method
    @languages = $stemmer->sources;

    # class method
    @languages = Lingua::Stem::UniNE->sources;

=back

=head1 SEE ALSO

L<Lingua::Stem::Snowball>, L<Lingua::Stem::UniNE>, L<Lingua::Stem>

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
