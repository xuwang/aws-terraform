#!/bin/bash
# 
# xuwang@gmail.com
# 
# Use AWS keypair as a 'lock' mechanism to protect some operations that should only be run
# by one team mate, e.g. updating terraform states. Only the person who owns the keypair's private key can
# perform the operation. 
# 
# Usage:
# session-lock -l
# <some operations>
# session-lock -u
# 

AWS_PROFILE=${AWS_PROFILE:-coreos-cluster}
CLUSTER_NAME=${CLUSTER_NAME:-coreos-cluster}
AWS_ACCOUNT=${AWS_ACCOUNT:-}
AWS_REGION=${AWS_REGION:-us-west-2}
ROOTDIR=${ROOTDIR:-`PWD`}

# Default keypair name, to be used as a lock
LOCK_KEYNAME="${CLUSTER_NAME}-tfstate-lock"
LOCK_KEY_PEMFILE="${ROOTDIR}/${LOCK_KEYNAME}.pem"

# AWS key command
AWS_EC2_CLI="aws --profile ${AWS_PROFILE} --region ${AWS_REGION} ec2"

check_finger_print(){
	FINGERPRINT_PUB=$( ${AWS_EC2_CLI} describe-key-pairs --key-names ${LOCK_KEYNAME} | jq -r ".KeyPairs[].KeyFingerprint")
	FINGERPRINT_PEM=$(openssl pkcs8 -in ${LOCK_KEY_PEMFILE} -inform PEM -outform DER -topk8 -nocrypt | openssl sha1 -c)
	if [[ "${FINGERPRINT_PUB}" != "${FINGERPRINT_PEM}" ]] ; then
	  	return 1
	 else
	 	return 0
	 fi
}

lock(){
	if  ! ${AWS_EC2_CLI} describe-key-pairs --key-name ${LOCK_KEYNAME} > /dev/null 2>&1 ; then
		${AWS_EC2_CLI} create-key-pair --key-name ${LOCK_KEYNAME} --query 'KeyMaterial' \
		 --output text > ${LOCK_KEY_PEMFILE} && echo "Created lock using keypair ${LOCK_KEYNAME}."
	elif [[ ! -f ${LOCK_KEY_PEMFILE} ]]; then
  		echo "${LOCK_KEYNAME} is in use by another person. Cannot start a new sessions."
  		return 1
  	else 
  		check_finger_print
  		if [ $? -eq 1 ]; then
	  		echo "${LOCK_KEY_PEMFILE} exists, but doesn't match the ${LOCK_KEYNAME}'s fingerprint."
	  		return 1
	 	else
			echo "You have aquired ${LOCK_KEYNAME}. Session started. Don't forget to release the lock." 
		fi
	fi
}

unlock(){
	if  ! ${AWS_EC2_CLI} describe-key-pairs --key-name ${LOCK_KEYNAME} > /dev/null 2>&1 ; then
		echo "keypair ${key} does not exist. Nothing to remove."
    return 0
	elif [ ! -f ${LOCK_KEY_PEMFILE} ]; then
    	echo "${LOCK_KEY_PEMFILE} in use but you don't own the private key. Won't remove."
    	return 1
  else 
    	check_finger_print
    	if [ $? -eq 1 ]; then
    		echo "${LOCK_KEY_PEMFILE} exists, but doesn't match the ${LOCK_KEYNAME}'s fingerprint. Won't remove."
    		return 1
    	fi
  fi
  ${AWS_EC2_CLI} delete-key-pair --key-name ${LOCK_KEYNAME} \
       && echo "Deleted ${LOCK_KEYNAME}." \
       && rm -rf ${LOCK_KEY_PEMFILE} && echo "Removed ${LOCK_KEY_PEMFILE}."
}

while getopts ":l:u:h" OPTION
do
  key=$OPTARG
  case $OPTION in
    l)
      lock
      ;;
    u)
      unlock
      ;;
    *)
      echo "Usage: $(basename $0) -l|-u keyname"
      exit 1
      ;;
  esac
done