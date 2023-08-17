#!/bin/zsh -x

if [ $# -eq 0 ]; then
  echo "No branch name provided"
  exit
elif [ $# -ne 1 ]; then
  echo "Too many parameters provided"
  exit
fi

RELEASE_BRANCH=$1

git fetch origin --tags --force --prune
git checkout --track origin/$RELEASE_BRANCH
git pull --force origin $RELEASE_BRANCH

echo "$GITHUB_DEPLOY_PRIVATE_KEY" | tr -d '\r' | ssh-add - > /dev/null

git remote add github git@github.com:ProtonMail/protoncore_ios.git
git push github $RELEASE_BRANCH

# We want to sync only tags that are added after history split. So commit for every existing tag is checked. And if the commit for the tag is in $RELEASE_BRANCH then 
# tag is pushed to the remote. 
#
# Now this is reasonably fast. It may happen that there will be so many tags in future that this will be slow. It will happen in a future and at that point probably 
# all the old (pre split) tags can be deleted and this logic can be deleted also. And then all the tags will be simply pushed.
tags=`git tag -l`
local IFS=$'\n'
setopt sh_word_split
for tag in $tags; do
    gitHash=`git rev-list -n 1 "${tag}"`
    contains=`git branch "${RELEASE_BRANCH}" --contains "${gitHash}"`
    if [[ ! -z "${contains}" ]]; then
        git push github "$tag"
    fi
done

