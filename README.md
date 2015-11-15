Small collection of scripts used to automate starting and calibrating PPM for
running Direwolf on my Raspberry Pi.

Problem:  RTL-SDR sticks the PPM varies as the temperature changes, and decoding
APRS requires the PPM to be pretty close, probably within 2-3 or you'll have
issues decoding.

Solution:  Using NOAA1 as a source, I use rtl_power to find the best signal
and then figure out what the correct PPM is based on that, and use that new
PPM.

I have a cron which runs the dw-start script every 5 minutes (in case the Pi has
rebooted, etc) and once an hour (at the 00 minute mark) this startup script
will run the calibration.  Other runs will use the last calibration determined
which is output to a file which is sourced at the top to be used.

Files:

dw-start - Script which is ran every 5 minutes
findppm.pl - Perl script which determines the best PPM
direwolf.sh - Script which actually starts direwolf

Each script is commented and hopefully clear what they each are doing.  I hope
this is useful for someone else.
