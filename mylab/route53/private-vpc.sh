profile=$1
prog=`basename $0`
echo "$prog"
aws --profile $profile route53 create-hosted-zone --name cluster.local --vpc VPCRegion=us-west-2,VPCId=vpc-dbff57be --caller-reference 2015-02-14-18:47 --hosted-zone-config  Comment=$prog
