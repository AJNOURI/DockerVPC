#!/bin/bash

# Building images if they don't exist
IMGLIST="$(sudo docker images | grep phubase | awk '{ print $1; }')"

! [[ $IMGLIST =~ "phubase" ]] && sudo docker build -t mybimage -f phusion-dockerbase .
! [[ $IMGLIST =~ "myapache" ]] && sudo docker build -t myapache -f apache-docker .
! [[ $IMGLIST =~ "myfirefox" ]] && sudo docker build -t myfirefox -f firefox-docker .

# The 1st container from the base image (tool)
BASE_I1="$(sudo docker images | grep phubase | awk '{ print $3; }')"
lxterminal -e "sudo docker run -t -i --name phubase1 $BASE_I1 /bin/bash"
sleep 2
BASE_C1="$(sudo docker ps | grep phubase1 | awk '{ print $1; }')"
sudo pipework br4 -i eth1 $BASE_C1 192.168.44.1/24@192.168.44.100 

# The 2nd container from the base image (tool)
BASE_I2="$(sudo docker images | grep phubase | awk '{ print $3; }')"
lxterminal -e "sudo docker run -t -i --name phubase2 $BASE_I2 /bin/bash"
sleep 2
BASE_C2="$(sudo docker ps | grep phubase2 | awk '{ print $1; }')"
sudo pipework br5 -i eth1 $BASE_C2 192.168.55.1/24@192.168.55.100 

# Apache server Container
APACHE_I1="$(sudo docker images | grep myapache | awk '{ print $3; }')"
lxterminal -t "Base apache" -e "sudo docker run -t -i --name apache1 $APACHE_I1 /bin/bash"
sleep 2
APACHE_C1="$(sudo docker ps | grep apache1 | awk '{ print $1; }')"
sudo pipework br6 -i eth1 $APACHE_C1 192.168.66.1/24@192.168.66.100 

# Firefox container
lxterminal -t "Firefox" -e "sudo docker run -ti --name firefox1 --rm -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix myfirefox"
sleep 2
FIREFOX_C1="$(sudo docker ps | grep firefox1 | awk '{ print $1; }')"
sudo pipework br7 -i eth1 $FIREFOX_C1 192.168.77.1/24@192.168.77.100 
