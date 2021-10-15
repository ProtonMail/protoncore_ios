#!/bin/bash -x

if [ "$1" = "--regression" ]; then 
    TESTPLAN="Example-UITests-regression"
    PARALLEL_TESTING_ENABLED="NO"
    PARALLEL_TESTING_WORKER_COUNT="1"
elif [ "$1" = "--smoke" ]; then 
    TESTPLAN="Example-UITests-smoke"
    PARALLEL_TESTING_ENABLED="YES"
    PARALLEL_TESTING_WORKER_COUNT="4"
else
    echo "You need to pass either --smoke or --regression flag"
    exit 1
fi

DERIVED_DATA_PATH=~/ProtonCore/UITests/$CI_PIPELINE_IID/DerivedData/
DESTINATION="platform=iOS Simulator,name=iPhone 11,OS=15.0"

defaults write com.apple.iphonesimulator ConnectHardwareKeyboard 0 # Fixing UI tests failing on secure field
mkdir -p "$DERIVED_DATA_PATH"
echo "$DERIVED_DATA_PATH"
echo "DYNAMIC_DOMAIN=$DYNAMIC_DOMAIN"
# bash scripts/generate_obfuscated_constants.sh --only-apps
echo "xcodebuild -workspace \"example-app/ExampleApp.xcworkspace\" -scheme \"Example-UITests\" -testPlan $TESTPLAN -destination $DESTINATION -resultBundlePath "UITestsResults" -derivedDataPath $DERIVED_DATA_PATH -parallel-testing-enabled $PARALLEL_TESTING_ENABLED -parallel-testing-worker-count $PARALLEL_TESTING_WORKER_COUNT -quiet test DYNAMIC_DOMAIN=$DYNAMIC_DOMAIN"

xcodebuild -workspace "example-app/ExampleApp.xcworkspace" -scheme "Example-UITests" -testPlan "$TESTPLAN" -destination "$DESTINATION" -resultBundlePath "UITestsResults" -derivedDataPath "$DERIVED_DATA_PATH" -parallel-testing-enabled "$PARALLEL_TESTING_ENABLED" -parallel-testing-worker-count "$PARALLEL_TESTING_WORKER_COUNT" -quiet test DYNAMIC_DOMAIN="$DYNAMIC_DOMAIN"