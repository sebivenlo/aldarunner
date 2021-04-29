#!/usr/bin/perl -w
use XML::XPath;
use XML::XPath::XMLParser;
use Config::Properties;
use Cwd;
use File::Basename;

my $properties = new Config::Properties();
open PROPS, "../default.properties" or die qq(cannot load ../default.properties\n);
$properties->load(*PROPS);
my $module_name=$properties->getProperty('module_name', 'PRC1');
my $mydir=getcwd;
my $exam_date=basename($mydir);
my $event=$module_name.$exam_date;

if ($#ARGV  <0 ){
    print STDERR qq(Usage: testxml2gradelist.pl <examnr> <filename>
    like 
       testxml2gradelist.pl EXAM100 sw/EXAM100/anagrams/target/surefire-reports/TEST-anagrams.ReversedCollectionSizeComparatorTest.xml
    or
       testxml2gradelist.pl EXAM000 examsolution/anagrams/target/surefire-reports/TEST-anagrams.ReversedCollectionSizeCompara
);
    exit 1;
}

my $examNr=$ARGV[0];
my $xmlFile=$ARGV[1];

# if ($xmlFile =~ m/^.*?(EXAM\d{3}).*$/) {
#     $examNr=$1;
#     print STDERR qq (found $examNr in $xmlFile\n);
# } else {
#     die qq(cannot find exam number in $xmlFile\n);
# }

my $xp = XML::XPath->new(filename => "$xmlFile");


my $nodeset = $xp->find('//testsuite/testcase'); # find all paragraphs
my ($passfail,$failure,$ignored,$error,$testcaseNode,$testName,$className);
foreach my $node ($nodeset->get_nodelist) {
    my $testName = $node->findvalue('@name');
    my $className = $node->findvalue('@classname');
    my $failure = $node->findvalue('failure');
    my $error = $node->findvalue('error');
    my $ignored = $node->findvalue('skipped');
    $passfail ="P,10.0";
    if ($failure ne "" ){
	$passfail="F,1.0";
    }
    if ($error ne "" ){
	$passfail="E,1.0";
    }
    if ($ignored ne "" ){
	$passfail="I,1.0";
    }
    print qq($event,$examNr,$className,$testName,$passfail\n);
}

