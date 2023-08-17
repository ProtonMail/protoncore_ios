#!/bin/bash -x

if [ $# -eq 0 ]; then
  echo "No branch name provided"
  exit
elif [ $# -ne 1 ]; then
  echo "Too many parameters provided"
  exit
fi

RELEASE_BRANCH=$1

git fetch origin --tags --force --prune
git checkout --track origin/$RELEASE_BRANCH
git pull origin $RELEASE_BRANCH --rebase --quiet

CURRENT_VERSION=$(cat pods_configuration.rb | grep "\$version = " | sed "s/\$version = \"//" | sed "s/\"//")

git tag $CURRENT_VERSION
git push origin $CURRENT_VERSION -o ci.skip
