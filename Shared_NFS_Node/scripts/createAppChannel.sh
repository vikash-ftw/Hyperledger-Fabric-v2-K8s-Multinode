# create channel block file
# pass channel name via arg -> createChannel.sh <channel name>

CHANNEL_NAME="$1"
: ${CHANNEL_NAME:="samplechannel"}

MAX_RETRY="3"
VERBOSE="false"

peer channel create -o orderer:7050 -c $CHANNEL_NAME -f ./channel-artifacts/${CHANNEL_NAME}.tx --outputBlock ./channel-artifacts/${CHANNEL_NAME}.block --tls --cafile /organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem