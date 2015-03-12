#!/bin/bash
# e.g. create-group-policies.sh sws-admin
groupName=$1
shift
users=$*
policyDoc="../data/$groupName.json"

[ ! -f $policyDoc ] && echo "Policy doc doesn't exist: $policyDoc" && exit 1 

aws --profile anchorage iam get-group --group-name $groupName  > /dev/null 2>&1
if [ $? -ne 0 ]; 
then
    aws --profile anchorage iam create-group --group-name=$groupName 
fi
aws --profile anchorage iam put-group-policy --group-name $groupName --policy-name site-s3buckets --policy-document file://$policyDoc

for user in $users
do
    aws --profile anchorage iam get-user --user-name=$user > /dev/null 2>&1
    if [ $? -ne 0 ];
    then
        echo "Creating $user to $groupName"
        aws --profile anchorage iam create-user --user-name=$user
    fi
    echo "Adding $user to $groupName"
    aws --profile anchorage iam add-user-to-group --user-name $user --group-name $groupName
done
