#!/bin/bash -x

# kill $(ps aux | grep 'Xcode' | awk '{print $2}')

git checkout origin develop
git fetch origin 
git pull origin develop --rebase

USAGE="bash scripts/create_version_update_merge_request.sh [version]

where version is in the semantic versioning format: MAJOR.MINOR.PATCH"

if [ $1 == "--help" ]; then
  echo "Usage:"
  echo "$USAGE"
  exit
fi

if [ $# -eq 0 ]; then
  echo "No version provided! The right usage:"
  echo "$USAGE"
  exit
elif [ $# -ne 1 ]; then
  echo "Too many parameters provided. The right usage:"
  echo "$USAGE"
  exit
fi

NEW_VERSION=$1

if [[ $NEW_VERSION =~ ^[[:digit:]]*\.[[:digit:]]*\.[[:digit:]]*$ ]]; then
  :
else 
  echo "Wrong format version. It should be: MAJOR.MINOR.PATCH"
  exit  
fi

CURRENT_VERSION=$(cat pods_configuration.rb | grep "\$version = " | sed "s/\$version = \"//" | sed "s/\"//")

if [[ $NEW_VERSION = $CURRENT_VERSION ]]; then 
  echo "The new version should be higher than the current version"
  exit  
fi

HIGHER_VERSION=$(echo -e "$CURRENT_VERSION\n$NEW_VERSION" | sort -r -V | head -n 1)

if [[ $HIGHER_VERSION != $NEW_VERSION ]]; then 
  echo "The new version should be higher than the current version"
  exit  
fi

git checkout -b feature/$NEW_VERSION

bash scripts/set_new_pods_version.sh $NEW_VERSION

bash scripts/update_pods_in_example_projects.sh

git add . -A
git commit -m "[$NEW_VERSION] Update version to $NEW_VERSION"
git push origin feature/$NEW_VERSION -o merge_request.create -o merge_request.target=develop -o merge_request.remove_source_branch -o merge_request.assign="yzhang" -o merge_request.assign="siejkowski" -o merge_request.assign="gbiegaj"





