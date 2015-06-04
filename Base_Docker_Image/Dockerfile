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
RUN apt-get update && apt-get install -y wget

# Miscellaneous tools
RUN sudo apt-get install -y iperf inetutils-traceroute iputils-tracepath \
mtr dnsutils sip-tester build-essential sip-tester tcpdump packeth libasound2-dev

WORKDIR /tmp

# Some useful .pcap .xml files for voip testing
RUN wget hpnouri.free.fr/sip/dtmf_2833_1.pcap
RUN wget hpnouri.free.fr/sip/g711a.pcap
RUN wget http://sipp.sourceforge.net/doc/uac.xml
RUN wget http://sipp.sourceforge.net/doc/uac_pcap.xml

# Copy these files from host local directoy to /tmp
#ADD dtmf_2833_1.pcap /tmp/dtmf_2833_1.pcap
#ADD g711a.pcap /tmp/g711a.pcap
#ADD uac.xml /tmp/uac.xml
#ADD uac_pcap.xml /tmp/uac_pcap.xml

# Adjust to the new file location inside xml files (sipp)
RUN sed -i 's/pcap\/g711a.pcap/\/tmp\/g711a.pcap/g' uac_pcap.xml
RUN sed -i 's/pcap\/dtmf_2833_1.pcap/\/tmp\/dtmf_2833_1.pcap/g' uac_pcap.xml

# install pjsua voip testing tool
# executable to use: /tmp/pjproject-2.3/pjsip-apps/bin/pjsua-x86_64-unknown-linux-gnu
RUN wget http://www.pjsip.org/release/2.3/pjproject-2.3.tar.bz2
RUN tar -jxvf pjproject-2.3.tar.bz2
WORKDIR pjproject-2.3/
RUN ./configure && make dep && make clean && make

# Clean up APT
RUN apt-get clean && rm -rf /var/lib/apt/lists/*
