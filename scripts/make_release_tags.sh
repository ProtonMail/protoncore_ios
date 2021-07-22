#!/bin/bash -x

git checkout main
git pull --rebase --quiet

CURRENT_VERSION=$(cat pods_configuration.rb | grep "\$version = " | sed "s/\$version = \"//" | sed "s/\"//")

git tag $CURRENT_VERSION
git push origin $CURRENT_VERSION -o ci.skip
