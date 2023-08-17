#!/bin/bash -x

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

git pull origin $RELEASE_BRANCH --rebase

CURRENT_VERSION=$(cat pods_configuration.rb | grep "\$version = " | sed "s/\$version = \"//" | sed "s/\"//")

ssh-agent bash -c "ssh-add - <<< \"$GITHUB_DEPLOY_PRIVATE_KEY\"; git remote add github git@github.com:ProtonMail/protoncore_ios.git; git remote -v; git fetch github --tags --force --prune; git push github $RELEASE_BRANCH; git push github $CURRENT_VERSION"
