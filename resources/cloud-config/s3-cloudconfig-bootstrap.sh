#!/bin/bash -e

# This is a coreos-cluster-cloudinit bootstrap script. It is passed in as 'user-data' file during the machine build. 
# Then the script is excecuted to download the CoreOs "cloud-config.yaml" file  and "intial-cluster" files.
# These files  will configure the system to join the CoreOS cluster. The second stage cloud-config.yaml can 
# be changed to allow system configuration changes wihtout having to rebuild the system. All it takes is a reboot.
# If this script changes, the machine will need to be rebuild (user-data change)

# Convention: 
# 1. A bucket should exist that contains role-based cloud-config.yaml
#  e.g. <account-id>-coreos-cluster-cloudinit/<roleProfile>/cloud-config.yaml
# 2. All machines should have instance role profile, with a policy that allows readonly access to this bucket.

# Get instance auth token from meta-data
get_value() {
  echo -n $(curl -s http://169.254.169.254/latest/meta-data/iam/security-credentials/$roleProfile | jq -r ".$1")
}

# Headers for curl
create_string_to_sign() {
  contentType="application/x-compressed-tar"
  contentType=""
  dateValue="`date +'%a, %d %b %Y %H:%M:%S %z'`"

  # stringToSign
  stringToSign="GET

${contentType}
${dateValue}
x-amz-security-token:${s3Token}
${resource}"
}

# Log curl call 
debug_log () {
    echo ""  >> /tmp/s3-bootstrap.log
    echo "curl -s -O -H \"Host: ${bucket}.s3.amazonaws.com\"
  -H \"Content-Type: ${contentType}\"
  -H \"Authorization: AWS ${s3Key}:${signature}\"
  -H \"x-amz-security-token:${s3Token}\"
  -H \"Date: ${dateValue}\"
	https://${bucket}.s3.amazonaws.com/${filePath} " >> /tmp/s3-bootstrap.log
}

# Instance profile
instanceProfile=$(curl -s http://169.254.169.254/latest/meta-data/iam/info \
        | jq -r '.InstanceProfileArn' \
	| sed  's#.*instance-profile/##')

# AWS Account
accountId=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document \
	| grep -Eo '([[:digit:]]{12})')

# Bucket path for the cloud-config.yaml 
bucket=${accountId}-coreos-cluster-cloudinit

# Path to cloud-config.yaml
# Remove environment from instanceProfile, if any. Assume all instances sharing the same prefix is the same role.
# e.g. hosting, hosting-nonprod assuming "hosting" role.
roleProfile=${instanceProfile/-*/}
cloudConfigYaml="${roleProfile}/cloud-config.yaml"

# path to initial-cluster urls file
initialCluster="etcd/initial-cluster"

# Find token, AccessKeyId,  line, remove leading space, quote, commas
s3Token=$(get_value "Token")
s3Key=$(get_value "AccessKeyId")
s3Secret=$(get_value "SecretAccessKey")

workDir="/root/cloudinit"
mkdir -m 700 -p ${workDir}
cd ${workDir}

# Download coreos-cluster-cloudinit/<profile>/clould-config.yaml
# 
# And replace ipv4 vars in clould-config.yaml
# because oem-cloudinit.service does it only on native "user-data", i.e. this script.
resource="/${bucket}/${cloudConfigYaml}"
create_string_to_sign
signature=$(/bin/echo -n "$stringToSign" | openssl sha1 -hmac ${s3Secret} -binary | base64)
filePath=${cloudConfigYaml}
debug_log
curl -L -s -H "Host: ${bucket}.s3.amazonaws.com" \
  -H "Content-Type: ${contentType}" \
  -H "Authorization: AWS ${s3Key}:${signature}" \
  -H "x-amz-security-token:${s3Token}" \
  -H "Date: ${dateValue}" \
  https://${bucket}.s3.amazonaws.com/${filePath} \
  | sed "s/\\$private_ipv4/$private_ipv4/g; s/\\$public_ipv4/$public_ipv4/g; s/role=INSTANCE_PROFILE/role=$instanceProfile/g" \
  > ${workDir}/cloud-config.yaml

# Download initial-cluster
resource="/${bucket}/${initialCluster}"
create_string_to_sign
signature=$(/bin/echo -n "$stringToSign" | openssl sha1 -hmac ${s3Secret} -binary | base64)
filePath=${initialCluster}
debug_log
retry=4
ready=0
until [[ $retry -eq 0 ]]  || [[ $ready -eq 1  ]]
do
  curl -s -L -O -H "Host: ${bucket}.s3.amazonaws.com" \
    -H "Content-Type: ${contentType}" \
    -H "Authorization: AWS ${s3Key}:${signature}" \
    -H "x-amz-security-token:${s3Token}" \
    -H "Date: ${dateValue}" https://${bucket}.s3.amazonaws.com/${filePath}
  if [ -f ${workDir}/initial-cluster ] && grep -q ETCD_INITIAL_CLUSTER ${workDir}/initial-cluster ;
  then
    ready=1
  else
    let "retry--"
  fi
done

# Copy initial-cluster to the volume that will be picked up by etcd boostraping
if [ $ready -eq 1 ];
then
  mkdir -p /etc/sysconfig
  cp ${workDir}/initial-cluster /etc/sysconfig/initial-cluster
fi

# Create /etc/environment file so the cloud-init can get IP addresses
coreos_env='/etc/environment'
if [ ! -f $coreos_env ];
then
    echo "COREOS_PRIVATE_IPV4=$private_ipv4" > /etc/environment
    echo "COREOS_PUBLIC_IPV4=$public_ipv4" >> /etc/environment
    echo "INSTANCE_PROFILE=$instanceProfile" >> /etc/environment
fi

# Run cloud-init
coreos-cloudinit --from-file=${workDir}/cloud-config.yaml
