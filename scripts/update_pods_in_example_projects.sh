#!/bin/bash -x

cd example-app
echo -e "\n\n🐶 Updating example-app"

pod install --clean-install 

echo -e "\n\n\n🦁 Finished updating pods in the example app"

