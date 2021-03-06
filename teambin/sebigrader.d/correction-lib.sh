#!/bin/bash
## helpers to correct a bunch of maven projects with AB tests
## expects to be run in a directory containing examproject and examsolution
## 

if [ ! -d examproject ]; then
    echo "cannot find an examproject"
fi

if [ ! -d examsolution ]; then
    echo "cannot find an examsolution"
fi


if [ -z "${ARENA}" ]; then
    ARENA=/media/ramdisk/
fi
export ARENA
echo "all battles in ${ARENA}"

## 
## @param SANDBOXES
## @param APP e.g templateengine
## @param EXAM eg EXAM124
## @param ROUND e.g B0
function prepSandbox(){
    local SANDBOXES=$1; shift
    local APP=$1; shift
    local EXAM=$1; shift
    local ROUND=$1; shift
    local examdir=${SANDBOXES}/examproject-${EXAM}/${APP}
    local arena=${ARENA}/${EXAM}-${APP}-${ROUND}
    if [ ! -d ${examdir} ]; then
	echo -e "\033[41m $examdir does not exist \033[m"
	exit 1
    fi
    echo -e "\033[7mcreate arena ${arena} for ${EXAM} round ${ROUND}\033[m"
    rm -fr ${arena}
    mkdir -p ${arena}/target/classes
#    mkdir -p ${arena}/src/{main,test}/java
    # if [ -d examsolution/${APP}/src/main/resourcescd / ]; then
    # 	rsync -a examsolution/${APP}/src/main/resources/ ${arena}/target/classes/
    # fi
    cp examsolution/${APP}/pom.xml ${arena}
    # default to AA round
    local  asrc=examsolution/${APP}/target/classes
    local atest=examsolution/${APP}/target/test-classes
    local  bsrc=${examdir}/target/classes
    local btest=${examdir}/target/test-classes
    ## First char describes tes, second source
    case ${ROUND} in
	AA)
	    TEST=${atest}
	     SRC=${asrc}
	    ;;
	AB)
	    TEST=${atest}
	     SRC=${bsrc}
	    ;;
	BA)
	    TEST=${btest}
	     SRC=${asrc}
	    ;;
	B0)
	    TEST=${btest}
	    SRC=examproject/${APP}/target/classes0
	;;
	B[1-9])
	    TEST=${btest}
	    local R=${ROUND:1}
	    SRC=examsolution/${APP}/target/classes${R}
	;;
    esac
    echo "  prep ${ROUND} for exam dir ${EXAM}"
    echo -e "  src=${SRC}\n  test=${TEST} for ${EXAM}"
    test -d ${SRC} \
    && test -d ${TEST} \
    && rsync -a  ${SRC}/ ${arena}/target/classes/ \
    && rsync -a ${TEST}/ ${arena}/target/test-classes/

}

##
## Run the tests in a prepared arena
## @param SANDBOXES where code and tests are
## @param arena where code and tests are
## @param APP the  application name
## @param EXAM the exam number, eg. EXAM124
## @param the round, one of AA AB BA BB B0 B[1..9]

function runTests(){
    local SANDBOXES=$1; shift
    local arena=$1; shift
    local APP=$1; shift
    local EXAM=$1; shift
    local ROUND=$1; shift
    local startdir=$(pwd)
    local ring=${arena}/${EXAM}-${APP}-${ROUND}
    local reportdir=${SANDBOXES}/examproject-${EXAM}/${APP}/${ROUND}-surefire-reports
    echo "  find the reports in ${reportdir}"
    mkdir -p ${reportdir}
    cd ${ring}
    mkdir -p target/surefire-reports
#    mvn -fae -q compile test-compile > compiler-out.txt
    mvn -fae -q surefire:test | tee mvn-run-out.txt
    #cp reports
    rsync -a target/surefire-reports/ ${startdir}/${reportdir}/
    cp  mvn-run-out.txt ${startdir}/${reportdir}/
    cd ${startdir}
    cp  ${SANDBOXES}/examproject-${EXAM}/${APP}/compiler-out.txt ${startdir}/${reportdir}/
    rm -fr ${ring}
}


##
## prepare areana and run test
## @param SANDBOXES
## @param APP the  application name
## @param EXAM the exam number, eg. EXAM124
## @param the round, one of AA AB BA BB B0 B[1..9]
function prep_and_run(){
    local SANDBOXES=$1 ; shift
    local APP=$1 ; shift
    local exam=$1 ; shift
    local round=$1 ; shift
    prepSandbox ${SANDBOXES} ${APP} ${exam} ${round}
    runTests ${SANDBOXES} ${ARENA} ${APP} ${exam} ${round}
}

##
## run all tests B[1..9]
## @param SANDBOXES
## @param APP the  application name
## @param EXAM the exam number, eg. EXAM124
function all_bx_rounds(){
    local SANDBOXES=$1 ; shift
    local APP=$1 ; shift
    local exam=$3 ; shift
    for t in {1..9}; do
	broken_business=examsolution/${APP}/src/main/java${t}
	if [ -d ${broken_business} ]; then
	    prep_and_run ${SANDBOXES} ${APP} ${exam} B${t}
	fi
    done
}


## run all tests AB BB BA B0 tests
## @param SANDBOXES
## @param APP the  application name
## @param EXAM the exam number, eg. EXAM124
function all_AB_rounds(){
    local SANDBOXES=$1 ; shift
    local APP=$1 ; shift
    local exam=$1 ; shift
    for r in AB BA BB B0; do
	prep_and_run ${SANDBOXES} ${APP} ${exam} ${r}
    done
}

## run all tests rounds
## @param SANDBOXES
## @param APP the  application name
## @param EXAM the exam number, eg. EXAM124
function all_rounds(){
    local SANDBOXES=$1 ; shift
    local APP=$1 ; shift
    local exam=$1 ; shift 
    all_AB_rounds ${SANDBOXES} ${APP} ${exam}
    all_bx_rounds ${SANDBOXES} ${APP} ${exam}
}


