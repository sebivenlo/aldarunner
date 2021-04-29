#!/bin/bash

while [ $# -gt 0 ]; do
    g=$1; shift
    ## look at pom files, maven module parent has nr src, only pom.xml
    for s in $(find ${g} -name pom.xml -type f | sort); do
	
	/usr/bin/svn info $(dirname $s) | \
	    sed -re 's/"hom"/"www-data"/;s/:\s(.+)/="\1"/;s/\s/_/;s/Changed /Changed_/;s/ Root /_Root_/' \
		> $(dirname $s)/last-changed-revision.txt
    done
done
