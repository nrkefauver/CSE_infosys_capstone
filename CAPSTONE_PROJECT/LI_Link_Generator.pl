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

chomp ($fname = shift @ARGV);
chomp ($lname = shift @ARGV);
if (!$fname || !$lname) { die; }

print "https://www.google.com/#q=$fname+$lname+ohio+state+university+linkedin";
