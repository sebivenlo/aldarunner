#!/bin/bash

## find css and images in directory above file
## and substite links to ./css and ./images with the found dirs.
function fixsurefireresource(){
    local file=$1; shift
    echo fixing ${file}
    opwd=$(pwd)
    dir=..
    cssdir=''
    imagesdir=''
    cd $(dirname ${file})
    while [ "$(readlink -f ${dir})" != "/" ]; do
	if [ -d "${dir}/css" ]; then
	    cssdir="${dir}/css"
	    imagesdir="${dir}/images"
	    break;
	fi
	dir="../${dir}"
    done
    
    if [ -n "${cssdir}" -a -d "${cssdir}" ]; then
	echo "found resources at ${cssdir} and ${imagesdir}"
	cd ${opwd}
	sed -i "s#./css/#css/#g;s#css/#${cssdir}/#g;s#./images/#images/#g;s#images/#${imagesdir}/#g"  ${file}
    else
	cd ${opwd}
	echo "resources not found"
    fi
}

dir=$1; shift
for f in $(find ${dir} -name surefire-report.html); do
    fixsurefireresource ${f}
done
