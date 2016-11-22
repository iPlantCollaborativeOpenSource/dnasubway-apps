#!/bin/bash

echo ""
printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' =

echo "AGAVE_TENANT: $AGAVE_TENANT"
echo "APP: $_APP"
echo "AUTHOR: $_AUTHOR"
echo "LICENSE: $_LICENSE"
echo "VERSION: $_VERSION"
echo "BIN_PATH: $PATH"
echo "LIBRARY_PATH: $LIBRARY_PATH"

printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -

echo "ENVIRONMENT:"
env | grep -v "^_"

printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -

echo "SYSTEM CONTEXT:"
echo "UNAME:  $(uname -a)"
echo -e "VOLUMES:\n$(df -l)"
echo "PWD: $(pwd)"
echo -e "PWDTREE:\n$(tree -L 3)"

printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -

echo "IMAGE ENTRYPOINT: $0"

printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' =
echo ""