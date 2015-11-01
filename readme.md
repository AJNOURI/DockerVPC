VirtualPC container for GNS3
=======================
Tested platforms: ***Ubuntu, OpenSuse, Redhat***

The goal is to take profit of docker containers to use inside GNS3 almost as a full-fledged linux endhost instead of
using the very limited VPCS or an overkill virtual machine.

This includes a script to manage containers and set networking parameters using pipework.

Requirements
------------------------------
You will need: git, docker, pipework and lxterminal.

1.git  
> sudo apt-get install git  

2.Docker [easy to install](https://docs.docker.com/installation/ubuntulinux/)  
> docker -v  
> Docker version 1.8.1, build d12ea79  
 
3.pipework, a simple yet powerful bash script, for advanced docker networking  
> sudo bash -c “curl https://raw.githubusercontent.com/jpetazzo/pipework/master/pipework > /usr/local/bin/pipework”  
> sudo chmod a+x /usr/local/bin/pipework  

4.lxterminal  
> sudo apt-get install lxterminal  

To use docker as non-root user
> sudo usermod -aG docker {user}



Pull images from DockerHub
------------------------------
The script will automatically pull the latest iused images from DockerHUb, if they do not exist locally.

You can do it manually If you want:
> docker pull ajnouri/dockervpc
> docker pull quantumobject/docker-cacti
> docker pull socketplane/openvswitch


Manually Build DockerVPC image
------------------------------
After cloning the repository you can modify Dockerfile, to add your own tools or alleviate it, and rebuild it manually.
Clone the repository  

> git clone https://github.com/AJNOURI/DockerVPC  
> cd DockerVPC  

If you want to use public keys for SSH authentication you will have to generate or copy your own public key in the repository directory and build the image manually.

> cp /home/user/.ssh/id_rsa.pub id_rsa.pub

or generate a special key pair:

> ssh-keygen -t rsa


Now, build the image using the following command:

> sudo docker build -t  {image-tag} {location-of-Dockerfile}

ex:  

>sudo docker build -t dockervpc .  

The image will be used to run any number of container with the same content:


Start a container  
------------------------------
>~/DockerVPC$  **./startvpc.sh dockervpc pc1**  
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



#### <i class="icon-folder-open"></i> SSH server
 **Connect to the container using password-chalenge**  

- Start SSHD on the server container  
root@pc2:/# /usr/sbin/sshd    
>The default SSH password for user ***root*** is ***gns3vpc***

- From gns3 host  
$ ssh root@172.17.0.3  
>The authenticity of host '172.17.0.3 (172.17.0.3)' can't be >established.
>ECDSA key fingerprint is >af:c3:85:55:5e:f5:66:cd:b5:99:8b:85:05:c5:27:42.
>Are you sure you want to continue connecting (yes/no)? yes
>Failed to add the host to the list of known hosts (/home/ajn/.ssh/known_hosts).
>root@172.17.0.3's password: 
>Last login: Sat Oct 17 14:42:30 2015 from 172.17.42.1
>root@pc2:~#   

- From another container  
root@pc1:/# ssh root@192.168.22.1  
>root@192.168.22.1's password: 
>Last login: Sat Oct 17 14:45:16 2015 from 172.17.42.1
>root@pc2:~# 

------------------------------
**Example of using ansible to manage multiple DockerVPCs**

Let's start Apache on multiple containers

- Add container IP addresses in /etc/ansible/hosts
> [containers]  
> 172.17.0.1  
> 172.17.0.2  

- $ ansible containers -i /etc/ansible/hosts -m command -a “/usr/sbin/apachectl start” -u root  
> The authenticity of host ‘172.17.0.1 (172.17.0.1)’ can’t be established.  
> ECDSA key fingerprint is 60:e4:db:26:ac:0c:26:fe:53:0e:b1:86:12:28:55:35.  
> Are you sure you want to continue connecting (yes/no)? yes  
> The authenticity of host ‘172.17.0.2 (172.17.0.2)’ can’t be established.  
> ECDSA key fingerprint is 60:e4:db:26:ac:0c:26:fe:53:0e:b1:86:12:28:55:35.  
> Are you sure you want to continue connecting (yes/no)? yes  
> 172.17.0.1 | success | rc=0 >>  
> 172.17.0.2 | success | rc=0 >>  




------------------------------
#### <i class="icon-folder-open"></i> Qupzilla browser

- More lightweight than Firefox and supports Java and html5, but still troubleshooting flash support.  
Just start it:   
> qupzilla &

-------------
#### <i class="icon-folder-open"></i> Apache server
- Start Apache server:

> /usr/sbin/apachectl start

- From another container connect to the server using ***curl*** , ***links2*** or ***Qupzilla***.

-------------
#### <i class="icon-folder-open"></i> Traffic generation tools
##### **- Ostinato**
- From the running container, start the server component of Ostinato “drone” in the background, so you can 
continue to use the terminal: 
>drone &

- From Docker host (Your Desktop OS), start Ostinato client GUI and connect to containers IP running drone.
##### - **D-ITG**
- Single UDP flow with constant inter-departure time between packets and constant packets size:  
start the receiver on the destination host (10.0.0.3):
>$ ./ITGRecv

- start the sender on the source host (10.0.0.4):
>$ ./ITGSend -a 10.0.0.3 -sp 9400 -rp 9500 -C 100 -c 500 -t 20000 -x recv_log_file


##### - **iperf**
- on the destination container (ex: 192.168.22.1):
>iperf -s  

- on the source container:  
>iperf -c 192.168.22.1

-------------
#### <i class="icon-folder-open"></i> VoIP applications
##### **sipp (text-based)**
##### **pjsua (text-based)**
##### **linphone (text + GUI)**

-------------
#### <i class="icon-folder-open"></i> IPv6 THC tools


-------------
#### <i class="icon-folder-open"></i> VLC (VideoLAN)
- Simply start vlc with username vlc in background 

> su -c “vlc” -s /bin/sh vlc &  

**/media** directory contains small video files in multiple formats to play with.

-------------
#### <i class="icon-folder-open"></i> Links2 browser
- A minimalistic browser (text+graphic mode).  
Text mode: 

> links <_url_>

- Graphic mode: 

> links2 -g <_url_>

-------------
#### <i class="icon-folder-open"></i> vSFTPd server & ftp client

- On the server container create a user  
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
  
- Enable sftpd:  
> root@vsftpd1:/# /usr/sbin/vsftpd  
  
- On the client container:  
(ex: 172.17.0.48 is IP of the server container)  
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
https://github.com/alexismp/OpenJDK-Docker/blob/master/debian/Dockerfile
