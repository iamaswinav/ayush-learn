Usage() {
 echo ""
 echo "Usage: ./createPeerAdminCard.sh [-h host] [-n]"
 echo ""
 echo "Options:"
 echo -e "\t-h or --host:\t\t(Optional) name of the host to specify in the connection profile"
 echo -e "\t-n or --noimport:\t(Optional) don't import into card store"
 echo ""
 echo "Example: ./createPeerAdminCard.sh"
 echo ""
 exit 1
}

Parse_Arguments() {
 while [ $# -gt 0 ]; do
 case $1 in
 --help)
 HELPINFO=true
 ;;
 --host | -h)
 shift
 HOST="$1"
 ;;
 --noimport | -n)
 NOIMPORT=true
 ;;
 esac
 shift
 done
}

HOST=localhost
Parse_Arguments $@

if [ "${HELPINFO}" == "true" ]; then
 Usage
fi

# Grab the current directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [ -z "${HL_COMPOSER_CLI}" ]; then
 HL_COMPOSER_CLI=$(which composer)
fi

echo
# check that the composer command exists at a version >v0.16
COMPOSER_VERSION=$("${HL_COMPOSER_CLI}" --version 2>/dev/null)
COMPOSER_RC=$?

if [ $COMPOSER_RC -eq 0 ]; then
 AWKRET=$(echo $COMPOSER_VERSION | awk -F. '{if ($2<19) print "1"; else print "0";}')
 if [ $AWKRET -eq 1 ]; then
 echo Cannot use $COMPOSER_VERSION version of composer with fabric 1.1, v0.19 or higher is required
 exit 1
 else
 echo Using composer-cli at $COMPOSER_VERSION
 fi
else
 echo 'No version of composer-cli has been detected, you need to install composer-cli at v0.19 or higher'
 exit 1
fi

cat << EOF > DevServer_connection.json
{
    "name": "hlfv1",
    "x-type": "hlfv1",
    "version": "1.0.0",
    "client": {
        "organization": "Org1",
        "connection": {
            "timeout": {
                "peer": {
                    "endorser": "300",
                    "eventHub": "300",
                    "eventReg": "300"
                },
                "orderer": "300"
            }
        }
    },
    "channels": {
        "mychannel": {
            "orderers": [
                "orderer.example.com"
            ],
            "peers": {
                "peer0.org1.example.com": {
                    "endorsingPeer": true,
                    "chaincodeQuery": true,
                    "eventSource": true
                },
                "peer1.org1.example.com": {
                    "endorsingPeer": true,
                    "chaincodeQuery": true,
                    "eventSource": true
                }
            }
        }
    },
    "organizations": {
        "Org1": {
            "mspid": "Org1MSP",
            "peers": [
                "peer0.org1.example.com",
                "peer1.org1.example.com"
            ],
            "certificateAuthorities": [
                "ca.example.com"
            ]
        }
    },
    "orderers": {
        "orderer.example.com": {
            "url": "grpc://100.24.21.91:7050",
            "grpcOptions": {
                "ssl-target-name-override": "orderer.example.com"
            },
            "tlsCACerts": {
                "pem": "-----BEGIN CERTIFICATE-----\nMIICNjCCAdygAwIBAgIRANKVdf2ZuipYc2j+cRKr1KEwCgYIKoZIzj0EAwIwbDEL\nMAkGA1UEBhMCVVMxEzARBgNVBAgTCkNhbGlmb3JuaWExFjAUBgNVBAcTDVNhbiBG\ncmFuY2lzY28xFDASBgNVBAoTC2V4YW1wbGUuY29tMRowGAYDVQQDExF0bHNjYS5l\neGFtcGxlLmNvbTAeFw0xOTAzMzAxOTIxMDhaFw0yOTAzMjcxOTIxMDhaMGwxCzAJ\nBgNVBAYTAlVTMRMwEQYDVQQIEwpDYWxpZm9ybmlhMRYwFAYDVQQHEw1TYW4gRnJh\nbmNpc2NvMRQwEgYDVQQKEwtleGFtcGxlLmNvbTEaMBgGA1UEAxMRdGxzY2EuZXhh\nbXBsZS5jb20wWTATBgcqhkjOPQIBBggqhkjOPQMBBwNCAARyk+5jZ6v4GUupStdG\nHSAYx79DlAGg7iDF2Jb6o3voG1gj2ZQtRkks3ct2I2yo+wChrEzx9ZpS8GoUy5QB\nVvcXo18wXTAOBgNVHQ8BAf8EBAMCAaYwDwYDVR0lBAgwBgYEVR0lADAPBgNVHRMB\nAf8EBTADAQH/MCkGA1UdDgQiBCCKVqegmLHYs13Ex/sz1ZhFX/5WFQvZLaSPfuQq\nv6EU9TAKBggqhkjOPQQDAgNIADBFAiEA4WtWhRNTmzKWa0lIzSyLQ6bFBnB+SJyd\naAGxTjMV9nUCICwGnIv/rdeXtZWneAMflNuRv5p8nLBocd+FlUqUcMkZ\n-----END CERTIFICATE-----\n"
            }
        }
    },
    "peers": {
        "peer0.org1.example.com": {
            "url": "grpc://100.24.21.91:7051",
            "eventUrl": "grpc://100.24.21.91:7053",
            "grpcOptions": {
                "ssl-target-name-override": "peer0.org1.example.com"
            },
            "tlsCACerts": {
                "pem": "-----BEGIN CERTIFICATE-----\nMIICSTCCAfCgAwIBAgIRAO5I+/ktrHZgXQmnl/Y/haswCgYIKoZIzj0EAwIwdjEL\nMAkGA1UEBhMCVVMxEzARBgNVBAgTCkNhbGlmb3JuaWExFjAUBgNVBAcTDVNhbiBG\ncmFuY2lzY28xGTAXBgNVBAoTEG9yZzEuZXhhbXBsZS5jb20xHzAdBgNVBAMTFnRs\nc2NhLm9yZzEuZXhhbXBsZS5jb20wHhcNMTkwMzMwMTkyMTA4WhcNMjkwMzI3MTky\nMTA4WjB2MQswCQYDVQQGEwJVUzETMBEGA1UECBMKQ2FsaWZvcm5pYTEWMBQGA1UE\nBxMNU2FuIEZyYW5jaXNjbzEZMBcGA1UEChMQb3JnMS5leGFtcGxlLmNvbTEfMB0G\nA1UEAxMWdGxzY2Eub3JnMS5leGFtcGxlLmNvbTBZMBMGByqGSM49AgEGCCqGSM49\nAwEHA0IABOQILSHCZAtZFVNswrsrIps7uMYDoCHKMqSiwTnEBEkjnOqyPimt+fyz\nUJ8VAU4afp8CCU2FElvxJGmOMYsqElyjXzBdMA4GA1UdDwEB/wQEAwIBpjAPBgNV\nHSUECDAGBgRVHSUAMA8GA1UdEwEB/wQFMAMBAf8wKQYDVR0OBCIEIHCNzR8334Bg\nsp7cHVpZUdhhuze8yREez/JdpZ9FX15mMAoGCCqGSM49BAMCA0cAMEQCIHwcbMM2\nyh5WZ97pbT+RnZ9AzO+Qc8ogZhOQkA3R8pPtAiAu84qTNxcNAI7Rjy3Z50BBnXUw\nnx3Vbs9/Y7KpqXMSsQ==\n-----END CERTIFICATE-----\n"
            }
        },
        "peer1.org1.example.com": {
            "url": "grpc://100.24.21.91:8051",
            "eventUrl": "grpc://100.24.21.91:8053",
            "grpcOptions": {
                "ssl-target-name-override": "peer1.org1.example.com"
            },
            "tlsCACerts": {
                "pem": "-----BEGIN CERTIFICATE-----\nMIICSTCCAfCgAwIBAgIRAO5I+/ktrHZgXQmnl/Y/haswCgYIKoZIzj0EAwIwdjEL\nMAkGA1UEBhMCVVMxEzARBgNVBAgTCkNhbGlmb3JuaWExFjAUBgNVBAcTDVNhbiBG\ncmFuY2lzY28xGTAXBgNVBAoTEG9yZzEuZXhhbXBsZS5jb20xHzAdBgNVBAMTFnRs\nc2NhLm9yZzEuZXhhbXBsZS5jb20wHhcNMTkwMzMwMTkyMTA4WhcNMjkwMzI3MTky\nMTA4WjB2MQswCQYDVQQGEwJVUzETMBEGA1UECBMKQ2FsaWZvcm5pYTEWMBQGA1UE\nBxMNU2FuIEZyYW5jaXNjbzEZMBcGA1UEChMQb3JnMS5leGFtcGxlLmNvbTEfMB0G\nA1UEAxMWdGxzY2Eub3JnMS5leGFtcGxlLmNvbTBZMBMGByqGSM49AgEGCCqGSM49\nAwEHA0IABOQILSHCZAtZFVNswrsrIps7uMYDoCHKMqSiwTnEBEkjnOqyPimt+fyz\nUJ8VAU4afp8CCU2FElvxJGmOMYsqElyjXzBdMA4GA1UdDwEB/wQEAwIBpjAPBgNV\nHSUECDAGBgRVHSUAMA8GA1UdEwEB/wQFMAMBAf8wKQYDVR0OBCIEIHCNzR8334Bg\nsp7cHVpZUdhhuze8yREez/JdpZ9FX15mMAoGCCqGSM49BAMCA0cAMEQCIHwcbMM2\nyh5WZ97pbT+RnZ9AzO+Qc8ogZhOQkA3R8pPtAiAu84qTNxcNAI7Rjy3Z50BBnXUw\nnx3Vbs9/Y7KpqXMSsQ==\n-----END CERTIFICATE-----\n"
            }
        }
    },
    "certificateAuthorities": {
        "ca.example.com": {
            "url": "http://100.24.21.91:7054",
            "caName": "ca.example.com",
            "httpOptions": {
                "verify": false
            }
        }
    }
}
EOF

PRIVATE_KEY="${DIR}"/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp/keystore/2baa84fbe9db7b756648835db5e00089db70056cd635dcdb30a00128b618f1a5_sk
CERT="${DIR}"/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp/signcerts/Admin@org1.example.com-cert.pem

if [ "${NOIMPORT}" != "true" ]; then
 CARDOUTPUT=/tmp/PeerAdmin@hlfv1.card
else
 CARDOUTPUT=PeerAdmin@hlfv1.card
fi

"${HL_COMPOSER_CLI}" card create -p DevServer_connection.json -u PeerAdmin -c "${CERT}" -k "${PRIVATE_KEY}" -r PeerAdmin -r ChannelAdmin --file $CARDOUTPUT

if [ "${NOIMPORT}" != "true" ]; then
 if "${HL_COMPOSER_CLI}" card list -c PeerAdmin@hlfv1 > /dev/null; then
 "${HL_COMPOSER_CLI}" card delete -c PeerAdmin@hlfv1
 fi

"${HL_COMPOSER_CLI}" card import --file /tmp/PeerAdmin@hlfv1.card 
 "${HL_COMPOSER_CLI}" card list
 echo "Hyperledger Composer PeerAdmin card has been imported, host of fabric specified as '${HOST}'"
 rm /tmp/PeerAdmin@hlfv1.card
else
 echo "Hyperledger Composer PeerAdmin card has been created, host of fabric specified as '${HOST}'"
fi