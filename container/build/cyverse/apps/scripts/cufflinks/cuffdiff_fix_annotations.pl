#!/usr/bin/perl -w
use strict;


my $infile = shift or die "No infile";
my $fasta  = shift || '';;
$fasta = "-s $fasta" if $fasta;

print STDERR "\n\nFixing annotation file $infile to work with cuffdiff!\n\n";

system "cuffcompare -r $infile $fasta -T $infile";
system "bin/munge_ids.pl <cuffcmp.combined.gtf >annotation.gtf";
system "mv annotation.gtf $infile" unless $infile eq 'annotation.gtf';
system "rm -f cuffcmp* *fai";
