#!/bin/bash
scriptdir=$(dirname $0)
source ../default.properties
exam_date=$(basename $(pwd))

db=${module_name}_${exam_date}

dropdb --if-exists  ${db} &> /dev/null
createdb ${db}  &> /dev/null
cat ${scriptdir}/config/sebiresultschema.sql | psql -q -X ${db} &> /dev/null
echo -e "created database \e[34m${db}\e[m"
