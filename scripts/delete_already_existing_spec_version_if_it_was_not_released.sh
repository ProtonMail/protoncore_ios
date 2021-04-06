#!/bin/bash -x

VERSION=$1

find * -name "*.podspec" -maxdepth 0 -exec sh -c 'rm -r -f Specs/"$(basename {} .podspec)/"'$VERSION \;