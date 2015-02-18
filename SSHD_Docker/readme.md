###### Build the image
sudo docker build -t ajn_sshd .

###### Run a ajn_sshd container
sudo docker run -d -P --name sshd1 ajn_sshd

###### You can then use docker port to find out what host port the container's port 22 is mapped to:
sudo docker port sshd1 22
