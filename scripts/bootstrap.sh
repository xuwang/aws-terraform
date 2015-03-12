#!/usr/bin/bash -e
#systemctl stop etcd
#cd /var/lib/
#timestamp=20150214-8825
#mv etcd etcd. && mkdir etcd && chown etcd:etcd etcd
#systemctl start etcd

etcdctl mkdir /_pacific/_aws/deployment
etcdctl mkdir /_pacific/_datadog/

etcdctl set /_pacific/_aws/deployment/id "AKIAJDEQITCVIWI5XA7A"
etcdctl set /_pacific/_aws/deployment/key XbP/MmWNU18XMfs7iX24cA3f48AzR1+9XwFLBaHS
etcdctl set /_pacific/_aws/deployment/app-config-bucket s3://mylab-config/apps
etcdctl set /_pacific/_datadog/apikey ce4c6581a99eea7f9e5c3e39a0c76469
/opt/bin/setup-aws-env
systemctl start s3sync
