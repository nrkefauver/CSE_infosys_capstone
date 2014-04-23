#! /bin/perl

#############################################
# FaceBook Link Generator
# AUTHOR: Tracy Parsons
# VERSIONS: 0.1.0: 4/15/2014
#############################################

#
# Generates facebook search page link to find profile page with input name
#

sub FB_Link_Generator {
	my $fname = $_[0]; my $lname = $_[1];
	if (!$fname || !$lname) { die; }
	my $ret;
	$ret = ", https://facebook.com/search.php?q=Ohio+State+". $fname ."+". $lname;
	return $ret;
}
1;
