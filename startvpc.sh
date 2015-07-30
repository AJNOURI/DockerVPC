#!/bin/bash

# AJ NOURI: cciethebeginning.wordpress.com
# Email: ajn.bin@gmail.com

# $1 = Image tag
# $2 = Container name
function end_host(){
 # local variables
 # $1: container name
 # $2: Image tag
 xhost local:root
 lxterminal -e "sudo docker run --privileged -ti -v /tmp/.X11-unix:/tmp/.X11-unix
                                                 -v /dev/snd:/dev/snd -e DISPLAY=unix$DISPLAY
                                                 --name $1 $2 /bin/bash"
}

function quagga(){
  # local variable
  # $1: container name
  # $2: Image id
  lxterminal -e "sudo docker run -t -i --privileged=true --name $1 $2 /bin/bash"
}

function networking(){
  # $1 : The 1st argument passed to the function, container ID.
  # Configure additional interfaces on the container:
  # - host bridge to  which the interfaces is connected
  # - container interface IP
  # - gateway: the last configured gateway is used
  echo "Container networking... \n"
  while true; do
    read -p 'Continue? [Yy] [Nn]' NET
    case $NET in
    [Yy]* ) break;;
    [Nn]* ) exit;;
    esac
  done
  while true; do
    read -p 'Enter Host bridge to connect the container to => ' BR
    read -p 'Enter a new interface inside the container to connect to host bridge => ' INT
    read -p 'Enter IP address (without mask) for the container interface => ' IP
    read -p 'Enter the mask length => ' MASK
    read -p 'Enter the next-hop IP (GNS3 device) => ' NH

    ISBR="$(brctl show  | grep $BR | awk '{ print $1; }')"
    if [[ $ISBR == $BR ]]; then
      echo "Bridge $BR already exists! "
      echo "Make sure to use the same subnet for a given bridge interface."
      read -p 'Would you like to continue?  [Yy] [Nn]  ' CONT
      while true; do
        case $CONT in
          [Yy]* ) break 1;;
          [Nn]* ) exit;;
          * ) echo "Please answer yes [Yy]* or no [Nn]*";;
        esac
      done
    else
      echo "$BR doesn't exist"
    fi
    if sudo pipework $BR -i $INT $1 $IP/$MASK@$NH ; then
      sudo echo "command: >> sudo pipework $BR -i $INT $1 $IP/$MASK@$NH << successfully executed."
    else
      echo "pipework error!" 1>&2
    fi
    while true; do
      read -p 'Would you like to continue with network configuration? [Yy] [Nn]  ' CONT
      case $CONT in
        [Yy]* ) break 1;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes [Yy]* or no [Nn]*";;
      esac
    done
  done
}

if [ ! $# == 2 ]; then
  echo "Usage: `$0` {image_tag} {container_name}"
  exit 2
fi

INAME=$1
CNAME=$2
IID="$(sudo docker images | grep $INAME | awk '{ print $3; }')"
RCID="$(sudo docker ps -a | grep $CNAME | grep Up | awk '{ print $1; }')"
CID="$(sudo docker ps -a | grep $CNAME | grep Exited | awk '{ print $1; }')"

if [[ ! $IID  ]]
then
  echo " "
  echo "There is no such image, please check the image list."
  echo "Otherwise compile your image from Dockerfile or pull it from DockerHub"
  echo " "
  echo "$(sudo docker images)"
  echo " "
  exit
fi

if [[ $RCID ]]
then
  while true; do
    echo "There is a running container with the same name, $CNAME :CID= $RCID"
    read -p 'Would you like to [E]xit it, [D]elete it, [A]ttach a console or [S]kip? [Ee]/[Dd]/[Aa]/[Ss]  ' RESP
    case "$RESP" in
      [Ee]* ) sudo docker stop $RCID;exit;;
      [Ss]* ) networking $CID; exit;;
      [Dd]* ) sudo docker stop $RCID; sudo docker rm $RCID; exit;;
      [Aa]* ) lxterminal -e "sudo docker attach $RCID";exit;;
      * ) echo "Please answer yes [Yy]* or no [Nn]*";;
    esac
  done
fi

if [[ $CID  ]]
  then
    echo "Container ID: $CID"
    while true; do
    echo "There is a stopped container with the same name, $CNAME :CID= $CID"
    read -p 'Would you like to [R]un it or [D]elete it or [S]kip? [Rr]/[Dd]/[Ss]  ' RESP
    case $RESP in
      [Rr]* ) sudo docker start $CID;lxterminal -e "sudo docker attach $CNAME"; sleep 2;networking $CID; break;;
      [Dd]* ) sudo docker stop $CID; sudo docker rm $CID; exit;;
      [Ss]* ) exit;;
      * ) echo "Please answer yes [Yy]* or no [Nn]*";;
    esac
  done
else
  echo "Spawning a new container"
  end_host $CNAME $IID
  sleep 2
  CID="$(sudo docker ps | grep $CNAME | awk '{ print $1; }')"
  networking $CID
fi
