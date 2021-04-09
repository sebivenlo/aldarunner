#!/usr/bin/perl -w
my ($recfile,$datum,$subject,$lang,$langlc);

$recfile='setup.csv';
if ( ($#ARGV+1) > 0 ) {
    $recfile=$ARGV[0];
}
print qq(#!/bin/bash
mkdir -p out
);
open(REC,"<$recfile") or die qq(cannot open file setup.csv, please correct\n);
my $count=0;
while(<REC>){
    $count++;
    chomp;
    ($subject,$lang) = split/;/;
    $langlc=lc($lang);
    if (defined $subject){
    print qq((
for i in 1 2; do
pdflatex -jobname=doc_${langlc} -output-directory out <<EOF > /dev/null
\\documentclass[10pt,oneside,dvipsnames]{article}
\\usepackage[utf8]{inputenc}
\\providecommand\\StudentId{${subject}~\\ExamDate}
\\providecommand\\StickNr{${lang}}
\\input assessmentdoc_${langlc}
EOF
done
)&
);
}}
# make sure the program waits for all children 
print qq(
wait

if [ -e out/doc_en.pdf ] ; then
    cp out/doc_en.pdf .
    echo doc_en.pdf
else
    cat out/*.log
fi
);
