VirtualPC container for GNS3
=======================

The goal is to take profit of docker containers to use inside GNS3 almost as a full-fledged linux endhost instead of
using the very limited VPCS or an overkill virtual machine.

This includes a script to manage containers and set networking parameters using pipework.

Requirements
------------------------------
1.Docker [easy to install](https://docs.docker.com/installation/ubuntulinux/)

> docker -v
> Docker version 1.8.1, build d12ea79  
 
2.pipework, a simple yet powerful bash script, for advanced docker networking  
> sudo bash -c “curl https://raw.githubusercontent.com/jpetazzo/pipework/master/pipework > /usr/local/bin/pipework”


To use docker as non-root user
> sudo usermod -aG docker {user}

Otherwise, precede all “docker” commands (terminal and scripts) with sudo.


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
Some examples of playing with the containers remotely through SSH:  
  
Having SSHd enabled on the containers  
> /usr/sbin/sshd  
  
From the host send command through SSd  
> ssh root@172.17.0.1 ‘ip a’  
  
Remotely interact with the command:  
> ssh -t root@172.17.0.1 ‘top’  
  
Send multiple commands:  
> ssh root@172.17.0.1 ‘ip a; ps -aux; whoami’  

Example of using ansible to send a command on multiple containers

ex: Start Apache on all containers

1- Add container IP addresses in /etc/ansible/hosts

> [containers]  
> 172.17.0.1  
> 172.17.0.2  

2- ~/DockerVPC$ **ansible containers -i /etc/ansible/hosts -m command -a “/usr/sbin/apachectl start” -u root**  
> The authenticity of host ‘172.17.0.1 (172.17.0.1)’ can’t be established.  
> ECDSA key fingerprint is 60:e4:db:26:ac:0c:26:fe:53:0e:b1:86:12:28:55:35.  
> Are you sure you want to continue connecting (yes/no)? yes  
> The authenticity of host ‘172.17.0.2 (172.17.0.2)’ can’t be established.  
> ECDSA key fingerprint is 60:e4:db:26:ac:0c:26:fe:53:0e:b1:86:12:28:55:35.  
> Are you sure you want to continue connecting (yes/no)? yes  
> 172.17.0.1 | success | rc=0 >>  
>   
>   
> 172.17.0.2 | success | rc=0 >>  


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
#### <i class="icon-folder-open"></i> vSFTPd server & ftp client

On the server container create a user  
> root@vsftpd1:/# ***adduser user1***  
> Adding user `user1’ ...  
> Adding new group `user1’ (1001) ...  
> Adding new user `user1’ (1001) with group `user1’ ...  
> Creating home directory `/home/user1’ ...  
> Copying files from `/etc/skel’ ...  
> Enter new UNIX password:   
> Retype new UNIX password:   
> passwd: password updated successfully  
> Changing the user information for user1  
> Enter the new value, or press ENTER for the default  
>   Full Name []:   
>   Room Number []:   
>   Work Phone []:   
>   Home Phone []:   
>   Other []:   
> Is the information correct? [Y/n] ***Y***  
> root@vsftpd1:/#   
  
Enable sftpd:  
> root@vsftpd1:/# /usr/sbin/vsftpd  
  
On the client container:  
(X.X.X.X being the IP of the server container)  
  
> root@pc1:/# ***ftp -n 172.17.0.48***  
> Connected to 172.17.0.48.  
> 220 (vsFTPd 3.0.2)  
> ftp> ***user***  
> (username) ***user1***  
> 331 Please specify the password.  
> Password:   
> 230 Login successful.  
> Remote system type is UNIX.  
> Using binary mode to transfer files.  
> ftp> ***ls -a***  
> 200 PORT command successful. Consider using PASV.  
> 150 Here comes the directory listing.  
> drwxr-xr-x    2 1001     1001         4096 Aug 07 06:48 .  
> drwxr-xr-x    5 0        0            4096 Aug 07 07:04 ..  
> -rw-r--r--    1 1001     1001          220 Aug 07 06:48 .bash_logout  
> -rw-r--r--    1 1001     1001         3637 Aug 07 06:48 .bashrc  
> -rw-r--r--    1 1001     1001          675 Aug 07 06:48 .profile  
> 226 Directory send OK.  
> ftp> ***pwd***  
> 257 “/home/user1”  
> ftp>   


-------------
#### <i class=”icon-folder-open”></i> And many other tools
inetutils-traceroute, iputils-tracepath, mtr...i


References:
--------------------
https://registry.hub.docker.com/u/odiobill/vsftpd/
https://registry.hub.docker.com/u/jess/

