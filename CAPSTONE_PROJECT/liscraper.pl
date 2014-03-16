#! /bin/perl

$graphedu = 'school([^"]*\"){8}[^o]*(ohio state university|osu)[^y]*year([^"]*\"){8}([^"]*)([^c]*concentration([^"]*\"){8}([^"]*))+'; # $2 - osu, $4 - year, $7 - c
$graphwork = 'work[^e]*employer([^"]*\"){8}([^"]*)[^p]*position([^"]*\"){8}([^"]*)';	# $2 - employer, $4 - position
$fulledu = '#About#(Studie[ds](.*?) at|Past:) .*?(the.ohio.state.university|osu)'; # $2 - concentration, $3 - school
$fullwork = '#About#(Former )?(.*?) at #([^#]*)'; # $2 - title, $3 - employer
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
	
	return $ret;
}



chomp ($fname = shift @ARGV);
chomp ($lname = shift @ARGV);
if (!$fname || !$lname) { $name = 0; }
else {
	$name = 1;
	print "Linkedin search page for: $fname $lname\n";
}
$target= "'https://www.linkedin.com/pub/dir/?first=".$fname."&last=".$lname."&search=search'";
print "Target: ".$target."\n";
if ($name) { system ("wget -q -U Mozilla -O ./profiles/". $fname ."_". $lname. "_li ".$target); } 
else { system ("ls -l profiles/ > output"); }

print "\n";
