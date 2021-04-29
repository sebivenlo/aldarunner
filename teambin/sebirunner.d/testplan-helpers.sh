#!/bin/bash


function makeTestSummaries(){
    for dir in $(find . -name surefire-reports); do
	sitedir=$(dirname $dir)/site
	#	repdir=target/surefire-reports
	mkdir -p ${sitedir}
	find ${dir} -name "*.txt" -exec cat {} \; | sebitestsummary | tee  ${sitedir}/testsummary.csv
    done
}

function makeJacocoSummaries(){
    for dir in $(find . -name jacoco -type d); do
	sitedir=$(dirname ${dir})
	jfile="${dir}/jacoco.csv"
	if [ -s ${jfile} ]; then
	    jacocosummary ${jfile} > ${sitedir}/jacocoCoverage.txt
	fi
    done
}

## execute the tests with coverage measurement.
## @pre The src tree and pom file are prepared.
## @post the test results are aggregated under target/site/
## @param arena the place where the tests are executed.
## 
function testWithJacoco(){
    local arena=$1; shift
    local app=$(basename $(dirname ${arena}))/$(basename ${arena})
    local grp=$(basename $(dirname $(dirname ${arena})))

    (
	cd ${arena}
	for t in $(find . -name target -type d); do
	    rm -fr $t
	done
	mkdir -p target/site
	## no need to do things twice
	# timeout 60s mvn -q -fn -P jacoco test -Djacoco.report.title="Coverage report for ${grp} ${app} " jacoco:report \
	    # 	| tee mvn-run-out.txt | grep "COMPILATION ERROR" > compiler-error.txt
	echo running test and reporting maven task
	timeout 60s mvn -q -fn -P jacoco test -Djacoco.report.title="Coverage report for ${grp} ${app} " \
		jacoco:report  \
	    | tee -a target/site/mvn-run-out.txt | grep "COMPILATION ERROR" > target/site/compiler-error.txt
	mvn -q -Dsurefire.report.title="Surefire Report ${grp} ${app}" surefire-report:report-only
	echo maven task completed
	makeTestSummaries
	makeJacocoSummaries
	## remove false negatives
	find . -name compiler-error.txt -empty  -exec rm -f {} \;
	# combine into target/site
	#mv *.txt *.csv target/*.csv 
	for f in $(compgen -G "*.txt"; compgen -G "*.csv" ; compgen -G "target/*.csv" ); do
	    mv ${f} target/site
	done
    )   
}

## execute the tests with coverage measurement.
## @pre The src tree and pom file are prepared.
## @post the test results are aggregated under target/site/
## @param arena the place where the tests are executed.
## 
function fastWithJacoco(){
    local arena=$1; shift
    local app=$(basename $(dirname ${arena}))/$(basename ${arena})
    local grp=$(basename $(dirname $(dirname ${arena})))

    (
	cd ${arena}
	for t in $(find . -name target -type d); do
	    rm -fr $t
	done
	mkdir -p target/site
	## no need to do things twice
	# timeout 60s mvn -q -fn -P jacoco test -Djacoco.report.title="Coverage report for ${grp} ${app} " jacoco:report \
	    # 	| tee mvn-run-out.txt | grep "COMPILATION ERROR" > compiler-error.txt
	echo running test and reporting maven task
	timeout 60s mvnd -q -fn -P jacoco test -Djacoco.report.title="Coverage report for ${grp} ${app} " \
		jacoco:report  \
	    | tee -a target/site/mvn-run-out.txt | grep "COMPILATION ERROR" > target/site/compiler-error.txt
	mvnd -q -Dsurefire.report.title="Surefire Report ${grp} ${app}" surefire-report:report-only
	echo maven task completed
	makeTestSummaries
	makeJacocoSummaries
	## remove false negatives
	find . -name compiler-error.txt -empty  -exec rm -f {} \;
	# combine into target/site
	#mv *.txt *.csv target/*.csv 
	for f in $(compgen -G "*.txt"; compgen -G "*.csv" ; compgen -G "target/*.csv" ); do
	    mv ${f} target/site
	done
    )   
}

## @param arena 
## @param site as in siteBB
function moveToSite(){
    local arena=$1; shift
    local siteName=$1; shift
    echo -e "\e[36mmove to site ${arena} ${siteName}\e[0m"
    if [ -d ${arena}/${siteName} ]; then
	return
    fi
    if [ -d ${arena}/target/site ] ; then
	mv ${arena}target/site ${arena}/${siteName}
    fi
    find ${arena} -mindepth 1 -maxdepth 1 -name "*.txt" -exec mv {} ${arena}/${siteName} \;
    find ${arena} -mindepth 1 -maxdepth 1 -name "*.csv" -exec mv {} ${arena}/${siteName} \;
    echo -e "\e[36mmove complete\e[m"
}

export -f testWithJacoco

