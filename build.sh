#!/usr/bin/env bash
set -euo pipefail

if [[ "$#" -lt 1 ]]; then
    echo "Usage: $0 /path/to/project/sources"
    exit 1
fi

SRC=$(realpath "$1")

SIGN_KEY_ID=EC56CED77C05107E4C416EF8173873AE062F3A10
SIGN_KEY=$(gpg --armor --export-secret-key $SIGN_KEY_ID)

for DIST in buster; do
    IMAGE_NAME=cmake-deb-builder:$DIST
    CONTAINER_NAME=cmake-deb-builder
    docker build --pull --build-arg DIST=$DIST -t $IMAGE_NAME .
    docker run -it --name $CONTAINER_NAME -v$SRC:/src:ro -e DIST=$DIST -e SIGN_KEY_ID="$SIGN_KEY_ID" -e SIGN_KEY="$SIGN_KEY" $IMAGE_NAME
    docker cp $CONTAINER_NAME:/packages.tar.gz .
    docker rm $CONTAINER_NAME
    mkdir -p packages/$DIST
    tar xvfz packages.tar.gz -C packages/$DIST
    rm packages.tar.gz
done