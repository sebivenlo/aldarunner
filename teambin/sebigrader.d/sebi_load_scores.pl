#!/usr/bin/perl -w
# read template.csv and result.csv
# create sql insert statements for them.
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
print qq(
truncate questions restart identity cascade;
truncate students cascade;
);

open(STUDENTS, "< students.csv") or  die qq(cannot open students.csv file, cannot continue
);

open(STICKS, "< sticks.csv") or  die qq(cannot open sticks.csv file, cannot continue
    run grade first
);

open(TEMPLATE, "< template.csv") or  die qq(cannot open template.csv file, cannot continue
    run grade first
);
open(RESULT, "< result.csv") or  die qq(cannot open result.csv file, cannot continue
    run grade first
);
my $qCount=1;
my ($mevent, $stick, $testclass, $method, $passfail, $weight,$score,$class_method, $snr,$snummer);
my $project;
my $cat='@';
my $oProject='';
while(<TEMPLATE>){
    chomp;
    ($mevent, $project, $testclass, $method, $passfail, $weight)=split/[,;]/;
    if ($mevent eq $event) {
	if ($oProject ne $project){
	    $oProject=$project;
	    $cat=chr(ord($cat)+1);
	}
	$classmethod=$testclass.'#'.$method;
	print qq(insert into questions (event,question_nr,cat,test_method,weight)
		 values ('$mevent',$qCount,'$cat','$classmethod', 1);\n);
	$qCount++;
    }
}

while(<RESULT>){
    chomp;
    ($mevent, $stick, $testclass, $method, $passfail, $score)=split/[,;]/;
    if ($stick =~m/EXAM(\d{3})/) {
	$snr=$1;
	$classmethod=$testclass.'#'.$method;
	print qq(
with q as (select question_id from questions where event='$mevent' and test_method='$classmethod')
insert into scores (stick_nr,question_id,pass_fail,score) select $snr,q.question_id,'$passfail', $score from q
on conflict(stick_nr,question_id) do update set (pass_fail,score,remark) 
= (EXCLUDED.pass_fail, EXCLUDED.score, EXCLUDED.remark) ;
);
  }
}

while (<STUDENTS>){
  chomp;
  ($snummer, $achternaam, $roepnaam, $sclass, $voorletters, $lang,
   $prjm_id, $alias, $token, $cohort, $email1, $education, $lo)= split/[,;]/;
  if ($snummer =~ m/^\d+$/){
    print qq(insert into students (snummer, achternaam, roepnaam, sclass, voorletters, lang,
   prjm_id, alias, token, cohort, email1, education, lo)
  select $snummer, '$achternaam', '$roepnaam', '$sclass', '$voorletters', '$lang',
   $prjm_id, '$alias', '$token', $cohort, '$email1', '$education', $lo where $snummer not in (select snummer from students);\n);
  }
}

while (<STICKS>){
  chomp;
  ($stick,$snummer) =split/[,;]/;
  if ($snummer =~ m/^\d+$/){
    print qq(insert into exam_candidates (event,stick_nr,snummer) values('$event',$stick,$snummer);\n);
  }
}

close(STUDENTS);
close(STICKS);
close(RESULT);
close(TEMPLATE);
print qq(\n);
