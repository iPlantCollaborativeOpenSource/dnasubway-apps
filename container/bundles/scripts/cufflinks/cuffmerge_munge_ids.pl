#!/usr/bin/perl -w
use strict;

open GTF, "cuffmerge_out/merged.gtf" or die $!;
open OUT, ">cuffmerge_out/merged_with_ref_ids.gtf" or die $!;

while (<GTF>) {
    chomp;
    my ($class_code) = /class_code "([=cj])"/;
    if ($class_code) {
        my ($tid) = /oId "([^\"]+)"/;
        if ($tid) {
            (my $gid = $tid) =~ s/\.\S+$//;
            s/gene_id "[^\"]+"/gene_id "$gid"/;
            s/transcript_id "[^\"]+"/transcript_id "$tid"/;
            print OUT "$_\n";
        }
        else {
            print OUT "$_\n";
        }
    }
    else {
        print OUT "$_\n";
    }
}
close OUT;
close GTF;
