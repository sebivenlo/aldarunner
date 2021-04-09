#!/bin/bash
SVN=/usr/bin/svn
## collect svn incoming (Add, Delete or Update) into ${g}/incoming.r<revision number>
while [ "$#" -gt 0 ] ; do
    g=$1; shift
    if [ -d ${g}/.svn ]; then
	${SVN} cleanup -q ${g}
	${SVN} cleanup -q --remove-ignored ${g}
	${SVN} up ${g} |  grep -P '^[ACDGMU] ' | tee ${g}/incoming.tmp
	${SVN} info ${g} | tee ${g}/svninfo.current
	## save and extract revision number
	rev=$(${SVN} info --show-item revision ${g})
	## just the number
	## rename the incoming file
	mv ${g}/incoming{.tmp,.${rev}}
	## for all project dirs write last-changed-revision.txt that can be sourced by bash
	svninfo2symbols.sh ${g}
    fi
done
