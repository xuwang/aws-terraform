#!/bin/bash
#
# Init variables and sanity checks
function init() {
    export PROJECTROOT=~/projects/aws-terraform
    export GITROOT=$(dirname $PROJECTROOT)
    export SCRIPTDIR=$GITROOT/scripts
    export TFCOMMON=$PROJECTROOT/tfcommon
    export PATH=$PATH:~/bin/terraform

    if [ ! -d "$GITROOT" ]; 
    then
        echo "$GITROOT doesn't exit. Please run git clone https://github.com/xuwang/aws-terraform.git."
        exit 1
    fi

    if [ ! -d $PROJECTROOT ];
    then 
        echo "$PROJECTROOT doesn't exist."
        exit 1
    fi
    aws --profile $awsProfile support help 2>/dev/null 1>&2
    if [ $? = "255" ];
    then
        echo "Account $awsProfile doesn't exit."
        exit 1
    fi

    # Generate keys.tfvars
    install /dev/null $TFCOMMON/$awsProfile.keys
    aws_access_key_id=$($SCRIPTDIR/read_cfg.sh  ~/.aws/credentials "$awsProfile" aws_access_key_id)
    aws_secret_access_key=$($SCRIPTDIR/read_cfg.sh  ~/.aws/credentials "$awsProfile" aws_secret_access_key)
    cat > $TFCOMMON/$awsProfile.keys <<EOF
aws_access_key = "$aws_access_key_id"
aws_secret_key = "$aws_secret_access_key"
EOF
    (cd $TFCOMMON && ln -fs $awsProfile.keys keys.tfvars)
    echo "Account $TFCOMMON/$awsProfile.keys will be used to create resources."
    echo "Terraform keys.tfvars is generated as:"
    cat $TFCOMMON/keys.tfvars
}

#############
# Subroutines
#############

# Install buckets
function createBuckets() {
    ./create-buckets.sh $awsProfile $pacificProfile
}

# Create keypairs
function createKeyPairs() {
    ./create-keypairs.sh $awsProfile $pacificProfile
}

# Deployment key for elb, jenkins bucket, apps bucket.
function setupDeploymentKey() {
    ./setup-deployment-key.sh $awsProfile $pacificProfile
}

function createResource() {
    ( 
        cd $PROJECTROOT/$resourceType
        if [ -f 'terraform.tfstate' ];
        then 
            echo "$resourceType already exist. Here is the status."
            terraform refresh --var-file=../tfcommon/keys.tfvars --var-file=../tfcommon/network.tfvars
            terraform show terraform.tfstate
            echo "Finished status display."
       else
           echo "Creating $resourceType plan"
           terraform plan --var-file=../tfcommon/keys.tfvars --var-file=../tfcommon/network.tfvars
           echo "Do you wish to apply the plan"
           answerMe
           if [ "X$answer" = "XY" ]; then
               terraform apply --var-file=../tfcommon/keys.tfvars --var-file=../tfcommon/network.tfvars
               # Post process for some resources
               if [ "$resourceType" = "vpc" ];
               then
                    ./gen-network-tfvars.sh
               fi
           else
               echo "Skpping $resourceType creation."
               echo ""
           fi
       fi
    )
}

function hitAnyKey() {
    echo -n "Hit any key to continue, or Ctl-C to cancel....."
    read -n 1
    clear
}

# Get confirmation for an action
function answerMe() {
    answer='N'
    echo -n "Are you sure to contiune? [Y/N]: "
    read answer
    echo ""
}

# Core display screen
function coreScreen() {
    echo ""
    echo "1. Create VPC"
    echo "2. Create Storage Backend"
    echo "3. Create keypairs"
    echo "4. Create deployment key"
    echo "5. Create Route53 zones"
    echo "6. Create Core Load-balancers"
    echo "7. Create RDS"
    echo "8. Create etcd cluster"
    echo "9. Create admiral"
    echo "10. Create dockerhub"
    echo "11. Create workers"
    echo "88. Exit"
    echo ""
    echo "Note: If resources already exist, current status will be displayed."
    echo -n "Please select one of the options above: "
    read CHOICE 
 
    echo ""
    case $CHOICE in
        1)
            resourceType='vpc'
            createResource
            hitAnyKey
            return $callAgain
            ;;
        2)
            createBuckets
            hitAnyKey
            return $callAgain
            ;;
        3)
            createKeyPairs
            hitAnyKey
            return $callAgain
            ;;
        4)
            setupDeploymentKey
            hitAnyKey
            return $callAgain
            ;;
        5)
            resourceType='route53'
            createResource
            hitAnyKey
            return $callAgain
            ;;
        6)
            resourceType='core-lb'
            createResource
            hitAnyKey
            return $callAgain
            ;;
        7)
            resourceType='rds'
            createResource 
            hitAnyKey
            return $callAgain
            ;;
        8)
            resourceType='etcd'
            createResource 
            hitAnyKey
            return $callAgain
            ;;
        9)
            resourceType='admiral'
            createResource
            hitAnyKey
            return $callAgain
            ;;
        10)
            resourceType='dockerhub'
            createResource
            hitAnyKey
            return $callAgain
            ;;
        11)
            resourceType='hosting'
            createResource
            hitAnyKey
            return $callAgain
            ;;
        88|q|quit|exit)
            exit 0
             ;;
        *)
            clear
            return $callAgain
    esac
} 

# Core display screen
function workerScreen() {
    echo ""
    echo "1. Create VPC"
    echo "2. Create keypairs"
    echo "3. Create workers"
    echo "88. Exit"
    echo ""
    echo "Note: If resources already exist, current status will be displayed."
    echo -n "Please select one of the options above: "
    read CHOICE 
 
    echo ""
    case $CHOICE in
        1)
            resourceType='vpc' 
            createResource
            hitAnyKey
            return $callAgain
            ;;
        2)
            createKeyPairs
            hitAnyKey
            return $callAgain
            ;;
        3)
            resourceType='hosting' 
            createResource
            hitAnyKey
            return $callAgain
            ;;
        88|q|quit|exit)
            exit 0
            ;;
        *)
            clear
            return $callAgain
    esac
} 


################
# Main routine. 
################

if [ "X$1" = "X" ];
then
    echo "Project name is required. The name should match one of your aws profile defined in ~/.aws/credentials."
    exit 1
else 
    awsProfile=$1
    isCore=$(./read_cfg.sh ~/.dockerage/config $awsprofile core)
fi
init
callAgain=99
status=$callAgain
while [ $status -eq $callAgain ]
do
    if [ "$isCore" = "yes" ];
    then
        coreScreen
    else
        workerScreen
    fi
    status=$?
    clear
done

exit 0
