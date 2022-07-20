#!/bin/bash

# NOTE that this needs docker or podman to run in your EC2 instance
####################################################################

CLIENTNAME=$1
OVPN_DATA="ovpn-data"

function get_public_ip() {
	echo "getting public IP addr"
	PUBLIC_IPV4=$(dig @resolver4.opendns.com myip.opendns.com +short)
}

get_public_ip

docker volume create --name ${OVPN_DATA}
docker run -v ${OVPN_DATA}:/etc/openvpn --rm kylemanna/openvpn ovpn_genconfig -b -u udp://${PUBLIC_IPV4}
docker run -v ${OVPN_DATA}:/etc/openvpn --rm -it kylemanna/openvpn ovpn_initpki nopass
docker run -v ${OVPN_DATA}:/etc/openvpn -d -p 1194:1194/udp --cap-add=NET_ADMIN kylemanna/openvpn
docker run -v ${OVPN_DATA}:/etc/openvpn --rm -it kylemanna/openvpn easyrsa build-client-full ${CLIENTNAME} nopass
docker run -v ${OVPN_DATA}:/etc/openvpn --rm kylemanna/openvpn ovpn_getclient ${CLIENTNAME} > ${CLIENTNAME}.ovpn
