#!/usr/bin/env perl

# Authors: Martin Dahlo, Cornel Ghiban
#
# Usage:  perl scriptname.pl <infile
# ex.
# perl scriptname.pl reads.fq

use warnings;
use strict;


=pod

Used to detect the format of a fastq file.

It can only differentiate between Sanger/Illumina1.8+ and Solexa/Illumina1.3+/Illumina1.5+.

To run the program in normal mode, give it only the name of the fastq file:

perl scriptname.pl <infile>
Ex.
perl scriptname.pl myReads.fq


Pseudo code

* Open the fastq file
* Look at each quality ASCII char and convert it to a number
* Depending on if that number is above or below certain thresholds,
  determine the format. 

=cut


# get filename
my $usage = <<EOF;
Usage:  perl scriptname.pl <infile>

EOF

my $fq = shift or die $usage;

# open the files

my $num_lines = 1000;

# initiate
my @line;
my $l;
my $number;
 
my $solexa = 0;
my $sanger = 0;
 
# zcat with -f behaves la cat when $fh is not a gzip file ;)
open FQ, "zcat -f $fq|" or die $!;

# go thorugh the file
while(<FQ>) {

    # if it is the line before the quality line
    if($_ =~ /^\+/) {

			$l = <FQ>; # get the quality line
			chomp($l); # remove newline and whitespaces
			@line = split(//,$l); # divide in chars

			for(my $i = 0; $i <= $#line; $i++){ # for each char

				$number = ord($line[$i]); # get the number represented by the ascii char

				# check if it is sanger or illumina/solexa, based on the ASCII image at http://en.wikipedia.org/wiki/FASTQ_format#Encoding
				if($number > 74){ # if solexa/illumina
				    #die "This file is Solexa/Illumina1.3+/Illumina1.5+ format.\n"; # print result to terminal and die
                    $solexa++;
				}
                if($number < 59){ # if sanger
					#die "This file is Sanger/Illumina 1.8+ format.\n"; # print result to terminal and die
                    $sanger++;
				}
			}
        last unless $num_lines--;
    }
}

#print STDERR '$solexa vs $sanger = ', "$solexa vs $sanger", $/;

if ($solexa > $sanger) {
        print '-Q64';   
}
else {
        print '-Q33';
}

close FQ;

