#!/bin/bash -x

git checkout main
git fetch
git pull --rebase

PREVIOUS_VERSION=$(git tag --points-at HEAD | grep --regex "^\d*\.\d*\.\d*.*\$")

git checkout develop
git fetch
git pull --rebase

CURRENT_VERSION=$(cat pods_configuration.rb | grep "\$version = " | sed "s/\$version = \"//" | sed "s/\"//")

if test -z $CURRENT_VERSION; then 
  echo "No current version defined! Check pods_configuration.rb file, version variable must be set"
  exit
fi
if test -z $PREVIOUS_VERSION; then 
  echo "No previous version defined! The main branch is misconfigured and doesn't have the version tag"
  exit
fi
if test $CURRENT_VERSION == $PREVIOUS_VERSION; then
  echo "The current version $CURRENT_VERSION must be different than the previous version $PREVIOUS_VERSION"
  exit
fi

HIGHER_VERSION=$(echo -e "$CURRENT_VERSION\n$PREVIOUS_VERSION" | sort -r -V | head -n 1)

if test $HIGHER_VERSION != $CURRENT_VERSION; then
  echo "The current version $CURRENT_VERSION must be higher than the previous version $PREVIOUS_VERSION"
  exit
fi

echo "Creating release merge request from develop to main"

git push origin develop -o merge_request.create -o merge_request.target=main -o merge_request.remove_source_branch -o merge_request.title="Release $CURRENT_VERSION" -o merge_request.assign="yzhang" -o merge_request.assign="siejkowski" -o merge_request.assign="gbiegaj"