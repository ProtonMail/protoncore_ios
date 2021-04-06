#!/bin/bash -x

# kill $(ps aux | grep 'Xcode' | awk '{print $2}')

HASH_TAG_PREFIX="commit_"

git checkout main
git fetch
git pull --rebase

PREVIOUS_DEVELOP_COMMIT_HASH=$(git tag --points-at HEAD | grep "$HASH_TAG_PREFIX" | sed "s/$HASH_TAG_PREFIX//")
PREVIOUS_VERSION=$(git tag --points-at HEAD | grep --regex "^\d*\.\d*\.\d*\$")

git checkout develop
git fetch
git pull --rebase

CURRENT_DEVELOP_COMMIT_HASH=$(git rev-parse HEAD)
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

echo "Creating release branch: release/$CURRENT_VERSION"

git checkout -b release/$CURRENT_VERSION

git rebase --onto main $PREVIOUS_DEVELOP_COMMIT_HASH release/$CURRENT_VERSION

git tag $HASH_TAG_PREFIX$CURRENT_DEVELOP_COMMIT_HASH
git tag $CURRENT_VERSION
git push origin $HASH_TAG_PREFIX$CURRENT_DEVELOP_COMMIT_HASH -o ci.skip
git push origin $CURRENT_VERSION -o ci.skip

git push origin release/$CURRENT_VERSION -o merge_request.create -o merge_request.target=main -o merge_request.remove_source_branch -o merge_request.title="Release $CURRENT_VERSION" -o merge_request.assign="yzhang" -o merge_request.assign="siejkowski" -o merge_request.assign="gbiegaj"