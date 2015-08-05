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
 lxterminal -e "sudo docker run --privileged -ti \
     -v /tmp/.X11-unix:/tmp/.X11-unix \
     -v /dev/snd:/dev/snd \
     -e DISPLAY=unix$DISPLAY \
     --hostname $1 \
     --name $1 $2 \
     /bin/bash"
}

function quagga(){
  # local variable
  # $1: container name
  # $2: Image id
  lxterminal -e "sudo docker run -t -i --privileged=true --name $1 $2 /bin/bash"
}

function networking(){
  # $1 : Container ID.
  # Configure additional interfaces on the container and 
  # connect them to host bridges.
  # Required inputs from the user:
  # - host bridge: to which we connect the new conatiner interface
  # - The new container interface (name, IP and mask)
  # - The new container interface IP
  # - The new container interface
  # - gateway: should be the IP of the next-hop simulated device in GNS3

  echo "Container networking... "
  while true; do
    read -p 'Continue? [Yy] [Nn] ' NET
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
      read -p 'Would you like to apply these network settings?  [Yy] [Nn]  ' CONT
      while true; do
        case $CONT in
          [Yy]* ) break 1;;
          [Nn]* ) exit;;
          * ) echo "Please answer yes [Yy]* or no [Nn] *";;
        esac
      done
    else
      echo "$BR doesn't exist, creating it."
    fi
    if sudo pipework $BR -i $INT $1 $IP/$MASK@$NH ; then
      sudo echo "command: >> sudo pipework $BR -i $INT $1 $IP/$MASK@$NH << successfully executed."
    else
      echo "pipework error!" 1>&2
    fi
    while true; do
      read -p 'Continue with network configuration[Cc], or quit[Qq]?  ' CONT
      case $CONT in
        [Cc]* ) break 1;;
        [Qq]* ) exit;;
        * ) echo "Please answer [Cc]* to continue  or [Qq]* to quit ";;
      esac
    done
done
}

usage(){
  echo "Usage: $0 {image_tag} {container_name}"
  exit 1
}

if [ "$#" -ne 2 ]; then
  usage
fi

# Image tag
INAME=$1
# Container name
CNAME=$2
# Image ID
IID="$(sudo docker images | grep $INAME | awk '{ print $3; }')"
# Running container ID
RCID="$(sudo docker ps -a | grep $CNAME | grep Up | awk '{ print $1; }')"
# Stopped container ID
CID="$(sudo docker ps -a | grep $CNAME | grep Exited | awk '{ print $1; }')"

# Check whether the image exists
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

# Check whether the container (by name) is running
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
      * ) echo "Please answer yes [Yy]* or no [Nn]* ";;
    esac
  done
fi

# Check whether a continer is created but stopped
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
      * ) echo "Please answer yes [Yy]* or no [Nn]* ";;
    esac
  done
else
  echo "Spawning a new container"
  end_host $CNAME $IID
  sleep 2
  CID="$(sudo docker ps | grep $CNAME | awk '{ print $1; }')"
  networking $CID
fi
