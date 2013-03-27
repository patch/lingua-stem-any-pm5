use strict;
use warnings;
use utf8;
use Test::More;

eval 'use Test::Spelling';
plan skip_all => 'Test::Spelling not installed; skipping' if $@;

add_stopwords(<DATA>);
all_pod_files_spelling_ok();

__DATA__
