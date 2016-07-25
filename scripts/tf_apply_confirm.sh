#!/bin/bash
#
# Decide if we should carry out terraform apply based on if there is a change

TF_PLAN="terraform plan -module-depth=1"
TF_GET="terraform get -update"
TF_APPLY="terraform apply -refresh=false"
resource=$(basename $(PWD))

$TF_GET
echo "Creating or updating $resource plan. This may take a while."
$TF_PLAN -detailed-exitcode > /dev/null
if [ $? -eq 2 ];
then
    $TF_PLAN
    echo "CONTINUE? [Y/N]: "
    read ANSWER
    if [ "$ANSWER" != "Y" ];
    then 
        echo "Exiting."
        exit 1
    else
	$TF_APPLY
    fi
else
   echo "Nothing to change."
fi

