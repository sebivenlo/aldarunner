#!/usr/bin/perl -w

my $grp=$ARGV[0];
open(STATS,"<stats.csv") or die qq(Cannot open stats.csv);
my (@line);
print qq(
<html>
<head>
    <title>Stats for ${grp}</title>
    <script type="text/javascript" src="/js/jquery.min.js"></script>
    <script src="/js/jquery.tablesorter.js"></script>
    <link rel='stylesheet' type='text/css' href='/css/tablesorterstyle.css'/>
</head>
<body>
    <h1>Stats for ${grp}</h1>
    <table id='myTable' class='tablesorter'>\n);
my $lineCount=0;
my $cls='';
while(<STATS>){
    chomp;
    (@line) = split/;/;
    if ($lineCount == 0) {
	print qq(<thead>\n<tr>);
	foreach my $v (@line) {
	    print qq(<th class='tabledata head'>$v</th>);
	}
	print qq(</tr></thead>\n<tbody>\n);
    } else {
	print qq(  <tr>);
	foreach my $v (@line) {
	    if ( $v =~ m/^\d+/) {
		$cls='num';
	    } else {
		$cls='';
	    }
	    print qq(<td class='tabledata $cls'>$v</td>);
	}
	print qq(</tr>\n);
    }
    $lineCount++;
}
print qq(</tbody>
</table>
    <script type="text/javascript">                                         
      \$(document).ready(function() {
           \$("#myTable").tablesorter({widgets: ['zebra']}); 
      });
    </script>
</body>
</html>);
