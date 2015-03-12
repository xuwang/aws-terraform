#!/bin/bash
hostedZoneId=Z1X0KFWJ26JEFP
recordName=spelunking.anchorage.local

hostedZoneName=$(aws --profile anchorage route53 get-hosted-zone --id=$hostedZoneId --query "HostedZone.Name")

cat > /tmp/$newName.json <<CHANGESET
{
    "Comment": "Update vi update-r53-private.sh", 
    "Changes": [
        {
            "Action": "UPSERT", 
            "ResourceRecordSet": {
                "Name": "${recordName}", 
                "Type": "A", 
                "TTL": 60, 
                "ResourceRecords": [
                    {
                        "Value": "10.42.2.15"
                    }
                ]
            }
        }
    ]
}
CHANGESET

aws route53 change-resource-record-sets --hosted-zone-id $hostedZoneId --change-batch file:///tmp/$newName.json --profile anchorage
