#!/bin/bash 

USAGE="
\$ bash scripts/pull_github_pr.sh [pr_number] [origin_branch_name]

where:
* pr_number is a number of PR on Github. You can see it at the end of the PR address, like https://github.com/ProtonMail/protoncore_ios/pull/1)
* origin_branch_name is the name of the branch on origin. It will be prefixed with \"github_pr/\" to indicate it came from Github"

if [ $# -eq 0 ]; then
  echo "Neither PR number nor origin branch name provided! The right usage:"
  echo "$USAGE"
  exit
elif [ $# -eq 1 ]; then
  echo "No origin branch name provided! The right usage:"
  echo "$USAGE"
  exit
elif [ $# -ne 2 ]; then
  echo "Too many parameters provided. The right usage:"
  echo "$USAGE"
  exit
fi

PULL_NUMBER=$1
BRANCH_NAME=$2

GITHUB_PR="pull/$PULL_NUMBER/head"
ORIGIN_BRANCH="github_pr/$PULL_NUMBER/$BRANCH_NAME"

echo "Executing: \$ git fetch origin --tags --force --prune"
git fetch origin --tags --force --prune

echo "Executing: \$ git remote add github git@github.com:ProtonMail/protoncore_ios.git"
git remote add github git@github.com:ProtonMail/protoncore_ios.git

echo "Executing: \$ git fetch github $GITHUB_PR:$ORIGIN_BRANCH"
git fetch github $GITHUB_PR:$ORIGIN_BRANCH

echo "Executing: \$ git log $ORIGIN_BRANCH -1 --pretty=\"[Github] PR #$PULL_NUMBER by %an: %s (see https://github.com/ProtonMail/protoncore_ios/pull/$PULL_NUMBER)\""
TITLE=$(git log $ORIGIN_BRANCH -1 --pretty="[Github] PR #$PULL_NUMBER by %an: '%s' (see https://github.com/ProtonMail/protoncore_ios/pull/$PULL_NUMBER)")

echo "Executing: \$ git push origin $ORIGIN_BRANCH -o merge_request.create -o merge_request.target=develop -o merge_request.title=\"$TITLE\" -o merge_request.remove_source_branch -o merge_request.assign=\"yzhang\" -o merge_request.assign=\"siejkowski\" -o merge_request.assign=\"gbiegaj\""
git push origin $ORIGIN_BRANCH -o merge_request.create -o merge_request.target=develop -o merge_request.title="$TITLE" -o merge_request.remove_source_branch -o merge_request.assign="yzhang" -o merge_request.assign="siejkowski" -o merge_request.assign="gbiegaj"

echo "Executing: \$ git remote remove github"
git remote remove github
