profile=$1
if [ -z "$profile" ];
then
    echo "Need aws profile auth name."
    exit 1
fi
prog=`basename $0`
time=$(date +%Y-%m-%d-%H:%M)
vpcid=$(grep vpc_id ../mylab-new/tfcommon/network.tfvars)
vpcid=${vpcid/vpc_id=//}
# By giving vpcid, it indicates a private route53 zone
aws --profile $profile route53 create-hosted-zone --name cluster.local --vpc VPCRegion=us-west-2,VPCId=vpc-dbff57be \
    --caller-reference $time --hosted-zone-config Comment=$prog
