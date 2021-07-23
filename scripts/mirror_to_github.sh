#!/bin/bash -x

if [[ $1 == "main" ]]; then
  CURRENT_VERSION=$(cat pods_configuration.rb | grep "\$version = " | sed "s/\$version = \"//" | sed "s/\"//")
  ssh-agent bash -c "ssh-add - <<< \"$GITHUB_DEPLOY_PRIVATE_KEY\"; git remote add github git@github.com:ProtonMail/protoncore_ios.git; git remote -v; git push github main; git push github $CURRENT_VERSION"
  exit
fi

if [[ $1 == "develop" ]]; then
  ssh-agent bash -c "ssh-add - <<< \"$GITHUB_DEPLOY_PRIVATE_KEY\"; git remote add github git@github.com:ProtonMail/protoncore_ios.git; git remote -v; git push github develop"
  exit
fi

echo "You must specify that either develop or main should be mirrored"
