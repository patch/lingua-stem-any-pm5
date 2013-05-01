use utf8;
use strict;
use warnings;
use English;
use Test::More tests => 1;

BEGIN { use_ok 'Lingua::Stem::Any' }

diag 'Testing ', join ', ' => (
    "Lingua::Stem::Any $Lingua::Stem::Any::VERSION",
    "Moo $Moo::VERSION",
    "Perl $PERL_VERSION ($EXECUTABLE_NAME)",
);
