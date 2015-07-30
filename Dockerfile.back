# Use phusion/baseimage as base image. To make your builds
# reproducible, make sure you lock down to a specific version, not
# to `latest`! See
# https://github.com/phusion/baseimage-docker/blob/master/Changelog.md
# for a list of version numbers.
FROM phusion/baseimage:0.9.16

# Use baseimage-docker's init system.
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
RUN apt-get update && apt-get install -y wget git zip

# Apache server
RUN sudo apt-get install -y apache2
RUN apt-get install php5 libapache2-mod-php5 w3m -y
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf
RUN /usr/sbin/apachectl restart


# Enable SSH loging provided by Baseimage docker and regenerate keys
RUN rm -f /etc/service/sshd/down
RUN /etc/my_init.d/00_regen_ssh_host_keys.sh
RUN mkdir -p /root/.ssh
ADD id_rsa.pub /tmp/id_rsa.pub
RUN cat /tmp/id_rsa.pub >> /root/.ssh/authorized_keys && rm -f /tmp/id_rsa.pub


# Miscellaneous tools
RUN sudo apt-get install -y iperf inetutils-traceroute iputils-tracepath \
mtr dnsutils sip-tester build-essential sip-tester tcpdump packeth libasound2-dev libpcap-dev libssl-dev

# Install IPv6-THC tool
RUN git clone https://github.com/vanhauser-thc/thc-ipv6
WORKDIR thc-ipv6/
RUN make && make install

# Install Ostinato traffic generator
# from the container use "drone" to start the server
# from docker host use "ostinato" to start GUI client
RUN apt-get install -y ostinato

# Install VoIP tools
WORKDIR /tmp

# Copy some useful files from host local directoy to /tmp
ADD ./voip/dtmf_2833_1.pcap /tmp/dtmf_2833_1.pcap
ADD ./voip/g711a.pcap /tmp/g711a.pcap
ADD ./voip/uac.xml /tmp/uac.xml
ADD ./voip/uac_pcap.xml /tmp/uac_pcap.xml

# Adjust to the new file location inside xml files (sipp)
RUN sed -i 's/pcap\/g711a.pcap/\/tmp\/g711a.pcap/g' uac_pcap.xml
RUN sed -i 's/pcap\/dtmf_2833_1.pcap/\/tmp\/dtmf_2833_1.pcap/g' uac_pcap.xml

# install pjsua voip testing tool
# executable to use: /tmp/pjproject-2.3/pjsip-apps/bin/pjsua-x86_64-unknown-linux-gnu
RUN wget http://www.pjsip.org/release/2.3/pjproject-2.3.tar.bz2
RUN tar -jxvf pjproject-2.3.tar.bz2
RUN rm pjproject-2.3.tar.bz2
WORKDIR pjproject-2.3/
RUN ./configure && make dep && make clean && make

# Install Ostinato
RUN apt-get install -y ostinato

# Install D-ITG
WORKDIR /
RUN wget http://traffic.comics.unina.it/software/ITG/codice/D-ITG-2.8.1-r1023-src.zip
RUN unzip D-ITG-2.8.1-r1023-src.zip
RUN rm D-ITG-2.8.1-r1023-src.zip
WORKDIR /D-ITG-2.8.1-r1023/src
RUN make && make install PREFIX=/usr/local

RUN apt-get install linphone vlc links2 -y

WORKDIR /tmp
ADD ./media/small.3gp /tmp/small.3gp
ADD ./media/small.flv /tmp/small.flv
ADD ./media/small.mp4 /tmp/small.mp4
ADD ./media/small.ogv /tmp/small.ogv
ADD ./media/small.webm /tmp/small.webm

WORKDIR /

CMD /bin/bash

#EXPOSE 22 80 7878

# Clean up APT
#RUN apt-get clean && rm -rf /var/lib/apt/lists/*
