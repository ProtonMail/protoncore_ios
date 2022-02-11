#!/bin/bash -x

if [ "$1" = "--regression" ]; then 
    TESTPLAN="Example-UITests-regression-V4"
    PARALLEL_TESTING_ENABLED="NO"
    PARALLEL_TESTING_WORKER_COUNT="1"
elif [ "$1" = "--smoke" ]; then 
    TESTPLAN="Example-UITests-smoke-V4"
    PARALLEL_TESTING_ENABLED="YES"
    PARALLEL_TESTING_WORKER_COUNT="4"
else
    echo "You need to pass either --smoke or --regression flag"
    exit 1
fi

DERIVED_DATA_PATH=~/ProtonCore/UITests/$CI_PIPELINE_IID/DerivedData/
DESTINATION="platform=iOS Simulator,name=iPhone 11,OS=15.2"
UI_TESTS_RESULTS="UITestsResults-$CI_PIPELINE_IID"

defaults write com.apple.iphonesimulator ConnectHardwareKeyboard 0 # Fixing UI tests failing on secure field
mkdir -p "$DERIVED_DATA_PATH"
echo "$DERIVED_DATA_PATH"
echo "DYNAMIC_DOMAIN=$DYNAMIC_DOMAIN"
bash scripts/generate_obfuscated_constants.sh
echo "xcodebuild -workspace \"example-app/example-app-v4/ExampleApp-V4.xcworkspace\" -scheme \"Example-UITests-V4\" -testPlan $TESTPLAN -destination $DESTINATION -resultBundlePath $UI_TESTS_RESULTS -derivedDataPath $DERIVED_DATA_PATH -parallel-testing-enabled $PARALLEL_TESTING_ENABLED -parallel-testing-worker-count $PARALLEL_TESTING_WORKER_COUNT -quiet test DYNAMIC_DOMAIN=$DYNAMIC_DOMAIN"

xcodebuild -workspace "example-app/example-app-v4/ExampleApp-V4.xcworkspace" -scheme "Example-UITests-V4" -testPlan "$TESTPLAN" -destination "$DESTINATION" -resultBundlePath "$UI_TESTS_RESULTS" -derivedDataPath "$DERIVED_DATA_PATH" -parallel-testing-enabled "$PARALLEL_TESTING_ENABLED" -parallel-testing-worker-count "$PARALLEL_TESTING_WORKER_COUNT" -quiet test DYNAMIC_DOMAIN="$DYNAMIC_DOMAIN"
tests_running_status=$?

# A (hopefully) temporary measure to work around xcresult bundle size explosion in Xcode 13.2
# See https://developer.apple.com/forums/thread/698054 for more details
xchtmlreport -r UITestsResults-${CI_PIPELINE_IID}.xcresult -i
rm -rf UITestsResults-${CI_PIPELINE_IID}.xcresult
mv index.html UITestsResults-${CI_PIPELINE_IID}.html

exit $tests_running_status