#!/bin/bash

echo

export FABRIC_CA_CLIENT_HOME=/organizations/ordererOrganizations/example.com
echo $FABRIC_CA_CLIENT_HOME

set -x
fabric-ca-client reenroll -u https://admin:adminpw@ca-orderer:7054 --caname ca-orderer --tls.certfiles "/organizations/fabric-ca/ordererOrg/tls-cert.pem" --csr.keyrequest.reusekey
{ set +x; } 2>/dev/null

# Copy orderer org's CA cert to orderer org's /msp/tlscacerts directory (for use in the channel MSP definition)
mkdir -p /organizations/ordererOrganizations/example.com/msp/tlscacerts
cp /organizations/fabric-ca/ordererOrg/ca-cert.pem /organizations/ordererOrganizations/example.com/msp/tlscacerts/tlsca.example.com-cert.pem

# Copy orderer org's CA cert to orderer org's /tlsca directory (for use by clients)
mkdir -p /organizations/ordererOrganizations/example.com/tlsca
cp /organizations/fabric-ca/ordererOrg/ca-cert.pem /organizations/ordererOrganizations/example.com/tlsca/tlsca.example.com-cert.pem

# ---------------------------------------
# orderer 1

echo "Re-enroll the orderer msp"
set -x
fabric-ca-client reenroll -u https://orderer:ordererpw@ca-orderer:7054 --caname ca-orderer -M "/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp" --csr.hosts orderer.example.com --csr.hosts localhost --csr.hosts ca-orderer --csr.hosts orderer --tls.certfiles "/organizations/fabric-ca/ordererOrg/tls-cert.pem" --csr.keyrequest.reusekey
{ set +x; } 2>/dev/null

cp "/organizations/ordererOrganizations/example.com/msp/config.yaml" "/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/config.yaml"

echo "Re-enroll the orderer-tls certificates"
set -x
fabric-ca-client reenroll -u https://orderer:ordererpw@ca-orderer:7054 --caname ca-orderer -M "/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls" --enrollment.profile tls --csr.hosts orderer.example.com --csr.hosts localhost --csr.hosts ca-orderer --csr.hosts orderer --tls.certfiles "/organizations/fabric-ca/ordererOrg/tls-cert.pem" --csr.keyrequest.reusekey
{ set +x; } 2>/dev/null

# Copy the tls CA cert, server cert, server keystore to well known file names in the orderer's tls directory that are referenced by orderer startup config
cp /organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/tlscacerts/* /organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/ca.crt
cp /organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/signcerts/* /organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/server.crt
cp /organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/keystore/* /organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/server.key

# Copy orderer org's CA cert to orderer's /msp/tlscacerts directory (for use in the orderer MSP definition)
mkdir -p /organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts
cp /organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/tlscacerts/* /organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

# ---------------------------------------
# orderer 2

echo "Re-enroll the orderer2 msp"
set -x
fabric-ca-client reenroll -u https://orderer:ordererpw@ca-orderer:7054 --caname ca-orderer -M "/organizations/ordererOrganizations/example.com/orderers/orderer2.example.com/msp" --csr.hosts orderer2.example.com --csr.hosts localhost --csr.hosts ca-orderer --csr.hosts orderer2 --tls.certfiles "/organizations/fabric-ca/ordererOrg/tls-cert.pem" --csr.keyrequest.reusekey
{ set +x; } 2>/dev/null

cp "/organizations/ordererOrganizations/example.com/msp/config.yaml" "/organizations/ordererOrganizations/example.com/orderers/orderer2.example.com/msp/config.yaml"

echo "Re-enroll the orderer2-tls certificates"
set -x
fabric-ca-client reenroll -u https://orderer:ordererpw@ca-orderer:7054 --caname ca-orderer -M "/organizations/ordererOrganizations/example.com/orderers/orderer2.example.com/tls" --enrollment.profile tls --csr.hosts orderer2.example.com --csr.hosts localhost --csr.hosts ca-orderer2 --csr.hosts orderer2 --tls.certfiles "/organizations/fabric-ca/ordererOrg/tls-cert.pem" --csr.keyrequest.reusekey
{ set +x; } 2>/dev/null

# Copy the tls CA cert, server cert, server keystore to well known file names in the orderer's tls directory that are referenced by orderer startup config
cp /organizations/ordererOrganizations/example.com/orderers/orderer2.example.com/tls/tlscacerts/* /organizations/ordererOrganizations/example.com/orderers/orderer2.example.com/tls/ca.crt
cp /organizations/ordererOrganizations/example.com/orderers/orderer2.example.com/tls/signcerts/* /organizations/ordererOrganizations/example.com/orderers/orderer2.example.com/tls/server.crt
cp /organizations/ordererOrganizations/example.com/orderers/orderer2.example.com/tls/keystore/* /organizations/ordererOrganizations/example.com/orderers/orderer2.example.com/tls/server.key

# Copy orderer org's CA cert to orderer's /msp/tlscacerts directory (for use in the orderer MSP definition)
mkdir -p /organizations/ordererOrganizations/example.com/orderers/orderer2.example.com/msp/tlscacerts
cp /organizations/ordererOrganizations/example.com/orderers/orderer2.example.com/tls/tlscacerts/* /organizations/ordererOrganizations/example.com/orderers/orderer2.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

# ---------------------------------------
# orderer 3

echo "Re-enroll the orderer3 msp"
set -x
fabric-ca-client reenroll -u https://orderer:ordererpw@ca-orderer:7054 --caname ca-orderer -M "/organizations/ordererOrganizations/example.com/orderers/orderer3.example.com/msp" --csr.hosts orderer3.example.com --csr.hosts localhost --csr.hosts ca-orderer --csr.hosts orderer3 --tls.certfiles "/organizations/fabric-ca/ordererOrg/tls-cert.pem" --csr.keyrequest.reusekey
{ set +x; } 2>/dev/null

cp "/organizations/ordererOrganizations/example.com/msp/config.yaml" "/organizations/ordererOrganizations/example.com/orderers/orderer3.example.com/msp/config.yaml"

echo "Re-enroll the orderer3-tls certificates"
set -x
fabric-ca-client reenroll -u https://orderer:ordererpw@ca-orderer:7054 --caname ca-orderer -M "/organizations/ordererOrganizations/example.com/orderers/orderer3.example.com/tls" --enrollment.profile tls --csr.hosts orderer3.example.com --csr.hosts localhost --csr.hosts ca-orderer3 --csr.hosts orderer3 --tls.certfiles "/organizations/fabric-ca/ordererOrg/tls-cert.pem" --csr.keyrequest.reusekey
{ set +x; } 2>/dev/null

# Copy the tls CA cert, server cert, server keystore to well known file names in the orderer's tls directory that are referenced by orderer startup config
cp /organizations/ordererOrganizations/example.com/orderers/orderer3.example.com/tls/tlscacerts/* /organizations/ordererOrganizations/example.com/orderers/orderer3.example.com/tls/ca.crt
cp /organizations/ordererOrganizations/example.com/orderers/orderer3.example.com/tls/signcerts/* /organizations/ordererOrganizations/example.com/orderers/orderer3.example.com/tls/server.crt
cp /organizations/ordererOrganizations/example.com/orderers/orderer3.example.com/tls/keystore/* /organizations/ordererOrganizations/example.com/orderers/orderer3.example.com/tls/server.key

# Copy orderer org's CA cert to orderer's /msp/tlscacerts directory (for use in the orderer MSP definition)
mkdir -p /organizations/ordererOrganizations/example.com/orderers/orderer3.example.com/msp/tlscacerts
cp /organizations/ordererOrganizations/example.com/orderers/orderer3.example.com/tls/tlscacerts/* /organizations/ordererOrganizations/example.com/orderers/orderer3.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

# ---------------------------------------
# orderer 4

echo "Re-enroll the orderer4 msp"
set -x
fabric-ca-client reenroll -u https://orderer:ordererpw@ca-orderer:7054 --caname ca-orderer -M "/organizations/ordererOrganizations/example.com/orderers/orderer4.example.com/msp" --csr.hosts orderer4.example.com --csr.hosts localhost --csr.hosts ca-orderer --csr.hosts orderer4 --tls.certfiles "/organizations/fabric-ca/ordererOrg/tls-cert.pem" --csr.keyrequest.reusekey
{ set +x; } 2>/dev/null

cp "/organizations/ordererOrganizations/example.com/msp/config.yaml" "/organizations/ordererOrganizations/example.com/orderers/orderer4.example.com/msp/config.yaml"

echo "Re-enroll the orderer4-tls certificates"
set -x
fabric-ca-client reenroll -u https://orderer:ordererpw@ca-orderer:7054 --caname ca-orderer -M "/organizations/ordererOrganizations/example.com/orderers/orderer4.example.com/tls" --enrollment.profile tls --csr.hosts orderer4.example.com --csr.hosts localhost --csr.hosts ca-orderer4 --csr.hosts orderer4 --tls.certfiles "/organizations/fabric-ca/ordererOrg/tls-cert.pem" --csr.keyrequest.reusekey
{ set +x; } 2>/dev/null

# Copy the tls CA cert, server cert, server keystore to well known file names in the orderer's tls directory that are referenced by orderer startup config
cp /organizations/ordererOrganizations/example.com/orderers/orderer4.example.com/tls/tlscacerts/* /organizations/ordererOrganizations/example.com/orderers/orderer4.example.com/tls/ca.crt
cp /organizations/ordererOrganizations/example.com/orderers/orderer4.example.com/tls/signcerts/* /organizations/ordererOrganizations/example.com/orderers/orderer4.example.com/tls/server.crt
cp /organizations/ordererOrganizations/example.com/orderers/orderer4.example.com/tls/keystore/* /organizations/ordererOrganizations/example.com/orderers/orderer4.example.com/tls/server.key

# Copy orderer org's CA cert to orderer's /msp/tlscacerts directory (for use in the orderer MSP definition)
mkdir -p /organizations/ordererOrganizations/example.com/orderers/orderer4.example.com/msp/tlscacerts
cp /organizations/ordererOrganizations/example.com/orderers/orderer4.example.com/tls/tlscacerts/* /organizations/ordererOrganizations/example.com/orderers/orderer4.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

# ---------------------------------------
# orderer 5

echo "Re-enroll the orderer5 msp"
set -x
fabric-ca-client reenroll -u https://orderer:ordererpw@ca-orderer:7054 --caname ca-orderer -M "/organizations/ordererOrganizations/example.com/orderers/orderer5.example.com/msp" --csr.hosts orderer5.example.com --csr.hosts localhost --csr.hosts ca-orderer --csr.hosts orderer5 --tls.certfiles "/organizations/fabric-ca/ordererOrg/tls-cert.pem" --csr.keyrequest.reusekey
{ set +x; } 2>/dev/null

cp "/organizations/ordererOrganizations/example.com/msp/config.yaml" "/organizations/ordererOrganizations/example.com/orderers/orderer5.example.com/msp/config.yaml"

echo "Re-enroll the orderer5-tls certificates"
set -x
fabric-ca-client reenroll -u https://orderer:ordererpw@ca-orderer:7054 --caname ca-orderer -M "/organizations/ordererOrganizations/example.com/orderers/orderer5.example.com/tls" --enrollment.profile tls --csr.hosts orderer5.example.com --csr.hosts localhost --csr.hosts ca-orderer5 --csr.hosts orderer5 --tls.certfiles "/organizations/fabric-ca/ordererOrg/tls-cert.pem" --csr.keyrequest.reusekey
{ set +x; } 2>/dev/null

# Copy the tls CA cert, server cert, server keystore to well known file names in the orderer's tls directory that are referenced by orderer startup config
cp /organizations/ordererOrganizations/example.com/orderers/orderer5.example.com/tls/tlscacerts/* /organizations/ordererOrganizations/example.com/orderers/orderer5.example.com/tls/ca.crt
cp /organizations/ordererOrganizations/example.com/orderers/orderer5.example.com/tls/signcerts/* /organizations/ordererOrganizations/example.com/orderers/orderer5.example.com/tls/server.crt
cp /organizations/ordererOrganizations/example.com/orderers/orderer5.example.com/tls/keystore/* /organizations/ordererOrganizations/example.com/orderers/orderer5.example.com/tls/server.key

# Copy orderer org's CA cert to orderer's /msp/tlscacerts directory (for use in the orderer MSP definition)
mkdir -p /organizations/ordererOrganizations/example.com/orderers/orderer5.example.com/msp/tlscacerts
cp /organizations/ordererOrganizations/example.com/orderers/orderer5.example.com/tls/tlscacerts/* /organizations/ordererOrganizations/example.com/orderers/orderer5.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

echo "Re-enroll the admin msp"
set -x
fabric-ca-client reenroll -u https://ordererAdmin:ordererAdminpw@ca-orderer:7054 --caname ca-orderer -M "/organizations/ordererOrganizations/example.com/users/Admin@example.com/msp" --tls.certfiles "/organizations/fabric-ca/ordererOrg/tls-cert.pem" --csr.keyrequest.reusekey
{ set +x; } 2>/dev/null

cp "/organizations/ordererOrganizations/example.com/msp/config.yaml" "/organizations/ordererOrganizations/example.com/users/Admin@example.com/msp/config.yaml"