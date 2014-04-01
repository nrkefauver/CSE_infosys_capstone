#! /bin/perl

chomp ($fname = shift @ARGV);
chomp ($lname = shift @ARGV);
if (!$fname || !$lname) { $name = 0; }
else {
	$name = 1;
#	print "Linkedin search page for: $fname $lname;\n";
}
#$target= "https://www.linkedin.com/pub/dir/?first=".$fname."&last=".$lname."&search=search";
#$target = "https://www.google.com/#q=$fname+$lname+ohio+state+university+linkedin";

print "https://www.google.com/#q=$fname+$lname+ohio+state+university+linkedin";
#open OUT, ">>output" or die "what happen\n";
#print OUT "$fname $lname: $target\n";
	
#if ($name) { system ("wget -q -U Mozilla -O ./profiles/". $fname ."_". $lname. "_li ".$target); } 
#else { system ("ls -l profiles/ > output"); }

#print "\n";
