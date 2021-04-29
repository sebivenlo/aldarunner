#!/usr/bin/perl -w
use XML::XPath;
use Path::Tiny;
use XML::XPath::XMLParser;
use Config::Properties;
use Cwd;
use File::Basename;

my $properties = new Config::Properties();
my ($key, $values, $states);
my $grp=$ARGV[0];
my $xmlFile=$ARGV[1];
my %collector;
# if ( -s 'collector.csv') {
#     open(COL, "< collector.csv") or die qq(cannot open file collector.csv\n);
#     while(<COL>) {
# 	chomp;
# 	($key,$values) = split/=/;
# 	${collector}{$key}=$values;
#     }
#     close(COL);
# }
my ($className,$testName);
my @dirs=('siteBB', 'siteB0', 'siteB1', 'siteB2', 'siteB3');
foreach my $dir (@dirs) {
    if ( -d "$dir/surefire-reports") {
	print qq($dir\n);
	my @xmlPaths=path("${dir}/surefire-reports")->children( qr/\.xml$/);
	
	foreach my $xmlP (@xmlPaths) {
	    my $xp = XML::XPath->new(filename => "$xmlP");
	    my $nodeset = $xp->find('//testsuite/testcase'); # find all paragraphs
	    my ($passfail,$failure,$ignored,$error,$testcaseNode,$testName,$className);
	    foreach my $node ($nodeset->get_nodelist) {
		$testName = $node->findvalue('@name');
		$className = $node->findvalue('@classname');
		$key=$className.'#'.$testName;
		my $failure = $node->findvalue('failure');
		my $error = $node->findvalue('error');
		my $ignored = $node->findvalue('skipped');
		$passfail ="P";
		if ($failure ne "" ){
		    $passfail="F";
		}
		if ($error ne "" ){
		    $passfail="E";
		}
		if ($ignored ne "" ){
		    $passfail="I";
		}
		my $v=$collector{$key};	    
		
		if ( defined $v ) {
		    $v.=$passfail;
		} else {
		    $v=$passfail;
		}
		$collector{$key} =$v;
#		print qq($key=$passfail\n);
		#	print qq($className,$testName,$passfail\n);
	    }
	    # add a commad in all cases
	}
	foreach $key (sort keys %collector) {
	    $collector{$key} .=',';
	}
    }
}

open(COL, ">collector.csv") or
    die qq(cannot open file collector.csv for write\n);
foreach $key (sort keys %collector) {
#while (($key,$value) = each %collector) {
    print COL qq($key=$collector{$key}\n);
}
close(COL);
