#!/bin/sh

ppm=$1
gain=$2
noupdate=$3

dwpath="/opt/direwolf"

netstat -nap | grep "LISTEN " >/tmp/netstat.log

# Set our config file and update objects and other settings
config=${dwpath}/direwolf.conf

PARENT_COMMAND="$(ps -o comm= $PPID)"
# Only run APRS objects script if we're not coming from cron
if [ "$PARENT_COMMAND" != "run-parts" ]; then
	source ${dwpath}/updateobjects.sh
fi

mkdir -p /var/tmp/direwolf/

# Without a ppm/gain argument, we assume we're using audio
if [ "$ppm" == "" ]; then
	# Using a real radio
	/usr/local/bin/direwolf -t 0 -c $config >${dwpath}/logs/direwolf.log
else
	# Using an SDR
	/usr/local/bin/rtl_fm -f 144390000 -s 44100 -p $ppm -g $gain | /usr/local/bin/direwolf -t 0 -c ${dwpath}/direwolf-sdr.conf >${dwpath}/logs/direwolf.log
fi
