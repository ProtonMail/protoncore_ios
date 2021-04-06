#!/bin/bash -x

CURRENT_VERSION=$(cat pods_configuration.rb | grep "\$version = " | sed "s/\$version = \"//" | sed "s/\"//")

TAGS_STRING=$(git tag --points-at HEAD | grep --regex "\d*\.\d*\.\d*" | sort -r -V | head -2 | sort -V | tr '\n' ' ')
TAGS_ARRAY=(`echo "$TAGS_STRING"`)

for TAG in "${TAGS_ARRAY[@]}"
do  
    git tag --delete $TAG
    git push --delete origin $TAG
done

git push --delete origin release/$CURRENT_VERSION