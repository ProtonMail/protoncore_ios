#!/bin/bash -x

cd example-app/example-app-v4
echo -e "\n\n🐶 Updating example-app-v4"

pod install --clean-install 

echo -e "\n\n\n🦁 Finished updating pods in the example app v4"

cd ../example-app-v5
echo -e "\n\n🐹 Updating example-app-v5"

pod install --clean-install 

echo -e "\n\n\n🦊 Finished updating pods in the example app v5"

cd ../example-app-v5-ios14macos11
echo -e "\n\n🐻 Updating example-app-v5-ios14macos11"

pod install --clean-install 

echo -e "\n\n\n🐻‍❄️ Finished updating pods in the example app v5 ios14 macos11"


