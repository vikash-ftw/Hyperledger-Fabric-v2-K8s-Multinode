#!/bin/bash

set -e

# -------- CONFIG --------
CHAINCODE_SRC_DIR="./my-chaincodes/contract-node/packaging"
# CHAINCODE_SRC_DIR="./my-chaincodes/contract-go/packaging"

TARGET_DIR="./chaincode/packaging"

PACKAGE_NAME="smartcontract-node.tgz"
# PACKAGE_NAME="smartcontract-go.tgz"

echo "Starting chaincode packaging..."

# -------- STEP 1: Ensure target packaging directory exists --------
if [ ! -d "$TARGET_DIR" ]; then
    echo "Creating directory: $TARGET_DIR"
    mkdir -p "$TARGET_DIR"
fi

# -------- STEP 2: Go to source packaging directory --------
cd "$CHAINCODE_SRC_DIR"

echo "Current directory: $(pwd)"

# -------- STEP 3: Create code.tar.gz --------
echo "Creating code.tar.gz..."
tar -czf code.tar.gz connection.json META-INF

# -------- STEP 4: Create final chaincode package --------
echo "Creating $PACKAGE_NAME..."
tar -czf "$PACKAGE_NAME" code.tar.gz metadata.json

# -------- STEP 5: Remove temporary file --------
echo "Cleaning temporary files..."
rm -f code.tar.gz

# -------- STEP 6: Copy final package --------
echo "Copying package to $TARGET_DIR..."
cp "$PACKAGE_NAME" ../../../chaincode/packaging/

echo "Packaging completed successfully!"
echo "Chaincode Package available at: $TARGET_DIR/$PACKAGE_NAME"