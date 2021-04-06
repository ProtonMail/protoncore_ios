#!/bin/bash -x

CURRENT_VERSION=$(cat pods_configuration.rb | grep "\$version = " | sed "s/\$version = \"//" | sed "s/\"//")

git fetch --tags --force --quiet
TAGS_STRING=$(git tag --points-at $CURRENT_VERSION | tr '\n' ' ')
TAGS_ARRAY=(`echo "$TAGS_STRING"`)

git checkout main
git pull --rebase --quiet

echo "Transfering tags $TAGS_STRING"

for TAG in "${TAGS_ARRAY[@]}"
do  
    echo "Transfering $TAG"    
    git tag --delete $TAG
    git push --delete origin $TAG
    git tag $TAG
    git push origin $TAG -o ci.skip
done
