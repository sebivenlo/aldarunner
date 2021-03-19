#!/bin/bash

if [ $# -lt 3 ]; then
    cat <<EOF
    This program assumes that 
      1) you are in the parent of all project repos and
      2) the <project> you are about to inject into the repo is unpacked in this directory too, in a subdir named <project-name>.
    You then invoke this project, stating the <week-directory>, <group>, and <project_name>  with:
    echo $0 <week-directory> <group> <project-name>"
EOF
    exit 1
fi
wd=$(pwd)

week=$1
shift
group=$1
shift
project_name=$1

file_url=file://${wd}/${group}/trunk/${week}/${project_name}
shift
echo "$week ${group} ${project_zip} to ${file_url}"
sudo -u www-data svn import -m"'import week ${week} ${project_name} to ${file_url}'" ${project_name} ${file_url}
