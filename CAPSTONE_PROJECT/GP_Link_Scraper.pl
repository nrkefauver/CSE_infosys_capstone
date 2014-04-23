#!/usr/bin/perl
#############################################
#	Google Plus account finder proof of concept
#	AUTHOR:		Tracy Parsons
#	VERSIONS:	0.1.0: 4/3/2014
#############################################

sub GP_Link_Scraper {
	#system ("wget -q -O tmp https://plus.google.com/s/ohio%20state%20". $fname ."%20". $lname ."/people");
	system ("rm CULLEDFILE") if -e "CULLEDFILE";
	my $fname = $_[0]; my $lname = $_[1]; my $input = $_[2];
	if (!$fname || !$lname || !$input) { die; }
	
	my @links = split (', ', $input);

	my $regex = '"\.\/(/d+)"';
	my %OSU_Matches;
	my %Gen_Matches;
	foreach (@links) {
		$link = $_;		
		if ($link =~ m/www\.plus\.google\.com\/s\/ohio+state+university/) {
			system ("wget -q -U Mozilla -O tmp $_");
			sleep (1);
			open IN, "<tmp" or die "THAT'S NO MOON!";
			while (<IN>) {
				my @tmp = ($_ =~ /$regex/ig);
				print "\n";				
				print @tmp;
				print "\n";				
				if (@tmp) {
					my $match = $tmp[0] ."/about";
					$OSU_Matches{$tmp[0]} += 1;
				}
			}
			close IN;
			system ("rm tmp");
		}
		elsif ($link =~ m/www\.plus\.google\.com\/s\//) {
			system ("wget -q -U Mozilla -O tmp $_");
			sleep (1);
			open IN, "<tmp" or die "THAT'S NO MOON!";
			while (<IN>) {
				my @tmp = ($_ =~ /$regex/ig);
				if (@tmp) {
					my $match = $tmp[0] ."/about";
					$Gen_Matches{$tmp[0]} += 1;
				}
			}
			close IN;
			system ("rm tmp");
		}
	}

	my @Overlap = ();
	foreach (keys (%Gen_Matches)) {
		if ($OSU_Matches{$_}) {	push @Overlap, $_; }
	}
	
	#open OUTPUT, ">$file";
	if (@Overlap > 0) {
		foreach (@Overlap) { $ret = $ret . ", $_"; }
	}
	else {
		foreach (keys (%Gen_Matches)) { $ret = $ret . ", $_"; }
	}
	return $ret;
}
1;
