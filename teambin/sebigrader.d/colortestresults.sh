#!/bin/bash

filename=$1; shift
l=$(tail -1  ${filename})
IFS=',' read -r -a arr <<<  "${l}"
IFS=',' read -r -a colors <<< "\e[32m,\e[33m,\e[31m,\e[38m"
coloridx=0
set --  "${arr[@]}"
shift
while (($#)) ; do
    i="$1"; shift
    if [[ ! "${i}" =~ ^[0-9]+$ ]]; then
	break;
    fi
    echo -e -n "${colors[$coloridx]}"
    while [ ${i} -gt 0 ]; do
	echo -e -n "\U0002588"
	i=$((${i}-1))
    done
    coloridx=$((${coloridx}+1))
done
echo -e  "\e[m\t ${l}"
