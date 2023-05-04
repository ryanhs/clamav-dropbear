#!/bin/sh
MSYS_NO_PATHCONV=1

# Azure Devops / TFS scan, provide git remote url & PAT

# example: ./devops-scan.sh <remote url> <PAT> <dir_name_path_to_clone>
# example: ./devops-scan.sh "http://visual...com/project/_git/acme" xxxxxxxxx /home/node/workspace/acme_project


# Check is Lock File exists, if not create it and set trap on exit
LOCKFILE=/tmp/devops-scan.lock
if { set -C; 2>/dev/null > $LOCKFILE; }; then
    trap "rm -f $LOCKFILE" EXIT
else
    echo "Device or resource busy! exiting"
    exit 16; # Device or resource busy
fi

# vars
REMOTE_URL=$1
PAT=$2
B64_PAT=$(printf "%s"":$PAT" | base64)
GENERATED_CHECKOUT_DIR=$PWD/workspace/`date +%s`
CHECKOUT_DIR=${3:-$GENERATED_CHECKOUT_DIR}

# echo
# echo "REMOTE_URL: $REMOTE_URL"
# echo "PAT: $PAT"
# echo "B64_PAT: $B64_PAT"
# echo "GENERATED_CHECKOUT_DIR: $GENERATED_CHECKOUT_DIR"
# echo "CHECKOUT_DIR: $CHECKOUT_DIR"
# echo

# freshclam -l /dev/null --stdout  -F

# clone
mkdir -p $CHECKOUT_DIR
git -c http.extraHeader="Authorization: Basic ${B64_PAT}" \
    clone --depth=1 $REMOTE_URL $CHECKOUT_DIR

# remove .git for faster scan
rm -rf $CHECKOUT_DIR/.git


# scan
echo "scanning..."
clamscan --stdout -i -r $CHECKOUT_DIR

# cleanup
rm -rf $CHECKOUT_DIR