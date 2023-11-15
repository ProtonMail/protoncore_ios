#!/bin/bash

# Conceptually, the release process is composed of two parts:
# A. Updating Cocoapods Podspecs and example app to the new version
# B. Copying the Cocoapods Podspecs for the new version to "Specs"
# C. Making a release tag on a commit with the new version of core
#
# First two points are performed in this script. Third point is done in finish_release_mr_with_new_version.sh.
#
# For updating cocoapods configuration we use code-reviewed merge requests, 
# so that there's a chance for a sanity check from the developers before new version is released.
# 
# Overview of script steps:
# 0. There are three pieces of information we need to update Cocoapods Podspecs:
#   - What is the new version? (version)
#   - What commit contains the source code of the new version? (source)
#   - What branch the MR with updated configuration should be merged into? (target_branch)
# 1. We need to validate that the new version won't overwrite the old version. 
#    To do that, we checkout latest develop to have the lates info about all versions
# 2. We validate that new version is higher than the old version (if we'll be creating tag on develop) 
#    or different than all the other versions (if we'll be creating tag somewhere else).
# 3. We create a `release/version` branch to have the base for making the MR
# 4. We update the Cocoapods Podspecs on the `release/version` branch
# 5. We update example app so that it uses the new version
# 6. To simplify the release flow, if the release is on develop, we're creating only a single MR. 
#    However, if it's not on develop, on this step we create a MR with updated Cocoapods Podspecs 
#    from `release/branch` to target_branch.
# 7. We add the Cocoapods Podspecs for the new version to "Specs"
# 8. We make an MR with update to "Specs". If the the release is on develop, 
#    this MR will also contain the update of the Cocoapods Podspecs and the example app.
# 9. Use Gitlab API to update CHANGELOG.md





LOG_PREFIX="[create_release_mr_with_new_version.sh]"
RELEASE_BRANCH_PREFIX=release





# 0. Ensure the input parameter (new version number) is provided

USAGE="bash scripts/create_version_update_merge_request.sh [version] [source]->[target_branch]

where 
  * version is in the semantic versioning format: MAJOR.MINOR.PATCH{optional_suffix}
  * source->target_branch is optional parameter specifying 
    - from what source (branch, tag or commit) the release should be created,
    - on which branch the release tag should be set. 
    Defaults to develop->develop"

if [ "$1" == "--help" ]; then
  echo "Usage:"
  echo "$USAGE"
  exit
fi

if [ $# -eq 0 ]; then
  echo "No version number provided. The script should be invoked with:"
  echo "$USAGE"
  exit

elif [ $# -eq 1 ]; then
  NEW_VERSION=$1
  SOURCE_GIT_ENTITY=develop
  TARGET_BRANCH=develop

elif [ $# -ne 2 ]; then
  echo "Too many parameters provided. The script should be invoked with:"
  echo "$USAGE"
  exit

else
  NEW_VERSION=$1
  SOURCE_AND_TARGET=$2
  SOURCE_GIT_ENTITY=$(echo $SOURCE_AND_TARGET | sed "s/->/:/" | tr -s ":" "\n" | head -1)
  TARGET_BRANCH=$(echo $SOURCE_AND_TARGET | sed "s/->/:/" | tr -s ":" "\n" | tail -1)

  if test -z $SOURCE_GIT_ENTITY; then 
    echo "source->target_branch parameter has wrong format. The script should be invoked with:"
    echo "$USAGE"
  fi

  if test -z $TARGET_BRANCH; then 
    echo "source->target_branch parameter has wrong format. The script should be invoked with:"
    echo "$USAGE"
  fi

fi

echo "$LOG_PREFIX Making release $NEW_VERSION from $SOURCE_GIT_ENTITY at $TARGET_BRANCH"





# 1. Switch to latest develop

echo "$LOG_PREFIX $ git fetch origin --tags --force --prune"
git fetch origin --tags --force --prune

echo "$LOG_PREFIX $ git checkout --track develop"
git checkout develop

echo "$LOG_PREFIX $ git pull origin develop --rebase"
git pull origin develop --rebase





# 2. Validate the new version

if [[ $NEW_VERSION =~ ^[[:digit:]]+\.[[:digit:]]+\.[[:digit:]]+.*$ ]]; then
  :
else 
  echo " Wrong format version. It should be: MAJOR.MINOR.PATCH{optional suffix}. Aborting."
  git checkout -
  exit  
fi

if [ $TARGET_BRANCH == "develop" ]; then

  # if it's a new version on develop, it must be higher than the previous version

  CURRENT_VERSION=$(cat pods_configuration.rb | grep "\$version = " | sed "s/\$version = \"//" | sed "s/\"//")

  if [[ $NEW_VERSION = $CURRENT_VERSION ]]; then 
    echo "$LOG_PREFIX The new version should be higher than the current version. Aborting."
    git checkout -
    exit  
  fi

  HIGHER_VERSION=$(echo -e "$CURRENT_VERSION\n$NEW_VERSION" | sort -r -V | head -n 1)

  if [[ $HIGHER_VERSION != $NEW_VERSION ]]; then 
    echo "$LOG_PREFIX The new version should be higher than the current version. Aborting."
    git checkout -
    exit  
  fi

else

  # if it's a new version on some other branch, it must be different than all the existing versions

  VERSIONS=$(ls Specs/ProtonCore-Log | sort -r -V)
  if printf '%s\n' "${VERSIONS[@]}" | grep -F -x -q $NEW_VERSION; then
    echo "$LOG_PREFIX The new version should be different than any already existing version. Aborting."
    git checkout -
    exit
  fi
fi





# 3. Create a release branch from a source branch

echo "$LOG_PREFIX $ git checkout $SOURCE_GIT_ENTITY"
git checkout $SOURCE_GIT_ENTITY
checkout_status=$?
if ! test "$checkout_status" -eq 0
then
    echo >&2 "$LOG_PREFIX $ git checkout $SOURCE_GIT_ENTITY failed with exit status $checkout_status"
    git checkout -
    exit
fi

RELEASE_BRANCH=$RELEASE_BRANCH_PREFIX/$NEW_VERSION

echo "$LOG_PREFIX $ git checkout -b $RELEASE_BRANCH"
git checkout -b $RELEASE_BRANCH





# 4. Update the pods version

cp pods_configuration.rb pods_configuration.tmp

sed -i '' "s/^\$version = \".*\"$/\$version = \"$NEW_VERSION\"/g" pods_configuration.rb

find * -name "*.podspec" -maxdepth 0 -exec sh -c 'mkdir -p Specs/"$(basename {} .podspec)"' \;
find * -name "*.podspec" -maxdepth 0 -exec sh -c 'mkdir -p Specs/"$(basename {} .podspec)/"'$NEW_VERSION \;
find * -name "*.podspec" -maxdepth 0 -exec sh -c 'cp "{}" Specs/"$(basename {} .podspec)/"'$NEW_VERSION \;
find * -name "*.podspec" -maxdepth 0 -exec sh -c 'cp pods_configuration.rb Specs/"$(basename {} .podspec)/"'$NEW_VERSION \;

rm -f pods_configuration.rb

mv pods_configuration.tmp pods_configuration.rb

echo "$LOG_PREFIX $ git add . -A"
git add . -A

echo "$LOG_PREFIX $ git stash"
git stash

echo "$LOG_PREFIX Updating the version in pods_configuration.rb"
sed -i '' "s/^\$version = \".*\"$/\$version = \"$NEW_VERSION\"/g" pods_configuration.rb





# 5. Ensure example app uses the latest pods

echo "$LOG_PREFIX $ bash scripts/update_pods_in_example_projects.sh"
bash scripts/update_pods_in_example_projects.sh





# The next step is to create the Cocoapods specs configuration for the new version
# If the source branch is develop, we will need it on the release branch to have only a single MR with everything
# If source branch is not develop, we will make an MR from release branch to source branch first 
#                                  and then a separate MR with Specs update from a separate branch to develop

if [ $TARGET_BRANCH != "develop" ]; then

# 6. Create an MR from release branch to source branch with the version update and switch back to develop

echo "$LOG_PREFIX $ git add . -A"
git add . -A

echo "$LOG_PREFIX $ git commit -m \"[$NEW_VERSION] Releasing core version $NEW_VERSION\""
git commit -m "[$NEW_VERSION] Releasing core version $NEW_VERSION"

echo "$LOG_PREFIX $ git push origin $RELEASE_BRANCH -o merge_request.create -o merge_request.target=$TARGET_BRANCH -o merge_request.remove_source_branch -o merge_request.assign=\"vjalencas\" -o merge_request.assign=\"crolland\" -o merge_request.assign=\"eackerma\""
git push origin $RELEASE_BRANCH -o merge_request.create -o merge_request.target=$TARGET_BRANCH -o merge_request.remove_source_branch -o merge_request.assign="ksiejkow" -o merge_request.assign="vjalencas" -o merge_request.assign="crolland"  -o merge_request.assign="eackerma"

echo "$LOG_PREFIX $ git checkout develop"
git checkout develop

RELEASE_BRANCH=feature/specs_for_$NEW_VERSION

echo "$LOG_PREFIX $ git checkout -b $RELEASE_BRANCH"
git checkout -b $RELEASE_BRANCH

fi





# 7. Create podspecs with new version in Specs directory

echo "$LOG_PREFIX $ git stash pop"
git stash pop





# 8. Create a merge request with updated Specs. If source branch is develop, it will contain also the updated example app and pods configuration

echo "$LOG_PREFIX $ git add . -A"
git add . -A

if [ $TARGET_BRANCH == "develop" ]; then
  echo "$LOG_PREFIX $ git commit -m \"[$NEW_VERSION] Releasing core version $NEW_VERSION\""
  git commit -m "[$NEW_VERSION] Releasing core version $NEW_VERSION"
else
  echo "$LOG_PREFIX $ git commit -m \"Updating specs for new release version $NEW_VERSION\""
  git commit -m "Updating specs for new release version $NEW_VERSION"
fi

echo "$LOG_PREFIX $ git push origin $RELEASE_BRANCH -o merge_request.create -o merge_request.target=develop -o merge_request.remove_source_branch -o merge_request.assign=\"ksiejkow\" -o merge_request.assign=\"vjalencas\" -o merge_request.assign=\"crolland\" -o merge_request.assign=\"eackerma\""
git push origin $RELEASE_BRANCH -o merge_request.create -o merge_request.target=develop -o merge_request.remove_source_branch -o merge_request.assign="ksiejkow" -o merge_request.assign="vjalencas" -o merge_request.assign="crolland" -o merge_request.assign="eackerma"




# 9. Use Gitlab API to update CHANGELOG.md

bash -x scripts/create_changelog_on_gitlab.sh $NEW_VERSION $RELEASE_BRANCH
