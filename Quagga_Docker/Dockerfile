
# Using special Docker image that automatically handles important system processes.
# For more inf.
# http://phusion.github.io/baseimage-docker/
# https://github.com/phusion/baseimage-docker
FROM phusion/baseimage:0.9.16
MAINTAINER AJ NOURI <ajn.bin@gmail.com>
# Originally from https://github.com/fredhsu/docker-quagga

# Use baseimage-docker's init system to handle container processes.
CMD ["/sbin/my_init"]

# Tell debconf to run in non-interactive mode
ENV DEBIAN_FRONTEND noninteractive


# Update the source list for appropriate repository, trusty 14.04 LTS, in this case.
# Generated from:
# https://wiki.ubuntu.com/DevelopmentCodeNames
# http://repogen.simplylinux.ch/

RUN echo "deb http://fr.archive.ubuntu.com/ubuntu/ trusty main" >> /etc/apt/sources.list
RUN echo "deb-src http://fr.archive.ubuntu.com/ubuntu/ trusty main universe" >> /etc/apt/sources.list
RUN echo "deb http://fr.archive.ubuntu.com/ubuntu/ trusty-security main" >> /etc/apt/sources.list
RUN echo "deb http://fr.archive.ubuntu.com/ubuntu/ trusty-updates main" >> /etc/apt/sources.list
RUN echo "deb-src http://fr.archive.ubuntu.com/ubuntu/ trusty-security main universe" >> /etc/apt/sources.list
RUN echo "deb-src http://fr.archive.ubuntu.com/ubuntu/ trusty-updates main universe" >> /etc/apt/sources.list
RUN apt-get update && apt-get install -y wget

# Enable SSH loging provided by Baseimage docker and regenerate keys
RUN rm -f /etc/service/sshd/down
RUN /etc/my_init.d/00_regen_ssh_host_keys.sh
RUN mkdir -p /root/.ssh
ADD id_rsa.pub /tmp/id_rsa.pub
RUN cat /tmp/id_rsa.pub >> /root/.ssh/authorized_keys && rm -f /tmp/id_rsa.pub


# install tools


# install quagga
RUN apt-get install -y quagga telnet

# enable daemons
RUN sed -i 's/=no/=yes/g' /etc/quagga/daemons

# copy the default configs for the routing daemons
# TODO: replace this with using ADD for local files
RUN cp /usr/share/doc/quagga/examples/*.sample /etc/quagga/

RUN echo "for curFile in /etc/quagga/*.sample; do mv \"\$curFile\" \"\${curFile:0:-7}\"; done" | bash
RUN echo VTYSH_PAGER=more >> /etc/environment
RUN echo export VTYSH_PAGER=more >> /etc/bash.bashrc

# forward babeld debug logging to a file
RUN sed -i 's/log stdout/\!log stdout/g' /etc/quagga/babeld.conf
RUN sed -i 's/\!log file/log file/g' /etc/quagga/babeld.conf

RUN mkdir /etc/service/quagga
ADD quagga.sh /etc/service/quagga/run
CMD ["/etc/init.d/quagga","start"]
#entrypoint ["/etc/init.d/quagga"]


# Map a container directory to Docker host directory (not in the other direction)
VOLUME /etc/quagga/

# expose ssh, bgp and quagga management ports
EXPOSE 179 2601 2602 2603 2604 2605 2606
