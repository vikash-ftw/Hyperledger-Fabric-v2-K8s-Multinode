#!/bin/bash

CHAINCODE_TYPE="${1:-node}"    # default = node

set -e

# -------- CONFIG --------
TARGET_DIR="/chaincode/packaging"

if [ "$CHAINCODE_TYPE" = "node" ]; then
  CHAINCODE_PKG_SRC_DIR="/my-chaincodes/contract-node/packaging"
  PACKAGE_NAME="smartcontract-node.tgz"
elif [ "$CHAINCODE_TYPE" = "go" ]; then
  CHAINCODE_PKG_SRC_DIR="/my-chaincodes/contract-go/packaging"
  PACKAGE_NAME="smartcontract-go.tgz"
else
  echo "Invalid chaincode type. use 'node' or 'go'."
  exit 1
fi

echo "Starting chaincode packaging..."

# -------- STEP 1: Ensure target packaging directory exists --------
if [ ! -d "$TARGET_DIR" ]; then
    echo "Creating directory: $TARGET_DIR"
    mkdir -p "$TARGET_DIR"
fi

# -------- STEP 2: Go to source packaging directory --------
cd "$CCHAINCODE_PKG_SRC_DIR"

echo "Current directory: $(pwd)"

# -------- STEP 3: Create code.tar.gz --------
echo "Creating code.tar.gz..."
tar -czf /tmp/code.tar.gz connection.json META-INF

# -------- STEP 4: Create final chaincode package --------
cp metadata.json /tmp/

echo "$(ls /tmp)"

cd /tmp
echo "Creating $PACKAGE_NAME..."
tar -czf "$PACKAGE_NAME" code.tar.gz metadata.json
echo "$(ls /tmp)"

# -------- STEP 5: Copy final package --------
echo "Copying package to $TARGET_DIR..."
cp /tmp/"$PACKAGE_NAME" "$TARGET_DIR"

echo "Packaging completed successfully!"
echo "Chaincode Package available at: $TARGET_DIR/$PACKAGE_NAME"