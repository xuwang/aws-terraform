#!/bin/bash
set -e
shopt -s extglob # enables pattern lists like +(...|...)

# Supported regions
regions="us-east-1 us-west-1 us-west-2 eu-west-1 sa-east-1 ap-northeast-1 ap-southeast-1 ap-southeast-2"
regionRegexp='+(us-east-1|us-west-1|us-west-2|eu-west-1|sa-east-1|ap-northeast-1|ap-southeast-1|ap-southeast-2)'

# Script actions
actionsRegexp='+(create|delete|show)'

# Create trails for all supported regions and create SNS topics
create(){
  snstopic=${trailname}-${region}

  # Create one primary cloudtrail which will include other trails logs
  cmd="aws --profile $profile cloudtrail create-subscription 
      --region ${region} \
      --name $trailname-${region} \
      --$bucketopt $trailbucket --sns-new-topic $snstopic \
      --include-global-service-events true"

  echo "$cmd"
  [ $dryrun -eq 0 ] && $cmd

  # Create other cloudtrails, set no-include-global-service-events to 
  # avoid global service log duplications
  for i in $regions
  do 
    # The region that get global event is already set.
    if [[ $i = "$region" ]]; then
      continue
    fi
    snstopic=${trailname}-$i
    cmd="aws --profile $profile cloudtrail create-subscription --region $i \
        --name ${trailname}-$i \
        --s3-use-bucket $trailbucket --sns-new-topic $snstopic \
        --include-global-service-events false"
    [ $dryrun -eq 0 ] && $cmd
  done

  # For SplunkAppForAWS, you need a SQS. Other applications may not need this
  # Create one primary cloudtrail which will include other trails logs

  # Cloudtrail SQS and Trail name
  queuename=${accountname}-cloudtrail
  answer='N'
  echo "Splunk integration needs a message queue."
  echo -n "Do you want to create SQS $queuename? [Y/N]"
  read answer
  echo ""
  if [ "X$answer" != "XY" ]; then
    echo "No queue is created."
    exit 0
  else
    cmd="aws --profile $profile sqs create-queue --queue-name $queuename --region ${region}"
    [ $dryrun -eq 0 ] && $cmd
  fi
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
  aws --profile coreos-cluster sqs list-queues --queue-name-prefix $accountname | jq --raw-output  '.QueueUrls[]'
}

delete(){
  # Delete SNS topics
  for i in $regions
  do
    snstopic=${trailname}-$i
    topicarn=$(aws --profile $profile sns list-topics --region $i |grep $snstopic | awk '{print $2}' | sed 's/\"//g')
    if [ $topicarn ]; then
      cmd="aws --profile $profile sns delete-topic --topic-arn $topicarn --region $i"
      echo $cmd
      [ $dryrun -eq 0 ] && $cmd
    fi
  done

  # Delete Cloudtrails
  for i in $regions
  do
    snstopic=${trailname}-$i
    cmd="aws --profile $profile cloudtrail delete-trail --region $i --name $trailname-$i"
    echo $cmd
    [ $dryrun -eq 0 ] && $cmd
  done
  
  # Delete sqs
  queuename=${accountname}-cloudtrail
  queueurl=$(aws --profile $profile sqs get-queue-url --queue-name $queuename --query QueueUrl | sed 's/\"//g')
  cmd="aws --profile $profile sqs delete-queue --queue-url $queueurl"
  echo $cmd
  [ $dryrun -eq 0 ] && $cmd
}

help(){
  echo "create-cloudtrail [-p <profile>] -b <bucket> -r region -n"
  echo ""
  echo " -a <create|show|delete>: action. create or delete everthing."
  echo " -p <aws profile>: authenticate as this profile."
  echo " -b <bucket>: optional. bucket name to get all trail reports."
  echo " -r <region>: region to get AWS global events, e.g. IAM"
  echo " -n     : dryrun. print out the commands"
  echo " -h     : Help"
}

# Main
dryrun=0
interactive=1

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
      region=$OPTARG
      case $region in
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

if [[ -z $action || -z $profile || -z $region ]]; then
  help
  exit 1
fi

echo "Getting AWS account number ..."
accountname=$(aws --profile $profile iam get-user | jq '.User.Arn' | grep -Eo '[[:digit:]]{12}')
if [ -z "$accountname" ]; then
  echo "Cannot find AWS account number."
  exit 1
else 
  if [[ $interactive -ne 0 && $action != "show" ]]; then
    answer='N'
    echo -n "Do you accept the $accountname SNA and cloudtrail bucket prefix? [Y/N]"
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
trailbucket=${bucket:-${accountname}-cloudtrail}

if ! aws --profile $profile s3 ls s3://$trailbucket > /dev/null 2>&1; then
  bucketopt="s3-new-bucket"
else
  bucketopt="s3-use-bucket"
fi

# Call functions based on action 
case $action in
  'create')
    trail=$(aws --profile $profile cloudtrail describe-trails --region us-west-2 | jq --raw-output '.trailList[].Name')
    if [ $? -eq 0 ];
    then
      echo "$accountname already has CloudTrail setup: $trail."
      exit 0
    else
      create
    fi
    ;;
  'delete')
    trail=$(aws --profile $profile cloudtrail describe-trails --region us-west-2 | jq --raw-output '.trailList[].Name')
    if [ -z $trail ];
    then
      echo "$accountname does not have CloudTrail."
      exit 1
    else
      delete
    fi
    ;; 
  'show')
    show
    ;;
esac

[ $dryrun -eq 1 ] && echo "Dryrun mode. Nothing is changed."

exit 0
