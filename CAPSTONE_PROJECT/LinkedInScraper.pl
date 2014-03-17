#! /bin/perl
#############################################
# LinkedIn Scraper
# AUTHOR: Tracy Parsons
# VERSIONS: 0.1.0: 3/12/2014
#############################################

#
# 1: scrapes public profile html page
# 2: prints information
# NOTE: Don't expect the wget lines to download what we want. There will need to be some work done to make it scrape the search pages to get matches
#

sub Regexer {
	my $mode = $_[0];
	my $ret = 0;
	my $stuff = "";

	open FILES, "<$_[1]" or return 0;
	open CULLEDFILE, ">>LinkedInCULLEDFILE" or return 0;

	print CULLEDFILE "\n\nFILE NAME: ". $_[1] ."\n";

	while (<FILES>) {
		$newstuff = $_;
		$newstuff =~ s/(\n|\r)+/_/g;
		$stuff = $stuff . $newstuff;
	}
	#if (!($_[1] =~ /graph/)) { $stuff =~ s/\"[^"]*\"|\'[^']*\'//gi; } # if not a graph, dump stuff in quotes
	#$stuff =~ s/\n//g;
	$stuff =~ s/[	 ]{2,}/ /g;
	$stuff =~ s/<.*?>//g;	# Eat html tags
	$stuff =~ s/( *?_)+/\n/g;
	print CULLEDFILE $stuff;	# need to record this stuff so that we can make the regexes

	close FILES;
	close CULLEDFILE;

	my $name = $_[1];
	$name =~ /\/([^-\/]+)-/i;
	$name = $1;
	$name =~ s/\./ /g;
	my $curwork = $name .'.*? Overview\n Current((\n .+?\n at\n.+?\n\t)+)';
	# curwork: NEED TO CAPTURE ENTIRE OUTPUT
	my $pastwork = $name .'.*? Overview(.*\n)*?\n Past((\n .+?\n at\n.+?\n\t)+)';
	# pastwork: NEED TO CAPTURE ENTIRE OUTPUT
	my $edu = $name ."'s? Education(\n.*?)*? The Ohio State University\n(.+?),\n(.+?)\n [0-9]{4} .*? ([0-9]{4})\n";
	# edu: $2 = degree, $3 = field, $4 = graduation
	my $class; my $degree; my %jobs; # year, degree, title, company
	my $Alum = 0;
	my @curjobs;
	my @pastjobs;
	if ($stuff =~ m/$edu/i) {
		$Alum = 1;
		# they've been edumacated at osu, so look for work. Snag other info from education to verify identity?
		if ($4) { $class = $4; }
		if ($2 && $3) { $degree = $2 ." IN ". $3; }
		@curjobs = $stuff =~ /$curwork/gi;
		@pastjobs = $stuff =~ /$pastwork/gi;
		
		if (@curjobs > 0 || @pastjobs > 0) {
			#$alljobs[0] =~ s/#()//gi;
			my @tmpjobs = split (/\n\t*/, $curjobs[0]);
			my $x = 0;
			while ($x < @tmpjobs) {
				print $tmpjobs[$x] ."\n";
				$jobs{$tmpjobs[$x+3]} = $tmpjobs[$x+1];
				$x+=4;
			}
			#print %jobs; 
		}
	}
		
	if ($Alum) {	# ohio state alumni/student
		$ret = "OHIO STATE ALUMNI;";
		if ($class) { $ret = $ret ." YEAR: ". $class .";"; }
		if ($degree) { $ret = $ret ." DEGREE: ". $degree; }
		$ret = $ret ."\n";

		if (%jobs) { $ret = $ret ."EMPLOYMENT:\n"; }
		foreach (keys %jobs) {	# job
			if ($jobs{$_}) { $ret = $ret ."	". $jobs{$_} ." FOR ". $_ .";"; }
			elsif ($_) { $ret = $ret ."WORKS FOR: ". $_ .";"; }
			$ret = $ret ."\n";
		}
		
	}
	return $ret;
}

#system ("rm LinkedInCULLEDFILE");

chomp ($fname = shift @ARGV);
chomp ($lname = shift @ARGV);
if (!$fname || !$lname) { $name = 0; }
else {
	$name = 1;
	print "Name to search: $fname $lname;\n\n";
}

if ($name) { system ("wget -q -U Mozilla -O output https://linkedin.com/pub/dir/?first=". $fname ."&last=". $lname); } #
# change these commands to get stuff from linkedin
else { system ("ls -l ./profiles/*-LinkedIn > output"); }
open OUT, "<output" or die "what happen\n";

$tmpregex = '\d\d:\d\d ([^-]*)-';
if ($name) { $tmpregex = '"https\:\/\/www.linkedin.com\/'. $fname .'.?'. $lname; } # .'[^"]*"'

while (<OUT>) {
	$output = $_;
	@tmp = $output =~ /$tmpregex/gi;	# find substring that starts with $fname,
	foreach (@tmp) { $matches{$_} = 1; }
}
close OUT;

if (!%matches) {
	print "No matches\n\n";
	exit;
}

$parity = 1;
foreach (keys %matches) {
	$elem = $_;
	if ($elem) {
		$tmp2 = 0;
		print "Match ". $parity .": $elem\n";
		if ($name) { system ("wget -q -U Mozilla -O ./profiles/". $elem ."-LinkedIn https://linkedin.com/in/$elem"); }
		$tmp = Regexer (0, $elem ."-LinkedIn");
		if ($tmp && $tmp != 1) {
			print "$tmp\n";
			$tmp2 = 1;
		}

		if (!$tmp2 ) { print "Insufficient information\n\n"; }
		elsif ($tmp == 1) { print "Ohio State present on page;\n"; }
		$parity++;
	}
}
print "\n";
