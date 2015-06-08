#!/bin/bash

# $1 = Container name

function networking(){
   # $1 : The 1st argument passed to the function, container ID
   # Configure additional interfaces on the container,
   # - host bridge to  which the interfaces is connected
   # - container interface IP
   # - gateway: the last configured gateway is used
   echo "Quagga networking... \n"
   while true; do
       read -p 'Continue? [Yy] [Nn]' NET
       case $NET in
       [Yy]* ) break;;
       [Nn]* ) exit;;
       esac
   done
   while true; do
       read -p 'Host bridge interface => ' BR
       read -p 'Container: interface (a new one) connected to host bridge => ' INT
       read -p 'Container: interface IP => ' IP
       read -p 'Container: interface IP mask => ' MASK
       read -p 'Container: interface next-hop IP (GNS3) => ' NH
       if sudo pipework $BR -i $INT $1 $IP/$MASK@$NH ; then
        sudo echo "command: >> sudo pipework $BR -i $INT $1 $IP/$MASK@$NH << successfully executed."
    else
        echo "Error executing pipework command!" 1>&2
    fi
       read -p 'Would you like to continue with network configuration? [Yy] [Nn]' CONT
       case $CONT in
            [Yy]* ) ;;
            [Nn]* ) exit;;
            * ) echo "Please answer yes [Yy]* or no [Nn]*";;
            esac
    done
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

if [[ $RCID ]]
then
    while true; do
        echo "$CNAME is a running container: $RCID"
        read -p 'There is a running container with the same name. Would you like to stop it? [Yy] [Nn]' RESP
        case "$RESP" in
        [Yy]* ) sudo docker stop $RCID;exit;;
        [Nn]* ) networking $CID; exit;;
        * ) echo "Please answer yes [Yy]* or no [Nn]*";;
        esac
    done
fi

if [[ $CID  ]]
then
    echo "Container ID: $CID"
    while true; do
        read -p 'There is a stopped container with the same name. Would you like to start it? [Yy] [Nn]' RESP
        case $RESP in
        [Yy]* ) sudo docker start $CID;lxterminal -e "sudo docker attach $CNAME"; sleep 2;networking $CID; break;;
        [Nn]* ) exit;;
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
