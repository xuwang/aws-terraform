#!/usr/bin/env bash

# Replace AWS-ACCOUNT with aws account number in *.tf.tmpl and *.json.tmpl files. Can be used 
# to form policy documents, resource names etc, with the aws account number as part of a string.
# If a substitusion is made, a new file will be created with the original name with out the .tmpl sufix.

# Script location
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

# AWS account number - getting it from an existing user resource
echo "Getting AWS account number..."
AWS_ACCOUNT=$(aws --profile coreos-cluster iam get-user --user-name=coreos-cluster | jq ".User.Arn" | grep -Eo '[[:digit:]]{12}')
workdir=${DIR}/../coreos-cluster
cd $workdir
files=$(grep -s -l AWS-ACCOUNT -r --include *.tmpl --include *.tmpl .)
if [ "X$files" != "X" ];
then
  for i in $files
  do
    path=$(dirname $i)
    newfile=$(basename $i .tmpl)
    echo "generating $newfile"
    perl -p -e "s/AWS-ACCOUNT/$AWS_ACCOUNT/g" $i > $workdir/$path/$newfile
  done
fi

