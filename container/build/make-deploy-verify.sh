#!/bin/bash 

IMG_ORG="cyverse"
IMG_TAG="dnasub_apps"
IMGNAME="${IMG_ORG}-${IMG_TAG}.img.bz2"
MD5APP="openssl md5 "
DEPLOYSYSTEM=data.iplantcollaborative.org
DEPLOYPATH=vaughn/applications/dnasubway/container/assets
DEPLOYNOTIFY=vaughn@tacc.utexas.edu

WORKDIR=$PWD

auth-tokens-refresh -S

echo "Local: file://${PWD}/assets/${IMGNAME}"
LOCALSIZE=$(ls -Lon assets/${IMGNAME} | awk '{ printf $4; }')
#echo $LOCALSIZE

echo "Remote: agave://${DEPLOYSYSTEM}/${DEPLOYPATH}/${IMGNAME}"
REMOTESTATUS=$(files-history -v -S ${DEPLOYSYSTEM} ${DEPLOYPATH}/${IMGNAME} | jq -r .[-1:][0].status )
if [[ "$REMOTESTATUS" == "TRANSFORMING_COMPLETED" ]];
then
	REMOTESIZE=$(files-list -v -S ${DEPLOYSYSTEM} ${DEPLOYPATH}/${IMGNAME} | jq -r .[0].length)
	#echo $REMOTESIZE
	if [ "${LOCALSIZE}" -ne "${REMOTESIZE}" ];
	then
		echo -e "ERROR: File size mismatch.\nLocal: ${LOCALSIZE} bytes Remote: ${REMOTESIZE} bytes\n"
		exit 1
	else
		echo -e "Remote and local files are the same size (${REMOTESIZE} bytes).\nThis is a poor integrity check but better than nothing."
		exit 0
	fi
else
	echo -e "${IMGNAME} has not transferred to ${DEPLOYSYSTEM}.\nPlease check back in a few minutes."
	if [ -n "${REMOTESTATUS}" ];
	then
		echo "(Status=$REMOTESTATUS)"
	fi
	exit 1
fi
