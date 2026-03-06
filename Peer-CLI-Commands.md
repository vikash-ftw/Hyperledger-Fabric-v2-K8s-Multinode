### Channel Commands
- To create channel block file
```bash
# Only one peer
./scripts/createAppChannel.sh
```
- Join peer to the channel
```bash
# Each peer
peer channel list
peer channel join -b /channel-artifacts/samplechannel.block
``` 
- Update Anchor peer in channel
```bash
# Only one peer
./scripts/updateAnchorPeer.sh
```

### Chaincode Package command
- On NFS: go to packaging directory of respective chaincode Go or Node at `my-chaincodes` directory to run below commands
```bash
# create tar of connection.json and META-INF (for indexing) in code.tar.gz
tar -czf code.tar.gz connection.json META-INF
```
```bash
# create final tar with metadata.json and code.tar.gz

# for Go
tar -czf smartcontract-go.tgz code.tar.gz metadata.json

# for Node
tar -czf smartcontract-node.tgz code.tar.gz metadata.json
```
- Copy this final smartcontract tar to the `chaincode/packaging` dir on NFS
- Chaincode will only be available inside peer cli for the next *Chaincode Installation Stage* after it is copied to the above-specified directory.

### Chaincode Lifecycle Stage Process
- **_Package_**: Already done at via creating tar.
- **_Install_**: Installing chaincode on each peer and copy the *PackageID* for further use.
```bash
# Each peer
peer lifecycle chaincode queryinstalled

# For Go chaincode
peer lifecycle chaincode install ./builders/external/chaincode/packaging/smartcontract-go.tgz

# For Node chaincode
peer lifecycle chaincode install ./builders/external/chaincode/packaging/smartcontract-node.tgz
```

> :memo: **Note:** We need to use this generated PackageID in our Chaincode Deployment yaml file. Edit the respective go or node deployment yaml file and replace the placeholder value for `CHAINCODE_ID`. After change `kubectl apply` yaml files of chaincode to run the chaincode externally as Pod.

- **_Approve_**:
```bash
# Only one peer

# For Go Chaincode 
peer lifecycle chaincode approveformyorg --channelID samplechannel --name smartcontract-go --version 1.0 --package-id <Copied-PkgID> --sequence 1 -o orderer:7050 --tls --cafile $ORDERER_CA

# For Node Chaincode
peer lifecycle chaincode approveformyorg --channelID samplechannel --name smartcontract-node --version 1.0 --package-id <Copied-PkgID> --sequence 1 -o orderer:7050 --tls --cafile $ORDERER_CA
```

- **_Commit_**:
```bash
# Only one peer

# --- For Go Chaincode ---
peer lifecycle chaincode checkcommitreadiness --channelID samplechannel --name smartcontract-go --version 1.0 --sequence 1 -o orderer:7050 --tls --cafile $ORDERER_CA

peer lifecycle chaincode commit -o orderer:7050 --channelID samplechannel --name smartcontract-go --version 1.0 --sequence 1 --tls true --cafile $ORDERER_CA --peerAddresses peer0-org1:7051 --tlsRootCertFiles /organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt --peerAddresses peer1-org1:7051 --tlsRootCertFiles /organizations/peerOrganizations/org1.example.com/peers/peer1.org1.example.com/tls/ca.crt --peerAddresses peer2-org1:7051 --tlsRootCertFiles /organizations/peerOrganizations/org1.example.com/peers/peer2.org1.example.com/tls/ca.crt --peerAddresses peer3-org1:7051 --tlsRootCertFiles /organizations/peerOrganizations/org1.example.com/peers/peer3.org1.example.com/tls/ca.crt

# --- For Node Chaincode ---

peer lifecycle chaincode checkcommitreadiness --channelID samplechannel --name smartcontract-node --version 1.0 --sequence 1 -o orderer:7050 --tls --cafile $ORDERER_CA

peer lifecycle chaincode commit -o orderer:7050 --channelID samplechannel --name smartcontract-node --version 1.0 --sequence 1 --tls true --cafile $ORDERER_CA --peerAddresses peer0-org1:7051 --tlsRootCertFiles /organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt --peerAddresses peer1-org1:7051 --tlsRootCertFiles /organizations/peerOrganizations/org1.example.com/peers/peer1.org1.example.com/tls/ca.crt --peerAddresses peer2-org1:7051 --tlsRootCertFiles /organizations/peerOrganizations/org1.example.com/peers/peer2.org1.example.com/tls/ca.crt --peerAddresses peer3-org1:7051 --tlsRootCertFiles /organizations/peerOrganizations/org1.example.com/peers/peer3.org1.example.com/tls/ca.crt

```

- **_Invoke_**: *Optional Step* to check if Chaincode working fine
```bash
# Only one peer

# For Go Chaincode
peer chaincode invoke -o orderer:7050 --tls true --cafile $ORDERER_CA -C samplechannel -n smartcontract-go --peerAddresses peer0-org1:7051 --tlsRootCertFiles /organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt --peerAddresses peer1-org1:7051 --tlsRootCertFiles /organizations/peerOrganizations/org1.example.com/peers/peer1.org1.example.com/tls/ca.crt --peerAddresses peer2-org1:7051 --tlsRootCertFiles /organizations/peerOrganizations/org1.example.com/peers/peer2.org1.example.com/tls/ca.crt --peerAddresses peer3-org1:7051 --tlsRootCertFiles /organizations/peerOrganizations/org1.example.com/peers/peer3.org1.example.com/tls/ca.crt -c '{"Args":["InitLedger"]}' --waitForEvent

# For Node Chaincode
peer chaincode invoke -o orderer:7050 --tls true --cafile $ORDERER_CA -C samplechannel -n smartcontract-node --peerAddresses peer0-org1:7051 --tlsRootCertFiles /organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt --peerAddresses peer1-org1:7051 --tlsRootCertFiles /organizations/peerOrganizations/org1.example.com/peers/peer1.org1.example.com/tls/ca.crt --peerAddresses peer2-org1:7051 --tlsRootCertFiles /organizations/peerOrganizations/org1.example.com/peers/peer2.org1.example.com/tls/ca.crt --peerAddresses peer3-org1:7051 --tlsRootCertFiles /organizations/peerOrganizations/org1.example.com/peers/peer3.org1.example.com/tls/ca.crt -c '{"Args":["InitLedger"]}' --waitForEvent

```

