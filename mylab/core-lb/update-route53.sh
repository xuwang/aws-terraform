#!/bin/bash
hostedZoneId=$1
elbName=$2
recordName=$3

elbZone=$(aws elb describe-load-balancers --load-balancer-name=$elbName --profile mylab  --query "LoadBalancerDescriptions[0].CanonicalHostedZoneNameID")
elbDns=$(aws elb describe-load-balancers --load-balancer-name=$elbName --profile mylab --query "LoadBalancerDescriptions[0].DNSName")
hostedZoneName=$(aws --profile mylab route53 get-hosted-zone --id=$hostedZoneId --query "HostedZone.Name")

cat > /tmp/$elbName.json <<CHANGESET
{
  "Comment": "Updated via route53.sh",
  "Changes": [
    {
      "Action": "UPSERT",
      "ResourceRecordSet": {
        "Name": "${recordName}",
        "Type": "A",
        "AliasTarget": {
          "HostedZoneId": ${elbZone},
          "DNSName": ${elbDns},
          "EvaluateTargetHealth": false
        }
      }
    }
  ]
}
CHANGESET

aws route53 --profile mylab change-resource-record-sets --hosted-zone-id $hostedZoneId --change-batch file:///tmp/$elbName.json
