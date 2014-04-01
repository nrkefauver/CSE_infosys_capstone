#!/usr/bin/perl
#############################################
#	Facebook account finder proof of concept
#	AUTHOR:		Tracy Parsons
#	VERSIONS:	0.0.1: 1/30/2014
#				0.1.0: 2/3/2014
#				0.2.0: 2/9/2014
#				SPLIT INTO FB_Scraper.pl AND THIS FILE
#				0.3.0: 4/1/2014
#############################################

#
# 1: requests facebook search page with specified search terms
# 2: scrapes account names/numbers from returned html page
# 3: prints likely matches
#

system ("rm CULLEDFILE") if -e "CULLEDFILE";

chomp ($fname = shift @ARGV);
chomp ($lname = shift @ARGV);
if (!$fname || !$lname) { die; }

system ("wget -q -U Mozilla -O tmp https://facebook.com/search.php?q=Ohio+State+". $fname ."+". $lname);
#else { system ("ls -l profiles/ > tmp"); }
open TMP, "<tmp" or die "what happen\n";

$tmpregex = '"(https\:\/\/www.facebook.com\/[^"]*)"';  # "https://www.facebook.com/FName...LName..."

$exclude = 'pages|state|athletics|buckeyes|\?|facebook$|directory|privacy|recover|www.facebook.com\/osu$';

while (<TMP>) {
	$tmp = $_;
	@tmp = $tmp =~ /$tmpregex/gi;	# find substring that starts with $fname,
	foreach (@tmp) {
		if (!($_ =~ m/$exclude/)) { $matches{$_} = 1; }
	}
}
close TMP;

if (!%matches) { exit; }

foreach (keys %matches) {
	if ($_) { print "$_ "; }
}
