#!/bin/bash

[ $(id -u) -ne 0 ] && sudo ./$0 && exit 0

dpkg -s rtpmdump || apt-get install rtmpdump

iptables -t nat -A OUTPUT -p tcp --dport 1935 -j REDIRECT

rtmpsrv

#rtmpdump -r "rtmp://livestream.someaddress.com/live/" -a "live/" -f "LNX 11,6,602,171" -W "https://www.someaddress.org/live/player.swf" -p "http://live.tv/" -y "nnnnnn.sdp" -o nnnnnn.flv

iptables -t nat -D OUTPUT -p tcp --dport 1935 -j REDIRECT
