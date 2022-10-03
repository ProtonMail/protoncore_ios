#!/bin/bash -x

REPOSITORY="https://github.com/pointfreeco/swift-snapshot-testing"

USAGE="bash scripts/update_swift_snapshot_testing_dependency.sh [version]

where version is in the release tag name in the $REPOSITORY"
  

if [ "$1" == "--help" ]; then
  echo "Usage:"
  echo "$USAGE"
  exit
fi

if [ $# -eq 0 ]; then
  echo "No version provided. The script should be invoked with:"
  echo "$USAGE"
  exit

elif [ $# -eq 1 ]; then
  VERSION=$1

elif [ $# -ne 2 ]; then
  echo "Too many parameters provided. The script should be invoked with:"
  echo "$USAGE"
  exit
fi


git subtree pull --squash --message "Update swift-snapshot-testing code to $VERSION" --prefix=third-party/swift-snapshot-testing "$REPOSITORY" "$VERSION"


sed -i '' -r "s/^.+s.version.+=.+\'.*\'/    s.version          = \'$VERSION\'/g" swift-snapshot-testing.podspec

bash scripts/update_pods_in_example_projects.sh

git add . -A
git commit -m "Update swift-snapshot-testing podspec version to $VERSION"

