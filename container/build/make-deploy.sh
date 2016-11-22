#!/bin/bash

APPLIST="wc fastqc fastx tophat cufflinks cuffmerge cuffdiff tophat-refprep"

WORKDIR=$PWD
UPLOAD=${UPLOAD:-1}
DELETE=${DELETE:-1}

DEPLOYSYSTEM=data.iplantcollaborative.org
DEPLOYPATH=vaughn/applications/dnasubway/container
DEPLOYNOTIFY=vaughn@tacc.utexas.edu

auth-tokens-refresh -S

if [ "$UPLOAD" == "1" ];
then

	if [ -d "$WORKDIR/assets" ];
	then
		if [ "$DELETE" == "1" ];
		then
			echo "Deleting remote assets directory first..."
			files-delete ${DEPLOYPATH}/assets
		fi
		files-upload -F $WORKDIR/assets -S $DEPLOYSYSTEM -C $DEPLOYNOTIFY $DEPLOYPATH
	else
		echo "Required directory 'assets' not found."
	fi

else
	echo "Warning: You are not updating assets stored at ${DEPLOYPATH}."
fi

for A in $APPLIST;
do
	if [ -f "$WORKDIR/bundles/$A/app.json" ];
	then
		echo "Registering $A"
		apps-addupdate -F $WORKDIR/bundles/$A/app.json
	fi
done
