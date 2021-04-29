#!/bin/bash
for f in $(find sw -name compiler-error.txt); do
    if [ -s ${f} ] ; then
	echo "${f/site\/compiler-error.txt}"
    fi
done
