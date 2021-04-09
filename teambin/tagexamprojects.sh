#!/bin/bash

function tagProject(){
    local projectfile=$1
    shift 
    local grp=$1
    sed -i "s@examproject</name>@examproject-${grp}</name>@" ${projectfile}
}

for g in g*; do

    for file in $(find ${g} -name project.xml -o -name pom.xml); do
	tagProject ${file} ${g}
    done
done
