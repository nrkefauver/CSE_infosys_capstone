#! /bin/perl
#############################################
#	Facebook account finder proof of concept
#	AUTHOR:		Tracy Parsons
#	VERSIONS:	0.0.1: 1/30/2014
#				0.1.0: 2/3/2014
#				0.2.0: 2/9/2014
#############################################

#
# 1: requests facebook search page with specified search terms
# 2: scrapes account names/numbers from returned html page
# 3: prints likely matches
#

# this stuff should work pretty much no matter what, since graph format standardized
$graphedu = 'school([^"]*\"){8}[^o]*(ohio state university|osu)[^y]*year([^"]*\"){8}([^"]*)([^c]*concentration([^"]*\"){8}([^"]*))+'; # $2 - osu, $4 - year, $7 - concentration # look for concentrations; may not be present
$graphwork = 'work[^e]*employer([^"]*\"){8}([^"]*)[^p]*position([^"]*\"){8}([^"]*)';	# $2 - employer, $4 - position

# redo these

#!-- #About#Faculty# at #The Ohio State University# and #Deputy Director, Technology# at #City of Columbus#Past: #myCIO# and #Scimus Information Systems#Studied at #Wright State University#Past: #The Ohio State University# and #Lycée Habib Maazoun Sfax#Lives in #Columbus, Ohio#From #Tunis, Tunisia#Followed by #17 people#Photos# · #567#Friends# · #749#Terri Vesely#Laura Novak Provard#Josselin Ravalec#Ghayour Chouchane#Lisette Tedeschi Kidwell#Iyes Dendeni#Heather Bapst Mazotas#Dan Snyder#Stephen Vadakin#Places#Paris Charles Degaulle International Airport#about 2 weeks ago#Sports# · #1#Sfax Railways Sports#Music# · #14#The Beatles#Bob Marley#Adele#Rihanna#Majida El Roumi#The Spider Bytes# --#

#!-- #About#Software Engineer at #Chemical Abstracts Service#June 17, 2013 to present#Studies Computer Science and Engineering at #The Ohio State University#Past: #Hilliard Darby High School#Photos# · #276#Places#Columbus, Ohio#about 8 months ago#Archer House# — with #Julia Young#.#about 10 months ago#Groups# · #4#Events &amp; Parties#6,432 members#Get the word out about your party,...#Free &amp; For Sale#6,579 members#Find fridges, futons, textbooks,...#Jobs &amp; Internships#6,531 members#Find and list jobs available on...#Textbook Exchange#3,696 members#Buy, sell and trade textbooks with...# --#

#!-- #About#Studied at #The Ohio State University#Past: #George Mason University# and #Westerville - South High School#Photos# · #65#Friends# · #128#Omar El-Sayed#Hassan Nur#Faduma Ahmed#Hussein Ali#Sree Ram Mohanan#Saad Al Doseri#Princess Donia#Moin Azfar Sheriff#Fadumina Iskufilan#Groups# · #5#The Ohio State University Class of 2013#5,635 members#MSA Brothers#167 members#Offical MSA group for MSA...#Somali Professionals#574 members#SSA-OSU#270 members#Official Somali Students...# --#

#!-- #About#Studied at #The Ohio State University#Photos# · #205#Friends# · #162#Samuel Allen Maxwell#Will Posner#Daniel Kirschenbaum#Amanda King#Andrea Fleming#Morgan Goose#Nicholas Peterson#Gene Edwards#Al-x Everett#Music# · #1#The Lost Revival#Ask#Ask Nick for a music recommendation# --#

$fulledu = '#About#(Studie[ds](.*?) at|Past:) .*?(the.ohio.state.university|osu)'; # $2 - concentration, $3 - school
$fullwork = '#About#(Former )?(.*?) at #([^#]*)'; # $2 - title, $3 - employer

#!-- #Work and Education#Employers#City of Columbus#Deputy Director, Technology# · #Columbus, Ohio#The Ohio State University#Faculty# · #Columbus, Ohio#myCIO#Owner/ President# · #Columbus, Ohio#Hondros College#CIO# · #Columbus, Ohio#See All Employers#Graduate School#Wright State University#Class of 1990# · #Dayton, Ohio#College#The Ohio State University#Class of 1988# · #Columbus, Ohio#High School#Lycée Habib Maazoun Sfax#Class of 1984# · #Sfax# --#
#!-- #Life Events#1990#Graduated from Wright State University#1988#Graduated from The Ohio State University#1984#Graduated from Lycée Habib Maazoun Sfax#Started Working at Compuware#Started Working at Wright State University#Started School at Wright State University#Started School at The Ohio State University#Started Working at Rational Software Corporation#Started Working at Title First Agency#Started Working at City of Columbus#Started School at Lycée Habib Maazoun Sfax#Started Working at The Ohio State University#Started Working at myCIO#Started Working at Hondros College#Started Working at Scimus Information Systems#See All Life Events# --#

#!-- #Work and Education#Employers#Chemical Abstracts Service#Software Engineer# · #Columbus, Ohio# · #Jun 17, 2013 to present#College#The Ohio State University#Aug 2010 to Apr 2014# · #Computer Science and Engineering# · #Columbus, Ohio#High School#Hilliard Darby High School#Class of 2010# · #Hilliard, Ohio# --#
#!-- #Life Events#2013#Started Working at Chemical Abstracts Service#2012#First Met Julia Young#2010#Started School at The Ohio State University#Graduated from Hilliard Darby High School#2006#Started School at Hilliard Darby High School# --#

#!-- #Work and Education#College#The Ohio State University#Columbus, Ohio#Ask for Nick&#039;s work info#Ask for Nick&#039;s high school# --#
#!-- #Life Events#Started School at The Ohio State University# --#

$infoedu = '#Work and Education.*?#(Graduate School|College)#The Ohio State University#((Class of |.*? to )([^#]*))?#?([^#]*#([^#]*)#)?[^#]*#Columbus, Ohio#*'; # $1 - Grad/College, $4 - class year, $6 - concentration 
$infowork = '(#Work and Education#Employers(#[^#]*#[^#]*# · #[^,]*, [^#]*)*)'; # needs further parsing

sub EatTags {
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

sub Regexer {
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
	$stuff = EatTags (0, $stuff);	# Eat html tags
	$stuff =~ s/	+/ /g;			# Replace strings of tabs with single spaces
	$stuff =~ s/#+/#/g;				# Replace strings of #'s with single #'s
	$stuff =~ s/ +/ /g;				# Replace strings of spaces with single spaces
	$stuff =~ s/ \n/\n/g;			# Replace ' \n' with a newline
	$stuff =~ s/\n+/\n/g;			# Replace strings of newlines with single newline
	print CULLEDFILE $stuff;	# need to record this shit so that we can make the regexes
	
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
	#else {
	#	if ($tmp =~ m/href="https:\/\/facebook.com\/(the.ohio.state.university|osu)/) { $ret = 1; }
	#}
	return $ret;
}

system ("rm CULLEDFILE");

chomp ($fname = shift @ARGV);
chomp ($lname = shift @ARGV);
if (!$fname || !$lname) { $name = 0; }
else {
	$name = 1;
	print "Name to search: $fname $lname;\n\n";
}

if ($name) { system ("wget -q -U Mozilla -O output https://facebook.com/search.php?q=Ohio+State+". $fname ."+". $lname); } #
else { system ("ls -l profiles/ > output"); }
open OUT, "<output" or die "what happen\n";

$tmpregex = '\d\d:\d\d ([^-]*)-';
if ($name) { $tmpregex = '"https\:\/\/www.facebook.com\/('. $fname .'.?'. $lname .'[^"]*)"'; }  # "https://www.facebook.com/FName...LName..."

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
		# search graph search files
		if ($name) { system ("wget -q -U Mozilla -O ./profiles/". $elem ."-graph-public https://graph.facebook.com/$elem?fields=education,work"); }
		$tmp = Regexer (1, "./profiles/". $elem ."-graph-public");
		if ($tmp && $tmp != 1) {
			print "$tmp\n";
			$tmp2 = 1;
		}
		
		$tmp = Regexer (1, "./profiles/". $elem ."-graph-friend");
		if ($tmp && $tmp != 1) {
			print "$tmp\n";
			$tmp2 = 1;
		}
		
		#search standard profile pages
		if ($name) { system ("wget -q -U Mozilla -O ./profiles/". $elem ."-full-public https://www.facebook.com/$elem"); }
		$tmp = Regexer (0, "./profiles/". $elem ."-full-public");
		if ($tmp && $tmp != 1) {
			print "$tmp\n";
			$tmp2 = 1;
		}
		
		$tmp = Regexer (0, "./profiles/". $elem ."-full-loggedin");
		if ($tmp && $tmp != 1) {
			print "$tmp\n";
			$tmp2 = 1;
		}
		
		$tmp = Regexer (0, "./profiles/". $elem ."-full-friend");
		if ($tmp && $tmp != 1) {
			print "$tmp\n";
			$tmp2 = 1;
		}
		
		#search profile 'about' pages
		if ($name) { system ("wget -q -U Mozilla -O ./profiles/". $elem ."-full-info-public https://www.facebook.com/$elem/info"); }
		$tmp = Regexer (2, "./profiles/". $elem ."-full-info-public");
		if ($tmp && $tmp != 1) {
			print "$tmp\n";
			$tmp2 = 1;
		}
		
		$tmp = Regexer (2, "./profiles/". $elem ."-full-info-loggedin");
		if ($tmp && $tmp != 1) {
			print "$tmp\n";
			$tmp2 = 1;
		}
		
		$tmp = Regexer (2, "./profiles/". $elem ."-full-info-friend");
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
