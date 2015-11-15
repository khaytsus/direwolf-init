#!/usr/bin/perl

# Determine the PPM from an rtl_power csv file
# Command line arguments are as follows
#  ppm - ppm used for rtl_power run
#  target - target frequency we're using to find a peak on
#  file - csv file output by rtl_power
#  terse - set to 1 to output only ppm value

# Example:  Use 162.400 as that's a strong NOAA channel and it's stable
# rtl_power -c .1 -f 162.39M:162.41M:64 -i 2 -g 10 -p 80 -e 10m noaa.csv
# findppm.pl 80 162400000 noaa.csv
# Output:  Best PPM is 63
# Output verified in gqrx is 63.
# For terse output, set terse to 1, output will just be the numeric ppm
#  for use in scripts

# Known Limitation - If you use a very wide carrier with an even strength
# signal, this script might determine the right PPM is at the bottom of the
# carrier.  Logically, the middle would be more appropriate.  But this script
# simply finds the best signal and uses the best one it finds.  Narrow signals
# and sane gain settings are suggested.

# Get command-line arguments
my $ppm = $ARGV[0];
my $target = $ARGV[1];
my $file = $ARGV[2];
my $terse = $ARGV[3];

# Exit if we didn't get all of our arguments
if ( $file eq "" ) { die "$0 ppm targethz filename\n"; }

# Step in hz per ppm change
my $ppmstep = $target / 1000000;

# Get the last line of the csv file, presumably the best/most warmed up
my $lastline = "";

open(IN,"<",$file) || die "Could not open $file\n";
foreach $line (<IN>)
{
	chomp($line);
	$lastline = $line;
}

# Create an array out of the last csv file line and get some stuff out of it
my @linearray = split(',',$lastline);
my $low = $linearray[2];
my $step = $linearray[4];

# Get rid the columns which don't contain sample data
splice @linearray, 0, 5;

# Find number of elements and iterate through the array to find the highest value
my $elements = @linearray;

my $bestdb = -200;
my $bestdbcol = 0;

for (my $i=7; $i < $elements; $i++)
{
	if ($linearray[$i] > $bestdb)
	{
		$bestdb = $linearray[$i];
		$bestdbcol = $i;
	}
}

# Calculate how far away we are from the ppm we're currently using
my $ppmchange = round(( $target - ( $low + ($step * $bestdbcol) ) ) / $ppmstep);

# Calculate the ppm we should be using
my $finalppm = $ppm + $ppmchange;

if ($terse)
{
	print "$finalppm";
}
else
{
	print "Best PPM is $finalppm\n";
}

exit;

# Round a value
sub round
{
	$_[0] > 0 ? int($_[0] + .5) : -int(-$_[0] + .5)
}
