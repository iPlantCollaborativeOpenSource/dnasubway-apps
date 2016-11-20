#!/usr/bin/env bash

DIR=$(dirname $0)
cd $DIR

cp test.txt.orig test.txt
export TYPE="docker"
export input="test.txt"
DEBUG=0 TYPE=docker ./wrap-wc.sh && cat wc_out/output.txt && rm -rf wc_out && rm -f _* .agave.archive
