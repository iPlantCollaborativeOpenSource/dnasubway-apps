#!/usr/bin/env bash

DIR=$(dirname $0)
cd $DIR

export ENTRYPOINT="/usr/bin/env"
export TYPE="docker"
export input="test.txt"
TYPE=docker ./wrap-fastqc.sh && rm -f _* .agave.archive

