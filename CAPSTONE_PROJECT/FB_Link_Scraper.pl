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
# 1: fetches facebook search page with specified search terms
# 2: scrapes account names/numbers from returned html page
# 3: prints likely matches
#
sub FB_Link_Scraper {
	system ("rm CULLEDFILE") if -e "CULLEDFILE";
	my $fname = $_[0]; my $lname = $_[1]; my $input = $_[2];
	if (!$fname || !$lname || !$input) { die; }
	
	my @links = split (', ', $input);
	#print "\nINPUT: $input\nLINKS: ";
	#print @links;
	foreach (@links) {
		if ($_) {
			system ("wget -q -U Mozilla -O tmp $_");
			#else { system ("ls -l profiles/ > tmp"); }
			open TMP, "<tmp" or die "what happen\n";
			
			$tmpregex = '"(https\:\/\/www.facebook.com\/[^"]*)"';  # "https://www.facebook.com/FName...LName..."

			$exclude = 'pages|state|athletics|buckeyes|\?|facebook$|directory|privacy|recover|www.facebook.com\/osu$';

			while (<TMP>) {
				my $tmp = $_;
				#print $_;
				my @tmp2 = $tmp =~ /$tmpregex/gi;	# find substring that starts with $fname,
				foreach (@tmp2) {
					if (!($_ =~ m/$exclude/)) { $matches{$_} = 1; }
				}
			}
			close TMP;
			system ("rm tmp");
		}
	}

	my $ret;
	foreach (keys (%matches)) {
		if ($_) {
			$ret = $ret . ", $_";
		}
	}
	return $ret;
}
1;
