#!/usr/bin/perl -w
use File::stat;
use Cwd qw(cwd);
my ($filename,$size,$run_file,$problem_file,$orginal_file,$exam,%repairs);
## in exam folder
## deletes files that cause compiler errors

## assume file names with struct sw/EXAM362/boxes/site/compiler-error.txt come in
## if file size > 0
while(<>){
    chomp;
    if (/.*compiler-error.txt$/) {
	$filename = $_;
	$size = -s $filename;
	if ($size > 0) {
#	    print qq ($filename size $size\n);

	    $run_file = $filename;
	    $run_file =~ s/compiler-error.txt$//;
	    $run_file .='mvn-run-out.txt';
	    open(ERF, "<$run_file") or die qq(cannot open $run_file\n);
	    while (<ERF>) {
		chomp;
		if (/^\[ERROR\].*(EXAM\d{3})((\/.*.java)?):/) {
		    $exam=${1};
		    $problem_file=substr(${2},1);
		    $repairs{"${exam}:${problem_file}"}='x';
		}
	    }
	    close(ERF);
	}
    }
}

my ($problem,$repair_file,$project,$tail);
my $wdir=cwd;
foreach $problem (sort keys %repairs) {
    print qq(problem in \033[41m${problem}\033[m\n);
    ($exam,$problem_file)= split(/:/,$problem);
    ($project,$problem_file) = split(/\//,$problem_file,2);
    $orginal_file="examproject/${project}/${problem_file}";
    $repair_file="sw/${exam}/${project}/exam_repairs.sh";
    print qq(## creating repair file $repair_file\n);
    open(REP,">$repair_file") or die qq(cannot open repair file $repair_file\n);
    if ( -e  "examproject/${problem_file}" ){
	print REP qq(## exam ${exam} has problematic new file \033[33m${problem_file}\033[m, \033[42mreplaced\033[m\n);
	print REP qq(cp ${wdir}/${orginal_file} ${problem_file}\n);
    } else {
	print REP qq(## exam ${exam} has problematic new file \033[31m${problem_file}\033[m, \033[41mremoved\033[m\n);
	print REP qq(rm -f ${problem_file}\n);
    }
    close(REP)
}
## NOTE: If a file is in err, and it exists in the examproject, copy it from the examproject.
## else drop it.
