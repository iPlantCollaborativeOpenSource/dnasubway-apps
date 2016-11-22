#!/usr/bin/env perl

use strict;
use warnings;

my $left = shift;
my $right = shift;

exit 1 unless $left;

$left  =~ s/-fx\d+|\.f(?:ast)?q//g;

unless ($right) {
    print $left;
    exit 0;
}

$right =~ s/-fx\d+|\.f(?:ast)?q$//g;

my $ll = length $left;
my $lr = length $right;
my $l  = $ll < $lr ? $ll : $lr;

if (abs($ll - $lr) > 1 || $ll < 3) {
    #print STDERR abs($ll - $lr), $/;
    print "$left-$right";
    exit 0;
}

my $name = '';
for (0 .. $l) {
    #print STDERR ' ', substr($left, $_, 1), ' ', substr($right, $_, 1), $/;
    if (lc(substr($left, $_, 1)) eq lc(substr($right, $_, 1))) {
        $name .= substr($left, $_, 1);
    }
}

$name =~ s/([^a-z0-9])+/$1/gi;
$name =~ s/[^a-z0-9]*$//i;
print $name;

exit 0;
