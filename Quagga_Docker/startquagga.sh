#!/bin/bash

# $1 = Container name

function networking(){
   # $1 : The 1st argument passed to the function, container ID
   # Configure additional interfaces on the container,
   # - host bridge to  which the interfaces is connected
   # - container interface IP
   # - gateway: the last configured gateway is used
   echo "Configuring networking... \n"
   sudo pipework br2 -i eth1 $1 192.168.12.1/24@192.168.12.100
   sudo pipework br3 -i eth2 $1 192.168.13.1/24@192.168.13.100
   sudo pipework br4 -i eth3 $1 192.168.14.1/24@192.168.14.100
   }

if [ "$#" -ne 2 ]
then
    echo "Usage: `basename $0` {Quagga_image_tag} {Quagga_container_name}" ;exit 2
fi


INAME=$1
CNAME=$2
IID="$(sudo docker images | grep quagga | awk '{ print $3; }')"
RCID="$(sudo docker ps -a | grep $CNAME | grep Up | awk '{ print $1; }')"
CID="$(sudo docker ps -a | grep $CNAME | grep Exited | awk '{ print $1; }')"
RUNNING=false

if [[ $RCID ]]
then
    while true; do
        echo "$CNAME is a running container: $RCID"
        read -p 'There is a running container with the same name. Would you like to stop it? [Yy] [Nn]' resp
        case "$resp" in
        [Yy]* ) sudo docker stop $RCID;exit;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes [Yy]* or no [Nn]*";;
        esac
    done
fi

if [[ $CID  ]]
then
    echo "Container ID: $CID"
    while true; do
        read -p 'There is a stopped container with the same name. Would you like to start it? [Yy] [Nn]' resp
        case $resp in
        [Yy]* ) sudo docker start $CID;lxterminal -e "sudo docker attach $CNAME"; sleep 2;networking $CID; break;;
        [Nn]* ) RUNNING=true; exit;;
        * ) echo "Please answer yes [Yy]* or no [Nn]*";;
        esac
    done
else
    echo "Spawning a new quagga container"
    lxterminal -e "sudo docker run -t -i --privileged=true --name $CNAME $IID /bin/bash"
    sleep 2
    CID="$(sudo docker ps | grep $CNAME | awk '{ print $1; }')"
    networking $CID
fi
