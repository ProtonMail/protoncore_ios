#!/bin/bash -x

THIS_DIR=$(pwd)

if [[ ! -f "$THIS_DIR/libraries/Login/Scripts/prepare_obfuscated_constants.sh" ]]; then 
    cd ..
    THIS_DIR=$(pwd)    
fi

TESTS="true"
APPS="true"

if [ "$1" = "--only-apps" ]; then 
    TESTS="false"
fi

if [ "$1" = "--only-tests" ]; then 
    APPS="false"
fi

if [ "$TESTS" = "true" ]; then

    cd $THIS_DIR/libraries/Authentication-KeyGeneration/Scripts/
    echo "$(pwd)/prepare_obfuscated_constants.sh"
    bash prepare_obfuscated_constants.sh

    cd $THIS_DIR/libraries/Login/Scripts/
    echo "$(pwd)/prepare_obfuscated_constants.sh"
    bash prepare_obfuscated_constants.sh

fi

if [ "$APPS" = "true" ]; then 

    cd $THIS_DIR/example-app/Scripts/
    echo "$(pwd)/prepare_obfuscated_constants.sh"
    bash prepare_obfuscated_constants.sh

fi
