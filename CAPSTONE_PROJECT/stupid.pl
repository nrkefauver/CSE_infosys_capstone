#!/usr/bin/perl
# rely dum
open IN, "<tmp" or die "dead";

print "Printing...\n";
my $regex = '("https:\/\/plus.google.com\/\d+")';
while (<IN>) {
	my $tmp = $_ =~ m/("https:\/\/plus.google.com\/\d+")/ig;
	if ($tmp) { print $1 ."\n"; }
}
