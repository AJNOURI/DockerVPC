#!/bin/bash

# Script arguments:
# $1: base image tag
# $2: number of container to run
# $3: the host bridge interface number to connect containers to
# $4:
#./multidocker.sh mybimage 2 br5 192.168.55 192.168.55.100 192.168.44.1
BASE_I="$(sudo docker images | grep $1 | awk '{ print $3; }')"
if [ "$#" -lt 5 ] || [ "$#" -gt 6]; then
  echo -e "Usage: $0 <image-tag> <nbr-of-containers> <bridge-interface> <X.X.X.> <def-gateway> {dns-server}\n" >&2
  exit 1
elif [ "$BASE_I" == "" ]; then
  echo -e "Image $1 not found \n" >&2
  echo -e "Check your image with <docker images> command \n"
  exit 1
else
    for (( i=1; i<=$2; i=i+1 ))
    do
        echo -e "\nContainer $i $BASE_I\n"
        if [ "$#" -eq 6 ]; then
            lxterminal -e "sudo docker run --dns=$6 -ti --name mybimage$i $BASE_I /bin/bash"
        else
            lxterminal -e "sudo docker run -ti --name mybimage$i $BASE_I /bin/bash"
        fi
        sleep 2
        echo -e "\nContainer $i : setting network parameters \n"
        BASE_C="$(sudo docker ps | grep mybimage$i | awk '{ print $1; }')"
        echo -e "\nContainer ID $BASE_C \n"
        sudo pipework $3 -i eth1 $BASE_C $4.$i/24@$5
    done
fi
