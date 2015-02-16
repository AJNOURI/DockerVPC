# Use phusion/baseimage as base image. To make your builds
# reproducible, make sure you lock down to a specific version, not
# to `latest`! See
# https://github.com/phusion/baseimage-docker/blob/master/Changelog.md
# for a list of version numbers.
FROM phusion/baseimage:0.9.16

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

# Prepare Installation
WORKDIR /tmp

# Update the source list for appropriate repository, trusty 12.04 LTS, in this case.
RUN echo "deb http://fr.archive.ubuntu.com/ubuntu/ trusty main" >> /etc/apt/sources.list
RUN echo "deb-src http://fr.archive.ubuntu.com/ubuntu/ trusty main universe" >> /etc/apt/sources.list
RUN echo "deb http://fr.archive.ubuntu.com/ubuntu/ trusty-security main" >> /etc/apt/sources.list
RUN echo "deb http://fr.archive.ubuntu.com/ubuntu/ trusty-updates main" >> /etc/apt/sources.list
RUN echo "deb-src http://fr.archive.ubuntu.com/ubuntu/ trusty-security main universe" >> /etc/apt/sources.list
RUN echo "deb-src http://fr.archive.ubuntu.com/ubuntu/ trusty-updates main universe" >> /etc/apt/sources.list
RUN apt-get update
RUN sudo apt-get Install -y wget

# Tools
RUN sudo apt-get install -y iperf
RUN sudo apt-get install -y inetutils-traceroute
RUN sudo apt-get install mtr

# Apache
RUN sudo apt-get install -y apache2
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf
/usr/sbin/apachectl restart

# Clean up APT
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
