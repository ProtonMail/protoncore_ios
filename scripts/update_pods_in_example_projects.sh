#!/bin/bash -x


cd example-app/example-app
echo -e "\n\n🐹 Updating example-app"

pod install --clean-install 

echo -e "\n\n\n🦊 Finished updating pods in the example app"

cd ../example-app-ios14macos11
echo -e "\n\n🐻 Updating example-app-v5-ios14macos11"

pod install --clean-install 

echo -e "\n\n\n🐻‍❄️ Finished updating pods in the example app v5 ios14 macos11"


