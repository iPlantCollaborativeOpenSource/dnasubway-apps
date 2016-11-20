#!/bin/bash

APPLIST="wc fastqc tophat fastx cufflinks cuffmerge cuffdiff"
WORKDIR=$PWD

for A in $APPLIST
do
	bundles/$A/env-${A}.sh
done
