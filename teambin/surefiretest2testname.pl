#!/usr/bin/perl -w
while(<>){
    chomp;
    if (m/\<testcase name="(.+)?" classname=.*$/) {
	print qq($1;1\n);
    }
}
