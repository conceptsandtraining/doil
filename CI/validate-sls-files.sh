#!/bin/bash

LOCATION=${1}

if [[ -z ${LOCATION} ]]
then
	echo "Usage ./validate-sls-files.sh <path-to-sls-folder>"
	exit
fi

ERROR=FALSE
FILES=$(find . -type f -name "*.sls")
for FILE in ${FILES}
do
	# ignore init and top files
	if [[ ${FILE} == *"top.sls"* ]]
	then
		continue
	fi

	TMPFILE="${FILE}.tmp"
	touch $TMPFILE

    echo "---" > ${TMPFILE}
	sed 's/{%.*%}//' ${FILE} >> ${TMPFILE}
    sed 's/{{.*}}/bar/' ${TMPFILE} > ${TMPFILE}.tmp
	mv ${TMPFILE}.tmp ${TMPFILE}

	TEST=$(yamllint -c ./CI/sls-lint-rules.yml ${FILE}.tmp)
	if [[ ! -z "${TEST}" ]]
	then
		echo ${TEST}
		ERROR=TRUE
	fi

	rm ${FILE}.tmp
done

if [[ ${ERROR} == TRUE ]]
then
	exit 1
fi
exit 0