#!/bin/bash

SOURCES_DIR=$(dirname $0)/../Sources
echo "SOURCES_DIR" $SOURCES_DIR

PREFIX=$SOURCES_DIR

arr=( "$PREFIX/../../../../../pmconstants" "$PREFIX/../../../../pmconstants" "$PREFIX/../../../pmconstants" "$PREFIX/../../pmconstants" "$PREFIX/../pmconstants" "$PREFIX/pmconstants")
for item in "${arr[@]}"
do
    echo "Looking for directory" $item
    if [ -d "$item" ];
    then
        echo "$item directory found."
        CONSTANTS_DIR="$item"
        break
    fi
done


echo "CONSTANTS_DIR" $CONSTANTS_DIR

DATA_FILE=$CONSTANTS_DIR/ObfuscatedConstants.swift
MODULE="ProtonCore-ObfuscatedConstants"

BASE_FILE_NAME=$SOURCES_DIR/Template/ObfuscatedConstants.base.swift
DEST_FILE_NAME=$SOURCES_DIR/ObfuscatedConstants.swift

pwd
mkdir -p $DEST_DIR
rm -f DEST_FILE_NAME

if [[ -f "$DATA_FILE" ]]; then 
    echo "$DATA_FILE was found. Creating a file with real values at $DEST_FILE_NAME"
    cp $DATA_FILE $DEST_FILE_NAME
else
    echo "warning: $DATA_FILE not found. Creating a file with empty values at $DEST_FILE_NAME"
    cp $BASE_FILE_NAME $DEST_FILE_NAME
    exit
fi
