#!/usr/bin/env bash
set -euo pipefail

if [[ -f /src/cmake-builder-deps ]]; then
    wget -O - https://repo.openwebrx.de/debian/key.gpg.txt | apt-key add
    echo "deb https://repo.openwebrx.de/debian/ $DIST main" > /etc/apt/sources.list.d/openwebrx.list
    apt-get update
    apt-get install -y $(cat /src/cmake-builder-deps)
fi

mkdir -p /build
cd /build
cmake /src
cpack

export GPG_TTY=$(tty)
gpg --batch --import <(echo "$SIGN_KEY")
debsigs --sign=maint -k $SIGN_KEY_ID *.deb

dpkg-deb -I *.deb

tar cvfz /packages.tar.gz *.deb