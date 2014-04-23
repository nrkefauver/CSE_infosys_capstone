#! /bin/perl

#############################################
# LinkedIn Link Generator
# AUTHOR: Tracy Parsons
# VERSIONS: 0.1.0: 3/12/2014
#			0.2.0: 4/1/2014
#############################################

#
# Prints google link to find profile page with input name
#

sub LI_Link_Generator {
	my $fname = $_[0]; my $lname = $_[1];
	if (!$fname || !$lname) { die; }

	$ret = ", https://www.google.com/#q=$fname+$lname+ohio+state+university+linkedin";
	return $ret;
}
1;
