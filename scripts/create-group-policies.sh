#!/bin/bash

trustpolicy='../data/ec2-role-trust-policy.json'
[ ! -f $trustpolicy ]  && echo "$trustpolicy is required." && exit 1

for profile in config gmylab logs registry jenkins admiral
do
    policydoc="../data/s3-${profile}-policy.json"
    echo "Checking policy file $policydoc."
    if [ ! -f $policydoc ];
    then
        echo "$policydoc is required." 
    else
        echo "$policydoc is OK." 
    fi
done

for profile in config gmylab logs registry jenkins admiral
do
    policydoc="../data/s3-${profile}-policy.json"
    echo "Checking policy file $policydoc."
    aws --profile anchorage iam create-role --role-name $profile --assume-role-policy-document file://$trustpolicy && \
    aws --profile anchorage iam put-role-policy --role-name $profile --policy-name s3-${profile} --policy-document file://$policydoc && \
    aws --profile anchorage iam create-instance-profile --instance-profile-name $profile && \
    aws --profile anchorage iam add-role-to-instance-profile --instance-profile-name $profile --role-name $profile
done
