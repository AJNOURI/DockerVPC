VirtualPC container for GNS3
=======================

The goal is to take profit of docker containers to use inside GNS3 almost as a full-fledged linux endhost instead of
using the very limited VPCS or an overkill virtual machine.

This includes a script to manage containers and set networking parameters using pipework.



Build VirtualPC image
------------------------------
Before building the image, make sure to copy your public key to the the repository directory:

> cp /home/user/.ssh/id_rsa.pub id_rsa.pub

or generate a special key pair:

> ssh-keygen -t rsa


Now, build the image using the following command:

> sudo docker build -t   {image-tag}  {location-of-Dockerfile}

ex:

>sudo docker build -t gns3pc .

The image will be used to run any number of container with the same content:


Start a container from the built image
------------------------------
>~/DockerVPC$  **./startvpc.sh gns3pc pc1**  
>Spawning a new container  
>non-network local connections being added to access control list  
>Container networking... \n  
>Continue? [Yy] [Nn] **y**  
>Enter Host bridge to connect the container to => **br10**  
>Enter a new interface inside the container to connect to host bridge => **eth1**  
>Enter IP address (without mask) for the container interface => **192.168.10.1**  
>Enter the mask length => **24**  
>Enter the next-hop IP (GNS3 device) => **192.168.10.254**  
>br10 doesn’t exist  
>command: >> sudo pipework br10 -i eth1 a62dfeff0205 192.168.10.1/24@192.168.10.254 << successfully executed.  
>Continue with network configuration[Cc], or quit[Qq]?  **q**  
>~/DockerVPC$  




Included tools in the image
------------------------------
These tools included in the image are available in all generated containers.

> **Tip:** You can install other tools if you make the container reach Internet, either directly through host docker0 interface, or by connecting it to your GNS3 
topology.
> Nevertheless, the container VirtualPC is as flexible as a Docker container can be. 
Docker container technology is developing very fast, so this image will be subject to changes as container capabilities grow.



#### <i class="icon-folder-open"></i> SSH server to connect to the Virtual PC from the host
Docker copies your public from the repository directory into the built image to be used in all containers run from it.

From the container, start SSHd: 

> /usr/sbin/sshd

From your Docker host, ssh to the container IP X.X.X.X: 

> ssh root@X.X.X.X



------------------------------
#### <i class="icon-folder-open"></i> Apache server
#####- Apache server 
Start Apache server:

> /usr/sbin/apachectl start

From another container connect to the server using ***curl*** or ***links2***

-------------
#### <i class="icon-folder-open"></i> Traffic generation tools
##### **- Ostinato**
From the running container, start the server component of Ostinato “drone” in the background, so you can 
continue to use the terminal: 
>drone &

From Docker host (Your Desktop OS), start Ostinato client GUI and connect to containers IP running drone.
##### - **D-ITG**
Example from [D-ITG official documentation](http://traffic.comics.unina.it/software/ITG/manual/index.html#SECTION00051000000000000000)

Single UDP flow with constant inter-departure time between packets and constant packets size:
start the receiver on the destination host (10.0.0.3):
>$ ./ITGRecv

start the sender on the source host (10.0.0.4):

>$ ./ITGSend -a 10.0.0.3 -sp 9400 -rp 9500 -C 100 -c 500 -t 20000 -x recv_log_file


##### - **iperf**

-------------
#### <i class="icon-folder-open"></i> VoIP applications
##### **sipp (text-based)**
##### **pjsua (text-based)**
##### **linphone (text + GUI)**

-------------
#### <i class="icon-folder-open"></i> IPv6 THC tools


-------------
#### <i class="icon-folder-open"></i> VLC (VideoLAN)
Simply start vlc with username vlc in background 

> su -c “vlc” -s /bin/sh vlc &

**/media** directory contains small video files in multiple formats to play with.

-------------
#### <i class="icon-folder-open"></i> Links2 browser
A minimalistic browser (text+graphic mode).
Text mode: 

> links <_url_>

Graphic mode: 

> links2 -g <_url_>

-------------
#### <i class=”icon-folder-open”></i> And many other tools
inetutils-traceroute, iputils-tracepath, mtr...
