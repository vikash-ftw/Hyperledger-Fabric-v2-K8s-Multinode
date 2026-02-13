export FABRIC_CFG_PATH=${PWD}/configtx

echo "------------------------------------------"
echo "---- Generating Orderer Genesis Block ----"
echo "------------------------------------------"

configtxgen -profile OrgOrdererGenesis -channelID system-channel -outputBlock ./system-genesis-block/genesis.block