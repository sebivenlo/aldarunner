#!/bin/bash
## runs test fro one student

if [ $# -lt 2 ]; then
    echo supply grp and app
    exit 0
fi
grp=$1; shift
app=$1; shift
export RAMDISK=/media/ramdisk
pid=$(echo $$)
ARENA=${RAMDISK}/sebirunner-${pid}
export PATH=~/teambin/sebirunner.d:$PATH
if [ ! -s config.properties ]; then
    echo "please provide config.properties file in current dir."
    exit 1
fi
source config.properties
source ~/teambin/sebirunner.d/sebirunner.lib
## check if there is work done
#svnup ${grp}

if checkWork ${publish_host} ${publish_basedir} ${grp} ${app} ; then
    testplan="solutions/${app}/testPlan.sh"
    ring=${ARENA}/${grp}/${app}/
    mkdir -p ${ring}
    echo "the arena is ${ring}"
    if [ -s ${testplan} ]; then
	## assume it to be an alda problem.
	bash ${testplan} ${ring} ${grp} ${app}
    else
	echo prc2 default tests ${grp} ${app}
	bash ~/teambin/sebirunner.d/defaultTestPlan.sh ${ring} ${grp} ${app}
    fi
    mvnOutToHtml ${ring} ${grp} ${app}
    publishResults ${publish_host} ${publish_basedir} ${ARENA} ${grp} ${app}
fi

if [ -z "${SEBI_DEBUG}" ]; then
    rm -fr ${ARENA}
fi
