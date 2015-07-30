#!/usr/bin/env bash

# Default Environment variables
COREOS_UPDATE_CHANNE="${COREOS_UPDATE_CHANNE:-beta}"      # stable/beta/alpha
AWS_ZONE=${AWS_ZONE:-us-west-2}                           # us-west-1/us-west-2/...
VM_TYPE=${VM_TYPE:-pv}                                    # hvm/pv - note: t1.micro supports only pv type

# Get options from the command line
while getopts ":c:z:t:" OPTION
do
    case $OPTION in
        c)
          COREOS_UPDATE_CHANNE=$OPTARG
          ;;
        z)
          AWS_ZONE=$OPTARG
          ;;
        t)
          VM_TYPE=$OPTARG
          ;;
        *)
          echo "Usage: $(basename $0) -c <stable|beta|alpha> -z <aws zone> -t <hvm|pv>"
          exit 0
          ;;
    esac
done


# Get the AMI id
url=`printf "http://%s.release.core-os.net/amd64-usr/current/coreos_production_ami_%s_%s.txt" $COREOS_UPDATE_CHANNE $VM_TYPE $AWS_ZONE`

cat <<EOF
# Generated by scripts/get-ami.sh
variable "amis" {
  default = {
    us-west-2 = "`curl -s $url`"
  }
}
EOF