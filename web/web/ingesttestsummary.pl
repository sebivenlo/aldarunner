#!/usr/bin/perl -w
##
## insert test data for project group and task into database
## arg 0 is prjm_id like 1011
## arg 1 is group number
## arg 2 is project like 'wk01/name' as stored in apps-list.txt
## arg 3 is svn revision 
## arg 4 testsummary file-name
my $numargs=$#ARGV+1;
if ($numargs < 5) {
    die qq(need prjm_id, grp, task, rev, testsummary file like 1011 g105 wk01/fraction 42 testsummary.csv \n);
}
my ($prjm_id,$grp,$task,$project,$revision,$fname);
my ($lastLine,@parts,$grp_num,$tests, $passed, $fails, $errs, $skips, $time);
$prjm_id=$ARGV[0];
$grp=$ARGV[1];
$task=$ARGV[2];
$revision=$ARGV[3];
$fname=$ARGV[4];
$grp =~ s/^g0*//;
$grp_num = int($grp);
# print qq($fname $grp $task\n);
if ( -f $fname ){
    open(TSF,"<$fname") or die qq (cannot open file $fname\n);
    while(<TSF>){
	chomp;
	# print qq($_);	
	$lastLine=$_;
    }
    close(TSF);
    ($tests, $passed, $fails, $errs, $skips, $time) =split/,/,$lastLine;
    print qq(insert into sebi_homework_tasks 
	     (prjm_id, grp_num, task, revision, tests, passed, fails, errs, skips, test_time)
	     values($prjm_id,$grp,'$task',$revision, $tests, $passed, $fails, $errs, $skips, $time);\n);
}

