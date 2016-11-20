#!/bin/bash

WORKDIR=$PWD
BUILD_DIR=${WORKDIR}/build/cyverse
cd ${BUILD_DIR}

for K in dnasub_core dnasub_lang dnasub_base
do
  echo "Building $K..."
  cd dnasub_base/${K}/docker
  docker build -f Dockerfile -t cyverse/${K} .
  cd ${BUILD_DIR}
  echo "Done"

  echo "Testing ${K}..."
  docker run cyverse/${K}

done

cd $WORKDIR
