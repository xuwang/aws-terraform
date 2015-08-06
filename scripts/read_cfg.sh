#!/bin/bash
# Read INI formatted file, return the value of a given key in a given section
# E.g. ./read_cfg.sh FILE SECTION INI_VAR
while [ $# -gt 0 ]
do
    case $1 in 
    * )
	if [ -z "$INI_FILE" ]
        then
            INI_FILE=$1
        else 
            if [ -z "$INI_SECTION" ]
            then
                INI_SECTION=$1
            else
		if [ -z "$INI_VAR" ]
                then
		    INI_VAR=$1
                fi
            fi
        fi
        ;;
    esac
    shift
done

if [ -z "$INI_FILE" ] || [ -z "$INI_SECTION" ] || [ -z "$INI_VAR" ]
then
    echo -e "Usage: $(basename $0) FILE SECTION INI_VAR"
    exit 1
fi

if [ ! -f $INI_FILE ] 
then
    echo "$INI_FILE doesn't exist."
    exit 1
else
    if ! grep -q "$INI_SECTION" $INI_FILE
    then
        echo "$INI_SECTION doesn't exist."
        exit 1
    fi
fi

in_section="false"
while read -r line || [ -n "$line" ]
do
   if [[ "${line}" =~ \[${INI_SECTION}\] ]] && [[ $in_section = "false" ]]
   then
       in_section="true"
       continue
   else
       if [[ "${line}" =~ "${INI_VAR}" ]] && [[ $in_section = "true"  ]]
       then
           line=`echo "$line" | sed 's/[[:space:]]=[[:space:]]/=/'`
           echo "${line/${INI_VAR}=/}"
           break
       fi
    fi 
done <"${INI_FILE}"
