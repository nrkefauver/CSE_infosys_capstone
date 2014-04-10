#!/usr/bin/perl
use warnings;
use strict;
#use Data::Dumper;
#Employment data project

###Data Munging###

#load from files supplied on command line

my @lines;
while (my $cmdarg = shift) {
	#print "Opening file $cmdarg;\n";
	open FILE, "<$cmdarg" or die $!;
	while (<FILE>) { push @lines, $_; }
	close(FILE);
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

system ("rm OUTPUT.dat") if -e "OUTPUT.dat";
open FILE, ">OUTPUT.dat";
print FILE "<?xml version=\"1.0\" encoding = \"UTF-8\"?>\n<data>\n";
foreach my $person (@words){
	my $fname = $person->{firstname};
	my $mname = $person->{middlename};
	my $lname = $person->{lastname};
	# NOTE: This stuff will have to change if we transition to a windows environment
	#system ("rm ./profiles/$fname-$lname.dat") if -e "./profiles/$fname-$lname.dat";
	print FILE "<person name = \"". $fname ." ". $mname ." ". $lname ."\">\n";  	
	print FILE "	<profile site=\"FaceBook\">\n";
	system ("echo `perl FB_Link_Generator.pl $fname $lname` >> OUTPUT.dat");
	wait;	
	print FILE "	</profile>\n";
	#system ("echo -n `perl FB_Scraper.pl $fname $lname` >> OUTPUT.dat");
	print FILE "	<profile site=\"LinkedIn\">\n";
	#`echo -n " " >> ./profiles/$fname-$lname.dat`;
	system ("echo `perl LI_Link_Generator.pl $fname $lname` >> OUTPUT.dat");
	wait;	
	#system ("echo -n `perl LI_Scraper.pl $fname $lname` >> OUTPUT.dat");
	print FILE "	</profile>\n";
	
	#`echo -n " " >> ./profiles/$fname-$lname.dat`;
	print FILE "	<profile site=\"GooglePlus\">\n";
	system ("echo `perl GP_Link_Generator.pl $fname $lname` >> OUTPUT.dat");
	wait;	
	print FILE "	</profile>\n";
	#system ("echo -n `perl GP_Scraper.pl $fname $lname` >> OUTPUT.dat");
	print FILE "</person>\n";
}
print FILE "</data>\n";
close FILE;
system ("chmod 755 OUTPUT.dat");
