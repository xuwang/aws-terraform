#!/usr/bin/env bash

# Replace CLUSTER_NAME with user defined name.

CLUSTER_NAME=${CLUSTER_NAME:-coreos-cluster}

files=$(grep -s -l CLUSTER-NAME -r $@)
if [ "X$files" != "X" ];
then
  for f in $files
  do
    perl -p -i -e "s/CLUSTER-NAME/$CLUSTER_NAME/g" $f
  done
fi

