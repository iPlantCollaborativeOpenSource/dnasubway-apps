#!/bin/bash

APPLIST="wc fastqc tophat fastx cufflinks cuffmerge cuffdiff tophat-refprep"

IMG_ORG="cyverse"
IMG_TAG="dnasub_apps"
REBUILD=${REBUILD:-1}

WORKDIR=$PWD
BUILD_DIR=${WORKDIR}/build/${IMG_ORG}
PKG_CACHE=${BUILD_DIR}/${IMG_TAG}/cache
IMGNAME="${IMG_ORG}-${IMG_TAG}.img"

MD5APP="openssl md5 "
# Todo: Validation test for MD5APP

# Get major.minor Docker version.
# Error if can't find Docker or version too low.
DOCKER_VERSION=$(docker --version | egrep -o  "\d\.\d+")
echo "Docker version ${DOCKER_VERSION} detected."
if [ $(echo ${DOCKER_VERSION}'<'1.10 | bc -l) == 1 ];
then
  echo "Critical error: Docker 1.10 or higher is required to build a Singularity image."
fi

mkdir -p ${PKG_CACHE}
cd ${PKG_CACHE}

for U in https://netcologne.dl.sourceforge.net/project/samtools/samtools/0.1.19/samtools-0.1.19.tar.bz2 \
         https://github.com/agordon/fastx_toolkit/releases/download/0.0.14/fastx_toolkit-0.0.14.tar.bz2 \
         https://github.com/agordon/libgtextutils/releases/download/0.7/libgtextutils-0.7.tar.gz \
         http://ccb.jhu.edu/software/tophat/downloads/tophat-2.0.11.Linux_x86_64.tar.gz \
         https://github.com/broadinstitute/picard/releases/download/1.120/picard-tools-1.120.zip \
         http://liquidtelecom.dl.sourceforge.net/project/bowtie-bio/bowtie2/2.2.1/bowtie2-2.2.1-linux-x86_64.zip \
         http://cole-trapnell-lab.github.io/cufflinks/assets/downloads/cufflinks-2.1.0.Linux_x86_64.tar.gz \
         http://www.bioinformatics.babraham.ac.uk/projects/fastqc/fastqc_v0.11.4.zip
do
  BASENAME=$(basename $U)
  if [ ! -f ${BASENAME} ];
  then
    echo "Fetching $BASENAME"
    curl -#L -O $U 
  fi
done

cd $WORKDIR

mkdir -p ${BUILD_DIR}/dnasub_apps/runners && cp -R bundles/scripts ${BUILD_DIR}/dnasub_apps/

for K in $APPLIST
do
  echo "Copying runner for $K..."
  if [ -f "bundles/$K/run-${K}.sh" ];
  then
	  cp bundles/$K/run-${K}.sh ${BUILD_DIR}/dnasub_apps/runners/
  fi
done

if [ "$REBUILD" -eq "1" ];
then

  cd $BUILD_DIR/dnasub_apps

    echo "Building apps container..."
    mkdir -p tmp
  	docker build -f Dockerfile -t cyverse/dnasub_apps . && \
    rm -rf runners && \
    rm -rf scripts && \
  	docker run cyverse/dnasub_apps

    if [ ! -f "${WORKDIR}/assets/${IMGNAME}.bz2" ]
    then
      echo "Building Singularity image..."
    	docker run \
    	-v /var/run/docker.sock:/var/run/docker.sock \
    	-v $PWD:/output \
    	--privileged -t --rm \
    	singularityware/docker2singularity:${DOCKER_VERSION} \
    	cyverse/dnasub_apps && \
      find . -name "*.img" -exec mv {} ${WORKDIR}/assets/${IMGNAME} \; && \
      echo "Compressing ${IMGNAME} ..." && \
      bzip2 ${WORKDIR}/assets/${IMGNAME} && \
      echo "Computing MD5 checksum ..." && \
      cd ${WORKDIR}/assets && \
      ${MD5APP} ${IMGNAME}.bz2 > ${IMGNAME}.bz2.md5
    fi

    echo "Done"

  cd $WORKDIR

fi

for K in $APPLIST
do
  echo "Copying wrapper and test for $K..."
  if [ -f "bundles/$K/wrap-${K}.sh" ];
  then
    cp bundles/$K/wrap-${K}.sh ${WORKDIR}/assets/
  fi
  if [ -f "bundles/$K/test-${K}.sh" ];
  then
    cp bundles/$K/test-${K}.sh ${WORKDIR}/assets/
  fi
done

cd $WORKDIR
