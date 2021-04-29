#!/usr/bin/perl -w
my $taskNr=$ARGV[0];
my $project=$ARGV[1];
my ($testName,$className);

my (@pp) = split/\//, $project;
my @dummy;
open(FILE,"<$project") or die qq(can not open project file $project\n );
while(<FILE>){
    if (/\<testcase name="(\S+)" classname="(\S+)"/) {
	$testName =$1;
	$className=$2;
	(@dummy) = split(/\./,$className);
	$className=$dummy[-1];
#	print qq($testName\n);
	if ($testName =~ /t[ABCDE](\\d+)?([abcdefgh]?)/) {
	    print qq($taskNr,$pp[1],$className,$testName,10\n);
	}
    }
}

close(FILE);
