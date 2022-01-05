#!/bin/bash

# Conceptually, the release process is composed of two parts:
# A. Updating Cocoapods Podspecs and example app to the new version
# B. Copying the Cocoapods Podspecs for the new version to "Specs"
# C. Making a release tag on a commit with the new version of core
#
# Third point is performed in this script. 
# First two points are performed in create_release_mr_with_new_version.sh. 




SOURCE_BRANCH=$CI_COMMIT_BRANCH




bash scripts/make_release_tags.sh $SOURCE_BRANCH

bash scripts/generate_and_publish_release_notes.sh $SOURCE_BRANCH

bash scripts/mirror_to_github.sh $SOURCE_BRANCH

