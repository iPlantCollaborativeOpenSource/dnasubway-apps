#!/usr/bin/perl -w
use strict;

my $labels = shift;
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

my $r = << "END";
library(cummeRbund)
cuff <- readCufflinks()
png('./graphs/density_plot.png')
csDensity(genes(cuff))
dev.off()
END
;

$r .= << "END";
png("./graphs/dispersion_plot.png")
dispersionPlot(genes(cuff))
dev.off()
png("./graphs/SCV_plot.png")
fpkmSCVPlot(genes(cuff))
dev.off()

END
;

for (@pairs) {
    my ($i,$j) = @$_;
    $r .= << "END";
png("./graphs/$i\_$j\_scatter_plot.png")
csScatter(genes(cuff),"$i","$j",smooth=T)
dev.off()
png("./graphs/$i\_$j\_MA_plot.png")
MAplot(genes(cuff),"$i","$j")
END
;
}

$r .= << "END";
png("./graphs/volcano_matrix_plot.png")
csVolcanoMatrix(genes(cuff));
dev.off()
END
;

# Forcing Cairo support works around the need for Xvfb
# which doesn't really work in containerized setups very well
# Source: http://stackoverflow.com/questions/24999983/r-unable-to-start-device-png-capabilities-has-true-for-png

open RS, ">cuffdiff_out/basic_plots.R";
print RS "options(bitmapType='cairo')";
print RS $r;
close RS;

my $pwd = `pwd`;
chdir "cuffdiff_out";
system "mkdir graphs";
system "perl -i -pe 's/(\\S)\\s+?\\#/\$1\\-/' *.*";
system "R --vanilla < basic_plots.R";
chdir $pwd;

