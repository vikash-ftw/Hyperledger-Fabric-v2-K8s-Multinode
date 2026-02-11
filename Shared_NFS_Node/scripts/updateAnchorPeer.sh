# update Anchor peer for channel
# pass OrgMsp & channel name via arg -> createChannel.sh <OrgMsp> <channel name>

CORE_PEER_LOCALMSPID="$1"
: ${CORE_PEER_LOCALMSPID:="Org1MSP"}
CHANNEL_NAME="$2"
: ${CHANNEL_NAME:="samplechannel"}

#echo $CORE_PEER_LOCALMSPID $CHANNEL_NAME
peer channel update -o orderer:7050  -c ${CHANNEL_NAME} -f ./channel-artifacts/${CORE_PEER_LOCALMSPID}_${CHANNEL_NAME}_anchors.tx --tls --cafile $ORDERER_CA