#!/usr/bin/perl -w
use strict;
my $count = 0;
while (<>) {
    chomp;
    if ($count++ % 4 == 2 && /^\+/) {
	s/\+.+$/\+/;
    }
    print "$_\n";
}
