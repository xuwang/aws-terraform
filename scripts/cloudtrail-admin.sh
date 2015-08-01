#!/bin/bash
set -e
shopt -s extglob # enables pattern lists like +(...|...)

# Supported regions
regions="us-east-1 us-west-1 us-west-2 eu-west-1 sa-east-1 ap-northeast-1 ap-southeast-1 ap-southeast-2"
regionRegexp='+(us-east-1|us-west-1|us-west-2|eu-west-1|sa-east-1|ap-northeast-1|ap-southeast-1|ap-southeast-2)'

# Script actions
actionsRegexp='+(create|delete)'

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
  
  # Delete sqs?
  answer='N'
  queuename=${accountname}-cloudtrail
  if aws --profile $profile sqs get-queue-url --queue-name $queuename > /dev/null 2>&1; then
    echo -n "Do you want to delete SQS $queuename? [Y/N]"
    read answer
    echo ""
    if [ "X$answer" != "XY" ]; then
      echo "Do nothing. Quit."
      exit 0
    else
      queueurl=$(aws --profile $profile sqs get-queue-url --queue-name $queuename --query QueueUrl | sed 's/\"//g')
      cmd="aws --profile $profile sqs delete-queue --queue-url $queueurl"
      [ $dryrun -eq 0 ] && $cmd
    fi
  fi
}

help(){
  echo "create-cloudtrail [-p <profile>] -b <bucket> -r region -n"
  echo ""
  echo " -a <create|delete>: action. create or delete everthing."
  echo " -p <aws profile>: authenticate as this profile."
  echo " -b <bucket>: optional. bucket name to get all trail reports."
  echo " -r <region>: region to get AWS global events, e.g. IAM"
  echo " -n     : dryrun. print out the commands"
  echo " -h     : Help"
}

# Main
dryrun=0
while getopts "a:p:b:r:hn" OPTION
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
else 
  answer='N'
  echo -n "Do you accept the $accountname SNA and cloudtrail bucket prefix? [Y/N]"
  read answer
  echo ""
  if [ "X$answer" != "XY" ]; then
    echo "Do nothing. Quit."
    exit 0
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

if [ $action = 'create' ]; 
then
  create
else
  delete
fi

[ $dryrun -eq 1 ] && echo "Dryrun mode. Nothing is changed."

exit 0
