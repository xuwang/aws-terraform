#!/bin/bash
set -e
shopt -s extglob # enables pattern lists like +(...|...)

# Default variables
init() {
  # Supported regions
  regions="us-east-1 us-west-1 us-west-2 eu-west-1 sa-east-1 ap-northeast-1 ap-southeast-1 ap-southeast-2"
  regionRegexp='+(us-east-1|us-west-1|us-west-2|eu-west-1|sa-east-1|ap-northeast-1|ap-southeast-1|ap-southeast-2)'

  # Script actions
  actionsRegexp='+(create|delete|show)'
  
  # Dryrun flag
  dryrun=0
  
  # Interactive flag
  interactive=1  
}

# Create trails for all supported regions and create SNS topics
create_trails(){
  bucketOpt="--s3-use-bucket"
  includeGlobal="false"
  
  # Setup the first trail to receive global events
  region=$defaultRegion
  thisTrail=${trailname}-$region
  trail=$(aws --profile $profile cloudtrail describe-trails --region $region --trail-name-list $thisTrail | jq --raw-output '.trailList[].Name')
  if [ "$trail" = "$thisTrail" ]; then
    echo "$accountId already has CloudTrail setup: $trail."
  else
    includeGlobal="true"
    if ! aws --profile $profile s3 ls s3://$trailbucket > /dev/null 2>&1; then
      bucketOpt="--s3-new-bucket"
    fi
    thisTrail=${trailname}-$region
    setup_trail
  fi
  
  # Setup the rest of the trails
  for region in $regions
  do
    thisTrail=${trailname}-$region
    trail=$(aws --profile $profile cloudtrail describe-trails --region $region --trail-name-list $thisTrail | jq --raw-output '.trailList[].Name')
    if [ "$trail" = "$thisTrail" ]; then
      echo "$accountId already has CloudTrail setup: $thisTrail."
    else
      setup_trail
    fi
  done
}

setup_trail(){
  snstopic=$thisTrail
  cmd="aws --profile $profile cloudtrail create-subscription --region $region \
      --name $thisTrail \
      $bucketOpt $trailbucket --sns-new-topic $snstopic \
      --include-global-service-events $includeGlobal"
  echo "Creating $thisTrail"
  [ $dryrun -eq 0 ] && $cmd
}

create_sqs(){
  # This is optional. Some third party AWS log service, e.g. SplunkAppForAWS, may need a SQS. 
  # Cloudtrail SQS and Trail name
  queuename=${accountId}-cloudtrail
  if [ $interactive -eq 1 ]; then
    answer='N'
    echo -n "Do you want to create SQS $queuename? [Y/N]"
    read answer
    echo ""
    if [ "X$answer" != "XY" ]; then
      echo "No queue is created."
      exit 0
    fi
  fi
  echo "Creating SQS service."
  cmd="aws --profile $profile sqs create-queue --queue-name $queuename --region $defaultRegion"
  [ $dryrun -eq 0 ] && $cmd
}

show(){
  echo "Trails" 
  for i in $regions
  do 
    aws --profile $profile cloudtrail describe-trails --region $i | jq --raw-output '.trailList[].Name'
  done

  echo "SNS"
  for i in $regions
  do
    aws --profile $profile sns list-topics --region $i | jq --raw-output '.Topics[].TopicArn' | grep "$profile-cloudtrail"
  done

  echo "SQS"
  if [ ! -z "$accountId" ]; then
    aws --profile $profile sqs list-queues --queue-name-prefix $accountId | jq --raw-output  '.QueueUrls[]'
  else
    aws --profile $profile sqs list-queues | jq --raw-output  '.QueueUrls[]'
  fi
}

# Delete SNS topics
delete_sns(){
  # Delete SNS topics
  for i in $regions
  do
    snstopic=${trailname}-$i
    topicarn=$(aws --profile $profile sns list-topics --region $i |grep $snstopic | awk '{print $2}' | sed 's/\"//g')
    if [ $topicarn ]; then
      cmd="aws --profile $profile sns delete-topic --topic-arn $topicarn --region $i"
      echo "Deleting $topicarn."
      [ $dryrun -eq 0 ] && $cmd
    fi
  done
}

# Delete Cloudtrails
delete_trails() {
  for i in $regions
  do
    thisTrail=$trailname-$i
    trail=$(aws --profile $profile cloudtrail describe-trails --region $i  --trail-name-list $thisTrail | jq --raw-output '.trailList[].Name')
    if [ -z "$trail" ];
    then
      echo "$thisTrail doesn't exist."
      continue
    fi
    cmd="aws --profile $profile cloudtrail delete-trail --region $i --name $thisTrail"
    echo "Deleting $thisTrail."
    [ $dryrun -eq 0 ] && $cmd
  done
}
  
# Delete sqs
delete_sqs() {
  queuename=${accountId}-cloudtrail
  queueurl=$(aws --profile $profile sqs get-queue-url --queue-name $queuename --query QueueUrl | sed 's/\"//g')
  if [ -z $queueurl ]; then
    echo "No SQS to delete."
  else 
    cmd="aws --profile $profile sqs delete-queue --queue-url $queueurl"
    echo "Deleting $queueurl."
    [ $dryrun -eq 0 ] && $cmd
  fi
}

help(){
  echo "create-cloudtrail -a <action> -p <profile> [-b <bucket>] -r region [-n] [-y]"
  echo ""
  echo " -a <create|show|delete>: action. create, show or delete cloudtrails setup by this tool."
  echo " -p <aws profile>: authenticate as this profile."
  echo " -b <bucket>: optional. bucket name to get all trail reports."
  echo " -r <region>: region to get AWS global events, e.g. IAM"
  echo " -y     : non-interative mode. Answer to yes to all default values."
  echo " -n     : dryrun. print out the commands"
  echo " -h     : Help"
}

# Main

# Set default values
init

while getopts "a:p:b:r:hny" OPTION
do
  case $OPTION in
    a)
      action=$OPTARG
      case $action in
        $actionsRegexp) 
          ;;
        *)
          echo "Unsupported action $action."
          exit 1
      esac
      ;;
    p)
      profile=$OPTARG
      ;;
    b)
      bucket=$OPTARG
      ;;
    r)
      defaultRegion=$OPTARG
      case $defaultRegion in
         $regionRegexp)
           ;;
         *)
          echo "Unsuported region $region."
          exit 1
      esac
      ;;
    n)
      dryrun=1
      ;;
    y)
      interactive=0
      ;;
    [h?])
      help
      exit
      ;;
  esac
done

if [[ -z $action || -z $profile || -z $defaultRegion && $action != 'show' ]]; then
  help
  exit 1
fi

echo "Getting AWS account number ..."
accountId=$(aws --profile $profile iam get-user | jq '.User.Arn' | grep -Eo '[[:digit:]]{12}')
if [ -z "$accountId" ]; then
  echo "Cannot find AWS account number."
  exit 1
else 
  if [[ ! -z "bucket" && $interactive -ne 0 && $action != "show" ]]; then
      answer='N'
      echo -n "Do you accept the $accountId SNA and cloudtrail bucket prefix? [Y/N]"
      read answer
      echo ""
      [ "X$answer" != "XY" ] && echo "Do nothing. Quit."&&  exit 0
  fi
fi

# Don't exist on non-zero code because the following aws commmands exit code
# is '1' on sucess.
set +e 
# Cloudtrail name, one name per account.
trailname=${profile}-cloudtrail

# S3 bucket to receive logs
trailbucket=${bucket:-${accountId}-cloudtrail}

# Call functions based on action 
case $action in
  'create')
    create_trails
    create_sqs
    ;;
  'delete')
    delete_trails
    delete_sns
    delete_sqs
    ;; 
  'show')
    show
    ;;
esac

[ $dryrun -eq 1 ] && echo "Dryrun mode. Nothing is changed."

exit 0
