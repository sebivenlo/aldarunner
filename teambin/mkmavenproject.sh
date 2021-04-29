#!/bin/bash

if [ $# -lt 1 ]; then
    echo usage groupid artifactId
    exit 1
fi

my_groupId=$1; shift
my_artifactId=$1; shift
my_version=1.0-SNAPSHOT
if [ $# -gt 0 ]; then
    my_version=$1; shift
fi
mvn  archetype:generate                  \
  -DarchetypeGroupId=nl.fontys.sebivenlo \
  -DarchetypeArtifactId=sebiproject-archetype    \
  -DarchetypeVersion=1.0-SNAPSHOT         \
  -DgroupId=${my_groupId} \
  -DartifactId=${my_artifactId} \
  -Dversion=${my_version}
