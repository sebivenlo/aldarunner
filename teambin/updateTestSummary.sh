#!/bin/bash

while [ $# -ge 1 ]; do
    grp=$1; shift
    tests=0
    passed=0
    failed=0
    errors=0
    ignored=0
    if [ ! -d ${grp} ] ; then continue; fi
    for dir in $(find ${grp} -name "site*" -type d); do
	file=${dir}/testsummary.csv
	if [ -s ${file} ]; then
	    x=$(tail -1 ${file})
	    OLDIFS="$IFS"
	    IFS=',' read -ra LINE <<< "$x"
	    IFS="${OLDIFS}"
	    tests=$((${tests}+${LINE[0]}))
	    passed=$((${passed}+${LINE[1]}))
	    failed=$((${failed}+${LINE[2]}))
	    errors=$((${errors}+${LINE[3]}))
	    ignored=$((${ignored}+${LINE[4]}))
	fi
    done
    
    echo -e "tests,passed,failed,errors,ignored\n${tests},${passed},${failed},${errors},${ignored}" | tee ${grp}/alltestssummary.csv
done


