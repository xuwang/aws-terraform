#!/bin/bash
# generate-script.sh

profile=$1
if [ -z "$profile" ];
then
    echo "Need aws profile auth name."
    exit 1
fi

OUTFILE=bootstrap.sh         # Name of the file to generate.
aws --profile $profile s3 cp s3://$profile-config/credentials/deployment/id /tmp/id
ID=`cat /tmp/id`
aws --profile $profile s3 cp s3://$profile-config/credentials/deployment/key /tmp/key
KEY=`cat /tmp/key`
aws --profile $profile s3 cp s3://$profile-config/credentials/deployment/apps-bucket /tmp/apps-bucket
APPSBUCKET=`cat /tmp/apps-bucket`
aws --profile $profile s3 cp s3://$profile-config/credentials/deployment/datadog-apikey /tmp/datadog-apikey
DATADOGAPI=`cat /tmp/datadog-apikey`
TIMPSTAMP=$(date +%Y%m%d-$RANDOM)

for i in id key apps-bucket datadog-apikey
do
    rm /tmp/$i
done

# -----------------------------------------------------------
# 'Here document containing the body of the generated script.
(
cat <<EOF
#!/usr/bin/bash -e
#systemctl stop etcd
#cd /var/lib/
#timestamp=$TIMPSTAMP
#mv etcd etcd.$timestamp && mkdir etcd && chown etcd:etcd etcd
#systemctl start etcd

etcdctl mkdir /_pacific/_aws/deployment
etcdctl mkdir /_pacific/_datadog/

etcdctl set /_pacific/_aws/deployment/id $ID
etcdctl set /_pacific/_aws/deployment/key $KEY
etcdctl set /_pacific/_aws/deployment/app-config-bucket $APPSBUCKET
etcdctl set /_pacific/_datadog/apikey $DATADOGAPI
/opt/bin/setup-aws-env
systemctl start s3sync
EOF
) > $OUTFILE
# -----------------------------------------------------------

#  Quoting the 'limit string' prevents variable expansion
#+ within the body of the above 'here document.'
#  This permits outputting literal strings in the output file.

if [ -f "$OUTFILE" ]
then
  chmod 755 $OUTFILE
  # Make the generated file executable.
else
  echo "Problem in creating file: \"$OUTFILE\""
fi

#  This method also works for generating
#+ C programs, Perl programs, Python programs, Makefiles,
#+ and the like.

exit 0
