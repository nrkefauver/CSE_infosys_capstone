#!/usr/bin/perl
use warnings;
use strict;

require "FB_Link_Generator.pl";
require "FB_Link_Scraper.pl";
require "FB_Scraper.pl";
require "GP_Link_Generator.pl";
require "GP_Link_Scraper.pl";
#require "GP_Scraper.pl";
require "LI_Link_Generator.pl";
require "LI_Scraper.pl";
require "ZI_Link_Generator.pl";

#Employment data project

###Data Munging###

#load from files supplied on command line

my @lines;
while (my $cmdarg = shift) {
	#print "Opening file $cmdarg;\n";
	open FILE, "<$cmdarg" or die $!;
	while (<FILE>) { push @lines, $_; }
	close FILE;
}

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

foreach my $person (@words){
	my $fname = $person->{firstname};
	my $mname = $person->{middlename};
	my $lname = $person->{lastname};
	# NOTE: This stuff will have to change if we transition to a windows environment
	system ("rm ./profiles/$fname-$lname.dat") if -e "./profiles/$fname-$lname.dat";
	print "$fname,$mname,$lname";
	my $FBLinks = 0; $FBLinks = FB_Link_Generator ($fname, $lname);
	if ($FBLinks) {
		print $FBLinks;
		my $FBProfiles = 0; $FBProfiles = FB_Link_Scraper ($fname, $lname, $FBLinks);
		if ($FBProfiles) {
			print $FBProfiles;
			my $FBResults = 0; $FBResults = FB_Scraper ($fname, $lname, $FBProfiles);
			if ($FBResults) { print $FBResults; }
		}
	}
	my $GPLinks = GP_Link_Generator ($fname, $lname);
	#my $GPLinks = ", https://www.google.com/#q=$fname+$lname+ohio+state+university+google+plus";
	if ($GPLinks) {
		print $GPLinks;
		my $GPProfiles = 0;
		$GPProfiles = GP_Link_Scraper ($fname, $lname, $GPLinks);
		if ($GPProfiles) { print $GPProfiles; }
	}
	
	my $LILinks = LI_Link_Generator ($fname, $lname);
	if ($LILinks) { print $LILinks; }
	
	my $ZILinks = ZI_Link_Generator ($fname, $lname, "dummycode");	# for this to work, "dummycode" will need to be replaced with partner code from ZoomInfo 
	if ($ZILinks) { print $ZILinks; }

	print "\n";
}


