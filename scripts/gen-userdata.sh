#/bin/sh
project=$1
role=$2

if [ ! -z "$role" -a ! -z $project ];
then
    (cd ~/projects/pacific/pacific-aws/anchorage/$role && cat cloud-config/$role.yaml ../common/cloud-config/systemd-units.yaml ../common/cloud-config/files.yaml > user-data.$role)
fi
