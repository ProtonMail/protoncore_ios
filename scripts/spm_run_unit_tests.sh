#!/bin/bash -x

SKIP_BUILD_FLAG=""

if [ "$1" = "--no-clean" ]; then 
	echo "Using existing build cache from .build/ if available"
elif [ "$1" = "--skip-build" ]; then 
	echo "Skipping build completely with --skip-build flag"
	SKIP_BUILD_FLAG="--skip-build"
else
	echo "Cleaning build cache with \"rm -rf .build/\""
    rm -rf .build/
fi

swift package plugin --allow-writing-to-package-directory generate-obfuscated-constants

swift test $SKIP_BUILD_FLAG -Xswiftc -DDEBUG_CORE_INTERNALS \
	--skip "ProtonCoreCrypto_Go_Tests" \
	--skip "ProtonCoreCrypto_VPN_patched_Tests" \
	--skip "ProtonCoreCrypto_Search_Go_Tests" \
	--skip "ProtonCoreCryptoGoImplementation_Tests" \
	--skip "ProtonCoreCryptoVPNPatchedGoImplementation_Tests" \
	--skip "ProtonCoreCryptoSearchGoImplementation_Tests" \
| xcpretty
