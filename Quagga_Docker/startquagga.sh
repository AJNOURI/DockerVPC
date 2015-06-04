#!/bin/bash

IID1="$(sudo docker images | grep quagga | awk '{ print $3; }')"
lxterminal -e "sudo docker run -t -i --privileged=true --name quagga1 $IID1 /bin/bash"
sleep 2

CID1="$(sudo docker ps | grep quagga1 | awk '{ print $1; }')"

# Combaknfigure additional interfaces on the container,
# - host bridge to  which the interfaces is connected
# - container interface IP
# - gateway: the last configured gateway is used
sudo pipework br2 -i eth1 $CID1 192.168.12.1/24@192.168.12.100
sudo pipework br3 -i eth2 $CID1 192.168.13.1/24@192.168.13.100
sudo pipework br4 -i eth3 $CID1 192.168.14.1/24@192.168.14.100

