#! /bin/perl
#############################################
#	Facebook account scraper proof of concept
#	AUTHOR:		Tracy Parsons
#	VERSIONS:	0.0.1: 1/30/2014
#				0.1.0: 2/3/2014
#				0.2.0: 2/9/2014
#				SPLIT INTO FB_Link_Generator.pl AND THIS FILE
#				0.3.0: 4/1/2014
#############################################

#
# 1: requests provided facebook profile pages
# 2: scrapes information from profile pages and returns information
#

sub FB_EatTags {
	my $ret = $_[1];
	my $x = ($_[0] != 0);
	#my $len = length ($_[1]);
	my $cur = substr ($ret, $x, 1);
	while (length ($ret) > $x && (!$_[0] || substr ($ret, $x, 1) ne '>')) {
		if ($cur eq '<') { $ret = substr ($ret, 0, $x) . EatTags ($_[0]+1, substr ($ret, $x)); }
		else { $x++; }
		$cur = substr ($ret, $x, 1);
	}
	if ($_[0] > 0 && (substr ($ret, 0, $x+1) =~ m/ohio.state.university/i)) { return "#". substr ($ret, 1, $x-1) ."#". substr ($ret, $x+1); }
	elsif ($_[0] > 0) { return "#". substr ($ret, $x+1). "#"; }
	return $ret;
}

sub FB_Regexer {
	# this stuff should work pretty much no matter what, since graph format standardized
	my $graphedu = 'school([^"]*\"){8}[^o]*(ohio state university|osu)[^y]*year([^"]*\"){8}([^"]*)([^c]*concentration([^"]*\"){8}([^"]*))+'; # $2 - osu, $4 - year, $7 - concentration # look for concentrations; may not be present
	my $graphwork = 'work[^e]*employer([^"]*\"){8}([^"]*)[^p]*position([^"]*\"){8}([^"]*)';	# $2 - employer, $4 - position

	my $fulledu = '#About#(Studie[ds](.*?) at|Past:) .*?(the.ohio.state.university|osu)'; # $2 - concentration, $3 - school
	my $fullwork = '#About#(Former )?(.*?) at #([^#]*)'; # $2 - title, $3 - employer

	my $infoedu = '#Work and Education.*?#(Graduate School|College)#The Ohio State University#((Class of |.*? to )([^#]*))?#?([^#]*#([^#]*)#)?[^#]*#Columbus, Ohio#*'; # $1 - Grad/College, $4 - class year, $6 - concentration 
	my $infowork = '(#Work and Education#Employers(#[^#]*#[^#]*# · #[^,]*, [^#]*)*)'; # needs further parsing


	my $mode = $_[0];
	my $ret = 0;
	my $stuff = "";
	
	open FILES, "<$_[1]" or return 0;
	open CULLEDFILE, ">>CULLEDFILE" or return 0;
	
	print CULLEDFILE "\n\nFILE NAME: ". $_[1] ."\n";
	
	while (<FILES>) {
		if ($_ =~ /ohio.state.university/gi || $_[1] =~ /graph/) { $stuff = $stuff . $_; }
	}
	if (!($_[1] =~ /graph/)) { $stuff =~ s/\"[^"]*\"|\'[^']*\'//gi; } # if not a graph, dump stuff in quotes
	$stuff = FB_EatTags (0, $stuff);	# Eat html tags
	$stuff =~ s/	+/ /g;			# Replace strings of tabs with single spaces
	$stuff =~ s/#+/#/g;				# Replace strings of #'s with single #'s
	$stuff =~ s/ +/ /g;				# Replace strings of spaces with single spaces
	$stuff =~ s/ \n/\n/g;			# Replace ' \n' with a newline
	$stuff =~ s/\n+/\n/g;			# Replace strings of newlines with single newline
	print CULLEDFILE $stuff;	# need to record this respectful things so that we can make the regexes
	
	close FILES;
	close CULLEDFILE;
	
	my $class; my $degree; my %jobs; # year, degree, title, company
	my $Alum = 0; my @alljobs;
	if ($mode == 1) {
		if ($stuff =~ m/$graphedu/i) { # $2 - osu, $4 - year, $7 - concentration
			# they've been edumacated at osu, so look for work. Snag other info from education to verify identity
			$Alum = 1;
			if ($4) { $class = $4; }
			if ($7) { $degree = $7; }
			if ($stuff =~ /$graphwork/i) { # $2 - employer, $4 - position
				$jobs {$2} = $4;
			}
		}
	}
	elsif ($mode == 2) {
		if ($stuff =~ m/$infoedu/i) { # $1 - Grad/College, $4 - class year, $6 - concentration 
			$Alum = 1;
			# they've been edumacated at osu, so look for work. Snag other info from education to verify identity?
			if ($4) { $class = $4; }
			if ($5) { $degree = $6; }
			if (@alljobs = $stuff =~ /$infowork/gi) { # $3 - Name of company, $4 - Title
				$alljobs[0] =~ s/#(Work and Education#Employers#|Columbus, Ohio| · )//gi;
				my @tmpjobs = split (/#/, $alljobs[0]);
				my $x = 0;
				while (@tmpjobs[$x]) {
					$jobs{$tmpjobs[$x]} = $tmpjobs[$x+1];
					$x += 2;
				} 
			}
		}
	}	
	else {
		if (my $stuff =~ m/$fulledu/i) { # $2 - concentration, $3 - school
			$Alum = 1;
			# they've been edumacated at osu, so look for work. Snag other info from education to verify identity
			if ($2) { $degree = $2; }
			if ($stuff =~ /$fullwork/i) { # $2 - title, $3 - employer
				$jobs {$3} = $2;
			}
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

sub FB_Scraper {
	system ("rm CULLEDFILE") if -e "CULLEDFILE";
	my $fname = $_[0]; my $lname = $_[1]; my $input = $_[2];
	if (!$fname || !$lname || !$input) { die; }
	
	my @links = split (', ', $input);
	#print "\nINPUT: $input\nLINKS: ";
	#print @links;
	my $tmpregex = '\d\d:\d\d ([^-]*)-';
	my $exclude = 'pages|state|athletics|buckeyes|\?|facebook$|directory|privacy|recover|www.facebook.com\/osu$';
	my %matches;	
	#if ($name) { $tmpregex = '"(https\:\/\/www.facebook.com\/[^"]*)"'; }  # "https://www.facebook.com/FName...LName..."
	foreach (@links) {
		if ($_) {
			system ("wget -q -U Mozilla --load-cookies cookies.txt -O tmp $_");
			open TMP, "<tmp" or die "what happen\n";
			while (<TMP>) {
				$tmp = $_;
				@tmp = $tmp =~ /$tmpregex/gi;	# find substring that starts with $fname,
				foreach (@tmp) {
					if (!($_ =~ m/$exclude/)) { $matches{$_} = 1; }
				}
			}
			close TMP;
			system ("rm tmp");
		}
	}
	#print "MATCHES:\n";
	#print keys %matches;
	#if (!%matches) { break; }

	#$parity = 1;

	#open OUT, ">>output" or die "what happen\n";
	my $ret;
	foreach (keys %matches) {
		$elem = $_;
		if ($elem) {
		#	$tmp2 = 0;
		#	print "Match ". $parity .": $elem\n";
		#	print OUT "$fname $lname: $elem\n";
			# search graph search files
		#	if ($name) { system ("wget -q -U Mozilla -O ./profiles/". $elem ."-graph-public https://graph.facebook.com/$elem?fields=education,work"); }
		#	$tmp = Regexer (1, "./profiles/". $elem ."-graph-public");
		#	if ($tmp && $tmp != 1) {
		#		print "$tmp\n";
		#		$tmp2 = 1;
		#	}
		
		#	$tmp = Regexer (1, "./profiles/". $elem ."-graph-friend");
		#	if ($tmp && $tmp != 1) {
		#		print "$tmp\n";
		#		$tmp2 = 1;
		#	}
		
			#search standard profile pages
		#	if ($name) { system ("wget -q -U Mozilla -O ./profiles/". $elem ."-full-public https://www.facebook.com/$elem"); }
		#	$tmp = Regexer (0, "./profiles/". $elem ."-full-public");
		#	if ($tmp && $tmp != 1) {
		#		print "$tmp\n";
		#		$tmp2 = 1;
		#	}
		
		#	$tmp = Regexer (0, "./oldprofiles/". $elem ."-full-loggedin");
		#	if ($tmp && $tmp != 1) {
		#		print "$tmp\n";
		#		$tmp2 = 1;
		#	}
		
		#	$tmp = Regexer (0, "./profiles/". $elem ."-full-friend");
		#	if ($tmp && $tmp != 1) {
		#		print "$tmp\n";
		#		$tmp2 = 1;
		#	}
		
		#	#search profile 'about' pages
		#	if ($name) { system ("wget -q -U Mozilla -O ./profiles/". $elem ."-full-info-public https://www.facebook.com/$elem/info"); }
		#	$tmp = Regexer (2, "./profiles/". $elem ."-full-info-public");
		#	if ($tmp && $tmp != 1) {
		#		print "$tmp\n";
		#		$tmp2 = 1;
		#	}
		
		#	$tmp = Regexer (2, "./profiles/". $elem ."-full-info-loggedin");
		#	if ($tmp && $tmp != 1) {
		#		print "$tmp\n";
		#		$tmp2 = 1;
		#	}
		
		#	$tmp = Regexer (2, "./profiles/". $elem ."-full-info-friend");
		#	if ($tmp && $tmp != 1) {
		#		print "$tmp\n";
		#		$tmp2 = 1;
			}
		
		#	if (!$tmp2 ) { print "Insufficient information\n\n"; }
		#	elsif ($tmp == 1) { print "Ohio State present on page;\n"; }
		if ($_) {
			$ret = $ret . ",$_";
		#	$parity++;
		#	
		}
	}
	#system ("rm -y profiles/*");
	#print "\n";
	return $ret;
}
1;
