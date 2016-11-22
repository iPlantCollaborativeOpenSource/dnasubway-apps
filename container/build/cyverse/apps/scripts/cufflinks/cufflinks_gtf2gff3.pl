#!/usr/bin/perl -w
use strict;
use List::Util qw/min max/;

# a simple script to convert exon-only cufflinks GTF to 
# GFF3 with explicit genes and mRNAs

my %genes;
while (<>) {
    chomp;
    my @gff = split "\t";
    my $atts = pop @gff;
    my ($gene,$mRNA) = $atts =~ /"([^"]+)"/g;
    $gff[8] = "Parent=$mRNA";
    push @{$genes{$gene}{$mRNA}}, \@gff;
}

my %gff;
for my $gene (keys %genes) {
    my @mRNAs = sort keys %{$genes{$gene}};
    my @coords;
    my (@to_print,$ref,$src,$str);
    for my $mRNA (@mRNAs) {
	my @local_coords;
	my @exons = @{$genes{$gene}{$mRNA}};
	for my $exon (@exons) {
	    $ref ||= $$exon[0];
	    $src ||= $$exon[1]; 
	    $str ||= $$exon[6];
	    push @local_coords, @{$exon}[3,4];

	    $exon = join("\t", @$exon);
	}
	my $start = min(@local_coords);
	my $end   = max(@local_coords);
	push @coords, ($start,$end);
	unshift @exons, join("\t",$ref,$src,'mRNA',$start,$end,'.',$str,'.',"ID=$mRNA;Parent=$gene");
	push @to_print, @exons;
    }
    my $start = min(@coords);
    my $end   = max(@coords);
    unshift @to_print, join("\t",$ref,$src,'gene',$start,$end,'.',$str,'.',"ID=$gene");
    push @{$gff{$ref}}, [$start,\@to_print];
}

print "##gff-version 3\n";
for my $ref (sort keys %gff) {
    my @to_print = map {@$_} map {$_->[1]} sort {$a->[0] <=> $b->[0]} @{$gff{$ref}};
    print join("\n",@to_print), "\n";
}


__END__
gene_id "XLOC_000001"; transcript_id "TCONS_00000001"; exon_number "1"; oId "CUFF.3.1
"; tss_id "TSS1";
