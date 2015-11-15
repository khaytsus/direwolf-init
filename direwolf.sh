#!/bin/sh

ppm=$1
gain=$2

/usr/local/bin/rtl_fm -f 144390000 -s 44100 -p $ppm -g $gain | /usr/local/bin/direwolf -t 0 -c /opt/direwolf/direwolf.conf >/tmp/direwolf.log
