/*
SPDX-License-Identifier: Apache-2.0
*/

package main

import (
	"log"

	"github.com/hyperledger/fabric-chaincode-go/v2/shim"
	"github.com/hyperledger/fabric-contract-api-go/v2/contractapi"
	"contract-go/chaincode"
)

func main() {
	// create chaincode config from ENV variables
	config := serverConfig{
		CCID:    os.Getenv("CHAINCODE_ID"),
		Address: os.Getenv("CHAINCODE_SERVER_ADDRESS"),
	}

	fmt.Println("[Main] Starting chaincode server...")
	fmt.Printf("[Main] CHAINCODE_ID: %s, CHAINCODE_SERVER_ADDRESS: %s\n", config.CCID, config.Address)

	chaincode, err := contractapi.NewChaincode(&chaincode.SmartContract{})
	if err != nil {
		log.Panicf("Error creating ProductSmartContract chaincode: %v", err)
	}

	server := &shim.ChaincodeServer{
		CCID:    config.CCID,
		Address: config.Address,
		CC:      chaincode,
		TLSProps: shim.TLSProperties{
			Disabled: true,
		},	
	}

	if err := server.Start(); err != nil {
		log.Panicf("Error starting ProductSmartContract chaincode: %v", err)
	}
}