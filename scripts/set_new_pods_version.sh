#!/bin/bash -x

USAGE="bash scripts/set_version.sh [version]

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

echo "Setting version to $NEW_VERSION"

sed -i '' "s/^\$version = \".*\"$/\$version = \"$NEW_VERSION\"/g" pods_configuration.rb

find * -name "*.podspec" -maxdepth 0 -exec sh -c 'mkdir -p Specs/"$(basename {} .podspec)"' \;
find * -name "*.podspec" -maxdepth 0 -exec sh -c 'mkdir -p Specs/"$(basename {} .podspec)/"'$NEW_VERSION \;
find * -name "*.podspec" -maxdepth 0 -exec sh -c 'cp "{}" Specs/"$(basename {} .podspec)/"'$NEW_VERSION \;
find * -name "*.podspec" -maxdepth 0 -exec sh -c 'cp pods_configuration.rb Specs/"$(basename {} .podspec)/"'$NEW_VERSION \;