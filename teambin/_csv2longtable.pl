#!/usr/bin/perl -w
# read csv file, use first line as header of long table
# sum last column and put sum as last row in table
my $count=0;
my $testCount=1;
my $sum=0;
my @parts=('0','a', 'b', 'c', '0');
my ($line,$task,$otask,$hline);
$otask=0;
print qq({\\scriptsize\\begin{longtable}{|p{20mm}|r|p{40mm}|p{70mm}|r|}
\\caption{Grading Table}\\\\\\hline
\\rowcolor[gray]{0.8}\\textbf{Assignment}&\\textbf{Test\\#}&\\textbf{Test Class}&\\textbf{Test Method}&\\textbf{Points}\\\\\\hline
\\endhead
\\hline\\multicolumn{3}{r}{\\emph{Point List continued on next page}}
\\endfoot
\\endlastfoot
);
while(<>){
    chomp;
    s/_/\\_/g;
    @parts=split/,/;
    if ($count != 0) {
 	$sum+=$parts[-1];
	$task=$parts[0];
	if ($task != $otask) {
	    $testCount=1;
	    print qq(\\hline\n);
	}
	$otask=$task;
	$line=qq($parts[1] & $testCount & $parts[2] & $parts[3] & $parts[4]);
	print qq($line\\\\\n);
    }
    $count=1;
    $testCount++;
}

print qq(\\rowcolor[gray]{0.8}&&&Total points&$sum\\\\\n);
print qq(\\end{longtable}}\n);
