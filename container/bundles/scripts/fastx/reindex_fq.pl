#!/usr/bin/env perl
use strict;

my $count = 0;
my $readNum = 0;
while (<>) {
    if ($count++ % 4 == 0 && /^@/) {
        my $read = '@' . ++$readNum;
        s/^@[^ ]*/$read /;
    }
    print;
}

