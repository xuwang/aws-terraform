#!/bin/bash
#
# Decide if we should carry out terraform apply based on if there is a change

TF_PLAN=${TF_PLAN:-"terraform plan -module-depth=1"}
TF_GET=${TF_GET:-"terraform get -update"}
TF_APPLY=${TF_APPLY:-"terraform apply -refresh=false"}
CONFIRM_TF_APPLY=${CONFIRM_TF_APPLY:-"YES"}
resource=$(basename $(pwd))

$TF_GET > /dev/null
echo "Creating or updating $resource plan. This may take a while."
if [ "X${CONFIRM_TF_APPLY}" != "XYES" ]; then
  $TF_PLAN
  $TF_APPLY
else
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
fi  
