#! /bin/bash
#*******************************************************************************
#
# AFS © Antidot 2013
#
#*******************************************************************************
function vercomp () {
	if [[ $1 == $2 ]]
	then
		return 0
	fi
	local IFS=.
	local i ver1=($1) ver2=($2)
	for ((i=${#ver1[@]}; i<${#ver2[@]}; i++))
	do
		ver1[i]=0
	done
	for ((i=0; i<${#ver1[@]}; i++))
	do
		if [[ -z ${ver2[i]} ]]
		then
			ver2[i]=0
		fi
		if ((10#${ver1[i]} > 10#${ver2[i]}))
		then
			return 1
		fi
		if ((10#${ver1[i]} < 10#${ver2[i]}))
		then
			return 2
		fi
	done
	return 0
}

function gen_tag_file() {
    set -u
    output=$1
    input=$2
    set -e

    cat > ${output} << EOF
<?xml version='1.0' encoding='UTF-8' standalone='yes' ?>
<tagfile>
EOF

    for line in $(cat ${input})
    do
        classPart=${line%%;*}
        if [[ "${line}" == *";"* ]]
        then
            methodPart=${line#*;}
        else
            methodPart=""
        fi

        className=${classPart##*.}
        withoutClassName=${classPart/.${className}/}
        group=${withoutClassName##*.}
        fullPathName=${classPart//./\/}

        link=../javadoc/${fullPathName}.html

        cat >> ${output} << EOF
  <compound kind="class">
    <name>${group}::${className}</name>
    <filename>${link}</filename>
EOF

        IFS=\;
        for method in ${methodPart}
        do
            methodName=${method%(*}

            cat >> ${output} << EOF
    <member kind="function">
      <name>${methodName}</name>
      <anchorfile>${link}</anchorfile>
      <anchor>${method}</anchor>
      <arglist>(dummyArg)</arglist>
    </member>
EOF
        done

        cat >> ${output} << EOF
  </compound>
EOF
    done

    cat >> ${output} << EOF
</tagfile>
EOF
}

DUMMY=$(which doxygen)
if [ "$?" != "0" ]
then
    echo "Please install doxygen on your computer or add it to your PATH"
    exit 1
fi

VERSION=$(doxygen --version)
EXPECTED="1.8.5"
vercomp $VERSION $EXPECTED
COMP=$?

if [ "$COMP" -eq "2" ]
then
	echo "[1;31m[WARNING] Recommanded doxygen version is $EXPECTED whereas your version is $VERSION"
    echo "[WARNING] You should consider to use a more recent version of doxygen.[0m"
fi

gen_tag_file class.tags class_list.txt

rm -rf javadoc
javadoc -charset "UTF-8" -encoding "UTF-8" -docencoding "UTF-8" -windowtitle "Antidot Java API" -doctitle "Antidot Java API" -bottom "Copyright© 2013 Antidot and/or its affiliates. All rights reserved." -keywords -version -use -d $PWD/javadoc -sourcepath $PWD/../src/main/java/ -group "Common Packages" "net.antidot.api.common.*" -group "Antidot search engine API" "net.antidot.api.search.*" -group "Antidot PaF management" "net.antidot.api.upload.*" net.antidot.api.common net.antidot.api.search net.antidot.api.upload

doxygen afs_lib.doxygen
