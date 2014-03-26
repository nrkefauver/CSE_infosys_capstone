#!/usr/bin/perl
# New facebook search page scraper

system ("rm CULLEDFILE") if -e "CULLEDFILE";

chomp ($fname = shift @ARGV);
chomp ($lname = shift @ARGV);
if (!$fname || !$lname) { $name = 0; }
else { $name = 1; }

if ($name) { system ("wget -q -U Mozilla -O tmp https://facebook.com/search.php?q=Ohio+State+". $fname ."+". $lname); } #
else { system ("ls -l profiles/ > tmp"); }
open TMP, "<tmp" or die "what happen\n";

$tmpregex = '\d\d:\d\d ([^-]*)-';
if ($name) { $tmpregex = '"(https\:\/\/www.facebook.com\/[^"]*)"'; }  # "https://www.facebook.com/FName...LName..."

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
