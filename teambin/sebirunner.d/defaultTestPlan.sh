#!/bin/bash
## @param arena, sandbox to run tests in
## this script is started in student dir
export PATH=~/teambin/sebirunner.d/:${PATH}
arena=$1; shift
grp=$1; shift
app=$1; shift
if [ ! -d "${arena}" ]; then
    echo broken no arena
    exit 1;
fi

if [ ! -d "${grp}/${app}" ]; then
    echo grp/app not found
    exit 2
fi

if [ ! -d "solutions/${app}" ]; then
    echo cannot find solution/app
    exit 3
fi

source ~/teambin/sebirunner.d/testplan-helpers.sh

## cp all student sources to arena
rm -fr ${arena}/*
rsync -aq ./${grp}/${app}/ ${arena}/
## patch pom file
sed -e "s/solution/${grp}/"  < solutions/${app}/pom.xml > ${arena}/pom.xml
## run tests:## rename target/site to siteBB
testWithJacoco ${arena}
moveToSite ${arena} siteBB
# mv ${arena}/{target/site,siteBB}
# mv ${arena}/*.txt ${arena}/siteBB

## AB test
find ${arena}/ -name target -type d -exec rm -fr {} \;
rm -fr ${arena}/src/test/
rsync -aq ./solutions/${app}/src/test/ ${arena}/src/test/
testWithJacoco ${arena}
moveToSite ${arena} siteAB
# mv ${arena}/{target/site,siteAB}
# mv ${arena}/*.txt ${arena}/siteAB
exit 0
## EOF

