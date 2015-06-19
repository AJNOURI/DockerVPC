
Apache server
/usr/sbin/apachectl start

From a another host
curl <container_IP>
or 
browser (Desktop OS)


From container you want to control, start the server component of Ostinato “drone” in the background, so you can continue to use the terminal:
drone &

From Docker host (Desktop OS), you start Ostinato client GUI:
Type:
ostinato
and connect to containers IP running drone

SSH access to the container:
You can use your host keypairs
cp /home/<user>/.ssh/id_rsa.pub id_rsa.pub

or generate keypair in the current directory (where Dockerfile is located) for use with SSH to container:


From the container, start SSHd:
/usr/sbin/sshd

From Docker host:
ssh root@<container_IP>
