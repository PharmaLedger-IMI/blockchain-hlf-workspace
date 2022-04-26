#!/bin/bash

source setEnv.sh

rm -rf ./cc-anchor
rm -rf ./build
mkdir cc-anchor
mkdir build
cp ./hf-adapter/network/chaincode/anchor/* cc-anchor
tar -C cc-anchor/ -zcf cc-anchor/code.tar.gz connection.json
tar -C cc-anchor/ -zcf build/anchoring.tar.gz code.tar.gz metadata.json

cd ..
mv anchoring.tar.gz build
cd build

#peer lifecycle chaincode package anchoring.tar.gz --path build  --lang node --label anchoring_1.0

peer lifecycle chaincode install anchoring.tar.gz

sleep 2

peer lifecycle chaincode queryinstalled

sleep 2

export CC_PACKAGE_ID=`peer lifecycle chaincode queryinstalled | grep ID | cut -d' ' -f 3 | cut -d',' -f 1`

echo $CC_PACKAGE_ID

peer lifecycle chaincode approveformyorg -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --channelID anchoring --name anchoring --version 1.0 --package-id $CC_PACKAGE_ID --sequence 1 --tls --cafile ${PWD}/fabric-samples/test-network/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

export CORE_PEER_LOCALMSPID="Org2MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/fabric-samples/test-network/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/fabric-samples/test-network/organizations/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
export CORE_PEER_ADDRESS=localhost:9051


peer lifecycle chaincode approveformyorg -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --channelID anchoring --name anchoring --version 1.0 --package-id $CC_PACKAGE_ID --sequence 1 --tls --cafile ${PWD}/fabric-samples/test-network/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

# Return to ORG1
source setEnv.sh

peer lifecycle chaincode checkcommitreadiness --channelID anchoring --name anchoring --version 1.0 --sequence 1 --tls --cafile ${PWD}/fabric-samples/test-network/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem --output json

peer lifecycle chaincode commit -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --channelID anchoring --name anchoring --version 1.0 --sequence 1 --tls --cafile ${PWD}/fabric-samples/test-network/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem --peerAddresses localhost:7051 --tlsRootCertFiles ${PWD}/fabric-samples/test-network/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt --peerAddresses localhost:9051 --tlsRootCertFiles ${PWD}/fabric-samples/test-network/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt

sleep 3
peer lifecycle chaincode querycommitted --channelID anchoring --name anchoring --cafile ${PWD}/fabric-samples/test-network/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

