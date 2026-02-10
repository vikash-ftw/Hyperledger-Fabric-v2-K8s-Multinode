#!/bin/bash

# create channel
# pass channel via arg -> createChannel.sh <channel name>

CHANNEL_NAME="$1"
: ${CHANNEL_NAME:="samplechannel"}

MAX_RETRY="3"
VERBOSE="false"

export FABRIC_CFG_PATH=${PWD}/configtx

verifyResult() {
  if [ $1 -eq 0 ]; then
    echo "SUCCESS: $2"
  else
    echo "ERROR: $3"
    exit 1
  fi
  echo
}

createChannelTxn() {
    set -x
	configtxgen -profile OrgChannel -outputCreateChannelTx ./channel-artifacts/${CHANNEL_NAME}.tx -channelID $CHANNEL_NAME
	res=$?
	set +x
	verifyResult $res "txn file generated for $CHANNEL_NAME" "Failed to generate $CHANNEL_NAME txn file!"
}

createAnchorPeerTxn() {
	echo "--- Creating org anchor peer txn for ${CHANNEL_NAME} ---"
	#for orgmsp in Org1MSP Org2MSP Org3MSP; do
    for orgmsp in Org1MSP; do
		echo "--- Generating anchor peer update transaction for ${orgmsp} ---"
		set -x
		configtxgen -profile OrgChannel -outputAnchorPeersUpdate ./channel-artifacts/${orgmsp}_${CHANNEL_NAME}_anchors.tx -channelID $CHANNEL_NAME -asOrg ${orgmsp}
		res=$?
		set +x
		verifyResult $res "anchorTxn file generated for ${orgmsp} Anchor peer" "Failed to generate anchorTxn file for ${orgmsp} Anchor peer!"
	done
}

## Create channeltx
echo "Generating channel create transaction '${CHANNEL_NAME}.tx'"
createChannelTxn

## Create anchorpeertx
echo "Generating anchor peer update transactions"
createAnchorPeerTxn

exit 0