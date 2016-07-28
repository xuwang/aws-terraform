#!/bin/bash
#
# Written by Xueshan Feng <xueshan.feng@gmail.com>
#
# Init variables and sanity checks
export DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
function init() {
    export PROJECTROOT=$DIR
    export GITROOT=$DIR
    export SCRIPTDIR=$GITROOT/scripts
    [ -f $DIR/envs.sh ] && source $DIR/envs.sh

    if [ ! -d $PROJECTROOT ];
    then 
        echo "$PROJECTROOT doesn't exist."
        exit 1
    fi
    aws --profile $AWS_PROFILE support help 2>/dev/null 1>&2
    if [ $? = "255" ];
    then
        echo "Account $AWS_PROFILE doesn't exit."
        exit 1
    fi
    # Update git repo
    cd $GITROOT
    git pull 
}

#############
# Subroutines
#############

# Show all resources
function showAllResources() {
  make show_all | more -R
}

function updateResource() {
  make $resourceType
}

function createCluster() {
  make all -k 2>&1  | tee /tmp/build.$$.log
}

function clusterDistroy() {
  make distroy_app -k 2>&1  | tee /tmp/destroy.$$.log
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
function clusterScreen() {
    echo "===== Cluster Wide Operations ======"
    echo ""
    echo "0. Create Cluster"
    echo "1. Destroy Cluster"
    echo "2. Show all Resources"
    echo 
    echo "===== Update Individual Resources ======"
    echo "3. Admiral"
    echo "4. Worker"
    echo "5. Etcd"
    echo "6. Iam"
    echo "7. Elastic loadbalancer: CI"
    echo "8. Elastic loadbalancer: GitLab"
    echo "9. Elastic loadbalancer: dockerhub"
    echo "10. EFS"
    echo "11. RDS"
    echo "12. Route53"
    echo "13. S3 buckets"
    echo "14. VPC"
    echo "88. Exit"
    echo ""
    echo "Note: If resources already exist, current status will be displayed."
    echo -n "Please select one of the options above: "
    read CHOICE 
 
    echo ""
    case $CHOICE in
 	0)
	    createCluster 
        hitAnyKey
        return $callAgain
	    ;;
        1)
            distroyCluster
            hitAnyKey
            return $callAgain
	    ;;
        2)
            showAllResources
            hitAnyKey
            return $callAgain
	    ;;
        3)
            resourceType='admiral'
            updateResource
            hitAnyKey
            return $callAgain
            ;;
        4)
            resourceType='worker'
            updateResource
            hitAnyKey
            return $callAgain
            ;;
        5)
            resourceType='etcd'
            updateResource
            hitAnyKey
            return $callAgain
            ;;
        6)
            resourceType='iam'
            updateResource
            hitAnyKey
            return $callAgain
            ;;
        7)
            resourceType='elb-ci'
            updateResource
            hitAnyKey
            return $callAgain
            ;;
        8)
            resourceType='elb-gitlab'
            updateResource
            hitAnyKey
            return $callAgain
            ;;
        9)
            resourceType='elb-dockerhub'
            updateResource
            hitAnyKey
            return $callAgain
            ;;
        10)
            resourceType='efs'
            updateResource
            hitAnyKey
            return $callAgain
            ;;
        11)
            resourceType='rds'
            updateResource
            hitAnyKey
            return $callAgain
            ;;
        12)
            resourceType='route53'
            updateResource
            hitAnyKey
            return $callAgain
            ;;
        13)
            resourceType='s3'
            updateResource
            hitAnyKey
            return $callAgain
            ;;
        14)
            resourceType='vpc'
            updateResource
            hitAnyKey
            return $callAgain
            ;;
        88|q|quit|exit)
            # Reminder to uppdate git repo
            cd $GITROOT
            git status
            echo "Please commit changes!"
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

if [ ! -f "envs.sh" ];
then
    echo "Please define required environment variables in envs.sh"
    exit 1
fi
init
callAgain=99
status=$callAgain
while [ $status -eq $callAgain ]
do
    clusterScreen
    status=$?
    clear
done

exit 0

DOCS=<<__END_OF_DOCS__

=head1 NAME

install-pacific - Menu-driven script to install Pacific docker platform.

=head1 FILES

The script reads the platform configuration from $HOME/.aws

=head1 AUTHORS

Xueshan Feng <sfeng@stanford.edu>

=cut
