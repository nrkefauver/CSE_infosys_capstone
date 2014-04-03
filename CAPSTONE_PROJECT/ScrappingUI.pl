#!/usr/bin/perl

use strict;
use warnings;

#my $output = `cat dat`; # redirecting from another perl file when needed
#my @lines  = split /\n/, $output;
open STDOUT, ">", "output.html" or die "$0: open: $!"; #redirecting output into a html file
open STDERR, ">&STDOUT"        or die "$0: dup: $!";

my $filename = "TestEmployment.txt"; # the name of the file

open(FH, $filename);    # open the file
my @files = <FH>;       # read the file
 my @lines  = @files;
my @damn;

foreach my $line (@lines) {

split(/\n/, $line); 
 

    my @d = split ',', $line;
   
   
   
    push @damn, \@d;
}



print <<HEADER;
<!DOCTYPE html>
<html>
<body>
<h1 style="text-align:center;"style="font-family:verdana;">TASEDATASS</h1>  
<table border="2" style="width:45px">
<tbody>
<tr><td style="background-color: #CCC","vertical-align: right; width: 80px;"><a href="#" onclick="toggleItem('myTbody')"><h3 style="font-family:verdana;">OLD-DATA</h3></a> </td></tr>
</tbody>
<tbody id="myTbody">
</tr>
HEADER
foreach my $d (@damn) {
#$d =~ m/"([^"]*)"/;
    print "\n", "<tr>";
    print map { "<th>$_</th>" } @$d;
    print "</tr>", "\t";
   
}

print <<FOOTER;
</tr>
</tbody>
</table>


 <script language="javascript">
    function getItem(id)
    {
        var itm = false;
        if(document.getElementById)
            itm = document.getElementById(id);
        else if(document.all)
            itm = document.all[id];
        else if(document.layers)
            itm = document.layers[id];

        return itm;
    }

    function toggleItem(id)
    {
        itm = getItem(id);

        if(!itm)
            return false;

        if(itm.style.display == 'none')
            itm.style.display = '';
        else
            itm.style.display = 'none';

        return false;
    }
    </script>
</html>
FOOTER
