#!/bin/bash

IMG_ORG="cyverse"
IMG_TAG="dnasub_base"
REBUILD=${REBUILD:-1}
MD5APP="openssl md5 "

WORKDIR=$PWD
BUILD_DIR=${WORKDIR}/build/${IMG_ORG}/${IMG_TAG}
PKG_CACHE=${BUILD_DIR}/dnasub_lang/docker/cache
IMGNAME="${IMG_ORG}-${IMG_TAG}.img"

mkdir -p ${PKG_CACHE}
cd ${PKG_CACHE}

for U in https://curl.haxx.se/download/curl-7.51.0.tar.gz \
		 https://cran.r-project.org/src/base/R-3/R-3.2.1.tar.gz \
		 http://pypi.python.org/packages/source/d/distribute/distribute-0.6.27.tar.gz \
		 http://www.python.org/ftp/python/2.7.1/Python-2.7.1.tar.bz2
do
  BASENAME=$(basename $U)
  if [ ! -f ${BASENAME} ];
  then
    echo "Fetching $BASENAME"
    curl -#L -O $U && ${MD5APP} ${BASENAME} > ${BASENAME}.md5
  fi
done

cd ${BUILD_DIR}

for K in dnasub_core dnasub_lang dnasub_base
do
  echo "Building $K..."
  cd ${BUILD_DIR}/${K}/docker
  docker build -f Dockerfile -t cyverse/${K} .
  cd ${BUILD_DIR}
  echo "Done"

  echo "Testing ${K}..."
  docker run cyverse/${K}

done

cd $WORKDIR
