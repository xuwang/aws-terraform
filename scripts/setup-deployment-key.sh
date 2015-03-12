#!/bin/bash

# IAM user for deployment
awsProfile=$1
if [ -z "$awsProfile" ];
then
    echo "Need AWS profile."
    exit 1
fi

iamuser='deployment'
# tmp date dir and timestamp 
tmpdir='tmp/iam'
today=$(date +%Y%m%d)

#  Cleanup previously created keypairs
#[ -d $tmpdir ] && rm -rf $tmpdir
mkdir -p $tmpdir

policydoc=$tmpdir/deployment-policy.json
cat > $policydoc <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Stmt1420181067000",
      "Effect": "Allow",
      "Action": [
        "elasticloadbalancing:*"
      ],
      "Resource": [
        "*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:*"
      ],
      "Resource": [
        "arn:aws:s3:::${awsProfile}-config",
        "arn:aws:s3:::${awsProfile}-config/*",
        "arn:aws:s3:::${awsProfile}-registry",
        "arn:aws:s3:::${awsProfile}-registry/*",
        "arn:aws:s3:::${awsProfile}-jenkins",
        "arn:aws:s3:::${awsProfile}-jenkins/*"
      ]
    }
  ]
}
EOF
[ ! -f $policydoc ] && echo "$policydoc doesn't exit." && exit 1

# Create iam user if it doesn't exist.
if  aws --profile mylab iam get-user --user-name deployment > /dev/null 2>&1 ;
then
    echo "$iamuser already exist. Skipping."
    exit 0
fi
aws --profile $awsProfile iam create-user --user-name $iamuser && \
aws --profile $awsProfile iam list-access-keys --user-name $iamuser --query 'AccessKey.SecretAccessKey' --output text > $tmpdir/deployment_key && \
aws --profile $awsProfile iam list-access-keys --user-name $iamuser  --query 'AccessKeyMetadata[0].AccessKeyId' > $tmpdir/deployment_id
# Upload key/id to s3 bucket
aws --profile $awsProfile s3 cp $tmpdir/deployment_id s3://${awsProfile}-config/credentials/deployment/id 
aws --profile $awsProfile s3 cp $tmpdir/deployment_key  s3://${awsProfile}-config/credentials/deployment/key
# Upload apps data store name
echo "s3://${awsProfile}-config/apps" > $tmpdir/datastore
datadogapi=$(./read_cfg.sh ~/.pacific/config default datadogapi)
echo $datadogapi > $tmpdir/datadogapi
aws --profile $awsProfile s3 cp $tmpdir/datastore  s3://${awsProfile}-config/credentials/deployment/apps-bucket
aws --profile $awsProfile s3 cp $tmpdir/datadogapi s3://${awsProfile}-config/credentials/deployment/datadog-apikey
# Put policy doc
aws --profile $awsProfile iam put-user-policy --user-name $iamuser --policy-name ${iamuser}-${today} --policy-document file://$policydoc

# Clean up
rm -rf $tmpdir
