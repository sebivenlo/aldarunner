= steps

Modes:
AA : prep, teacher test on teacher code
products: ids of tests

AB: teacher test on student code, does student business meet teacher requirement
BB: student test on students code, should have high coverage
BA: student test on teacher code, should be all green. 
B0: student test on pristine project, lots of red but not necessarily all
B1: additional student test on puprosely broken code, more red
Bn: , ,

sources (first is test, second is business)
AA: solution, solution
AB: solution, student project
BB: student project, student project
BA: student project, solution
B0: student project, pristine examproject
B1: student project, solution/java1
Bn: student project, solution/javan

pom always comes from solution.

preping arena:
ring=${arena}/${grp}/${app}
mkdir -p ${ring}/src/{main,test}

testsrc=...
busysrc=...
rsync -av ${testsrc}/ ${ring}/src/test/
rsync -av ${busysrc}/ ${ring}/src/main/
cp ${soldir}/${app}/pom.xml ${ring}/
# run tests
# make sure required reports are in place
# copy (rsync) reports to publish location, like siteBB, siteAB etc.
