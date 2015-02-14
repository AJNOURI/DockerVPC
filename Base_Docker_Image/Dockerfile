# Use phusion/baseimage as base image. To make your builds
# reproducible, make sure you lock down to a specific version, not
# to `latest`! See
# https://github.com/phusion/baseimage-docker/blob/master/Changelog.md
# for a list of version numbers.
FROM phusion/baseimage:latest

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

# ...put your own build instructions here...

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


# wget https://iperf.fr/download/iperf_2.0.5/iperf_2.0.5-2_i386 ; chmod +x iperf_2.0.5-2_i386 ; sudo mv iperf_2.0.5-2_i386 /usr/bin/iperf
# mtr
# nc
# nmap: apt-get  --yes --force-yes install nmap
# nload
# iftop : apt-get --yes --force-yes install iftop
# iptraf:
# bmon
# nethogs
# tcptrack
# curl

