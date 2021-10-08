#!/bin/bash

if [ -n "$SRCROOT" ]; then PREFIX=${SRCROOT%/*}; else PREFIX=../..; fi
CONSTANTS_DIR=$PREFIX/../../pmconstants
SCRIPT_FILE=$CONSTANTS_DIR/prepare_obfuscated_constants.sh
MODULE="ProtonCore-Login-Tests"
BASE_FILE_NAME=$(dirname $0)/ObfuscatedConstants.base.swift
DEST_DIR=$(dirname $0)/../Tests
DEST_FILE_NAME=$DEST_DIR/ObfuscatedConstants.swift

pwd
mkdir -p $DEST_DIR

if [[ -f "$SCRIPT_FILE" ]]; then echo "$SCRIPT_FILE was found. Creating a file with real values"; else
    echo "warning: pmconstants file $SCRIPT_FILE not found. Creating a file with dummy values"
    cp $BASE_FILE_NAME $DEST_FILE_NAME
    exit
fi

bash $SCRIPT_FILE $MODULE $BASE_FILE_NAME $DEST_FILE_NAME