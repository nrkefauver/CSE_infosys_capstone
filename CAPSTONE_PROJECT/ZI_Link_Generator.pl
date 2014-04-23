#!/usr/bin/perl
use Digest::MD5 qw(md5_hex);
use Time::Piece;


# ZoomInfo link generator

sub ZI_Link_Generator {
	my $fname = $_[0]; my $lname = $_[1]; my $code = $_[2];
	if (!$fname || !$lname || !$code) { die "Need more arguments!\n"; }
	
	my $ret;
	my $date = localtime->strftime('%Y/%d/%m');
	($year, $mday, $mon) = split (/\/0?/, $date);
	
	my $key = substr ($fname, 0, 2) . substr ($lname, 0, 2) . "Oh" . $code . $mon . $mday . $year;
	$key = md5_hex ($key);

	my $ret = ", https://www.google.com/#q=$fname+$lname+ohio+state+university+zoominfo, http://partnerapi.zoominfo.com/partnerapi/xmloutput.aspx?query_type=people_search_query&pc=$code&firstName=$fname&lastName=$lname&school=Ohio+State&key=$key";
	# NOTE: for this to work, a password from ZoomInfo will be required. ZoomInfo would be happy to give us a password and api access for $15K
	#	
	return $ret;
}
1;
