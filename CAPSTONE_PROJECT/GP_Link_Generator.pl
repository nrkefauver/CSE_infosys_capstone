#! /bin/perl

#############################################
# Google Plus Link Generator
# AUTHOR: Tracy Parsons
# VERSIONS: 0.1.0: 4/17/2014
#############################################

#
# Generates facebook search page link to find profile page with input name
#

sub GP_Link_Generator {
	my $fname = $_[0]; my $lname = $_[1];
	if (!$fname || !$lname) { die; }

	$ret = ", https://www.google.com/#q=$fname+$lname+ohio+state+university+google+plus, https://www.plus.google.com/s/ohio+state+university+$fname+$lname/people, https://www.plus.google.com/s/$fname+$lname/people";	#
	return $ret;
}
1;
