#!/bin/bash

# AJ NOURI: cciethebeginning.wordpress.com
# Email: ajn.bin@gmail.com
# $1 = Image tag
# $2 = Container name


function run_container(){
 # local variables
 # $1: container name
 # $2: Image tag
 # $3: Running container ID
 case "$INAME" in
  cacti) cacti_run $1 $3 ;;
  ovs) ovs_run $1 $2;;
  dockervpc) end_host_run $1 $2 $3;;
  *) echo "Please Provide an existing image tag";;
 esac
}

function console_attach(){
 # local variables
 # $1: container name
 defans="y"
 while true; do
  read -p "Attach a console to the running container $1 ? (y / n) [Yy] " ATTACH
  [ -z "$ATTACH" ] && ATTACH=$defans
  case $ATTACH in
    [Yy]* ) $terminal -e "docker attach $1" & >/dev/null;exit;;
    [Nn]* ) exit;;
  esac
 done
}

function end_host_run(){
 # local variables
 # $1: container name
 # $2: Image tag
 if [[ $3 ]] ; then
    docker start $3
    console_attach $1
    sleep 2
    networking $3
    exit
 else
     xhost local:root
     docker run --privileged -tid \
         -v /tmp/.X11-unix:/tmp/.X11-unix \
         -v /dev/snd:/dev/snd \
         -e DISPLAY=unix$DISPLAY \
         --hostname $1 \
         --name $1 $2 \
         /bin/bash
 fi
 }


function cacti_run(){
  # Run caci container
  # local variable
  # $1: container name
  # $2: Running container ID
#  CACTI_ID=$(docker ps -a | grep $1 | awk '{ print $1; }')
#  echo "CACTI_ID=$CACTI_ID"
#  echo "\$2=$2"
  
  if [[ $2 ]] ; then
      docker start $2
      CIP="$(docker inspect -f '{{ .NetworkSettings.IPAddress }}' $2)"
      echo "Cacti is reachable through http://$CIP:80/cacti"
      exit
  else
      CACTI_ID=$(docker run -d -p 80 -p 161:161 --name $1 quantumobject/docker-cacti)
      if [[ $CACTI_ID ]] ; then
          echo "Cacti container Successfully started."
          CIP=$(docker inspect -f '{{.NetworkSettings.IPAddress}}' $CACTI_ID)
          echo "Cacti is reachable through http://$CIP:80/cacti"
          exit
      else
          echo "Issue running Cacti container" 1>&2
          exit
      fi
  fi
}


function ovs_run(){
  # Run ovs container
  # local variable
  # $1: container name
  # $2: Stopped container ID if exist
#  OVS_ID=$(docker ps | grep $1 | awk '{ print $1; }')
  if [[ $2 ]] ; then
      docker start $2
      $terminal -e "docker exec -it $2 /bin/sh" &>/dev/null
  else
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
      $terminal -e "docker exec -it $ovsid /bin/sh" &>/dev/null
  fi
}

function stop_del_exit(){
  while true; do
    echo "There is a already a running container from $1 image"
    read -p 'Would you like to [S]top it, [D]elete it or [q]uit? [Ss]/[Dd]/[Qq]  ' RESP
    case "$RESP" in
      [Ss]* ) docker stop $2;exit;;
      [Dd]* ) docker stop $2; docker rm $2; exit;;
      [Qq]* ) exit;;
      * ) echo "Please answer by [Ss], [Dd] or [Qq] ";;
    esac
  done
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
  defint='eth1'
  echo "Container networking... "
  while true; do
    read -p 'Continue? [Yy] [Nn] ' NET
    case $NET in
    [Yy]* ) break;;
    [Nn]* ) return 1;;
    esac
  done
  while true; do
    read -p 'Enter Host bridge to connect the container to => ' BR
    read -p "Enter a new interface inside the container to connect to host bridge [$defint] => " INT
    [ -z "$INT" ] && INT=$defint
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
        [Qq]* ) break 2;;
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

terminal="$(ps -p $(ps -p $(ps -p $$ -o ppid=) -o ppid=) o args=)"  
echo $terminal

# Image name
INAME=$1
# Container name
CNAME=$2
# Image ID
IID="$(docker images | grep $INAME | awk '{ print $3; }')"
# Running container ID by name
RCID="$(docker ps -a | grep $CNAME | grep Up | awk '{ print $1; }')"
# Running container ID by image tag
RCID_ITAG="$(docker ps -a | grep $CNAME | grep Up | awk '{ print $1; }')"
# Stopped container ID
CID="$(docker ps -a | grep $CNAME | grep 'Exited\|Created' | awk '{ print $1; }')"
#container running from cacti image
CACTI_IMAGE_UP="$(docker ps --format '{{.ID}} {{.Image}}' | grep cacti)"
#container running from openvswitch image
OVS_IMAGE_UP="$(docker ps --format '{{.ID}} {{.Image}}' | grep openvswitch)"

if [[ $CACTI_IMAGE_UP && $INAME == "cacti" ]]; then
    RCID=$(docker ps --format "{{.ID}} {{.Image}}" | grep cacti | awk '{ print $1; }')
    stop_del_exit $INAME $RCID
fi

if [[ $OVS_IMAGE_UP && $INAME == "ovs" ]]; then
    RCID=$(docker ps --format "{{.ID}} {{.Image}}" | grep openvswitch | awk '{ print $1 }')
    stop_del_exit $INAME $RCID
fi

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
  docker pull $pullname
  #Recalculate image ID
  IID="$(docker images | grep $INAME | awk '{ print $3; }')"
fi

# Check whether the container (by name) is running
if [[ $RCID ]]
then
  while true; do
    echo "There is a running container with the same name, $CNAME :CID= $RCID"
    read -p 'Would you like to [S]top it, [D]elete it, [A]ttach a console or s[K]ip? [Ss]/[Dd]/[Aa]/[Kk]  ' RESP
    case "$RESP" in
      [Ss]* ) docker stop $RCID;exit;;
      [Kk]* ) networking $RCID;console_attach $CNAME ;exit;;
      [Dd]* ) docker stop $RCID; docker rm $RCID; exit;;
      [Aa]* ) if [[ $INAME == "dockervpc" ]]; then
            console_attach $CNAME
          elif [[ $INAME == "ovs" ]]; then
            docker exec -it $RCID /bin/sh;exit;
          fi;;
      * ) echo "Please answer by [Ss], [Dd], [Aa] or [Kk] ";;
    esac
  done
fi

# Check whether a container is created but stopped
if [[ $CID  ]]
  then
    echo "Container ID: $CID"
    while true; do
    echo "There is a stopped container with the same name, $CNAME :CID= $CID"
    read -p 'Would you like to [R]un it or [D]elete it or s[K]ip? [Rr]/[Dd]/[Kk]  ' RESP
    case $RESP in
      [Rr]* ) run_container $CNAME $IID $CID; break;;
      [Dd]* ) docker stop $CID; docker rm $CID; exit;;
      [Kk]* ) exit;;
      * ) echo "Please answer by [Rr], [Dd] or [Kk] ";;
    esac
  done
else
  echo "Spawning a new container"
  run_container $CNAME $IID
  sleep 2
  CID="$(docker ps | grep $CNAME | awk '{ print $1; }')"
  networking $CID
  console_attach $CNAME
fi
