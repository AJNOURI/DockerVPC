#!/bin/bash

# Script arguments:
# $1: image tag
# $2: number of container to run
# $3: the host bridge interface to connect containers to
# $4: network portion common to all hosts (/24) X.X.X
# $5: next-hop of the segment
#./multi-container.sh <mybimage> 2 br5 192.168.55 192.168.55.100
warn () {
    echo "$@" >&2
}

die () {
    status="$1"
    shift
    warn "$@"
    exit "$status"
}

if [ "$#" -lt 5 ] || [ "$#" -gt 6]; then
  echo ""
  echo -e "Usage: $0 <image-tag> <nbr-of-containers> <bridge-interface> <X.X.X> <def-gateway> {dns-server}\n" >&2
  echo "{dns-server} is optional."
  echo ""
  die 1
fi

ITAG="$(sudo docker images | grep $1 | awk '{ print $3; }')"
IS_IMAGE="$(sudo docker images | grep $1 | awk '{ print $1; }')"
CNAMES="multi-PC"
CINT="eth1"
echo "Image tag = $1"
echo "Number of containers = $2"
echo "Bridge interface = $3"
echo "Subnet portion = $4"
echo "default gw = $5"
echo "DNS server = $6"
echo "ITAG = $ITAG"
echo "IS_IMAGE = $IS_IMAGE"
#die 1



if [ "$IS_IMAGE" == "" ]; then
  echo -e "Image $1 not found \n" >&2
  echo -e "Check for the available image with <docker images> command. \n"
  die 1
else
    for (( i=1; i<=$2; i=i+1 ))
    do
        echo -e "\nContainer $CNAMES $i\n"
        if [ "$#" -eq 6 ]; then
            sudo docker run --dns=$6 -tid --hostname $CNAMES$i --name $CNAMES$i $ITAG /bin/bash
        else
            sudo docker run -tid --hostname $CNAMES$i --name $CNAMES$i $ITAG /bin/bash
        fi
        sleep 2
        CID="$(sudo docker ps | grep $CNAMES$i | awk '{ print $1; }')"
        sudo pipework $3 -i $CINT $CID $4.$i/24@$5
    done
fi
