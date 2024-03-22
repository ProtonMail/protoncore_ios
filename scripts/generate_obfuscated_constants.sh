#!/bin/bash -x

THIS_DIR=$(pwd)

if [[ ! -f "$THIS_DIR/libraries/ObfuscatedConstants/Scripts/create_obfuscated_constants.sh" ]]; then 
    cd ..
    THIS_DIR=$(pwd)    
fi

cd $THIS_DIR/libraries/ObfuscatedConstants/Scripts
echo "$(pwd)/create_obfuscated_constants.sh"
bash create_obfuscated_constants.sh
cd $THIS_DIR
