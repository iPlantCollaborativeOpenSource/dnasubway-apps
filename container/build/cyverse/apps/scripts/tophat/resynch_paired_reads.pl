#!/usr/bin/perl -w
use strict;

# The purpose of this script to to re-synch paired end
# read files after the disruptive process of quality filtering,
# so that all reads are paired in their two files, as is 
# required by TopHat.

my (%left,%right);

my $left  = shift;
my $right = shift;


$left && $right || die "Usage: ./resynch_paired_reads.pl left_reads.fastq right_reads.fastq\n";

# compile regexp
my $re = qr/^\@(\d+)\s+/;

open LEFT, $left  or die $!;
open RIGHT,$right or die $!;

print "Reading in read indices\nleft reads: ";
while (<LEFT>) {
    next unless /$re/;
    $left{$1}++;
}
print scalar keys %left, "\n";

print "right reads: ";
while (<RIGHT>) {
    next unless /$re/;
    $right{$1}++;
}

print scalar keys %right, "\n";

values %left && values %right 
    || die "Reads not indexed!\nDid you run index_fastq_reads.pl on the left ".
           "and right reads files first?\n";

close LEFT;
close RIGHT;

print "re-synching pared sets...\n";
for my $k (keys %left) {
    delete $left{$k} unless $right{$k};
}

open LEFT, $left  or die $!;
open RIGHT,$right or die $!;
open LOUT, ">$left\_synched";
open ROUT, ">$right\_synched";

my (@read,$read,$idx);
print "writing new left read file\n";
while (<LEFT>) {
    $idx++;
    push @read, $_;
    if ($idx == 1) {
        ($read) = /$re/;
    }
    if ($idx == 4) {
        $idx = 0;
        print LOUT join('',@read) if $left{$read};
        @read = ();
        $read = 0;
    }
}

print "writing new right read file\n";
(@read,$read,$idx) = ();
while (<RIGHT>) {
    $idx++;
    push @read,$_;
    if ($idx == 1) {
        ($read) = /$re/;
    }
    if ($idx ==4) {
        $idx = 0;
        print ROUT join('',@read) if $left{$read};
        @read =();
        $read = 0;
    }
}

exit 0;
