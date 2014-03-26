#!/usr/bin/perl
use warnings;
use strict;
use Data::Dumper;
#Employment data project

###Data Munging###

#load from "raw"

open FILE, "raw" or die $!;
my @lines = <FILE>;
close(FILE);
my @words;
foreach my $line (@lines){
	$line=~s/\"//g;
	my @split = split(/,/,$line);
	my %data=(
		firstname=>$split[0],
		middlename=>$split[1],
		lastname=>$split[2],
		suffix=>$split[3],
		address=>$split[4],
		city=>$split[5],
		state=>$split[6],
		zip=>$split[7],
		birthdate=>$split[8],
		fn=>$split[9],
	);
	push(@words,\%data);
}

#print Dumper @words;

$browser = "firefox";	# set with environment variables;

foreach my $person (@words){
	my $fname = $person->{firstname};
	my $lname = $person->{lastname};
#	system($^X, "fbscraper.pl", $fname, $lname);
#	system($^X, "liscraper.pl", $fname, $lname);
	# NOTE: This stuff will have to change if we transition to a windows environment
	system ("rm $fname.$lname") if -e "$fname.$lname";
	`echo -n "$browser " >> $fname.$lname`;
	system ("echo -n `perl newfacebookscraper.pl $fname $lname` >> $fname.$lname");
	`echo -n " " >> $fname.$lname`;
	system ("echo -n `perl liscraper.pl $fname $lname` >> $fname.$lname");
}


