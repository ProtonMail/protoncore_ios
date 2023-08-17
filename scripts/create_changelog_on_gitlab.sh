#!/bin/bash

USAGE="bash scripts/create_changelog_on_gitlab.sh [new_version] [release_branch]

the script also expects to have \$PROTON_GIT_URL and \$GITLAB_REPO_TOKEN 
defined in the environment."

if [ "$1" == "--help" ]; then
  echo "Usage:"
  echo "$USAGE"
  exit
fi

if [ $# -eq 0 ]; then
  echo "The script should be invoked with:"
  echo "$USAGE"
  exit

elif [ $# -eq 2 ]; then
  NEW_VERSION=$1
  RELEASE_BRANCH=$2

else
  echo "Too many parameters provided. The script should be invoked with:"
  echo "$USAGE"
  exit
fi

curl --request POST --header "PRIVATE-TOKEN: $GITLAB_REPO_TOKEN" --data "version=$NEW_VERSION&branch=$RELEASE_BRANCH" "https://$PROTON_GIT_URL/api/v4/projects/1252/repository/changelog"