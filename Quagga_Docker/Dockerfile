
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

# try ssh by default with basedocker

# install tools
#RUN apt-get install -y openssh-server
#RUN mkdir -p /var/run/sshd

# install quagga
RUN apt-get install -y quagga telnet

# enable daemons
RUN sed -i 's/=no/=yes/g' /etc/quagga/daemons

# ip forwarding is enabled by default

# copy the default configs for the routing daemons
# TODO: replace this with using ADD for local files
RUN cp /usr/share/doc/quagga/examples/*.sample /etc/quagga/
RUN echo "for curFile in /etc/quagga/*.sample; do mv \"\$curFile\" \"\${curFile:0:-7}\"; done" | bash
RUN echo VTYSH_PAGER=more > /etc/environment
#ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf 

RUN mkdir /etc/service/quagga
ADD quagga.sh /etc/service/quagga/run
CMD ["/etc/init.d/quagga","start"]
#entrypoint ["/etc/init.d/quagga"]

# expose ssh, bgp and quagga management ports
EXPOSE 22 179 2601 2602 2603 2604 2605 2606
