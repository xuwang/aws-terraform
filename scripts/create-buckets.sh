#!/bin/bash

awsProfile=$1
if [ -z "$awsProfile" ];
then
    echo "Need aws profile auth name."
    exit 1
fi
# Application buckets
buckets=$(./read_cfg.sh  ~/.pacific/config $awsProfile buckets)
isCore=$(./read_cfg.sh  ~/.pacific/config $awsProfile core)
for i in $buckets
do
    if ! aws --profile $awsProfile s3 ls s3://${awsProfile}-${i} > /dev/null 2>&1 ;
    then
        aws --profile $awsProfile s3 mb s3://${awsProfile}-${i}
        if [ $i = "config" ];
        then
            aws --profile $awsProfile s3 mb s3://${awsProfile}-config/certs
        fi
        if [ $i = "registry" ];
        then
            aws --profile $awsProfile s3 mb s3://${awsProfile}-registry/data
        fi
    else 
       echo "s3://$awsProfile-${i} already exists."
    fi
done

# Reserve static page bucket
if ! aws --profile $awsProfile s3 ls s3://$awsProfile.example.com > /dev/null 2>&1 ;
then 
    aws --profile $awsProfile s3 mb s3://$awsProfile.example.com
else
    echo "s3://$awsProfile.example.com already exists."
fi

# Setting up policies
echo "Creating bucket policies"
mkdir -p tmp
cat > tmp/ec2-role-trust-policy.json <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": { "Service": "ec2.amazonaws.com"},
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
trustpolicy='tmp/ec2-role-trust-policy.json'
for i in $buckets
do
cat > tmp/s3-${i}-policy.json <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:*"
      ],
      "Resource": [
        "arn:aws:s3:::${awsProfile}-${i}",
        "arn:aws:s3:::${awsProfile}-${i}/*"
      ]
    }
  ]
}
EOF
done

# Create admiral role to allow access to jenkins and apps s3 buckets.
if [ "$isCore" = "yes" ];
then
   if ! aws --profile $awsProfile iam get-role --role-name=admiral > /dev/null 2>&1 ;
   then
       aws --profile $awsProfile iam create-role --role-name admiral --assume-role-policy-document file://$trustpolicy && \  
       aws --profile $awsProfile iam create-instance-profile --instance-profile-name admiral
       aws --profile $awsProfile iam add-role-to-instance-profile --instance-profile-name admiral --role-name admiral
   else
       echo "Role admiral aleady exist. Skipping"
   fi 
fi

# Add inline policies to the roles.
for i in $buckets
do
    policydoc="tmp/s3-${i}-policy.json"
    if ! aws --profile $awsProfile iam get-role --role-name=$i > /dev/null 2>&1 ;
    then
        aws --profile $awsProfile iam create-role --role-name $i --assume-role-policy-document file://$trustpolicy && \
        aws --profile $awsProfile iam put-role-policy --role-name $i --policy-name s3-${i} --policy-document file://$policydoc && \
        aws --profile $awsProfile iam create-instance-profile --instance-profile-name $i && \
        aws --profile $awsProfile iam add-role-to-instance-profile --instance-profile-name $i --role-name $i
        if [ $isCore = "yes" ];
        then
            aws --profile $awsProfile iam put-role-policy --role-name admiral --policy-name s3-${i} --policy-document file://$policydoc
        fi
    else
        echo "Role $i already exist."
    fi
done
