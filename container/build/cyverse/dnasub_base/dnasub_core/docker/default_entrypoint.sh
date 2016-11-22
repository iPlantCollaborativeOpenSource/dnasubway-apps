#!/bin/bash

echo ""
echo "##################################################"

echo "APP: $_APP"
echo "AUTHOR: $_AUTHOR"
echo "LICENSE: $_LICENSE"
echo "VERSION: $_VERSION"
echo "AGAVE_TENANT: $AGAVE_TENANT"
echo "PATH: $PATH"

echo "--------------------------------------------------"

echo "ENVIRONMENT:"
env

echo "--------------------------------------------------"

echo "SYSTEM CONTEXT:"
uname -a
df -l
ls .

echo "--------------------------------------------------"

echo "IMAGE ENTRYPOINT: $0"

echo "##################################################"
echo ""
