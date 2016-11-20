#!/usr/bin/perl -w
use strict;
use Data::Dumper;

use File::Basename;

my (%desc);

my $usage = "cuffdiff_sort.pl PATH LABELS SPECIES_NAME(optional, if annotations exists)\n";
my $path   = shift or die $usage;
my $labels = shift or die $usage;
my $species = shift;

my @labels = split(',',$labels);

my @pairs;
my %pair;
for my $i (@labels) {
    for my $j (@labels) {
        my $pair = join '.', sort ($i,$j);
        next if $pair{$pair}++ || $i eq $j;
        push @pairs, [$i,$j];
    }
}

my $fdr = shift || 0.05;

if ($species){
    open DEF, "$path/$species.txt" or die $!;
    while (<DEF>) {
        chomp;
        my ($g,$l,$d) = split "\t";
        $l or next;
        $desc{$l}  = $d || '.';
    }
    close DEF;
}

open INDEX, ">$path/cuffdiff_out/summary.txt" or die $!;

my $idx;
for my $pair (@pairs) {
    $idx++;
    screen_file("$path/cuffdiff_out/gene_exp.diff",1,0,"$path/cuffdiff_out", "genes_$idx\_summary",0,@$pair);
    screen_file("$path/cuffdiff_out/isoform_exp.diff",1,0,"$path/cuffdiff_out", "transcripts_$idx\_summary",1,@$pair);
}

close INDEX;


sub format_p_val {
    my $p = shift;
    $p = sprintf("%.4f", $p) unless $p < 0.0001;
    $p = 1 if $p == 1;
    $p = 0 if $p == 0;
    return $p;
}

sub screen_file {
    my $infile = shift;
    my $maxp   = shift;
    my $minfold = shift;
    my $outpath = shift;
    my $outfile = shift;
    my $transcript = shift;
    my $s1 = shift;
    my $s2 = shift;

    my ($index, %nearest);
    if ($transcript) {
        #$index = '-k8nr';
        $index = '-k9n';
        my $isof_tracking = dirname($infile) . '/isoforms.fpkm_tracking';
        # build the nearest_id hash table
        if (open(my $fh, '<', $isof_tracking)) {
            while (<$fh>) {
                my @data = split "\t";
                if ($data[0] && $data[2]) {
                    $nearest{$data[0]} = $data[2];
                }
            }
            close $fh;
        }
    }
    else {
        $index = '-k7nr';
    }
    
    $outfile = join('/',$outpath,$outfile);

    my @header = $transcript ? ('Transcript', 'Nearest Ref Id') : ();
    push @header, ('Gene','Alias','Fold Change', 'Direction', 'Sample 1 FPKM', 'Sample 2 FPMK', 'Q-Value', 'Description');

    open TXT,  ">$outfile.csv"  or die $!;
    open HTML, ">$outfile.html" or die $!; 

    my $file_base = basename($outfile);
    print INDEX join("\t","$file_base.csv","$file_base.html",$s1,$s2), "\n";

    print TXT join(',', @header), "\n";
    close TXT;
    open  TXT , "| sort $index | perl -pe 's/\t/,/g' >>$outfile.csv";

    open IN, $infile or die "Could not open $infile for writing: $!";
    my ($out,@out);
    while (<IN>) {
        next if /test_id/;
        next unless /OK/;

        chomp;
          
        my @line = split "\t";

        next unless $line[4] eq $s1 || $line[4] eq $s2;
        next unless $line[5] eq $s1 || $line[5] eq $s2;

        my ($gene,$locus) = @line[1,2];
        $locus = '-' if $line[2] eq $gene;
        my $prefix = '';
        if ($locus ne '-'){
            $prefix = "GENE:";
        }
        #$locus = '' if $locus eq '-';
        $gene =~ s/,\S+//;
        my $direction =$line[7] > $line[8] ? 'DOWN' : 'UP';
        if ($line[4] ne $s1) {
            $direction = $direction eq 'UP' ? 'DOWN' : 'UP';
        }

        my ($hi,$lo) = sort { $b <=> $a } $line[7], $line[8];
        next unless $hi && $lo;
        my $fold_change = $hi/$lo;
        next if $minfold && $fold_change < $minfold;
        my $p_val = format_p_val($line[12]);
        next if $maxp && $p_val > $maxp;
        $p_val = "RED:$p_val" if $p_val <= $fdr;
        my $tid = $line[0];
        my $out = $transcript 
                 ? "$tid\t" . (defined $nearest{$tid} ? "NEAREST:$nearest{$tid}" : '') . "\t"
                 : '';

        $out .= join ("\t",$gene,$prefix.$locus,sprintf("%.2f",$fold_change),$direction,$line[7],$line[8],$p_val);
        print "NO p value! $out\n" unless $p_val;

        if (defined $desc{$locus}) {
            $out .= "\t$desc{$locus}\n";
        }
        elsif ($gene =~ /XLOC/ && $locus eq '-') {
            $out .= "\tCufflinks novel gene\n";
        }
        else {
            $out .= "\t\n";
        }

        # we will be csv
        $out =~ s/,/;/g;
        print TXT $out;
    }
    close IN;
    close TXT;


    open TXT, "<$outfile.csv" or die $!;
    
    my $thing  = $transcript ? 'Transcripts' : 'Genes';

    chomp(my $export = `basename $outfile.csv`);
    print HTML <<"END";
<html>
 <head>
  <title>Cuffdiff data summary</title>
  <link type="text/css" rel="stylesheet" href="/css/cdtables.css" />
  <script src="//ajax.googleapis.com/ajax/libs/jquery/2.0.0/jquery.min.js"></script>
  <!-- DataTables CSS -->
  <link rel="stylesheet" type="text/css" href="http://ajax.aspnetcdn.com/ajax/jquery.dataTables/1.9.4/css/jquery.dataTables.css">
  <!-- DataTables -->
  <script type="text/javascript" charset="utf8" src="http://ajax.aspnetcdn.com/ajax/jquery.dataTables/1.9.4/jquery.dataTables.min.js"></script>
 </head>
 <body>
  <div id="export-csv">
   <a href="$export"><img src="/images/v2/csv.jpg" align="middle"> Export data to spreadsheet</a>
  </div>
  <h2>$thing sorted by Q-Value</h2>
  <table id="cd_table" cellspacing=0>
  <thead>
END
;

    my $first = 1;
    my $ehref = 'http://ensemblgenomes.org/search/eg/';
    my $i = 0;
    while (<TXT>) {
        chomp;
        if ($first) {
            $_ = qq(   <tr style="background:gainsboro">\n    <th>$_</th>\n   </tr>);
            s!,!</th>\n    <th>!g;
            $_ .= "\n   </thead>\n   <tbody>\n";
            undef $first;
        }
        else {
            #s/GENE://g if /XLOC|CUFF/;
            $_ = "   <tr>\n    <td>$_</td>\n  </tr>\n";
            s!,!</td>\n    <td>!g;
            s!RED:([^,]+)!<span style="color:red">$1</span>!;
        }
        print HTML $_;
        $i++;
        last if $i > 1000;
    }
   
    my $column = $thing eq 'Genes' ? 6 : 8; 
    print HTML <<"END";
   </tbody>
  </table>
  <script language="Javascript" type="text/javascript">
    \$(document).ready(function() {
      var table = \$("#cd_table").dataTable({
              //"aoColumnDefs": [
              //    { "bSortable": false, "aTargets": [ 2, 3 ] },
              //],
              "bPaginate": false,
              "sScrollY": "350px",
              "sDom": "frtiS",
              "bDeferRender": true,
            });
            // sort by column $column (fpkm) descending on load
            table.fnSort( [ [ $column, 'asc'] ] );
      });
  </script>
 </body>
</html>
END
;

    close TXT;
    close HTML;
    
    system "perl -i -pe 's/GENE\:|RED\:|NEAREST\://g' $outfile.csv";
    system qq(perl -i -pe 's!GENE:([^<]+)!<a href="$ehref\$1" target="_blank">\$1</a>!g' $outfile.html);
    system qq(perl -i -pe 's!NEAREST:([^<]+)!<a href="$ehref\$1" target="_blank">\$1</a>!g' $outfile.html);
}

exit 0;



