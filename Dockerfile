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
RUN apt-get install -y apache2
RUN apt-get install php5 libapache2-mod-php5 w3m -y
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf

# PHP Server (for IP detection)
RUN apt-get install php5 libapache2-mod-php5
ADD ./index.php /var/www/html/index.php

# Enable SSH loging provided by Baseimage docker and regenerate keys
RUN rm -f /etc/service/sshd/down
RUN /etc/my_init.d/00_regen_ssh_host_keys.sh
RUN mkdir -p /root/.ssh
#ADD id_rsa.pub /tmp/id_rsa.pub
#RUN cat /tmp/id_rsa.pub >> /root/.ssh/authorized_keys && rm -f /tmp/id_rsa.pub

# Permanently enable the insecure-key
RUN /usr/sbin/enable_insecure_key

RUN echo 'root:gns3vpc' | chpasswd
RUN sed -i "s/#PermitRootLogin without-password/PermitRootLogin yes/" /etc/ssh/sshd_config
# SSH login fix. Otherwise user is kicked off after loging
#RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

#ENV NOTVISIBLE "in users profile"
#RUN echo "export VISIBLE=now" >> /etc/profile


# Miscellaneous tools
RUN sudo apt-get install -y iperf inetutils-traceroute iputils-tracepath \
mtr dnsutils sip-tester build-essential sip-tester tcpdump packeth libasound2-dev libpcap-dev libssl-dev \
libnetfilter-queue-dev qupzilla openjdk-7-jdk icedtea-plugin gstreamer1.0* libreadline6 \
libreadline6-dev autoconf flex bison libncurses5-dev libncursesw5-dev

# Install BIRD internet routing
RUN wget ftp://bird.network.cz/pub/bird/bird-1.5.0.tar.gz && tar -zxvf bird-1.5.0.tar.gz && rm bird-1.5.0.tar.gz
WORKDIR bird-1.5.0
RUN ./configure && make && make install

# Install IPv6-THC tool
WORKDIR /
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

# Install other packages 
RUN apt-get install wireshark linphone vlc links2 -y

# Copy media files to use with vlc
ADD ./media/small.3gp /media/small.3gp
ADD ./media/small.flv /media/small.flv
ADD ./media/small.mp4 /media/small.mp4
ADD ./media/small.ogv /media/small.ogv
ADD ./media/small.webm /media/small.webm

# Add user vlc for VideoLAN to work.
ENV HOME /home/vlc
RUN useradd --create-home --home-dir $HOME vlc \
    && chown -R vlc:vlc $HOME \
    && chown -R vlc:vlc /media \
    && usermod -a -G audio,video vlc

# Install ftp client & server
RUN apt-get install -y vsftpd ftp

# Enable local users  + disable anonymous
RUN echo "local_enable=YES" >> /etc/vsftpd.conf
RUN sed -i "s/anonymous_enable=YES/anonymous_enable=NO/" /etc/vsftpd.conf
# enable users to write to their own directory
RUN echo "write_enable=YES" >> /etc/vsftpd.conf
RUN echo "chroot_list_file=/etc/vsftpd.chroot_list"  >> /etc/vsftpd.conf
RUN mkdir -p /var/run/vsftpd/empty
# Set default file permission for directory to 755 and files to 644
RUN echo "local_umask=022" >> /etc/vsftpd.conf


WORKDIR /

#CMD /bin/bash

# Clean up APT
RUN apt-get clean && rm -rf /var/lib/apt/lists/*
