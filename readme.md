VirtualPC container for GNS3
=======================

The goal is to take profit of docker containers to useinside GNS3 as aslmost a fill-fledged linux end host instead of using the very limited VPCS or an overkill virtual machine.

This includes a script to manage containers and set networking parameters using pipework.

Included tools in Docker image
------------------------------
These tools are included in the image, so they are available in all generated containers.

> **Tip:** You can install other tools if you make the container reach Internet either before connecting the container to GNS3 (through a bridge) or through your
GNS3 topology.

> Nevertheless, the container VirtualPC is as flexible as a Docker container can be. Docker containers technology is developing very fast.
So this image will be subject to changes as container capabilities grow 

-------------
#### <i class="icon-folder-open"></i> Apache server
Apache server 

> /usr/sbin/apachectl start

From a another container connect to the server using ***curl*** or ***links2***

-------------
#### <i class="icon-folder-open"></i> Traffic generation tools
##### **Ostinato**
From container you want to control, start the server component of Ostinato “drone” in the background, so you can continue to use the terminal: drone &
From Docker host (Desktop OS), you start Ostinato client GUI: Type: ostinato and connect to containers IP running drone
##### **D-ITG**
##### **iperf**

-------------
#### <i class="icon-folder-open"></i> SSH server to connect to connect to the Virtual PC from the host
SSH access to the container: You can use your host keypairs 

> cp /home//.ssh/id_rsa.pub id_rsa.pub

or generate keypair in the current directory (where Dockerfile is located) for use with SSH to container:
From the container, start SSHd: 

> /usr/sbin/sshd

From Docker host: 

> ssh root@

-------------
#### <i class="icon-folder-open"></i> VoIP applications
##### **sipp (text-based)**
##### **pjsua (text-based)**
##### **linphone (text + GUI)**

-------------
#### <i class="icon-folder-open"></i> IPv6 THC tools


-------------
#### <i class="icon-folder-open"></i> VLC (VideoLAN)
Simply start vlc in background 

> vlc &

Small video files in different formats are provided for streaming testing.

-------------
#### <i class="icon-folder-open"></i> Links2 browser

Text mode: 

> links <_url_>

Graphic mode: 

> links2 -g <_url_>

-------------
#### <i class=”icon-folder-open”></i> And many other tools
inetutils-traceroute, iputils-tracepath, mtr...
