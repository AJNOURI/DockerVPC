VirtualPC container for GNS3
=======================

The goal is to take profit of docker containers to useinside GNS3 as aslmost a fill-fledged linux end host instead of using the very limited VPCS or an overkill virtual machine.

This includes a script to manage containers and set networking parameters using pipework.

Included tools
-------------
#### <i class="icon-folder-open"></i> Apache server
Apache server /usr/sbin/apachectl start

From a another host curl or browser (Desktop OS)

#### <i class="icon-folder-open"></i> Ostinato traffic generator
From container you want to control, start the server component of Ostinato “drone” in the background, so you can continue to use the terminal: drone &

From Docker host (Desktop OS), you start Ostinato client GUI: Type: ostinato and connect to containers IP running drone

#### <i class="icon-folder-open"></i> SSH server to connect to connect to the Virtual PC from the host
SSH access to the container: You can use your host keypairs cp /home//.ssh/id_rsa.pub id_rsa.pub

or generate keypair in the current directory (where Dockerfile is located) for use with SSH to container:

From the container, start SSHd: /usr/sbin/sshd

From Docker host: ssh root@

#### <i class="icon-folder-open"></i> VLC (VideoLAN)
Simply type vlc & for backgroud so you still have access to terminal. Small video files in different formats are provided for streaming testing.

#### <i class="icon-folder-open"></i> Links2 browser

Text mode: links <_url_>

Graphic mode links2 -g <_url_>

