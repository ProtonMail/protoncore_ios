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

PROTONCORE_ID=1252
TITLE="Release+$CURRENT_VERSION"
DESCRIPTION="Release+$CURRENT_VERSION"
FENG_ID=42
GREG_ID=253
KRIS_ID=361

open "https://gitlab.protontech.ch/apple/shared/protoncore/-/merge_requests/new?merge_request%5Bsource_project_id%5D=$PROTONCORE_ID&merge_request%5Bsource_branch%5D=develop&merge_request%5Btarget_project_id%5D=$PROTONCORE_ID&merge_request%5Btarget_branch%5D=main&merge_request%5Btitle%5D=$TITLE&merge_request%5Bdescription%5D=$DESCRIPTION&merge_request%5Bassignee_ids%5D%5B%5D=$KRIS_ID&merge_request%5Bassignee_ids%5D%5B%5D=$FENG_ID&merge_request%5Bassignee_ids%5D%5B%5D=$GREG_ID&merge_request%5Breviewer_ids%5D%5B%5D=$KRIS_ID&merge_request%5Breviewer_ids%5D%5B%5D=$FENG_ID&merge_request%5Breviewer_ids%5D%5B%5D=$GREG_ID"