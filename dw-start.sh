#!/bin/sh

# Example script to compare old and new direcolf config files after updating APRS objects and restart or start Direwolf

dwdir=/opt/direwolf
config=/opt/direwolf/direwolf.conf
template=/opt/direwolf/direwolf.template

cd $dwdir

# Check to see if direwolf is already running, if so, see if we have an update config file
pid=$(pgrep -c direwolf)
if [ $pid -gt 0 ]; then
    # Generate a fresh direwolf configuration file
    mv $config ${config}.bak
    cat $template >$config
    perl aprs.pl >>$config

    # Get md5sum's of the configuration files to see if they changed
    origsum=`md5sum ${config}.bak | cut -f 1 -d " "`
    newsum=`md5sum ${config} | cut -f 1 -d " "`

    # If changed, kill direwolf, otherwise exit script
    if [ "$origsum" != "$newsum" ]; then
        echo "md5sums are different [${origsum}] [${newsum}], killing direwolf"
        killall direwolf
        sleep 5 
    else
        echo "Config files match, exiting dw-start script"
        exit
        fi
fi
    
# Direwolf is not running, so generate a fresh direwolf configuration file and run it
mv $config ${config}.bak
cat $template >$config
perl aprs.pl >>$config

# Check our return code; if it's non-zero let's revert to our previous config file
rc=$?

if [ $rc != 0 ]; then
    echo "APRS Script failed, reverting"
    mv ${config}.bak $config
fi

# Start Direwolf
/usr/local/bin/direwolf -t 0 -c $config >/opt/direwolf/logs/direwolf.log
