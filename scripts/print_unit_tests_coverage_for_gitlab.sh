#!/bin/bash

RESULTS=$(xcrun xccov view --report fastlane/test_output/Example-UnitTests-V5.xcresult)

FRAMEWORKS=("APIClient" "AccountDeletion" "AccountSwitcher" "Authentication" "Authentication_KeyGeneration" "Challenge" "Common" "CoreTranslation" "Crypto" "DataModel" "Doh" "Features" "ForceUpgrade" "Foundations" "Hash" "HumanVerification" "KeyManager" "Keymaker" "Log" "Login" "LoginUI" "Networking" "ObfuscatedConstants" "Payments" "PaymentsUI" "TroubleShooting"  "Services" "Settings" "TestingToolkit" "UIFoundations" "Utilities")

TOTAL_COVERED=0
TOTAL_ALL=0

echo "Coverage report:"

for FRAMEWORK in "${FRAMEWORKS[@]}"
do
	VALUES=($(echo "$RESULTS" | grep "ProtonCore_$FRAMEWORK.framework" | head -1 | perl -pe 's/.+?(\d+\.\d+%)\s\((\d+)\/(\d+)\).*/\1 \2 \3/'))
	TOTAL_COVERED=$(( $TOTAL_COVERED + ${VALUES[1]} ))
	TOTAL_ALL=$(( $TOTAL_ALL + ${VALUES[2]} ))
	echo "	$FRAMEWORK: ${VALUES[0]} (${VALUES[1]} out of ${VALUES[2]} lines covered)"
done

PERCENTAGE=$(( 10000*$TOTAL_COVERED / $TOTAL_ALL ))
echo "$TOTAL_COVERED out of $TOTAL_ALL total number of lines covered"
echo "$PERCENTAGE" | perl -pe 's/(\d+)(\d\d)/Total coverage value: \1.\2%/'