#!/bin/bash

cd apps/CoreExample
echo -e "\n\n🐶 Updating CoreExample"
pod install --clean-install 
cd ../example-login
echo -e "\n\n\n🐭 Updating example-login"
pod install --clean-install 
cd ../example-accountswitcher
echo -e "\n\n\n🐹 Updating example-accountswitcher"
pod install --clean-install 
cd ../example-networking
echo -e "\n\n\n🐻 Updating example-networking"
pod install --clean-install 
cd ../example-uifoundations
echo -e "\n\n\n🐼 Updating example-uifoundations"
pod install --clean-install 
cd ../example-payments
echo -e "\n\n\n🐷 Updating example-payments"
pod install --clean-install 
cd ../example-features
echo -e "\n\n\n🐸 Updating example-features"
pod install --clean-install 

echo -e "\n\n\n🦁 Finished updating pods in the example apps"

