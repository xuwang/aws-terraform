#!/bin/sh -e


# Assemble cloud-config.yaml for a particular EC2 role, and upload it to S3 bucket. 
# The cloud-config.yaml fiile will be downloaded by a script when a machine is rebooted. 
# The cloud-config will be processed by coreos-cloudinit to bootstrap the machine. 

# aws profile
AWS_PROFILE=${AWS_PROFILE:-coreos-cluster}
CLUSTER_NAME=${CLUSTER_NAME:-coreos-cluster}

CLOUDINIT_BUCKET=${CLOUDINIT_BUCKET:-${CLUSTER_NAME}-cloudinit}

# Role to be used by the instance
AWS_ROLE=$1
# A file that contains a list of cloudinit files
CLOUDINIT_DEF=$2

if [[ "X$AWS_ROLE" = "X" ]] && [[ -f "$CLOUDINIT_DEF" ]];
then
    echo "  Usage: $0 <role> <cloudinit.def>"
    echo "Example: $0 worker cloudinit-etcd.def"
    exit 1
fi

AWS_ACCOUNT=$(aws --profile ${AWS_PROFILE} iam get-user | jq ".User.Arn" | grep -Eo '[[:digit:]]{12}')
BUCKET_URL="s3://${AWS_ACCOUNT}-${CLOUDINIT_BUCKET}"
YAML="${AWS_ROLE}/cloud-config.yaml"
TMP_DIR="user-data"
mkdir -p ${TMP_DIR}/${AWS_ROLE}

echo cloudinit is defined in ${CLOUDINIT_DEF}
# Upload to cloud-config location for bootstrapping
grep '.yaml' ${CLOUDINIT_DEF} | xargs cat > ${TMP_DIR}/${YAML}
if ! aws --profile ${AWS_PROFILE} s3 ls ${BUCKET_URL} > /dev/null 2>&1 ;
then
   aws --profile ${AWS_PROFILE} s3 mb ${BUCKET_URL}
fi
aws --profile ${AWS_PROFILE} s3 cp ${TMP_DIR}/${YAML} ${BUCKET_URL}/${YAML}
