#!/bin/bash

# AJ NOURI: cciethebeginning.wordpress.com
# Email: ajn.bin@gmail.com

# $1 = Image tag
# $2 = Container name



function run_container(){
 # local variables
 # $1: container name
 # $2: Image tag

 case "$INAME" in
  cacti) cacti_run $1;;
  ovs) ovs_run $1;;
  dockervpc) end_host_run $1 $2;;
  *) echo "Please Provide an existing image tag";;
 esac
}


function end_host_run(){
 # local variables
 # $1: container name
 # $2: Image tag
 xhost local:root
 lxterminal -e "docker run --privileged -ti \
     -v /tmp/.X11-unix:/tmp/.X11-unix \
     -v /dev/snd:/dev/snd \
     -e DISPLAY=unix$DISPLAY \
     --hostname $1 \
     --name $1 $2 \
     /bin/bash"
}

function single_run(){
  # Limit to a single running container for some images
  # local variable
  # $1: container name
  RUN_ID=$(docker ps | grep $1 | awk '{ print $1; }')
  if [[ $RUN_ID ]] ; then
    echo "There is already a running container, $RUN_ID, from the same image $1"
    echo " >>> Only one single container from this image can be run <<<"
    while true; do
      read -p 'Would you like to [E]xit it, [D]elete it or [S]kip? [Ee]/[Dd]/[Ss]  ' RESP
      case "$RESP" in
        [Ee]* ) docker stop $RUN_ID;exit;;
        [Ss]* ) exit;;
        [Dd]* ) docker stop $RUN_ID; docker rm $RUN_ID; exit;;
         * ) echo "Please answer yes [Yy]* or no [Nn]* ";;
      esac
    done
  fi
  }

function cacti_run(){
  # Run caci container
  # local variable
  # $1: container name
  RUN_ID=$(docker ps | grep $1 | awk '{ print $1; }')
  if [[ $RUN_ID ]] ; then
  single_run quantumobject/docker-cacti
  CACTI_ID=$(docker run -d -p 80 -p 161:161 --name $1 quantumobject/docker-cacti)
  if [[ $CACTI_ID ]] ; then
      echo "Cacti container Successfully started."
      CACTI_IP=$(docker inspect --format='{{.NetworkSettings.IPAddress}}' $CACTI_ID)
      echo "Cacti is reachable through http://$CACTI_IP:80/cacti"
      exit
  else
      echo "Issue running Cacti container" 1>&2
      exit
  fi
}

function ovs_run(){
  # Run ovs container
  # local variable
  # $1: container name
  RUN_ID=$(docker ps | grep $1 | awk '{ print $1; }')
  if [[ $RUN_ID ]] ; then
  single_run socketplane/openvswitch
  echo "Running ovs container..."
  ovsid=$(sudo docker run -itd --name $1 --cap-add NET_ADMIN socketplane/openvswitch)
  echo -n "Adding interfaces "
  OVSINT=16
  for i in $(seq -w 1 $OVSINT)
    do
      sudo pipework br1$i -i eth$i $ovsid 0/0
      echo -n "."
      sleep 1
    done
  echo ""
  lxterminal -e "docker exec -it $ovsid /bin/sh"
}

function networking(){
  # Configure additional interfaces on the container and 
  # connect them to host bridges.
  # Required inputs from the user:
  # - host bridge: to which we connect the new conatiner interface
  # - The new container interface (name, IP and mask)
  # - The new container interface IP
  # - The new container interface
  # - gateway: should be the IP of the next-hop simulated device in GNS3
  # local variable
  # $1 : Container ID.

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
      echo "command: >> sudo pipework $BR -i $INT $1 $IP/$MASK@$NH << successfully executed."
    else
      echo "pipework error!" 1>&2
      echo "command: >> sudo pipework $BR -i $INT $1 $IP/$MASK@$NH <<"

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
  echo ""
  echo "Supported images {image_tag}"
  echo "  dockervpc : Virtual PC container"
  echo "  cacti     : Cacti server container"
  echo "  ovs       : OVS container "
  echo ""

  exit 1
}

if [ "$#" -ne 2 ]; then
  usage
fi

# Image name
INAME=$1
# Container name
CNAME=$2
# Image ID
IID="$(docker images | grep $INAME | awk '{ print $3; }')"
# Running container ID
RCID="$(docker ps -a | grep $CNAME | grep Up | awk '{ print $1; }')"
# Stopped container ID
CID="$(docker ps -a | grep $CNAME | grep Exited | awk '{ print $1; }')"

# Check whether the image exists

if [[ ! $IID  ]]
then
  case "$INAME" in
   cacti) pullname="quantumobject/docker-cacti";;
   dockervpc) pullname="ajnouri/dockervpc";;
   ovs) pullname="socketplane/openvswitch";;
   *) echo "This image is not supported by the script";exit;;
  esac
  echo " "
fi

# Check whether the container (by name) is running
if [[ $RCID ]]
then
  while true; do
    echo "There is a running container with the same name, $CNAME :CID= $RCID"
    read -p 'Would you like to [E]xit it, [D]elete it, [A]ttach a console or [S]kip? [Ee]/[Dd]/[Aa]/[Ss]  ' RESP
    case "$RESP" in
      [Ee]* ) docker stop $RCID;exit;;
      [Ss]* ) networking $RCID; exit;;
      [Dd]* ) docker stop $RCID; docker rm $RCID; exit;;
      [Aa]* ) lxterminal -e "docker attach $RCID";exit;;
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
      [Rr]* ) docker start $CID; lxterminal -e "docker attach $CNAME"; sleep 2;networking $CID; break;;
      [Dd]* ) docker stop $CID; docker rm $CID; exit;;
      [Ss]* ) exit;;
      * ) echo "Please answer yes [Yy]* or no [Nn]* ";;
    esac
  done
else
  echo "Spawning a new container"
  run_container $CNAME $IID
  sleep 2
  CID="$(docker ps | grep $CNAME | awk '{ print $1; }')"
  networking $CID
fi
